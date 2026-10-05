import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform(super.data);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const accountUuid = 'wallet-additional-behavior-user';
  const watchAddress = '0x1111111111111111111111111111111111111111';

  late WalletActionProvider provider;
  late _WalletStoragePlatform secureStorage;
  late FlutterSecureStoragePlatform previousStoragePlatform;
  late UserInfo? previousUser;
  late Map<String, dynamic> previousChainUrlMap;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    previousUser = AppGlobals.userInfo;
    previousStoragePlatform = FlutterSecureStoragePlatform.instance;
    previousChainUrlMap = chainUrlMap;
    AppGlobals.userInfo = UserInfo(uuid: accountUuid);
    secureStorage = _WalletStoragePlatform({});
    FlutterSecureStoragePlatform.instance = secureStorage;
    app.globalProviderContainer = ProviderContainer();
    provider = WalletActionProvider()..buildwallet = true;
  });

  tearDown(() async {
    provider.dispose();
    app.globalProviderContainer.dispose();
    FlutterSecureStoragePlatform.instance = previousStoragePlatform;
    AppGlobals.userInfo = previousUser;
    chainUrlMap = previousChainUrlMap;
  });

  test(
    'watch-only wallet trims inputs and persists only EVM chain configs',
    () async {
      await provider.addWatchOnlyWallet('  ', '  $watchAddress  ');

      expect(provider.walletInfoList, hasLength(1));
      final wallet = provider.walletInfoList.single;
      expect(wallet.walletName, 'Watch 1');
      expect(wallet.walletUuid, accountUuid);
      expect(wallet.watchOnly, isTrue);
      expect(wallet.watchAddress, watchAddress);
      expect(wallet.mainWallet, isFalse);
      expect(wallet.hasMnemonic, isFalse);
      expect(wallet.hasPrivateKey, isFalse);
      expect(wallet.coinInfo, isNotEmpty);
      expect(
        wallet.coinInfo!.values.every(
          (chain) =>
              (chain as Map<String, dynamic>)['baseInfo']['blockchainType'] ==
              'Ethereum',
        ),
        isTrue,
      );

      final persisted = await SPUtil().getWalletInfo();
      final persistedWallets =
          (persisted![accountUuid]['wallet'] as List<dynamic>);
      final savedWallet = persistedWallets.single as Map<String, dynamic>;
      expect(savedWallet['watchOnly'], isTrue);
      expect(savedWallet['watchAddress'], watchAddress);
      expect(savedWallet['walletName'], 'Watch 1');
      expect(
        ((savedWallet['coinInfo'] as Map<String, dynamic>).values).every(
          (chain) =>
              (chain as Map<String, dynamic>)['baseInfo']['blockchainType'] ==
              'Ethereum',
        ),
        isTrue,
      );
      expect(
        jsonDecode(secureStorage.data['walletInfo']!) as Map<String, dynamic>,
        contains(accountUuid),
      );
    },
  );

  test(
    'failed wallet rebuild restores the previously visible coin lists',
    () async {
      chainUrlMap = {
        'ETH': {'baseInfo': null, 'showList': true},
      };
      final brokenWallet = WalletInfo(
        walletName: 'Stored wallet',
        timestamp: 'wallet-with-invalid-chain',
        coinInfo: {
          'ETH': {'baseInfo': null},
        },
      )..mainWallet = true;
      await SPUtil().setWalletInfo({
        accountUuid: {
          'index': 0,
          'miningIndex': 0,
          'wallet': [brokenWallet.toJson()],
        },
      });

      final previousCoin = CoinModel();
      provider
        ..buildwallet = false
        ..coinList.add(previousCoin)
        ..coinModels.add(previousCoin);

      await expectLater(provider.initWallet(), throwsA(isA<TypeError>()));

      expect(provider.buildwallet, isFalse);
      expect(provider.coinList, [same(previousCoin)]);
      expect(provider.coinModels, [same(previousCoin)]);
    },
  );
}
