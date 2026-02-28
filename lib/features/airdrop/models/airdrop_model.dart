// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// ─── 辅助函数 ─────────────────────────────────────────────────────────────

/// 安全解析可空 DateTime 字符串
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}

/// 安全提取 double，默认 0
double _toDouble(dynamic value) => (value ?? 0).toDouble();

/// 空投状态
enum AirdropStatus {
  /// 即将开始
  upcoming,
  /// 进行中（可领取）
  active,
  /// 已领取
  claimed,
  /// 已过期
  expired,
  /// 不符合条件
  ineligible,
}

/// 空投类型
enum AirdropType {
  /// 代币空投
  token,
  /// NFT 空投
  nft,
  /// 积分空投
  points,
  /// 测试网空投
  testnet,
}

/// 空投优先级
enum AirdropPriority {
  /// 高优先级（大额、即将截止）
  high,
  /// 中等优先级
  medium,
  /// 低优先级
  low,
}

/// 空投信息模型
class AirdropModel {
  final String id;
  final String name;
  final String description;
  final String projectName;
  final String projectLogo;
  final String? projectUrl;
  final String chainSymbol;
  final int chainId;
  final AirdropType type;
  final AirdropStatus status;
  final AirdropPriority priority;

  /// 代币符号
  final String? tokenSymbol;

  /// 代币合约地址
  final String? tokenAddress;

  /// 预估价值（USD）
  final double? estimatedValueUsd;

  /// 空投数量
  final String? amount;

  /// 开始时间
  final DateTime? startDate;

  /// 结束时间
  final DateTime? endDate;

  /// 领取截止时间
  final DateTime? claimDeadline;

  /// 领取条件
  final List<AirdropRequirement> requirements;

  /// 用户是否符合条件
  final bool? isEligible;

  /// 用户可领取数量
  final String? userClaimableAmount;

  /// 领取链接
  final String? claimUrl;

  /// 领取交易 hash
  final String? claimTxHash;

  /// 社交链接
  final Map<String, String>? socialLinks;

  /// 标签
  final List<String> tags;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  AirdropModel({
    required this.id,
    required this.name,
    required this.description,
    required this.projectName,
    required this.projectLogo,
    this.projectUrl,
    required this.chainSymbol,
    required this.chainId,
    required this.type,
    required this.status,
    this.priority = AirdropPriority.medium,
    this.tokenSymbol,
    this.tokenAddress,
    this.estimatedValueUsd,
    this.amount,
    this.startDate,
    this.endDate,
    this.claimDeadline,
    this.requirements = const [],
    this.isEligible,
    this.userClaimableAmount,
    this.claimUrl,
    this.claimTxHash,
    this.socialLinks,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 是否即将截止（7天内）
  bool get isExpiringSoon {
    if (claimDeadline == null) return false;
    final daysLeft = claimDeadline!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 7;
  }

  /// 剩余天数
  int? get daysLeft {
    if (claimDeadline == null) return null;
    return claimDeadline!.difference(DateTime.now()).inDays;
  }

  /// 是否可领取
  bool get isClaimable {
    return status == AirdropStatus.active && (isEligible ?? false);
  }

  factory AirdropModel.fromJson(Map<String, dynamic> json) {
    return AirdropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      projectName: json['project_name'] ?? '',
      projectLogo: json['project_logo'] ?? '',
      projectUrl: json['project_url'],
      chainSymbol: json['chain_symbol'] ?? 'ETH',
      chainId: json['chain_id'] ?? 1,
      type: AirdropType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AirdropType.token,
      ),
      status: AirdropStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AirdropStatus.upcoming,
      ),
      priority: AirdropPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AirdropPriority.medium,
      ),
      tokenSymbol: json['token_symbol'],
      tokenAddress: json['token_address'],
      estimatedValueUsd: json['estimated_value_usd']?.toDouble(),
      amount: json['amount'],
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      claimDeadline: _parseDateTime(json['claim_deadline']),
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => AirdropRequirement.fromJson(e))
              .toList() ??
          [],
      isEligible: json['is_eligible'],
      userClaimableAmount: json['user_claimable_amount'],
      claimUrl: json['claim_url'],
      claimTxHash: json['claim_tx_hash'],
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'])
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'project_name': projectName,
      'project_logo': projectLogo,
      'project_url': projectUrl,
      'chain_symbol': chainSymbol,
      'chain_id': chainId,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'token_symbol': tokenSymbol,
      'token_address': tokenAddress,
      'estimated_value_usd': estimatedValueUsd,
      'amount': amount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'claim_deadline': claimDeadline?.toIso8601String(),
      'requirements': requirements.map((e) => e.toJson()).toList(),
      'is_eligible': isEligible,
      'user_claimable_amount': userClaimableAmount,
      'claim_url': claimUrl,
      'claim_tx_hash': claimTxHash,
      'social_links': socialLinks,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // sentinel 用于区分"明确传 null"与"不传（保留原值）"
  static const Object _sentinel = Object();

  AirdropModel copyWith({
    Object? isEligible = _sentinel,
    Object? userClaimableAmount = _sentinel,
    List<AirdropRequirement>? requirements,
    AirdropStatus? status,
  }) {
    return AirdropModel(
      id: id,
      name: name,
      description: description,
      projectName: projectName,
      projectLogo: projectLogo,
      projectUrl: projectUrl,
      chainSymbol: chainSymbol,
      chainId: chainId,
      type: type,
      status: status ?? this.status,
      priority: priority,
      tokenSymbol: tokenSymbol,
      tokenAddress: tokenAddress,
      estimatedValueUsd: estimatedValueUsd,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      claimDeadline: claimDeadline,
      requirements: requirements ?? this.requirements,
      isEligible: isEligible == _sentinel ? this.isEligible : isEligible as bool?,
      userClaimableAmount: userClaimableAmount == _sentinel
          ? this.userClaimableAmount
          : userClaimableAmount as String?,
      claimUrl: claimUrl,
      claimTxHash: claimTxHash,
      socialLinks: socialLinks,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// 空投领取条件
class AirdropRequirement {
  final String id;
  final String description;
  final RequirementType type;
  final bool? isMet;
  final String? details;

  AirdropRequirement({
    required this.id,
    required this.description,
    required this.type,
    this.isMet,
    this.details,
  });

  factory AirdropRequirement.fromJson(Map<String, dynamic> json) {
    return AirdropRequirement(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      type: RequirementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RequirementType.other,
      ),
      isMet: json['is_met'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type.name,
      'is_met': isMet,
      'details': details,
    };
  }
}

/// 条件类型
enum RequirementType {
  /// 持有代币
  holdToken,
  /// 持有 NFT
  holdNft,
  /// 交易次数
  transactionCount,
  /// 交易量
  transactionVolume,
  /// 使用 DApp
  useDapp,
  /// 质押
  staking,
  /// 提供流动性
  liquidity,
  /// 社交任务
  social,
  /// 投票
  governance,
  /// 其他
  other,
}

/// 空投追踪统计
class AirdropStats {
  final int totalAirdrops;
  final int eligibleAirdrops;
  final int claimedAirdrops;
  final double totalValueUsd;
  final double claimedValueUsd;
  final double pendingValueUsd;

  AirdropStats({
    required this.totalAirdrops,
    required this.eligibleAirdrops,
    required this.claimedAirdrops,
    required this.totalValueUsd,
    required this.claimedValueUsd,
    required this.pendingValueUsd,
  });

  factory AirdropStats.empty() {
    return AirdropStats(
      totalAirdrops: 0,
      eligibleAirdrops: 0,
      claimedAirdrops: 0,
      totalValueUsd: 0,
      claimedValueUsd: 0,
      pendingValueUsd: 0,
    );
  }

  factory AirdropStats.fromJson(Map<String, dynamic> json) {
    return AirdropStats(
      totalAirdrops: json['total_airdrops'] ?? 0,
      eligibleAirdrops: json['eligible_airdrops'] ?? 0,
      claimedAirdrops: json['claimed_airdrops'] ?? 0,
      totalValueUsd: _toDouble(json['total_value_usd']),
      claimedValueUsd: _toDouble(json['claimed_value_usd']),
      pendingValueUsd: _toDouble(json['pending_value_usd']),
    );
  }
}

/// 空投筛选条件
class AirdropFilter {
  final List<AirdropStatus>? statuses;
  final List<AirdropType>? types;
  final List<String>? chains;
  final bool? onlyEligible;
  final bool? onlyHighValue;
  final double? minValueUsd;
  final AirdropSortBy sortBy;
  final bool sortDescending;

  AirdropFilter({
    this.statuses,
    this.types,
    this.chains,
    this.onlyEligible,
    this.onlyHighValue,
    this.minValueUsd,
    this.sortBy = AirdropSortBy.priority,
    this.sortDescending = true,
  });

  AirdropFilter copyWith({
    List<AirdropStatus>? statuses,
    List<AirdropType>? types,
    List<String>? chains,
    bool? onlyEligible,
    bool? onlyHighValue,
    double? minValueUsd,
    AirdropSortBy? sortBy,
    bool? sortDescending,
  }) {
    return AirdropFilter(
      statuses: statuses ?? this.statuses,
      types: types ?? this.types,
      chains: chains ?? this.chains,
      onlyEligible: onlyEligible ?? this.onlyEligible,
      onlyHighValue: onlyHighValue ?? this.onlyHighValue,
      minValueUsd: minValueUsd ?? this.minValueUsd,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}

/// 排序方式
enum AirdropSortBy {
  priority,
  value,
  deadline,
  name,
  createdAt,
}
