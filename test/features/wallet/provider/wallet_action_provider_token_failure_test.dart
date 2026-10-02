import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform(super.data);
}

Map<String, dynamic> _nativeCoin() => {
  'coinType': 'ETH',
  'mKey': 'ETH',
  'name': 'Ethereum',
  'miniName': 'ETH',
  'unit': 'eth',
  'blockchainType': 'Ethereum',
  'decimals': 18,
  'icon': 'eth.png',
  'isContract': false,
};

Map<String, dynamic> _chain() => {
  'baseInfo': _nativeCoin(),
  'isTest': false,
  'showList': true,
  'addrType': 'legacy',
  'pathIndex': 2,
  'mainnets': <String, dynamic>{},
  'testnets': [
    {'testnetContract': <String, dynamic>{}},
  ],
};

Map<String, dynamic> _token() => {
  'coinType': 'ETH',
  'mKey': '0X00000000000000000000000000000000000000AA',
  'name': 'Synthetic Token',
  'miniName': 'SYN',
  'symbol': 'SYN',
  'unit': 'syn',
  'blockchainType': 'Ethereum',
  'decimals': 6,
  'contract': '0x00000000000000000000000000000000000000AA',
  'isContract': true,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WalletActionProvider store;
  late WalletInfo wallet;
  late _WalletStoragePlatform secureStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    secureStorage = _WalletStoragePlatform({});
    FlutterSecureStoragePlatform.instance = secureStorage;
    app.globalProviderContainer = ProviderContainer();
    store = WalletActionProvider();
    wallet = WalletInfo(walletName: 'Synthetic wallet')
      ..coinInfo = <String, dynamic>{};
    store.walletInfoList.add(wallet);
    store.walletIndex = 0;
  });

  tearDown(() async {
    await Future<void>.delayed(Duration.zero);
    app.globalProviderContainer.dispose();
  });

  test(
    'missing parent coin model leaves token maps and persistence unchanged',
    () {
      final chain = _chain();
      wallet.coinInfo!['ETH'] = chain;

      expect(() => store.addWalletChainToken(_token()), throwsStateError);

      expect(chain['mainnets'], isEmpty);
      expect(store.coinList, isEmpty);
      expect(secureStorage.data, isEmpty);
    },
  );

  test('adding a chain extracts its mainnet token configurations', () async {
    final token = _token();
    final chain = _chain()
      ..['mainnets'] = <String, dynamic>{token['mKey'] as String: token};

    await store.addWalletChain(chain);

    expect(store.coinModels.single.tokens, contains(token['mKey']));
    expect(store.coinModels.single.tokens[token['mKey']], same(token));
  });

  test('test chain extraction ignores mainnet tokens', () async {
    final testToken = _token()
      ..['mKey'] = '0XTEST'
      ..['contract'] = '0xtest';
    final mainnetToken = _token()
      ..['mKey'] = '0XMAIN'
      ..['contract'] = '0xmain';
    final chain = _chain()
      ..['isTest'] = true
      ..['mainnets'] = <String, dynamic>{
        mainnetToken['mKey'] as String: mainnetToken,
      }
      ..['testnets'][0]['testnetContract'] = <String, dynamic>{
        testToken['mKey'] as String: testToken,
      };

    await store.addWalletChain(chain);

    expect(store.coinModels.single.tokens.keys, [testToken['mKey']]);
    expect(
      store.coinModels.single.tokens,
      isNot(contains(mainnetToken['mKey'])),
    );
  });
}
