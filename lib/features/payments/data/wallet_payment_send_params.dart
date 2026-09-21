import 'dart:collection';

import 'package:n42_wallet/features/payments/data/wallet_payment_asset_resolver.dart';
import 'package:n42_wallet/features/payments/domain/payment_amount.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

enum WalletPaymentSendParamsError {
  invalidAmount,
  precisionMismatch,
  invalidAddress,
  fromAddressMismatch,
  importedKeyUnsupported,
  invalidDerivation,
  invalidChainConfig,
}

final class WalletPaymentSendParamsException implements Exception {
  const WalletPaymentSendParamsException(this.error, this.message);

  final WalletPaymentSendParamsError error;
  final String message;

  @override
  String toString() => 'WalletPaymentSendParamsException: $message';
}

/// Builds inert EVM sender parameters from a current wallet snapshot.
///
/// This adapter performs no RPC, key access, authorization, signing, or
/// broadcast. The result is valid only for direct dispatch to [EvmSender]; a
/// coin-type-based sender factory may select a cached sender for another
/// network. [SendParams.amount] is only a compatibility/display value; the
/// exact payment is carried exclusively by the applicable integer override.
final class WalletPaymentSendParamsAdapter {
  const WalletPaymentSendParamsAdapter({
    this.assetResolver = const WalletPaymentAssetResolver(),
  });

  final WalletPaymentAssetResolver assetResolver;

  static final _evmAddress = RegExp(r'0x[0-9a-f]{40}', caseSensitive: false);
  static final _pathComponent = RegExp(r"([0-9]+)(['hH]?)");
  static final _maxUint256 = (BigInt.one << 256) - BigInt.one;
  static final _maxDerivationIndex = BigInt.from(0x7fffffff);
  static final _maxSignedInt64 = BigInt.parse('9223372036854775807');

  SendParams build({
    required List<CoinModel> coins,
    required PaymentAmount amount,
    required String expectedFromAddress,
    required String recipient,
  }) {
    final coin = assetResolver.resolve(coins, amount.asset.id);
    final baseInfo = resolveChainBaseInfo(coin.coin)!;
    final config = CoinConfigView(baseInfo);

    if (amount.units <= BigInt.zero || amount.units > _maxUint256) {
      _fail(
        WalletPaymentSendParamsError.invalidAmount,
        'Payment units must be a positive uint256',
      );
    }

    final walletDecimals = _strictDecimals(baseInfo);
    if (walletDecimals != amount.asset.decimals) {
      _fail(
        WalletPaymentSendParamsError.precisionMismatch,
        'Payment precision does not match the selected wallet asset',
      );
    }

    _requireNonZeroAddress(expectedFromAddress, 'Expected from address');
    _requireNonZeroAddress(recipient, 'Recipient');
    final selectedAddress = coin.address;
    if (selectedAddress is! String || !_isNonZeroAddress(selectedAddress)) {
      _fail(
        WalletPaymentSendParamsError.invalidAddress,
        'Selected wallet asset has no valid EVM address',
      );
    }
    if (selectedAddress.toLowerCase() != expectedFromAddress.toLowerCase()) {
      _fail(
        WalletPaymentSendParamsError.fromAddressMismatch,
        'Expected from address does not match the selected wallet asset',
      );
    }

    final contract = coin.isTest ? config.contractTest : config.contract;
    if (config.isContract) {
      _requireNonZeroAddress(contract, 'Contract');
    }

    if (coin.privateKey?.isNotEmpty ?? false) {
      _fail(
        WalletPaymentSendParamsError.importedKeyUnsupported,
        'Imported-key wallets are not supported by this adapter',
      );
    }

    final path = _derivePath(
      config.pathForAddrType(coin.addrType),
      coin.pathIndex,
    );
    final chainConfig = _snapshotChainConfig(coin, baseInfo, config);

    return SendParams(
      coinType: config.coinType,
      fromAddress: selectedAddress,
      toAddress: recipient,
      amount: double.parse(amount.format(trimTrailingZeros: false)),
      decimals: walletDecimals,
      path: path,
      isTest: coin.isTest,
      contractAddress: config.isContract ? contract : '',
      tokenDecimals: config.isContract ? walletDecimals : 0,
      privateKey: null,
      chainConfig: chainConfig,
      valueWeiOverride: config.isContract ? null : amount.units,
      tokenValueWeiOverride: config.isContract ? amount.units : null,
    );
  }

  int _strictDecimals(Map<String, dynamic> baseInfo) {
    final hasDecimals = baseInfo.containsKey('decimals');
    final hasLegacy = baseInfo.containsKey('decimal');
    if (!hasDecimals && !hasLegacy) {
      _fail(
        WalletPaymentSendParamsError.precisionMismatch,
        'Selected wallet asset has no precision',
      );
    }
    final primary = hasDecimals
        ? _parsePrecision(baseInfo['decimals'])
        : _parsePrecision(baseInfo['decimal']);
    if (primary == null) {
      _fail(
        WalletPaymentSendParamsError.precisionMismatch,
        'Selected wallet asset has invalid precision',
      );
    }
    if (hasDecimals && hasLegacy) {
      final legacy = _parsePrecision(baseInfo['decimal']);
      if (legacy == null || legacy != primary) {
        _fail(
          WalletPaymentSendParamsError.precisionMismatch,
          'Selected wallet asset has conflicting precision fields',
        );
      }
    }
    return primary;
  }

  int? _parsePrecision(Object? value) {
    final String digits;
    if (value is int) {
      digits = value.toString();
    } else if (value is String && _isAsciiDigits(value)) {
      digits = value;
    } else {
      return null;
    }
    final parsed = int.tryParse(digits);
    return parsed != null && parsed >= 0 && parsed <= 255 ? parsed : null;
  }

  Map<String, dynamic> _snapshotChainConfig(
    CoinModel coin,
    Map<String, dynamic> baseInfo,
    CoinConfigView config,
  ) {
    if (config.coinType.isEmpty || config.blockchainType != 'Ethereum') {
      _fail(
        WalletPaymentSendParamsError.invalidChainConfig,
        'Selected asset has invalid EVM routing metadata',
      );
    }
    final chainKey = coin.isTest ? 'chainId_test' : 'chainId';
    final chainId = _strictChainId(baseInfo[chainKey]);
    if (chainId == null) {
      _fail(
        WalletPaymentSendParamsError.invalidChainConfig,
        'Selected network has an invalid chain ID',
      );
    }

    final snapshot = <String, dynamic>{
      'blockchainType': config.blockchainType,
      'coinType': config.coinType,
      if (config.mKey.isNotEmpty) 'mKey': config.mKey,
      'decimals': _strictDecimals(baseInfo),
      'isContract': config.isContract,
      chainKey: chainId,
    };
    final serviceKey = coin.isTest ? 'service_test' : 'service';
    final service = baseInfo[serviceKey];
    if (service is! String || !_isValidRpcUrl(service)) {
      _fail(
        WalletPaymentSendParamsError.invalidChainConfig,
        'Selected network has no valid HTTP RPC URL',
      );
    }
    snapshot[serviceKey] = service;
    final contractKey = coin.isTest ? 'contract_test' : 'contract';
    snapshot[contractKey] = config.isContract
        ? (coin.isTest ? config.contractTest : config.contract)
        : '';

    final frozen = UnmodifiableMapView<String, dynamic>(snapshot);
    if (EvmSender.resolveChainId(frozen, isTest: coin.isTest) != chainId) {
      _fail(
        WalletPaymentSendParamsError.invalidChainConfig,
        'Chain snapshot does not preserve the selected network',
      );
    }
    final expectedRpc = service;
    if (EvmSender.resolveRpcOverride(frozen, isTest: coin.isTest) !=
        expectedRpc) {
      _fail(
        WalletPaymentSendParamsError.invalidChainConfig,
        'Chain snapshot does not preserve the selected RPC',
      );
    }
    return frozen;
  }

  int? _strictChainId(Object? value) {
    final String digits;
    if (value is int) {
      digits = value.toString();
    } else if (value is String && _isAsciiDigits(value)) {
      digits = value;
    } else {
      return null;
    }
    final parsed = int.tryParse(digits);
    if (parsed == null || parsed <= 0) return null;
    final exact = BigInt.parse(digits);
    if (exact > _maxSignedInt64 || BigInt.from(parsed) != exact) return null;
    return parsed;
  }

  String _derivePath(String? basePath, int pathIndex) {
    if (basePath == null || basePath.isEmpty) {
      _fail(
        WalletPaymentSendParamsError.invalidDerivation,
        'Selected wallet asset has no derivation path',
      );
    }
    if (pathIndex < 0 || BigInt.from(pathIndex) > _maxDerivationIndex) {
      _fail(
        WalletPaymentSendParamsError.invalidDerivation,
        'Selected wallet asset has an invalid path index',
      );
    }
    final parts = basePath.split('/');
    if (parts.length < 4 || parts.first != 'm') {
      _invalidPath();
    }
    for (final part in parts.skip(1)) {
      final match = _pathComponent.matchAsPrefix(part);
      if (match == null || match.end != part.length) _invalidPath();
      final component = BigInt.parse(match.group(1)!);
      if (component > _maxDerivationIndex) _invalidPath();
    }
    final last = _pathComponent.firstMatch(parts.last)!;
    parts[parts.length - 1] = '$pathIndex${last.group(2)}';
    return parts.join('/');
  }

  Never _invalidPath() => _fail(
    WalletPaymentSendParamsError.invalidDerivation,
    'Selected wallet asset has an invalid derivation path',
  );

  void _requireNonZeroAddress(String address, String label) {
    if (!_isNonZeroAddress(address)) {
      _fail(
        WalletPaymentSendParamsError.invalidAddress,
        '$label must be a non-zero EVM address',
      );
    }
  }

  bool _isNonZeroAddress(String value) {
    final match = _evmAddress.matchAsPrefix(value);
    return match != null &&
        match.end == value.length &&
        value.substring(2).contains(RegExp(r'[1-9a-f]', caseSensitive: false));
  }

  bool _isAsciiDigits(String value) {
    if (value.isEmpty) return false;
    for (final unit in value.codeUnits) {
      if (unit < 0x30 || unit > 0x39) return false;
    }
    return true;
  }

  bool _isValidRpcUrl(String value) {
    if (value.isEmpty || value.trim() != value) return false;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.authority.contains('@') ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      return false;
    }
    try {
      uri.port;
    } on FormatException {
      return false;
    }
    return true;
  }

  Never _fail(WalletPaymentSendParamsError error, String message) {
    throw WalletPaymentSendParamsException(error, message);
  }
}
