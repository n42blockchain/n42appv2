import 'package:n42_wallet/features/payments/domain/payment_asset.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

enum WalletPaymentAssetResolutionError {
  unsupportedNamespace,
  invalidWalletAsset,
  duplicateIdentity,
  notFound,
}

final class WalletPaymentAssetResolutionException implements Exception {
  const WalletPaymentAssetResolutionException(this.error, this.message);

  final WalletPaymentAssetResolutionError error;
  final String message;

  @override
  String toString() => 'WalletPaymentAssetResolutionException: $message';
}

/// Resolves an explicit payment identity against the current trusted wallet
/// inventory without consulting symbols, RPC services, or signing state.
///
/// A returned [CoinModel] is only a lookup result. Wallet records are mutable,
/// so callers must resolve and validate the asset again immediately before
/// authorization/signing.
final class WalletPaymentAssetResolver {
  const WalletPaymentAssetResolver();

  static final _decimalChainId = RegExp(r'[0-9]+');

  CoinModel resolve(List<CoinModel> coins, PaymentAssetId requested) {
    if (requested.namespace != 'eip155') {
      throw WalletPaymentAssetResolutionException(
        WalletPaymentAssetResolutionError.unsupportedNamespace,
        'Unsupported payment asset namespace: ${requested.namespace}',
      );
    }

    final byIdentity = <PaymentAssetId, CoinModel>{};
    for (final coin in coins) {
      final baseInfo = resolveChainBaseInfo(coin.coin)!;
      final config = CoinConfigView(baseInfo);
      if (config.isAggregated || config.blockchainType != 'Ethereum') {
        continue;
      }

      final chainKey = coin.isTest ? 'chainId_test' : 'chainId';
      final chainId = _strictChainId(
        baseInfo[chainKey],
        coin,
        '$chainKey must be a positive integer',
      );
      if (!identical(baseInfo, coin.coin)) {
        final topLevelKey = coin.isTest ? 'testnetChainID' : 'mainnetChainID';
        if (coin.coin.containsKey(topLevelKey)) {
          final topLevelChainId = _strictChainId(
            coin.coin[topLevelKey],
            coin,
            '$topLevelKey must be a positive integer',
          );
          if (topLevelChainId != chainId) {
            _invalid(coin, '$chainKey conflicts with $topLevelKey');
          }
        }
      }

      final configuredContract = coin.isTest
          ? config.contractTest
          : config.contract;
      if (config.isContract && configuredContract.isEmpty) {
        _invalid(coin, 'contract asset has no contract address');
      }
      if (!config.isContract && configuredContract.isNotEmpty) {
        _invalid(coin, 'native asset unexpectedly has a contract address');
      }

      late final PaymentAssetId identity;
      try {
        identity = PaymentAssetId(
          namespace: 'eip155',
          network: chainId,
          contract: config.isContract ? configuredContract : null,
        );
      } on ArgumentError {
        _invalid(coin, 'invalid EVM contract address');
      }

      if (byIdentity.containsKey(identity)) {
        throw WalletPaymentAssetResolutionException(
          WalletPaymentAssetResolutionError.duplicateIdentity,
          'Wallet contains duplicate payment asset identity $identity',
        );
      }
      byIdentity[identity] = coin;
    }

    final match = byIdentity[requested];
    if (match == null) {
      throw WalletPaymentAssetResolutionException(
        WalletPaymentAssetResolutionError.notFound,
        'Payment asset $requested is not present in the wallet',
      );
    }
    return match;
  }

  String _strictChainId(Object? value, CoinModel coin, String reason) {
    final String digits;
    if (value is int) {
      digits = value.toString();
    } else if (value is String && _isFullDecimal(value)) {
      digits = value;
    } else {
      _invalid(coin, reason);
    }
    final parsed = BigInt.parse(digits);
    if (parsed <= BigInt.zero) {
      _invalid(coin, reason);
    }
    return parsed.toString();
  }

  bool _isFullDecimal(String value) {
    final match = _decimalChainId.matchAsPrefix(value);
    return match != null && match.end == value.length;
  }

  Never _invalid(CoinModel coin, String reason) {
    final label = coin.config.mKey.isNotEmpty
        ? coin.config.mKey
        : coin.config.coinType;
    throw WalletPaymentAssetResolutionException(
      WalletPaymentAssetResolutionError.invalidWalletAsset,
      'Invalid EVM wallet asset ${label.isEmpty ? '<unknown>' : label}: '
      '$reason',
    );
  }
}
