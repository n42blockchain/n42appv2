import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/price_alert_sheet.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openSheet(
    WidgetTester tester, {
    required String coinId,
    required String symbol,
    required String name,
    double currentPrice = 0,
    required ValueChanged<bool?> onResult,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showPriceAlertSheet(
                context: context,
                coinId: coinId,
                symbol: symbol,
                name: name,
                currentPrice: currentPrice,
              );
              onResult(result);
            },
            child: const Text('Open alert'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();
  }

  testWidgets('invalid target price stays open and shows validation', (
    tester,
  ) async {
    bool? result;
    await openSheet(
      tester,
      coinId: 'bitcoin',
      symbol: 'BTC',
      name: 'Bitcoin',
      onResult: (value) => result = value,
    );
    final context = tester.element(find.text('Price Alert · BTC'));

    await tester.tap(find.text(S.of(context).g_alert_set));
    await tester.pumpAndSettle();

    expect(find.text(S.of(context).g_alert_invalid_price), findsOneWidget);
    expect(find.text('Price Alert · BTC'), findsOneWidget);
    expect(result, isNull);
    expect(await CoinPriceAlertService.loadAll(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new alert saves direction, enabled state, and normalized symbol',
    (tester) async {
      bool? result;
      await openSheet(
        tester,
        coinId: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        currentPrice: 123.45,
        onResult: (value) => result = value,
      );
      final context = tester.element(find.text('Price Alert · BTC'));
      final priceField = tester.widget<TextField>(find.byType(TextField));
      expect(priceField.controller!.text, '123.4500');
      expect(
        find.text(S.of(context).g_alert_current_price('123.4500')),
        findsOneWidget,
      );

      await tester.tap(find.text(S.of(context).g_alert_below));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '98.765');
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.of(context).g_alert_set));
      await tester.pumpAndSettle();

      final saved = (await CoinPriceAlertService.loadAll())['bitcoin'];
      expect(result, isTrue);
      expect(saved, isNotNull);
      expect(saved!.symbol, 'btc');
      expect(saved.name, 'Bitcoin');
      expect(saved.targetPrice, 98.765);
      expect(saved.alertAbove, isFalse);
      expect(saved.enabled, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('existing alert loads and remove clears persisted config', (
    tester,
  ) async {
    await CoinPriceAlertService.save(
      const CoinPriceAlertConfig(
        coinId: 'ethereum',
        symbol: 'eth',
        name: 'Ethereum',
        targetPrice: 2500,
        alertAbove: false,
        enabled: false,
        lastNotifiedMs: 123456,
      ),
    );
    bool? result;
    await openSheet(
      tester,
      coinId: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      onResult: (value) => result = value,
    );
    final context = tester.element(find.text('Price Alert · ETH'));
    final priceField = tester.widget<TextField>(find.byType(TextField));

    expect(priceField.controller!.text, '2500.00');
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.text(S.of(context).g_alert_update), findsOneWidget);

    await tester.tap(find.text(S.of(context).g_alert_remove));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(await CoinPriceAlertService.loadAll(), isEmpty);
    expect(tester.takeException(), isNull);
  });
}
