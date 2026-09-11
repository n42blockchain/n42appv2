// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/services/aggregated_balance_reader.dart';
import 'package:n42_wallet/features/wallet/utils/decimal_amount.dart';

enum AggregateBalanceStatus { unavailable, loading, ready, stale, error }

/// 链上余额信息
class ChainBalance {
  final String chainSymbol;
  final String contract;
  final int decimals;
  final int chainId;
  final BigInt balance;
  final String address;

  ChainBalance({
    required this.chainSymbol,
    required this.contract,
    required this.decimals,
    required this.chainId,
    required this.balance,
    required this.address,
  });

  /// 格式化余额
  double get balanceDouble {
    if (balance == BigInt.zero) return 0.0;
    // 使用整数除法避免精度丢失
    final divisor = BigInt.from(10).pow(decimals);
    final intPart = balance ~/ divisor;
    final fracPart = balance.remainder(divisor);
    return intPart.toDouble() + fracPart.toDouble() / divisor.toDouble();
  }
}

/// 聚合代币模型 - 用于主页显示多链聚合的 USDT/USDC
class AggregatedCoinModel extends CoinModel {
  /// 聚合代币配置
  final AggregatedToken tokenConfig;

  /// 各链余额
  final Map<String, ChainBalance> chainBalances = {};

  /// 是否为聚合代币
  bool get isAggregated => true;

  final Map<String, AggregateBalanceStatus> statuses = {};
  final Future<BigInt> Function(ChainTokenConfig, String) _readBalance;
  Map<String, String> _addresses = {};
  Future<void>? _pending;
  int _revision = 0;

  int get _totalDecimals =>
      tokenConfig.chains.fold(6, (n, c) => math.max(n, c.decimals));
  BigInt get _preciseTotal => chainBalances.values.fold(
    BigInt.zero,
    (sum, entry) =>
        sum +
        entry.balance * BigInt.from(10).pow(_totalDecimals - entry.decimals),
  );
  BigInt get totalBalance =>
      _preciseTotal ~/ BigInt.from(10).pow(_totalDecimals - 6);
  String get totalBalanceString =>
      bigIntToDecimalString(_preciseTotal, _totalDecimals);
  String balanceStringForAddresses(Map<String, String> addresses) {
    final total = chainBalances.entries
        .where((entry) => addresses[entry.key] == entry.value.address)
        .fold(
          BigInt.zero,
          (sum, entry) =>
              sum +
              entry.value.balance *
                  BigInt.from(10).pow(_totalDecimals - entry.value.decimals),
        );
    return bigIntToDecimalString(total, _totalDecimals);
  }

  double get totalBalanceDouble => double.parse(totalBalanceString);
  bool get hasIncompleteBalance => tokenConfig.chains.any(
    (c) => statuses[c.chainSymbol] != AggregateBalanceStatus.ready,
  );
  AggregateBalanceStatus statusFor(String chain) =>
      statuses[chain.toUpperCase()] ?? AggregateBalanceStatus.unavailable;

  /// 支持的链列表
  List<String> get supportedChains =>
      tokenConfig.chains.map((c) => c.chainSymbol).toList();

  AggregatedCoinModel({
    required this.tokenConfig,
    Future<BigInt> Function(ChainTokenConfig, String)? balanceReader,
  }) : _readBalance = balanceReader ?? AggregatedBalanceReader().read {
    // 初始化 coin 基本信息
    // 注意：coinPrice 初始化为 0.0，会从 API 获取真实价格
    coin = {
      'mKey': tokenConfig.symbol,
      'blockchainType': 'Aggregated',
      'coinType': 'AGGREGATED',
      'icon': tokenConfig.icon,
      'name': tokenConfig.name,
      'miniName': tokenConfig.symbol,
      'unit': tokenConfig.symbol,
      'decimals': 6, // 统一使用 6 位精度显示
      'balance': '0',
      'balance_test': '0',
      'coinPrice': 0.0, // 从 API 获取真实价格
      'percentage': 0.0,
      'isContract': true,
      'isAggregated': true, // 标记为聚合代币
      'path': {'legacy': "m/44'/60'/0'/0/0"},
      'service': '',
      'service_test': '',
      'chainId': 0,
      'chainId_test': 0,
      'contract': '',
      'contract_test': '',
      'canEdit': false,
      'rules': 'MULTI',
    };
    showList = true;
    isTest = false;
    coinPrice = 0.0; // 从 API 获取真实价格
  }

  /// 根据链符号获取该链的余额
  ChainBalance? getChainBalance(String chainSymbol) {
    return chainBalances[chainSymbol.toUpperCase()];
  }

  /// 更新某条链的余额
  void updateChainBalance(
    String chainSymbol,
    BigInt newBalance,
    String address,
  ) {
    final config = tokenConfig.chains
        .where((c) => c.chainSymbol == chainSymbol.toUpperCase())
        .firstOrNull;
    if (newBalance.isNegative) throw const FormatException('Negative balance');
    if (config == null) return; // 不支持的链静默返回

    chainBalances[chainSymbol.toUpperCase()] = ChainBalance(
      chainSymbol: chainSymbol,
      contract: config.contract,
      decimals: config.decimals,
      chainId: config.chainId,
      balance: newBalance,
      address: address,
    );

    statuses[config.chainSymbol] = AggregateBalanceStatus.ready;
    _updateTotals();
  }

  void _updateTotals() {
    balance = totalBalance;
    value = totalBalanceDouble * coinPrice;
    loadError = statuses.values.any(
      (s) =>
          s == AggregateBalanceStatus.error ||
          s == AggregateBalanceStatus.stale,
    );
  }

  /// Coalesces equal requests; changed address sets invalidate late responses.
  Future<void> fetchAllBalances(
    Map<String, String> addressByChain, {
    VoidCallback? onChanged,
  }) {
    final addresses = <String, String>{
      for (final entry in addressByChain.entries)
        if (supportedChains.contains(entry.key.toUpperCase()) &&
            entry.value.trim().isNotEmpty)
          entry.key.toUpperCase(): entry.value.trim(),
    };
    if (_pending != null && mapEquals(addresses, _addresses)) return _pending!;
    _addresses = addresses;
    final revision = ++_revision;
    chainBalances.removeWhere(
      (chain, balance) => addresses[chain] != balance.address,
    );
    for (final config in tokenConfig.chains) {
      statuses[config.chainSymbol] = addresses.containsKey(config.chainSymbol)
          ? AggregateBalanceStatus.loading
          : AggregateBalanceStatus.unavailable;
    }
    isRefresh = addresses.isNotEmpty;
    _updateTotals();
    onChanged?.call();
    final operation = Future.wait(
      tokenConfig.chains.map((config) async {
        final address = addresses[config.chainSymbol];
        if (address == null) return;
        try {
          final amount = await _readBalance(
            config,
            address,
          ).timeout(const Duration(seconds: 15));
          if (revision != _revision) return;
          updateChainBalance(config.chainSymbol, amount, address);
        } catch (_) {
          if (revision != _revision) return;
          statuses[config.chainSymbol] =
              chainBalances.containsKey(config.chainSymbol)
              ? AggregateBalanceStatus.stale
              : AggregateBalanceStatus.error;
          _updateTotals();
        }
        onChanged?.call();
      }),
    ).then<void>((_) {});
    final tracked = operation.whenComplete(() {
      if (revision != _revision) return;
      isRefresh = false;
      _pending = null;
      onChanged?.call();
    });
    _pending = tracked;
    return tracked;
  }

  @override
  double balanceDoubleAll() {
    return totalBalanceDouble;
  }

  @override
  String balanceString() {
    return totalBalanceString;
  }
}

/// Match deployed contracts, never ticker text alone (which can be spoofed).
AggregatedToken? aggregatedTokenForCoin(CoinModel coin) {
  if (coin is AggregatedCoinModel) return coin.tokenConfig;
  if (coin.isTest ||
      coin.custom ||
      coin.coin['custom'] == true ||
      !coin.config.isContract) {
    return null;
  }
  for (final token in AggregatedTokens.all) {
    for (final chain in token.chains) {
      if (chain.chainSymbol != coin.config.coinType) continue;
      final matches = chain.rules == 'ERC20' || chain.rules == 'BEP20'
          ? chain.contract.toLowerCase() == coin.config.contract.toLowerCase()
          : chain.contract == coin.config.contract;
      if (matches && coin.config.decimals == chain.decimals) return token;
    }
  }
  return null;
}
