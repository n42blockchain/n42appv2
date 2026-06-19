// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// ENS 数据模型
// 包含 ENS 域名生命周期管理所需的全部数据类型：
// 价格、可用性、已拥有域名、子域名、注册/续费结果等。

String _ensJsonString(
  Map<String, dynamic> json,
  String key, {
  String fallback = '',
}) {
  final value = json[key];
  if (value == null) return fallback;
  return value.toString();
}

int _ensJsonInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _ensJsonDouble(
  Map<String, dynamic> json,
  String key, {
  double fallback = 0,
}) {
  final value = json[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _ensJsonBool(
  Map<String, dynamic> json,
  String key, {
  bool fallback = false,
}) {
  final value = json[key];
  if (value is bool) return value;
  final normalized = value?.toString().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return fallback;
}

DateTime? _ensJsonDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return DateTime.tryParse(value.toString());
}

Map<String, String>? _ensJsonStringMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map) return null;
  final result = <String, String>{};
  for (final entry in value.entries) {
    if (entry.key == null || entry.value == null) continue;
    result[entry.key.toString()] = entry.value.toString();
  }
  return result.isEmpty ? null : result;
}

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
      basePrice: _ensJsonDouble(json, 'basePrice'),
      annualPrice: _ensJsonDouble(json, 'annualPrice'),
      totalPrice: _ensJsonDouble(json, 'totalPrice'),
      years: _ensJsonInt(json, 'years', fallback: 1),
      nameLength: _ensJsonInt(json, 'nameLength'),
      updatedAt: _ensJsonDateTime(json, 'updatedAt') ?? DateTime.now(),
      usdPrice: json['usdPrice'] == null
          ? null
          : _ensJsonDouble(json, 'usdPrice'),
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
  String get formattedAnnualPrice =>
      '${annualPrice.toStringAsFixed(4)} ETH/year';
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
    return EnsAvailabilityResult(name: name, isAvailable: true);
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
    return EnsAvailabilityResult(name: name, isAvailable: false, error: error);
  }

  factory EnsAvailabilityResult.fromJson(Map<String, dynamic> json) {
    return EnsAvailabilityResult(
      name: _ensJsonString(json, 'name'),
      isAvailable: _ensJsonBool(json, 'isAvailable'),
      expiresAt: _ensJsonDateTime(json, 'expiresAt'),
      ownerAddress: json['ownerAddress'] == null
          ? null
          : _ensJsonString(json, 'ownerAddress'),
      error: json['error'] == null ? null : _ensJsonString(json, 'error'),
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
      name: _ensJsonString(json, 'name'),
      ownerAddress: _ensJsonString(json, 'ownerAddress'),
      resolvedAddress: json['resolvedAddress'] == null
          ? null
          : _ensJsonString(json, 'resolvedAddress'),
      expiresAt: _ensJsonDateTime(json, 'expiresAt') ?? DateTime.now(),
      registeredAt: _ensJsonDateTime(json, 'registeredAt'),
      avatar: json['avatar'] == null ? null : _ensJsonString(json, 'avatar'),
      isPrimary: _ensJsonBool(json, 'isPrimary'),
      textRecords: _ensJsonStringMap(json, 'textRecords'),
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

  /// 获取剩余天数
  int get daysUntilExpiry {
    final days = expiresAt.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  /// 检查是否即将过期 (30 天内)
  bool get isExpiringSoon => daysUntilExpiry > 0 && daysUntilExpiry <= 30;

  /// 检查是否已过期
  bool get isExpired =>
      daysUntilExpiry == 0 && DateTime.now().isAfter(expiresAt);

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
      label: _ensJsonString(json, 'label'),
      fullName: _ensJsonString(json, 'fullName'),
      owner: _ensJsonString(json, 'owner'),
      resolver: json['resolver'] == null
          ? null
          : _ensJsonString(json, 'resolver'),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'fullName': fullName,
    'owner': owner,
    'resolver': resolver,
  };

  /// 地址是否为零地址（即子域名已被删除）
  bool get isDeleted => owner == '0x0000000000000000000000000000000000000000';
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
      commitmentHash: _ensJsonString(json, 'commitmentHash'),
      secret: _ensJsonString(json, 'secret'),
      txHash: json['txHash'] == null ? null : _ensJsonString(json, 'txHash'),
      commitTime: _ensJsonDateTime(json, 'commitTime') ?? DateTime.now(),
      minWaitTime: _ensJsonInt(json, 'minWaitTime', fallback: 60),
      maxWaitTime: _ensJsonInt(json, 'maxWaitTime', fallback: 86400),
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

  /// 自 commitTime 以来经过的秒数
  int get _elapsedSeconds => DateTime.now().difference(commitTime).inSeconds;

  /// 检查是否可以注册
  bool get canRegister {
    final elapsed = _elapsedSeconds;
    return elapsed >= minWaitTime && elapsed <= maxWaitTime;
  }

  /// 获取剩余等待时间 (秒)
  int get remainingWaitTime {
    final remaining = minWaitTime - _elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// 检查承诺是否已过期
  bool get isExpired => _elapsedSeconds > maxWaitTime;
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
    return RegisterResult(success: false, name: name, error: error);
  }

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      success: _ensJsonBool(json, 'success'),
      txHash: json['txHash'] == null ? null : _ensJsonString(json, 'txHash'),
      name: _ensJsonString(json, 'name'),
      expiresAt: _ensJsonDateTime(json, 'expiresAt'),
      error: json['error'] == null ? null : _ensJsonString(json, 'error'),
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
    return RenewResult(success: false, name: name, error: error);
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
