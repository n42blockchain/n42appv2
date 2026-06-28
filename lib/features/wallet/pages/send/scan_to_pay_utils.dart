// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';

class ScanToPayResolution {
  final CoinModel coinModel;
  final String recipient;
  final String? amount;

  const ScanToPayResolution({
    required this.coinModel,
    required this.recipient,
    this.amount,
  });
}

class ScanToPayResolver {
  const ScanToPayResolver._();

  static ScanToPayResolution? resolve({
    required Eip681Request request,
    required Iterable<CoinModel> coinModels,
    CoinModel? currentCoin,
  }) {
    final recipient = request.recipient?.trim() ?? '';
    if (recipient.isEmpty) return null;

    final targetCoin = request.isErc20Transfer
        ? _findErc20Coin(request, coinModels)
        : _findNativeCoin(request, coinModels, currentCoin: currentCoin);
    if (targetCoin == null) return null;

    return ScanToPayResolution(
      coinModel: targetCoin,
      recipient: recipient,
      amount: formatMinUnits(request.amount, targetCoin.config.decimals),
    );
  }

  static bool sameAsset(CoinModel a, CoinModel b) {
    if (identical(a, b)) return true;
    if (a.isTest != b.isTest) return false;
    if (a.config.coinType != b.config.coinType) return false;
    if (a.config.isContract != b.config.isContract) return false;
    if (a.address?.toString() != b.address?.toString()) return false;
    if (!a.config.isContract) return _chainIdFor(a) == _chainIdFor(b);
    return _normalizeAddress(_contractFor(a)) ==
            _normalizeAddress(_contractFor(b)) &&
        _chainIdFor(a) == _chainIdFor(b);
  }

  static String? formatMinUnits(String? rawAmount, int decimals) {
    if (rawAmount == null || rawAmount.trim().isEmpty) return null;
    final value = BigInt.tryParse(rawAmount.trim());
    if (value == null || value < BigInt.zero) return null;
    if (decimals <= 0) return value.toString();

    final scale = BigInt.from(10).pow(decimals);
    final whole = value ~/ scale;
    final fraction = value % scale;
    if (fraction == BigInt.zero) return whole.toString();

    final fractionText = fraction
        .toString()
        .padLeft(decimals, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    return '$whole.$fractionText';
  }

  static CoinModel? _findErc20Coin(
    Eip681Request request,
    Iterable<CoinModel> coinModels,
  ) {
    final token = _normalizeAddress(request.tokenAddress);
    if (token.isEmpty) return null;
    return _firstOrNull(
      coinModels.where((coin) {
        if (!coin.config.isContract) return false;
        if (_normalizeAddress(_contractFor(coin)) != token) return false;
        return _matchesChainId(coin, request.chainId);
      }),
    );
  }

  static CoinModel? _findNativeCoin(
    Eip681Request request,
    Iterable<CoinModel> coinModels, {
    CoinModel? currentCoin,
  }) {
    if (currentCoin != null &&
        !currentCoin.config.isContract &&
        _isEvmCoin(currentCoin) &&
        _matchesChainId(currentCoin, request.chainId)) {
      return currentCoin;
    }

    return _firstOrNull(
      coinModels.where((coin) {
        if (coin.config.isContract) return false;
        if (!_isEvmCoin(coin)) return false;
        return _matchesChainId(coin, request.chainId);
      }),
    );
  }

  static bool _isEvmCoin(CoinModel coin) =>
      coin.config.blockchainType == BlockchainType.Ethereum.name;

  static bool _matchesChainId(CoinModel coin, int? requestedChainId) {
    if (requestedChainId == null) return true;
    final chainId = _chainIdFor(coin);
    return chainId != null && chainId == requestedChainId;
  }

  static int? _chainIdFor(CoinModel coin) {
    final key = coin.isTest ? 'chainId_test' : 'chainId';
    final direct = _readInt(coin.coin[key]);
    if (direct != null && direct > 0) return direct;
    final baseInfo = coin.coin['baseInfo'];
    if (baseInfo is Map) {
      final fromBase = _readInt(baseInfo[key]);
      if (fromBase != null && fromBase > 0) return fromBase;
    }
    return null;
  }

  static String _contractFor(CoinModel coin) =>
      coin.isTest ? coin.config.contractTest : coin.config.contract;

  static String _normalizeAddress(String? value) =>
      (value ?? '').trim().toLowerCase();

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static T? _firstOrNull<T>(Iterable<T> values) {
    final iterator = values.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
