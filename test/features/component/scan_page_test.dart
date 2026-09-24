import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n42_wallet/features/component/pages/scan_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

class _ScannerPlatform extends MobileScannerPlatform {
  final captures = StreamController<BarcodeCapture?>.broadcast();
  final torches = StreamController<TorchState>.broadcast();
  int starts = 0;
  int stops = 0;
  int toggles = 0;
  int disposals = 0;

  @override
  Stream<BarcodeCapture?> get barcodesStream => captures.stream;

  @override
  Stream<TorchState> get torchStateStream => torches.stream;

  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();

  @override
  Widget buildCameraView() => const SizedBox.expand();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async {
    starts++;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(320, 480),
    );
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> toggleTorch() async {
    toggles++;
    torches.add(toggles.isOdd ? TorchState.on : TorchState.off);
  }

  @override
  Future<void> dispose() async => disposals++;
}

void main() {
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  late _ScannerPlatform scanner;
  late MobileScannerPlatform originalScanner;
  var permission = 1;
  var requests = 0;

  setUp(() {
    scanner = _ScannerPlatform();
    originalScanner = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = scanner;
    requests = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          switch (call.method) {
            case 'checkPermissionStatus':
              return permission;
            case 'requestPermissions':
              requests++;
              return <int, int>{1: permission};
            case 'openAppSettings':
              return true;
          }
          throw StateError('Unexpected permission call ${call.method}');
        });
  });

  tearDown(() async {
    MobileScannerPlatform.instance = originalScanner;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    await scanner.captures.close();
    await scanner.torches.close();
  });

  Future<void> open(WidgetTester tester, ValueChanged<String?> onResult) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          localizationsDelegates: [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  TextButton(
                    key: const ValueKey('open_scanner'),
                    onPressed: () async {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute<String>(
                          builder: (_) => const ScanPage(),
                        ),
                      );
                      onResult(result);
                    },
                    child: const Text('Scan'),
                  ),
                  const Text('scanner host'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open_scanner')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  testWidgets('returns one raw scan string and disposes camera once', (
    tester,
  ) async {
    permission = 1;
    String? result;
    await open(tester, (value) => result = value);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MobileScanner), findsOneWidget);
    expect(scanner.starts, 1);

    scanner.captures.add(
      const BarcodeCapture(barcodes: [Barcode(rawValue: ' raw:qr://payload ')]),
    );
    scanner.captures.add(
      const BarcodeCapture(barcodes: [Barcode(rawValue: 'duplicate')]),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(result, ' raw:qr://payload ');
    expect(scanner.stops, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(scanner.disposals, 1);
  });

  testWidgets('requests denied camera permission and shows no scanner', (
    tester,
  ) async {
    permission = 0;
    String? result;
    await open(tester, (value) => result = value);
    expect(requests, 1);
    expect(find.byType(MobileScanner), findsNothing);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restricted camera permission is not requested repeatedly', (
    tester,
  ) async {
    permission = 2;
    String? result;
    await open(tester, (value) => result = value);
    expect(requests, 0);
    expect(find.byType(MobileScanner), findsNothing);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pause and resume serialize scanner stop and start', (
    tester,
  ) async {
    permission = 1;
    String? result;
    await open(tester, (value) => result = value);
    await tester.pump(const Duration(milliseconds: 100));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(scanner.stops, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(scanner.starts, 2);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('flash control toggles the mobile scanner torch', (tester) async {
    permission = 1;
    String? result;
    await open(tester, (value) => result = value);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('scan_flash_button')));
    await tester.pump();
    expect(scanner.toggles, 1);
    expect(find.byIcon(Icons.flash_on), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('hot reload reassembles camera lifecycle safely', (tester) async {
    permission = 1;
    String? result;
    await open(tester, (value) => result = value);
    await tester.pump(const Duration(milliseconds: 100));
    tester.binding.reassembleApplication();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(scanner.stops, 1);
    expect(scanner.starts, 2);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
