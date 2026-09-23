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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );
    wallet = WalletActionProvider();
  });

  tearDown(() {
    wallet.dispose();
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
}
