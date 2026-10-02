import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/pages/today_mining_page.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('blocked by offline mining widget test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const miningChannel = MethodChannel('flutter_mining');
  final previousHttpOverrides = HttpOverrides.current;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'miningV1Status': jsonEncode({
        '0xabc': {
          'miningType': 'N',
          'miningValue': {'n': 50, 'ntest': 50},
        },
      }),
    });
    HttpOverrides.global = _OfflineHttpOverrides();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(miningChannel, (call) async {
          if (call.method == 'emit') return '{"data":"started"}';
          return null;
        });
    globalMiningV1 = MiningProvider();
    globalMiningV1.address = '0xabc';
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(miningChannel, null);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(const TodayMiningPage()));
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('unjoined wallet shows plan and inactive mining status', (
    tester,
  ) async {
    globalMiningV1.setMiningType(null);
    globalMiningV1.setDepositsEnable(false);
    await pumpPage(tester);

    expect(find.text(S.current.g_mining_key_5), findsOneWidget);
    expect(find.text(S.current.g_mining_key_47), findsOneWidget);
    expect(find.text('0 N'), findsOneWidget);
    expect(find.text(S.current.g_mining_key_9), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active deposit renders background mining and mining totals', (
    tester,
  ) async {
    globalMiningV1.setMiningType(MiningType.N);
    globalMiningV1.setMiningStatus(true);
    globalMiningV1.setDepositsNum(50);
    globalMiningV1.setDepositsEnable(true);
    await pumpPage(tester);

    expect(find.text(S.current.g_key_193), findsOneWidget);
    expect(find.text(S.current.g_mining_key_9), findsOneWidget);
    expect(find.text(S.current.g_mining_key31), findsOneWidget);
    expect(find.text('0 N'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
