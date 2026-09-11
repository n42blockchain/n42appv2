import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_aggregate_detail_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import '../../../helpers/widget_test_helpers.dart';
import '../../../helpers/aggregate_wallet_fixtures.dart';

void main() {
  late WalletActionProvider wallet;
  late AggregatedCoinModel coin;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );
    wallet = WalletActionProvider()
      ..walletInfoLsit.add(WalletInfo())
      ..walletIndex = 0;
    wallet.coinModels.add(aggregateMainFixture());
    coin = AggregatedCoinModel(
      tokenConfig: AggregatedTokens.usdt,
      balanceReader: (_, _) async => BigInt.from(1230001),
    );
    wallet.coinList.add(coin);
  });
  tearDown(() => app.globalProviderContainer.dispose());
  Future<void> mount(
    WidgetTester tester, {
    bool row = false,
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
            child: row
                ? WalletCoinItem(
                    coinInfo: coin,
                    itemKey: 'aggregate',
                    group: 'test',
                  )
                : WalletAggregateDetailPage(coin: coin),
          ),
        ),
        locale: locale,
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('home aggregate tap opens real detail and returns', (
    tester,
  ) async {
    await mount(tester, row: true);
    await tester.tap(find.byKey(const ValueKey('wallet_coin_open_aggregate')));
    await tester.pumpAndSettle();
    expect(find.byType(WalletAggregateDetailPage), findsOneWidget);
    expect(find.text(S.current.g_key_aa_coming_soon), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(WalletCoinItem), findsOneWidget);
  });
  for (final locale in [const Locale('en'), const Locale('zh', 'TW')]) {
    testWidgets(
      'unknown and cached balances stay distinct on narrow large text $locale',
      (tester) async {
        coin.updateChainBalance(
          'ETH',
          BigInt.parse('9007199254740993000001'),
          wallet.coinModels.single.address.toString(),
        );
        coin.statuses['ETH'] = AggregateBalanceStatus.stale;
        await mount(tester, narrow: true, locale: locale);
        expect(find.text(S.current.g_aggregate_known_balance), findsOneWidget);
        expect(find.text('9007199254740993.000001 USDT'), findsWidgets);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('aggregate_status_ETH')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text(S.current.g_aggregate_cached_balance), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('refresh button runs real provider and updates known subtotal', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('—'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('aggregate_refresh')));
    await tester.pumpAndSettle();
    expect(find.text('1.230001 USDT'), findsWidgets);
    expect(wallet.balanceTotal, 0);
    expect(coin.statusFor('ETH'), AggregateBalanceStatus.ready);
  });
  testWidgets('copy uses the selected chain account', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData')
          copied = (call.arguments as Map)['text'] as String;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await mount(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('aggregate_copy_ETH')),
    );
    await tester.tap(find.byKey(const ValueKey('aggregate_copy_ETH')));
    await tester.pumpAndSettle();
    expect(copied, wallet.coinModels.single.address);
  });
  testWidgets(
    'receive opens existing QR screen with the chain-specific token',
    (tester) async {
      await mount(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('aggregate_receive_ETH')),
      );
      await tester.tap(find.byKey(const ValueKey('aggregate_receive_ETH')));
      await tester.pumpAndSettle();
      final qr = tester.widget<WalletReceiveQr>(find.byType(WalletReceiveQr));
      expect(qr.chainCoinModel, wallet.coinModels.single);
      expect(
        qr.tokenCoinModel!.coin['contract'],
        AggregatedTokens.usdt.chains.first.contract,
      );
      expect(qr.tokenCoinModel!.address, wallet.coinModels.single.address);
      expect(qr.tokenCoinModel!.privateKey, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('removed asset disables actions after provider update', (
    tester,
  ) async {
    await mount(tester);
    wallet.coinList.clear();
    wallet.refresh();
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_aggregate_unavailable), findsOneWidget);
    expect(find.byKey(const ValueKey('aggregate_receive_ETH')), findsNothing);
    expect(find.byKey(const ValueKey('aggregate_refresh')), findsNothing);
  });
  testWidgets('in-flight refresh prevents repeated button requests', (
    tester,
  ) async {
    final pending = Completer<BigInt>();
    var calls = 0;
    coin = AggregatedCoinModel(
      tokenConfig: AggregatedTokens.usdt,
      balanceReader: (_, _) {
        calls++;
        return pending.future;
      },
    );
    wallet.coinList = [coin];
    await mount(tester);
    await tester.tap(find.byKey(const ValueKey('aggregate_refresh')));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('aggregate_refresh')))
          .onPressed,
      isNull,
    );
    expect(calls, 1);
    pending.complete(BigInt.zero);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('aggregate_refresh')))
          .onPressed,
      isNotNull,
    );
  });
  testWidgets('legacy aggregate marker gets an explicit unavailable page', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletAggregateDetailPage(
          coin: CoinModel()..coin = {'miniName': 'USDT', 'isAggregated': true},
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_aggregate_unavailable), findsOneWidget);
  });
  testWidgets(
    'network switch immediately hides the previous network subtotal and receive action',
    (tester) async {
      coin.updateChainBalance(
        'ETH',
        BigInt.from(2000000),
        wallet.coinModels.single.address.toString(),
      );
      await mount(tester);
      expect(find.text('2 USDT'), findsWidgets);
      wallet.coinModels.single.isTest = true;
      wallet.refresh();
      await tester.pumpAndSettle();
      expect(find.text('2 USDT'), findsNothing);
      expect(find.byKey(const ValueKey('aggregate_receive_ETH')), findsNothing);
    },
  );
  testWidgets(
    'ordinary stablecoin also has an operational network detail projection',
    (tester) async {
      final source = aggregateSourceFixture()..value = 55;
      wallet.coinList = [source];
      wallet.setBalanceTotal(55);
      await tester.pumpWidget(
        wrapForTest(
          WalletAggregateDetailPage(coin: source),
          overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WalletAggregateDetailPage), findsOneWidget);
      expect(
        find.byKey(const ValueKey('aggregate_receive_ETH')),
        findsOneWidget,
      );
      expect(find.text(S.current.g_aggregate_unavailable), findsNothing);
      expect(wallet.balanceTotal, 55);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'home unknown aggregate is a dash, while confirmed zero is zero',
    (tester) async {
      coin.loadError = true;
      await mount(tester, row: true);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('— USDT'), findsOneWidget);
      expect(find.text(r'$0.00'), findsNothing);
      expect(
        find.byTooltip(S.current.g_wallet_balance_warning),
        findsOneWidget,
      );
      coin.updateChainBalance(
        'ETH',
        BigInt.zero,
        wallet.coinModels.single.address.toString(),
      );
      // Rebuild the actual row with the newly confirmed balance.
      await tester.pumpWidget(const SizedBox());
      await mount(tester, row: true);
      expect(find.text(r'$0.00'), findsOneWidget);
      expect(find.text('0 USDT'), findsOneWidget);
    },
  );
}
