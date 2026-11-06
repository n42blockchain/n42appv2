import 'dart:async';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  RecentAddressEntry entry(String address) =>
      RecentAddressEntry(address: address, time: DateTime.utc(2026));
  Widget bar({
    String chain = 'SUI',
    Future<List<RecentAddressEntry>> Function(String)? loader,
    ValueChanged<String>? select,
  }) => wrapForTest(
    RecentAddressBar(
      coinType: chain,
      historyLoader: loader,
      onSelected: select ?? (_) {},
    ),
  );

  testWidgets('read failure is visible and retry restores selectable history', (
    tester,
  ) async {
    var calls = 0;
    String? selected;
    await tester.pumpWidget(
      bar(
        loader: (_) async {
          if (++calls == 1) throw const FormatException('corrupt');
          return [entry('recipient')];
        },
        select: (value) => selected = value,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Failed to load'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.textContaining('Failed to load'), findsNothing);
    await tester.tap(find.byType(ActionChip));
    expect(selected, 'recipient');
  });
  for (final fails in [false, true]) {
    testWidgets(
      'old chain ${fails ? 'failure' : 'result'} cannot replace new history',
      (tester) async {
        final first = Completer<List<RecentAddressEntry>>();
        final second = Completer<List<RecentAddressEntry>>();
        Future<List<RecentAddressEntry>> loader(String chain) =>
            chain == 'SUI' ? first.future : second.future;
        await tester.pumpWidget(bar(loader: loader));
        await tester.pumpWidget(bar(chain: 'ETH', loader: loader));
        second.complete([entry('new-chain')]);
        await tester.pumpAndSettle();
        if (fails) {
          first.completeError(StateError('old failure'));
        } else {
          first.complete([entry('old-chain')]);
        }
        await tester.pumpAndSettle();
        expect(find.text('new-chain'), findsOneWidget);
        expect(find.text('old-chain'), findsNothing);
        expect(find.textContaining('Failed to load'), findsNothing);
      },
    );
  }
  testWidgets(
    'real corrupt preferences show retry without deleting stored history',
    (tester) async {
      await RecentAddressService.save('SUI', 'original');
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getKeys().single;
      await prefs.setString(key, '{broken');
      await tester.pumpWidget(bar());
      await tester.pumpAndSettle();
      expect(find.textContaining('Failed to load'), findsOneWidget);
      expect(prefs.getString(key), '{broken');
    },
  );
  testWidgets(
    'switching identity invalidates old choices and reloads the new owner',
    (tester) async {
      final previous = AppGlobals.userInfo;
      addTearDown(() => AppGlobals.userInfo = previous);
      AppGlobals.userInfo = UserInfo(uuid: 'alice');
      String? selected;
      final pending = Completer<List<RecentAddressEntry>>();
      Future<List<RecentAddressEntry>> loader(String _) async =>
          RecentAddressService.currentUser == 'alice'
          ? [entry('alice-address')]
          : pending.future;
      await tester.pumpWidget(
        bar(loader: loader, select: (value) => selected = value),
      );
      await tester.pumpAndSettle();
      AppGlobals.userInfo = UserInfo(uuid: 'bob');
      // The old chip may still be on screen before the parent rebuilds.
      await tester.tap(find.byType(ActionChip));
      expect(selected, isNull);
      await tester.pumpWidget(
        bar(loader: loader, select: (value) => selected = value),
      );
      expect(find.text('alice-address'), findsNothing);
      pending.complete([entry('bob-address')]);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ActionChip));
      expect(selected, 'bob-address');
    },
  );

  testWidgets('disposed load completion does not update state', (tester) async {
    final pending = Completer<List<RecentAddressEntry>>();
    await tester.pumpWidget(bar(loader: (_) => pending.future));
    await tester.pumpWidget(const SizedBox());
    pending.completeError(StateError('late failure'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
