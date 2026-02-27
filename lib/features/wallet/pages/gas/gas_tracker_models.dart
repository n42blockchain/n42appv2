// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'gas_tracker_page.dart';

// ══════════════════════════════════════════════════════════
// 数据模型
// ══════════════════════════════════════════════════════════

/// 网络配置（静态常量，页面内使用）
class NetworkConfig {
  final String symbol;
  final String name;
  final String icon;
  final Color color;

  const NetworkConfig({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// 单次采样的网络 Gas 数据
class NetworkGasData {
  final double gasPrice;
  final double? baseFee;
  final double? priorityFee;
  final DateTime lastUpdated;

  NetworkGasData({
    required this.gasPrice,
    this.baseFee,
    this.priorityFee,
    required this.lastUpdated,
  });
}
