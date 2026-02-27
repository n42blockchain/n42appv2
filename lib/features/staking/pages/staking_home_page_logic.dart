// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/features/staking/api/atom_staking_api.dart';
import 'package:n42_wallet/features/staking/api/eth_staking_api.dart';
import 'package:n42_wallet/features/staking/api/sol_staking_api.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/stake_page.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';

/// Logic mixin for [StakingHomePage].
///
/// Contains state fields, APY data loading, amount formatting, and navigation.
mixin StakingHomePageLogicMixin on State<StakingHomePage> {
  // Evaluated once at compile time; avoids repeated bool.fromEnvironment calls on every build.
  static const bool dotStakingEnabled =
      bool.fromEnvironment('FEATURE_DOT_STAKING', defaultValue: false);

  late TabController tabController;
  late StakingProvider provider;

  // 实时 APY 缓存：key = protocol.id
  final Map<String, double> liveApys = {};
  bool loadingApys = false;

  // ─── Lifecycle helpers ─────────────────────────────────────────────────────

  void initLogic(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);
    provider = StakingProvider();

    // 加载用户仓位
    if (widget.userAddresses != null && widget.userAddresses!.isNotEmpty) {
      provider.loadAllUserPositions(widget.userAddresses!);
    }

    // 并行拉取各协议实时 APY
    loadLiveApys();
  }

  void disposeLogic() {
    tabController.dispose();
    provider.dispose();
  }

  // ─── Data loading ─────────────────────────────────────────────────────────

  /// 并行拉取三条链的实时 APY，全部完成后刷新 UI
  Future<void> loadLiveApys() async {
    if (loadingApys) return;
    if (!mounted) return;
    setState(() => loadingApys = true);

    try {
      final results = await Future.wait([
        EthStakingApi().getLidoApy(),
        SolStakingApi().getEstimatedApy(),
        AtomStakingApi().getInflationAndApy(),
      ]);

      if (!mounted) return;

      final newApys = <String, double>{};

      final ethResult = results[0];
      if (!ethResult.error && ethResult.data is double) {
        newApys[StakingProtocols.ethLido.id] = ethResult.data as double;
      }

      final solResult = results[1];
      if (!solResult.error && solResult.data is double) {
        newApys[StakingProtocols.solNative.id] = solResult.data as double;
      }

      final atomResult = results[2];
      if (!atomResult.error && atomResult.data is Map) {
        final atomData = atomResult.data as Map;
        final apy = (atomData['apy'] as num?)?.toDouble();
        if (apy != null && apy > 0) {
          newApys[StakingProtocols.atomNative.id] = apy;
        }
      }

      setState(() {
        liveApys.addAll(newApys);
        loadingApys = false;
      });
    } catch (_) {
      if (mounted) setState(() => loadingApys = false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // 链符号 -> 精度映射
  static const _chainDecimals = {
    'ETH': 18,
    'SOL': 9,
    'ATOM': 6,
    'DOT': 10,
  };

  String formatAmount(BigInt amount, String symbol) {
    final decimals = _chainDecimals[symbol] ?? 18;
    final value = amount.toDouble() / BigInt.from(10).pow(decimals).toDouble();
    return '${value.toStringAsFixed(4)} $symbol';
  }

  void navigateToStakePage(BuildContext context, StakingProtocol protocol) {
    final userAddress = widget.userAddresses?[protocol.chainType];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StakePage(
          protocol: protocol,
          userAddress: userAddress,
        ),
      ),
    );
  }
}
