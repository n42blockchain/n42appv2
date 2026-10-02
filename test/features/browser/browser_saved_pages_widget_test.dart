import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection.dart';
import 'package:n42_wallet/features/browser/pages/browser_collection_list.dart';
import 'package:n42_wallet/features/browser/pages/browser_history_page.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/widget_test_helpers.dart';

// Keep the real API, model mapping, DAO and SQLite schema in the exercised path.
// Only replace the native database/toast boundaries, with a fresh file per test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Database database;
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('browser_saved_pages_');
    await databaseFactory.setDatabasesPath(directory.path);
    database = await AppDatabase().database;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (_) async => true);
  });

  tearDown(() async {
    await database.close();
    await databaseFactory.setDatabasesPath(Directory.systemTemp.path);
    directory.deleteSync(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<void> waitFor(WidgetTester tester, bool Function() ready) async {
    for (var attempt = 0; attempt < 100; attempt++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      });
      // Advance fake frame time too: pop/refresh animations gate their callbacks.
      await tester.pump(const Duration(milliseconds: 16));
      if (ready()) {
        await tester.pumpAndSettle();
        // Fluttertoast keeps its native-toast lifetime timer in Dart as well.
        await tester.pump(const Duration(seconds: 8));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        return;
      }
    }
    final persisted = await tester.runAsync(
      () => database.query('browserCollection'),
    );
    final fields = find
        .byType(TextField)
        .evaluate()
        .map((element) => (element.widget as TextField).controller?.text)
        .toList();
    final texts = find
        .byType(Text)
        .evaluate()
        .map((element) => (element.widget as Text).data)
        .toList();
    fail(
      'The saved-page UI did not reach the expected state. Fields: $fields; text: $texts; bookmarks: $persisted; exception: ${tester.takeException()}',
    );
  }

  Future<void> openPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(wrapForTest(page));
    await tester.pumpAndSettle();
  }

  Future<void> pushPage(
    WidgetTester tester,
    Widget page,
    void Function(Object?) onResult,
  ) async {
    await openPage(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            onResult(
              await Navigator.of(
                context,
              ).push<Object?>(MaterialPageRoute(builder: (_) => page)),
            );
          },
          child: const Text('Open saved page'),
        ),
      ),
    );
    await tester.tap(find.text('Open saved page'));
    await tester.pumpAndSettle();
  }

  Future<void> seedHistory({
    required String url,
    String? title,
    required DateTime time,
  }) async {
    await database.insert('browserHistory', {
      'url': url,
      'title': title,
      'time': '${time.millisecondsSinceEpoch ~/ 1000}',
    });
  }

  testWidgets('empty history can refresh and display newly persisted visits', (
    tester,
  ) async {
    await openPage(tester, const BrowserHistoryPage());
    await waitFor(tester, () => find.byType(EmptyView).evaluate().isNotEmpty);
    await tester.runAsync(
      () => seedHistory(
        url: 'https://fresh.example',
        title: 'Fresh visit',
        time: DateTime.now(),
      ),
    );
    await tester.tap(find.byIcon(Icons.wifi_protected_setup_outlined));
    await waitFor(tester, () => find.text('Fresh visit').evaluate().isNotEmpty);
    expect(find.byType(EmptyView), findsNothing);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('history groups dates and returns the selected fallback URL', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);
    await tester.runAsync(() async {
      await seedHistory(
        url: 'https://today.example',
        title: 'Today visit',
        time: today,
      );
      await seedHistory(
        url: 'https://fallback.example',
        time: today.subtract(const Duration(days: 1)),
      );
    });
    Object? result;
    await pushPage(
      tester,
      const BrowserHistoryPage(),
      (value) => result = value,
    );
    await waitFor(tester, () => find.text('Today visit').evaluate().isNotEmpty);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('https://fallback.example'), findsNWidgets(2));
    expect(find.text('12:00'), findsNWidgets(2));
    await tester.tap(find.text('https://fallback.example').first);
    await tester.pumpAndSettle();
    expect(result, 'https://fallback.example');
    expect(
      await tester.runAsync(() => database.query('browserHistory')),
      hasLength(2),
    );
  });

  testWidgets('swiping a history row deletes only that persisted visit', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await seedHistory(
        url: 'https://keep.example',
        title: 'Keep visit',
        time: DateTime.now(),
      );
      await seedHistory(
        url: 'https://delete.example',
        title: 'Delete visit',
        time: DateTime.now().add(const Duration(seconds: 1)),
      );
    });
    await openPage(tester, const BrowserHistoryPage());
    await waitFor(
      tester,
      () => find.text('Delete visit').evaluate().isNotEmpty,
    );
    await tester.drag(
      find.ancestor(
        of: find.text('Delete visit'),
        matching: find.byType(Dismissible),
      ),
      const Offset(-900, 0),
    );
    await waitFor(tester, () => find.text('Delete visit').evaluate().isEmpty);
    expect(find.text('Keep visit'), findsOneWidget);
    final rows = await tester.runAsync(() => database.query('browserHistory'));
    expect(rows, hasLength(1));
    expect(rows!.single['url'], 'https://keep.example');
  });

  testWidgets('clear history requires confirmation and clears persisted rows', (
    tester,
  ) async {
    await tester.runAsync(
      () => seedHistory(
        url: 'https://clear.example',
        title: 'Clear visit',
        time: DateTime.now(),
      ),
    );
    await openPage(tester, const BrowserHistoryPage());
    await waitFor(tester, () => find.text('Clear visit').evaluate().isNotEmpty);
    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();
    expect(find.text('Clear all browsing history?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Clear visit'), findsOneWidget);
    expect(
      await tester.runAsync(() => database.query('browserHistory')),
      hasLength(1),
    );
    await tester.tap(find.byIcon(Icons.delete_sweep));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await waitFor(tester, () => find.byType(EmptyView).evaluate().isNotEmpty);
    expect(
      await tester.runAsync(() => database.query('browserHistory')),
      isEmpty,
    );
    expect(find.byIcon(Icons.delete_sweep), findsNothing);
  });

  testWidgets(
    'bookmark creation validates fields then persists trimmed inputs',
    (tester) async {
      var returned = false;
      await pushPage(
        tester,
        const BrowserCollection('', ''),
        (_) => returned = true,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('No bookmarks added yet'), findsOneWidget);
      expect(
        await tester.runAsync(() => database.query('browserCollection')),
        isEmpty,
      );
      await tester.enterText(find.byType(TextField).at(0), '  Favorite  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('No bookmarks added yet'), findsNWidgets(2));
      await tester.enterText(
        find.byType(TextField).at(1),
        '  https://favorite.example  ',
      );
      await tester.enterText(find.byType(TextField).at(2), 'Personal note');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await waitFor(
        tester,
        () => find.byType(BrowserCollection).evaluate().isEmpty,
      );
      expect(returned, isTrue);
      final rows = await tester.runAsync(
        () => database.query('browserCollection'),
      );
      expect(rows, hasLength(1));
      expect(rows!.single, containsPair('name', 'Favorite'));
      expect(rows.single, containsPair('url', 'https://favorite.example'));
      expect(rows.single, containsPair('desc', 'Personal note'));
    },
  );

  testWidgets('bookmark selection returns URL without deleting storage', (
    tester,
  ) async {
    await tester.runAsync(
      () => BrowserApi().insertBrowserCollection(
        'Selected bookmark',
        'https://selected.example',
      ),
    );
    Object? result;
    await pushPage(
      tester,
      const BrowserCollectionList(),
      (value) => result = value,
    );
    await waitFor(
      tester,
      () => find.text('Selected bookmark').evaluate().isNotEmpty,
    );
    await tester.tap(find.text('Selected bookmark'));
    await tester.pumpAndSettle();
    expect(result, 'https://selected.example');
    expect(
      await tester.runAsync(() => database.query('browserCollection')),
      hasLength(1),
    );
  });

  testWidgets(
    'bookmark details save edits and deletion updates list and storage',
    (tester) async {
      await tester.runAsync(
        () => BrowserApi().insertBrowserCollection(
          'Original bookmark',
          'https://original.example',
          desc: 'Original note',
        ),
      );
      await openPage(tester, const BrowserCollectionList(type: 1));
      await waitFor(
        tester,
        () => find.text('Original bookmark').evaluate().isNotEmpty,
      );
      await tester.tap(find.text('Original bookmark'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(3));
      await tester.enterText(
        find.byType(TextField).at(0),
        '  Edited bookmark  ',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        '  https://edited.example  ',
      );
      await tester.enterText(find.byType(TextField).at(2), 'Edited note');
      await tester.tap(find.text('Save'));
      await waitFor(
        tester,
        () => find.text('Edited bookmark').evaluate().isNotEmpty,
      );
      expect(find.text('https://edited.example'), findsOneWidget);
      final rows = await tester.runAsync(
        () => database.query('browserCollection'),
      );
      expect(rows!.single, containsPair('name', 'Edited bookmark'));
      expect(rows.single, containsPair('url', 'https://edited.example'));
      expect(rows.single, containsPair('desc', 'Edited note'));
      await tester.tap(find.text('Edited bookmark'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete).last);
      await waitFor(tester, () => find.byType(EmptyView).evaluate().isNotEmpty);
      expect(
        await tester.runAsync(() => database.query('browserCollection')),
        isEmpty,
      );
    },
  );

  testWidgets('bookmark list deletion preserves the other persisted bookmark', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await BrowserApi().insertBrowserCollection(
        'Keep bookmark',
        'https://keep.example',
      );
      await BrowserApi().insertBrowserCollection(
        'Delete bookmark',
        'https://delete.example',
      );
    });
    await openPage(tester, const BrowserCollectionList());
    await waitFor(
      tester,
      () => find.text('Delete bookmark').evaluate().isNotEmpty,
    );
    await tester.tap(find.byIcon(Icons.delete).first);
    await waitFor(
      tester,
      () => find.text('Delete bookmark').evaluate().isEmpty,
    );
    expect(find.text('Keep bookmark'), findsOneWidget);
    final rows = await tester.runAsync(
      () => database.query('browserCollection'),
    );
    expect(rows, hasLength(1));
    expect(rows!.single['name'], 'Keep bookmark');
  });

  testWidgets(
    'bookmark scrolling loads the next page and refresh replaces rows',
    (tester) async {
      await tester.runAsync(() async {
        for (var index = 0; index < 21; index++) {
          await BrowserApi().insertBrowserCollection(
            'Bookmark ${index.toString().padLeft(2, '0')}',
            'https://page.example/$index',
          );
        }
      });
      await openPage(tester, const BrowserCollectionList());
      await waitFor(
        tester,
        () => find.text('Bookmark 20').evaluate().isNotEmpty,
      );
      for (var attempt = 0; attempt < 15; attempt++) {
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        });
        await tester.pumpAndSettle();
        if (find.text('Bookmark 00').evaluate().isNotEmpty) break;
      }
      expect(find.text('Bookmark 00'), findsOneWidget);
      expect(
        await tester.runAsync(() => database.query('browserCollection')),
        hasLength(21),
      );
      // Further scrolls at the short final page must not append duplicates.
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Bookmark 00'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        await database.delete('browserCollection');
        await BrowserApi().insertBrowserCollection(
          'Refreshed bookmark',
          'https://refreshed.example',
        );
      });
      // Move back to the actual leading edge before performing a pull-to-refresh.
      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await waitFor(
        tester,
        () => find.text('Refreshed bookmark').evaluate().isNotEmpty,
      );
      expect(find.text('Bookmark 20'), findsNothing);
      expect(find.text('Bookmark 00'), findsNothing);
    },
  );
}
