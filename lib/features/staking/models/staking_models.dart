// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 支持的 Staking 链类型
enum StakingChainType {
  ethereum, // Lido stETH
  solana, // 原生质押
  cosmos, // ATOM 原生质押
  polkadot, // DOT 原生质押
}

/// Staking 协议信息
class StakingProtocol {
  final String id;
  final String name;
  final String description;
  final StakingChainType chainType;
  final String chainSymbol;
  final String logoUri;
  final double apy;
  final double minStakeAmount;
  final int unbondingPeriodDays;
  final bool isLiquid; // 是否为流动性质押
  final String? liquidTokenSymbol; // 流动性质押代币符号 (如 stETH)
  final String? contractAddress;

  const StakingProtocol({
    required this.id,
    required this.name,
    required this.description,
    required this.chainType,
    required this.chainSymbol,
    required this.logoUri,
    required this.apy,
    required this.minStakeAmount,
    required this.unbondingPeriodDays,
    this.isLiquid = false,
    this.liquidTokenSymbol,
    this.contractAddress,
  });

  factory StakingProtocol.fromJson(Map<String, dynamic> json) {
    return StakingProtocol(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      chainType: StakingChainType.values.firstWhere(
        (e) => e.name == json['chainType'],
        orElse: () => StakingChainType.ethereum,
      ),
      chainSymbol: json['chainSymbol'] ?? '',
      logoUri: json['logoUri'] ?? '',
      apy: (json['apy'] ?? 0).toDouble(),
      minStakeAmount: (json['minStakeAmount'] ?? 0).toDouble(),
      unbondingPeriodDays: json['unbondingPeriodDays'] ?? 0,
      isLiquid: json['isLiquid'] ?? false,
      liquidTokenSymbol: json['liquidTokenSymbol'],
      contractAddress: json['contractAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'chainType': chainType.name,
      'chainSymbol': chainSymbol,
      'logoUri': logoUri,
      'apy': apy,
      'minStakeAmount': minStakeAmount,
      'unbondingPeriodDays': unbondingPeriodDays,
      'isLiquid': isLiquid,
      'liquidTokenSymbol': liquidTokenSymbol,
      'contractAddress': contractAddress,
    };
  }
}

/// 验证者信息
class Validator {
  final String address;
  final String name;
  final String description;
  final String logoUri;
  final double commission; // 佣金比例 (0-100)
  final double apy;
  final BigInt totalStaked;
  final int delegatorCount;
  final bool isActive;
  final double uptime; // 正常运行时间 (0-100)

  const Validator({
    required this.address,
    required this.name,
    required this.description,
    required this.logoUri,
    required this.commission,
    required this.apy,
    required this.totalStaked,
    required this.delegatorCount,
    required this.isActive,
    required this.uptime,
  });

  factory Validator.fromJson(Map<String, dynamic> json) {
    return Validator(
      address: json['address'] ?? '',
      name: json['name'] ?? json['moniker'] ?? 'Unknown',
      description: json['description'] ?? '',
      logoUri: json['logoUri'] ?? json['logo'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
      apy: (json['apy'] ?? 0).toDouble(),
      totalStaked:
          BigInt.tryParse(json['totalStaked']?.toString() ?? '0') ??
          BigInt.zero,
      delegatorCount: json['delegatorCount'] ?? 0,
      isActive: json['isActive'] ?? json['status'] == 'BOND_STATUS_BONDED',
      uptime: (json['uptime'] ?? 100).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'description': description,
      'logoUri': logoUri,
      'commission': commission,
      'apy': apy,
      'totalStaked': totalStaked.toString(),
      'delegatorCount': delegatorCount,
      'isActive': isActive,
      'uptime': uptime,
    };
  }
}

/// 用户质押仓位
class StakingPosition {
  final String id;
  final StakingProtocol protocol;
  final Validator? validator;
  final BigInt stakedAmount;
  final BigInt rewardsEarned;
  final BigInt pendingRewards;
  final DateTime stakedAt;
  final DateTime? unbondingAt;
  final StakingPositionStatus status;

  const StakingPosition({
    required this.id,
    required this.protocol,
    this.validator,
    required this.stakedAmount,
    required this.rewardsEarned,
    required this.pendingRewards,
    required this.stakedAt,
    this.unbondingAt,
    required this.status,
  });

  factory StakingPosition.fromJson(Map<String, dynamic> json) {
    return StakingPosition(
      id: json['id'] ?? '',
      protocol: StakingProtocol.fromJson(json['protocol'] ?? {}),
      validator: json['validator'] != null
          ? Validator.fromJson(json['validator'])
          : null,
      stakedAmount:
          BigInt.tryParse(json['stakedAmount']?.toString() ?? '0') ??
          BigInt.zero,
      rewardsEarned:
          BigInt.tryParse(json['rewardsEarned']?.toString() ?? '0') ??
          BigInt.zero,
      pendingRewards:
          BigInt.tryParse(json['pendingRewards']?.toString() ?? '0') ??
          BigInt.zero,
      stakedAt:
          DateTime.tryParse(json['stakedAt']?.toString() ?? '') ??
          DateTime.now(),
      unbondingAt: json['unbondingAt'] != null
          ? DateTime.tryParse(json['unbondingAt'].toString())
          : null,
      status: StakingPositionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StakingPositionStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'protocol': protocol.toJson(),
      'validator': validator?.toJson(),
      'stakedAmount': stakedAmount.toString(),
      'rewardsEarned': rewardsEarned.toString(),
      'pendingRewards': pendingRewards.toString(),
      'stakedAt': stakedAt.toIso8601String(),
      'unbondingAt': unbondingAt?.toIso8601String(),
      'status': status.name,
    };
  }

  /// 计算当前价值（质押金额 + 待领取奖励）
  BigInt get currentValue => stakedAmount + pendingRewards;

  /// 是否正在解绑中
  bool get isUnbonding => status == StakingPositionStatus.unbonding;

  /// 获取解绑剩余天数
  int? get unbondingDaysLeft {
    if (unbondingAt == null) return null;
    final remaining = unbondingAt!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}

/// 质押仓位状态
enum StakingPositionStatus {
  active, // 活跃质押中
  unbonding, // 解绑中
  completed, // 解绑完成
  withdrawn, // 已提取
}

/// 质押操作类型
enum StakingActionType {
  stake, // 质押
  unstake, // 解质押
  claim, // 领取奖励
  restake, // 复投（领取并再质押）
  redelegate, // 重新委托（换验证者）
}

/// Staking 交易响应
class StakingTransactionResponse {
  final bool success;
  final String? txHash;
  final String? error;
  final Map<String, dynamic>? txData;

  const StakingTransactionResponse({
    required this.success,
    this.txHash,
    this.error,
    this.txData,
  });

  factory StakingTransactionResponse.success({
    required String txHash,
    Map<String, dynamic>? txData,
  }) {
    return StakingTransactionResponse(
      success: true,
      txHash: txHash,
      txData: txData,
    );
  }

  factory StakingTransactionResponse.error(String error) {
    return StakingTransactionResponse(success: false, error: error);
  }
}

/// Staking 统计数据
class StakingStats {
  final BigInt totalStaked;
  final BigInt totalRewards;
  final double averageApy;
  final int activePositions;

  const StakingStats({
    required this.totalStaked,
    required this.totalRewards,
    required this.averageApy,
    required this.activePositions,
  });

  factory StakingStats.empty() {
    return StakingStats(
      totalStaked: BigInt.zero,
      totalRewards: BigInt.zero,
      averageApy: 0,
      activePositions: 0,
    );
  }
}

/// 缩短地址显示的工具方法
///
/// [prefixLen] 前缀长度，[suffixLen] 后缀长度
String shortenStakingAddress(
  String address, {
  int prefixLen = 8,
  int suffixLen = 6,
}) {
  final minLen = prefixLen + suffixLen + 3; // 3 for '...'
  if (address.length <= minLen) return address;
  return '${address.substring(0, prefixLen)}...${address.substring(address.length - suffixLen)}';
}

/// 预定义的 Staking 协议
class StakingProtocols {
  static const ethLido = StakingProtocol(
    id: 'eth_lido',
    name: 'Lido',
    description: 'Liquid staking for Ethereum. Stake ETH and receive stETH.',
    chainType: StakingChainType.ethereum,
    chainSymbol: 'ETH',
    logoUri:
        'https://tokens.1inch.io/0xae7ab96520de3a18e5e111b5eaab095312d7fe84.png',
    apy: 4.0,
    minStakeAmount: 0.0001,
    unbondingPeriodDays: 0, // Lido 是流动性质押，无锁定期
    isLiquid: true,
    liquidTokenSymbol: 'stETH',
    contractAddress: '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84',
  );

  static const solNative = StakingProtocol(
    id: 'sol_native',
    name: 'Solana Staking',
    description: 'Native Solana staking with validators.',
    chainType: StakingChainType.solana,
    chainSymbol: 'SOL',
    logoUri:
        'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
    apy: 7.0,
    minStakeAmount: 0.01,
    unbondingPeriodDays: 2,
  );

  static const atomNative = StakingProtocol(
    id: 'atom_native',
    name: 'Cosmos Staking',
    description: 'Native ATOM staking with Cosmos Hub validators.',
    chainType: StakingChainType.cosmos,
    chainSymbol: 'ATOM',
    logoUri:
        'https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/images/atom.png',
    apy: 15.0,
    minStakeAmount: 0.001,
    unbondingPeriodDays: 21,
  );

  static const dotNative = StakingProtocol(
    id: 'dot_native',
    name: 'Polkadot Staking',
    description: 'Native DOT staking with Polkadot validators.',
    chainType: StakingChainType.polkadot,
    chainSymbol: 'DOT',
    logoUri:
        'https://raw.githubusercontent.com/polkadot-js/apps/master/packages/apps/public/polkadot-circle.svg',
    apy: 12.0,
    minStakeAmount: 1.0,
    unbondingPeriodDays: 28,
  );

  static const List<StakingProtocol> all = [
    ethLido,
    solNative,
    atomNative,
    dotNative,
  ];

  /// 按 ID 查找协议，未找到时返回 null
  static StakingProtocol? getById(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// 按链类型过滤协议列表
  static List<StakingProtocol> getByChainType(StakingChainType type) {
    return all.where((p) => p.chainType == type).toList();
  }
}
