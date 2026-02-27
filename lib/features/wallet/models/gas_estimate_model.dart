// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Gas 相关常量
class GasConstants {
  GasConstants._();

  /// 1 Gwei = 10^9 Wei
  static final BigInt gweiInWei = BigInt.from(1000000000);

  /// 网络空闲阈值 (Gwei) - 低于此值认为网络空闲
  static const int networkIdleThresholdGwei = 30;

  /// 网络拥堵阈值 (Gwei) - 高于此值认为网络拥堵
  static const int networkBusyThresholdGwei = 100;

  /// 默认 Gas Limit（普通转账）
  static const int defaultGasLimit = 21000;

  /// 默认 Gas Limit（合约调用）
  static const int defaultContractGasLimit = 100000;

  /// Gas 安全边际百分比 (%)
  static const int gasSafetyMarginPercent = 20;

  /// EIP-1559 下一个区块 base fee 最大增幅 (12.5%)
  static const int baseFeeMaxIncreasePermille = 125;

  /// 慢速交易倍率 (90%)
  static const int slowMultiplierPercent = 90;

  /// 快速交易倍率 (130%)
  static const int fastMultiplierPercent = 130;

  /// 超快交易 base fee 倍率
  static const int fastBaseFeeMutiplier = 2;

  /// 预估确认时间 - 慢速 (秒)
  static const int slowEstimatedSeconds = 180;

  /// 预估确认时间 - 标准 (秒)
  static const int standardEstimatedSeconds = 60;

  /// 预估确认时间 - 快速 (秒)
  static const int fastEstimatedSeconds = 15;

  /// EIP-1559 标准预估确认时间 (秒)
  static const int eip1559StandardSeconds = 30;

  /// EIP-1559 快速预估确认时间 (秒)
  static const int eip1559FastSeconds = 12;
}

/// Gas 估算速度类型
enum GasSpeed {
  slow,
  standard,
  fast,
}

/// EIP-1559 Gas 费用数据
class EIP1559GasFee {
  /// 最大优先费 (maxPriorityFeePerGas) - Wei
  final BigInt maxPriorityFeePerGas;

  /// 最大费用 (maxFeePerGas) - Wei
  final BigInt maxFeePerGas;

  /// 基础费 (baseFee) - Wei
  final BigInt baseFee;

  /// 预估确认时间（秒）
  final int estimatedSeconds;

  EIP1559GasFee({
    required this.maxPriorityFeePerGas,
    required this.maxFeePerGas,
    required this.baseFee,
    required this.estimatedSeconds,
  });

  /// 计算总 gas 费用
  BigInt totalFee(BigInt gasLimit) {
    return maxFeePerGas * gasLimit;
  }

  /// 从 JSON 创建
  factory EIP1559GasFee.fromJson(Map<String, dynamic> json) {
    return EIP1559GasFee(
      maxPriorityFeePerGas: BigInt.parse(json['maxPriorityFeePerGas']?.toString() ?? '0'),
      maxFeePerGas: BigInt.parse(json['maxFeePerGas']?.toString() ?? '0'),
      baseFee: BigInt.parse(json['baseFee']?.toString() ?? '0'),
      estimatedSeconds: json['estimatedSeconds'] ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'maxPriorityFeePerGas': maxPriorityFeePerGas.toString(),
      'maxFeePerGas': maxFeePerGas.toString(),
      'baseFee': baseFee.toString(),
      'estimatedSeconds': estimatedSeconds,
    };
  }
}

/// Legacy Gas 费用数据（非 EIP-1559）
class LegacyGasFee {
  /// Gas 价格 - Wei
  final BigInt gasPrice;

  /// 预估确认时间（秒）
  final int estimatedSeconds;

  LegacyGasFee({
    required this.gasPrice,
    required this.estimatedSeconds,
  });

  /// 计算总 gas 费用
  BigInt totalFee(BigInt gasLimit) {
    return gasPrice * gasLimit;
  }

  /// 从 JSON 创建
  factory LegacyGasFee.fromJson(Map<String, dynamic> json) {
    return LegacyGasFee(
      gasPrice: BigInt.parse(json['gasPrice']?.toString() ?? '0'),
      estimatedSeconds: json['estimatedSeconds'] ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'gasPrice': gasPrice.toString(),
      'estimatedSeconds': estimatedSeconds,
    };
  }
}

/// Gas 估算结果模型
class GasEstimateModel {
  /// 是否支持 EIP-1559
  final bool supportsEIP1559;

  /// 慢速选项
  final GasOption slow;

  /// 标准速度选项
  final GasOption standard;

  /// 快速选项
  final GasOption fast;

  /// 当前区块的基础费（EIP-1559）
  final BigInt? baseFee;

  /// Gas Limit
  final BigInt gasLimit;

  /// 链符号
  final String chainSymbol;

  /// 小数位数
  final int decimals;

  /// 主链代币符号
  final String unit;

  /// 当前选择的速度
  GasSpeed selectedSpeed;

  GasEstimateModel({
    required this.supportsEIP1559,
    required this.slow,
    required this.standard,
    required this.fast,
    this.baseFee,
    required this.gasLimit,
    required this.chainSymbol,
    required this.decimals,
    required this.unit,
    this.selectedSpeed = GasSpeed.standard,
  });

  /// 获取当前选择的 Gas 选项
  GasOption get currentOption {
    switch (selectedSpeed) {
      case GasSpeed.slow:
        return slow;
      case GasSpeed.standard:
        return standard;
      case GasSpeed.fast:
        return fast;
    }
  }

  /// 获取当前选择的总费用
  BigInt get currentTotalFee {
    return currentOption.totalFee(gasLimit);
  }

  /// 从历史数据创建估算模型
  factory GasEstimateModel.fromFeeHistory({
    required List<BigInt> baseFeeHistory,
    required List<List<BigInt>> rewardHistory,
    required BigInt gasLimit,
    required bool supportsEIP1559,
    required String chainSymbol,
    required int decimals,
    required String unit,
  }) {
    if (!supportsEIP1559 || baseFeeHistory.isEmpty) {
      // Legacy 模式
      final avgGasPrice = baseFeeHistory.isNotEmpty
          ? baseFeeHistory.reduce((a, b) => a + b) ~/ BigInt.from(baseFeeHistory.length)
          : BigInt.zero;

      return GasEstimateModel(
        supportsEIP1559: false,
        slow: GasOption.legacy(
          gasPrice: avgGasPrice * BigInt.from(GasConstants.slowMultiplierPercent) ~/ BigInt.from(100),
          estimatedSeconds: GasConstants.slowEstimatedSeconds,
        ),
        standard: GasOption.legacy(
          gasPrice: avgGasPrice,
          estimatedSeconds: GasConstants.standardEstimatedSeconds,
        ),
        fast: GasOption.legacy(
          gasPrice: avgGasPrice * BigInt.from(120) ~/ BigInt.from(100),
          estimatedSeconds: GasConstants.fastEstimatedSeconds,
        ),
        gasLimit: gasLimit,
        chainSymbol: chainSymbol,
        decimals: decimals,
        unit: unit,
      );
    }

    // EIP-1559 模式
    final latestBaseFee = baseFeeHistory.last;

    // 计算优先费的百分位数
    final flatRewards = rewardHistory.expand((r) => r).toList()..sort();

    final slowPriorityFee = _percentile(flatRewards, 10);
    final standardPriorityFee = _percentile(flatRewards, 50);
    final fastPriorityFee = _percentile(flatRewards, 90);

    // 预测下一个区块的基础费（最多增加12.5%）
    final nextBaseFee = latestBaseFee * BigInt.from(1000 + GasConstants.baseFeeMaxIncreasePermille) ~/ BigInt.from(1000);

    return GasEstimateModel(
      supportsEIP1559: true,
      baseFee: latestBaseFee,
      slow: GasOption.eip1559(
        maxPriorityFeePerGas: slowPriorityFee,
        maxFeePerGas: nextBaseFee + slowPriorityFee,
        baseFee: latestBaseFee,
        estimatedSeconds: GasConstants.slowEstimatedSeconds,
      ),
      standard: GasOption.eip1559(
        maxPriorityFeePerGas: standardPriorityFee,
        maxFeePerGas: nextBaseFee + standardPriorityFee,
        baseFee: latestBaseFee,
        estimatedSeconds: GasConstants.eip1559StandardSeconds,
      ),
      fast: GasOption.eip1559(
        maxPriorityFeePerGas: fastPriorityFee,
        maxFeePerGas: nextBaseFee * BigInt.from(GasConstants.fastBaseFeeMutiplier) + fastPriorityFee,
        baseFee: latestBaseFee,
        estimatedSeconds: GasConstants.eip1559FastSeconds,
      ),
      gasLimit: gasLimit,
      chainSymbol: chainSymbol,
      decimals: decimals,
      unit: unit,
    );
  }

  /// 从 JSON 创建
  factory GasEstimateModel.fromJson(Map<String, dynamic> json) {
    return GasEstimateModel(
      supportsEIP1559: json['supportsEIP1559'] ?? false,
      slow: GasOption.fromJson(json['slow']),
      standard: GasOption.fromJson(json['standard']),
      fast: GasOption.fromJson(json['fast']),
      baseFee: json['baseFee'] != null ? BigInt.parse(json['baseFee'].toString()) : null,
      gasLimit: BigInt.parse(json['gasLimit']?.toString() ?? '21000'),
      chainSymbol: json['chainSymbol'] ?? '',
      decimals: json['decimals'] ?? 18,
      unit: json['unit'] ?? 'ETH',
      selectedSpeed: GasSpeed.values[json['selectedSpeed'] ?? 1],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'supportsEIP1559': supportsEIP1559,
      'slow': slow.toJson(),
      'standard': standard.toJson(),
      'fast': fast.toJson(),
      'baseFee': baseFee?.toString(),
      'gasLimit': gasLimit.toString(),
      'chainSymbol': chainSymbol,
      'decimals': decimals,
      'unit': unit,
      'selectedSpeed': selectedSpeed.index,
    };
  }

  static BigInt _percentile(List<BigInt> list, int percentile) {
    if (list.isEmpty) return BigInt.zero;
    final index = (list.length * percentile / 100).floor().clamp(0, list.length - 1);
    return list[index];
  }
}

/// Gas 选项（支持 EIP-1559 和 Legacy）
class GasOption {
  /// EIP-1559 费用数据
  final EIP1559GasFee? eip1559;

  /// Legacy 费用数据
  final LegacyGasFee? legacy;

  /// 是否为 EIP-1559
  bool get isEIP1559 => eip1559 != null;

  /// 预估确认时间
  int get estimatedSeconds => eip1559?.estimatedSeconds ?? legacy?.estimatedSeconds ?? 0;

  GasOption._({this.eip1559, this.legacy});

  /// 创建 EIP-1559 选项
  factory GasOption.eip1559({
    required BigInt maxPriorityFeePerGas,
    required BigInt maxFeePerGas,
    required BigInt baseFee,
    required int estimatedSeconds,
  }) {
    return GasOption._(
      eip1559: EIP1559GasFee(
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        baseFee: baseFee,
        estimatedSeconds: estimatedSeconds,
      ),
    );
  }

  /// 创建 Legacy 选项
  factory GasOption.legacy({
    required BigInt gasPrice,
    required int estimatedSeconds,
  }) {
    return GasOption._(
      legacy: LegacyGasFee(
        gasPrice: gasPrice,
        estimatedSeconds: estimatedSeconds,
      ),
    );
  }

  /// 计算总费用
  BigInt totalFee(BigInt gasLimit) {
    return eip1559?.totalFee(gasLimit) ?? legacy?.totalFee(gasLimit) ?? BigInt.zero;
  }

  /// 获取用于签名的 gas price（兼容 legacy 系统）
  BigInt get effectiveGasPrice {
    return eip1559?.maxFeePerGas ?? legacy?.gasPrice ?? BigInt.zero;
  }

  /// 获取 maxPriorityFeePerGas（仅 EIP-1559）
  BigInt get maxPriorityFeePerGas {
    return eip1559?.maxPriorityFeePerGas ?? BigInt.zero;
  }

  /// 从 JSON 创建
  factory GasOption.fromJson(Map<String, dynamic> json) {
    if (json['eip1559'] != null) {
      return GasOption._(eip1559: EIP1559GasFee.fromJson(json['eip1559']));
    } else if (json['legacy'] != null) {
      return GasOption._(legacy: LegacyGasFee.fromJson(json['legacy']));
    }
    // 默认返回零费用的 legacy
    return GasOption.legacy(gasPrice: BigInt.zero, estimatedSeconds: 0);
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      if (eip1559 != null) 'eip1559': eip1559!.toJson(),
      if (legacy != null) 'legacy': legacy!.toJson(),
    };
  }
}
