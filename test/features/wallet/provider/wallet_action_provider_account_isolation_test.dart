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
}
