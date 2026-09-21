import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/edit_address_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  const native = MethodChannel('trustdart');
  late AddressBookModel record;
  late Map<String, dynamic> original;
  late List<Map<dynamic, dynamic>> validations;
  Completer<bool>? validationGate;
  Completer<Object?>? clipboardGate;
  String? clipboard;
  bool nativeThrows = false;

  setUp(() {
    record = AddressBookModel.fromJson({
      'id': 42,
      'coinName': 'BTC',
      'coinIcon': '',
      'address': 'synthetic-original',
      'name': 'Original recipient',
      'desc': 'Original note',
    });
    original = record.toJson();
    validations = [];
    validationGate = null;
    clipboardGate = null;
    clipboard = null;
    nativeThrows = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(native, (call) async {
          expect(call.method, 'validateAddress');
          validations.add(Map<dynamic, dynamic>.from(call.arguments as Map));
          if (nativeThrows) {
            throw PlatformException(code: 'synthetic-unavailable');
          }
          return validationGate == null ? false : await validationGate!.future;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            return clipboardGate == null
                ? (clipboard == null ? null : {'text': clipboard})
                : await clipboardGate!.future;
          }
          return null;
        });
  });
  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(native, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Finder field(int i) => find.byType(TextField).at(i);
  String value(WidgetTester tester, int i) =>
      tester.widget<TextField>(field(i)).controller!.text;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EditAddressPage(info: record),
                    ),
                  );
                },
                child: const Text('Open recipient'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open recipient'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    tester.testTextInput.hide();
    await tester.tap(find.text(S.current.g_key_115));
    await tester.pumpAndSettle();
  }

  testWidgets('blank address is blocked before native validation', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(field(0), '   ');
    await save(tester);
    expect(find.text(S.current.g_key_41), findsOneWidget);
    expect(validations, isEmpty);
    expect(record.toJson(), original);
  });

  testWidgets('invalid recipient retains draft and allows corrected retry', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(field(0), ' bitcoin:synthetic-one?amount=9 ');
    await tester.enterText(field(1), 'Draft recipient');
    await save(tester);
    expect(validations.single, {'coin': 'BTC', 'address': 'synthetic-one'});
    expect(find.text(S.current.g_key_t_50), findsOneWidget);
    expect(value(tester, 1), 'Draft recipient');
    await tester.enterText(field(0), 'synthetic-two');
    await save(tester);
    expect(validations.last['address'], 'synthetic-two');
    expect(validations, hasLength(2));
    expect(record.toJson(), original);
    expect(find.byType(EditAddressPage), findsOneWidget);
  });

  testWidgets('native validator failure is shown as rejection', (tester) async {
    nativeThrows = true;
    await open(tester);
    await save(tester);
    expect(find.text(S.current.g_key_t_50), findsOneWidget);
    expect(record.toJson(), original);
    expect(tester.takeException(), isNull);
  });

  for (final text in <String?>[null, 'null']) {
    testWidgets(
      'clipboard ${text == null ? 'absent' : 'literal null'} does not erase draft',
      (tester) async {
        clipboard = text;
        await open(tester);
        await tester.tap(find.text(S.current.g_key_166));
        await tester.pumpAndSettle();
        expect(value(tester, 0), 'synthetic-original');
        expect(validations, isEmpty);
        expect(record.toJson(), original);
      },
    );
  }

  testWidgets('paste normalizes payment URI without changing other fields', (
    tester,
  ) async {
    clipboard = ' bitcoin:transfer/synthetic-pasted?amount=99 ';
    await open(tester);
    await tester.tap(find.text(S.current.g_key_166));
    await tester.pumpAndSettle();
    expect(value(tester, 0), 'synthetic-pasted');
    expect(value(tester, 1), 'Original recipient');
    expect(value(tester, 2), 'Original note');
    expect(record.toJson(), original);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Open recipient'), findsOneWidget);
    expect(record.toJson(), original);
  });

  testWidgets('leaving during validation ignores even a late valid result', (
    tester,
  ) async {
    validationGate = Completer<bool>();
    await open(tester);
    await tester.enterText(field(0), 'synthetic-pending');
    await save(tester);
    expect(validations, hasLength(1));
    await tester.pageBack();
    await tester.pumpAndSettle();
    validationGate!.complete(true);
    await tester.pumpAndSettle();
    expect(record.toJson(), original);
    expect(find.text('Open recipient'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late clipboard response after route exit is ignored', (
    tester,
  ) async {
    clipboardGate = Completer<Object?>();
    await open(tester);
    await tester.tap(find.text(S.current.g_key_166));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    clipboardGate!.complete({'text': 'synthetic-late'});
    await tester.pumpAndSettle();
    expect(record.toJson(), original);
    expect(validations, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
