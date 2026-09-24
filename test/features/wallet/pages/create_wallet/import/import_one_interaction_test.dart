import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_one.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../../helpers/widget_test_helpers.dart';

class _ImportStore extends WalletActionProvider {
  @override
  String get userUUID => 'synthetic-import-account';
}

void main() {
  const trustdart = MethodChannel('trustdart');
  const syntheticPhrase = 'synthetic test phrase';

  late _ImportStore store;
  late List<String> validationRequests;
  late List<String> toasts;
  late bool mnemonicIsValid;
  late String? clipboard;
  Completer<bool>? validationGate;

  setUp(() {
    store = _ImportStore();
    validationRequests = [];
    toasts = [];
    mnemonicIsValid = true;
    clipboard = null;
    validationGate = null;

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(trustdart, (call) async {
      expect(call.method, 'checkMnemonic');
      final mnemonic = (call.arguments as Map)['mnemonic'] as String;
      validationRequests.add(mnemonic);
      return validationGate == null
          ? mnemonicIsValid
          : await validationGate!.future;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return clipboard == null ? null : {'text': clipboard};
      }
      return null;
    });
    messenger.setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (call) async {
        if (call.method == 'showToast') {
          toasts.add((call.arguments as Map)['msg'] as String);
        }
        return true;
      },
    );
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(trustdart, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      null,
    );
  });

  Future<void> openImport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const ImportOne()),
            ),
            child: const Text('Open synthetic import'),
          ),
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open synthetic import'));
    await tester.pumpAndSettle();
  }

  Future<void> enterPhrase(WidgetTester tester, String phrase) async {
    await tester.enterText(find.byType(TextField), phrase);
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text(S.current.g_key_11));
    await tester.pump();
  }

  Future<void> finishToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 8));
  }

  String inputText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('manual input normalizes whitespace before import', (
    tester,
  ) async {
    await openImport(tester);
    await enterPhrase(tester, 'Synthetic\tTEST\nphrase');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(validationRequests, [syntheticPhrase]);
    expect(find.byType(CreatePassword), findsOneWidget);
    expect(
      tester.widget<CreatePassword>(find.byType(CreatePassword)).wInfo.mnemonic,
      syntheticPhrase,
    );
  });

  testWidgets('clipboard phrase is normalized before validation and display', (
    tester,
  ) async {
    clipboard = 'Synthetic\tTEST\nphrase';
    await openImport(tester);

    expect(validationRequests, [syntheticPhrase]);
    expect(inputText(tester), syntheticPhrase);
  });

  testWidgets('invalid phrase stays on the import page', (tester) async {
    mnemonicIsValid = false;
    await openImport(tester);
    await enterPhrase(tester, syntheticPhrase);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(validationRequests, [syntheticPhrase]);
    expect(find.byType(ImportOne), findsOneWidget);
    expect(find.byType(CreatePassword), findsNothing);
    expect(find.text(S.current.w_key_12), findsOneWidget);
    expect(toasts, contains(S.current.w_key_12));
    await finishToast(tester);
  });

  testWidgets('duplicate phrase is refused before password setup', (
    tester,
  ) async {
    store.walletInfoLsit.add(
      WalletInfo(
        walletName: 'Synthetic existing wallet',
        mnemonic: syntheticPhrase,
      ),
    );
    await openImport(tester);
    await enterPhrase(tester, syntheticPhrase);
    await submit(tester);
    await tester.pumpAndSettle();

    expect(validationRequests, [syntheticPhrase]);
    expect(store.walletInfoLsit, hasLength(1));
    expect(find.byType(ImportOne), findsOneWidget);
    expect(find.byType(CreatePassword), findsNothing);
    expect(
      find.text(S.current.g_key_214('Synthetic existing wallet')),
      findsOneWidget,
    );
    await finishToast(tester);
  });

  testWidgets('late validation result is ignored after leaving the page', (
    tester,
  ) async {
    await openImport(tester);
    await enterPhrase(tester, syntheticPhrase);
    validationGate = Completer<bool>();
    await submit(tester);
    expect(validationRequests, [syntheticPhrase]);

    Navigator.of(tester.element(find.byType(ImportOne))).pop();
    await tester.pumpAndSettle();
    validationGate!.complete(true);
    await tester.pumpAndSettle();

    expect(find.byType(ImportOne), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
