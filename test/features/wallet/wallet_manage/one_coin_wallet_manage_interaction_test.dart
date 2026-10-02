import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/message_sign/message_sign_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/export_keystore_desc.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/ens_address_display.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

class _Fixture {
  final CoinModel coin;
  final WalletInfo wallet;
  final WalletActionProvider provider = WalletActionProvider();

  _Fixture({
    bool btc = true,
    bool privateKey = false,
    bool watchOnly = false,
    String password = 'synthetic-wallet-password',
    List<int> accounts = const [0, 2],
    int selectedAccount = 2,
  }) : coin = CoinModel()
         ..coin = {
           'coinType': btc ? 'BTC' : 'ETH',
           'blockchainType': btc ? 'Bitcoin' : 'Ethereum',
           'name': btc ? 'Bitcoin' : 'Ethereum',
           'miniName': btc ? 'BTC' : 'ETH',
           'path': <String, dynamic>{
             'legacy': btc ? "m/44'/0'/0'/0/0" : "m/44'/60'/0'/0/0",
             if (btc) 'segwit': "m/84'/0'/0'/0/0",
           },
         }
         ..addrType = 'legacy'
         // BTC does not resolve ENS. Empty EVM address also avoids all networking.
         ..address = btc ? 'synthetic-btc-address' : '',
       wallet = WalletInfo(
         walletName: 'Synthetic wallet',
         walletUuid: 'synthetic-owner',
         timestamp: 'synthetic-wallet-record',
         password: password,
         privateKey: privateKey ? 'not-a-private-key-test-fixture' : null,
       ) {
    wallet.watchOnly = watchOnly;
    wallet.watchAddress = watchOnly ? 'synthetic-watch-address' : '';
    wallet.coinInfo = {
      btc ? 'BTC' : 'ETH': {
        'baseInfo': coin.coin,
        'addrType': 'legacy',
        'pathList': List<int>.of(accounts),
        'pathIndex': selectedAccount,
      },
    };
    provider.walletInfoList.add(wallet);
    provider.walletIndex = 0;
  }

  OneCoinWalletManage get page =>
      OneCoinWalletManage(walletInfo: wallet, model: coin, walletIndex: 0);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const native = MethodChannel('trustdart');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');
  const publicKey = 'synthetic-public-key-fixture-for-display';
  late List<MethodCall> nativeCalls;
  late List<String> clipboard;
  late List<String> notifications;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    nativeCalls = [];
    clipboard = [];
    notifications = [];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(native, (call) async {
      nativeCalls.add(call);
      if (call.method == 'getPublicKey') return publicKey;
      // The fixture contains no usable key material, and the native boundary
      // explicitly refuses every secret-export/signing operation.
      throw PlatformException(code: 'sensitive-operation-forbidden-in-test');
    });
    messenger.setMockMethodCallHandler(toast, (call) async {
      if (call.method == 'showToast') {
        notifications.add((call.arguments as Map)['msg'] as String);
      }
      return true;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
  });

  tearDown(() {
    expect(
      nativeCalls.map((call) => call.method),
      everyElement('getPublicKey'),
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(native, null);
    messenger.setMockMethodCallHandler(toast, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> open(WidgetTester tester, _Fixture fixture) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(fixture.provider.dispose);
    await tester.pumpWidget(
      wrapForTest(
        fixture.page,
        overrides: [wapBridgeProvider.overrideWith((ref) => fixture.provider)],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(finder);
    // Export keeps a busy spinner behind its modal; it never settles until
    // the prompt closes. Advance the modal transition without waiting for it.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  Future<void> finishToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'selected BTC chain, address, derivation account and public key render',
    (tester) async {
      final fixture = _Fixture();
      await open(tester, fixture);
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text(' (BTC)'), findsOneWidget);
      expect(
        tester
            .widget<EnsAddressDisplay>(find.byType(EnsAddressDisplay))
            .address,
        'synthetic-btc-address',
      );
      expect(find.text("(m/44'/0'/0'/0/2)"), findsOneWidget);
      expect(find.text("m/44'/0'/0'/0/0"), findsOneWidget);
      expect(find.text("m/44'/0'/0'/0/2"), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('synthetic-…-display'), findsOneWidget);
      expect(nativeCalls.single.arguments, containsPair('coin', 'BTC'));
      expect(
        nativeCalls.single.arguments,
        containsPair('path', "m/44'/0'/0'/0/2"),
      );
      expect(find.text(S.current.g_key_msgsign_title), findsNothing);
    },
  );

  testWidgets('copying public key copies the complete public fixture', (
    tester,
  ) async {
    await open(tester, _Fixture());
    await tap(tester, find.byIcon(Icons.copy_rounded).last);
    expect(clipboard, [publicKey]);
    await finishToast(tester);
  });

  testWidgets('private-key wallet hides derivation and export actions', (
    tester,
  ) async {
    await open(tester, _Fixture(privateKey: true));
    expect(find.text(S.current.g_key_ex_keystore), findsNothing);
    expect(find.text(S.current.g_key_ex_keystore_19), findsNothing);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
    expect(find.text("m/44'/0'/0'/0/2"), findsNothing);
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.byType(ExportKeystoreDesc), findsNothing);
  });

  testWidgets(
    'watch-only EVM wallet exposes no signing or secret export controls',
    (tester) async {
      await open(tester, _Fixture(btc: false, watchOnly: true));
      expect(find.text(S.current.g_key_msgsign_title), findsNothing);
      expect(find.text(S.current.g_key_ex_keystore), findsNothing);
      expect(find.text(S.current.g_key_ex_keystore_19), findsNothing);
      expect(find.byType(MessageSignPage), findsNothing);
      expect(find.byType(ExportKeystoreDesc), findsNothing);
      expect(clipboard, isEmpty);
      expect(nativeCalls, isEmpty);
    },
  );

  testWidgets(
    'watch-only wallet cannot add or select derived signing accounts',
    (tester) async {
      await open(tester, _Fixture(watchOnly: true));
      expect(find.byIcon(Icons.add_circle_outline), findsNothing);
      expect(find.text("m/44'/0'/0'/0/0"), findsNothing);
      expect(find.byType(ExportKeystoreDesc), findsNothing);
    },
  );

  for (final action in ['sign', 'keystore', 'private key']) {
    testWidgets('a rendered $action control refuses a newly watch-only wallet', (
      tester,
    ) async {
      final fixture = _Fixture(
        btc: action != 'sign',
        privateKey: action == 'sign',
      );
      await open(tester, fixture);
      final label = action == 'sign'
          ? S.current.g_key_msgsign_title
          : action == 'keystore'
          ? S.current.g_key_ex_keystore
          : S.current.g_key_ex_keystore_19;
      expect(find.text(label), findsOneWidget);
      // Model flags can change before a mounted entry receives its next build.
      // Exercise the actual rendered callback, without opening a secret flow.
      fixture.wallet.watchOnly = true;
      await tap(tester, find.text(label));
      expect(find.byType(MessageSignPage), findsNothing);
      expect(find.byType(ExportKeystoreDesc), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(OneCoinWalletManage), findsOneWidget);
      expect(clipboard, isEmpty);
      expect(nativeCalls, hasLength(1));
    });
  }

  testWidgets(
    'supported signing entry navigates to an idle tool without signing',
    (tester) async {
      final fixture = _Fixture(btc: false, privateKey: true);
      await open(tester, fixture);
      await tap(tester, find.text(S.current.g_key_msgsign_title));
      expect(find.byType(MessageSignPage), findsOneWidget);
      final page = tester.widget<MessageSignPage>(find.byType(MessageSignPage));
      expect(page.walletInfo, same(fixture.wallet));
      expect(page.model, same(fixture.coin));
      expect(page.path, "m/44'/60'/0'/0/2");
      expect(clipboard, isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(OneCoinWalletManage), findsOneWidget);
    },
  );

  testWidgets(
    'adding and removing an unselected derivation account updates list',
    (tester) async {
      await open(tester, _Fixture());
      await tap(tester, find.byIcon(Icons.add_circle_outline));
      expect(find.text("m/44'/0'/0'/0/3"), findsOneWidget);
      await tap(tester, find.byIcon(Icons.remove));
      expect(find.text("m/44'/0'/0'/0/3"), findsNothing);
      expect(find.text("m/44'/0'/0'/0/0"), findsOneWidget);
      expect(find.text("m/44'/0'/0'/0/2"), findsOneWidget);
    },
  );

  testWidgets(
    'opening BTC address type chooser and choosing current type is inert',
    (tester) async {
      final fixture = _Fixture();
      await open(tester, fixture);
      await tap(tester, find.text('legacy'));
      expect(find.text('segwit'), findsOneWidget);
      await tap(tester, find.text('legacy').last);
      expect(find.text('segwit'), findsNothing);
      expect(fixture.coin.addrType, 'legacy');
      expect(fixture.coin.address, 'synthetic-btc-address');
    },
  );

  testWidgets(
    'canceling existing-password export prompt never invokes export',
    (tester) async {
      await open(tester, _Fixture());
      await tap(tester, find.text(S.current.g_key_ex_keystore));
      expect(find.text(S.current.g_key_ex_keystore_pwd_title), findsOneWidget);
      await tap(tester, find.text(S.current.g_key_79));
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(ExportKeystoreDesc), findsNothing);
      expect(clipboard, isEmpty);
    },
  );

  testWidgets(
    'wrong existing password refuses keystore export and resets busy UI',
    (tester) async {
      await open(tester, _Fixture());
      await tap(tester, find.text(S.current.g_key_ex_keystore));
      await tester.enterText(find.byType(TextField), 'wrong-test-password');
      await tap(tester, find.text(S.current.g_key_78));
      expect(notifications, contains(S.current.g_key_146));
      expect(find.byType(ExportKeystoreDesc), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(clipboard, isEmpty);
      await finishToast(tester);
    },
  );

  testWidgets('wrong existing password refuses private key copy', (
    tester,
  ) async {
    await open(tester, _Fixture());
    await tap(tester, find.text(S.current.g_key_ex_keystore_19));
    await tester.enterText(find.byType(TextField), 'wrong-test-password');
    await tap(tester, find.text(S.current.g_key_78));
    expect(notifications, contains(S.current.g_key_146));
    expect(clipboard, isEmpty);
    await finishToast(tester);
  });

  testWidgets('new-password export prompt cancels without secret operations', (
    tester,
  ) async {
    await open(tester, _Fixture(password: ''));
    expect(find.text(S.current.g_key_ex_keystore_19), findsNothing);
    await tap(tester, find.text(S.current.g_key_ex_keystore));
    expect(find.byType(TextField), findsNWidgets(2));
    await tap(tester, find.text(S.current.g_key_79));
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(ExportKeystoreDesc), findsNothing);
  });

  testWidgets(
    'empty new-password confirmation refuses export before native calls',
    (tester) async {
      await open(tester, _Fixture(password: ''));
      await tap(tester, find.text(S.current.g_key_ex_keystore));
      await tap(tester, find.text(S.current.g_key_78));
      expect(notifications, contains(S.current.g_key_21));
      expect(find.byType(ExportKeystoreDesc), findsNothing);
      expect(clipboard, isEmpty);
      await finishToast(tester);
    },
  );
}
