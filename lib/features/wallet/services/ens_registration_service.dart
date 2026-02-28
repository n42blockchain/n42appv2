// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/services/ens_models.dart';
import 'package:web3dart/web3dart.dart';

export 'package:n42_wallet/features/wallet/services/ens_management_service.dart';
export 'package:n42_wallet/features/wallet/services/ens_models.dart';

/// ENS 注册服务
///
/// 提供 ENS 域名的完整生命周期管理：
/// - 可用性检查
/// - 价格查询
/// - 两步注册 (commit + register)
/// - 续费、记录管理、转移、子域名管理（见 EnsManagementService extension）
class EnsRegistrationService {
  final String _baseUrl;
  final Map<String, String> _headers;

  /// 待处理的注册承诺缓存
  final Map<String, CommitResult> _pendingCommitments = {};

  EnsRegistrationService()
      : _baseUrl = AppConfig.getApiUrlOnline('tokenViewUri'),
        _headers = {'content-type': 'application/json'};

  /// 去除 .eth 后缀的基础名称
  String _baseName(String name) => normalizeName(name).replaceAll('.eth', '');

  // ============ 查询功能 ============

  /// 检查 ENS 名称可用性
  ///
  /// [name] - ENS 名称 (可以带或不带 .eth 后缀)
  Future<EnsAvailabilityResult> checkAvailability(String name) async {
    final normalizedName = normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.get(
        '${_baseUrl}v1/ens/available',
        params: {'domain': normalizedName},
        header: _headers,
      );

      if (response['code'] == 200) {
        final data = response['data'];
        if (data['available'] == true) {
          return EnsAvailabilityResult.available(normalizedName);
        } else {
          return EnsAvailabilityResult.unavailable(
            normalizedName,
            expiresAt: data['expiresAt'] != null
                ? DateTime.parse(data['expiresAt'] as String)
                : null,
            ownerAddress: data['owner'] as String?,
          );
        }
      } else {
        return EnsAvailabilityResult.error(
          normalizedName,
          response['msg']?.toString() ?? 'Unknown error',
        );
      }
    } catch (e) {
      debugPrint('ENS availability check error: $e');
      return EnsAvailabilityResult.error(normalizedName, e.toString());
    }
  }

  /// 获取 ENS 注册价格
  ///
  /// [name] - ENS 名称，[years] - 注册年限
  Future<MessageModel> getPrice(String name, int years) async {
    final mm = MessageModel();

    try {
      final response = await BaseApi.requestEmptyH.get(
        '${_baseUrl}v1/ens/price',
        params: {'domain': normalizeName(name), 'years': years.toString()},
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = EnsPrice.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        mm.error = true;
      }
    } catch (e) {
      debugPrint('ENS price query error: $e');
      mm.error = true;
    }

    return mm;
  }

  /// 获取地址拥有的所有 ENS 名称
  ///
  /// [address] - 以太坊地址
  Future<MessageModel> getOwnedNames(String address) async {
    final mm = MessageModel();

    try {
      final response = await BaseApi.requestEmptyH.get(
        '${_baseUrl}v1/ens/owned',
        params: {'address': address.toLowerCase()},
        header: _headers,
      );

      if (response['code'] == 200) {
        final dataList = response['data'] as List<dynamic>?;
        mm.error = false;
        mm.data = (dataList ?? [])
            .map((e) => OwnedEns.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        mm.error = true;
        mm.data = <OwnedEns>[];
      }
    } catch (e) {
      debugPrint('ENS owned names query error: $e');
      mm.error = true;
      mm.data = <OwnedEns>[];
    }

    return mm;
  }

  // ============ 注册流程 ============

  /// 生成注册密钥
  String _generateSecret() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return '0x${bytesToHex(Uint8List.fromList(bytes))}';
  }

  /// 计算承诺哈希
  ///
  /// commitment = keccak256(abi.encode(name, owner, secret))
  /// 实际实现需要与 ENS 合约的 makeCommitment 函数一致
  String _calculateCommitment(String name, String owner, String secret) {
    final nameBytes = utf8.encode(name);
    final ownerBytes = hexToBytes(owner.replaceFirst('0x', '').padLeft(64, '0'));
    final secretBytes = hexToBytes(secret.replaceFirst('0x', ''));

    final combined = Uint8List(nameBytes.length + 32 + 32);
    combined.setAll(0, nameBytes);
    combined.setAll(nameBytes.length, ownerBytes);
    combined.setAll(nameBytes.length + 32, secretBytes);

    return '0x${bytesToHex(keccak256(combined))}';
  }

  /// 第一步：提交注册承诺
  ///
  /// [name] - ENS 名称 (不含 .eth 后缀)
  /// [owner] - 所有者地址
  /// [secret] - 可选，如果不提供则自动生成
  Future<MessageModel> commit(
    String name,
    String owner, {
    String? secret,
  }) async {
    final mm = MessageModel();
    final normalizedName = _baseName(name);
    final secretValue = secret ?? _generateSecret();

    try {
      final commitment = _calculateCommitment(normalizedName, owner, secretValue);
      final body = {
        'name': normalizedName,
        'owner': owner,
        'commitment': commitment,
      };

      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/commit',
        params: body,
        data: body,
        header: _headers,
      );

      if (response['code'] == 200) {
        final result = CommitResult(
          commitmentHash: commitment,
          secret: secretValue,
          txHash: response['data']['txHash'] as String?,
          commitTime: DateTime.now(),
          minWaitTime: response['data']['minWaitTime'] as int? ?? 60,
          maxWaitTime: response['data']['maxWaitTime'] as int? ?? 86400,
        );
        _pendingCommitments[normalizedName] = result;
        mm.error = false;
        mm.data = result;
      } else {
        mm.error = true;
      }
    } catch (e) {
      debugPrint('ENS commit error: $e');
      mm.error = true;
    }

    return mm;
  }

  /// 获取待处理的承诺
  CommitResult? getPendingCommitment(String name) {
    return _pendingCommitments[_baseName(name)];
  }

  /// 回滚注册承诺（best-effort）
  ///
  /// 当注册失败且承诺已过期时调用。
  /// 清除本地缓存并通知服务端回滚，服务端可将未完成的 order 标记为废弃。
  /// 此操作是 best-effort：服务端通知失败不会影响本地状态清理。
  Future<void> rollbackCommit(String name) async {
    final normalizedName = _baseName(name);
    _pendingCommitments.remove(normalizedName);
    try {
      await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/rollback',
        params: <String, dynamic>{},
        data: {'name': normalizedName},
        header: _headers,
      );
    } catch (e) {
      // best-effort：服务端通知失败不影响本地状态
      debugPrint('ENS rollback notify error: $e');
    }
  }

  /// 第二步：执行注册
  ///
  /// [params] - 注册参数
  Future<MessageModel> register(RegisterParams params) async {
    final mm = MessageModel();

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/register',
        params: params.toJson(),
        data: params.toJson(),
        header: _headers,
      );

      if (response['code'] == 200) {
        final data = response['data'];
        _pendingCommitments.remove(params.name);
        mm.error = false;
        mm.data = RegisterResult.success(
          txHash: data['txHash'] as String,
          name: '${params.name}.eth',
          expiresAt: DateTime.parse(data['expiresAt'] as String),
        );
      } else {
        final errCode = response['code'] as int? ?? 0;
        final errMsg = response['msg']?.toString() ?? 'Registration failed';
        // 仅信任服务端明确的错误码 4001 判断承诺过期
        // 避免依赖 errMsg 字符串匹配——服务端可在任何消息中注入 "expired" 关键词
        final isExpired = errCode == 4001;
        if (isExpired) {
          await rollbackCommit(params.name);
        }
        // 非过期错误（网络抖动、gas 不足等）保留缓存，允许 UI 层重试
        mm.error = true;
        mm.data = RegisterResult.failure(
          params.name,
          isExpired ? EnsRegisterErrorType.commitmentExpired.name : errMsg,
        );
      }
    } catch (e) {
      debugPrint('ENS register error: $e');
      mm.error = true;
      mm.data = RegisterResult.failure(params.name, e.toString());
    }

    return mm;
  }

  // ============ 辅助方法 ============

  /// 已知 ENS 域名后缀（顺序无关，仅用于 endsWith 检查）
  static const _knownSuffixes = ['.eth', '.n42', '.arb'];

  /// 标准化 ENS 名称
  ///
  /// 若名称已有已知后缀（.eth / .n42 / .arb 等）则不修改；
  /// 否则追加 .eth（向后兼容）。
  String normalizeName(String name) {
    final normalized = name.toLowerCase().trim();
    if (_knownSuffixes.any((s) => normalized.endsWith(s))) {
      return normalized;
    }
    return '$normalized.eth';
  }

  /// 验证 ENS 名称格式（至少3字符，仅含字母/数字/连字符，不可首尾为连字符）
  bool isValidEnsName(String name) {
    final normalized = _baseName(name);
    if (normalized.length < 3) return false;
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(normalized)) return false;
    if (normalized.startsWith('-') || normalized.endsWith('-')) return false;
    return true;
  }

  /// 获取名称长度定价等级
  ///
  /// - 3 字符: premium（最贵）
  /// - 4 字符: standard（中等）
  /// - 5+ 字符: basic（基础价格）
  String getPricingTier(String name) {
    final length = _baseName(name).length;
    if (length == 3) return 'premium';
    if (length == 4) return 'standard';
    return 'basic';
  }

  /// 清理过期的承诺缓存
  void cleanExpiredCommitments() {
    _pendingCommitments.removeWhere((_, commit) => commit.isExpired);
  }

  /// 获取所有待处理的承诺（只读视图）
  Map<String, CommitResult> get pendingCommitments =>
      Map.unmodifiable(_pendingCommitments);

  /// 暴露给 extension 的网络配置
  String get baseUrl => _baseUrl;
  Map<String, String> get headers => _headers;
}

/// ENS 注册服务单例
class EnsRegistrationServiceProvider {
  static EnsRegistrationService? _instance;

  static EnsRegistrationService get instance {
    _instance ??= EnsRegistrationService();
    return _instance!;
  }

  /// 重置实例（用于测试）
  static void reset() {
    _instance = null;
  }
}
