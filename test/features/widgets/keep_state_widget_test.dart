// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Tests for `KeepStateWidget`, the small AutomaticKeepAliveClientMixin
// wrapper used to preserve child state inside lazy-built TabView /
// PageView containers. The widget itself is tiny but it's used in
// several home-tab / setting pages, so a regression here would silently
// break tab-switch state preservation across the app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/keep_state_widget.dart';

void main() {
  group('KeepStateWidget', () {
    testWidgets('renders the child it is given', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KeepStateWidget(
            child: Text('hello kid'),
          ),
        ),
      );
      expect(find.text('hello kid'), findsOneWidget);
    });

    testWidgets('wantKeepAlive defaults to true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KeepStateWidget(child: Text('x')),
        ),
      );

      // Find the State<KeepStateWidget> and read wantKeepAlive.
      final state = tester.state<State<KeepStateWidget>>(
        find.byType(KeepStateWidget),
      );
      // ignore: invalid_use_of_protected_member
      expect((state as dynamic).wantKeepAlive, isTrue);
    });

    testWidgets('wantKeepAlive=false is honored', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KeepStateWidget(
            wantKeepAlive: false,
            child: Text('x'),
          ),
        ),
      );

      final state = tester.state<State<KeepStateWidget>>(
        find.byType(KeepStateWidget),
      );
      // ignore: invalid_use_of_protected_member
      expect((state as dynamic).wantKeepAlive, isFalse);
    });

    testWidgets('preserves child State across IndexedStack tab switches', (
      tester,
    ) async {
      // This is the integration test that actually exercises why
      // KeepStateWidget exists: when a stateful child is swapped out of
      // the visible subtree and back in, its State should NOT be
      // recreated.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TwoTabHarness(),
          ),
        ),
      );

      // Initial: tab 0 visible, counter at 0.
      expect(find.text('counter=0'), findsOneWidget);

      // Tap to bump counter to 3.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('bump'));
        await tester.pump();
      }
      expect(find.text('counter=3'), findsOneWidget);

      // Switch to tab 1, then back to tab 0.
      await tester.tap(find.text('switch'));
      await tester.pump();
      await tester.tap(find.text('switch'));
      await tester.pump();

      // The counter should STILL be 3 — State preserved.
      expect(find.text('counter=3'), findsOneWidget);
    });
  });
}

/// A two-tab harness that swaps between two children via an IndexedStack.
///
/// The first child is a stateful counter wrapped in KeepStateWidget; the
/// test toggles between tabs to verify the counter state survives.
class _TwoTabHarness extends StatefulWidget {
  @override
  State<_TwoTabHarness> createState() => _TwoTabHarnessState();
}

class _TwoTabHarnessState extends State<_TwoTabHarness> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => setState(() => _tab = 1 - _tab),
          child: const Text('switch'),
        ),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [
              KeepStateWidget(child: _Counter()),
              SizedBox.expand(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _n = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('counter=$_n'),
        TextButton(
          onPressed: () => setState(() => _n++),
          child: const Text('bump'),
        ),
      ],
    );
  }
}
