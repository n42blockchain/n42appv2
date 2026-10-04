import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_key_list.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_output_tip.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

class _MiningStorage extends TestFlutterSecureStoragePlatform {
  _MiningStorage(super.data);
}

class _MiningBridge extends MiningV2Provider {
  int reloadCount = 0;

  @override
  Future<void> getMiningData() async {
    reloadCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late String? clipboardText;
  late FlutterSecureStoragePlatform originalStorage;
  late _MiningStorage storage;
  late _MiningBridge bridge;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    originalStorage = FlutterSecureStoragePlatform.instance;
    storage = _MiningStorage({});
    FlutterSecureStoragePlatform.instance = storage;
    bridge = _MiningBridge();
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async => true);
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalStorage;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    storage.data['miningData'] = jsonEncode({
      'AstranetWallet': {
        'active-key': {
          'isMining': true,
          'keypart': {'publicKey': '0xActivePublic'},
        },
        'stopped-key': {
          'isMining': false,
          'keypart': {'publicKey': '0xStoppedPublic'},
        },
      },
    });
    await tester.pumpWidget(
      wrapForTest(
        const MiningKeyList(),
        overrides: [miningBridgeProvider.overrideWith((ref) => bridge)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows mining state actions and removes only stopped keys', (
    tester,
  ) async {
    await mount(tester);
    final context = tester.element(find.byType(MiningKeyList));

    expect(find.text('active-key'), findsOneWidget);
    expect(find.text('stopped-key'), findsOneWidget);
    expect(find.text(S.of(context).g_key_193), findsOneWidget);
    expect(find.text(S.of(context).g_mining_key_102), findsOneWidget);
    expect(find.byIcon(Icons.output_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);
    expect(find.text('PublicKey:0xActivePublic'), findsOneWidget);
    expect(find.text('PublicKey:0xStoppedPublic'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.copy).first);
    await tester.pump();
    expect(clipboardText, '0xActivePublic');
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_forever_outlined));
    await tester.pumpAndSettle();

    final persisted = jsonDecode(storage.data['miningData']!) as Map;
    final walletKeys = persisted['AstranetWallet'] as Map;
    expect(walletKeys.keys, ['active-key']);
    expect(find.text('stopped-key'), findsNothing);
    expect(find.text('active-key'), findsOneWidget);
    expect(bridge.reloadCount, 1);

    await tester.tap(find.byIcon(Icons.output_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(MiningOutputTip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
