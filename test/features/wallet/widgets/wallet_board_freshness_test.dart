import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/generated/l10n.dart';
import '../../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    DateTime? updated,
    bool failed = false,
    bool partial = false,
    bool narrow = false,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = Size(narrow ? 320 : 390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(narrow ? 2 : 1)),
            child: SingleChildScrollView(
              child: WalletBoard(
                accountPrice: 25,
                priceLastUpdated: updated,
                priceRefreshFailed: failed,
                hasPartialPrices: partial,
              ),
            ),
          ),
        ),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('no successful quote reports unavailable instead of fresh', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text(S.current.g_wallet_prices_unavailable), findsOneWidget);
    expect(find.text(S.current.g_wallet_prices_just_updated), findsNothing);
  });
  testWidgets(
    'first refresh failure reports unavailable without claiming saved quotes',
    (tester) async {
      await mount(tester, failed: true);
      expect(find.text(S.current.g_wallet_prices_unavailable), findsOneWidget);
      expect(find.text(S.current.g_wallet_prices_cached), findsNothing);
    },
  );
  testWidgets('fresh timestamp explicitly describes prices', (tester) async {
    await mount(tester, updated: DateTime.now());
    expect(find.text(S.current.g_wallet_prices_just_updated), findsOneWidget);
    expect(find.text('Just updated'), findsNothing);
    expect(find.byKey(const ValueKey('wallet_price_status')), findsOneWidget);
    expect(
      tester.widget(find.byKey(const ValueKey('wallet_price_status'))),
      isA<Text>(),
    );
  });
  testWidgets(
    'failed refresh shows cached-price warning even for a recent timestamp',
    (tester) async {
      await mount(tester, updated: DateTime.now(), failed: true);
      expect(find.text(S.current.g_wallet_prices_cached), findsOneWidget);
      expect(find.text(S.current.g_wallet_prices_just_updated), findsNothing);
    },
  );
  testWidgets('age reflects minutes since the successful quote', (
    tester,
  ) async {
    await mount(
      tester,
      updated: DateTime.now().subtract(const Duration(minutes: 5, seconds: 5)),
    );
    expect(find.text(S.current.g_wallet_prices_minutes(5)), findsOneWidget);
  });
  testWidgets('old quotes show hours without resetting their age', (
    tester,
  ) async {
    await mount(
      tester,
      updated: DateTime.now().subtract(const Duration(hours: 3, minutes: 5)),
    );
    expect(find.text(S.current.g_wallet_prices_hours(3)), findsOneWidget);
  });
  for (final locale in [const Locale('en'), const Locale('zh', 'TW')]) {
    testWidgets(
      'warning wraps with fiat value on narrow large-text screen: $locale',
      (tester) async {
        await mount(
          tester,
          updated: DateTime.now(),
          failed: true,
          narrow: true,
          locale: locale,
        );
        expect(find.text(S.current.g_wallet_prices_cached), findsOneWidget);
        expect(
          find.byKey(const ValueKey('wallet_price_status')),
          findsOneWidget,
        );
      },
    );
  }
  testWidgets('age advances without parent rebuild or quote refresh', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 9, 11, 12);
    final updated = now;
    await tester.pumpWidget(
      wrapForTest(WalletPriceStatus(updated: updated, now: () => now)),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_wallet_prices_just_updated), findsOneWidget);
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(find.text(S.current.g_wallet_prices_minutes(1)), findsOneWidget);
    now = updated.add(const Duration(hours: 1));
    await tester.pump(const Duration(minutes: 59));
    expect(find.text(S.current.g_wallet_prices_hours(1)), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'resume immediately corrects age and timestamp replacement resets it',
    (tester) async {
      var now = DateTime.utc(2026, 9, 11, 12);
      final updated = now;
      await tester.pumpWidget(
        wrapForTest(WalletPriceStatus(updated: updated, now: () => now)),
      );
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 7));
      await tester.pump(const Duration(minutes: 7));
      expect(find.text(S.current.g_wallet_prices_just_updated), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text(S.current.g_wallet_prices_minutes(7)), findsOneWidget);
      await tester.pumpWidget(
        wrapForTest(WalletPriceStatus(updated: now, now: () => now)),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_wallet_prices_just_updated), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('hidden status stops ticking and catches up when visible', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 9, 11, 12);
    final updated = now;
    final enabled = ValueNotifier(true);
    addTearDown(enabled.dispose);
    await tester.pumpWidget(
      wrapForTest(
        ValueListenableBuilder<bool>(
          valueListenable: enabled,
          builder: (_, active, child) =>
              TickerMode(enabled: active, child: child!),
          child: WalletPriceStatus(updated: updated, now: () => now),
        ),
      ),
    );
    await tester.pumpAndSettle();
    enabled.value = false;
    await tester.pump();
    now = now.add(const Duration(minutes: 4));
    await tester.pump(const Duration(minutes: 4));
    expect(find.text(S.current.g_wallet_prices_just_updated), findsOneWidget);
    enabled.value = true;
    await tester.pump();
    expect(find.text(S.current.g_wallet_prices_minutes(4)), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  for (final locale in [const Locale('en'), const Locale('zh', 'TW')]) {
    testWidgets('partial prices are distinct from unavailable: $locale', (
      tester,
    ) async {
      await mount(
        tester,
        failed: true,
        partial: true,
        narrow: true,
        locale: locale,
      );
      expect(find.text(S.current.g_wallet_prices_partial), findsOneWidget);
      expect(find.text(S.current.g_wallet_prices_unavailable), findsNothing);
      expect(find.text(S.current.g_wallet_prices_just_updated), findsNothing);
    });
  }
}
