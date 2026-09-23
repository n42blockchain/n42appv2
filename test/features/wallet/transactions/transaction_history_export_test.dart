import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_csv.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_query.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_repository.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

class _UserStore extends SPUtil {
  @override
  Future<Map<String, dynamic>?> getUserInfo() async => null;
}

class _User extends CurrentUserNotifier {
  _User() : super(_UserStore()) {
    state = const SharedUserInfo(uuid: 'alice', email: '');
  }
}

class _ExportRepository extends TransactionHistoryRepository {
  final started = Completer<void>();
  final resume = Completer<void>();
  final finished = Completer<void>();
  bool fail = false;
  int exports = 0;
  TransactionHistoryScope? exportedScope;
  TransactionHistoryFilter? exportedFilter;

  @override
  Future<TransactionHistoryPage> load({
    required TransactionHistoryScope scope,
    TransactionHistoryFilter filter = const TransactionHistoryFilter(),
    int offset = 0,
    int limit = 50,
  }) async => TransactionHistoryPage([
    TransationRecordModel()
      ..from1 = scope.address
      ..to1 = 'recipient'
      ..coin = {'coinType': 'ETH', 'unit': 'ETH', 'decimals': 18},
  ], hasMore: false);

  @override
  Future<int> exportCsv({
    required TransactionHistoryScope scope,
    TransactionHistoryFilter filter = const TransactionHistoryFilter(),
    required Future<void> Function(String) writeChunk,
  }) async {
    exports++;
    exportedScope = scope;
    exportedFilter = filter;
    try {
      await writeChunk(TransactionHistoryCsv.header);
      started.complete();
      await resume.future;
      if (fail) throw StateError('export interrupted');
      await writeChunk('"fixture-row"\r\n');
      return 1;
    } finally {
      finished.complete();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const paths = MethodChannel('plugins.flutter.io/path_provider');
  const shares = MethodChannel('dev.fluttercommunity.plus/share');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory directory;
  late _ExportRepository repository;
  late Completer<Map<dynamic, dynamic>> shared;
  var shareFails = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('n42-history-export-test-');
    repository = _ExportRepository();
    shared = Completer<Map<dynamic, dynamic>>();
    shareFails = false;
    messenger.setMockMethodCallHandler(paths, (_) async => directory.path);
    messenger.setMockMethodCallHandler(shares, (call) async {
      expect(call.method, 'share');
      shared.complete(call.arguments as Map<dynamic, dynamic>);
      if (shareFails) throw PlatformException(code: 'share-unavailable');
      return 'dev.fluttercommunity.plus/share/dismissed';
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(paths, null);
    messenger.setMockMethodCallHandler(shares, null);
    directory.deleteSync(recursive: true);
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final coin = CoinModel()
      ..address = '0xalice'
      ..coin = {
        'coinType': 'ETH',
        'blockchainType': 'Ethereum',
        'unit': 'ETH',
        'decimals': 18,
      };
    await tester.pumpWidget(
      wrapForTest(
        TransactionHistoryList(coin, repository: repository),
        overrides: [currentUserProvider.overrideWith((ref) => _User())],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> startExport(WidgetTester tester) async {
    await tester.runAsync(() async {
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.download_outlined),
          )
          .onPressed!();
      await repository.started.future.timeout(const Duration(seconds: 5));
    });
    await tester.pump();
  }

  Future<void> finishExport(
    WidgetTester tester, {
    bool pageRemainsMounted = true,
  }) async {
    await tester.runAsync(() async {
      repository.resume.complete();
      await repository.finished.future.timeout(const Duration(seconds: 5));
    });

    // A busy export renders an indeterminate progress indicator which keeps
    // scheduling frames, so pumpAndSettle cannot be the completion signal.
    // Alternate real I/O time and widget frames until the observable action
    // returns or the page has been left.
    if (pageRemainsMounted) {
      for (var i = 0; i < 500; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
        if (find.byIcon(Icons.download_outlined).evaluate().isNotEmpty) break;
      }
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      await tester.pumpAndSettle();
    } else {
      for (var i = 0; i < 500 && directory.listSync().isNotEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('export shares the selected filter, CSV file and iPad anchor', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, S.current.g_key_t_3));
    await tester.tap(find.widgetWithText(ElevatedButton, S.current.g_key_78));
    await tester.pumpAndSettle();
    await startExport(tester);
    expect(find.byIcon(Icons.download_outlined), findsNothing);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.filter_list),
          )
          .onPressed,
      isNull,
    );
    expect(repository.exports, 1);
    await finishExport(tester);
    final args = (await tester.runAsync(() => shared.future))!;
    final file = File((args['paths'] as List).single as String);
    expect(
      file.readAsBytesSync(),
      utf8.encode('${TransactionHistoryCsv.header}"fixture-row"\r\n'),
    );
    expect(args['mimeTypes'], ['text/csv']);
    expect(args['originWidth'], greaterThan(0));
    expect(args['originHeight'], greaterThan(0));
    expect(repository.exportedScope!.userId, 'alice');
    expect(repository.exportedScope!.address, '0xalice');
    expect(repository.exportedFilter!.status, 2);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'failed export deletes partial file and restores controls for retry',
    (tester) async {
      repository.fail = true;
      await mount(tester);
      await startExport(tester);
      await finishExport(tester);
      expect(directory.listSync(), isEmpty);
      expect(shared.isCompleted, isFalse);
      expect(find.text(S.current.g_history_export_error), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.filter_list),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('leaving history cancels export and removes the partial file', (
    tester,
  ) async {
    await mount(tester);
    await startExport(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await finishExport(tester, pageRemainsMounted: false);
    expect(directory.listSync(), isEmpty);
    expect(shared.isCompleted, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'native share failure surfaces an error and releases busy state',
    (tester) async {
      shareFails = true;
      await mount(tester);
      await startExport(tester);
      await finishExport(tester);
      expect(shared.isCompleted, isTrue);
      expect(find.text(S.current.g_history_export_error), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
