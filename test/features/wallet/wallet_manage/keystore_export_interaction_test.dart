import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/export_keystore_desc.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/export_keystore_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  // Deliberately not a real keystore or usable key material.
  const syntheticJson =
      '{"testOnly":true,"ciphertext":"synthetic-export-fixture"}';
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late String clipboard;
  late List<String> clipboardWrites;

  setUp(() {
    clipboard = 'existing-test-clipboard';
    clipboardWrites = [];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String;
        clipboardWrites.add(clipboard);
      } else if (call.method == 'Clipboard.getData') {
        return {'text': clipboard};
      }
      return null;
    });
    messenger.setMockMethodCallHandler(toastChannel, (_) async => true);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMethodCallHandler(toastChannel, null);
  });

  Future<void> openExport(WidgetTester tester, {bool showRisk = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => showRisk
                      ? const ExportKeystoreDesc(keystoreJson: syntheticJson)
                      : const ExportKeystorePage(keystoreJson: syntheticJson),
                ),
              ),
              child: const Text('Open test export'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open test export'));
    await tester.pumpAndSettle();
  }

  Future<void> copy(WidgetTester tester) async {
    await tester.tap(find.text(S.current.g_key_119));
    await tester.pump();
  }

  Finder clearButton() =>
      find.textContaining('${S.current.g_key_ex_keystore_12} (');

  testWidgets(
    'risk acknowledgment is required before the secret display route',
    (tester) async {
      await openExport(tester, showRisk: true);
      expect(find.byType(ExportKeystoreDesc), findsOneWidget);
      expect(find.byType(ExportKeystorePage), findsNothing);
      expect(find.text(syntheticJson), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.text(S.current.next));
      await tester.pumpAndSettle();
      expect(find.byType(ExportKeystorePage), findsNothing);
      expect(clipboardWrites, isEmpty);
    },
  );

  testWidgets('acknowledgment can be revoked before proceeding', (
    tester,
  ) async {
    await openExport(tester, showRisk: true);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.text(syntheticJson), findsNothing);
    expect(clipboardWrites, isEmpty);
  });

  testWidgets('canceling the warning never exposes or copies the keystore', (
    tester,
  ) async {
    await openExport(tester, showRisk: true);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Open test export'), findsOneWidget);
    expect(find.byType(ExportKeystorePage), findsNothing);
    expect(find.text(syntheticJson), findsNothing);
    expect(clipboard, 'existing-test-clipboard');
    expect(clipboardWrites, isEmpty);
  });

  testWidgets(
    'acknowledged navigation displays the exact payload without copying',
    (tester) async {
      await openExport(tester, showRisk: true);
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text(S.current.next));
      await tester.pumpAndSettle();
      expect(find.byType(ExportKeystorePage), findsOneWidget);
      expect(find.text(syntheticJson), findsOneWidget);
      expect(clipboardWrites, isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ExportKeystoreDesc), findsOneWidget);
      expect(find.text(syntheticJson), findsNothing);
      expect(clipboard, isEmpty);
    },
  );

  testWidgets('copy preserves exact payload until the 60-second expiry', (
    tester,
  ) async {
    await openExport(tester);
    await copy(tester);
    expect(clipboard, syntheticJson);
    expect(clearButton(), findsOneWidget);
    await tester.pump(const Duration(seconds: 59));
    expect(clipboard, syntheticJson);
    expect(find.text('${S.current.g_key_ex_keystore_12} (1s)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(clipboard, isEmpty);
    expect(clearButton(), findsNothing);
    expect(find.text(S.current.g_key_119), findsOneWidget);
  });

  testWidgets('manual clear erases payload and cancels the old countdown', (
    tester,
  ) async {
    await openExport(tester);
    await copy(tester);
    await tester.tap(clearButton());
    await tester.pump();
    expect(clipboard, isEmpty);
    expect(clipboardWrites, [syntheticJson, '']);
    expect(find.text(S.current.g_key_119), findsOneWidget);
    await tester.pump(const Duration(seconds: 61));
    expect(clipboardWrites, [syntheticJson, '']);
  });

  testWidgets(
    'real route exit clears copied data immediately and stops its timer',
    (tester) async {
      await openExport(tester);
      await copy(tester);
      expect(clipboard, syntheticJson);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Open test export'), findsOneWidget);
      expect(find.byType(ExportKeystorePage), findsNothing);
      expect(clipboard, isEmpty);
      expect(clipboardWrites, [syntheticJson, '']);
      await tester.pump(const Duration(seconds: 61));
      expect(clipboardWrites, [syntheticJson, '']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('clearing then copying again starts a fresh expiry window', (
    tester,
  ) async {
    await openExport(tester);
    await copy(tester);
    await tester.pump(const Duration(seconds: 30));
    await tester.tap(clearButton());
    await tester.pump();
    await copy(tester);
    expect(clipboardWrites, [syntheticJson, '', syntheticJson]);
    await tester.pump(const Duration(seconds: 30));
    expect(
      clipboard,
      syntheticJson,
      reason: 'The old copy deadline must be canceled',
    );
    await tester.pump(const Duration(seconds: 30));
    expect(clipboard, isEmpty);
    expect(clipboardWrites, [syntheticJson, '', syntheticJson, '']);
  });
}
