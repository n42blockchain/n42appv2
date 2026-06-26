// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 非 EVM 链速度档位（与 EVM 的 GasSpeed 对应，但独立定义避免循环依赖）
enum NonEvmFeeSpeed { slow, standard, fast }

/// 非 EVM 链单一费用选项
class NonEvmFeeOption {
  /// 总费用（基础单位，如 satoshi、lamport、drop）
  final BigInt fee;

  /// 可选费率（如 BTC 的 sat/byte）
  final int? feeRate;

  /// 费率单位（如 "sat/byte"）
  final String? feeRateUnit;

  /// 预估确认时间（秒）
  final int estimatedSeconds;

  const NonEvmFeeOption({
    required this.fee,
    this.feeRate,
    this.feeRateUnit,
    required this.estimatedSeconds,
  });
}

/// 非 EVM 链费用模型
///
/// 用于 BTC 等链的 Slow/Standard/Fast 三档 + Custom 模式。
/// 对固定费用链（SOL、DOT、XRP 等），[isEditable] = false，三档相同。
class NonEvmFeeModel {
  /// 链符号，如 "BTC"、"SOL"
  final String chainSymbol;

  /// 显示单位，如 "BTC"、"SOL"
  final String unit;

  /// 小数位数
  final int decimals;

  /// 慢速选项
  final NonEvmFeeOption slow;

  /// 标准速度选项
  final NonEvmFeeOption standard;

  /// 快速选项
  final NonEvmFeeOption fast;

  /// 是否允许用户选择速度档位
  ///
  /// BTC 等 UTXO 链可编辑 fee rate；SOL/DOT/XRP 等固定费用链为 false。
  final bool isEditable;

  /// 当前选择的速度
  NonEvmFeeSpeed selectedSpeed;

  NonEvmFeeModel({
    required this.chainSymbol,
    required this.unit,
    required this.decimals,
    required this.slow,
    required this.standard,
    required this.fast,
    this.isEditable = false,
    this.selectedSpeed = NonEvmFeeSpeed.standard,
  });

  /// 获取当前选择的费用选项
  NonEvmFeeOption get currentOption {
    switch (selectedSpeed) {
      case NonEvmFeeSpeed.slow:
        return slow;
      case NonEvmFeeSpeed.standard:
        return standard;
      case NonEvmFeeSpeed.fast:
        return fast;
    }
  }

  /// 当前总费用
  BigInt get currentFee => currentOption.fee;

  // ─── 工厂方法 ──────────────────────────────────────────────────────────────

  /// 为 BTC/LTC/BCH 等 UTXO 链创建三档模型
  ///
  /// [averageRateSatPerByte] 来自服务器的网络平均费率
  /// [calcFeeByRate]         根据费率计算总费用的回调（satoshis）
  /// [unit]                  显示单位，默认 "BTC"
  factory NonEvmFeeModel.forBtcLike({
    required int averageRateSatPerByte,
    required int Function(int feeRate) calcFeeByRate,
    String chainSymbol = 'BTC',
    String unit = 'BTC',
    int decimals = 8,
    String feeRateUnit = 'sat/byte',
  }) {
    // 慢速：80%（≥1），标准：100%，快速：150%
    final slowRate = (averageRateSatPerByte * 0.8).ceil().clamp(
      1,
      averageRateSatPerByte,
    );
    final standardRate = averageRateSatPerByte;
    final fastRate = (averageRateSatPerByte * 1.5).ceil();

    return NonEvmFeeModel(
      chainSymbol: chainSymbol,
      unit: unit,
      decimals: decimals,
      isEditable: true,
      slow: NonEvmFeeOption(
        fee: BigInt.from(calcFeeByRate(slowRate)),
        feeRate: slowRate,
        feeRateUnit: feeRateUnit,
        estimatedSeconds: 3600, // ~60 min
      ),
      standard: NonEvmFeeOption(
        fee: BigInt.from(calcFeeByRate(standardRate)),
        feeRate: standardRate,
        feeRateUnit: feeRateUnit,
        estimatedSeconds: 1800, // ~30 min
      ),
      fast: NonEvmFeeOption(
        fee: BigInt.from(calcFeeByRate(fastRate)),
        feeRate: fastRate,
        feeRateUnit: feeRateUnit,
        estimatedSeconds: 600, // ~10 min
      ),
    );
  }

  /// 为固定费用链（SOL、DOT、XRP、ALGO、FIL、SUI、APT、TON、TRX 等）创建只读模型
  factory NonEvmFeeModel.fixed({
    required BigInt fee,
    required String chainSymbol,
    required String unit,
    required int decimals,
    int estimatedSeconds = 30,
  }) {
    final opt = NonEvmFeeOption(fee: fee, estimatedSeconds: estimatedSeconds);
    return NonEvmFeeModel(
      chainSymbol: chainSymbol,
      unit: unit,
      decimals: decimals,
      isEditable: false,
      slow: opt,
      standard: opt,
      fast: opt,
    );
  }
}
