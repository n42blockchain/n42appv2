import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wc_session_list_page.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../helpers/wallet_connect_session_fixture.dart';

class _Provider extends WalletConnectProvider {
  final sessions = <String, wc.SessionData>{};
  final disconnected = <String>[];
  int allCalls = 0;
  Future<void> Function() complete = () async {};
  @override
  Map<String, wc.SessionData> getActiveSessions() => Map.of(sessions);
  @override
  Future<void> disconnectSessionByTopic(String topic) async {
    disconnected.add(topic);
    await complete();
    sessions.remove(topic);
    refresh();
  }

  @override
  Future<void> disconnectAllSessions() async {
    allCalls++;
    await complete();
    sessions.clear();
    refresh();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<_Provider> mount(
    WidgetTester tester,
    List<wc.SessionData> sessions,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final provider = _Provider();
    provider.sessions.addEntries(sessions.map((s) => MapEntry(s.topic, s)));
    await tester.pumpWidget(
      wrapForTest(
        const WcSessionListPage(),
        overrides: [wcpBridgeProvider.overrideWith((ref) => provider)],
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  Finder one() => find
      .byWidgetPredicate(
        (w) => w is IconButton && w.tooltip == S.current.g_connect_key2,
      )
      .first;
  Finder all() => find.byWidgetPredicate(
    (w) => w is IconButton && w.tooltip == S.current.g_wc_disconnect_all,
  );
  Future<void> confirm(WidgetTester tester, bool yes) async {
    await tester.tap(
      find.widgetWithText(
        TextButton,
        yes ? S.current.g_key_78 : S.current.g_key_79,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty sessions expose scan action and omit disconnect-all', (
    tester,
  ) async {
    await mount(tester, []);
    expect(find.text(S.current.g_wc_no_sessions), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(all(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'chain tags deduplicate accounts and preserve unfamiliar chain names',
    (tester) async {
      await mount(tester, [
        session(
          'A long DApp name that should stay within the card',
          expired: true,
          accounts: [
            'eip155:1:0xa',
            'eip155:1:0xb',
            'eip155:999:0xc',
            'tron:mainnet:T1',
            'solana:mainnet:S1',
            'invalid',
          ],
        ),
      ]);
      expect(find.text('Ethereum'), findsOneWidget);
      expect(find.text('EIP155:999'), findsOneWidget);
      expect(find.text('TRON'), findsOneWidget);
      expect(find.text('solana:mainnet'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancel confirmation preserves connection and re-enables its action',
    (tester) async {
      final provider = await mount(tester, [session('Example')]);
      await tester.tap(one());
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_wc_disconnect_confirm), findsOneWidget);
      await confirm(tester, false);
      expect(provider.disconnected, isEmpty);
      expect(provider.sessions, hasLength(1));
      expect(tester.widget<IconButton>(one()).onPressed, isNotNull);
    },
  );

  testWidgets(
    'confirmed disconnect targets only its topic and guards duplicate requests',
    (tester) async {
      final provider = await mount(tester, [
        session('First'),
        session('Second'),
      ]);
      final pending = Completer<void>();
      provider.complete = () => pending.future;
      final action = tester.widget<IconButton>(one()).onPressed!;
      action();
      action();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await confirm(tester, true);
      expect(provider.disconnected, ['First']);
      expect(tester.widget<IconButton>(one()).onPressed, isNull);
      expect(tester.widget<IconButton>(all()).onPressed, isNull);
      pending.complete();
      await tester.pumpAndSettle();
      expect(provider.sessions.keys, ['Second']);
      expect(find.text('First'), findsNothing);
    },
  );

  testWidgets(
    'disconnect-all cancellation is harmless and confirmation removes all sessions',
    (tester) async {
      final provider = await mount(tester, [
        session('First'),
        session('Second'),
      ]);
      await tester.tap(all());
      await tester.pumpAndSettle();
      await confirm(tester, false);
      expect(provider.allCalls, 0);
      await tester.tap(all());
      await tester.pumpAndSettle();
      await confirm(tester, true);
      expect(provider.allCalls, 1);
      expect(find.text(S.current.g_wc_no_sessions), findsOneWidget);
    },
  );

  testWidgets('disconnect failure keeps sessions visible and permits retry', (
    tester,
  ) async {
    final provider = await mount(tester, [session('Example')]);
    provider.complete = () async => throw StateError('transport unavailable');
    await tester.tap(one());
    await tester.pumpAndSettle();
    await confirm(tester, true);
    expect(provider.sessions, hasLength(1));
    expect(find.text(S.current.g_key_175), findsOneWidget);
    expect(tester.widget<IconButton>(one()).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disconnect-all failure exposes an error and re-enables retry', (
    tester,
  ) async {
    final provider = await mount(tester, [session('Example')]);
    provider.complete = () async => throw StateError('partial disconnect');
    await tester.tap(all());
    await tester.pumpAndSettle();
    await confirm(tester, true);
    expect(provider.sessions, hasLength(1));
    expect(find.text(S.current.g_key_175), findsOneWidget);
    expect(tester.widget<IconButton>(all()).onPressed, isNotNull);
    expect(tester.widget<IconButton>(one()).onPressed, isNotNull);
    provider.complete = () async {};
    await tester.tap(all());
    await tester.pumpAndSettle();
    await confirm(tester, true);
    expect(find.text(S.current.g_wc_no_sessions), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'leaving page during disconnect does not update a disposed view',
    (tester) async {
      final provider = await mount(tester, [session('Example')]);
      final pending = Completer<void>();
      provider.complete = () => pending.future;
      await tester.tap(one());
      await tester.pumpAndSettle();
      await confirm(tester, true);
      await tester.pumpWidget(const SizedBox.shrink());
      // Fake transport completion must not emit through the disposed provider.
      // Completing with an error exercises the page's mounted guard.
      pending.completeError(StateError('transport closed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
