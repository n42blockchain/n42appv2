import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _Storage extends TestFlutterSecureStoragePlatform {
  _Storage() : super({});
  bool fail = false;
  int saves = 0;
  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    if (key == 'walletInfo') {
      saves++;
      if (fail) throw StateError('injected storage failure');
    }
    await super.write(key: key, value: value, options: options);
  }
}

void main() {
  const toast = MethodChannel('PonnamKarthik/fluttertoast');
  setUp(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, (_) async => true),
  );
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, null),
  );
  for (final fail in [false, true]) {
    testWidgets(
      'first password has no old-password requirement; storage failure=$fail',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        app.globalProviderContainer = ProviderContainer();
        addTearDown(app.globalProviderContainer.dispose);
        final secure = _Storage()..fail = fail;
        FlutterSecureStoragePlatform.instance = secure;
        final store = WalletActionProvider();
        final wallet = WalletInfo();
        await tester.pumpWidget(
          wrapForTest(
            Builder(
              builder: (context) => TextButton(
                child: const Text('Set password'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => EditWalletPassword(wallet, 0),
                  ),
                ),
              ),
            ),
            overrides: [wapBridgeProvider.overrideWith((ref) => store)],
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Set password'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNWidgets(2));
        await tester.enterText(find.byType(TextField).at(0), 'TestPass123!');
        await tester.enterText(find.byType(TextField).at(1), 'TestPass123!');
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.current.g_key_115));
        await tester.pumpAndSettle();
        expect(secure.saves, 1);
        expect(wallet.password, fail ? isNull : 'TestPass123!');
        await tester.pump(const Duration(seconds: 8));
      },
    );
  }
}
