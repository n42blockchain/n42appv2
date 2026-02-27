// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

/// ENS 域名管理操作（续费、记录更新、转移、子域名）
///
/// 作为 [EnsRegistrationService] 的 extension，共享网络配置，
/// 无需重复持有 baseUrl / headers。
extension EnsManagementService on EnsRegistrationService {
  // ============ 内部辅助 ============

  /// 通用 POST 辅助：提交请求并返回 txHash 或错误信息
  ///
  /// 成功时 mm.data = txHash（String），失败时 mm.data = 错误消息（String）。
  Future<MessageModel> _postTxHash(
    String path,
    Map<String, dynamic> body, {
    String fallbackError = 'Operation failed',
    String debugLabel = 'ENS',
  }) async {
    final mm = MessageModel();
    try {
      final response = await BaseApi.requestEmptyH.post(
        '$baseUrl$path',
        params: <String, dynamic>{},
        data: body,
        header: headers,
      );

      if (response['code'] == 200) {
        mm.error = false;
        mm.data = response['data']?['txHash'];
      } else {
        mm.error = true;
        mm.data = response['msg']?.toString() ?? fallbackError;
      }
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      mm.error = true;
      mm.data = e.toString();
    }
    return mm;
  }

  // ============ 续费 ============

  /// 续费 ENS 名称
  ///
  /// [name] - ENS 名称，[years] - 续费年限
  Future<MessageModel> renew(String name, int years) async {
    final normalizedName = normalizeName(name);

    try {
      final response = await BaseApi.requestEmptyH.post(
        '${baseUrl}v1/ens/renew',
        params: {'name': normalizedName, 'years': years},
        data: {'name': normalizedName, 'years': years},
        header: headers,
      );

      final mm = MessageModel();
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
      return mm;
    } catch (e) {
      debugPrint('ENS renew error: $e');
      return MessageModel()
        ..error = true
        ..data = RenewResult.failure(normalizedName, e.toString());
    }
  }

  // ============ 记录管理 ============

  /// 设置文本记录
  ///
  /// [name] - ENS 名称，[key] - 记录键 (如 'email', 'url', 'com.twitter')，[value] - 记录值
  Future<MessageModel> setTextRecord(String name, String key, String value) {
    return _postTxHash(
      'v1/ens/update-record',
      {'name': normalizeName(name), 'key': key, 'value': value},
      fallbackError: 'Update failed',
      debugLabel: 'ENS set text record',
    );
  }

  /// 批量设置文本记录
  ///
  /// [name] - ENS 名称，[records] - 记录键值对
  Future<MessageModel> setTextRecords(String name, Map<String, String> records) {
    return _postTxHash(
      'v1/ens/update-records',
      {'name': normalizeName(name), 'records': records},
      fallbackError: 'Update failed',
      debugLabel: 'ENS set text records',
    );
  }

  /// 设置解析地址
  ///
  /// [name] - ENS 名称，[address] - 目标地址
  Future<MessageModel> setAddress(String name, String address) {
    return _postTxHash(
      'v1/ens/set-address',
      {'name': normalizeName(name), 'address': address},
      fallbackError: 'Update failed',
      debugLabel: 'ENS set address',
    );
  }

  /// 转移 ENS 名称所有权
  ///
  /// [name] - ENS 名称，[newOwner] - 新所有者地址
  Future<MessageModel> transfer(String name, String newOwner) {
    return _postTxHash(
      'v1/ens/transfer',
      {'name': normalizeName(name), 'newOwner': newOwner},
      fallbackError: 'Transfer failed',
      debugLabel: 'ENS transfer',
    );
  }

  /// 设置主要名称 (反向解析)
  ///
  /// [name] - ENS 名称，[address] - 设置反向解析的地址
  Future<MessageModel> setPrimaryName(String name, String address) {
    return _postTxHash(
      'v1/ens/set-primary',
      {'name': normalizeName(name), 'address': address},
      fallbackError: 'Set primary failed',
      debugLabel: 'ENS set primary',
    );
  }

  // ============ 子域名管理 ============

  /// 获取域名下所有子域名列表
  ///
  /// [name] — 父域名（如 alice.eth）
  Future<MessageModel> getSubdomains(String name) async {
    final mm = MessageModel();

    try {
      final response = await BaseApi.requestEmptyH.get(
        '${baseUrl}v1/ens/subdomains',
        params: {'name': normalizeName(name)},
        header: headers,
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
  }) {
    final body = <String, dynamic>{
      'parent': normalizeName(parent),
      'label': label.toLowerCase().trim(),
      'owner': owner,
    };
    if (resolver != null && resolver.isNotEmpty) {
      body['resolver'] = resolver;
    }
    return _postTxHash(
      'v1/ens/create-subdomain',
      body,
      fallbackError: 'Create subdomain failed',
      debugLabel: 'ENS create subdomain',
    );
  }

  /// 删除子域名（将所有者设为零地址，释放子域名控制权）
  ///
  /// [parent] — 父域名（如 alice.eth），[label]  — 子域名标签（如 blog）
  Future<MessageModel> deleteSubdomain(String parent, String label) {
    return _postTxHash(
      'v1/ens/delete-subdomain',
      {
        'parent': normalizeName(parent),
        'label': label.toLowerCase().trim(),
      },
      fallbackError: 'Delete subdomain failed',
      debugLabel: 'ENS delete subdomain',
    );
  }

  /// 验证子域名标签格式（字母 / 数字 / 连字符，不可首尾为连字符）
  bool isValidSubdomainLabel(String label) {
    final normalized = label.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(normalized)) return false;
    if (normalized.startsWith('-') || normalized.endsWith('-')) return false;
    return true;
  }
}
