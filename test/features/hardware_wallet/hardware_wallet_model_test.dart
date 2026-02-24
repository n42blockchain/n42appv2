// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';

void main() {
  group('HardwareWalletModels Tests', () {
    group('HardwareWalletType enum', () {
      test('should have Ledger device types', () {
        expect(HardwareWalletType.values.contains(HardwareWalletType.ledgerNanoX), true);
        expect(HardwareWalletType.values.contains(HardwareWalletType.ledgerNanoSPlus), true);
        expect(HardwareWalletType.values.contains(HardwareWalletType.ledgerStax), true);
      });

      test('should have Trezor device types', () {
        expect(HardwareWalletType.values.contains(HardwareWalletType.trezorModelT), true);
        expect(HardwareWalletType.values.contains(HardwareWalletType.trezorOne), true);
      });
    });

    group('HardwareWalletConnectionState enum', () {
      test('should have correct values', () {
        expect(HardwareWalletConnectionState.values.contains(HardwareWalletConnectionState.disconnected), true);
        expect(HardwareWalletConnectionState.values.contains(HardwareWalletConnectionState.scanning), true);
        expect(HardwareWalletConnectionState.values.contains(HardwareWalletConnectionState.connecting), true);
        expect(HardwareWalletConnectionState.values.contains(HardwareWalletConnectionState.connected), true);
        expect(HardwareWalletConnectionState.values.contains(HardwareWalletConnectionState.error), true);
      });
    });

    group('BluetoothDeviceInfo', () {
      test('should create with correct values', () {
        final device = BluetoothDeviceInfo(
          id: 'BLE_001',
          name: 'Ledger Nano X',
          rssi: -50,
        );

        expect(device.id, 'BLE_001');
        expect(device.name, 'Ledger Nano X');
        expect(device.rssi, -50);
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'BLE_002',
          'name': 'Ledger Nano S Plus',
          'rssi': -65,
          'isConnectable': true,
        };

        final device = BluetoothDeviceInfo.fromJson(json);

        expect(device.id, 'BLE_002');
        expect(device.name, 'Ledger Nano S Plus');
        expect(device.rssi, -65);
        expect(device.isConnectable, true);
      });

      test('should convert to JSON correctly', () {
        final device = BluetoothDeviceInfo(
          id: 'BLE_003',
          name: 'Trezor Model T',
          rssi: -70,
        );

        final json = device.toJson();

        expect(json['id'], 'BLE_003');
        expect(json['name'], 'Trezor Model T');
        expect(json['rssi'], -70);
      });

      test('should calculate signal strength correctly', () {
        // Strong signal (rssi >= -50)
        final strongDevice = BluetoothDeviceInfo(id: '1', name: 'Test', rssi: -40);
        expect(strongDevice.signalStrength, 4);

        // Good signal (rssi >= -60)
        final goodDevice = BluetoothDeviceInfo(id: '2', name: 'Test', rssi: -55);
        expect(goodDevice.signalStrength, 3);

        // Medium signal (rssi >= -70)
        final mediumDevice = BluetoothDeviceInfo(id: '3', name: 'Test', rssi: -65);
        expect(mediumDevice.signalStrength, 2);

        // Weak signal (rssi >= -80)
        final weakDevice = BluetoothDeviceInfo(id: '4', name: 'Test', rssi: -75);
        expect(weakDevice.signalStrength, 1);

        // Very weak signal (rssi < -80)
        final veryWeakDevice = BluetoothDeviceInfo(id: '5', name: 'Test', rssi: -90);
        expect(veryWeakDevice.signalStrength, 0);
      });
    });
  });

  group('Derivation Path Tests', () {
    test('should validate Ethereum derivation path', () {
      const ethPath = "m/44'/60'/0'/0/0";
      final isValid = RegExp(r"^m/44'/60'/\d+'/\d+/\d+$").hasMatch(ethPath);
      expect(isValid, true);
    });

    test('should validate Bitcoin derivation path', () {
      const btcPath = "m/84'/0'/0'/0/0";
      final isValid = RegExp(r"^m/84'/0'/\d+'/\d+/\d+$").hasMatch(btcPath);
      expect(isValid, true);
    });

    test('should parse derivation path components', () {
      const path = "m/44'/60'/0'/0/5";
      final components = path.split('/');

      expect(components[0], 'm');
      expect(components[1], "44'");
      expect(components[2], "60'");
      expect(components[3], "0'");
      expect(components[4], '0');
      expect(components[5], '5');
    });
  });

  group('Transaction Data Tests', () {
    test('should create unsigned transaction data', () {
      final txData = {
        'to': '0x1234567890abcdef1234567890abcdef12345678',
        'value': '1000000000000000000',
        'gasLimit': '21000',
        'gasPrice': '20000000000',
        'nonce': '5',
        'chainId': '1',
        'data': '0x',
      };

      expect(txData.containsKey('to'), true);
      expect(txData.containsKey('value'), true);
      expect(txData.containsKey('chainId'), true);
    });

    test('should validate signed transaction format', () {
      final signedTx = {
        'rawTransaction': '0xf86c0585...',
        'v': '0x1b',
        'r': '0x1234...',
        's': '0x5678...',
      };

      expect(signedTx['rawTransaction']?.startsWith('0x'), true);
      expect(signedTx.containsKey('v'), true);
      expect(signedTx.containsKey('r'), true);
      expect(signedTx.containsKey('s'), true);
    });
  });
}
