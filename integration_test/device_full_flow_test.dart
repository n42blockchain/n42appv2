// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/main.dart' as app;

const _chatUsername = String.fromEnvironment('N42_E2E_CHAT_USERNAME');
const _chatPassword = String.fromEnvironment('N42_E2E_CHAT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'DEVICE-01 clicks the safe Wallet, Market, drawer, and Chat flows',
    (tester) async {
      app.main();
      await _waitForKey(
        tester,
        'home_page',
        timeout: const Duration(seconds: 60),
      );
      await _acceptTermsIfNeeded(tester);

      await _exerciseHomeTabs(tester);
      await _exerciseMarket(tester);
      await _exerciseWallet(tester);
      await _exerciseDrawer(tester);
      await _exerciseChat(tester);

      _expectNoException(tester, 'final device state');
      expect(find.byKey(const ValueKey<String>('home_page')), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 8)),
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
  tester.testTextInput.hide();
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

  await _tapKey(tester, 'wallet_assistant');
  await _waitForKey(tester, 'wallet_assistant_page');
  await tester.pageBack();
  await _waitForKey(tester, 'wallet_page');
  _expectNoException(tester, 'close wallet connect');

  await _tapKey(tester, 'wallet_connect');
  await _waitForKey(
    tester,
    'wallet_connect_page',
    timeout: const Duration(seconds: 30),
  );
  await tester.pageBack();
  await _waitForKey(tester, 'wallet_page');

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
  _expectNoException(tester, 'wallet safe actions');
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
    final finder = find.byKey(ValueKey<String>(destination));
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(finder);
    await tester.pump(const Duration(seconds: 1));
    expect(finder, findsNothing, reason: '$destination did not open a page');
    _expectNoException(tester, destination);
    await tester.pageBack();
    await _waitForKey(tester, destination);
  }

  await tester.pageBack();
  await _waitForKey(tester, 'wallet_page');
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
  await _tapKey(tester, key);
  await tester.pump(const Duration(seconds: 1));
  _expectNoException(tester, key);
  await _dismissTopRoute(tester);
  await _waitForKey(tester, 'wallet_page');
}

Future<void> _dismissTopRoute(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  if (!navigator.canPop()) return;
  navigator.pop();
  await tester.pump(const Duration(milliseconds: 750));
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await _waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 150));
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
