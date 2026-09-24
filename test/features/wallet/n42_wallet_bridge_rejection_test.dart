import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/n42_wallet_bridge.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';

class _WalletSnapshot extends Fake
    implements LegacyWalletActionProviderAdapter {
  @override
  final List<WalletInfo> walletInfoLsit = [];

  @override
  final List<CoinModel> coinModels = [];

  final addresses = <String, String>{};

  @override
  dynamic getAddress(String coinKey, {String addrType = 'legacy'}) =>
      addresses[coinKey];

  CoinModel buildTokenCoinModel(
    CoinModel mainChain,
    Map<String, dynamic> token,
  ) => CoinModel.fromMap(token)
    ..parentChainMKey = mainChain.config.mKey
    ..isTest = mainChain.isTest
    ..address = mainChain.address
    ..addressType = mainChain.addressType
    ..pathIndex = mainChain.pathIndex
    ..addrType = mainChain.addrType;
}

CoinModel _transferCoin({
  required String coinType,
  required String miniName,
  required String network,
  BigInt? balance,
}) => CoinModel()
  ..coin = {
    'coinType': coinType,
    'miniName': miniName,
    'name': '$miniName on $network',
    'blockchainType': network,
    'decimals': 6,
  }
  ..address = '0x1111111111111111111111111111111111111111'
  ..balance = balance ?? BigInt.zero;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final snapshot = _WalletSnapshot();
  late N42WalletBridge bridge;

  setUpAll(() => globalWapAdapter = snapshot);
  setUp(() {
    snapshot.walletInfoLsit.clear();
    snapshot.coinModels.clear();
    snapshot.addresses.clear();
    bridge = N42WalletBridge();
  });

  test(
    'disconnected wallet rejects transfer before reading coin details',
    () async {
      expect(bridge.isWalletConnected, isFalse);
      final result = await bridge.requestTransfer(
        toAddress: 'unused',
        amount: '1',
        token: 'ETH',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Wallet not connected');
    },
  );

  for (final amount in [
    '0',
    '-1',
    '',
    'not-an-amount',
    'NaN',
    'Infinity',
    '-Infinity',
    '1e9999',
  ]) {
    test(
      'connected wallet rejects invalid amount "$amount" before dispatch',
      () async {
        snapshot.walletInfoLsit.add(WalletInfo());
        final result = await bridge.requestTransfer(
          toAddress: 'unused',
          amount: amount,
          token: 'ETH',
        );
        expect(result.success, isFalse);
        expect(result.errorMessage, 'Invalid transfer amount');
      },
    );
  }

  test(
    'unknown token fails without selecting a different available asset',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      snapshot.coinModels.add(
        CoinModel()..coin = {'coinType': 'ETH', 'miniName': 'ETH'},
      );
      final result = await bridge.requestTransfer(
        toAddress: 'unused',
        amount: '1',
        token: 'USDC',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Token USDC not found in wallet');
    },
  );

  test(
    'same symbol on multiple networks is rejected before transfer setup',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      final zeroBalance = _transferCoin(
        coinType: 'USDC',
        miniName: 'UsDc',
        network: 'Ethereum',
      );
      final funded = _transferCoin(
        coinType: 'BNB',
        miniName: 'USDC',
        network: 'BinanceSmartChain',
        balance: BigInt.from(1000000),
      );

      for (final orderedCoins in [
        [zeroBalance, funded],
        [funded, zeroBalance],
      ]) {
        snapshot.coinModels
          ..clear()
          ..addAll(orderedCoins);
        final result = await bridge.requestTransfer(
          toAddress: '0x2222222222222222222222222222222222222222',
          amount: '1',
          token: 'uSdC',
        );

        expect(result.success, isFalse);
        expect(
          result.errorMessage,
          'Token uSdC matches multiple wallet assets; '
          'select a network and asset explicitly',
        );
      }
    },
  );

  test(
    'one record matching both identity fields is not treated as ambiguous',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      snapshot.coinModels.add(
        _transferCoin(coinType: 'USDC', miniName: 'usdc', network: 'Ethereum'),
      );
      final result = await bridge.requestTransfer(
        toAddress: '0x2222222222222222222222222222222222222222',
        amount: '1',
        token: 'UsDc',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Missing derivation path for UsDc (legacy)');
    },
  );

  test(
    'missing derivation path rejects matched token without ETH fallback',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      snapshot.coinModels.add(
        CoinModel()
          ..coin = {
            'coinType': 'SOL',
            'miniName': 'SOL',
            'blockchainType': 'Solana',
            'decimals': 9,
          }
          ..addrType = 'legacy',
      );
      final result = await bridge.requestTransfer(
        toAddress: 'unused',
        amount: '1',
        token: 'sol',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Missing derivation path for sol (legacy)');
    },
  );

  test(
    'balance lookup retains all decimal places and unknown assets return zero',
    () async {
      snapshot.coinModels.add(
        CoinModel()
          ..coin = {'coinType': 'ETH', 'miniName': 'USDC', 'decimals': 6}
          ..balance = BigInt.parse('9007199254740993123456'),
      );
      expect(await bridge.getBalance('usdc'), '9007199254740993.123456');
      expect(await bridge.getBalance('missing'), '0');
    },
  );

  test(
    'supported token list skips missing identity and keeps display precision',
    () async {
      snapshot.coinModels.addAll([
        CoinModel()..coin = {'miniName': 'Incomplete'},
        CoinModel()
          ..coin = {
            'coinType': 'ETH',
            'miniName': 'USDC',
            'name': 'USD Coin',
            'decimals': '6',
            'isContract': true,
            'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
          },
        CoinModel()..coin = {'coinType': 'SOL', 'decimal': 9},
      ]);
      final tokens = await bridge.getSupportedTokens();
      expect(tokens, hasLength(2));
      expect(tokens.first.symbol, 'USDC');
      expect(tokens.first.name, 'USD Coin');
      expect(tokens.first.decimals, 6);
      expect(tokens.first.isNative, isFalse);
      expect(tokens.last.symbol, 'SOL');
      expect(tokens.last.decimals, 9);
      expect(tokens.last.isNative, isTrue);
    },
  );

  test(
    'supported assets include nested tokens with exact parent identity',
    () async {
      final chain =
          CoinModel.fromMap({
              'coinType': 'ETH',
              'miniName': 'ETH',
              'name': 'Ethereum',
              'mKey': 'ethereum',
              'blockchainType': 'Ethereum',
              'decimals': 18,
              'isContract': false,
            })
            ..address = '0x1111111111111111111111111111111111111111'
            ..tokens['USDC'] = <String, dynamic>{
              'coinType': 'ETH',
              'miniName': 'USDC',
              'name': 'USD Coin',
              'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
              'blockchainType': 'Ethereum',
              'decimals': 6,
              'isContract': true,
              'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
            };
      snapshot.walletInfoLsit.add(WalletInfo());
      snapshot.coinModels.add(chain);

      final tokens = await bridge.getSupportedTokens();
      final usdc = tokens.singleWhere((token) => token.symbol == 'USDC');

      expect(usdc.chain, 'ethereum');
      expect(usdc.network, 'mainnet');
      expect(usdc.assetType, 'token');
      expect(usdc.assetId, '0xabcdef0123456789abcdef0123456789abcdef01');
      expect(usdc.decimals, 6);
      expect(usdc.isNative, isFalse);
    },
  );

  test(
    'testnet assets expose and resolve their configured test contract',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      final chain =
          CoinModel.fromMap({
              'coinType': 'ETH',
              'miniName': 'ETH',
              'mKey': 'ethereum',
              'blockchainType': 'Ethereum',
              'decimals': 18,
              'isContract': false,
            })
            ..isTest = true
            ..tokens['USDC'] = <String, dynamic>{
              'coinType': 'ETH',
              'miniName': 'USDC',
              'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
              'blockchainType': 'Ethereum',
              'decimals': 6,
              'isContract': true,
              'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
              'contract_test': '0x1234567890abcdef1234567890abcdef12345678',
            };
      snapshot.coinModels.add(chain);

      final tokens = await bridge.getSupportedTokens();
      final usdc = tokens.singleWhere((token) => token.symbol == 'USDC');

      expect(usdc.chain, 'ethereum');
      expect(usdc.network, 'testnet');
      expect(usdc.assetId, '0x1234567890abcdef1234567890abcdef12345678');
    },
  );

  test(
    'exact transfer resolves a nested EVM token case-insensitively',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      final chain =
          CoinModel.fromMap({
              'coinType': 'ETH',
              'miniName': 'ETH',
              'mKey': 'ethereum',
              'blockchainType': 'Ethereum',
              'decimals': 18,
              'isContract': false,
            })
            ..address = '0x1111111111111111111111111111111111111111'
            ..tokens['USDC'] = <String, dynamic>{
              'coinType': 'ETH',
              'miniName': 'USDC',
              'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
              'blockchainType': 'Ethereum',
              'decimals': 6,
              'isContract': true,
              'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
            };
      snapshot.coinModels.add(chain);

      final result = await bridge.requestTransferExact(
        toAddress: '0x2222222222222222222222222222222222222222',
        amount: '1',
        token: 'USDC',
        chain: 'ethereum',
        network: 'mainnet',
        assetType: 'token',
        assetId: '0xABCDEF0123456789ABCDEF0123456789ABCDEF01',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Missing derivation path for USDC (legacy)');
    },
  );

  test('exact transfer rejects amounts beyond token precision', () async {
    snapshot.walletInfoLsit.add(WalletInfo());
    final chain =
        CoinModel.fromMap({
            'coinType': 'ETH',
            'miniName': 'ETH',
            'mKey': 'ethereum',
            'blockchainType': 'Ethereum',
            'decimals': 18,
            'isContract': false,
          })
          ..tokens['USDC'] = <String, dynamic>{
            'coinType': 'ETH',
            'miniName': 'USDC',
            'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
            'blockchainType': 'Ethereum',
            'decimals': 6,
            'isContract': true,
            'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
          };
    snapshot.coinModels.add(chain);

    final result = await bridge.requestTransferExact(
      toAddress: '0x2222222222222222222222222222222222222222',
      amount: '1.0000001',
      token: 'USDC',
      chain: 'ethereum',
      network: 'mainnet',
      assetType: 'token',
      assetId: '0xabcdef0123456789abcdef0123456789abcdef01',
    );

    expect(result.success, isFalse);
    expect(
      result.errorMessage,
      'Transfer amount exceeds the selected asset precision',
    );
  });

  test(
    'exact transfer preserves the decimal amount and asset sent to sender',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      final chain =
          CoinModel.fromMap({
              'coinType': 'ETH',
              'miniName': 'ETH',
              'mKey': 'ethereum',
              'blockchainType': 'Ethereum',
              'decimals': 18,
              'isContract': false,
            })
            ..address = '0x1111111111111111111111111111111111111111'
            ..tokens['USDC'] = <String, dynamic>{
              'coinType': 'ETH',
              'miniName': 'USDC',
              'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
              'blockchainType': 'Ethereum',
              'decimals': 6,
              'isContract': true,
              'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
              'path': {'legacy': "m/44'/60'/0'/0/0"},
            };
      snapshot.coinModels.add(chain);

      SendParams? sentParams;
      bridge = N42WalletBridge(
        senderResolver: (coinType, {chainConfig}) => _CapturingSender((params) {
          sentParams = params;
        }),
      );

      final result = await bridge.requestTransferExact(
        toAddress: '0x2222222222222222222222222222222222222222',
        amount: '9007199254.123456',
        token: 'USDC',
        chain: 'ethereum',
        network: 'mainnet',
        assetType: 'token',
        assetId: '0xabcdef0123456789abcdef0123456789abcdef01',
      );

      expect(result.success, isTrue);
      expect(sentParams?.decimalAmountOverride, '9007199254.123456');
      expect(
        sentParams?.tokenValueWeiOverride,
        BigInt.parse('9007199254123456'),
      );
      expect(
        sentParams?.contractAddress,
        '0xabcdef0123456789abcdef0123456789abcdef01',
      );
      expect(
        sentParams?.toAddress,
        '0x2222222222222222222222222222222222222222',
      );
      expect(
        sentParams?.chainConfig?['mKey'],
        '0xabcdef0123456789abcdef0123456789abcdef01',
      );
    },
  );

  test(
    'exact testnet transfer sends the configured testnet contract',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      final chain =
          CoinModel.fromMap({
              'coinType': 'ETH',
              'miniName': 'ETH',
              'mKey': 'ethereum',
              'blockchainType': 'Ethereum',
              'decimals': 18,
              'isContract': false,
              'isTest': true,
            })
            ..isTest = true
            ..address = '0x1111111111111111111111111111111111111111'
            ..tokens['USDC'] = <String, dynamic>{
              'coinType': 'ETH',
              'miniName': 'USDC',
              'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
              'blockchainType': 'Ethereum',
              'decimals': 6,
              'isContract': true,
              'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
              'contract_test': '0x1234567890abcdef1234567890abcdef12345678',
              'path': {'legacy': "m/44'/60'/0'/0/0"},
            };
      snapshot.coinModels.add(chain);

      SendParams? sentParams;
      bridge = N42WalletBridge(
        senderResolver: (coinType, {chainConfig}) => _CapturingSender((params) {
          sentParams = params;
        }),
      );

      final result = await bridge.requestTransferExact(
        toAddress: '0x2222222222222222222222222222222222222222',
        amount: '1.234567',
        token: 'USDC',
        chain: 'ethereum',
        network: 'testnet',
        assetType: 'token',
        assetId: '0x1234567890abcdef1234567890abcdef12345678',
      );

      expect(result.success, isTrue);
      expect(sentParams?.isTest, isTrue);
      expect(
        sentParams?.contractAddress,
        '0x1234567890abcdef1234567890abcdef12345678',
      );
      expect(sentParams?.tokenValueWeiOverride, BigInt.parse('1234567'));
    },
  );

  test(
    'exact testnet transfer rejects assets without a testnet contract',
    () async {
      snapshot.walletInfoLsit.add(WalletInfo());
      final chain =
          CoinModel.fromMap({
              'coinType': 'ETH',
              'miniName': 'ETH',
              'mKey': 'ethereum',
              'blockchainType': 'Ethereum',
              'decimals': 18,
              'isContract': false,
              'isTest': true,
            })
            ..isTest = true
            ..address = '0x1111111111111111111111111111111111111111'
            ..tokens['USDC'] = <String, dynamic>{
              'coinType': 'ETH',
              'miniName': 'USDC',
              'mKey': '0xabcdef0123456789abcdef0123456789abcdef01',
              'blockchainType': 'Ethereum',
              'decimals': 6,
              'isContract': true,
              'contract': '0xabcdef0123456789abcdef0123456789abcdef01',
              'path': {'legacy': "m/44'/60'/0'/0/0"},
            };
      snapshot.coinModels.add(chain);

      SendParams? sentParams;
      bridge = N42WalletBridge(
        senderResolver: (coinType, {chainConfig}) => _CapturingSender((params) {
          sentParams = params;
        }),
      );

      final supported = await bridge.getSupportedTokens();
      final result = await bridge.requestTransferExact(
        toAddress: '0x2222222222222222222222222222222222222222',
        amount: '1.234567',
        token: 'USDC',
        chain: 'ethereum',
        network: 'testnet',
        assetType: 'token',
        assetId: '0xabcdef0123456789abcdef0123456789abcdef01',
      );

      expect(supported.any((token) => token.symbol == 'USDC'), isFalse);
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Token USDC not found in wallet');
      expect(sentParams, isNull);
    },
  );
}

class _CapturingSender implements ChainSender {
  _CapturingSender(this.onSend);

  final void Function(SendParams params) onSend;

  @override
  Future<SendResult> send(SendParams params) async {
    onSend(params);
    return const SendResult.ok('0xtransaction');
  }
}
