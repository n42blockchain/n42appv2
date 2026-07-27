// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ChangeNotifierProvider 在 Riverpod 3.x 里由 legacy 入口导出——与
// wallet_providers.dart 定义 wapBridgeProvider 的方式保持一致。
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/safe_change_notifier.dart';

/// Pins the rule behind the `WalletPage.initState` fix.
///
/// `WalletActionProvider` is exposed to widgets through a Riverpod
/// `ChangeNotifierProvider` (`wapBridgeProvider`). Riverpod asserts if such a
/// provider notifies while the widget tree is building. `initWallet()` is
/// `async`, but everything before its first `await` — including a `refresh()`
/// (i.e. `notifyListeners()`) — runs synchronously, so calling it straight from
/// `initState` fired:
///
/// > Tried to modify a provider while the widget tree was building.
///
/// (T26 physical-iPhone probe: `WalletPage.initState` → `initWallet` →
/// `refresh` → `Ref.notifyListeners`.)
///
/// The fix moved the call into `addPostFrameCallback`. These tests encode both
/// directions so the pattern can't quietly come back.
class _Counter extends ChangeNotifier with SafeChangeNotifierMixin {
  int value = 0;

  /// Mirrors `initWallet`: async, but mutates + notifies *before* any await.
  /// The await is a microtask rather than a timer so the test leaves no
  /// pending timer for the binding's invariant check.
  Future<void> bumpThenAwait() async {
    value++;
    notifyListeners();
    await Future<void>.value();
  }
}

final _counterProvider = ChangeNotifierProvider<_Counter>((ref) => _Counter());

class _EagerPage extends ConsumerStatefulWidget {
  const _EagerPage();
  @override
  ConsumerState<_EagerPage> createState() => _EagerPageState();
}

class _EagerPageState extends ConsumerState<_EagerPage> {
  @override
  void initState() {
    super.initState();
    // The bug shape: notifies while this element is still mounting.
    ref.read(_counterProvider).bumpThenAwait();
  }

  @override
  Widget build(BuildContext context) =>
      Text('${ref.watch(_counterProvider).value}');
}

class _DeferredPage extends ConsumerStatefulWidget {
  const _DeferredPage();
  @override
  ConsumerState<_DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends ConsumerState<_DeferredPage> {
  @override
  void initState() {
    super.initState();
    // The fix shape: same call, after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(_counterProvider).bumpThenAwait();
    });
  }

  @override
  Widget build(BuildContext context) =>
      Text('${ref.watch(_counterProvider).value}');
}

void main() {
  testWidgets('notifying from initState trips the Riverpod build assertion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Directionality(
          textDirection: TextDirection.ltr,
          child: _EagerPage(),
        )),
      ),
    );

    final error = tester.takeException();
    expect(
      error,
      isNotNull,
      reason: 'notifying a ChangeNotifierProvider during mount must assert; '
          'if this stops throwing, Riverpod relaxed the rule and the '
          'post-frame deferral in WalletPage.initState can be revisited',
    );
    expect(
      error.toString(),
      contains('while the widget tree was building'),
    );
  });

  testWidgets('deferring to addPostFrameCallback is clean and still applies', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Directionality(
          textDirection: TextDirection.ltr,
          child: _DeferredPage(),
        )),
      ),
    );

    expect(tester.takeException(), isNull);

    // The deferred call still runs and its notification still reaches the UI.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('1'), findsOneWidget);
  });
}
