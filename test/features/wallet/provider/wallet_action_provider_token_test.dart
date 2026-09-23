import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WalletActionProvider wallet;

  setUpAll(() {
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    wallet = WalletActionProvider();
  });

  tearDown(() {
    wallet.dispose();
  });

  tearDownAll(() {
    app.globalProviderContainer.dispose();
  });

  test('token model inherits its owning chain account context', () {
    final mainChain = CoinModel()
      ..coin = {
        'coinType': 'ETH',
        'miniName': 'ETH',
        'icon': 'eth.png',
        'isContract': false,
      }
      ..privateKey = 'private-key-for-account-2'
      ..pathIndex = 2
      ..isTest = true
      ..addrType = 'segwit'
      ..custom = true
      ..address = '0xaccount2'
      ..addressType = {'kind': 'fixture'};
    final token = wallet.buildTokenCoinModel(mainChain, {
      'coinType': 'ETH',
      'mKey': '0xTOKEN',
      'miniName': 'USDC',
      'symbol': 'USDC',
      'name': 'USD Coin',
      'contract': '0xTOKEN',
      'isContract': true,
      'decimals': 6,
    });

    expect(token.privateKey, 'private-key-for-account-2');
    expect(token.pathIndex, 2);
    expect(token.isTest, isTrue);
    expect(token.addrType, 'segwit');
    expect(token.custom, isTrue);
    expect(token.address, '0xaccount2');
    expect(token.addressType, {'kind': 'fixture'});
    expect(token.mainCoinIcon, 'eth.png');
  });

  test(
    'adding a mainnet token updates the wallet and suppresses duplicates',
    () {
      final mainChain = CoinModel()
        ..coin = {
          'coinType': 'ETH',
          'miniName': 'ETH',
          'icon': 'eth.png',
          'isContract': false,
        }
        ..pathIndex = 1
        ..address = '0xaccount';
      wallet.walletInfoLsit.add(
        WalletInfo()
          ..coinInfo = {
            'ETH': {
              'isTest': false,
              'baseInfo': mainChain.coin,
              'mainnets': <String, dynamic>{},
            },
          },
      );
      wallet.walletIndex = 0;
      wallet.coinModels.add(mainChain);
      final token = <String, dynamic>{
        'coinType': 'ETH',
        'mKey': '0xTOKEN',
        'miniName': 'USDC',
        'symbol': 'USDC',
        'name': 'USD Coin',
        'contract': '0xTOKEN',
        'isContract': true,
        'decimals': 6,
      };

      wallet.addWalletChainToken(token);
      wallet.addWalletChainToken(token);

      final stored = wallet.walletMap['ETH']['mainnets'] as Map;
      expect(stored.keys, ['0xTOKEN']);
      expect(wallet.coinList, hasLength(1));
      expect(wallet.coinList.single.config.miniName, 'USDC');
      expect(wallet.coinList.single.pathIndex, 1);
      expect(wallet.coinList.single.address, '0xaccount');
    },
  );

  test('adding a testnet token stores it under the selected test network', () {
    final mainChain = CoinModel()
      ..coin = {
        'coinType': 'ETH',
        'miniName': 'ETH',
        'icon': 'eth.png',
        'isContract': false,
      }
      ..isTest = true;
    wallet.walletInfoLsit.add(
      WalletInfo()
        ..coinInfo = {
          'ETH': {
            'isTest': true,
            'baseInfo': mainChain.coin,
            'mainnets': <String, dynamic>{},
            'testnets': [
              {'testnetContract': <String, dynamic>{}},
            ],
          },
        },
    );
    wallet.walletIndex = 0;
    wallet.coinModels.add(mainChain);
    final token = <String, dynamic>{
      'coinType': 'ETH',
      'mKey': '0xTESTTOKEN',
      'miniName': 'TEST',
      'symbol': 'TEST',
      'name': 'Test token',
      'contract': '0xTESTTOKEN',
      'isContract': true,
      'decimals': 6,
    };

    wallet.addWalletChainToken(token);

    final testTokens =
        wallet.walletMap['ETH']['testnets'][0]['testnetContract'] as Map;
    expect(testTokens.keys, ['0xTESTTOKEN']);
    expect(wallet.coinList.single.isTest, isTrue);
  });

  test('removing a token clears its model and only its pin record', () {
    final token = <String, dynamic>{
      'coinType': 'ETH',
      'mKey': '0xTOKEN',
      'miniName': 'USDC',
      'symbol': 'USDC',
      'name': 'USD Coin',
      'contract': '0xtoken',
      'isContract': true,
      'decimals': 6,
    };
    wallet.walletInfoLsit.add(
      WalletInfo()
        ..coinInfo = {
          'ETH': {
            'isTest': false,
            'baseInfo': {'coinType': 'ETH', 'isContract': false},
            'mainnets': {'0XTOKEN': token},
          },
        }
        ..pinnedCoins = ['ETH_USDC', 'ETH_DAI', 'BTC'],
    );
    wallet.walletIndex = 0;
    wallet.coinList.add(
      CoinModel()
        ..coin = {
          'coinType': 'ETH',
          'mKey': '0XTOKEN',
          'miniName': 'USDC',
          'contract': '0xTOKEN',
          'isContract': true,
        },
    );

    wallet.removeWalletChainToken(token, symbol: 'ETH');

    expect(wallet.walletMap['ETH']['mainnets'], isEmpty);
    expect(wallet.coinList, isEmpty);
    expect(wallet.walletInfo.pinnedCoins, ['ETH_DAI', 'BTC']);
  });
}
