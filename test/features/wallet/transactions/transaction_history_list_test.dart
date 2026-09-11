import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_query.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_repository.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/widget_test_helpers.dart';

class _Repository extends TransactionHistoryRepository {
  final Future<TransactionHistoryPage> Function(
    TransactionHistoryScope,
    TransactionHistoryFilter,
    int,
  )
  response;
  _Repository(this.response);
  @override
  Future<TransactionHistoryPage> load({
    required TransactionHistoryScope scope,
    TransactionHistoryFilter filter = const TransactionHistoryFilter(),
    int offset = 0,
    int limit = 50,
  }) => response(scope, filter, offset);
}

CoinModel coin(String address) => CoinModel()
  ..address = address
  ..coin = {
    'coinType': 'ETH',
    'blockchainType': 'Ethereum',
    'unit': 'ETH',
    'decimals': 18,
  };
TransactionHistoryPage page(String symbol, {bool more = false}) =>
    TransactionHistoryPage([
      TransationRecordModel()
        ..address = 'sender'
        ..from1 = 'sender'
        ..to1 = 'recipient'
        ..coin = {'coinType': 'ETH', 'unit': symbol, 'decimals': 18},
    ], hasMore: more);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets(
    'direction, status, date range and reset reach repository filters',
    (tester) async {
      // Material's range-picker header uses the wide Ahem font in widget tests.
      // A tablet viewport keeps this test focused on filter/date integration.
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final filters = <TransactionHistoryFilter>[];
      final repository = _Repository((scope, filter, offset) async {
        filters.add(filter);
        return const TransactionHistoryPage([], hasMore: false);
      });
      await tester.pumpWidget(
        wrapForTest(
          TransactionHistoryList(coin('sender'), repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> open() async {
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();
      }

      Future<void> apply() async {
        await tester.tap(
          find.widgetWithText(ElevatedButton, S.current.g_key_78),
        );
        await tester.pumpAndSettle();
      }

      for (final (label, direction) in [
        (S.current.g_key_t_4, 'out'),
        (S.current.g_key_t_5, 'in'),
      ]) {
        await open();
        await tester.tap(find.widgetWithText(ChoiceChip, label));
        await apply();
        expect(filters.last.direction, direction);
        expect(find.text(S.current.g_key_tx_no_results), findsOneWidget);
      }
      for (final (label, status) in [
        (S.current.g_key_t_1, 1),
        (S.current.g_key_t_2, 0),
      ]) {
        await open();
        await tester.tap(find.widgetWithText(ChoiceChip, label));
        await apply();
        expect(filters.last.status, status);
        expect(filters.last.direction, 'in');
      }
      await open();
      for (final chip
          in find
              .widgetWithText(ChoiceChip, S.current.g_audit_all)
              .evaluate()
              .toList()) {
        await tester.tap(find.byWidget(chip.widget));
        await tester.pump();
      }
      await apply();
      expect(filters.last.isActive, isFalse);

      await open();
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(DateRangePickerDialog), findsOneWidget);
      final range = DateTimeRange(
        start: DateTime(2026, 1, 2),
        end: DateTime(2026, 1, 4),
      );
      Navigator.of(
        tester.element(find.byType(DateRangePickerDialog)),
      ).pop(range);
      await tester.pumpAndSettle();
      expect(find.text('2026-01-02 → 2026-01-04'), findsOneWidget);
      await apply();
      expect(filters.last.dateFrom, range.start);
      expect(filters.last.dateTo, range.end);
      await open();
      await tester.tap(find.text(S.current.g_history_clear_dates));
      await apply();
      expect(filters.last.dateFrom, isNull);
      expect(filters.last.dateTo, isNull);

      await open();
      await tester.tap(find.widgetWithText(ChoiceChip, S.current.g_key_t_2));
      await tester.tap(find.text(S.current.g_key_reset));
      await apply();
      expect(filters.last.isActive, isFalse);
      expect(find.text(S.current.g_key_132), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('refresh failure after loading preserves a reachable retry', (
    tester,
  ) async {
    var calls = 0;
    final repository = _Repository((scope, filter, offset) async {
      if (++calls == 2) throw StateError('offline');
      return page('RECOVERED');
    });
    await tester.pumpWidget(
      wrapForTest(
        TransactionHistoryList(coin('sender'), repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_audit_activity_error), findsOneWidget);
    expect(find.textContaining('RECOVERED'), findsNothing);
    await tester.tap(find.text(S.current.g_key_retry));
    await tester.pumpAndSettle();
    expect(find.textContaining('RECOVERED'), findsOneWidget);
    expect(calls, 3);
  });

  testWidgets(
    'load failure has retry and pagination remains reachable for a short page',
    (tester) async {
      var calls = 0;
      final offsets = <int>[];
      final repository = _Repository((scope, filter, offset) async {
        offsets.add(offset);
        if (++calls == 1) throw StateError('offline');
        return calls == 2 ? page('FIRST', more: true) : page('SECOND');
      });
      await tester.pumpWidget(
        wrapForTest(
          TransactionHistoryList(coin('sender'), repository: repository),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_audit_activity_error), findsOneWidget);
      await tester.tap(find.text(S.current.g_key_retry));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(S.current.g_audit_load_more),
        250,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.g_audit_load_more));
      await tester.pumpAndSettle();
      expect(offsets, [0, 0, 1]);
      expect(find.textContaining('SECOND'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('changing the filter ignores a late unfiltered response', (
    tester,
  ) async {
    final pending = Completer<TransactionHistoryPage>();
    final repository = _Repository((scope, filter, offset) async {
      if (filter.status == 2) return page('FILTERED');
      return pending.future;
    });
    await tester.pumpWidget(
      wrapForTest(
        TransactionHistoryList(coin('sender'), repository: repository),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text(S.current.g_key_t_3));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(S.current.g_key_t_3));
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, S.current.g_key_78),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(ElevatedButton, S.current.g_key_78));
    await tester.pumpAndSettle();
    expect(find.textContaining('FILTERED'), findsOneWidget);
    pending.complete(page('STALE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('STALE'), findsNothing);
    expect(find.textContaining('FILTERED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('switching the address discards the previous account request', (
    tester,
  ) async {
    final pending = Completer<TransactionHistoryPage>();
    final repository = _Repository(
      (scope, filter, offset) async =>
          scope.address == 'old' ? pending.future : page('NEW'),
    );
    await tester.pumpWidget(
      wrapForTest(TransactionHistoryList(coin('old'), repository: repository)),
    );
    await tester.pump();
    await tester.pumpWidget(
      wrapForTest(TransactionHistoryList(coin('new'), repository: repository)),
    );
    await tester.pumpAndSettle();
    pending.complete(page('OLD'));
    await tester.pumpAndSettle();
    expect(find.textContaining('NEW'), findsOneWidget);
    expect(find.textContaining('OLD'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
