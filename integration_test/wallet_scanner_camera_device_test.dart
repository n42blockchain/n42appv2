import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'wallet scanner camera survives lifecycle transitions and disposal',
    (tester) async {
      final permission = await Permission.camera.request();
      expect(permission, PermissionStatus.granted);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          child: MaterialApp(
            localizationsDelegates: [S.delegate],
            supportedLocales: S.delegate.supportedLocales,
            home: const ScanPage(),
          ),
        ),
      );

      await _wait(
        tester,
        () => find.byType(MobileScanner).evaluate().isNotEmpty,
      );
      final controller = tester
          .widget<MobileScanner>(find.byType(MobileScanner))
          .controller!;
      await _wait(tester, () => controller.value.isRunning);

      for (var i = 0; i < 3; i++) {
        binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await _wait(tester, () => !controller.value.isRunning);
        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await _wait(tester, () => controller.value.isRunning);
        expect(
          tester.widget<MobileScanner>(find.byType(MobileScanner)).controller,
          same(controller),
        );
        expect(controller.value.error, isNull);
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Camera passed'))),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Future<void> _wait(WidgetTester tester, bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(
    ready(),
    isTrue,
    reason: 'Wallet scanner camera did not reach the expected state',
  );
}
