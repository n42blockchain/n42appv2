import 'package:flutter/material.dart';
import 'package:flutter_mining/mobileverify.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_providers.dart';
import 'package:n42_wallet/features/mining_v3/pages/mining_v3_page.dart';

import '../../helpers/widget_test_helpers.dart';

class _Preferences extends SPUtil {
  String? endpoint;
  @override
  Future<String?> getMiningV3Endpoint() async => endpoint;
  @override
  Future<void> setMiningV3Endpoint(String value) async => endpoint = value;
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
  for (final saved in [null, 'https://custom.example:4242']) {
    testWidgets('node defaults preserve saved address $saved', (tester) async {
      final preferences = _Preferences()..endpoint = saved;
      final engine = MiningV3Engine(
        api: _Native(),
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
      await tester.tap(find.byKey(const ValueKey('mining_v3_settings')));
      await tester.pumpAndSettle();
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, saved ?? miningV3LocalTestnetEndpoint);
      await tester.tap(find.text('Use local testnet'));
      await tester.pumpAndSettle();
      expect(field.controller!.text, miningV3LocalTestnetEndpoint);
      expect(
        preferences.endpoint,
        saved,
        reason: 'Choosing a preset still requires Save',
      );
      await tester.tap(find.text('Save node'));
      await tester.pumpAndSettle();
      expect(preferences.endpoint, miningV3LocalTestnetEndpoint);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'iOS explains background pause and locks its pending-resume node',
    (tester) async {
      final native = _Native()
        ..status = const MvMinerStatus(
          running: false,
          phase: 'idle',
          endpoint: miningV3LocalTestnetEndpoint,
          pausedForBackground: true,
          activeDurationMs: 7000,
          sessionId: 'ios-user-session',
          startedAtMs: 1,
        );
      final engine = MiningV3Engine(
        api: native,
        store: _Secure(),
        refreshEvery: const Duration(days: 1),
      );
      await tester.pumpWidget(
        wrapForTest(
          const MiningV3Page(),
          overrides: [
            spUtilProvider.overrideWithValue(_Preferences()),
            miningV3EngineProvider.overrideWith((ref) => engine),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Paused in background'), findsOneWidget);
      expect(
        find.textContaining('Only active time is counted.'),
        findsOneWidget,
      );
      expect(find.text('00:00:07'), findsOneWidget);
      expect(find.text('Pause mining'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('mining_v3_settings')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
        isFalse,
      );
      expect(find.text('Pause mining to change the node.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
