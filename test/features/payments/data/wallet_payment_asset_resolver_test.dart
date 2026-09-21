import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/data/wallet_payment_asset_resolver.dart';
import 'package:n42_wallet/features/payments/domain/payment_asset.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

void main() {
  const usdc = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd';
  const otherUsdc = '0x1111111111111111111111111111111111111111';
  const resolver = WalletPaymentAssetResolver();

  CoinModel evm({
    Object? chainId = 1,
    Object? testChainId = 11155111,
    String contract = '',
    String testContract = '',
    bool isContract = false,
    bool isTest = false,
    String symbol = 'ETH',
  }) {
    final coin = CoinModel.fromMap(<String, dynamic>{
      'mKey': symbol,
      'coinType': symbol,
      'miniName': symbol,
      'blockchainType': 'Ethereum',
      'isContract': isContract,
      'chainId': ?chainId,
      'chainId_test': ?testChainId,
      'contract': contract,
      'contract_test': testContract,
    });
    coin.isTest = isTest;
    return coin;
  }

  PaymentAssetId id(int network, [String? contract]) => PaymentAssetId(
    namespace: 'eip155',
    network: '$network',
    contract: contract,
  );

  WalletPaymentAssetResolutionException failure(
    List<CoinModel> coins,
    PaymentAssetId requested,
  ) {
    try {
      resolver.resolve(coins, requested);
      fail('Expected asset resolution to fail');
    } on WalletPaymentAssetResolutionException catch (error) {
      return error;
    }
  }

  test('resolves native and ERC20 assets by chain and contract identity', () {
    final native = evm();
    final token = evm(contract: usdc, isContract: true, symbol: 'USDC');

    expect(resolver.resolve([native, token], id(1)), same(native));
    expect(resolver.resolve([native, token], id(1, usdc)), same(token));
    expect(resolver.resolve([token], id(1, usdc.toUpperCase())), same(token));
  });

  test('same symbol on different networks or contracts never aliases', () {
    final ethereum = evm(contract: usdc, isContract: true, symbol: 'USDC');
    final base = evm(
      chainId: 8453,
      contract: usdc,
      isContract: true,
      symbol: 'USDC',
    );
    final other = evm(contract: otherUsdc, isContract: true, symbol: 'USDC');

    expect(resolver.resolve([ethereum, base, other], id(8453, usdc)), base);
    expect(resolver.resolve([ethereum, base, other], id(1, otherUsdc)), other);
  });

  test('testnet uses only test chain ID and test contract', () {
    final token = evm(
      contract: otherUsdc,
      testContract: usdc,
      isContract: true,
      isTest: true,
      symbol: 'USDC',
    );

    expect(resolver.resolve([token], id(11155111, usdc)), token);
    expect(
      failure([token], id(1, otherUsdc)).error,
      WalletPaymentAssetResolutionError.notFound,
    );
  });

  test('mixed wallet ignores explicit non-EVM and aggregated rows', () {
    final bitcoin = CoinModel.fromMap(<String, dynamic>{
      'blockchainType': 'Bitcoin',
      'coinType': 'BTC',
      'chainId': 0,
    });
    final aggregated = CoinModel.fromMap(<String, dynamic>{
      'blockchainType': 'Aggregated',
      'coinType': 'AGGREGATED',
      'isAggregated': true,
      'isContract': true,
      'chainId': 0,
    });
    final ethereum = evm();

    expect(resolver.resolve([bitcoin, aggregated, ethereum], id(1)), ethereum);
  });

  test('rejects unsupported namespace and absent assets explicitly', () {
    final solana = PaymentAssetId(
      namespace: 'solana',
      network: 'mainnet',
      contract: null,
    );
    expect(
      failure([evm()], solana).error,
      WalletPaymentAssetResolutionError.unsupportedNamespace,
    );
    expect(
      failure([evm()], id(8453)).error,
      WalletPaymentAssetResolutionError.notFound,
    );
  });

  test('missing testnet chain ID never falls back to mainnet', () {
    final token = evm(
      testChainId: null,
      testContract: usdc,
      isContract: true,
      isTest: true,
    );
    expect(
      failure([token], id(1, usdc)).error,
      WalletPaymentAssetResolutionError.invalidWalletAsset,
    );
  });

  test('rejects non-integral and non-finite numeric chain IDs', () {
    for (final chainId in <double>[1.5, double.nan, double.infinity]) {
      expect(
        failure([evm(chainId: chainId)], id(1)).error,
        WalletPaymentAssetResolutionError.invalidWalletAsset,
      );
    }
  });

  test('rejects chain ID strings with whitespace or trailing newline', () {
    for (final chainId in [' 1', '1 ', '1\n']) {
      expect(
        failure([evm(chainId: chainId)], id(1)).error,
        WalletPaymentAssetResolutionError.invalidWalletAsset,
      );
    }
  });

  test('rejects conflicting baseInfo and top-level chain IDs', () {
    final wrapped = CoinModel.fromMap(<String, dynamic>{
      'baseInfo': <String, dynamic>{
        'mKey': 'ETH',
        'coinType': 'ETH',
        'blockchainType': 'Ethereum',
        'isContract': false,
        'chainId': 1,
        'contract': '',
      },
      'mainnetChainID': 8453,
    });
    expect(
      failure([wrapped], id(1)).error,
      WalletPaymentAssetResolutionError.invalidWalletAsset,
    );
  });

  test('rejects malformed or contradictory EVM contract configuration', () {
    final invalidRows = <CoinModel>[
      evm(isContract: true),
      evm(contract: usdc),
      evm(contract: 'not-an-address', isContract: true),
    ];
    for (final row in invalidRows) {
      expect(
        failure([row], id(1)).error,
        WalletPaymentAssetResolutionError.invalidWalletAsset,
      );
    }
  });

  test('duplicate canonical identity fails closed', () {
    final first = evm(contract: usdc, isContract: true, symbol: 'USDC');
    final duplicate = evm(
      contract: usdc.toUpperCase(),
      isContract: true,
      symbol: 'OTHER',
    );
    expect(
      failure([first, duplicate], id(1, usdc)).error,
      WalletPaymentAssetResolutionError.duplicateIdentity,
    );
  });

  test('malformed unrelated EVM row fails the inventory closed', () {
    final valid = evm();
    final malformed = evm(chainId: null);
    expect(
      failure([valid, malformed], id(1)).error,
      WalletPaymentAssetResolutionError.invalidWalletAsset,
    );
  });
}
