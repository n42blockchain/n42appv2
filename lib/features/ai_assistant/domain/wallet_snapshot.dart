// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 单个资产快照。
class WalletAsset {
  final String symbol;
  final String balance; // 显示用十进制字符串
  final double usdValue;
  const WalletAsset({
    required this.symbol,
    required this.balance,
    required this.usdValue,
  });
}

/// 钱包只读上下文快照 —— 供 AI 助手（M1）做「只读 + 建议」。
///
/// 不含私钥/签名能力，纯数据。助手只读不代执行。
class WalletSnapshot {
  final double totalUsd;
  final List<WalletAsset> assets;
  final double? gasGwei;
  final String? chainName;

  const WalletSnapshot({
    this.totalUsd = 0,
    this.assets = const [],
    this.gasGwei,
    this.chainName,
  });
}
