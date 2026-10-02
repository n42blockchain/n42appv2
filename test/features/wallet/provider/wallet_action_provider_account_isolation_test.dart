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
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform(super.data);
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
}
