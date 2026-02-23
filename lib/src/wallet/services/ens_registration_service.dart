// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/http/base_api.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:web3dart/web3dart.dart';

/// ENS 价格信息
class EnsPrice {
  /// 基础价格 (ETH)
  final double basePrice;

  /// 年费 (ETH)
  final double annualPrice;

  /// 总价 (ETH)
  final double totalPrice;

  /// 注册年限
  final int years;

  /// ENS 名称长度
  final int nameLength;

  /// 价格更新时间
  final DateTime updatedAt;

  /// 美元估值
  final double? usdPrice;

  const EnsPrice({
    required this.basePrice,
    required this.annualPrice,
    required this.totalPrice,
    required this.years,
    required this.nameLength,
    required this.updatedAt,
    this.usdPrice,
  });

  factory EnsPrice.fromJson(Map<String, dynamic> json) {
    return EnsPrice(
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      annualPrice: (json['annualPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      years: json['years'] as int? ?? 1,
      nameLength: json['nameLength'] as int? ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      usdPrice: (json['usdPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'annualPrice': annualPrice,
      'totalPrice': totalPrice,
      'years': years,
      'nameLength': nameLength,
      'updatedAt': updatedAt.toIso8601String(),
      'usdPrice': usdPrice,
    };
  }

  /// 获取格式化的总价
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(4)} ETH';

  /// 获取格式化的年费
  String get formattedAnnualPrice => '${annualPrice.toStringAsFixed(4)} ETH/year';
}

/// ENS 可用性检查结果
class EnsAvailabilityResult {
  /// ENS 名称
  final String name;

  /// 是否可用
  final bool isAvailable;

  /// 如果不可用，到期时间
  final DateTime? expiresAt;

  /// 当前所有者地址
  final String? ownerAddress;

  /// 错误信息
  final String? error;

  const EnsAvailabilityResult({
    required this.name,
    required this.isAvailable,
    this.expiresAt,
    this.ownerAddress,
    this.error,
  });

  factory EnsAvailabilityResult.available(String name) {
    return EnsAvailabilityResult(
      name: name,
      isAvailable: true,
    );
  }

  factory EnsAvailabilityResult.unavailable(
    String name, {
    DateTime? expiresAt,
    String? ownerAddress,
  }) {
    return EnsAvailabilityResult(
      name: name,
      isAvailable: false,
      expiresAt: expiresAt,
      ownerAddress: ownerAddress,
    );
  }

  factory EnsAvailabilityResult.error(String name, String error) {
    return EnsAvailabilityResult(
      name: name,
      isAvailable: false,
      error: error,
    );
  }

  factory EnsAvailabilityResult.fromJson(Map<String, dynamic> json) {
    return EnsAvailabilityResult(
      name: json['name'] as String,
      isAvailable: json['isAvailable'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      ownerAddress: json['ownerAddress'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// 已拥有的 ENS 信息
class OwnedEns {
  /// ENS 名称
  final String name;

  /// 所有者地址
  final String ownerAddress;

  /// 解析到的地址 (可能与所有者不同)
  final String? resolvedAddress;

  /// 到期时间
  final DateTime expiresAt;

  /// 注册时间
  final DateTime? registeredAt;

  /// 头像 URL
  final String? avatar;

  /// 是否是主要名称 (反向解析)
  final bool isPrimary;

  /// 文本记录
  final Map<String, String>? textRecords;

  const OwnedEns({
    required this.name,
    required this.ownerAddress,
    this.resolvedAddress,
    required this.expiresAt,
    this.registeredAt,
    this.avatar,
    this.isPrimary = false,
    this.textRecords,
  });

  factory OwnedEns.fromJson(Map<String, dynamic> json) {
    return OwnedEns(
      name: json['name'] as String,
      ownerAddress: json['ownerAddress'] as String,
      resolvedAddress: json['resolvedAddress'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : null,
      avatar: json['avatar'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      textRecords: json['textRecords'] != null
          ? Map<String, String>.from(json['textRecords'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ownerAddress': ownerAddress,
      'resolvedAddress': resolvedAddress,
      'expiresAt': expiresAt.toIso8601String(),
      'registeredAt': registeredAt?.toIso8601String(),
      'avatar': avatar,
      'isPrimary': isPrimary,
      'textRecords': textRecords,
    };
  }

  /// 检查是否即将过期 (30 天内)
  bool get isExpiringSoon {
    final daysUntilExpiry = expiresAt.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// 检查是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 获取剩余天数
  int get daysUntilExpiry {
    final days = expiresAt.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  /// 获取格式化的过期时间
  String get formattedExpiresAt {
    return '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')}';
  }
}

/// ENS 子域名信息
class SubdomainInfo {
  /// 子域名标签（不含父域名，如 "blog"）
  final String label;

  /// 完整名称（如 "blog.alice.eth"）
  final String fullName;

  /// 所有者地址
  final String owner;

  /// 解析器合约地址（可选）
  final String? resolver;

  const SubdomainInfo({
    required this.label,
    required this.fullName,
    required this.owner,
    this.resolver,
  });

  factory SubdomainInfo.fromJson(Map<String, dynamic> json) {
    return SubdomainInfo(
      label: json['label'] as String,
      fullName: json['fullName'] as String,
      owner: json['owner'] as String,
      resolver: json['resolver'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'fullName': fullName,
        'owner': owner,
        'resolver': resolver,
      };

  /// 地址是否为零地址（即子域名已被删除）
  bool get isDeleted =>
      owner == '0x0000000000000000000000000000000000000000';
}

/// 注册承诺结果
class CommitResult {
  /// 承诺哈希
  final String commitmentHash;

  /// 秘密值 (需要保存用于注册)
  final String secret;

  /// 承诺交易哈希
  final String? txHash;

  /// 承诺时间戳
  final DateTime commitTime;

  /// 最小等待时间 (秒)
  final int minWaitTime;

  /// 最大等待时间 (秒)
  final int maxWaitTime;

  const CommitResult({
    required this.commitmentHash,
    required this.secret,
    this.txHash,
    required this.commitTime,
    this.minWaitTime = 60,
    this.maxWaitTime = 86400,
  });

  factory CommitResult.fromJson(Map<String, dynamic> json) {
    return CommitResult(
      commitmentHash: json['commitmentHash'] as String,
      secret: json['secret'] as String,
      txHash: json['txHash'] as String?,
      commitTime: DateTime.parse(json['commitTime'] as String),
      minWaitTime: json['minWaitTime'] as int? ?? 60,
      maxWaitTime: json['maxWaitTime'] as int? ?? 86400,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commitmentHash': commitmentHash,
      'secret': secret,
      'txHash': txHash,
      'commitTime': commitTime.toIso8601String(),
      'minWaitTime': minWaitTime,
      'maxWaitTime': maxWaitTime,
    };
  }

  /// 检查是否可以注册
  bool get canRegister {
    final elapsed = DateTime.now().difference(commitTime).inSeconds;
    return elapsed >= minWaitTime && elapsed <= maxWaitTime;
  }

  /// 获取剩余等待时间 (秒)
  int get remainingWaitTime {
    final elapsed = DateTime.now().difference(commitTime).inSeconds;
    final remaining = minWaitTime - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// 检查承诺是否已过期
  bool get isExpired {
    final elapsed = DateTime.now().difference(commitTime).inSeconds;
    return elapsed > maxWaitTime;
  }
}

/// 注册参数
class RegisterParams {
  /// ENS 名称 (不含 .eth 后缀)
  final String name;

  /// 所有者地址
  final String owner;

  /// 注册年限
  final int years;

  /// 秘密值 (来自 CommitResult)
  final String secret;

  /// 解析到的地址 (可选，默认为所有者)
  final String? resolver;

  /// 是否设置为反向解析
  final bool setReverseRecord;

  /// 自定义文本记录
  final Map<String, String>? textRecords;

  const RegisterParams({
    required this.name,
    required this.owner,
    required this.years,
    required this.secret,
    this.resolver,
    this.setReverseRecord = true,
    this.textRecords,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'years': years,
      'secret': secret,
      'resolver': resolver,
      'setReverseRecord': setReverseRecord,
      'textRecords': textRecords,
    };
  }
}

/// 注册结果
class RegisterResult {
  /// 是否成功
  final bool success;

  /// 交易哈希
  final String? txHash;

  /// ENS 名称
  final String name;

  /// 到期时间
  final DateTime? expiresAt;

  /// 错误信息
  final String? error;

  const RegisterResult({
    required this.success,
    this.txHash,
    required this.name,
    this.expiresAt,
    this.error,
  });

  factory RegisterResult.success({
    required String txHash,
    required String name,
    required DateTime expiresAt,
  }) {
    return RegisterResult(
      success: true,
      txHash: txHash,
      name: name,
      expiresAt: expiresAt,
    );
  }

  factory RegisterResult.failure(String name, String error) {
    return RegisterResult(
      success: false,
      name: name,
      error: error,
    );
  }

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      success: json['success'] as bool? ?? false,
      txHash: json['txHash'] as String?,
      name: json['name'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      error: json['error'] as String?,
    );
  }
}

/// 续费结果
class RenewResult {
  /// 是否成功
  final bool success;

  /// 交易哈希
  final String? txHash;

  /// ENS 名称
  final String name;

  /// 新的到期时间
  final DateTime? newExpiresAt;

  /// 错误信息
  final String? error;

  const RenewResult({
    required this.success,
    this.txHash,
    required this.name,
    this.newExpiresAt,
    this.error,
  });

  factory RenewResult.success({
    required String txHash,
    required String name,
    required DateTime newExpiresAt,
  }) {
    return RenewResult(
      success: true,
      txHash: txHash,
      name: name,
      newExpiresAt: newExpiresAt,
    );
  }

  factory RenewResult.failure(String name, String error) {
    return RenewResult(
      success: false,
      name: name,
      error: error,
    );
  }
}


/// ENS 注册错误类型
///
/// 用于区分可重试的瞬时错误与需要完整重启的过期错误。
enum EnsRegisterErrorType {
  /// 承诺哈希已过期，需要重新 commit（maxWaitTime 已超出）
  commitmentExpired,

  /// 承诺尚未到达最小等待时间（过早调用 register）
  tooEarly,

  /// 可重试的瞬时错误（网络抖动、gas 不足等）
  transient,

  /// 未知错误
  unknown,
}

/// ENS 注册服务
///
/// 提供 ENS 域名的完整生命周期管理：
/// - 可用性检查
/// - 价格查询
/// - 两步注册 (commit + register)
/// - 续费
/// - 记录管理
/// - 转移
class EnsRegistrationService {
  final String _baseUrl;
  final Map<String, String> _headers;

  /// 待处理的注册承诺缓存
  final Map<String, CommitResult> _pendingCommitments = {};

  EnsRegistrationService()
      : _baseUrl = AppConfig.getApiUrlOnline('tokenViewUri'),
        _headers = {'content-type': 'application/json'};

  // ============ 查询功能 ============

  /// 检查 ENS 名称可用性
  ///
  /// [name] - ENS 名称 (可以带或不带 .eth 后缀)
  Future<EnsAvailabilityResult> checkAvailability(String name) async {
    final normalizedName = _normalizeName(name);

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
  /// [name] - ENS 名称
  /// [years] - 注册年限
  Future<MessageModel> getPrice(String name, int years) async {
    final normalizedName = _normalizeName(name);
    final mm = MessageModel();

    try {
      final response = await BaseApi.requestEmptyH.get(
        '${_baseUrl}v1/ens/price',
        params: {
          'domain': normalizedName,
          'years': years.toString(),
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = EnsPrice.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        mm.error = true;
        mm.data = null;
      }
    } catch (e) {
      debugPrint('ENS price query error: $e');
      mm.error = true;
      mm.data = null;
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
        if (dataList != null) {
          mm.error = false;
          mm.data = dataList
              .map((e) => OwnedEns.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          mm.error = false;
          mm.data = [];
        }
      } else {
        mm.error = true;
        mm.data = [];
      }
    } catch (e) {
      debugPrint('ENS owned names query error: $e');
      mm.error = true;
      mm.data = [];
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
  String _calculateCommitment(String name, String owner, String secret) {
    // 简化的承诺哈希计算
    // 实际实现需要与 ENS 合约的 makeCommitment 函数一致
    final nameBytes = utf8.encode(name);
    final ownerBytes = hexToBytes(owner.replaceFirst('0x', '').padLeft(64, '0'));
    final secretBytes = hexToBytes(secret.replaceFirst('0x', ''));

    final combined = Uint8List(nameBytes.length + 32 + 32);
    combined.setAll(0, nameBytes);
    combined.setAll(nameBytes.length, ownerBytes);
    combined.setAll(nameBytes.length + 32, secretBytes);

    final hash = keccak256(combined);
    return '0x${bytesToHex(hash)}';
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
    final normalizedName = _normalizeName(name).replaceAll('.eth', '');
    final secretValue = secret ?? _generateSecret();

    try {
      final commitment = _calculateCommitment(normalizedName, owner, secretValue);

      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/commit',
        params: {
          'name': normalizedName,
          'owner': owner,
          'commitment': commitment,
        },
        data: {
          'name': normalizedName,
          'owner': owner,
          'commitment': commitment,
        },
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

        // 缓存承诺信息
        _pendingCommitments[normalizedName] = result;

        mm.error = false;
        mm.data = result;
      } else {
        mm.error = true;
        mm.data = null;
      }
    } catch (e) {
      debugPrint('ENS commit error: $e');
      mm.error = true;
      mm.data = null;
    }

    return mm;
  }

  /// 获取待处理的承诺
  CommitResult? getPendingCommitment(String name) {
    final normalizedName = _normalizeName(name).replaceAll('.eth', '');
    return _pendingCommitments[normalizedName];
  }


  /// 回滚注册承诺（best-effort）
  ///
  /// 当注册失败且承诺已过期时调用。
  /// 清除本地缓存并通知服务端回滚，服务端可将未完成的 order 标记为废弃。
  /// 此操作是 best-effort：服务端通知失败不会影响本地状态清理。
  ///
  /// [name] - ENS 名称（含或不含 .eth 后缀均可）
  Future<void> rollbackCommit(String name) async {
    final normalizedName = _normalizeName(name).replaceAll('.eth', '');
    // 立即清除本地缓存
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
        final result = RegisterResult.success(
          txHash: data['txHash'] as String,
          name: '${params.name}.eth',
          expiresAt: DateTime.parse(data['expiresAt'] as String),
        );

        // 清除缓存的承诺
        _pendingCommitments.remove(params.name);

        mm.error = false;
        mm.data = result;
      } else {
        final errCode = response['code'] as int? ?? 0;
        final errMsg = response['msg']?.toString() ?? 'Registration failed';
        // 判断是否是承诺过期错误（服务端约定：4001 或消息含 expired/commitment not valid）
        // 仅信任服务端明确的错误码 4001 判断承诺过期
        // 避免依赖 errMsg 字符串匹配——服务端可在任何消息中注入 "expired" 关键词
        final isExpired = errCode == 4001;
        if (isExpired) {
          // 承诺过期：清除本地缓存并通知服务端回滚
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

  // ============ 管理功能 ============

  /// 续费 ENS 名称
  ///
  /// [name] - ENS 名称
  /// [years] - 续费年限
  Future<MessageModel> renew(String name, int years) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/renew',
        params: {
          'name': normalizedName,
          'years': years,
        },
        data: {
          'name': normalizedName,
          'years': years,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        final data = response['data'];
        mm.error = false;
        mm.data = RenewResult.success(
          txHash: data['txHash'] as String,
          name: normalizedName,
          newExpiresAt: DateTime.parse(data['expiresAt'] as String),
        );
      } else {
        mm.error = true;
        mm.data = RenewResult.failure(
          normalizedName,
          response['msg']?.toString() ?? 'Renewal failed',
        );
      }
    } catch (e) {
      debugPrint('ENS renew error: $e');
      mm.error = true;
      mm.data = RenewResult.failure(normalizedName, e.toString());
    }

    return mm;
  }

  /// 设置文本记录
  ///
  /// [name] - ENS 名称
  /// [key] - 记录键 (如 'email', 'url', 'com.twitter')
  /// [value] - 记录值
  Future<MessageModel> setTextRecord(
    String name,
    String key,
    String value,
  ) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/update-record',
        params: {
          'name': normalizedName,
          'key': key,
          'value': value,
        },
        data: {
          'name': normalizedName,
          'key': key,
          'value': value,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Update failed';
      }
    } catch (e) {
      debugPrint('ENS set text record error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  /// 批量设置文本记录
  ///
  /// [name] - ENS 名称
  /// [records] - 记录键值对
  Future<MessageModel> setTextRecords(
    String name,
    Map<String, String> records,
  ) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/update-records',
        params: {
          'name': normalizedName,
          'records': records,
        },
        data: {
          'name': normalizedName,
          'records': records,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Update failed';
      }
    } catch (e) {
      debugPrint('ENS set text records error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  /// 设置解析地址
  ///
  /// [name] - ENS 名称
  /// [address] - 目标地址
  Future<MessageModel> setAddress(String name, String address) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/set-address',
        params: {
          'name': normalizedName,
          'address': address,
        },
        data: {
          'name': normalizedName,
          'address': address,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Update failed';
      }
    } catch (e) {
      debugPrint('ENS set address error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  /// 转移 ENS 名称所有权
  ///
  /// [name] - ENS 名称
  /// [newOwner] - 新所有者地址
  Future<MessageModel> transfer(String name, String newOwner) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/transfer',
        params: {
          'name': normalizedName,
          'newOwner': newOwner,
        },
        data: {
          'name': normalizedName,
          'newOwner': newOwner,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Transfer failed';
      }
    } catch (e) {
      debugPrint('ENS transfer error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  /// 设置主要名称 (反向解析)
  ///
  /// [name] - ENS 名称
  /// [address] - 设置反向解析的地址
  Future<MessageModel> setPrimaryName(String name, String address) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/set-primary',
        params: {
          'name': normalizedName,
          'address': address,
        },
        data: {
          'name': normalizedName,
          'address': address,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Set primary failed';
      }
    } catch (e) {
      debugPrint('ENS set primary error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  // ============ 子域名管理 ============

  /// 获取域名下所有子域名列表
  ///
  /// [name] — 父域名（如 alice.eth）
  Future<MessageModel> getSubdomains(String name) async {
    final mm = MessageModel();
    final normalizedName = _normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.get(
        '${_baseUrl}v1/ens/subdomains',
        params: {'name': normalizedName},
        header: _headers,
      );

      if (response['code'] == 200) {
        final dataList = response['data'] as List<dynamic>?;
        mm.error = false;
        mm.data = (dataList ?? [])
            .map((e) => SubdomainInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        mm.error = true;
        mm.data = <SubdomainInfo>[];
      }
    } catch (e) {
      debugPrint('ENS get subdomains error: $e');
      mm.error = true;
      mm.data = <SubdomainInfo>[];
    }

    return mm;
  }

  /// 创建子域名
  ///
  /// [parent]   — 父域名（如 alice.eth）
  /// [label]    — 子域名标签（如 blog → blog.alice.eth）
  /// [owner]    — 子域名所有者地址
  /// [resolver] — 解析器合约地址（可选，留空使用父域名解析器）
  Future<MessageModel> createSubdomain(
    String parent,
    String label,
    String owner, {
    String? resolver,
  }) async {
    final mm = MessageModel();
    final normalizedParent = _normalizeName(parent);
    final normalizedLabel = label.toLowerCase().trim();

    try {
      final body = <String, dynamic>{
        'parent': normalizedParent,
        'label': normalizedLabel,
        'owner': owner,
      };
      if (resolver != null && resolver.isNotEmpty) {
        body['resolver'] = resolver;
      }

      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/create-subdomain',
        params: <String, dynamic>{},
        data: body,
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']?['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Create subdomain failed';
      }
    } catch (e) {
      debugPrint('ENS create subdomain error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  /// 删除子域名（将所有者设为零地址，释放子域名控制权）
  ///
  /// [parent] — 父域名（如 alice.eth）
  /// [label]  — 子域名标签（如 blog）
  Future<MessageModel> deleteSubdomain(String parent, String label) async {
    final mm = MessageModel();
    final normalizedParent = _normalizeName(parent);
    final normalizedLabel = label.toLowerCase().trim();

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${_baseUrl}v1/ens/delete-subdomain',
        params: <String, dynamic>{},
        data: {
          'parent': normalizedParent,
          'label': normalizedLabel,
        },
        header: _headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']?['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? 'Delete subdomain failed';
      }
    } catch (e) {
      debugPrint('ENS delete subdomain error: $e');
      mm.error = true;
      mm.data = e.toString();
    }

    return mm;
  }

  /// 验证子域名标签格式（字母 / 数字 / 连字符，不可首尾为连字符）
  bool isValidSubdomainLabel(String label) {
    final normalized = label.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    final validChars = RegExp(r'^[a-z0-9-]+$');
    if (!validChars.hasMatch(normalized)) return false;
    if (normalized.startsWith('-') || normalized.endsWith('-')) return false;
    return true;
  }

  // ============ 辅助方法 ============

  /// 已知 ENS 域名后缀（顺序无关，仅用于 endsWith 检查）
  static const _knownSuffixes = ['.eth', '.n42', '.arb'];

  /// 标准化 ENS 名称
  ///
  /// 若名称已有已知后缀（.eth / .n42 / .arb / .base.eth 等）则不修改；
  /// 否则追加 .eth（向后兼容）。
  String _normalizeName(String name) {
    var normalized = name.toLowerCase().trim();
    if (!_knownSuffixes.any((s) => normalized.endsWith(s))) {
      normalized = '$normalized.eth';
    }
    return normalized;
  }

  /// 验证 ENS 名称格式
  bool isValidEnsName(String name) {
    final normalized = _normalizeName(name).replaceAll('.eth', '');

    // 至少 3 个字符
    if (normalized.length < 3) return false;

    // 只能包含字母、数字和连字符
    final validChars = RegExp(r'^[a-z0-9-]+$');
    if (!validChars.hasMatch(normalized)) return false;

    // 不能以连字符开头或结尾
    if (normalized.startsWith('-') || normalized.endsWith('-')) return false;

    return true;
  }

  /// 获取名称长度定价等级
  ///
  /// - 3 字符: 最贵
  /// - 4 字符: 中等
  /// - 5+ 字符: 基础价格
  String getPricingTier(String name) {
    final length = _normalizeName(name).replaceAll('.eth', '').length;
    if (length == 3) return 'premium';
    if (length == 4) return 'standard';
    return 'basic';
  }

  /// 清理过期的承诺缓存
  void cleanExpiredCommitments() {
    _pendingCommitments.removeWhere((_, commit) => commit.isExpired);
  }

  /// 获取所有待处理的承诺
  Map<String, CommitResult> get pendingCommitments =>
      Map.unmodifiable(_pendingCommitments);
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
