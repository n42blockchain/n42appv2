import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_settings.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_provider.dart';
import 'package:n42_wallet/features/mining_v1/provider/mining_v1_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/widget_test_helpers.dart';

const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);
const _miningChannel = MethodChannel('flutter_mining');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.isMainChainMining = true;
    globalMiningV1 = MiningProvider()..walletIndex = 4;
  });

  tearDown(() {
    globalMiningV1.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(_connectivityChannel, null)
      ..setMockMethodCallHandler(_miningChannel, null);
  });

  testWidgets('rapid repeated switch intents preserve the requested value', (
    tester,
  ) async {
    final pendingChecks = <Completer<Object?>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, (call) {
          expect(call.method, 'check');
          final pending = Completer<Object?>();
          pendingChecks.add(pending);
          return pending.future;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_miningChannel, (call) async {
          if (call.method == 'emit') {
            final request = jsonDecode(call.arguments as String);
            if (request['type'] == 'state') {
              return jsonEncode({'data': 'started'});
            }
            return jsonEncode({'data': 'started'});
          }
          return null;
        });
    await SPUtil().setMiningOpen(false);
    await _pumpSettings(tester, const MiningSettings());

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(pendingChecks, hasLength(2));

    for (final pending in pendingChecks) {
      pending.complete(<String>['wifi']);
    }
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(await SPUtil().getOpenMining(), isTrue);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSettings(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(wrapForTest(page));
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
}
