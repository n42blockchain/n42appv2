// Exercises the native camera; no account login or scanned payload is submitted.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/pages/qrcode/scan_qr_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native camera survives scanner pause and resume',
    (tester) async {
      // Grant the system camera prompt on the dedicated test device if requested.
      expect(await Permission.camera.request(), PermissionStatus.granted);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: ScanQRPage(),
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
    reason: 'Native camera did not reach the expected state',
  );
}
