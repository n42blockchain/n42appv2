import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/entities/user_info.dart';

import '../../test/helpers/widget_test_helpers.dart';

const _enabled = bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');

class _LoginMarket extends MarketApi {
  @override
  Future<Map<String, dynamic>> getWalletCoinsInfo(String coins) async => {
    'error': false,
    'data': [
      {'coin': 'ETH', 'price': 1},
    ],
  };
}

void registerWalletLoginFixture() {
  testWidgets('WLT-14 native host login isolates delayed wallet balances', (
    tester,
  ) async {
    final info = DeviceInfoPlugin();
    final virtual = Platform.isAndroid
        ? !(await info.androidInfo).isPhysicalDevice
        : Platform.isIOS && !(await info.iosInfo).isPhysicalDevice;
    expect(virtual, isTrue, reason: 'Requires the disposable QA simulator.');
    if (!virtual) return;
    final secure = SecureStorage();
    final storage = SPUtil();
    // Refuse to overwrite any existing host authentication.
    expect(AppGlobals.userInfo, isNull);
    expect(await secure.getUuid(), isNull);
    expect(await secure.getUserInfo(), isNull);
    expect(await secure.getToken(), isNull);
    expect(await storage.getUserInfo(), isNull);
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final firstOwner = 'native-login-a-$suffix';
    final secondOwner = 'native-login-b-$suffix';
    const firstAddress = '0x1111111111111111111111111111111111111111';
    const secondAddress = '0x2222222222222222222222222222222222222222';
    final original = await storage.getWalletInfo() ?? <String, dynamic>{};
    expect(
      original.containsKey(firstOwner) || original.containsKey(secondOwner),
      isFalse,
    );
    final originalChains = chainUrlMap;
    final staleRequested = Completer<void>();
    final staleRelease = Completer<void>();
    final staleReturned = Completer<void>();
    var holdOld = false;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    ProviderContainer? container;
    LegacyWalletActionProviderAdapter? adapter;
    TransactionRecordItemProvider? ownedTransactions;
    addTearDown(() async {
      if (!staleRelease.isCompleted) staleRelease.complete();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      if (adapter != null && !adapter.isDisposed) adapter.dispose();
      container?.dispose();
      ownedTransactions?.dispose();
      await server.close(force: true);
      AppGlobals.userInfo = null;
      // Remove only the two auth fields written by these token-free identities.
      await secure.deleteUuid();
      await secure.deleteUserInfo();
      await storage.saveUserInfo(null);
      expect(await secure.getUuid(), isNull);
      expect(await secure.getUserInfo(), isNull);
      final all = await storage.getWalletInfo() ?? <String, dynamic>{};
      all.remove(firstOwner);
      all.remove(secondOwner);
      await storage.setWalletInfo(all);
      final cleaned = await storage.getWalletInfo() ?? <String, dynamic>{};
      expect(
        cleaned.containsKey(firstOwner) || cleaned.containsKey(secondOwner),
        isFalse,
      );
      for (final entry in original.entries) {
        expect(
          jsonEncode(cleaned[entry.key]) == jsonEncode(entry.value),
          isTrue,
        );
      }
      chainUrlMap = originalChains;
    });
    server.listen((request) async {
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
      final params = body['params'];
      final address = params is List && params.isNotEmpty ? params.first : null;
      final stale =
          body['method'] == 'eth_getBalance' &&
          address == firstAddress &&
          holdOld;
      if (stale) {
        if (!staleRequested.isCompleted) staleRequested.complete();
        await staleRelease.future;
      }
      final units =
          BigInt.from(
            address == secondAddress
                ? 2
                : stale
                ? 9
                : 1,
          ) *
          BigInt.from(10).pow(18);
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': body['id'],
          if (body['method'] == 'eth_getBalance')
            'result': '0x${units.toRadixString(16)}'
          else
            'error': {'code': -32601, 'message': 'Read-only QA RPC'},
        }),
      );
      await request.response.close();
      if (stale && !staleReturned.isCompleted) staleReturned.complete();
    });
    final eth =
        jsonDecode(jsonEncode(originalChains['ETH'])) as Map<String, dynamic>;
    eth['mainnets'] = <String, dynamic>{};
    eth['testnets'] = <dynamic>[];
    eth['baseInfo']['service'] = 'http://127.0.0.1:${server.port}';
    eth['baseInfo']['service_test'] = eth['baseInfo']['service'];
    chainUrlMap = {'ETH': eth};
    final seeded = <String, dynamic>{...original};
    for (final entry in [
      (firstOwner, firstAddress, 'Login A'),
      (secondOwner, secondAddress, 'Login B'),
    ]) {
      final wallet =
          WalletInfo(
              walletName: entry.$3,
              walletUuid: entry.$1,
              timestamp: entry.$1,
              password: '0',
              mnemonic: '',
              coinInfo:
                  jsonDecode(jsonEncode(chainUrlMap)) as Map<String, dynamic>,
            )
            ..watchOnly = true
            ..watchAddress = entry.$2;
      seeded[entry.$1] = {
        'index': 0,
        'miningIndex': 0,
        'wallet': [wallet.toJson()],
      };
    }
    await storage.setWalletInfo(seeded);
    late final ProviderContainer root;
    root = ProviderContainer(
      overrides: [
        walletServiceProvider.overrideWith((ref) {
          final service = WalletServiceImpl(root);
          ref.onDispose(service.dispose);
          return service;
        }),
      ],
    );
    container = root;
    app.globalProviderContainer = root;
    final active = LegacyWalletActionProviderAdapter(
      root,
      marketApi: _LoginMarket(),
      stablecoinPriceRequest: (_) async => null,
    );
    adapter = active;
    globalWapAdapter = active;
    final connections = WalletConnectProvider();
    globalWcpInstance = connections;
    try {
      // An earlier wallet flow may already own the global transaction provider.
      final existing = globalTripInstance;
      expect(existing, isA<TransactionRecordItemProvider>());
    } catch (_) {
      final transactions = TransactionRecordItemProvider(
        userUuid: () => AppGlobals.walletStorageUuid,
      );
      ownedTransactions = transactions;
      globalTripInstance = transactions;
    }
    await AppGlobals.login(UserInfo(uuid: firstOwner));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: root,
        child: wrapForTest(
          const WalletPage(),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => active),
            wcpBridgeProvider.overrideWith((ref) => connections),
          ],
        ),
      ),
    );
    Future<void> expectBalance(String owner, int amount) async {
      for (var attempt = 0; attempt < 600; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (active.isWalletReady &&
            active.walletInfo.walletUuid == owner &&
            active.coinList.any(
              (coin) =>
                  coin.balance == BigInt.from(amount) * BigInt.from(10).pow(18),
            )) {
          break;
        }
      }
      expect(active.walletInfo.walletUuid, owner);
      final coin = active.coinList.singleWhere(
        (coin) => coin.config.coinType == 'ETH',
      );
      expect(
        coin.balance == BigInt.from(amount) * BigInt.from(10).pow(18),
        isTrue,
      );
    }

    await expectBalance(firstOwner, 1);
    holdOld = true;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    for (
      var attempt = 0;
      attempt < 300 && !staleRequested.isCompleted;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(staleRequested.isCompleted, isTrue);
    await AppGlobals.login(UserInfo(uuid: secondOwner));
    await expectBalance(secondOwner, 2);
    staleRelease.complete();
    for (
      var attempt = 0;
      attempt < 300 && !staleReturned.isCompleted;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(staleReturned.isCompleted, isTrue);
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await expectBalance(secondOwner, 2);
    expect(active.userUUID, secondOwner);
    expect(root.read(currentUserProvider)?.uuid, secondOwner);
    final listed = await root.read(walletListProvider.future);
    expect(listed, hasLength(1));
    expect(listed.single.walletUuid, secondOwner);
    expect(await secure.getToken(), isNull);
    expect(await secure.getUuid(), secondOwner);
    expect((await secure.getUserInfo())?['uuid'], secondOwner);
    expect((await storage.getUserInfo())?['uuid'], secondOwner);
    expect(
      active.walletMap['ETH']['baseInfo']['balance'],
      '2000000000000000000',
    );
    expect(find.text('Login B'), findsWidgets);
    expect(find.text('Login A'), findsNothing);
    expect(
      tester.widget<WalletBoard>(find.byType(WalletBoard)).accountPrice,
      2,
    );
    expect(tester.takeException(), isNull);
  }, skip: !_enabled);
}
