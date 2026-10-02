import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/service/ledger_service.dart';

const _hardwareChannel = MethodChannel('hardware_wallet');
const _scanChannel = EventChannel('hardware_wallet/scan');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = LedgerService();
  final calls = <MethodCall>[];
  var bluetoothAvailable = true;
  var permissionGranted = true;
  PlatformException? scanStartError;
  MockStreamHandlerEventSink? scanEvents;

  setUp(() async {
    calls.clear();
    bluetoothAvailable = true;
    permissionGranted = true;
    scanStartError = null;
    scanEvents = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(_hardwareChannel, (call) async {
        calls.add(call);
        switch (call.method) {
          case 'isBluetoothAvailable':
            return bluetoothAvailable;
          case 'requestBluetoothPermissions':
            return permissionGranted;
          case 'startScan':
            if (scanStartError case final error?) throw error;
            return null;
          case 'connect':
            return <String, dynamic>{};
          case 'getFirmwareVersion':
            return '2.1.0';
          case 'getBitcoinAddress':
            return 'bc1qtestaddress';
          case 'getChainAddress':
            return 'SoTestAddress';
          case 'stopScan':
          case 'disconnect':
            return null;
          default:
            return null;
        }
      })
      ..setMockStreamHandler(
        _scanChannel,
        MockStreamHandler.inline(
          onListen: (_, events) {
            scanEvents = events;
          },
        ),
      );

    await service.disconnect();
    calls.clear();
  });

  tearDown(() async {
    await service.stopScan();
    await service.disconnect();
  });

  test(
    'Bluetooth availability and permission use the native results',
    () async {
      bluetoothAvailable = false;
      permissionGranted = true;

      expect(await service.isBluetoothAvailable(), isFalse);
      expect(await service.requestBluetoothPermissions(), isTrue);
      expect(calls.map((call) => call.method), [
        'isBluetoothAvailable',
        'requestBluetoothPermissions',
      ]);
    },
  );

  test('a scan request preserves the Ledger filter and timeout', () async {
    await service.startScan(timeout: const Duration(seconds: 7));

    expect(service.connectionState, HardwareWalletConnectionState.scanning);
    expect(calls.single.method, 'startScan');
    expect(calls.single.arguments, {
      'serviceUUID': '13d63400-2c97-0004-0000-4c6564676572',
      'timeout': 7000,
    });
  });

  test('scan results ignore other devices and duplicate Ledger IDs', () async {
    final updates = <List<BluetoothDeviceInfo>>[];
    final subscription = service.scanResults.listen(updates.add);
    await service.startScan(timeout: const Duration(seconds: 1));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(scanEvents, isNotNull);

    scanEvents!.success({'id': 'other', 'name': 'Headphones', 'rssi': -40});
    scanEvents!.success({
      'id': 'ledger-1',
      'name': 'Ledger Nano X',
      'rssi': -55,
    });
    scanEvents!.success({
      'id': 'ledger-1',
      'name': 'Ledger Nano X',
      'rssi': -50,
    });
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.discoveredDevices, hasLength(1));
    expect(service.discoveredDevices.single.id, 'ledger-1');
    expect(updates, hasLength(1));
    expect(updates.single.single.signalStrength, 3);

    await service.stopScan();
    expect(service.connectionState, HardwareWalletConnectionState.disconnected);
    await subscription.cancel();
  });

  test(
    'an event-channel scan error moves the service to error state',
    () async {
      await service.startScan(timeout: const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      scanEvents!.error(code: 'SCAN_FAILED', message: 'Bluetooth scan stopped');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(service.connectionState, HardwareWalletConnectionState.error);
    },
  );

  test(
    'a native scan-start failure is surfaced and marks error state',
    () async {
      scanStartError = PlatformException(
        code: 'BLUETOOTH_DISABLED',
        message: 'Bluetooth is off',
      );

      await expectLater(
        service.startScan(timeout: const Duration(seconds: 3)),
        throwsA(
          isA<HardwareWalletError>().having(
            (error) => error.code,
            'code',
            HardwareWalletError.bluetoothDisabled,
          ),
        ),
      );
      expect(service.connectionState, HardwareWalletConnectionState.error);
    },
  );

  test(
    'address requests fail before native calls while disconnected',
    () async {
      final errorMatcher = throwsA(
        isA<HardwareWalletError>().having(
          (error) => error.code,
          'code',
          HardwareWalletError.deviceNotFound,
        ),
      );

      await expectLater(service.getBitcoinAddress(), errorMatcher);
      await expectLater(
        service.getChainAddress(
          coinType: 'sol',
          derivationPath: "m/44'/501'/0'/0'",
        ),
        errorMatcher,
      );
      expect(calls, isEmpty);
    },
  );

  test('connection enables Bitcoin and chain address requests', () async {
    final device = await service.connect(
      const BluetoothDeviceInfo(
        id: 'ledger-1',
        name: 'Ledger Nano S Plus',
        rssi: -48,
      ),
    );

    expect(device.type, HardwareWalletType.ledgerNanoSPlus);
    expect(device.firmwareVersion, '2.1.0');
    expect(device.isConnected, isTrue);
    expect(service.connectionState, HardwareWalletConnectionState.connected);

    expect(
      await service.getBitcoinAddress(
        derivationPath: "m/84'/0'/0'/0/2",
        display: true,
      ),
      'bc1qtestaddress',
    );
    expect(
      await service.getChainAddress(
        coinType: 'sol',
        derivationPath: "m/44'/501'/0'/0'",
      ),
      'SoTestAddress',
    );
    expect(calls.map((call) => call.method), [
      'connect',
      'getFirmwareVersion',
      'getBitcoinAddress',
      'getChainAddress',
    ]);
    expect(calls[0].arguments, {
      'deviceId': 'ledger-1',
      'serviceUUID': '13d63400-2c97-0004-0000-4c6564676572',
    });
    expect(calls[2].arguments, {'path': "m/84'/0'/0'/0/2", 'display': true});
    expect(calls[3].arguments, {
      'coinType': 'SOL',
      'path': "m/44'/501'/0'/0'",
      'display': false,
    });

    await service.disconnect();
    expect(service.connectionState, HardwareWalletConnectionState.disconnected);
    expect(service.connectedDevice, isNull);
  });
}
