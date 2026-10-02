import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v1/models/mining_type.dart';
import 'package:n42_wallet/features/mining_v1/pages/summary_page.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('blocked by offline summary logic test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final previousHttpOverrides = HttpOverrides.current;
  late ProviderContainer providerContainer;
  late LegacyWalletActionProviderAdapter walletAdapter;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
    providerContainer = ProviderContainer();
    walletAdapter = LegacyWalletActionProviderAdapter(providerContainer);
    globalWapAdapter = walletAdapter;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'miningV1Status': jsonEncode({})});
    HttpOverrides.global = _OfflineHttpOverrides();
    globalMiningV1 = MiningProvider()..address = '0xabc';
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  tearDownAll(() {
    walletAdapter.dispose();
    providerContainer.dispose();
  });

  Future<dynamic> mountSummary(
    WidgetTester tester, {
    Size viewport = const Size(800, 1200),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(wrapForTest(const SummaryPage()));
    await tester.pump(const Duration(milliseconds: 50));
    return tester.state(find.byType(SummaryPage));
  }

  testWidgets('summary card fits a narrow mobile viewport', (tester) async {
    await mountSummary(tester, viewport: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reward calculation applies each pool-specific cap and rate', (
    tester,
  ) async {
    final state = await mountSummary(tester);

    globalMiningV1.setMiningType(MiningType.FUJI_NFT);
    expect(
      state.computeRewardsValueByTaskNum(49, 2000),
      closeTo(0.3266666666634, 1e-12),
    );
    expect(
      state.computeRewardsValueByTaskNum(80, 2000),
      closeTo(0.33333333333, 1e-12),
    );
    expect(state.computeRewardsValueByTaskNum(70, 800), closeTo(0.1, 1e-12));
    expect(state.computeRewardsValueByTaskNum(100, 600), closeTo(0.025, 1e-12));

    globalMiningV1.setMiningType(MiningType.N);
    expect(
      state.computeRewardsValueByTaskNum(499, 50),
      closeTo(0.012475, 1e-12),
    );
    expect(state.computeRewardsValueByTaskNum(800, 50), closeTo(0.0125, 1e-12));
    expect(
      state.computeRewardsValueByTaskNum(120, 100),
      closeTo(0.0333333333333334, 1e-12),
    );
    expect(
      state.computeRewardsValueByTaskNum(150, 10),
      closeTo(0.2083333333333334, 1e-12),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('elapsed time and maximum reward index handle boundaries', (
    tester,
  ) async {
    final state = await mountSummary(tester);

    expect(state.formatElapsedTime(0), '00:00:00');
    expect(state.formatElapsedTime(3661), '01:01:01');
    expect(state.formatElapsedTime(90061), '25:01:01');

    state.epochList = <int>[];
    state.barValues = <double>[0, 5, 2];
    expect(state.getMaxRewardIndex(), -1);

    state.epochList = <int>[1, 2, 3];
    state.barValues = <double>[];
    expect(state.getMaxRewardIndex(), -1);

    state.barValues = <double>[0, 0, 0];
    expect(state.getMaxRewardIndex(), -1);

    state.barValues = <double>[2, 7, 7, 3];
    expect(state.getMaxRewardIndex(), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('past week labels are seven zero-padded day and month values', (
    tester,
  ) async {
    final state = await mountSummary(tester);
    final dates = (state.getPast7DaysDate() as List).cast<String>();

    expect(dates, hasLength(7));
    expect(dates, everyElement(matches(RegExp(r'^\d{2}/\d{2}$'))));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lock age uses mining-pool duration and rejects malformed dates',
    (tester) async {
      final state = await mountSummary(tester);

      globalMiningV1.setMiningType(MiningType.N);
      expect(state.getYearAgoTime('15/08/2026 12:30'), '15/08/2025 12:30');

      globalMiningV1.setMiningType(MiningType.FUJI_NFT);
      expect(state.getYearAgoTime('15/08/2026 12:30'), '17/05/2026 12:30');
      expect(state.getYearAgoTime('not a date'), '');
      expect(tester.takeException(), isNull);
    },
  );
}
