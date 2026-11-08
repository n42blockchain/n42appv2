import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

class _Storage extends TestFlutterSecureStoragePlatform {
  _Storage() : super({});
  bool fail = false;
  Future<void> Function()? beforeRead;
  Future<void> Function()? beforeWrite;
  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    if (key == 'walletInfo') await beforeRead?.call();
    return super.read(key: key, options: options);
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    if (key == 'walletInfo' && fail) throw StateError('storage unavailable');
    if (key == 'walletInfo') await beforeWrite?.call();
    await super.write(key: key, value: value, options: options);
  }
}

Map<String, dynamic> base({String key = 'ETH', int chain = 1}) => {
  'coinType': 'ETH',
  'mKey': key,
  'name': key,
  'miniName': key,
  'unit': key,
  'blockchainType': 'Ethereum',
  'chainId': chain,
  'chainId_test': 11155111,
  'contract': '',
  'decimals': 18,
  'icon': '',
  'isContract': false,
};
Map<String, dynamic> chain({
  String key = 'ETH',
  int id = 1,
  bool testnet = false,
}) => {
  'baseInfo': base(key: key, chain: id),
  'isTest': testnet,
  'pathIndex': 0,
  'addrType': 'legacy',
  'mainnets': <String, dynamic>{},
  'testnets': [
    {'testnetContract': <String, dynamic>{}},
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const contract = '0x52908400098527886E0F7030069857D2E4169EE7';
  late _Storage storage;
  late WalletActionProvider store;
  late WalletInfo wallet;
  late CoinModel parent;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = _Storage();
    FlutterSecureStoragePlatform.instance = storage;
    app.globalProviderContainer = ProviderContainer();
    store = WalletActionProvider();
    wallet = WalletInfo(walletName: 'fixture', timestamp: 'wallet-1')
      ..coinInfo = {'ETH': chain()};
    store.walletInfoList.add(wallet);
    store.walletIndex = 0;
    parent = CoinModel.fromMap(base())..isTest = false;
    store.coinModels.add(parent);
    storage.data['walletInfo'] = jsonEncode({
      store.walletDataOwnerUuid: {
        'index': 0,
        'wallet': [wallet.toJson()],
      },
    });
  });
  tearDown(() {
    app.globalProviderContainer.dispose();
    store.dispose();
  });
  Future<void> add({void Function()? validate}) =>
      store.addConfirmedWalletToken(
        parent: parent,
        contract: contract,
        symbol: 'ABC',
        decimals: 18,
        validateRequest: validate ?? () {},
      );
  Map storedChain(String key) {
    final all = jsonDecode(storage.data['walletInfo']!) as Map;
    return all[store.walletDataOwnerUuid]['wallet'][0]['coinInfo'][key] as Map;
  }

  test(
    'persists exact owner and updates the visible token after acknowledgement',
    () async {
      await add();
      expect((storedChain('ETH')['mainnets'] as Map).length, 1);
      expect(store.coinList.single.coin['contract'], contract);
      expect(parent.tokens.length, 1);
    },
  );
  test('storage failure leaves the list and wallet map unchanged and permits retry', () async {
    storage.fail = true;
    await expectLater(add(), throwsStateError);
    expect(store.coinList, isEmpty);
    expect(wallet.coinInfo!['ETH']['mainnets'], isEmpty);
    storage.fail = false;
    await add();
    expect(store.coinList.length, 1);
  });
  test('concurrent duplicates produce one stored and visible asset', () async {
    await Future.wait([add(), add()]);
    expect((storedChain('ETH')['mainnets'] as Map).length, 1);
    expect(store.coinList.length, 1);
  });
  test('pending read rejects a changed document before mutation', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var active = true;
    storage.beforeRead = () async {
      entered.complete();
      await release.future;
    };
    final pending = add(
      validate: () {
        if (!active) throw StateError('stale');
      },
    );
    await entered.future;
    active = false;
    release.complete();
    await expectLater(pending, throwsStateError);
    expect((storedChain('ETH')['mainnets'] as Map), isEmpty);
    expect(store.coinList, isEmpty);
  });
  test('wallet switch during read cannot add to another wallet', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    storage.beforeRead = () async {
      entered.complete();
      await release.future;
    };
    final pending = add();
    await entered.future;
    store.walletInfoList.add(
      WalletInfo(timestamp: 'wallet-2')..coinInfo = {'ETH': chain()},
    );
    store.walletIndex = 1;
    release.complete();
    await expectLater(pending, throwsStateError);
    expect(store.walletInfo.coinInfo!['ETH']['mainnets'], isEmpty);
    expect((storedChain('ETH')['mainnets'] as Map), isEmpty);
  });
  test('stored wallet replacement rejects the write', () async {
    final all = jsonDecode(storage.data['walletInfo']!) as Map;
    all[store.walletDataOwnerUuid]['wallet'][0]['timestamp'] = 'replacement';
    storage.data['walletInfo'] = jsonEncode(all);
    await expectLater(add(), throwsStateError);
    expect((storedChain('ETH')['mainnets'] as Map), isEmpty);
  });
  test('test-network tokens stay separate from mainnet', () async {
    parent.isTest = true;
    wallet.coinInfo!['ETH'] = chain(testnet: true);
    storage.data['walletInfo'] = jsonEncode({
      store.walletDataOwnerUuid: {
        'index': 0,
        'wallet': [wallet.toJson()],
      },
    });
    await add();
    expect(storedChain('ETH')['mainnets'], isEmpty);
    expect(
      (storedChain('ETH')['testnets'][0]['testnetContract'] as Map).length,
      1,
    );
    expect(store.coinList.single.coin['contract_test'], contract);
    expect(store.coinList.single.coin['balance_test'], '0');
  });
  test('EVM chains sharing coinType use their exact chain key', () async {
    parent = CoinModel.fromMap(base(key: 'POLYGON', chain: 137))
      ..isTest = false;
    store.coinModels.add(parent);
    wallet.coinInfo!['POLYGON'] = chain(key: 'POLYGON', id: 137);
    storage.data['walletInfo'] = jsonEncode({
      store.walletDataOwnerUuid: {
        'index': 0,
        'wallet': [wallet.toJson()],
      },
    });
    await add();
    expect(storedChain('ETH')['mainnets'], isEmpty);
    expect((storedChain('POLYGON')['mainnets'] as Map).length, 1);
  });
  test(
    'concurrent wallet preference save cannot erase the approved token',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      var writes = 0;
      storage.beforeWrite = () async {
        if (++writes == 1) {
          entered.complete();
          await release.future;
        }
      };
      final adding = add();
      await entered.future;
      wallet.walletName = 'Renamed while saving';
      final saving = store.saveWalletInfoOrThrow(wallet, 0);
      release.complete();
      await Future.wait([adding, saving]);
      expect((storedChain('ETH')['mainnets'] as Map).length, 1);
      final all = jsonDecode(storage.data['walletInfo']!) as Map;
      expect(
        all[store.walletDataOwnerUuid]['wallet'][0]['walletName'],
        'Renamed while saving',
      );
    },
  );

  test(
    'failed addition is not copied by a concurrent preference save',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      var writes = 0;
      storage.beforeWrite = () async {
        if (++writes == 1) {
          entered.complete();
          await release.future;
          throw StateError('write failed');
        }
      };
      final adding = add();
      await entered.future;
      wallet.walletName = 'Renamed';
      final saving = store.saveWalletInfoOrThrow(wallet, 0);
      final failed = expectLater(adding, throwsStateError);
      release.complete();
      await failed;
      await saving;
      expect(storedChain('ETH')['mainnets'], isEmpty);
      expect(store.coinList, isEmpty);
    },
  );

  test(
    'intentional removal after acknowledgement is not resurrected',
    () async {
      await add();
      (wallet.coinInfo!['ETH']['mainnets'] as Map).clear();
      await store.saveWalletInfoOrThrow(wallet, 0);
      expect(storedChain('ETH')['mainnets'], isEmpty);
    },
  );

  test('approved asset survives loading a fresh wallet provider', () async {
    await add();
    final reopened = WalletActionProvider();
    try {
      await reopened.getWalletInfo();
      final tokens = reopened.walletInfo.coinInfo!['ETH']['mainnets'] as Map;
      expect(tokens.length, 1);
      expect(tokens.values.single['contract'], contract);
      expect(tokens.values.single['decimals'], 18);
    } finally {
      reopened.dispose();
    }
  });

  test(
    'a new token never inherits the parent native balance or market price',
    () async {
      wallet.coinInfo!['ETH']['baseInfo'].addAll({
        'balance': '9000000000000000000',
        'balance_test': '8000000000000000000',
        'coinPrice': 2000.0,
        'percentage': 12.0,
      });
      storage.data['walletInfo'] = jsonEncode({
        store.walletDataOwnerUuid: {
          'index': 0,
          'wallet': [wallet.toJson()],
        },
      });
      await add();
      expect(store.coinList.single.balance, BigInt.zero);
      expect(store.coinList.single.coinPrice, 0);
      expect(store.coinList.single.value, 0);
    },
  );

  test(
    'legacy wallet without a timestamp remains supported at its bound index',
    () async {
      wallet.timestamp = null;
      storage.data['walletInfo'] = jsonEncode({
        store.walletDataOwnerUuid: {
          'index': 0,
          'wallet': [wallet.toJson()],
        },
      });
      await add();
      expect((storedChain('ETH')['mainnets'] as Map).length, 1);
    },
  );
}
