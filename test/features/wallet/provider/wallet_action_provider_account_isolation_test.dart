import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform(super.data, {this.failingReadKey});

  final String? failingReadKey;

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    if (key == failingReadKey) throw StateError('synthetic storage failure');
    return super.read(key: key, options: options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const trustdart = MethodChannel('trustdart');
  const generatedMnemonic = 'synthetic alpha beta gamma delta epsilon';
  const accountUuid = 'synthetic-new-account';

  late WalletActionProvider store;
  late _WalletStoragePlatform secureStorage;
  late UserInfo? previousUser;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    previousUser = AppGlobals.userInfo;
    AppGlobals.userInfo = UserInfo(uuid: accountUuid);
    app.globalProviderContainer = ProviderContainer();
    store = WalletActionProvider()..buildwallet = true;

    final previousWallet = WalletInfo(
      walletName: 'Wallet from previous account',
      walletUuid: 'previous-account',
      timestamp: 'synthetic-previous-wallet',
    )..mainWallet = true;
    final encodedWallets = jsonEncode({
      'AstranetWallet': {
        'index': 0,
        'miningIndex': 0,
        'wallet': [previousWallet.toJson()],
      },
    });
    secureStorage = _WalletStoragePlatform({'walletInfo': encodedWallets});
    FlutterSecureStoragePlatform.instance = secureStorage;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdart, (call) async {
          expect(call.method, 'generateMnemonic');
          return generatedMnemonic;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdart, null);
    app.globalProviderContainer.dispose();
    AppGlobals.userInfo = previousUser;
  });

  test(
    'new account creates its own wallet and preserves anonymous wallet',
    () async {
      await store.getWalletInfo();

      expect(store.walletInfoLsit, hasLength(1));
      expect(store.walletInfoLsit.single.walletName, 'Account1');
      expect(store.walletInfoLsit.single.walletUuid, accountUuid);
      expect(store.walletInfoLsit.single.mnemonic, generatedMnemonic);

      final persisted =
          jsonDecode(secureStorage.data['walletInfo']!) as Map<String, dynamic>;
      expect(
        (persisted['AstranetWallet']
            as Map<String, dynamic>)['wallet'][0]['walletName'],
        'Wallet from previous account',
      );
      expect(
        (persisted[accountUuid]
            as Map<String, dynamic>)['wallet'][0]['walletName'],
        'Account1',
      );
      expect(persisted, contains('AstranetWallet'));
    },
  );

  test(
    'getWalletInfo restores a missing mnemonic from secure storage',
    () async {
      const walletId = 'wallet-missing-json-mnemonic';
      const restoredMnemonic = 'synthetic restored wallet words';
      const legacyMnemonic = 'synthetic legacy wallet words';
      final wallet = WalletInfo(
        walletName: 'Restored wallet',
        walletUuid: accountUuid,
        timestamp: walletId,
      )..mainWallet = true;
      final legacyWallet = WalletInfo(
        walletName: 'Legacy wallet',
        walletUuid: accountUuid,
      );
      secureStorage = _WalletStoragePlatform({
        'walletInfo': jsonEncode({
          accountUuid: {
            'index': 0,
            'wallet': [wallet.toJson(), legacyWallet.toJson()],
          },
        }),
        'mnemonic_$walletId': restoredMnemonic,
        'mnemonic_${accountUuid}_1': legacyMnemonic,
      });
      FlutterSecureStoragePlatform.instance = secureStorage;

      await store.getWalletInfo();

      expect(store.walletInfoLsit, hasLength(2));
      expect(store.walletInfoLsit.first.walletName, 'Restored wallet');
      expect(store.walletInfoLsit[0].mnemonic, restoredMnemonic);
      expect(store.walletInfoLsit[1].mnemonic, legacyMnemonic);
    },
  );

  test('getWalletInfo restores the selected and mining indexes', () async {
    final firstWallet = WalletInfo(walletName: 'First');
    final selectedWallet = WalletInfo(walletName: 'Selected');
    secureStorage = _WalletStoragePlatform({
      'walletInfo': jsonEncode({
        accountUuid: {
          'index': 1,
          'miningIndex': -1,
          'wallet': [firstWallet.toJson(), selectedWallet.toJson()],
        },
      }),
    });
    FlutterSecureStoragePlatform.instance = secureStorage;

    await store.getWalletInfo();

    expect(store.walletInfoLsit.map((wallet) => wallet.walletName), [
      'First',
      'Selected',
    ]);
    expect(store.walletIndex, 1);
    expect(store.walletMiningIndex, 1);
  });

  test('getWalletInfo propagates secure mnemonic read failures', () async {
    final wallet = WalletInfo(
      walletName: 'Wallet missing JSON mnemonic',
      walletUuid: accountUuid,
      timestamp: 'synthetic-wallet-for-read-error',
    );
    secureStorage = _WalletStoragePlatform({
      'walletInfo': jsonEncode({
        accountUuid: {
          'index': 0,
          'wallet': [wallet.toJson()],
        },
      }),
    }, failingReadKey: 'mnemonic_synthetic-wallet-for-read-error');
    FlutterSecureStoragePlatform.instance = secureStorage;

    await expectLater(store.getWalletInfo(), throwsA(isA<StateError>()));
    expect(store.walletInfoLsit.single.walletName, wallet.walletName);
  });

  test('findWallet matches a private key or falls back to mnemonic', () {
    final primary = WalletInfo(walletName: 'Primary')
      ..privateKey = 'private-key-primary'
      ..mnemonic = 'primary recovery words';
    final secondary = WalletInfo(walletName: 'Secondary')
      ..privateKey = 'private-key-secondary'
      ..mnemonic = 'secondary recovery words';
    store.walletInfoLsit.addAll([primary, secondary]);

    expect(
      store.findWallet(
        pk: 'private-key-primary',
        mnemonic: 'secondary recovery words',
      ),
      same(primary),
    );
    expect(
      store.findWallet(mnemonic: 'secondary recovery words'),
      same(secondary),
    );
    expect(store.findWallet(pk: 'unknown-private-key'), isNull);
  });

  test(
    'setMainWallet persists the selected main wallet and emits selection',
    () async {
      final first = WalletInfo(walletName: 'First')..mainWallet = true;
      final second = WalletInfo(walletName: 'Second')..mainWallet = false;
      store.walletInfoLsit.addAll([first, second]);
      store.walletIndex = 0;
      store.walletMiningIndex = 1;
      secureStorage.data['walletInfo'] = jsonEncode({
        accountUuid: {
          'index': 0,
          'miningIndex': 1,
          'wallet': [first.toJson(), second.toJson()],
        },
      });
      final event = eventBus.on<EventPublic>().first;

      final result = store.setMainWallet(1);
      await event;
      await Future<void>.delayed(Duration.zero);

      expect(result.error, isFalse);
      expect(first.mainWallet, isFalse);
      expect(second.mainWallet, isTrue);
      final emitted = await event;
      expect(emitted.type, EventPublicType.selectWallet);
      expect(emitted.intValue, -1);
      expect(emitted.stringValue, 'mainwallet');
      final persisted =
          jsonDecode(secureStorage.data['walletInfo']!) as Map<String, dynamic>;
      final persistedWallets =
          ((persisted[accountUuid] as Map<String, dynamic>)['wallet']
              as List<dynamic>);
      expect(
        persistedWallets.map(
          (wallet) => (wallet as Map<String, dynamic>)['mainWallet'],
        ),
        [false, true],
      );
    },
  );

  test(
    'setMainWallet reports a missing current main wallet without mutation',
    () {
      final first = WalletInfo(walletName: 'First')..mainWallet = false;
      final second = WalletInfo(walletName: 'Second')..mainWallet = false;
      store.walletInfoLsit.addAll([first, second]);

      final result = store.setMainWallet(1);

      expect(result.error, isTrue);
      expect(result.data, 'Main wallet not found!');
      expect(first.mainWallet, isFalse);
      expect(second.mainWallet, isFalse);
    },
  );

  test(
    'deleteWalletInfo removes the default first wallet and clamps index',
    () async {
      final removed = WalletInfo(walletName: 'First');
      final retained = WalletInfo(walletName: 'Second');
      store.walletInfoLsit.addAll([removed, retained]);
      store.walletIndex = 1;

      final result = await store.deleteWalletInfo();

      expect(result, isNull);
      expect(store.walletInfoLsit, [same(retained)]);
      expect(store.walletIndex, 0);
    },
  );

  test('deleteWalletInfo is a no-op when the wallet list is empty', () async {
    expect(await store.deleteWalletInfo(), isNull);
    expect(store.walletIndex, -1);
  });

  test(
    'deleting a wallet before the selected wallet decrements its index',
    () async {
      final first = WalletInfo(walletName: 'First');
      final removed = WalletInfo(walletName: 'Removed');
      final selected = WalletInfo(walletName: 'Selected');
      store.walletInfoLsit.addAll([first, removed, selected]);
      store.walletIndex = 2;
      store.walletMiningIndex = 2;
      secureStorage.data['walletInfo'] = jsonEncode({
        accountUuid: {
          'index': 2,
          'miningIndex': 2,
          'wallet': [first.toJson(), removed.toJson(), selected.toJson()],
        },
      });

      expect(await store.deleteWalletInfo(info: removed), isNull);
      await Future<void>.delayed(Duration.zero);

      expect(store.walletInfoLsit, [same(first), same(selected)]);
      expect(store.walletIndex, 1);
      expect(store.walletMiningIndex, 1);
      final persisted =
          jsonDecode(secureStorage.data['walletInfo']!) as Map<String, dynamic>;
      final account = persisted[accountUuid] as Map<String, dynamic>;
      expect(account['index'], 1);
      expect(account['miningIndex'], 1);
      expect(
        (account['wallet'] as List<dynamic>).map(
          (item) => (item as Map<String, dynamic>)['walletName'],
        ),
        ['First', 'Selected'],
      );
    },
  );

  test(
    'deleting a wallet after the selected wallet preserves its index',
    () async {
      final selected = WalletInfo(walletName: 'Selected');
      final removed = WalletInfo(walletName: 'Removed');
      store.walletInfoLsit.addAll([selected, removed]);
      store.walletIndex = 0;
      secureStorage.data['walletInfo'] = jsonEncode({
        accountUuid: {
          'index': 0,
          'miningIndex': 0,
          'wallet': [selected.toJson(), removed.toJson()],
        },
      });

      expect(await store.deleteWalletInfo(info: removed), isNull);
      await Future<void>.delayed(Duration.zero);

      expect(store.walletInfoLsit, [same(selected)]);
      expect(store.walletIndex, 0);
    },
  );

  test('deleting a wallet outside the list leaves state unchanged', () async {
    final retained = WalletInfo(walletName: 'Retained');
    store.walletInfoLsit.add(retained);
    store.walletIndex = 0;
    final persistedBefore = secureStorage.data['walletInfo'];

    expect(
      await store.deleteWalletInfo(info: WalletInfo(walletName: 'Unknown')),
      isNull,
    );

    expect(store.walletInfoLsit, [same(retained)]);
    expect(store.walletIndex, 0);
    expect(secureStorage.data['walletInfo'], persistedBefore);
  });

  test('deleting the last selected wallet clamps both indexes', () async {
    final retained = WalletInfo(walletName: 'Retained');
    final removed = WalletInfo(walletName: 'Selected');
    store.walletInfoLsit.addAll([retained, removed]);
    store.walletIndex = 1;
    store.walletMiningIndex = 1;
    secureStorage.data['walletInfo'] = jsonEncode({
      accountUuid: {
        'index': 1,
        'miningIndex': 1,
        'wallet': [retained.toJson(), removed.toJson()],
      },
    });

    expect(await store.deleteWalletInfo(info: removed), isNull);
    await Future<void>.delayed(Duration.zero);

    expect(store.walletInfoLsit, [same(retained)]);
    expect(store.walletIndex, 0);
    expect(store.walletMiningIndex, 0);
    final persisted =
        jsonDecode(secureStorage.data['walletInfo']!) as Map<String, dynamic>;
    final account = persisted[accountUuid] as Map<String, dynamic>;
    expect(account['index'], 0);
    expect(account['miningIndex'], 0);
  });

  test(
    'checkWalletMnemonic maps invalid and failing SDK responses to -1',
    () async {
      final info = WalletInfo(walletName: 'Synthetic')
        ..mnemonic = 'synthetic test phrase';
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(trustdart, (call) async {
        expect(call.method, 'checkMnemonic');
        return false;
      });
      expect(await store.checkWalletMnemonic(info), -1);

      messenger.setMockMethodCallHandler(trustdart, (call) async {
        throw PlatformException(code: 'synthetic-sdk-error');
      });
      expect(await store.checkWalletMnemonic(info), -1);
    },
  );
}
