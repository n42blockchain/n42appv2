import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_keystore.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/choose_import_coin.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _ImportStore extends WalletActionProvider {
  int importLookups = 0;

  @override
  String get userUUID => 'synthetic-test-account';

  @override
  Map<String, dynamic> get walletMap {
    importLookups++;
    // The production import extension rejects missing chain configuration
    // before it can call secure storage or rebuild a wallet.
    return {};
  }
}

class _RouteResult {
  int returns = 0;
  bool? value;
}

void main() {
  // Neither value is a usable keystore, password or private key.
  const jsonFixture = '{"testOnly":true,"ciphertext":"synthetic-import"}';
  const passwordFixture = 'synthetic-test-password';
  const nativeChannel = MethodChannel('trustdart');
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late _ImportStore store;
  late List<Map<dynamic, dynamic>> decodeRequests;
  late List<String> toasts;
  late Map<String, dynamic> decoded;
  Completer<Map<String, dynamic>>? decodeGate;
  bool decodeThrows = false;
  String? clipboard;
  Completer<String?>? clipboardGate;

  setUp(() {
    store = _ImportStore();
    decodeRequests = [];
    toasts = [];
    decoded = {
      'privateKey': 'synthetic-not-a-real-key',
      'address': 'synthetic-address',
    };
    decodeGate = null;
    decodeThrows = false;
    clipboard = null;
    clipboardGate = null;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(nativeChannel, (call) async {
      expect(call.method, 'getWalletInfoWithKeyStore');
      decodeRequests.add(Map<dynamic, dynamic>.from(call.arguments as Map));
      if (decodeThrows) throw PlatformException(code: 'invalid-keystore');
      return decodeGate == null ? decoded : await decodeGate!.future;
    });
    messenger.setMockMethodCallHandler(toastChannel, (call) async {
      if (call.method == 'showToast') {
        toasts.add((call.arguments as Map)['msg'] as String);
      }
      return true;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        final text = clipboardGate == null
            ? clipboard
            : await clipboardGate!.future;
        return text == null ? null : {'text': text};
      }
      return null;
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(nativeChannel, null);
    messenger.setMockMethodCallHandler(toastChannel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<_RouteResult> openImport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final result = _RouteResult();
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result.value = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const ImportKeystore()),
              );
              result.returns++;
            },
            child: const Text('Open test import'),
          ),
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open test import'));
    await tester.pumpAndSettle();
    return result;
  }

  Future<void> fill(WidgetTester tester, {String json = jsonFixture}) async {
    await tester.enterText(find.byType(TextField).at(0), json);
    await tester.enterText(find.byType(TextField).at(1), passwordFixture);
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text(S.current.g_key_78));
    await tester.pump();
  }

  Future<void> finishToast(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 8));
  }

  String textAt(WidgetTester tester, int index) => tester
      .widget<TextField>(find.byType(TextField).at(index))
      .controller!
      .text;

  testWidgets('empty or whitespace JSON is rejected before native decoding', (
    tester,
  ) async {
    await openImport(tester);
    await fill(tester, json: '  \n  ');
    await submit(tester);
    expect(decodeRequests, isEmpty);
    expect(store.importLookups, 0);
    expect(toasts, contains(S.current.g_key_ex_keystore_18));
    expect(find.byType(ImportKeystore), findsOneWidget);
    await finishToast(tester);
  });

  testWidgets(
    'decoder error keeps draft and password and restores submission',
    (tester) async {
      await openImport(tester);
      decodeThrows = true;
      await fill(tester, json: '{malformed');
      await submit(tester);
      await tester.pumpAndSettle();
      expect(decodeRequests, hasLength(1));
      expect(store.importLookups, 0);
      expect(textAt(tester, 0), '{malformed');
      expect(textAt(tester, 1), passwordFixture);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      expect(toasts, contains(S.current.g_key_keystore_21));
      await finishToast(tester);
    },
  );

  for (final missing in ['privateKey', 'address']) {
    testWidgets('missing decoded $missing cannot be saved as a wallet', (
      tester,
    ) async {
      await openImport(tester);
      decoded[missing] = '';
      await fill(tester);
      await submit(tester);
      await tester.pumpAndSettle();
      expect(store.importLookups, 0);
      expect(find.byType(ImportKeystore), findsOneWidget);
      expect(textAt(tester, 0), jsonFixture);
      expect(toasts, contains(S.current.g_key_keystore_21));
      await finishToast(tester);
    });
  }

  testWidgets('rejected import preserves draft and permits another attempt', (
    tester,
  ) async {
    final result = await openImport(tester);
    await fill(tester);
    await submit(tester);
    await tester.pumpAndSettle();
    expect(store.importLookups, 1);
    expect(result.returns, 0);
    expect(textAt(tester, 0), jsonFixture);
    expect(textAt(tester, 1), passwordFixture);
    expect(toasts, contains(S.current.g_key_keystore_19));
    await finishToast(tester);
    await submit(tester);
    await tester.pumpAndSettle();
    expect(store.importLookups, 2);
    expect(result.returns, 0);
    expect(find.byType(ImportKeystore), findsOneWidget);
    await finishToast(tester);
  });

  testWidgets(
    'decoder receives trimmed JSON and exact password before import refusal',
    (tester) async {
      final result = await openImport(tester);
      decoded = {
        'privateKey': ' \nsynthetic-not-a-real-key\n ',
        'address': {'legacy': 'synthetic-address'},
        'addressType': 'legacy',
      };
      await fill(tester, json: '  $jsonFixture  ');
      await submit(tester);
      await tester.pumpAndSettle();
      expect(decodeRequests.single['keyStore'], jsonFixture);
      expect(decodeRequests.single['coin'], 'N');
      expect(decodeRequests.single['passphrase'], passwordFixture);
      expect(store.importLookups, 1);
      expect(result.returns, 0);
      expect(toasts, contains(S.current.g_key_keystore_19));
      await finishToast(tester);
    },
  );

  testWidgets('pending native decode disables repeat submission', (
    tester,
  ) async {
    await openImport(tester);
    decodeGate = Completer<Map<String, dynamic>>();
    await fill(tester);
    await submit(tester);
    final button = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.tap(button);
    await tester.pump();
    expect(decodeRequests, hasLength(1));
    expect(store.importLookups, 0);
    decodeGate!.complete(decoded);
    await tester.pumpAndSettle();
    expect(store.importLookups, 1);
    expect(find.byType(ImportKeystore), findsOneWidget);
    await finishToast(tester);
  });

  testWidgets('leaving during native decode prevents late wallet persistence', (
    tester,
  ) async {
    final result = await openImport(tester);
    decodeGate = Completer<Map<String, dynamic>>();
    await fill(tester);
    await submit(tester);
    await tester.pageBack();
    // Avoid settling the still-loading route before its exit animation ends.
    await tester.pumpAndSettle();
    expect(result.value, isNull);
    expect(result.returns, 1);
    decodeGate!.complete(decoded);
    await tester.pumpAndSettle();
    expect(store.importLookups, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'paste replaces only JSON while null clipboard preserves the draft',
    (tester) async {
      await openImport(tester);
      await fill(tester);
      for (final noContent in [null, 'null']) {
        clipboard = noContent;
        await tester.tap(find.text(S.current.g_key_166));
        await tester.pump();
        expect(textAt(tester, 0), jsonFixture);
      }
      clipboard = 'pasted-synthetic-json';
      await tester.tap(find.text(S.current.g_key_166));
      await tester.pump();
      expect(textAt(tester, 0), 'pasted-synthetic-json');
      expect(textAt(tester, 1), passwordFixture);
      expect(decodeRequests, isEmpty);
      expect(store.importLookups, 0);
    },
  );

  testWidgets('late clipboard result after route exit is ignored safely', (
    tester,
  ) async {
    await openImport(tester);
    clipboardGate = Completer<String?>();
    await tester.tap(find.text(S.current.g_key_166));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    clipboardGate!.complete('late-synthetic-json');
    await tester.pumpAndSettle();
    expect(find.byType(ImportKeystore), findsNothing);
    expect(store.importLookups, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling chain selection preserves inputs and original chain', (
    tester,
  ) async {
    await openImport(tester);
    await fill(tester);
    await tester.ensureVisible(find.byIcon(Icons.arrow_forward_ios));
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();
    expect(find.byType(ChooseImportCoin), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(textAt(tester, 0), jsonFixture);
    expect(textAt(tester, 1), passwordFixture);
    await submit(tester);
    await tester.pumpAndSettle();
    expect(decodeRequests.single['coin'], 'N');
    await finishToast(tester);
  });
}
