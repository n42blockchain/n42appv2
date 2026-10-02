import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/address_book_api.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/add_address_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const native = MethodChannel('trustdart');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');
  late Directory directory;
  late Database database;
  final validations = <Map<dynamic, dynamic>>[];
  final toasts = <String>[];
  bool isValid = false;
  String? clipboard;
  Completer<bool>? validationGate;
  Completer<Object?>? clipboardGate;
  Object? routeResult;
  bool returned = false;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('add_address_test_');
    await databaseFactory.setDatabasesPath(directory.path);
    database = await AppDatabase().database;
    validations.clear();
    toasts.clear();
    isValid = false;
    clipboard = null;
    validationGate = null;
    clipboardGate = null;
    returned = false;
    routeResult = null;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(native, (call) async {
      expect(call.method, 'validateAddress');
      validations.add(Map<dynamic, dynamic>.from(call.arguments as Map));
      return validationGate == null ? isValid : await validationGate!.future;
    });
    messenger.setMockMethodCallHandler(toast, (call) async {
      if (call.method == 'showToast') {
        toasts.add((call.arguments as Map)['msg'] as String);
      }
      return true;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return clipboardGate == null
            ? (clipboard == null ? null : {'text': clipboard})
            : await clipboardGate!.future;
      }
      return null;
    });
  });

  tearDown(() async {
    await database.close();
    await databaseFactory.setDatabasesPath(Directory.systemTemp.path);
    directory.deleteSync(recursive: true);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(native, null);
    messenger.setMockMethodCallHandler(toast, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Finder field(int index) => find.byType(TextField).at(index);
  String value(WidgetTester tester, int index) =>
      tester.widget<TextField>(field(index)).controller!.text;

  Future<void> open(WidgetTester tester, {String? initialAddress}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              routeResult = await Navigator.of(context).push<Object?>(
                MaterialPageRoute(
                  builder: (_) =>
                      AddAddressPage(initialAddress: initialAddress),
                ),
              );
              returned = true;
            },
            child: const Text('Open new recipient'),
          ),
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => WalletActionProvider()),
        ],
      ),
    );
    await tester.tap(find.text('Open new recipient'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    tester.testTextInput.hide();
    await tester.tap(find.text(S.current.g_key_115));
    await tester.pumpAndSettle();
  }

  Future<void> finishSave(WidgetTester tester) async {
    // SQLite performs real asynchronous IO even with the non-isolate factory.
    for (var attempt = 0; attempt < 100 && !returned; attempt++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      });
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(returned, isTrue);
    expect(routeResult, isTrue);
  }

  Future<void> expectEmpty(WidgetTester tester) async {
    final saved = await tester.runAsync(
      () => AddressBookApi().getAddressBookList(''),
    );
    expect(saved, isEmpty);
  }

  testWidgets(
    'blank address is rejected before native validation or persistence',
    (tester) async {
      await open(tester);
      await tester.enterText(field(0), '   ');
      await tester.enterText(field(1), 'Recipient');
      await save(tester);
      expect(find.text(S.current.g_key_41), findsOneWidget);
      expect(validations, isEmpty);
      expect(returned, isFalse);
      await expectEmpty(tester);
    },
  );

  testWidgets('invalid address retains draft and permits a corrected save', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(field(0), ' bitcoin:synthetic-invalid?amount=9 ');
    await tester.enterText(field(1), 'Draft recipient');
    await save(tester);
    expect(validations.single, {'coin': 'BTC', 'address': 'synthetic-invalid'});
    expect(find.text(S.current.g_key_t_50), findsOneWidget);
    expect(value(tester, 1), 'Draft recipient');
    await expectEmpty(tester);

    isValid = true;
    await tester.enterText(field(0), 'synthetic-corrected');
    await save(tester);
    await finishSave(tester);
    final saved = await tester.runAsync(
      () => AddressBookApi().getAddressBookList('BTC'),
    );
    expect(saved, hasLength(1));
    expect(saved!.single.address, 'synthetic-corrected');
    expect(saved.single.name, 'Draft recipient');
  });

  testWidgets(
    'valid payment URI saves normalized address and trimmed metadata',
    (tester) async {
      isValid = true;
      await open(tester);
      await tester.enterText(
        field(0),
        ' bitcoin:transfer/synthetic-recipient?amount=99 ',
      );
      await tester.enterText(field(1), '  Alice  ');
      await tester.enterText(field(2), '  Personal note  ');
      await save(tester);
      await finishSave(tester);
      expect(validations.single, {
        'coin': 'BTC',
        'address': 'synthetic-recipient',
      });
      final saved = await tester.runAsync(
        () => AddressBookApi().getAddressBookList(''),
      );
      expect(saved, hasLength(1));
      expect(saved!.single.coinName, 'BTC');
      expect(saved.single.address, 'synthetic-recipient');
      expect(saved.single.name, 'Alice');
      expect(saved.single.desc, 'Personal note');
      expect(find.text('Open new recipient'), findsOneWidget);
    },
  );

  testWidgets(
    'initial address prepopulates the form and follows the normal save path',
    (tester) async {
      isValid = true;
      await open(tester, initialAddress: 'bitcoin:synthetic-initial?amount=1');
      expect(value(tester, 0), 'bitcoin:synthetic-initial?amount=1');
      expect(validations, isEmpty);
      await tester.enterText(field(1), 'Initial recipient');
      await save(tester);
      await finishSave(tester);
      final saved = await tester.runAsync(
        () => AddressBookApi().getAddressBookList(''),
      );
      expect(saved!.single.address, 'synthetic-initial');
      expect(saved.single.name, 'Initial recipient');
    },
  );

  testWidgets('missing recipient name shows guidance without inserting a row', (
    tester,
  ) async {
    isValid = true;
    await open(tester, initialAddress: 'synthetic-recipient');
    await tester.enterText(field(1), '   ');
    await save(tester);
    expect(toasts, [S.current.g_key_address_1]);
    expect(returned, isFalse);
    await expectEmpty(tester);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('canceling a filled draft returns without saving', (
    tester,
  ) async {
    await open(tester, initialAddress: 'synthetic-unsaved');
    await tester.enterText(field(1), 'Unsaved recipient');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(returned, isTrue);
    expect(routeResult, isNull);
    expect(validations, isEmpty);
    await expectEmpty(tester);
  });

  testWidgets('paste normalizes the payment URI and preserves metadata', (
    tester,
  ) async {
    clipboard = ' bitcoin:transfer/synthetic-paste?amount=4 ';
    await open(tester);
    await tester.enterText(field(1), 'Pasted recipient');
    await tester.enterText(field(2), 'Draft note');
    await tester.tap(find.text(S.current.g_key_166));
    await tester.pumpAndSettle();
    expect(value(tester, 0), 'synthetic-paste');
    expect(value(tester, 1), 'Pasted recipient');
    expect(value(tester, 2), 'Draft note');
    expect(validations, isEmpty);
    await expectEmpty(tester);
  });

  for (final text in <String?>[null, 'null']) {
    testWidgets('clipboard ${text ?? 'absent'} preserves an existing draft', (
      tester,
    ) async {
      clipboard = text;
      await open(tester, initialAddress: 'synthetic-existing');
      await tester.tap(find.text(S.current.g_key_166));
      await tester.pumpAndSettle();
      expect(value(tester, 0), 'synthetic-existing');
      await expectEmpty(tester);
    });
  }

  testWidgets('late clipboard response is ignored after canceling the page', (
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
    expect(tester.takeException(), isNull);
    expect(validations, isEmpty);
    await expectEmpty(tester);
  });

  testWidgets(
    'late valid result after canceling does not update disposed state or save',
    (tester) async {
      validationGate = Completer<bool>();
      await open(tester, initialAddress: 'synthetic-pending');
      await tester.enterText(field(1), 'Pending recipient');
      await save(tester);
      expect(validations, hasLength(1));
      await tester.pageBack();
      await tester.pumpAndSettle();
      validationGate!.complete(true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(routeResult, isNull);
      await expectEmpty(tester);
    },
  );
}
