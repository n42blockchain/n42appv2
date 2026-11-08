import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
      if (await _isIosSimulator()) {
        markTestSkipped(
          'iOS Simulator has no camera; unsupported-state coverage runs separately. '
          'Camera capture and resume require supported hardware.',
        );
        return;
      }
      final permission = await Permission.camera.request();
      expect(permission, PermissionStatus.granted);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      await tester.pumpWidget(_scannerHost());

      await _wait(
        tester,
        () => find.byType(MobileScanner).evaluate().isNotEmpty,
      );
      final controller = tester
          .widget<MobileScanner>(find.byType(MobileScanner))
          .controller!;
      await _wait(
        tester,
        () => controller.value.isRunning,
        controller: controller,
      );

      for (var i = 0; i < 3; i++) {
        binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await _wait(
          tester,
          () => !controller.value.isRunning,
          controller: controller,
        );
        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await _wait(
          tester,
          () => controller.value.isRunning,
          controller: controller,
        );
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

  testWidgets(
    'wallet scanner handles unsupported iOS simulator camera and lifecycle',
    (tester) async {
      if (!await _isIosSimulator()) {
        markTestSkipped(
          'Unsupported-camera case applies only to iOS Simulator.',
        );
        return;
      }
      expect(await Permission.camera.request(), PermissionStatus.granted);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(_scannerHost());
      await _wait(
        tester,
        () => find.byType(MobileScanner).evaluate().isNotEmpty,
      );
      final controller = tester
          .widget<MobileScanner>(find.byType(MobileScanner))
          .controller!;
      for (var cycle = 0; cycle < 3; cycle++) {
        await _wait(
          tester,
          () =>
              controller.value.error?.errorCode ==
              MobileScannerErrorCode.unsupported,
          controller: controller,
        );
        expect(controller.value.isRunning, isFalse);
        expect(
          find.text(MobileScannerErrorCode.unsupported.message),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
        binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        await tester.pump(const Duration(milliseconds: 250));
        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          tester.widget<MobileScanner>(find.byType(MobileScanner)).controller,
          same(controller),
        );
      }
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Future<bool> _isIosSimulator() async =>
    Platform.isIOS && !(await DeviceInfoPlugin().iosInfo).isPhysicalDevice;

Widget _scannerHost() => ScreenUtilInit(
  designSize: const Size(360, 690),
  child: MaterialApp(
    localizationsDelegates: [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: const ScanPage(),
  ),
);

Future<void> _wait(
  WidgetTester tester,
  bool Function() ready, {
  MobileScannerController? controller,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(
    ready(),
    isTrue,
    reason:
        'Wallet scanner camera did not reach the expected state; '
        'initialized=${controller?.value.isInitialized}, '
        'running=${controller?.value.isRunning}, '
        'starting=${controller?.value.isStarting}, '
        'cameras=${controller?.value.availableCameras}, '
        'error=${controller?.value.error?.errorCode.name}, '
        'lifecycle=${WidgetsBinding.instance.lifecycleState?.name}',
  );
}
