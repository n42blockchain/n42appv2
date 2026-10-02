import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/portfolio_trade.dart';
import 'package:n42_wallet/features/wallet/pages/market/trade_entry_sheet.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _TradeStore implements TradeEntryStore {
  _TradeStore([List<PortfolioTrade>? initialTrades])
    : trades = List.of(initialTrades ?? const []);

  final List<PortfolioTrade> trades;
  final saved = <PortfolioTrade>[];
  final deletedIds = <int>[];
  Completer<void>? saveGate;
  bool failSave = false;
  bool failDelete = false;

  @override
  Future<List<PortfolioTrade>> getTradesForCoin(String coinId) async =>
      trades.where((trade) => trade.coinId == coinId).toList();

  @override
  Future<void> insertTrade(PortfolioTrade trade) async {
    if (saveGate != null) await saveGate!.future;
    if (failSave) throw StateError('save failed');
    saved.add(trade);
    trades.add(
      PortfolioTrade(
        id: 10,
        coinId: trade.coinId,
        symbol: trade.symbol,
        name: trade.name,
        quantity: trade.quantity,
        buyPriceUsd: trade.buyPriceUsd,
        buyTimeMs: trade.buyTimeMs,
      ),
    );
  }

  @override
  Future<void> deleteTrade(int id) async {
    deletedIds.add(id);
    if (failDelete) throw StateError('delete failed');
    trades.removeWhere((trade) => trade.id == id);
  }
}

PortfolioTrade _trade({int id = 5}) => PortfolioTrade(
  id: id,
  coinId: 'bitcoin',
  symbol: 'btc',
  name: 'Bitcoin',
  quantity: 1.25,
  buyPriceUsd: 50000,
  buyTimeMs: DateTime(2026, 1, 2).millisecondsSinceEpoch,
);

void main() {
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<Future<bool?>?> openSheet(
    WidgetTester tester, {
    required _TradeStore store,
    double currentPrice = 2.5,
  }) async {
    await setPhoneSize(tester);
    Future<bool?>? result;
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                result = showTradeEntrySheet(
                  context: context,
                  coinId: 'bitcoin',
                  symbol: 'BTC',
                  name: 'Bitcoin',
                  currentPrice: currentPrice,
                  storeForTesting: store,
                );
              },
              child: const Text('Add buy trade'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Add buy trade'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('invalid quantity is rejected and valid buy is saved', (
    tester,
  ) async {
    final store = _TradeStore();
    final result = await openSheet(tester, store: store);

    final context = tester.element(find.byType(TextFormField).first);
    final strings = S.of(context);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '0');
    await tester.tap(find.text(strings.g_pnl_save));
    await tester.pumpAndSettle();

    expect(find.text('> 0'), findsOneWidget);
    expect(store.saved, isEmpty);

    await tester.enterText(fields.first, '2.75');
    await tester.tap(find.text(strings.g_pnl_save));
    await tester.pumpAndSettle();

    expect(store.saved, hasLength(1));
    expect(store.saved.single.coinId, 'bitcoin');
    expect(store.saved.single.symbol, 'btc');
    expect(store.saved.single.name, 'Bitcoin');
    expect(store.saved.single.quantity, 2.75);
    expect(store.saved.single.buyPriceUsd, 2.5);
    expect(
      tester.widget<TextFormField>(fields.first).controller!.text,
      isEmpty,
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('save failure leaves sheet open and reports failure', (
    tester,
  ) async {
    final store = _TradeStore()..failSave = true;
    await openSheet(tester, store: store);
    final fields = find.byType(TextFormField);
    final saveLabel = S.of(tester.element(fields.first)).g_pnl_save;
    await tester.enterText(fields.first, '1');
    await tester.tap(find.text(saveLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(store.saved, isEmpty);
    expect(find.text(S.current.g_ui_trade_save_failed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('existing trade can be deleted and marks result changed', (
    tester,
  ) async {
    final store = _TradeStore([_trade()]);
    final result = await openSheet(tester, store: store);

    expect(find.textContaining('1.25 ×'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(store.deletedIds, [5]);
    expect(find.textContaining('1.25 ×'), findsNothing);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('delete failure keeps trade and does not mark result changed', (
    tester,
  ) async {
    final store = _TradeStore([_trade()])..failDelete = true;
    final result = await openSheet(tester, store: store);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(store.deletedIds, [5]);
    expect(find.textContaining('1.25 ×'), findsOneWidget);
    expect(find.text(S.current.g_ui_trade_delete_failed), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('close is disabled while a save is pending', (tester) async {
    final store = _TradeStore()..saveGate = Completer<void>();
    await openSheet(tester, store: store);

    final fields = find.byType(TextFormField);
    final saveLabel = S.of(tester.element(fields.first)).g_pnl_save;
    await tester.enterText(fields.first, '1');
    await tester.tap(find.text(saveLabel));
    await tester.pump();

    final closeButton = find.ancestor(
      of: find.byIcon(Icons.close),
      matching: find.byType(IconButton),
    );
    final close = tester.widget<IconButton>(closeButton);
    final saveButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(close.onPressed, isNull);
    expect(saveButton.onPressed, isNull);

    store.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(closeButton).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
