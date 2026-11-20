import 'package:flutter/material.dart';
import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_nodes.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_providers.dart';
import 'package:n42_wallet/features/mining_v3/pages/mining_v3_page.dart';

import '../../helpers/widget_test_helpers.dart';

class _Preferences extends SPUtil {
  String? node;
  String? autoNode;
  @override
  Future<String?> getMiningV3Node() async => node;
  @override
  Future<void> setMiningV3Node(String id) async => node = id;
  @override
  Future<String?> getMiningV3AutoNode() async => autoNode;
  @override
  Future<void> setMiningV3AutoNode(String id) async => autoNode = id;
  @override
  Future<String?> getSysLang() async => null;
}

class _Native extends Fake implements MobileVerifyApi {
  MvMinerStatus status = MvMinerStatus.idle;
  @override
  Future<MvMinerStatus> minerStatus() async => status;
}

class _Secure extends Fake implements SecureStore {}

void main() {
  Future<void> mountPage(
    WidgetTester tester,
    _Preferences preferences, {
    _Native? native,
  }) async {
    final engine = MiningV3Engine(
      api: native ?? _Native(),
      store: _Secure(),
      refreshEvery: const Duration(days: 1),
    );
    await tester.pumpWidget(
      wrapForTest(
        const MiningV3Page(),
        overrides: [
          spUtilProvider.overrideWithValue(preferences),
          miningV3EngineProvider.overrideWith((ref) => engine),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectNoAddressShown() {
    for (final node in miningV3Nodes) {
      final host = Uri.parse(node.url).host;
      expect(find.textContaining(host), findsNothing);
    }
    expect(find.textContaining('http'), findsNothing);
  }

  testWidgets('first launch assigns and keeps a fleet node automatically', (
    tester,
  ) async {
    final preferences = _Preferences();
    await mountPage(tester, preferences);
    final assigned = miningV3NodeById(preferences.autoNode);
    expect(assigned, isNotNull, reason: 'auto node is persisted');
    expect(preferences.node, isNull, reason: 'auto is not a user choice');
    expect(find.text(assigned!.name), findsOneWidget);
    expect(find.text('Automatic (recommended)'), findsOneWidget);
    expectNoAddressShown();
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a node requires Save and hides addresses', (
    tester,
  ) async {
    final preferences = _Preferences()..autoNode = 'fsn-2';
    await mountPage(tester, preferences);
    expect(find.text('Falkenstein 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mining_v3_settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mining_v3_node_auto')), findsOneWidget);
    for (final node in miningV3Nodes) {
      expect(find.byKey(ValueKey('mining_v3_node_${node.id}')), findsOneWidget);
    }
    expectNoAddressShown();

    await tester.tap(find.byKey(const ValueKey('mining_v3_node_nbg-1')));
    await tester.pumpAndSettle();
    expect(preferences.node, isNull, reason: 'picking still requires Save');
    await tester.tap(find.text('Save node'));
    await tester.pumpAndSettle();
    expect(preferences.node, 'nbg-1');
    expect(find.text('Nuremberg 1'), findsOneWidget);
    expect(find.text('Verification node'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an unknown saved node falls back to the automatic node', (
    tester,
  ) async {
    final preferences = _Preferences()
      ..node = 'retired-node'
      ..autoNode = 'us-1';
    await mountPage(tester, preferences);
    expect(find.text('US 1'), findsOneWidget);
    expect(find.text('Automatic (recommended)'), findsOneWidget);
  });

  testWidgets('node errors show the node name instead of its address', (
    tester,
  ) async {
    final native = _Native()
      ..status = MvMinerStatus(
        running: false,
        phase: 'idle',
        lastError:
            'dial ${miningV3Nodes[4].url}/mobileverify: '
            '188.245.191.239:21016 refused',
      );
    await mountPage(tester, _Preferences()..autoNode = 'nbg-1', native: native);
    await tester.tap(find.byKey(const ValueKey('mining_v3_settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last reported issue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nuremberg 1/mobileverify'), findsOneWidget);
    expectNoAddressShown();
  });

  testWidgets(
    'iOS explains background pause and locks its pending-resume node',
    (tester) async {
      final native = _Native()
        ..status = MvMinerStatus(
          running: false,
          phase: 'idle',
          endpoint: miningV3Nodes[2].url,
          pausedForBackground: true,
          activeDurationMs: 7000,
          sessionId: 'ios-user-session',
          startedAtMs: 1,
        );
      await mountPage(tester, _Preferences(), native: native);
      expect(find.text('Paused in background'), findsOneWidget);
      expect(
        find.textContaining('Only active time is counted.'),
        findsOneWidget,
      );
      expect(find.text('00:00:07'), findsOneWidget);
      expect(find.text('Pause mining'), findsOneWidget);
      expect(find.text(miningV3Nodes[2].name), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('mining_v3_settings')));
      await tester.pumpAndSettle();
      for (final tile in tester.widgetList<ListTile>(find.byType(ListTile))) {
        expect(tile.enabled, isFalse);
      }
      expect(find.text('Pause mining to change the node.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
