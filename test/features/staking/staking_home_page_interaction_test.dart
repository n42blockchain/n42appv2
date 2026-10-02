import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/staking/pages/stake_page.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('blocked by offline staking widget test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;

  setUp(() => HttpOverrides.global = _OfflineHttpOverrides());
  tearDown(() => HttpOverrides.global = previousHttpOverrides);

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(const StakingHomePage()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows supported protocol cards and hides DOT staking', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Lido'), findsOneWidget);
    expect(find.text('Solana Staking'), findsOneWidget);
    expect(find.text('Cosmos Staking'), findsOneWidget);
    expect(find.text('Polkadot Staking'), findsNothing);
    expect(find.text('4.0%'), findsOneWidget);
    expect(find.text('7.0%'), findsOneWidget);
    expect(find.text('15.0%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty positions offer a path back to protocol browsing', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text(S.current.g_key_stake_positions));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_key_stake_no_positions_yet), findsOneWidget);

    await tester.tap(find.text(S.current.g_key_stake_start_staking));
    await tester.pumpAndSettle();
    expect(find.text('Lido'), findsOneWidget);
    expect(find.text(S.current.g_key_stake_no_positions_yet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a protocol opens its stake page', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Lido'));
    await tester.pumpAndSettle();

    expect(find.byType(StakePage), findsOneWidget);
    expect(find.text('Lido'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
