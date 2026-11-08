import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/browser/presentation/providers/browser_providers.dart';
import 'package:n42_wallet/features/browser/provider/browser_provider.dart';
import 'package:n42_wallet/features/browser/widgets/dapp_asset_suggestion_sheet.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../test/helpers/widget_test_helpers.dart';

const _enabled = bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');
const _contract = '0x52908400098527886E0F7030069857D2E4169EE7';
const _cancelledContract = '0x1111111111111111111111111111111111111111';

// Only bookmark/history persistence is isolated. BrowserPage, provider, RPC,
// approval sheet, wallet mutation and native secure storage are production code.
class _OwnedBrowserApi extends BrowserApi {
  @override
  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
    String url,
  ) async => [];
  @override
  Future<int> insertBrowserHistory(String url, {String? title}) async => 1;
}

class _OwnedBrowser extends BrowserProvider {
  final _api = _OwnedBrowserApi();
  @override
  BrowserApi get browserApi => _api;
}

class _NoRelay extends WalletConnectProvider {
  @override
  Future<void> connectInit() async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'NATIVE-ASSET actual browser approval persists only its owned watch wallet',
    (tester) async {
      final device = DeviceInfoPlugin();
      final virtual = Platform.isAndroid
          ? !(await device.androidInfo).isPhysicalDevice
          : Platform.isIOS && !(await device.iosInfo).isPhysicalDevice;
      expect(virtual, isTrue, reason: 'Requires an owned disposable emulator.');
      if (!virtual) return;
      final secure = SecureStorage();
      final storage = SPUtil();
      expect(AppGlobals.userInfo, isNull);
      expect(await secure.getUuid(), isNull);
      expect(await secure.getToken(), isNull);
      expect(await secure.getUserInfo(), isNull);
      expect(await storage.getUserInfo(), isNull);
      final owner = 'native-asset-${DateTime.now().microsecondsSinceEpoch}';
      final identity = UserInfo(uuid: owner, name: 'Owned asset fixture');
      final otherIdentity = UserInfo(uuid: '$owner-other');
      final methods = <String>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final rpc = 'http://localhost:${server.port}/rpc';
      final pageUrl = 'http://localhost:${server.port}/dapp';
      final browser = _OwnedBrowser();
      final relay = _NoRelay();
      ProviderContainer? container;
      LegacyWalletActionProviderAdapter? adapter;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        if (adapter != null && !adapter.isDisposed) adapter.dispose();
        container?.dispose();
        await server.close(force: true);
        expect(
          identical(AppGlobals.userInfo, identity) ||
              identical(AppGlobals.userInfo, otherIdentity),
          isTrue,
        );
        AppGlobals.userInfo = null;
        await storage.updateWalletInfo<void>((all) {
          all.remove(owner);
        });
        final remaining = await storage.getWalletInfo() ?? {};
        expect(remaining.containsKey(owner), isFalse);
        expect(remaining.containsKey('$owner-other'), isFalse);
        expect(await secure.getUuid(), isNull);
        expect(await secure.getToken(), isNull);
        expect(await storage.getUserInfo(), isNull);
      });
      server.listen((request) async {
        try {
          if (request.method == 'GET' && request.uri.path == '/dapp') {
            request.response.headers.contentType = ContentType.html;
            request.response.write(
              '<!doctype html><html><head><title>Owned asset QA</title></head><body>Owned asset QA</body></html>',
            );
          } else if (request.method == 'POST' && request.uri.path == '/rpc') {
            final body =
                jsonDecode(await utf8.decoder.bind(request).join()) as Map;
            final method = body['method'] as String;
            methods.add(method);
            expect(request.headers.value('authorization'), isNull);
            final params = body['params'] as List;
            if (method == 'eth_call') {
              expect([
                _contract,
                _cancelledContract,
              ], contains(params.first['to']));
            }
            final result = switch (method) {
              'eth_chainId' => '0x7a69',
              'eth_getCode' => '0x6000',
              'eth_call' =>
                params.first['data'] == '0x95d89b41'
                    ? '0x414243${''.padRight(58, '0')}'
                    : '0x${'12'.padLeft(64, '0')}',
              _ => null,
            };
            request.response.headers.contentType = ContentType.json;
            request.response.write(
              jsonEncode({
                'jsonrpc': '2.0',
                'id': body['id'],
                'result': ?result,
                if (result == null)
                  'error': {
                    'code': -32601,
                    'message': 'Fixture method unavailable',
                  },
              }),
            );
          } else {
            request.response.statusCode = 204;
          }
          await request.response.close();
        } catch (_) {
          try {
            await request.response.close();
          } catch (_) {}
        }
      });
      AppGlobals.userInfo = identity;
      final base = <String, dynamic>{
        'coinType': 'ETH',
        'mKey': 'QA_EVM',
        'name': 'Owned EVM',
        'miniName': 'QA',
        'unit': 'QA',
        'blockchainType': 'Ethereum',
        'chainId': 31337,
        'chainId_test': 31338,
        'service': rpc,
        'service_test': rpc,
        'contract': '',
        'contract_test': '',
        'isContract': false,
        'decimals': 18,
        'icon': '',
        'balance': '9000000000000000000',
        'coinPrice': 2000.0,
      };
      final wallet =
          WalletInfo(
              walletName: 'Owned watch wallet',
              walletUuid: owner,
              timestamp: owner,
              coinInfo: {
                'QA_EVM': {
                  'baseInfo': base,
                  'isTest': false,
                  'showList': true,
                  'pathIndex': 0,
                  'addrType': 'legacy',
                  'mainnets': <String, dynamic>{},
                  'testnets': [
                    {'testnetContract': <String, dynamic>{}},
                  ],
                },
              },
            )
            ..watchOnly = true
            ..watchAddress = _cancelledContract;
      await storage.updateWalletInfo<void>((all) {
        expect(all.containsKey(owner), isFalse);
        all[owner] = {
          'index': 0,
          'miningIndex': 0,
          'wallet': [wallet.toJson()],
        };
      });
      container = ProviderContainer();
      app.globalProviderContainer = container;
      adapter = LegacyWalletActionProviderAdapter(container);
      globalWapAdapter = adapter;
      adapter.walletInfoList.add(wallet);
      adapter.walletIndex = 0;
      final parent = CoinModel.fromMap(base)
        ..address = _cancelledContract
        ..isTest = false;
      adapter.coinModels.add(parent);
      adapter.coinList.add(parent);
      await Clipboard.setData(const ClipboardData(text: ''));
      await tester.pumpWidget(
        WidgetTestWrapper(
          providerOverrides: [
            browserNotifierProvider.overrideWith((ref) => browser),
            wcpBridgeProvider.overrideWith((ref) => relay),
          ],
          child: BrowserPage(pageUrl),
        ),
      );
      Future<void> waitUntil(bool Function() ready, String reason) async {
        for (var attempt = 0; attempt < 200; attempt++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (ready()) return;
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
        }
        expect(ready(), isTrue, reason: reason);
      }

      await waitUntil(
        () =>
            browser.wvcList.isNotEmpty &&
            browser.wInfoList.last['load'] == false,
        'Owned browser document did not finish loading.',
      );
      final WebViewController controller = browser.wvcList.last;
      Future<bool> flag(String expression) async {
        final value = await controller.runJavaScriptReturningResult(expression);
        return value == true || value.toString() == 'true';
      }

      expect(
        await flag(
          '!!window.ethereum && window.ethereum._n42BridgeStatus() !== "missing"',
        ),
        isTrue,
      );
      Future<void> suggest(String address) => controller.runJavaScript('''
window.__qaAssetResult = 'pending';
window.ethereum.request({method:'wallet_watchAsset',params:{type:'ERC20',options:{
 address:${jsonEncode(address)},chainId:31337,symbol:'ABC',decimals:18
}}}).then(function(value){window.__qaAssetResult=value;},function(error){window.__qaAssetResult={code:error.code};});
''');
      Future<Map> persistedTokens() async {
        final all = await storage.getWalletInfo();
        return all![owner]['wallet'][0]['coinInfo']['QA_EVM']['mainnets']
            as Map;
      }

      await suggest(_contract);
      await waitUntil(
        () => find.byType(DAppAssetSuggestionSheet).evaluate().isNotEmpty,
        'Asset approval did not appear.',
      );
      expect(await flag('window.__qaAssetResult === true'), isTrue);
      expect(await persistedTokens(), isEmpty);
      final sheet = find.byType(DAppAssetSuggestionSheet);
      expect(find.text('Owned EVM (31337)'), findsOneWidget);
      await tester.tap(
        find.descendant(of: sheet, matching: find.byType(FilledButton)),
      );
      await waitUntil(
        () => find.byType(DAppAssetSuggestionSheet).evaluate().isEmpty,
        'Acknowledged asset approval did not close.',
      );
      await tester.pumpAndSettle();
      final saved = await persistedTokens();
      expect(saved.length, 1);
      expect(saved.values.single['contract'], _contract);
      expect(saved.values.single['balance'], '0');
      expect(saved.values.single['coinPrice'], 0.0);
      expect(adapter.coinList.last.balance, BigInt.zero);
      final reopened = WalletActionProvider();
      try {
        await reopened.getWalletInfo();
        final tokens =
            reopened.walletInfo.coinInfo!['QA_EVM']['mainnets'] as Map;
        expect(tokens.length, 1);
        expect(tokens.values.single['decimals'], 18);
      } finally {
        reopened.dispose();
      }
      await suggest(_cancelledContract);
      await waitUntil(
        () => find.byType(DAppAssetSuggestionSheet).evaluate().isNotEmpty,
        'Cancellation preview did not appear.',
      );
      await tester.tap(find.text(S.current.g_key_79));
      await waitUntil(
        () => find.byType(DAppAssetSuggestionSheet).evaluate().isEmpty,
        'Cancelled preview did not close.',
      );
      await tester.pumpAndSettle();
      expect((await persistedTokens()).length, 1);
      await suggest(_cancelledContract);
      await waitUntil(
        () => find.byType(DAppAssetSuggestionSheet).evaluate().isNotEmpty,
        'Account-bound preview did not appear.',
      );
      AppGlobals.userInfo = otherIdentity;
      await tester.tap(
        find.descendant(
          of: find.byType(DAppAssetSuggestionSheet),
          matching: find.byType(FilledButton),
        ),
      );
      await waitUntil(
        () => find
            .byKey(const ValueKey('asset-save-error'))
            .evaluate()
            .isNotEmpty,
        'Stale owner save did not fail in place.',
      );
      expect((await persistedTokens()).length, 1);
      expect(
        (await storage.getWalletInfo())!.containsKey('$owner-other'),
        isFalse,
      );
      await tester.tap(find.text(S.current.g_key_79));
      await tester.pumpAndSettle();
      AppGlobals.userInfo = identity;
      expect(methods, isNotEmpty);
      expect(
        methods.every({'eth_chainId', 'eth_getCode', 'eth_call'}.contains),
        isTrue,
      );
      expect(
        methods.any(
          (method) => method.contains('send') || method.contains('sign'),
        ),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
    skip: !_enabled,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
