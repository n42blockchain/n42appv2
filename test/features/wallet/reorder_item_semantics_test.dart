// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the index contract of [ReorderableListView.onReorderItem].
///
/// Flutter 3.41 deprecated `onReorder` in favour of `onReorderItem`. The two
/// callbacks hand out **different** `newIndex` values:
///
/// - `onReorder` reports the insertion slot *before* the dragged item is
///   removed, so every call site had to compensate with
///   `if (newIndex > oldIndex) newIndex--`.
/// - `onReorderItem` already accounts for the removal, so that compensation
///   must be deleted — keeping it drags the item one row short.
///
/// The 3.44 migration removed the compensation from
/// `WalletActionProviderToken.reorderChain` (wallet 管理链页) and from chat's
/// quick-replies page. The chat side was confirmed on a physical iPhone in
/// T26; the wallet side is still `NOT VERIFIED` on device because async
/// wallet initialisation mutated the source list mid-gesture.
///
/// These tests close that gap without a device: they drive a real
/// [ReorderableListView] so Flutter itself supplies `newIndex`, and assert
/// that "remove at oldIndex, insert at newIndex" — with **no** compensation —
/// lands the item where the user dropped it.
void main() {
  /// Applies the exact mutation `reorderChain` performs.
  List<String> applyReorder(List<String> items, int oldIndex, int newIndex) {
    final next = List<String>.from(items);
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    return next;
  }

  /// Same mutation but with the legacy `onReorder` compensation left in.
  List<String> applyReorderWithLegacyCompensation(
    List<String> items,
    int oldIndex,
    int newIndex,
  ) {
    var target = newIndex;
    if (target > oldIndex) target--;
    final next = List<String>.from(items);
    final moved = next.removeAt(oldIndex);
    next.insert(target, moved);
    return next;
  }

  Future<List<String>> dragAndCollect(
    WidgetTester tester, {
    required List<String> initial,
    required String dragLabel,
    required double dyOffset,
    required List<String> Function(List<String>, int, int) apply,
  }) async {
    var items = List<String>.from(initial);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ReorderableListView.builder(
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() => items = apply(items, oldIndex, newIndex));
                },
                itemBuilder: (context, index) => SizedBox(
                  key: ValueKey<String>(items[index]),
                  height: 56,
                  child: Center(child: Text(items[index])),
                ),
              );
            },
          ),
        ),
      ),
    );

    final handle = find.text(dragLabel);
    final gesture = await tester.startGesture(tester.getCenter(handle));
    // Long-press to pick the row up, then move in small steps so the list has
    // a chance to compute the drop slot exactly as it would under a real drag.
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    for (var moved = 0.0; moved.abs() < dyOffset.abs(); moved += dyOffset / 8) {
      await gesture.moveBy(Offset(0, dyOffset / 8));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    return items;
  }

  group('ReorderableListView.onReorderItem index contract', () {
    testWidgets('moving the first row down two slots lands it third', (
      tester,
    ) async {
      final result = await dragAndCollect(
        tester,
        initial: const ['N', 'BTC', 'ETH', 'SOL'],
        dragLabel: 'N',
        dyOffset: 56.0 * 2,
        apply: applyReorder,
      );

      // The user dropped N onto the third slot, so N must be third.
      expect(result, ['BTC', 'ETH', 'N', 'SOL']);
    });

    testWidgets('moving the third row up two slots lands it first', (
      tester,
    ) async {
      final result = await dragAndCollect(
        tester,
        initial: const ['N', 'BTC', 'ETH', 'SOL'],
        dragLabel: 'ETH',
        dyOffset: -56.0 * 2,
        apply: applyReorder,
      );

      expect(result, ['ETH', 'N', 'BTC', 'SOL']);
    });

    testWidgets(
      'keeping the legacy newIndex-- compensation drags one row short',
      (tester) async {
        final result = await dragAndCollect(
          tester,
          initial: const ['N', 'BTC', 'ETH', 'SOL'],
          dragLabel: 'N',
          dyOffset: 56.0 * 2,
          apply: applyReorderWithLegacyCompensation,
        );

        // Guards the regression in the other direction: if someone re-adds the
        // compensation, N stops one slot short of where it was dropped. This
        // test failing means the compensation is back.
        expect(result, ['BTC', 'N', 'ETH', 'SOL']);
        expect(result, isNot(['BTC', 'ETH', 'N', 'SOL']));
      },
    );

    testWidgets('upward drags are unaffected by the legacy compensation', (
      tester,
    ) async {
      // `newIndex > oldIndex` is false when dragging up, so both variants agree
      // — this documents why only downward drags regressed.
      final withCompensation = await dragAndCollect(
        tester,
        initial: const ['N', 'BTC', 'ETH', 'SOL'],
        dragLabel: 'ETH',
        dyOffset: -56.0 * 2,
        apply: applyReorderWithLegacyCompensation,
      );

      expect(withCompensation, ['ETH', 'N', 'BTC', 'SOL']);
    });
  });
}
