// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain_payment_uri.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';

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

enum WalletPaymentScanKind {
  plainAddress,
  walletConnect,
  eip681,
  chainAware,
  unsupported,
}

class WalletPaymentScanInput {
  final WalletPaymentScanKind kind;
  final Eip681Request? eip681Request;
  final ChainPaymentRequest? chainRequest;
  final String? walletConnectUri;

  const WalletPaymentScanInput._(
    this.kind, {
    this.eip681Request,
    this.chainRequest,
    this.walletConnectUri,
  });

  const WalletPaymentScanInput.plainAddress()
    : this._(WalletPaymentScanKind.plainAddress);

  const WalletPaymentScanInput.unsupported()
    : this._(WalletPaymentScanKind.unsupported);

  const WalletPaymentScanInput.eip681(Eip681Request request)
    : this._(WalletPaymentScanKind.eip681, eip681Request: request);

  const WalletPaymentScanInput.walletConnect(String uri)
    : this._(WalletPaymentScanKind.walletConnect, walletConnectUri: uri);

  const WalletPaymentScanInput.chainAware(ChainPaymentRequest request)
    : this._(WalletPaymentScanKind.chainAware, chainRequest: request);
}

/// Separates payment URIs from plain-address input so malformed or unsupported
/// payment schemes can never fall through to the coin picker.
class WalletPaymentScanParser {
  WalletPaymentScanParser._();

  static WalletPaymentScanInput parse(String raw) {
    final value = raw.trim();
    final walletConnectUri = normalizeWalletConnectUriString(value);
    if (walletConnectUri != null) {
      return WalletPaymentScanInput.walletConnect(walletConnectUri);
    }
    if (value.toLowerCase().startsWith(Eip681.scheme)) {
      final request = Eip681.parse(value);
      return request == null
          ? const WalletPaymentScanInput.unsupported()
          : WalletPaymentScanInput.eip681(request);
    }
    if (!ChainPaymentUri.isSupportedPaymentScheme(value)) {
      return _hasUriScheme(value)
          ? const WalletPaymentScanInput.unsupported()
          : const WalletPaymentScanInput.plainAddress();
    }
    final request = ChainPaymentUri.tryParse(value);
    return request == null
        ? const WalletPaymentScanInput.unsupported()
        : WalletPaymentScanInput.chainAware(request);
  }

  static bool _hasUriScheme(String value) =>
      RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:').hasMatch(value);
}

class ScanToPayResolver {
  const ScanToPayResolver._();

  static ScanToPayResolution? resolve({
    Eip681Request? request,
    ChainPaymentRequest? chainRequest,
    required Iterable<CoinModel> coinModels,
    CoinModel? currentCoin,
  }) {
    if ((request == null) == (chainRequest == null)) return null;
    if (chainRequest != null) {
      return _resolveChainPayment(chainRequest, coinModels);
    }
    if (request == null) return null;

    if (!_isSupportedRequest(request) ||
        _effectiveChainId(request, currentCoin) == null) {
      return null;
    }

    final recipient = request.recipient?.trim() ?? '';
    if (recipient.isEmpty) return null;

    final targetCoin = request.isErc20Transfer
        ? _findErc20Coin(request, coinModels, currentCoin: currentCoin)
        : _findNativeCoin(request, coinModels, currentCoin: currentCoin);
    if (targetCoin == null) return null;

    return ScanToPayResolution(
      coinModel: targetCoin,
      recipient: recipient,
      amount: formatMinUnits(request.amount, targetCoin.config.decimals),
    );
  }

  static ScanToPayResolution? _resolveChainPayment(
    ChainPaymentRequest request,
    Iterable<CoinModel> coinModels,
  ) {
    if (!ChainPaymentUri.isValidRequest(request)) return null;
    final isTest = request.network == ChainPaymentNetwork.testnet;
    final candidates = coinModels.toList(growable: false);
    final chains = candidates
        .where(
          (coin) =>
              !coin.config.isContract &&
              coin.config.mKey == request.chain &&
              coin.isTest == isTest,
        )
        .toList(growable: false);
    if (chains.length != 1) return null;
    final chain = chains.single;

    final CoinModel asset;
    if (request.assetType == ChainPaymentAssetType.native) {
      asset = chain;
    } else {
      final requestedContract = request.contract!.trim();
      final matches = candidates
          .where(
            (coin) =>
                coin.config.isContract &&
                coin.parentChainMKey == request.chain &&
                coin.isTest == isTest &&
                coin.config.coinType == chain.config.coinType &&
                coin.config.blockchainType == chain.config.blockchainType &&
                _sameContract(
                  coin.config.blockchainType,
                  _contractFor(coin),
                  requestedContract,
                ),
          )
          .toList(growable: false);
      if (matches.length != 1) return null;
      asset = matches.single;
    }

    final amount = request.amount?.trim();
    if (!_validDisplayAmount(amount, asset.config.decimals)) return null;
    return ScanToPayResolution(
      coinModel: asset,
      recipient: request.recipient.trim(),
      amount: amount,
    );
  }

  static bool _validDisplayAmount(String? amount, int decimals) {
    if (amount == null || amount.isEmpty) return true;
    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(amount)) return false;
    if (!amount.replaceAll('.', '').contains(RegExp(r'[1-9]'))) return false;
    final decimalPoint = amount.indexOf('.');
    if (decimalPoint == -1) return true;
    return amount.length - decimalPoint - 1 <= decimals;
  }

  static bool _sameContract(String blockchainType, String left, String right) {
    if (blockchainType == BlockchainType.Ethereum.name) {
      return left.trim().toLowerCase() == right.trim().toLowerCase();
    }
    return left.trim() == right.trim();
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
    Iterable<CoinModel> coinModels, {
    CoinModel? currentCoin,
  }) {
    final token = _normalizeAddress(request.tokenAddress);
    if (token.isEmpty) return null;
    final chainId = _effectiveChainId(request, currentCoin);
    final matches = coinModels
        .where((coin) {
          if (!_isEvmCoin(coin)) return false;
          if (!coin.config.isContract) return false;
          if (_normalizeAddress(_contractFor(coin)) != token) return false;
          return _matchesChainId(coin, chainId);
        })
        .toList(growable: false);
    if (matches.length == 1) return matches.single;
    if (currentCoin != null &&
        matches.any((coin) => sameAsset(coin, currentCoin))) {
      return matches.firstWhere((coin) => sameAsset(coin, currentCoin));
    }
    return null;
  }

  static CoinModel? _findNativeCoin(
    Eip681Request request,
    Iterable<CoinModel> coinModels, {
    CoinModel? currentCoin,
  }) {
    final chainId = _effectiveChainId(request, currentCoin);
    if (currentCoin != null &&
        !currentCoin.config.isContract &&
        _isEvmCoin(currentCoin) &&
        _matchesChainId(currentCoin, chainId)) {
      return currentCoin;
    }

    final matches = coinModels
        .where((coin) {
          if (coin.config.isContract) return false;
          if (!_isEvmCoin(coin)) return false;
          return _matchesChainId(coin, chainId);
        })
        .toList(growable: false);
    if (matches.length == 1) return matches.single;
    if (currentCoin != null &&
        matches.any((coin) => sameAsset(coin, currentCoin))) {
      return matches.firstWhere((coin) => sameAsset(coin, currentCoin));
    }
    return null;
  }

  static bool _isSupportedRequest(Eip681Request request) {
    if (request.hasDuplicateParameters ||
        request.hasMalformedParameters ||
        request.hasMalformedChainId) {
      return false;
    }
    if (request.chainId != null && request.chainId! <= 0) return false;

    final keys = request.parameters.keys.toSet();
    if (request.isErc20Transfer) {
      if (!keys.contains('address') ||
          keys.difference(const {'address', 'uint256'}).isNotEmpty) {
        return false;
      }
      return _isPositiveMinUnitAmount(request.parameters['uint256']);
    }

    if (request.functionName != null ||
        keys.difference(const {'value'}).isNotEmpty) {
      return false;
    }
    return _isPositiveMinUnitAmount(request.parameters['value']);
  }

  /// Missing amount is valid; a supplied amount must be a positive integer in
  /// base units. Rejecting it here prevents malformed input becoming a blank
  /// send form after [formatMinUnits] returns null.
  static bool _isPositiveMinUnitAmount(String? amount) {
    if (amount == null) return true;
    if (!RegExp(r'^\d+$').hasMatch(amount)) return false;
    final value = BigInt.tryParse(amount);
    return value != null && value > BigInt.zero;
  }

  static bool _isEvmCoin(CoinModel coin) =>
      coin.config.blockchainType == BlockchainType.Ethereum.name;

  /// EIP-681 `chain_id` 缺省时按**当前所选网络**（`currentCoin` 所在链）处理，
  /// 而非"通配任意链"——否则无 `@chainId` 的请求会把金额预填到列表首个匹配币，
  /// 可能落到错误链的同址代币/原生币。仅当既无请求 chainId、又无 EVM 当前币时
  /// 才退回宽松匹配（无链上下文的最后兜底，下游发送页仍会二次确认资产）。
  static int? _effectiveChainId(Eip681Request request, CoinModel? currentCoin) {
    if (request.chainId != null) return request.chainId;
    if (currentCoin != null && _isEvmCoin(currentCoin)) {
      return _chainIdFor(currentCoin);
    }
    return null;
  }

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
}
