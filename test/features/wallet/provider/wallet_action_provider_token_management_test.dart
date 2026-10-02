import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
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

Map<String, dynamic> _token({
  required String contract,
  required String miniName,
}) => {
  'coinType': 'ETH',
  'mKey': contract.toUpperCase(),
  'name': miniName,
  'miniName': miniName,
  'symbol': miniName,
  'unit': miniName.toLowerCase(),
  'blockchainType': 'Ethereum',
  'decimals': 6,
  'contract': contract,
  'isContract': true,
};

Map<String, dynamic> _chain({
  Map<String, dynamic>? mainnets,
  bool isTest = false,
  Map<String, dynamic>? testnetTokens,
  bool showList = true,
}) => {
  'baseInfo': _nativeCoin(),
  'isTest': isTest,
  'showList': showList,
  'addrType': 'legacy',
  'pathIndex': 2,
  'mainnets': mainnets ?? <String, dynamic>{},
  'testnets': [
    {'testnetContract': testnetTokens ?? <String, dynamic>{}},
  ],
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
    'adding a hidden chain restores its row and persists visibility',
    () async {
      final chain = _chain(showList: false);
      wallet.coinInfo!['ETH'] = chain;
      final native = CoinModel.fromMap(_nativeCoin())..showList = false;
      store.coinModels.add(native);

      await store.addWalletChain({...chain, 'showList': true});

      expect(store.walletMap['ETH']['showList'], isTrue);
      expect(native.showList, isTrue);
      expect(store.coinList, [same(native)]);
      final persisted =
          jsonDecode(secureStorage.data['walletInfo']!) as Map<String, dynamic>;
      final persistedWallets =
          (persisted['AstranetWallet'] as Map<String, dynamic>)['wallet']
              as List<dynamic>;
      expect(
        (persistedWallets.single as Map<String, dynamic>)['coinInfo'],
        contains('ETH'),
      );
    },
  );

  test('adding a new chain builds its native coin model from config', () async {
    final chain = _chain(showList: true);

    await store.addWalletChain(chain);

    final native = store.coinModels.single;
    expect(store.walletMap['ETH'], same(chain));
    expect(native.coin, same(chain['baseInfo']));
    expect(native.showList, isTrue);
    expect(native.isTest, isFalse);
    expect(native.addrType, 'legacy');
    expect(native.pathIndex, 2);
    expect(store.coinList, [same(native)]);
    expect(store.walletInfo.coinInfo, contains('ETH'));
  });

  test('toggling chain visibility updates the model and wallet config', () {
    final chain = _chain();
    wallet.coinInfo!['ETH'] = chain;
    final native = CoinModel.fromMap(_nativeCoin());
    store.coinModels.add(native);

    store.toggleChainVisibility(native);

    expect(native.showList, isFalse);
    expect(chain['showList'], isFalse);
    expect(store.walletInfo.coinInfo!['ETH']['showList'], isFalse);

    store.toggleChainVisibility(native);

    expect(native.showList, isTrue);
    expect(chain['showList'], isTrue);
  });

  test('removing a chain without tokens deletes its model and pin entries', () {
    wallet.coinInfo!['ETH'] = _chain();
    wallet.pinnedCoins = ['ETH', 'ETH_USDT', 'BTC'];
    final native = CoinModel.fromMap(_nativeCoin());
    store.coinModels.add(native);
    store.coinList.add(native);

    store.removeWalletChain('ETH', 'ETH');

    expect(store.walletMap, isEmpty);
    expect(store.coinModels, isEmpty);
    expect(store.coinList, isEmpty);
    expect(wallet.pinnedCoins, ['BTC']);
  });

  test(
    'removing a chain with tokens hides its native row but retains tokens',
    () {
      final token = _token(
        contract: '0x00000000000000000000000000000000000000AA',
        miniName: 'USDT',
      );
      wallet.coinInfo!['ETH'] = _chain(
        mainnets: {token['mKey'] as String: token},
      );
      wallet.pinnedCoins = ['ETH', 'ETH_USDT', 'BTC'];
      final native = CoinModel.fromMap(_nativeCoin());
      final tokenCoin = CoinModel.fromMap(token);
      store.coinModels.add(native);
      store.coinList.addAll([native, tokenCoin]);

      store.removeWalletChain('ETH', 'ETH');

      expect(store.walletMap['ETH']['showList'], isFalse);
      expect(store.walletMap['ETH']['mainnets'], contains(token['mKey']));
      expect(store.coinModels, [same(native)]);
      expect(store.coinList, [same(tokenCoin)]);
      expect(wallet.pinnedCoins, ['BTC']);
    },
  );

  test('adding a mainnet token copies its parent wallet metadata', () {
    final chain = _chain();
    wallet.coinInfo!['ETH'] = chain;
    final native = CoinModel.fromMap(_nativeCoin())
      ..pathIndex = 7
      ..address = '0x0000000000000000000000000000000000000001'
      ..addressType = {'legacy': '0x0000000000000000000000000000000000000001'};
    store.coinModels.add(native);
    store.coinList.add(native);
    final token = _token(
      contract: '0x00000000000000000000000000000000000000AA',
      miniName: 'USDT',
    );

    store.addWalletChainToken(token);

    final added = store.coinList.last;
    expect(chain['mainnets'], contains(token['mKey']));
    expect(added.coin['mKey'], token['mKey']);
    expect(added.pathIndex, 7);
    expect(added.addrType, 'legacy');
    expect(added.address, native.address);
    expect(added.addressType, native.addressType);
    expect(added.mainCoinIcon, 'eth.png');
  });

  test('adding a duplicate token does not create or persist a second row', () {
    final token = _token(
      contract: '0x00000000000000000000000000000000000000AA',
      miniName: 'USDT',
    );
    final chain = _chain(mainnets: {token['mKey'] as String: token});
    wallet.coinInfo!['ETH'] = chain;
    final native = CoinModel.fromMap(_nativeCoin());
    store.coinModels.add(native);
    store.coinList.add(native);

    store.addWalletChainToken(token);

    expect(store.coinList, [same(native)]);
    expect(chain['mainnets'], hasLength(1));
    expect(secureStorage.data, isEmpty);
  });

  test('testnet token additions stay out of the mainnet contract map', () {
    final chain = _chain(isTest: true);
    wallet.coinInfo!['ETH'] = chain;
    final native = CoinModel.fromMap(_nativeCoin())
      ..isTest = true
      ..pathIndex = 3;
    store.coinModels.add(native);
    final token = _token(
      contract: '0x00000000000000000000000000000000000000BB',
      miniName: 'TEST',
    );

    store.addWalletChainToken(token);

    expect(chain['mainnets'], isEmpty);
    final testnetTokens = (chain['testnets'] as List).single['testnetContract'];
    expect(testnetTokens, contains(token['mKey']));
    expect(store.coinList.single.isTest, isTrue);
    expect(store.coinList.single.pathIndex, 3);
  });

  test('removing one token preserves sibling contracts and pins', () {
    final usdt = _token(
      contract: '0x00000000000000000000000000000000000000AA',
      miniName: 'USDT',
    );
    final usdc = _token(
      contract: '0x00000000000000000000000000000000000000BB',
      miniName: 'USDC',
    );
    wallet.coinInfo!['ETH'] = _chain(
      mainnets: {usdt['mKey'] as String: usdt, usdc['mKey'] as String: usdc},
    );
    wallet.pinnedCoins = ['ETH', 'ETH_USDT', 'ETH_USDC', 'BTC'];
    final native = CoinModel.fromMap(_nativeCoin());
    final usdtCoin = CoinModel.fromMap(usdt);
    final usdcCoin = CoinModel.fromMap(usdc);
    store.coinList.addAll([native, usdtCoin, usdcCoin]);

    store.removeWalletChainToken(usdt, symbol: 'ETH', miniName: 'USDT');

    expect(store.walletMap['ETH']['mainnets'], contains(usdc['mKey']));
    expect(store.walletMap['ETH']['mainnets'], isNot(contains(usdt['mKey'])));
    expect(store.coinList, [same(native), same(usdcCoin)]);
    expect(wallet.pinnedCoins, ['ETH', 'ETH_USDC', 'BTC']);
  });

  test('removing a testnet token leaves mainnet tokens untouched', () {
    final testToken = _token(
      contract: '0x00000000000000000000000000000000000000AA',
      miniName: 'TEST',
    );
    final mainnetToken = _token(
      contract: '0x00000000000000000000000000000000000000BB',
      miniName: 'MAIN',
    );
    final chain = _chain(
      isTest: true,
      mainnets: {mainnetToken['mKey'] as String: mainnetToken},
      testnetTokens: {testToken['mKey'] as String: testToken},
    );
    wallet.coinInfo!['ETH'] = chain;
    wallet.pinnedCoins = ['ETH_TEST', 'ETH_MAIN'];
    final native = CoinModel.fromMap(_nativeCoin())..isTest = true;
    final testCoin = CoinModel.fromMap(testToken);
    final mainCoin = CoinModel.fromMap(mainnetToken);
    store.coinList.addAll([native, testCoin, mainCoin]);

    store.removeWalletChainToken(testToken, symbol: 'ETH', miniName: 'TEST');

    expect(chain['mainnets'], contains(mainnetToken['mKey']));
    final testnetTokens = (chain['testnets'] as List).single['testnetContract'];
    expect(testnetTokens, isNot(contains(testToken['mKey'])));
    expect(store.coinList, [same(native), same(mainCoin)]);
    expect(wallet.pinnedCoins, ['ETH_MAIN']);
  });
}
