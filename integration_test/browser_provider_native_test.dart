import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/features/browser/js/ethereum_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Real platform WebView and JS channels. The native responder only rejects a
// synthetic connection request and recognizes an asset suggestion. Recognition
// does not add an asset; no wallet, account, key or external site is used.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('NATIVE-BROWSER parses, discovers and rejects through the bridge', (
    tester,
  ) async {
    final ready = Completer<void>();
    final result = Completer<Map<String, dynamic>>();
    final calls = <String>[];
    final errors = <String>[];
    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setOnConsoleMessage((message) {
      if (message.level == JavaScriptLogLevel.error) {
        errors.add(message.message);
      }
    });
    await controller.addJavaScriptChannel(
      'N42Qa',
      onMessageReceived: (message) {
        final value = jsonDecode(message.message) as Map<String, dynamic>;
        if (value['ready'] == true) {
          if (!ready.isCompleted) ready.complete();
        } else if (!result.isCompleted) {
          result.complete(value);
        }
      },
    );
    await controller.addJavaScriptChannel(
      'N42Wallet',
      onMessageReceived: (message) async {
        try {
          final request = jsonDecode(message.message) as Map<String, dynamic>;
          calls.add(request['method'] as String);
          if (request['method'] == 'wallet_watchAsset') {
            final params = request['params'] as List;
            expect(params, hasLength(1));
            expect(params.single['type'], 'ERC20');
            expect(
              params.single['options']['address'],
              '0x52908400098527886E0F7030069857D2E4169EE7',
            );
            await controller.runJavaScript(
              'window.ethereum._n42Cb(${jsonEncode(request['id'])}, "true", null);',
            );
            return;
          }

          expect(request['method'], 'eth_requestAccounts');
          expect(request['params'], isEmpty);
          final rejection = jsonEncode({
            'code': 4001,
            'message': 'Synthetic user rejection',
          });
          await controller.runJavaScript(
            'window.ethereum._n42Cb(${jsonEncode(request['id'])}, null, ${jsonEncode(rejection)});',
          );
        } catch (error) {
          if (!result.isCompleted) result.complete({'nativeFailure': '$error'});
        }
      },
    );
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WebViewWidget(controller: controller)),
        ),
      );
      await controller.loadHtmlString(r'''
<!doctype html><html><body>N42 owned native fixture<script>
window.addEventListener('load', function() { N42Qa.postMessage('{"ready":true}'); });
</script></body></html>
''', baseUrl: 'https://n42-native.invalid/');
      final report = await tester.runAsync(() async {
        await ready.future.timeout(const Duration(seconds: 30));
        await controller.runJavaScript(r'''
window.__n42QaAnnouncements = [];
window.addEventListener('eip6963:announceProvider', function(event) {
  window.__n42QaAnnouncements.push(event.detail.info);
});
''');
        await controller.runJavaScript(
          EthereumProviderJs.buildProviderScript('0x1', []),
        );
        await controller.runJavaScript(
          EthereumProviderJs.buildProviderScript('0x1', []),
        );
        await controller.runJavaScript(r'''
window.dispatchEvent(new Event('eip6963:requestProvider'));
Promise.all([
  window.ethereum.request({method: 'eth_chainId'}),
  window.ethereum.request({method: 'eth_accounts'})
]).then(function(values) {
  return window.ethereum.request({method: 'eth_requestAccounts'}).then(function() {
    N42Qa.postMessage('{"unexpectedAuthorization":true}');
  }, function(error) {
    return window.ethereum.request({method: 'wallet_watchAsset', params: {
      type: 'ERC20', options: {address: '0x52908400098527886E0F7030069857D2E4169EE7'}
    }}).then(function(recognized) {
    N42Qa.postMessage(JSON.stringify({
      assetRecognized: recognized,
      chainId: values[0], accounts: values[1], rejectedCode: error.code,
      bridge: window.ethereum._n42BridgeStatus(),
      ids: window.__n42QaAnnouncements.map(function(info) { return info.uuid; }),
      rdns: window.__n42QaAnnouncements[0].rdns,
      legacyProvider: window.web3.currentProvider === window.ethereum,
      userAgent: navigator.userAgent
    }));
    });
  });
}).catch(function(error) { N42Qa.postMessage(JSON.stringify({scriptFailure: String(error)})); });
''');
        return result.future.timeout(const Duration(seconds: 30));
      });
      expect(report, isNotNull);
      expect(report!['chainId'], '0x1');
      expect(report['accounts'], isEmpty);
      expect(report['rejectedCode'], 4001);
      expect(report['assetRecognized'], isTrue);
      expect(report['bridge'], anyOf('direct', 'webkit'));
      expect(report['legacyProvider'], isTrue);
      expect(report['rdns'], 'ai.n42.wallet');
      final ids = (report['ids'] as List).cast<String>();
      expect(ids, hasLength(2));
      expect(
        ids.first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(ids.last, ids.first);
      expect(calls, ['eth_requestAccounts', 'wallet_watchAsset']);
      expect(errors, isEmpty);
      debugPrint('NATIVE_BROWSER_USER_AGENT ${report['userAgent']}');
    } finally {
      await controller.removeJavaScriptChannel('N42Wallet');
      await controller.removeJavaScriptChannel('N42Qa');
      await tester.pumpWidget(const SizedBox.shrink());
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
