import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/device_scan_page.dart';
import 'package:n42_wallet/features/hardware_wallet/provider/hardware_wallet_provider.dart';

import '../../helpers/widget_test_helpers.dart';

class _FakeHardwareWalletProvider extends Fake
    implements HardwareWalletProvider {
  final listeners = <VoidCallback>[];
  Future<bool> Function() permissions = () async => true;
  bool bluetoothAvailable = true;
  bool scanning = false;
  String? error;
  int scanStarts = 0;
  String? scanError;

  void _notify() {
    for (final listener in List<VoidCallback>.from(listeners)) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) => listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => listeners.remove(listener);

  @override
  Future<bool> requestPermissions() => permissions();

  @override
  Future<bool> checkBluetoothAvailable() async => bluetoothAvailable;

  @override
  Future<void> startScan() async {
    scanStarts++;
    scanning = true;
    error = null;
    _notify();
    if (scanError != null) {
      scanning = false;
      error = scanError;
      _notify();
    }
  }

  @override
  Future<void> stopScan() async {
    scanning = false;
    _notify();
  }

  @override
  bool get isScanning => scanning;

  @override
  String? get errorMessage => error;

  @override
  List<BluetoothDeviceInfo> get discoveredDevices => const [];

  @override
  HardwareWalletConnectionState get connectionState =>
      HardwareWalletConnectionState.disconnected;
}

void main() {
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'initial scan screen renders while permission prompt is pending',
    (tester) async {
      await setPhoneSize(tester);
      final provider = _FakeHardwareWalletProvider();
      final permission = Completer<bool>();
      provider.permissions = () => permission.future;

      await tester.pumpWidget(
        wrapForTest(Scaffold(body: DeviceScanPage(provider: provider))),
      );
      await tester.pump();

      expect(find.text('Search complete'), findsOneWidget);
      expect(find.text('No devices found'), findsOneWidget);
      expect(find.text('Scan Again'), findsOneWidget);
      expect(provider.scanStarts, 0);

      permission.complete(false);
      await tester.pumpAndSettle();
      expect(find.text('Bluetooth Permission Required'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('permission denial shows retry guidance without starting scan', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final provider = _FakeHardwareWalletProvider()
      ..permissions = () async => false;

    await tester.pumpWidget(
      wrapForTest(Scaffold(body: DeviceScanPage(provider: provider))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bluetooth Permission Required'), findsOneWidget);
    expect(
      find.text(
        'Please grant Bluetooth permission to scan for hardware wallets.',
      ),
      findsOneWidget,
    );
    expect(provider.scanStarts, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled Bluetooth shows settings guidance and skips scan', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final provider = _FakeHardwareWalletProvider()..bluetoothAvailable = false;

    await tester.pumpWidget(
      wrapForTest(Scaffold(body: DeviceScanPage(provider: provider))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bluetooth Disabled'), findsOneWidget);
    expect(
      find.text(
        'Please enable Bluetooth in your device settings to connect to your hardware wallet.',
      ),
      findsOneWidget,
    );
    expect(provider.scanStarts, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scan failure is shown instead of a misleading empty result', (
    tester,
  ) async {
    await setPhoneSize(tester);
    final provider = _FakeHardwareWalletProvider()
      ..scanError = 'Bluetooth scan failed';

    await tester.pumpWidget(
      wrapForTest(Scaffold(body: DeviceScanPage(provider: provider))),
    );
    await tester.pump();
    await tester.pump();

    expect(provider.scanStarts, 1);
    expect(find.text('Bluetooth scan failed'), findsOneWidget);
    expect(find.text('No devices found'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
