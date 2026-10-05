import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform(super.data);
}

Map<String, dynamic> _importSourceChain() => {
  'baseInfo': {
    'coinType': 'ETH',
    'name': 'Ethereum',
    'service': 'https://stored.example/rpc',
    'path': {'legacy': "m/44'/60'/0'/0/0"},
    'isTest': true,
    'mainnets': <String, dynamic>{
      'LIVE': {'symbol': 'LIVE'},
    },
    'balance': '12.5',
    'balance_test': '7.25',
    'canEdit': true,
  },
  'isTest': true,
  'showList': true,
  'mainnets': <String, dynamic>{
    'LIVE': {'symbol': 'LIVE'},
  },
  'testnets': <dynamic>[],
  'addrType': 'legacy',
  'pathIndex': 0,
};

Map<String, dynamic> _nChain({
  required Map<String, dynamic> baseInfo,
  String? addressType = 'legacy',
}) => {'baseInfo': baseInfo, 'addrType': ?addressType, 'pathIndex': 5};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const trustdart = MethodChannel('trustdart');
  const userId = 'wallet-provider-behavior-user';

  late WalletActionProvider provider;
  late _WalletStoragePlatform secureStorage;
  late FlutterSecureStoragePlatform previousStoragePlatform;
  late UserInfo? previousUser;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    previousUser = AppGlobals.userInfo;
    previousStoragePlatform = FlutterSecureStoragePlatform.instance;
    AppGlobals.userInfo = UserInfo(uuid: userId);
    secureStorage = _WalletStoragePlatform({});
    FlutterSecureStoragePlatform.instance = secureStorage;
    app.globalProviderContainer = ProviderContainer();
    provider = WalletActionProvider()..buildwallet = true;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdart, null);
    await Future<void>.delayed(Duration.zero);
    provider.dispose();
    app.globalProviderContainer.dispose();
    FlutterSecureStoragePlatform.instance = previousStoragePlatform;
    AppGlobals.userInfo = previousUser;
  });

  test(
    'importing a chain clones its config without mutating the active wallet',
    () async {
      final sourceChain = _importSourceChain();
      final originalChain =
          jsonDecode(jsonEncode(sourceChain)) as Map<String, dynamic>;
      final activeWallet = WalletInfo(walletName: 'Active wallet')
        ..coinInfo = {'ETH': sourceChain};
      provider.walletInfoList.add(activeWallet);
      provider.walletIndex = 0;
      await SPUtil().setWalletInfo({
        userId: {
          'index': 0,
          'miningIndex': 0,
          'wallet': [activeWallet.toJson()],
        },
      });

      final importedWallet = WalletInfo(
        walletName: 'ETH',
        walletUuid: userId,
        privateKey: 'synthetic-private-key',
      );
      expect(await provider.addImportWalletInfo(importedWallet), isTrue);

      expect(activeWallet.coinInfo!['ETH'], equals(originalChain));
      final importedChain =
          importedWallet.coinInfo!['ETH'] as Map<String, dynamic>;
      final importedBaseInfo =
          importedChain['baseInfo'] as Map<String, dynamic>;
      expect(importedChain, isNot(same(sourceChain)));
      expect(importedBaseInfo, isNot(same(sourceChain['baseInfo'])));
      // Imported wallets start with clean network state. The source wallet
      // keeps its network selection and balances unchanged.
      expect(importedBaseInfo['isTest'], isFalse);
      expect(importedBaseInfo['mainnets'], isEmpty);
      expect(importedBaseInfo['balance'], '0');
      expect(importedBaseInfo['balance_test'], '0');
      expect(importedBaseInfo['canEdit'], isFalse);
      final importedPath = importedBaseInfo['path'] as Map<String, dynamic>;
      final activeBaseInfo = sourceChain['baseInfo'] as Map<String, dynamic>;
      expect(importedPath, isNot(same(activeBaseInfo['path'])));
      importedPath['legacy'] = 'synthetic changed path';
      expect(
        (activeBaseInfo['path'] as Map<String, dynamic>)['legacy'],
        "m/44'/60'/0'/0/0",
      );

      final importedTokens = importedChain['mainnets'] as Map<String, dynamic>;
      final activeTokens = sourceChain['mainnets'] as Map<String, dynamic>;
      expect(importedTokens, {
        'LIVE': {'symbol': 'LIVE'},
      });
      expect(importedTokens, isNot(same(activeTokens)));
      (importedTokens['LIVE'] as Map<String, dynamic>)['symbol'] = 'CHANGED';
      expect((activeTokens['LIVE'] as Map<String, dynamic>)['symbol'], 'LIVE');
      expect(activeWallet.coinInfo!['ETH'], equals(originalChain));

      final persisted = await SPUtil().getWalletInfo();
      final persistedWallets = (persisted![userId]['wallet'] as List<dynamic>);
      expect(persistedWallets, hasLength(2));
      final persistedImport = persistedWallets.last as Map<String, dynamic>;
      final persistedChain =
          (persistedImport['coinInfo'] as Map<String, dynamic>)['ETH']
              as Map<String, dynamic>;
      expect(persistedChain['mainnets'], {
        'LIVE': {'symbol': 'LIVE'},
      });
      expect(persistedImport['walletName'], 'ETH');
    },
  );

  test(
    'import rejects a missing wallet name without changing wallet state',
    () async {
      final existing = WalletInfo(walletName: 'Active wallet')
        ..coinInfo = <String, dynamic>{};
      provider.walletInfoList.add(existing);
      provider.walletIndex = 0;

      expect(
        await provider.addImportWalletInfo(WalletInfo(walletName: '')),
        isFalse,
      );

      expect(provider.walletInfoList, [same(existing)]);
      expect(secureStorage.data, isEmpty);
    },
  );

  test('import rejects an unsupported chain without adding a wallet', () async {
    final existing = WalletInfo(walletName: 'Active wallet')
      ..coinInfo = <String, dynamic>{};
    provider.walletInfoList.add(existing);
    provider.walletIndex = 0;

    expect(
      await provider.addImportWalletInfo(
        WalletInfo(walletName: 'Unknown chain'),
      ),
      isFalse,
    );

    expect(provider.walletInfoList, [same(existing)]);
    expect(secureStorage.data, isEmpty);
  });

  test(
    'main wallet key lookup skips wallets without a usable N path',
    () async {
      var sdkCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(trustdart, (call) async {
            sdkCalls++;
            return '';
          });

      provider.walletInfoList.addAll([
        WalletInfo(walletName: 'Secondary')
          ..mainWallet = false
          ..coinInfo = {
            'N': _nChain(
              baseInfo: {
                'path': {'legacy': "m/44'/314'/0'/0/0"},
              },
            ),
          },
        WalletInfo(walletName: 'No chain'),
        WalletInfo(walletName: 'No path')
          ..mainWallet = true
          ..coinInfo = {'N': _nChain(baseInfo: <String, dynamic>{})},
        WalletInfo(walletName: 'No address path')
          ..mainWallet = true
          ..coinInfo = {
            'N': _nChain(
              baseInfo: {'path': <String, dynamic>{}},
              addressType: 'legacy',
            ),
          },
      ]);

      final pairs = await provider.publicKeyAndPrivateKeyPair();

      expect(pairs, isEmpty);
      expect(provider.getPrivateKeyWithPublicKey('0102'), isNull);
      expect(sdkCalls, 0);
    },
  );

  test(
    'main wallet key lookup decodes the SDK keypair using its N path',
    () async {
      const mnemonic = 'synthetic recovery phrase';
      const basePath = "m/44'/314'/0'/0/0'";
      var sdkCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(trustdart, (call) async {
            sdkCalls++;
            expect(call.method, 'getPrivateKeyAndPublicKey');
            final arguments = call.arguments as Map<dynamic, dynamic>;
            expect(arguments['coin'], 'N');
            expect(arguments['path'], "m/44'/314'/0'/0/5'");
            expect(arguments['mnemonic'], mnemonic);
            expect(arguments['privateKey'], '');
            return jsonEncode({
              'publicKey': base64Encode([0x01, 0x02]),
              'privateKey': base64Encode([0xa0, 0xb0]),
            });
          });
      provider.walletInfoList.add(
        WalletInfo(walletName: 'Main', mnemonic: mnemonic)
          ..mainWallet = true
          ..coinInfo = {
            'N': _nChain(
              baseInfo: {
                'path': {'legacy': basePath},
              },
            ),
          },
      );

      final pairs = await provider.publicKeyAndPrivateKeyPair();

      expect(sdkCalls, 1);
      expect(pairs, {'0102': 'a0b0'});
      expect(provider.getPrivateKeyWithPublicKey('0102'), 'a0b0');
    },
  );

  test('main wallet key lookup discards a malformed SDK response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdart, (call) async => 'not-json');
    provider.walletInfoList.add(
      WalletInfo(walletName: 'Main', mnemonic: 'synthetic recovery phrase')
        ..mainWallet = true
        ..coinInfo = {
          'N': _nChain(
            baseInfo: {
              'path': {'legacy': "m/44'/314'/0'/0/0"},
            },
          ),
        },
    );

    expect(await provider.publicKeyAndPrivateKeyPair(), isEmpty);
  });

  test('setMainWallet changes the selected main wallet', () async {
    final previousMain = WalletInfo(walletName: 'Previous main')
      ..mainWallet = true;
    final nextMain = WalletInfo(walletName: 'Next main');
    provider.walletInfoList.addAll([previousMain, nextMain]);
    provider.walletIndex = 0;
    await SPUtil().setWalletInfo({
      userId: {
        'index': 0,
        'miningIndex': 0,
        'wallet': [previousMain.toJson(), nextMain.toJson()],
      },
    });

    final result = provider.setMainWallet(1);

    expect(result.error, isFalse);
    expect(previousMain.mainWallet, isFalse);
    expect(nextMain.mainWallet, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final persisted = await SPUtil().getWalletInfo();
    final wallets = persisted![userId]['wallet'] as List<dynamic>;
    expect((wallets[0] as Map<String, dynamic>)['mainWallet'], isFalse);
    expect((wallets[1] as Map<String, dynamic>)['mainWallet'], isTrue);
  });

  test('setMainWallet reports when no wallet is currently marked main', () {
    final first = WalletInfo(walletName: 'First');
    final second = WalletInfo(walletName: 'Second');
    provider.walletInfoList.addAll([first, second]);

    final result = provider.setMainWallet(1);

    expect(result.error, isTrue);
    expect(result.data, 'Main wallet not found!');
    expect(first.mainWallet, isFalse);
    expect(second.mainWallet, isFalse);
  });
}
