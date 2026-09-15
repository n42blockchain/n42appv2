import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/provider/browser_provider.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../helpers/browser_platform_fake.dart';

class _Wallet extends Fake implements LegacyWalletActionProviderAdapter {
  @override
  List<CoinModel> coinModels = [];
  @override
  int walletIndex = 0;
}

class _Secrets extends Fake implements IWalletService {
  int reads = 0;
  @override
  Future<String?> getPrivateKeyForWallet(int index) async {
    reads++;
    throw StateError('An expired request must not read a key');
  }
}

class _Bookmarks extends Fake implements BrowserApi {
  final history = <(String, String?)>[];
  final deleted = <String>[];
  Future<List<BrowserCollectionModel>> Function(String) select = (_) async =>
      [];
  @override
  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(String url) =>
      select(url);
  @override
  Future<int> insertBrowserHistory(String url, {String? title}) async {
    history.add((url, title));
    return history.length;
  }

  @override
  Future<int> deleteBrowserCollectionUrl(String url) async {
    deleted.add(url);
    return 1;
  }
}

class _Provider extends BrowserProvider {
  final _bookmarks = _Bookmarks();
  @override
  _Bookmarks get browserApi => _bookmarks;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final wallet = _Wallet();
  late _Provider provider;
  late BrowserPlatformFake platform;
  WebViewPlatform? previousPlatform;
  const address = '0x1111111111111111111111111111111111111111';
  setUpAll(() => globalWapAdapter = wallet);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    wallet.walletIndex = 0;
    wallet.coinModels = [
      CoinModel()
        ..address = address
        ..coin = {
          'coinType': 'ETH',
          'blockchainType': 'Ethereum',
          'chainId': 1,
        },
    ];
    previousPlatform = WebViewPlatform.instance;
    platform = BrowserPlatformFake();
    WebViewPlatform.instance = platform;
    provider = _Provider()..browserInit();
    await Future<void>.delayed(Duration.zero);
  });
  tearDown(() {
    provider.dispose();
    WebViewPlatform.instance = previousPlatform ?? BrowserPlatformFake();
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);
  Future<BrowserControllerFake> tab(String url) async {
    provider.wListAdd(url: url);
    await flush();
    return platform.controllers.last;
  }

  Future<void> message(
    BrowserControllerFake controller,
    String method, {
    int id = 7,
    List<dynamic> params = const [],
  }) async {
    controller.channels['N42Wallet']!.onMessageReceived(
      JavaScriptMessage(
        message: jsonEncode({'id': id, 'method': method, 'params': params}),
      ),
    );
    await flush();
  }

  (int, dynamic, dynamic) response(BrowserControllerFake controller) {
    final script = controller.scripts.lastWhere((s) => s.contains('._n42Cb('));
    final args =
        jsonDecode(
              '[${script.substring(script.indexOf('._n42Cb(') + 8, script.length - 1)}]',
            )
            as List;
    return (
      args[0] as int,
      args[1] == null ? null : jsonDecode(args[1] as String),
      args[2] == null ? null : jsonDecode(args[2] as String),
    );
  }

  test(
    'first load waits for native channels and local storage setup',
    () async {
      final gate = Completer<void>();
      platform.channelGate = gate;
      provider.wListAdd(url: 'https://one.example.test');
      await flush();
      final controller = platform.controllers.single;
      expect(controller.loads, isEmpty);
      expect(controller.channels.keys, ['FlutterWcClipboard']);
      gate.complete();
      await flush();
      expect(controller.calls, [
        'mode:unrestricted',
        'background',
        'navigation',
        'channel:FlutterWcClipboard',
        'channel:N42Wallet',
        'userAgent',
        'console',
        'clearLocalStorage',
        'load',
      ]);
      expect(controller.loads.single.toString(), 'https://one.example.test');
      expect(provider.wListIndex, 0);
      expect(provider.titleEditingController?.text, 'https://one.example.test');
    },
  );

  test(
    'background URL/progress updates stay attached to their original tab',
    () async {
      final first = await tab('https://one.example.test');
      await tab('https://two.example.test');
      first.navigation!.progress!(65);
      first.navigation!.urlChanged!(
        const UrlChange(url: 'https://one.example.test/new'),
      );
      expect(provider.wInfoList[0]['progress'], .65);
      expect(provider.wInfoList[0]['openUrl'], 'https://one.example.test/new');
      expect(provider.wInfoList[1]['progress'], isNull);
      expect(provider.titleEditingController?.text, 'https://two.example.test');
      provider.wListShow(0);
      await flush();
      expect(
        provider.titleEditingController?.text,
        'https://one.example.test/new',
      );
    },
  );

  test('loading completion records the title and clears progress', () async {
    final controller = await tab('https://one.example.test');
    controller.navigation!.started!('https://one.example.test');
    expect(provider.wInfoList.single['load'], isTrue);
    controller.navigation!.progress!(90);
    controller.navigation!.finished!('https://one.example.test');
    await flush();
    expect(provider.wInfoList.single['load'], isFalse);
    expect(provider.wInfoList.single['progress'], 0);
    expect(provider.wInfoList.single['title'], 'Fixture title');
    expect(provider.browserApi.history, [
      ('https://one.example.test', 'Fixture title'),
    ]);
    expect(
      controller.scripts.any((s) => s.contains('window.ethereum')),
      isTrue,
    );
  });

  test(
    'resource errors clear only the failing tab loading indicator',
    () async {
      final first = await tab('https://one.example.test');
      final second = await tab('https://two.example.test');
      first.navigation!.started!('https://one.example.test');
      second.navigation!.started!('https://two.example.test');
      await flush();
      first.navigation!.resourceError!(
        const WebResourceError(errorCode: -1, description: 'offline'),
      );
      expect(provider.wInfoList[0]['load'], isFalse);
      expect(provider.wInfoList[1]['load'], isTrue);
    },
  );

  for (final scheme in [
    'javascript:alert(1)',
    'data:text/html,test',
    'file:///local',
    'blob:https://one.example.test/id',
  ]) {
    test('native navigation prevents $scheme', () async {
      final controller = await tab('https://one.example.test');
      expect(
        await controller.navigation!.request!(
          NavigationRequest(url: scheme, isMainFrame: true),
        ),
        NavigationDecision.prevent,
      );
      expect(
        await controller.navigation!.request!(
          const NavigationRequest(
            url: 'https://safe.example.test',
            isMainFrame: true,
          ),
        ),
        NavigationDecision.navigate,
      );
    });
  }

  test(
    'late callbacks from a closed tab cannot update its replacement',
    () async {
      final first = await tab('https://one.example.test');
      await tab('https://two.example.test');
      final callbacks = first.navigation!;
      provider.wListDelete(0);
      await flush();
      callbacks.progress!(99);
      callbacks.urlChanged!(const UrlChange(url: 'https://old.example.test'));
      callbacks.finished!('https://old.example.test');
      await flush();
      expect(provider.wInfoList.single['openUrl'], 'https://two.example.test');
      expect(provider.wInfoList.single['progress'], isNull);
      expect(provider.browserApi.history, isEmpty);
      expect(first.navigation, isNot(same(callbacks)));
    },
  );

  test('deleting the selected last tab selects its predecessor', () async {
    await tab('https://one.example.test');
    await tab('https://two.example.test');
    provider.wListDelete(1);
    await flush();
    expect(provider.wListIndex, 0);
    expect(provider.titleEditingController?.text, 'https://one.example.test');
  });

  test('deleting the only tab creates one usable default tab', () async {
    await tab('https://one.example.test');
    provider.wListDelete(0);
    await flush();
    expect(provider.wvcList, hasLength(1));
    expect(provider.wInfoList, hasLength(1));
    expect(provider.wListIndex, 0);
    expect(platform.controllers.last.loads, hasLength(1));
  });

  test(
    'clear tabs detaches old delegates and opens one default page',
    () async {
      final first = await tab('https://one.example.test');
      final callbacks = first.navigation!;
      await tab('https://two.example.test');
      provider.setShowWList(true);
      provider.cleanWList();
      await flush();
      expect(first.navigation, isNot(same(callbacks)));
      expect(provider.wvcList, hasLength(1));
      expect(provider.wListIndex, 0);
      expect(provider.showWList, isFalse);
    },
  );

  test(
    'address-bar submission normalizes and loads only the selected tab',
    () async {
      final first = await tab('https://one.example.test');
      final second = await tab('https://two.example.test');
      provider.titleEditingController!.text = 'a search term';
      provider.loadRequest();
      expect(first.loads, hasLength(1));
      expect(
        second.loads.last.toString(),
        'https://www.google.com/search?q=a+search+term',
      );
      expect(provider.wInfoList[1]['openUrl'], second.loads.last.toString());
    },
  );

  test(
    'newer title response wins when responses arrive in reverse order',
    () async {
      final controller = await tab('https://one.example.test');
      final old = Completer<String?>();
      controller.title = () => old.future;
      final pending = provider.getTitle();
      controller.title = () async => 'New title';
      await provider.getTitle();
      old.complete('Old title');
      await pending;
      expect(provider.wInfoList.single['title'], 'New title');
    },
  );

  test(
    'title response for a previously selected tab does not rename the current tab',
    () async {
      final first = await tab('https://one.example.test');
      final old = Completer<String?>();
      first.title = () => old.future;
      final pending = provider.getTitle();
      await tab('https://two.example.test');
      old.complete('Old tab title');
      await pending;
      expect(provider.wInfoList[1]['title'], isNull);
    },
  );

  test('newer navigation response wins over a slow earlier query', () async {
    final controller = await tab('https://one.example.test');
    final old = Completer<bool>();
    controller.back = () => old.future;
    final pending = provider.checkCanGo();
    controller.back = () async => true;
    controller.forward = () async => true;
    await provider.checkCanGo();
    old.complete(false);
    await pending;
    expect(provider.canBack, isTrue);
    expect(provider.canForward, isTrue);
  });

  test(
    'bookmark response from another URL does not overwrite the active bookmark',
    () async {
      await tab('https://one.example.test');
      final old = Completer<List<BrowserCollectionModel>>();
      provider.browserApi.select = (url) =>
          url.contains('one.') ? old.future : Future.value([]);
      final pending = provider.getCollectionUrl('https://one.example.test');
      await tab('https://two.example.test');
      await provider.getCollectionUrl('https://two.example.test');
      old.complete([
        BrowserCollectionModel('https://one.example.test', 'Saved', ''),
      ]);
      await pending;
      expect(provider.collect, isFalse);
    },
  );

  test(
    'bookmark deletion uses the selected URL and refreshes the indicator',
    () async {
      await tab('https://one.example.test');
      provider.collect = true;
      await provider.deleteBrowserCollectionUrl();
      await flush();
      expect(provider.browserApi.deleted, ['https://one.example.test']);
      expect(provider.collect, isFalse);
    },
  );

  test('unconnected origin sees no account or coinbase', () async {
    final controller = await tab('https://one.example.test');
    await message(controller, 'eth_accounts');
    expect(response(controller).$1, 7);
    expect(response(controller).$2, isEmpty);
    expect(response(controller).$3, isNull);
    await message(controller, 'eth_coinbase', id: 8);
    expect(response(controller), (8, null, null));
  });

  test(
    'account approval is requested for the originating background tab',
    () async {
      final first = await tab('https://one.example.test');
      final second = await tab('https://two.example.test');
      final origins = <String>[];
      provider.onSigningRequest =
          ({required origin, required method, required details}) async {
            origins.add(origin);
            expect(method, 'eth_requestAccounts');
            expect(details, {'address': address, 'chainId': '0x1'});
            return true;
          };
      await message(first, 'eth_requestAccounts');
      expect(origins, ['https://one.example.test']);
      expect(response(first).$1, 7);
      expect(response(first).$2, [address]);
      expect(response(first).$3, isNull);
      expect(second.scripts, isEmpty);
      await message(first, 'eth_accounts');
      expect(response(first).$2, [address]);
      await message(second, 'eth_accounts');
      expect(response(second).$2, isEmpty);
      await message(first, 'eth_requestAccounts');
      expect(origins, hasLength(1));
    },
  );

  for (final hasApproval in [false, true]) {
    test(
      'account request rejects when approval is ${hasApproval ? 'denied' : 'unwired'}',
      () async {
        final controller = await tab('https://one.example.test');
        if (hasApproval) {
          provider.onSigningRequest =
              ({required origin, required method, required details}) async =>
                  false;
        }
        await message(controller, 'eth_requestAccounts');
        expect(response(controller).$3['code'], 4001);
        await message(controller, 'eth_accounts');
        expect(response(controller).$2, isEmpty);
      },
    );
  }

  test(
    'no-wallet request returns a correlated error without prompting',
    () async {
      wallet.coinModels = [];
      final controller = await tab('https://one.example.test');
      await message(controller, 'eth_requestAccounts', id: 99);
      expect(response(controller).$1, 99);
      expect(response(controller).$3['code'], -32603);
    },
  );

  test(
    'unsupported provider method returns its normalized JSON-RPC error',
    () async {
      final controller = await tab('https://one.example.test');
      await message(controller, 'unknown_method');
      expect(response(controller).$3['code'], -32601);
    },
  );

  test('different ports do not share account authorization', () async {
    final first = await tab('https://one.example.test:8443');
    final second = await tab('https://one.example.test:9443');
    provider.onSigningRequest =
        ({required origin, required method, required details}) async => true;
    await message(first, 'eth_requestAccounts');
    await message(second, 'eth_accounts');
    expect(response(second).$2, isEmpty);
  });

  test(
    'approval completing after cross-origin navigation cannot expose the account to the new page',
    () async {
      final controller = await tab('https://one.example.test');
      final approval = Completer<bool>();
      provider.onSigningRequest =
          ({required origin, required method, required details}) =>
              approval.future;
      await message(controller, 'eth_requestAccounts');
      controller.navigation!.urlChanged!(
        const UrlChange(url: 'https://two.example.test'),
      );
      approval.complete(true);
      await flush();
      expect(
        controller.scripts,
        isEmpty,
        reason: 'Old promise response must not execute in the new document',
      );
      await message(controller, 'eth_accounts', id: 8);
      expect(response(controller).$2, isEmpty);
    },
  );

  test(
    'approval completing after its tab closes does not execute JavaScript',
    () async {
      final first = await tab('https://one.example.test');
      await tab('https://two.example.test');
      final approval = Completer<bool>();
      provider.onSigningRequest =
          ({required origin, required method, required details}) =>
              approval.future;
      await message(first, 'eth_requestAccounts');
      provider.wListDelete(0);
      await flush();
      approval.complete(true);
      await flush();
      expect(first.scripts, isEmpty);
    },
  );

  test(
    'same-origin SPA route update keeps the pending approval valid',
    () async {
      final controller = await tab('https://one.example.test/start');
      final approval = Completer<bool>();
      provider.onSigningRequest =
          ({required origin, required method, required details}) =>
              approval.future;
      await message(controller, 'eth_requestAccounts');
      controller.navigation!.urlChanged!(
        const UrlChange(url: 'https://one.example.test/connected'),
      );
      approval.complete(true);
      await flush();
      expect(response(controller).$2, [address]);
      expect(response(controller).$3, isNull);
    },
  );

  for (final navigation in ['reload', 'away-and-back']) {
    test(
      'pending approval is invalidated by $navigation even when the final URL matches',
      () async {
        final controller = await tab('https://one.example.test');
        final approval = Completer<bool>();
        provider.onSigningRequest =
            ({required origin, required method, required details}) =>
                approval.future;
        await message(controller, 'eth_requestAccounts');
        if (navigation == 'reload') {
          controller.navigation!.started!('https://one.example.test');
          await flush();
          controller.scripts.clear();
        } else {
          controller.navigation!.urlChanged!(
            const UrlChange(url: 'https://two.example.test'),
          );
          controller.navigation!.urlChanged!(
            const UrlChange(url: 'https://one.example.test'),
          );
        }
        approval.complete(true);
        await flush();
        expect(controller.scripts, isEmpty);
        await message(controller, 'eth_accounts');
        expect(response(controller).$2, isEmpty);
      },
    );
  }

  test(
    'a rejected old request cannot deliver an error into the next page',
    () async {
      final controller = await tab('https://one.example.test');
      final approval = Completer<bool>();
      provider.onSigningRequest =
          ({required origin, required method, required details}) =>
              approval.future;
      await message(controller, 'eth_requestAccounts');
      controller.navigation!.urlChanged!(
        const UrlChange(url: 'https://two.example.test'),
      );
      approval.completeError(StateError('approval view closed'));
      await flush();
      expect(controller.scripts, isEmpty);
    },
  );

  test(
    'same-origin paths share approved accounts and include coinbase',
    () async {
      final first = await tab('https://one.example.test/a');
      final second = await tab('https://one.example.test/b');
      provider.onSigningRequest =
          ({required origin, required method, required details}) async => true;
      await message(first, 'eth_requestAccounts');
      await message(second, 'eth_coinbase');
      expect(response(second).$2, address);
    },
  );

  for (final payload in ['not json', '{}', '{"method":"eth_accounts"}']) {
    test(
      'malformed or uncorrelated message $payload produces no callback',
      () async {
        final controller = await tab('https://one.example.test');
        controller.channels['N42Wallet']!.onMessageReceived(
          JavaScriptMessage(message: payload),
        );
        await flush();
        expect(controller.scripts, isEmpty);
      },
    );
  }

  test(
    'provider chain lookup follows replacement wallet models with the same count',
    () async {
      final controller = await tab('https://one.example.test');
      await message(controller, 'eth_chainId');
      expect(response(controller).$2, '0x1');
      wallet.coinModels = [
        CoinModel()
          ..address = address
          ..coin = {
            'coinType': 'ETH',
            'blockchainType': 'Ethereum',
            'chainId': 137,
          },
      ];
      await message(controller, 'eth_chainId');
      expect(response(controller).$2, '0x89');
    },
  );

  test(
    'sensitive request requires approval through the origin-bound handler',
    () async {
      final controller = await tab('https://one.example.test');
      final calls = <(String, String)>[];
      provider.onSigningRequest =
          ({required origin, required method, required details}) async {
            calls.add((origin, method));
            return false;
          };
      await message(controller, 'personal_sign', params: ['0x6869', address]);
      expect(calls, [('https://one.example.test', 'personal_sign')]);
      expect(response(controller).$3['code'], 4001);
    },
  );

  for (final change in ['models', 'index', 'address']) {
    test('pending signature rejects a wallet $change change', () async {
      final controller = await tab('https://one.example.test');
      final approval = Completer<bool>();
      provider.onSigningRequest =
          ({required origin, required method, required details}) =>
              approval.future;
      await message(controller, 'personal_sign', params: ['0x6869', address]);
      if (change == 'index') {
        wallet.walletIndex++;
      } else if (change == 'address') {
        wallet.coinModels.single.address =
            '0x2222222222222222222222222222222222222222';
      } else {
        wallet.coinModels = [
          CoinModel()
            ..address = address
            ..coin = Map.of(wallet.coinModels.single.coin),
        ];
      }
      approval.complete(true);
      await flush();
      expect(response(controller).$3, containsPair('code', 4001));
    });
  }

  for (final change in ['reload', 'navigation', 'closed tab']) {
    test('signature approval after $change never accesses a key', () async {
      final secrets = _Secrets();
      app.globalProviderContainer = ProviderContainer(
        overrides: [walletServiceProvider.overrideWithValue(secrets)],
      );
      addTearDown(app.globalProviderContainer.dispose);
      final controller = await tab('https://one.example.test');
      final approval = Completer<bool>();
      provider.onSigningRequest =
          ({required origin, required method, required details}) =>
              approval.future;
      await message(controller, 'personal_sign', params: ['0x6869', address]);
      if (change == 'closed tab') {
        provider.wListDelete(0);
      } else if (change == 'reload') {
        controller.navigation!.started!('https://one.example.test');
      } else {
        controller.navigation!.urlChanged!(
          const UrlChange(url: 'https://two.example.test'),
        );
      }
      approval.complete(true);
      await flush();
      expect(secrets.reads, 0);
      expect(
        controller.scripts.where((script) => script.contains('._n42Cb(')),
        isEmpty,
      );
    });
  }

  test(
    'connection approval for one wallet does not expose another wallet',
    () async {
      final controller = await tab('https://one.example.test');
      var approvals = 0;
      provider.onSigningRequest =
          ({required origin, required method, required details}) async {
            approvals++;
            return true;
          };
      await message(controller, 'eth_requestAccounts');
      const otherAddress = '0x2222222222222222222222222222222222222222';
      wallet.coinModels = [
        CoinModel()
          ..address = otherAddress
          ..coin = Map.of(wallet.coinModels.single.coin),
      ];
      await message(controller, 'eth_accounts');
      expect(response(controller).$2, isEmpty);
      await message(controller, 'eth_coinbase');
      expect(response(controller).$2, isNull);
      await message(controller, 'eth_requestAccounts');
      expect(response(controller).$2, [otherAddress]);
      expect(approvals, 2);
    },
  );

  test('pending connection approval is rejected when wallet changes', () async {
    final controller = await tab('https://one.example.test');
    final approval = Completer<bool>();
    provider.onSigningRequest =
        ({required origin, required method, required details}) =>
            approval.future;
    await message(controller, 'eth_requestAccounts');
    wallet.coinModels = [
      CoinModel()
        ..address = '0x2222222222222222222222222222222222222222'
        ..coin = Map.of(wallet.coinModels.single.coin),
    ];
    approval.complete(true);
    await flush();
    expect(response(controller).$3, containsPair('code', 4001));
    await message(controller, 'eth_accounts');
    expect(response(controller).$2, isEmpty);
  });

  test('clipboard bridge dispatches a WalletConnect URI once', () async {
    final controller = await tab('https://one.example.test');
    const uri = 'wc:fixture@2?relay-protocol=irn&symKey=fixture';
    final requests = <String>[];
    provider.connectDAPPCallBack = requests.add;
    for (var i = 0; i < 2; i++) {
      controller.channels['FlutterWcClipboard']!.onMessageReceived(
        const JavaScriptMessage(message: uri),
      );
    }
    expect(requests, [uri]);
    expect(controller.loads, hasLength(1));
  });
}
