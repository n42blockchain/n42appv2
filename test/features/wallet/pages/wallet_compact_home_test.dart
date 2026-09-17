import 'package:flutter/material.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_list_header.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_list_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page_helpers.dart';
import 'package:n42_wallet/features/wallet/widgets/feature_entry_cards.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import '../../../helpers/widget_test_helpers.dart';

CoinModel sampleCoin({String symbol = 'ETH', bool contract = false}) =>
    CoinModel()
      ..coin = {
        'coinType': 'ETH',
        'mKey': 'ETH',
        'miniName': symbol,
        'name': 'Ethereum',
        'blockchainType': 'Ethereum',
        'unit': symbol,
        'decimals': 18,
        'isContract': contract,
      }
      ..balance = BigInt.parse('1250000000000000000')
      ..coinPrice = 2500
      ..value = 3125
      ..percentage = -1.24;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );
    addTearDown(app.globalProviderContainer.dispose);
  });

  testWidgets('measure compact home at standard phone width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Theme(
          data: ThemeAdapter.buildDark(ThemeAdapter.defaultAccent),
          child: RepaintBoundary(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WalletBoard(
                    accountPrice: 3125,
                    priceLastUpdated: DateTime.now(),
                    sendTap: () {},
                    receiveTap: () {},
                  ),
                  FeatureEntryHorizontal(
                    onEnsTap: () {},
                    onSmartAccountTap: () {},
                  ),
                  WalletCoinItem(
                    coinInfo: sampleCoin(),
                    itemKey: 'sample',
                    group: 'test',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final row = tester.getSize(find.byType(WalletCoinItem));
    final board = tester.getSize(find.byType(WalletBoard));
    final features = tester.getSize(find.byType(FeatureEntryHorizontal));
    debugPrint(
      'HOME_GEOMETRY row=${row.height} board=${board.height} features=${features.height}',
    );
    expect(row.height, inInclusiveRange(52, 57));
    expect(row.height / 83.36, inInclusiveRange(0.63, 0.69));
    expect(board.height, lessThan(205));
    expect(features.height, lessThan(70));
    final pinSize = tester.getSize(find.byType(WalletPinIconButton));
    expect(pinSize.width, greaterThanOrEqualTo(44));
    expect(pinSize.height, greaterThanOrEqualTo(44));
    expect(
      tester.getTopLeft(find.text(r'$3,125.00')).dy,
      lessThan(tester.getTopLeft(find.text('1.25 ETH')).dy),
    );
    expect(find.text(r'$2,500'), findsOneWidget);
    expect(find.text('-1.24%'), findsOneWidget);
  });

  testWidgets(
    'loading skeleton matches compact row height and trailing space',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrapForTest(
          Column(
            children: [
              WalletCoinItem(
                coinInfo: sampleCoin(),
                itemKey: 'geometry',
                group: 'test',
              ),
              const WalletSkeletonCoinRow(shimmerColor: Colors.grey),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(WalletSkeletonCoinRow)).height,
        closeTo(tester.getSize(find.byType(WalletCoinItem)).height, 0.1),
      );
    },
  );

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('long values fit 320px with $theme at ${scale}x', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final coin = sampleCoin(symbol: 'VERYLONGWRAPPEDTOKEN', contract: true)
          ..balance = BigInt.parse('987654321012345678901234567890')
          ..value = 987654321.12
          ..coinPrice = 76543.2198
          ..loadError = true;
        await tester.pumpWidget(
          wrapForTest(
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WalletCoinItem(
                    coinInfo: coin,
                    itemKey: 'long',
                    group: 'test',
                  ),
                ),
              ),
            ),
            themeMode: theme,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('VERYLONGWRAPPEDTOKEN'), findsOneWidget);
        expect(find.text(r'$987,654,321.12'), findsOneWidget);
        expect(find.text('-1.24%'), findsOneWidget);
        expect(
          find.byTooltip(S.current.g_wallet_balance_warning),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byType(WalletPinIconButton)).shortestSide,
          greaterThanOrEqualTo(44),
        );
        if (scale > 1) {
          expect(
            tester.getSize(find.byType(WalletCoinItem)).height,
            greaterThan(60),
          );
        }
      });
    }
  }

  testWidgets('pin button toggles the real provider and never opens a route', (
    tester,
  ) async {
    final coin = sampleCoin();
    final wap = WalletActionProvider()
      ..walletInfoLsit.add(WalletInfo())
      ..walletIndex = 0
      ..coinList.add(coin);
    await tester.pumpWidget(
      wrapForTest(
        Consumer(
          builder: (context, ref, _) {
            ref.watch(wapBridgeProvider);
            return WalletCoinItem(
              coinInfo: coin,
              itemKey: 'pin',
              group: 'test',
            );
          },
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => wap)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(S.current.g_wallet_pin_token));
    await tester.pumpAndSettle();
    expect(coin.isPinned, isTrue);
    expect(wap.walletInfo.pinnedCoins, contains('ETH'));
    expect(find.byTooltip(S.current.g_wallet_unpin_token), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(WalletCoinItem))).canPop(),
      isFalse,
    );
    await tester.tap(find.byTooltip(S.current.g_wallet_unpin_token));
    await tester.pumpAndSettle();
    expect(coin.isPinned, isFalse);
    expect(wap.walletInfo.pinnedCoins, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final editable in [false, true]) {
    testWidgets('swipe deletion respects canEdit=$editable', (tester) async {
      final coin = sampleCoin()..coin['canEdit'] = editable;
      final wap = WalletActionProvider()
        ..walletInfoLsit.add(
          WalletInfo()
            ..coinInfo = {
              'ETH': {'mainnets': <String, dynamic>{}},
            },
        )
        ..walletIndex = 0
        ..coinList.add(coin)
        ..coinModels.add(coin);
      await tester.pumpWidget(
        wrapForTest(
          WalletCoinItem(coinInfo: coin, itemKey: 'delete', group: 'test'),
          overrides: [wapBridgeProvider.overrideWith((ref) => wap)],
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(WalletCoinItem), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(wap.coinList.contains(coin), !editable);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'aggregated row omits pin and zero holdings use two fiat decimals',
    (tester) async {
      final coin = sampleCoin()
        ..coin['isAggregated'] = true
        ..balance = BigInt.zero
        ..value = 0
        ..percentage = 0;
      await tester.pumpWidget(
        wrapForTest(
          WalletCoinItem(coinInfo: coin, itemKey: 'aggregate', group: 'test'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WalletPinIconButton), findsNothing);
      expect(find.text(r'$0.00'), findsOneWidget);
      expect(find.text('0 ETH'), findsOneWidget);
      expect(find.text('+0.00%'), findsOneWidget);
    },
  );

  testWidgets(
    'compact actions retain send, receive, swap and both feature entrances',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final tapped = <String>[];
      await tester.pumpWidget(
        wrapForTest(
          Column(
            children: [
              WalletBoard(
                accountPrice: 0,
                sendTap: () => tapped.add('send'),
                receiveTap: () => tapped.add('receive'),
                swapTap: () => tapped.add('swap'),
              ),
              FeatureEntryHorizontal(
                onEnsTap: () => tapped.add('ens'),
                onSmartAccountTap: () => tapped.add('smart_account'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final action in ['send', 'receive', 'swap']) {
        final button = find.byKey(ValueKey('wallet_action_$action'));
        expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
        await tester.tap(button);
      }
      for (final feature in ['ens', 'smart_account']) {
        await tester.tap(find.byKey(ValueKey('wallet_feature_$feature')));
      }
      expect(tapped, ['send', 'receive', 'swap', 'ens', 'smart_account']);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'aggregate and regular holdings share the same column and height',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final regular = sampleCoin();
      final aggregate = sampleCoin(symbol: 'USDT')
        ..coin['isAggregated'] = true
        ..value = 0;
      await tester.pumpWidget(
        wrapForTest(
          Column(
            children: [
              WalletCoinItem(
                coinInfo: regular,
                itemKey: 'regular',
                group: 'test',
              ),
              WalletCoinItem(
                coinInfo: aggregate,
                itemKey: 'aggregate',
                group: 'test',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopRight(find.text(r'$3,125.00')).dx,
        tester.getTopRight(find.text(r'$0.00')).dx,
      );
      final rows = find.byType(WalletCoinItem);
      expect(
        tester.getSize(rows.first).height,
        tester.getSize(rows.last).height,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'background balance syncing has no banner, spinner or list jump',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final wap = WalletActionProvider()
        ..walletInfoLsit.add(WalletInfo())
        ..walletIndex = 0
        ..coinList.add(sampleCoin())
        ..loadBalance = Load.loading;
      final search = TextEditingController();
      final focus = FocusNode();
      final query = ValueNotifier('');
      addTearDown(wap.dispose);
      addTearDown(search.dispose);
      addTearDown(focus.dispose);
      addTearDown(query.dispose);
      Widget surface() => wrapForTest(
        CustomScrollView(
          slivers: [
            WalletCoinListHeader(
              waValue: wap,
              smallAssetsThreshold: 0,
              onAddToken: () {},
              onChangeNetwork: () {},
              onThresholdChanged: (_) {},
              searchController: search,
              searchFocusNode: focus,
              isSearchVisible: false,
              onSearchVisibilityChanged: (_) {},
              onSearchChanged: (_) {},
              onRefresh: () {},
              onMarketTap: () {},
              onPortfolioTap: () {},
            ),
            WalletCoinListSliver(
              waValue: wap,
              smallAssetsThreshold: 0,
              searchQuery: query,
              discoveredTokens: const [],
              onDiscoveryDismiss: () {},
              onDiscoveryAdded: () {},
              onShowAllTap: () {},
              coinItemBuilder: (coin, key, group) =>
                  WalletCoinItem(coinInfo: coin, itemKey: key, group: group),
            ),
          ],
        ),
      );
      await tester.pumpWidget(surface());
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_key_208), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final before = tester.getTopLeft(find.byType(WalletCoinItem)).dy;
      wap.loadBalance = Load.finish;
      await tester.pumpWidget(surface());
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(WalletCoinItem)).dy, before);
      expect(tester.takeException(), isNull);
    },
  );

  Future<void> mountCoinList(
    WidgetTester tester, {
    required WalletActionProvider wallet,
    required ValueNotifier<String> query,
    double threshold = 0,
    VoidCallback? onShowAll,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        CustomScrollView(
          slivers: [
            WalletCoinListSliver(
              waValue: wallet,
              smallAssetsThreshold: threshold,
              searchQuery: query,
              discoveredTokens: const [],
              onDiscoveryDismiss: () {},
              onDiscoveryAdded: () {},
              onShowAllTap: onShowAll ?? () {},
              coinItemBuilder: (coin, key, group) => Text(
                '$key:${coin.coin['miniName']}:$group',
                key: ValueKey(key),
              ),
            ),
          ],
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('coin list search normalizes input and updates in place', (
    tester,
  ) async {
    final wallet = WalletActionProvider()
      ..coinList = [
        sampleCoin(symbol: 'ETH')..coin['name'] = 'Ethereum',
        sampleCoin(symbol: 'USDC')
          ..coin['coinType'] = 'POLYGON'
          ..coin['name'] = 'USD Coin',
      ];
    final query = ValueNotifier('  usd COIN ');
    addTearDown(wallet.dispose);
    addTearDown(query.dispose);
    await mountCoinList(tester, wallet: wallet, query: query, settle: false);

    expect(find.text('c0:USDC:coin_list'), findsOneWidget);
    expect(find.textContaining(':ETH:'), findsNothing);
    query.value = 'polygon';
    await tester.pumpAndSettle();
    expect(find.text('c0:USDC:coin_list'), findsOneWidget);
    query.value = 'missing';
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_market_no_results), findsOneWidget);
  });

  testWidgets('small-asset filter explains hidden holdings and restores all', (
    tester,
  ) async {
    final wallet = WalletActionProvider()
      ..coinList = [sampleCoin()..value = 0.5];
    final query = ValueNotifier('');
    var showAllCalls = 0;
    addTearDown(wallet.dispose);
    addTearDown(query.dispose);
    await mountCoinList(
      tester,
      wallet: wallet,
      query: query,
      threshold: 1,
      onShowAll: () => showAllCalls++,
    );

    expect(find.text(S.current.g_key_coin_list_all_hidden), findsOneWidget);
    final showAll = find.text(S.current.g_key_coin_list_show_all);
    expect(tester.getSize(showAll.hitTestable()).height, greaterThan(0));
    await tester.tap(showAll);
    expect(showAllCalls, 1);
  });

  testWidgets('pinned list inserts one divider without changing item keys', (
    tester,
  ) async {
    final eth = sampleCoin(symbol: 'ETH')..isPinned = true;
    final btc = sampleCoin(symbol: 'BTC')..isPinned = true;
    final sol = sampleCoin(symbol: 'SOL');
    final wallet = WalletActionProvider()..coinList = [eth, btc, sol];
    final query = ValueNotifier('');
    addTearDown(wallet.dispose);
    addTearDown(query.dispose);
    await mountCoinList(tester, wallet: wallet, query: query);

    expect(find.text(S.current.g_key_coin_list_separator), findsOneWidget);
    expect(find.byKey(const ValueKey('c0')), findsOneWidget);
    expect(find.byKey(const ValueKey('c1')), findsOneWidget);
    expect(find.byKey(const ValueKey('c2')), findsOneWidget);
  });

  testWidgets(
    'wallet initialization displays skeleton instead of empty state',
    (tester) async {
      final wallet = WalletActionProvider()..buildwallet = true;
      final query = ValueNotifier('');
      addTearDown(wallet.dispose);
      addTearDown(query.dispose);
      await mountCoinList(tester, wallet: wallet, query: query, settle: false);

      expect(find.byType(WalletCoinListSkeleton), findsOneWidget);
      expect(find.text(S.current.g_market_no_results), findsNothing);
    },
  );
}
