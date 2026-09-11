// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/identity/pages/id_hub_sign_page.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_coin_item.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_aggregate_detail_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/generated/l10n.dart';

const _chatUsername = String.fromEnvironment('N42_E2E_CHAT_USERNAME');
const _chatPassword = String.fromEnvironment('N42_E2E_CHAT_PASSWORD');
const _includeChat = bool.fromEnvironment(
  'N42_E2E_INCLUDE_CHAT',
  defaultValue: true,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    _includeChat
        ? 'DEVICE-01 clicks the safe Wallet, Market, drawer, and Chat flows'
        : 'DEVICE-NAV-01 clicks Wallet, Market and drawer (Chat excluded)',
    (tester) async {
      await app.main();
      if (const bool.fromEnvironment('N42_E2E_CHECK_DEEP_LINKS')) {
        // Inject before the first app frame, exercising the actual startup
        // backlog and host router. This is not an OS universal-link claim.
        await _exerciseColdDeepLink(tester);
      }
      await _waitForKey(
        tester,
        'home_page',
        timeout: const Duration(seconds: 60),
      );
      await _acceptTermsIfNeeded(tester);

      if (const bool.fromEnvironment('N42_E2E_CHECK_PROXY')) {
        expect(
          ProxyConfig.authToken.isNotEmpty,
          isTrue,
          reason: 'Provide the local proxy define file for this check',
        );
        final trending = await MarketApi().getTrendingCoins();
        expect(
          trending,
          isNotEmpty,
          reason: 'Authenticated market proxy returned no data',
        );
        debugPrint(
          'DEVICE_PROXY verified trendingCoins=${trending.length} authenticated=true readOnly=true',
        );
      }
      await _exerciseHomeTabs(tester);
      await _exerciseMarket(tester);
      await _exerciseWallet(tester);
      await _exerciseDrawer(tester);
      if (_includeChat) {
        await _exerciseChat(tester);
      } else {
        debugPrint('DEVICE_SCOPE authenticated Chat excluded from this run');
      }

      _expectNoException(tester, 'final device state');
      expect(find.byKey(const ValueKey<String>('home_page')), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<void> _exerciseColdDeepLink(WidgetTester tester) async {
  debugPrint(
    'DEVICE_STEP deep link: cold startup, duplicate, untrusted origin',
  );
  final service = app.globalProviderContainer.read(deepLinkServiceProvider);
  final link = Uri.parse(
    'n42id://bind?sid=00000000-0000-4000-8000-000000000000&hub=https://id.n42.ai',
  );
  service.handleUri(link);
  await _waitFor(
    tester,
    find.byType(IdHubSignPage),
    timeout: const Duration(seconds: 60),
  );
  final page = tester.widget<IdHubSignPage>(find.byType(IdHubSignPage));
  expect(page.sessionId, '00000000-0000-4000-8000-000000000000');
  expect(page.hubUrl, 'https://id.n42.ai');
  expect(page.isLogin, isFalse);
  service.handleUri(link);
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.byType(IdHubSignPage, skipOffstage: false), findsOneWidget);
  await _dismissTopRoute(tester);
  await _waitForKey(tester, 'home_page');
  service.handleUri(
    Uri.parse(
      'n42id://bind?sid=00000000-0000-4000-8000-000000000000&hub=https://untrusted.invalid',
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.byType(IdHubSignPage, skipOffstage: false), findsNothing);
  _expectNoException(tester, 'deep link navigation');
  debugPrint(
    'DEVICE_DEEP_LINK cold=true duplicateBlocked=true untrustedBlocked=true signed=false',
  );
}

Future<void> _acceptTermsIfNeeded(WidgetTester tester) async {
  final agree = find.byKey(const ValueKey<String>('terms_agree'));
  if (agree.evaluate().isEmpty) return;

  debugPrint('DEVICE_STEP terms: accept');
  await tester.tap(agree);
  await tester.pump(const Duration(seconds: 1));
  expect(agree, findsNothing);
  _expectNoException(tester, 'accept terms');
}

Future<void> _exerciseHomeTabs(WidgetTester tester) async {
  debugPrint('DEVICE_STEP home: navigate primary tabs');
  expect(
    find.byKey(const ValueKey<String>('home_content_wallet')),
    findsOneWidget,
  );

  await _tapKey(tester, 'home_tab_mining');
  await _waitForKey(tester, 'home_content_mining');

  if (Platform.isAndroid) {
    await _tapKey(tester, 'home_tab_earn');
    await _waitForKey(tester, 'home_content_earn');
  }

  await _tapKey(tester, 'home_tab_market');
  await _waitForKey(tester, 'home_content_market');
  _expectNoException(tester, 'primary tabs');
}

Future<void> _exerciseMarket(WidgetTester tester) async {
  debugPrint('DEVICE_STEP market: tabs and search input');
  await _tapKey(tester, 'market_tab_search');
  await _waitForKey(tester, 'market_search_input');
  await tester.enterText(
    find.byKey(const ValueKey<String>('market_search_input')),
    'bitcoin',
  );
  await tester.pump(const Duration(seconds: 2));
  expect(find.byKey(const ValueKey<String>('market_page')), findsOneWidget);
  FocusManager.instance.primaryFocus?.unfocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  await tester.pump(const Duration(milliseconds: 300));

  await _tapKey(tester, 'market_tab_watchlist');
  await tester.pump(const Duration(milliseconds: 500));
  await _tapKey(tester, 'market_tab_news');
  await tester.pump(const Duration(milliseconds: 500));
  await _tapKey(tester, 'market_tab_trending');
  await tester.pump(const Duration(milliseconds: 500));
  _expectNoException(tester, 'market tabs and search');

  await _tapKey(tester, 'home_tab_wallet');
  await _waitForKey(tester, 'home_content_wallet');
}

Future<void> _exerciseWallet(WidgetTester tester) async {
  debugPrint('DEVICE_STEP wallet: account, assistant, connect, and actions');

  await _tapAndDismissRoute(tester, 'wallet_select_account');

  debugPrint('DEVICE_STEP wallet: wallet_assistant');
  await _tapKey(tester, 'wallet_assistant');
  await _waitForKey(tester, 'wallet_assistant_page');
  await tester.pageBack();
  await _waitForKey(tester, 'home_content_wallet');
  _expectNoException(tester, 'close wallet connect');

  debugPrint('DEVICE_STEP wallet: wallet_connect');
  await _tapKey(tester, 'wallet_connect');
  await _waitForKey(
    tester,
    'wallet_connect_page',
    timeout: const Duration(seconds: 30),
  );
  await tester.pageBack();
  await _waitForKey(tester, 'home_content_wallet');

  debugPrint('DEVICE_STEP wallet: wallet_qr_menu');
  await _tapKey(tester, 'wallet_qr_menu');
  await _waitForKey(tester, 'wallet_qr_menu_item_1');
  await _tapKey(tester, 'wallet_qr_menu_item_1');
  await tester.pump(const Duration(seconds: 1));
  await _dismissTopRoute(tester);

  await _tapAndDismissRoute(tester, 'wallet_action_send');
  await _tapAndDismissRoute(tester, 'wallet_action_receive');
  if (Platform.isAndroid &&
      find
          .byKey(const ValueKey<String>('wallet_action_swap'))
          .evaluate()
          .isNotEmpty) {
    await _tapAndDismissRoute(tester, 'wallet_action_swap');
  }

  await _tapAndDismissRoute(tester, 'wallet_feature_ens');
  await _tapAndDismissRoute(tester, 'wallet_feature_smart_account');
  debugPrint('DEVICE_STEP wallet: compact token row opens asset details');
  await _waitFor(tester, find.byType(WalletCoinItem).first);
  final firstRow = find.byType(WalletCoinItem).first;
  await tester.ensureVisible(firstRow);
  await tester.pump(const Duration(milliseconds: 500));
  final rowHeight = tester.getSize(firstRow).height;
  expect(rowHeight, greaterThanOrEqualTo(44));
  debugPrint('DEVICE_HOME tokenRowHeight=$rowHeight');
  final rowKey = tester.widget<WalletCoinItem>(firstRow).itemKey;
  await _tapKey(tester, 'wallet_coin_open_$rowKey');
  await _waitFor(tester, find.byType(WalletChainInfo));
  await _dismissTopRoute(tester);
  if (const bool.fromEnvironment('N42_E2E_CHECK_PROXY')) {
    debugPrint('DEVICE_STEP wallet: manual price refresh');
    final wap = app.globalProviderContainer.read(wapBridgeProvider);
    final previous = wap.priceLastUpdated;
    final refreshButton = find
        .byTooltip(S.current.g_key_bridge_refresh)
        .hitTestable();
    await _waitFor(tester, refreshButton);
    await tester.tap(refreshButton);
    await tester.pump();
    final deadline = DateTime.now().add(const Duration(seconds: 40));
    while (wap.load == Load.refresh && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(wap.load, isNot(Load.refresh));
    if (wap.priceRefreshFailed) {
      expect(
        wap.priceLastUpdated,
        previous,
        reason: 'Incomplete or failed quotes must not claim a fresh portfolio',
      );
    } else {
      expect(wap.priceLastUpdated, isNotNull);
      if (previous != null) {
        expect(wap.priceLastUpdated!.isAfter(previous), isTrue);
      }
    }
    expect(find.text(S.current.g_key_208), findsNothing);
    // The list can scroll the balance card out of the sliver viewport.
    // Return to its actual scroll origin before inspecting the status text.
    final walletScroll = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView).hitTestable().first,
    );
    walletScroll.controller!.jumpTo(0);
    await tester.pump(const Duration(milliseconds: 250));
    await _waitForKey(tester, 'wallet_price_status');
    final status = tester.widget<Text>(
      find.byKey(const ValueKey('wallet_price_status')),
    );
    if (wap.priceRefreshFailed) {
      expect(
        status.data,
        wap.hasPartialPrices
            ? S.current.g_wallet_prices_partial
            : previous == null
            ? S.current.g_wallet_prices_unavailable
            : S.current.g_wallet_prices_cached,
      );
    } else {
      expect(status.data, S.current.g_wallet_prices_just_updated);
    }
    debugPrint(
      'DEVICE_HOME manualRefresh complete=${!wap.priceRefreshFailed} '
      'partial=${wap.hasPartialPrices} statusVerified=true banner=false',
    );
  }
  await _exerciseAggregateDetail(tester);
  _expectNoException(tester, 'wallet safe actions');
}

Future<void> _exerciseAggregateDetail(WidgetTester tester) async {
  debugPrint('DEVICE_STEP wallet: stablecoin network balances');
  final stableRow = find
      .byWidgetPredicate(
        (widget) =>
            widget is WalletCoinItem &&
            aggregatedTokenForCoin(widget.coinInfo) != null,
      )
      .first;
  await _waitFor(tester, stableRow);
  await tester.ensureVisible(stableRow);
  await tester.pump(const Duration(milliseconds: 500));
  final row = tester.widget<WalletCoinItem>(stableRow);
  await _tapKey(tester, 'wallet_coin_open_${row.itemKey}');
  final direct = row.coinInfo is AggregatedCoinModel;
  if (!direct) {
    await _waitFor(tester, find.byType(WalletChainInfo));
    await _tapKey(tester, 'asset_network_balances');
  }
  await _waitFor(tester, find.byType(WalletAggregateDetailPage));
  await _waitForKey(tester, 'aggregate_balance_ETH');
  final refresh = find.byKey(const ValueKey('aggregate_refresh'));
  final deadline = DateTime.now().add(const Duration(seconds: 25));
  while (tester.widget<IconButton>(refresh).onPressed == null &&
      DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(tester.widget<IconButton>(refresh).onPressed, isNotNull);
  final total = tester
      .widget<SelectableText>(find.byKey(const ValueKey('aggregate_total')))
      .data!;
  expect(total.contains('NaN'), isFalse);
  if (const bool.fromEnvironment('N42_E2E_CAPTURE_AGGREGATE')) {
    debugPrint('DEVICE_AGGREGATE screenshotReady=true');
    await tester.pump(const Duration(seconds: 12));
  }
  await _tapKey(tester, 'aggregate_receive_ETH');
  await _waitFor(tester, find.byType(WalletReceiveQr));
  final qr = tester.widget<WalletReceiveQr>(find.byType(WalletReceiveQr));
  expect(qr.tokenCoinModel, isNotNull);
  expect(qr.tokenCoinModel!.privateKey, isNull);
  expect(qr.chainCoinModel.isTest, isFalse);
  await _dismissTopRoute(tester);
  await _tapKey(tester, 'aggregate_network_ETH');
  await _waitFor(tester, find.byType(WalletChainInfo).hitTestable());
  await _dismissTopRoute(tester);
  await _dismissTopRoute(tester);
  if (!direct) await _dismissTopRoute(tester);
  debugPrint(
    'DEVICE_AGGREGATE detail=true receive=true network=true readOnly=true',
  );
}

Future<void> _exerciseDrawer(WidgetTester tester) async {
  debugPrint('DEVICE_STEP drawer: open every non-destructive destination');
  await _tapKey(tester, 'wallet_open_drawer');
  await _waitForKey(tester, 'drawer_profile');

  for (final destination in <String>[
    'drawer_profile',
    'drawer_wallet_manage',
    'drawer_address_book',
    'drawer_security',
    'drawer_settings',
    'drawer_loyalty',
    'drawer_airdrop',
    'drawer_browser',
    'drawer_about',
  ]) {
    debugPrint('DEVICE_STEP drawer: $destination');
    final finder = find.byKey(ValueKey<String>(destination));
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(finder);
    await tester.pump(const Duration(seconds: 1));
    expect(finder, findsNothing, reason: '$destination did not open a page');
    _expectNoException(tester, destination);
    if (destination == 'drawer_browser') {
      final closeBrowser = find.image(
        const AssetImage('assets/browser/close.png'),
      );
      expect(closeBrowser, findsOneWidget);
      await tester.tap(closeBrowser);
    } else {
      await tester.pageBack();
    }
    await _waitForKey(tester, destination);
  }

  final closeDrawer = find.descendant(
    of: find.byType(Drawer),
    matching: find.widgetWithIcon(IconButton, Icons.close_rounded),
  );
  expect(closeDrawer, findsOneWidget);
  await tester.tap(closeDrawer);
  await tester.pump(const Duration(milliseconds: 750));
  expect(find.byKey(const ValueKey<String>('drawer_profile')), findsNothing);
  await _waitForKey(tester, 'home_content_wallet');
}

Future<void> _exerciseChat(WidgetTester tester) async {
  debugPrint('DEVICE_STEP chat: login, search, tabs, and add menu');
  await _tapKey(tester, 'home_tab_chat');
  var state = await _waitForAnyKey(tester, const <String>[
    'chat_welcome_page',
    'chat_login_page',
    'chat_main_page',
  ], timeout: const Duration(seconds: 60));

  if (state == 'chat_welcome_page') {
    await _tapKey(tester, 'chat_welcome_login');
    await _waitForKey(tester, 'chat_login_page');
    state = 'chat_login_page';
  }

  if (state == 'chat_login_page') {
    expect(
      _chatUsername,
      isNotEmpty,
      reason: 'Set N42_E2E_CHAT_USERNAME for an unauthenticated device.',
    );
    expect(
      _chatPassword,
      isNotEmpty,
      reason: 'Set N42_E2E_CHAT_PASSWORD for an unauthenticated device.',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('chat_login_username')),
      _chatUsername,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('chat_login_password')),
      _chatPassword,
    );
    await _tapKey(tester, 'chat_login_submit');
    await _waitForKey(
      tester,
      'chat_main_page',
      timeout: const Duration(seconds: 90),
    );
  }

  await _waitForKey(tester, 'chat_content_messages');
  await _tapKey(tester, 'chat_global_search_open');
  await _waitForKey(tester, 'chat_global_search_page');
  await tester.enterText(
    find.byKey(const ValueKey<String>('chat_global_search_input')),
    _chatUsername.isEmpty ? 'test' : _chatUsername,
  );
  await tester.pump(const Duration(seconds: 2));
  _expectNoException(tester, 'chat global search');
  await tester.pageBack();
  await _waitForKey(tester, 'chat_main_page');

  for (final tab in <MapEntry<int, String>>[
    const MapEntry<int, String>(1, 'chat_content_contacts'),
    const MapEntry<int, String>(2, 'chat_content_discover'),
    const MapEntry<int, String>(3, 'chat_content_me'),
    const MapEntry<int, String>(0, 'chat_content_messages'),
  ]) {
    await _tapKey(tester, 'chat_tab_${tab.key}');
    await _waitForKey(tester, tab.value);
    _expectNoException(tester, 'chat tab ${tab.key}');
  }

  await _tapKey(tester, 'chat_add_menu');
  await _waitForKey(tester, 'chat_add_menu_add_friend');
  expect(
    find.byKey(const ValueKey<String>('chat_add_menu_group')),
    findsOneWidget,
  );
  expect(
    find.byKey(const ValueKey<String>('chat_add_menu_scan')),
    findsOneWidget,
  );
  expect(
    find.byKey(const ValueKey<String>('chat_add_menu_payment')),
    findsOneWidget,
  );
  await tester.pageBack();
  await tester.pump(const Duration(milliseconds: 500));

  await _tapKey(tester, 'chat_back_to_wallet');
  await _waitForKey(tester, 'home_page');
}

Future<void> _tapAndDismissRoute(WidgetTester tester, String key) async {
  debugPrint('DEVICE_STEP wallet: $key');
  await _tapKey(tester, key);
  await tester.pump(const Duration(seconds: 1));
  _expectNoException(tester, key);
  await _dismissTopRoute(tester);
  await _waitForKey(tester, 'home_content_wallet');
}

Future<void> _dismissTopRoute(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  expect(navigator.canPop(), isTrue, reason: 'Expected an opened destination');
  navigator.pop();
  await tester.pump(const Duration(milliseconds: 750));
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await _waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 150));
  // A route can expose the previous page before its exit animation stops
  // intercepting taps. Wait for the actual target to receive pointer events.
  await _waitFor(tester, finder.hitTestable());
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _waitForKey(
  WidgetTester tester,
  String key, {
  Duration timeout = const Duration(seconds: 20),
}) => _waitFor(tester, find.byKey(ValueKey<String>(key)), timeout: timeout);

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final stopwatch = Stopwatch()..start();
  while (finder.evaluate().isEmpty && stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump();
  expect(finder, findsOneWidget);
}

Future<String> _waitForAnyKey(
  WidgetTester tester,
  List<String> keys, {
  required Duration timeout,
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    for (final key in keys) {
      if (find.byKey(ValueKey<String>(key)).evaluate().isNotEmpty) return key;
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  fail('Timed out waiting for one of: ${keys.join(', ')}');
}

void _expectNoException(WidgetTester tester, String step) {
  expect(tester.takeException(), isNull, reason: 'Flutter error after $step');
}
