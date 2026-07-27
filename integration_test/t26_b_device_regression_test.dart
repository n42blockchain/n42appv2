// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/presentation/pages/settings/quick_replies_page.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/features/home/setting/security/security_setting.dart';
import 'package:n42_wallet/features/home/widgets/nav_select_image.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/pages/manage_chains_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'T26 B1-B4 physical-device dependency regressions',
    (tester) async {
      app.main();
      await _waitForKey(
        tester,
        'home_page',
        timeout: const Duration(seconds: 60),
      );
      await _acceptTermsIfNeeded(tester);
      await tester.runAsync(_waitForWalletOrderStable);
      await tester.pump();
      final startupException = tester.takeException();
      if (startupException != null) {
        debugPrint('T26_SETUP drained startup exception: $startupException');
      }

      final failures = <String>[];
      await _runStep(
        tester,
        'B1 wallet chain reorder',
        () => _verifyWalletChainReorder(tester),
        failures,
      );
      await _runStep(
        tester,
        'B1 quick reply reorder',
        () => _verifyQuickReplyReorder(tester),
        failures,
      );
      await _runStep(
        tester,
        'B2 Face ID',
        () => _verifyFaceIdToggle(tester),
        failures,
      );
      await _runStep(
        tester,
        'B4 scanner',
        () => _verifyScannerReentry(tester),
        failures,
      );
      await _runStep(
        tester,
        'B4 file picker',
        () => _verifyFilePickerOpenCancel(tester),
        failures,
      );

      _expectNoException(tester, 'final T26 B1-B4 state');
      expect(find.byKey(const ValueKey<String>('home_page')), findsOneWidget);
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<void> _runStep(
  WidgetTester tester,
  String name,
  Future<void> Function() body,
  List<String> failures,
) async {
  try {
    await body();
    debugPrint('T26_STEP $name: PASS');
  } catch (error, stack) {
    failures.add('$name: $error');
    debugPrint('T26_STEP $name: FAIL\n$error\n$stack');
    final navigator = AppGlobals.navigatorKey.currentState;
    while (navigator?.canPop() ?? false) {
      navigator!.pop();
      await tester.pump(const Duration(milliseconds: 300));
    }
  }
}

Future<void> _waitForWalletOrderStable() async {
  debugPrint('T26_SETUP waiting for stable wallet chain order');
  var previous = <String>[];
  var stableSamples = 0;
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < const Duration(seconds: 90)) {
    final wallet = app.globalProviderContainer.read(wapBridgeProvider);
    final current = wallet.coinModels
        .map((coin) => coin.config.coinType)
        .toList(growable: false);
    final walletBuildComplete =
        current.length >= 3 && wallet.coinList.length >= current.length;
    if (walletBuildComplete && _sameStrings(current, previous)) {
      stableSamples++;
      if (stableSamples >= 8) {
        debugPrint('T26_SETUP wallet order stable (${current.length} chains)');
        return;
      }
    } else {
      stableSamples = 0;
      previous = current;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  fail('Wallet chain order did not stabilize within 90 seconds.');
}

bool _sameStrings(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Future<void> _verifyWalletChainReorder(WidgetTester tester) async {
  final wallet = app.globalProviderContainer.read(wapBridgeProvider);
  expect(
    wallet.coinModels.length,
    greaterThanOrEqualTo(3),
    reason: 'B1 needs at least three configured wallet chains.',
  );
  final original = wallet.coinModels
      .take(3)
      .map((coin) => coin.config.coinType)
      .toList(growable: false);
  debugPrint('T26_B1 wallet before: ${original.join(' > ')}');

  await _push(tester, const ManageChainsPage());
  await _waitForKey(tester, 'manage_chains_page');
  await _waitForKey(tester, original[0]);
  await _waitForKey(tester, original[2]);
  await _dragItemDownTwo(
    tester,
    itemKey: original[0],
    dragIcon: Icons.drag_handle_rounded,
    thirdItemKey: original[2],
  );
  final after = wallet.coinModels
      .take(3)
      .map((coin) => coin.config.coinType)
      .toList(growable: false);
  debugPrint('T26_B1 wallet after: ${after.join(' > ')}');
  expect(after, <String>[original[1], original[2], original[0]]);

  await _dragItemToTop(
    tester,
    itemKey: original[0],
    dragIcon: Icons.drag_handle_rounded,
    topItemKey: original[1],
  );
  expect(
    wallet.coinModels
        .take(3)
        .map((coin) => coin.config.coinType)
        .toList(growable: false),
    original,
    reason: 'The test must restore the user wallet chain order.',
  );
  await _pop(tester);
}

Future<void> _verifyQuickReplyReorder(WidgetTester tester) async {
  final storage = PreferencesDataSource();
  final original = await storage.getQuickReplies();
  final fixtures = <Map<String, dynamic>>[
    {'id': 't26_a', 'content': 'T26 A', 'order': 0, 'isSystem': false},
    {'id': 't26_b', 'content': 'T26 B', 'order': 1, 'isSystem': false},
    {'id': 't26_c', 'content': 'T26 C', 'order': 2, 'isSystem': false},
  ];

  try {
    await storage.saveQuickReplies(fixtures);
    await _push(tester, QuickRepliesPage(storageDataSource: storage));
    await _waitForKey(tester, 't26_a');
    debugPrint('T26_B1 quick replies before: t26_a > t26_b > t26_c');

    await _dragItemDownTwo(
      tester,
      itemKey: 't26_a',
      dragIcon: Icons.drag_handle,
      thirdItemKey: 't26_c',
    );
    final after = await storage.getQuickReplies();
    final afterIds = after.map((reply) => reply['id'] as String).toList();
    debugPrint('T26_B1 quick replies after: ${afterIds.join(' > ')}');
    expect(afterIds, <String>['t26_b', 't26_c', 't26_a']);

    await _dragItemToTop(
      tester,
      itemKey: 't26_a',
      dragIcon: Icons.drag_handle,
      topItemKey: 't26_b',
    );
    await _pop(tester);
  } finally {
    await storage.saveQuickReplies(original);
  }
}

Future<void> _verifyFaceIdToggle(WidgetTester tester) async {
  debugPrint(
    'T26_B2 Face ID: authenticate on the iPhone when the native prompt appears.',
  );
  await _push(tester, const SecuritySetting());
  await _waitForKey(
    tester,
    'security_face_toggle',
    timeout: const Duration(seconds: 60),
  );
  final toggle = find.byKey(const ValueKey<String>('security_face_toggle'));
  final original = tester.widget<Switch>(toggle).value;
  debugPrint('T26_B2 Face ID original: $original');

  if (original) {
    await tester.tap(toggle);
    await _waitForSwitchValue(tester, toggle, false);
  }

  await tester.tap(toggle);
  await _waitForSwitchValue(
    tester,
    toggle,
    true,
    timeout: const Duration(seconds: 60),
  );
  debugPrint('T26_B2 Face ID native authentication: PASS');

  if (!original) {
    await tester.tap(toggle);
    await _waitForSwitchValue(tester, toggle, false);
  }
  await _pop(tester);
}

Future<void> _verifyScannerReentry(WidgetTester tester) async {
  for (var cycle = 1; cycle <= 3; cycle++) {
    await _push(tester, const ScanPage());
    await _waitForKey(tester, 'scan_page');
    await tester.pump(const Duration(seconds: 2));
    _expectNoException(tester, 'scanner cycle $cycle open');
    debugPrint('T26_B4 scanner cycle $cycle: OPEN');
    await _pop(tester);
    _expectNoException(tester, 'scanner cycle $cycle close');
    debugPrint('T26_B4 scanner cycle $cycle: CLOSED');
  }
}

Future<void> _verifyFilePickerOpenCancel(WidgetTester tester) async {
  debugPrint(
    'T26_B4 file picker: cancel the native picker on the iPhone after it opens.',
  );
  await _push(tester, const Scaffold(body: SafeArea(child: NavSelectImage())));
  await tester.tap(
    find.byKey(const ValueKey<String>('nav_select_image_file_picker')),
  );
  await tester.runAsync(_waitForNativePickerRoundTrip);
  _expectNoException(tester, 'file picker open/cancel');
  await _pop(tester);
  debugPrint('T26_B4 file picker open/cancel: PASS');
}

Future<void> _waitForNativePickerRoundTrip() async {
  final stopwatch = Stopwatch()..start();
  var leftForeground = false;
  while (stopwatch.elapsed < const Duration(seconds: 90)) {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != AppLifecycleState.resumed) {
      leftForeground = true;
    } else if (leftForeground) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  fail('Native file picker did not complete an open/cancel round trip.');
}

Future<void> _dragItemDownTwo(
  WidgetTester tester, {
  required String itemKey,
  required IconData dragIcon,
  required String thirdItemKey,
}) async {
  final source = find.descendant(
    of: find.byKey(ValueKey<String>(itemKey)),
    matching: find.byIcon(dragIcon),
  );
  final destination = find.byKey(ValueKey<String>(thirdItemKey));
  await tester.ensureVisible(destination);
  final delta =
      tester.getCenter(destination) -
      tester.getCenter(source) +
      const Offset(0, 24);
  await tester.timedDrag(source, delta, const Duration(milliseconds: 900));
  await tester.pump(const Duration(seconds: 1));
  _expectNoException(tester, 'drag $itemKey down two rows');
}

Future<void> _dragItemToTop(
  WidgetTester tester, {
  required String itemKey,
  required IconData dragIcon,
  required String topItemKey,
}) async {
  final source = find.descendant(
    of: find.byKey(ValueKey<String>(itemKey)),
    matching: find.byIcon(dragIcon),
  );
  final destination = find.byKey(ValueKey<String>(topItemKey));
  final delta =
      tester.getCenter(destination) -
      tester.getCenter(source) -
      const Offset(0, 24);
  await tester.timedDrag(source, delta, const Duration(milliseconds: 900));
  await tester.pump(const Duration(seconds: 1));
  _expectNoException(tester, 'drag $itemKey back to top');
}

Future<void> _waitForSwitchValue(
  WidgetTester tester,
  Finder finder,
  bool value, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 250));
    if (tester.widget<Switch>(finder).value == value) return;
  }
  fail('Timed out waiting for switch value $value.');
}

Future<void> _push(WidgetTester tester, Widget page) async {
  AppGlobals.navigatorKey.currentState!.push(
    MaterialPageRoute<void>(builder: (_) => page),
  );
  await tester.pump(const Duration(milliseconds: 750));
  _expectNoException(tester, 'open ${page.runtimeType}');
}

Future<void> _pop(WidgetTester tester) async {
  AppGlobals.navigatorKey.currentState!.pop();
  await tester.pump(const Duration(milliseconds: 750));
}

Future<void> _acceptTermsIfNeeded(WidgetTester tester) async {
  final agree = find.byKey(const ValueKey<String>('terms_agree'));
  if (agree.evaluate().isEmpty) return;
  await tester.tap(agree);
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _waitForKey(
  WidgetTester tester,
  String key, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final finder = find.byKey(ValueKey<String>(key));
  final stopwatch = Stopwatch()..start();
  while (finder.evaluate().isEmpty && stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump();
  expect(finder, findsOneWidget);
}

void _expectNoException(WidgetTester tester, String step) {
  expect(tester.takeException(), isNull, reason: 'Flutter error after $step');
}
