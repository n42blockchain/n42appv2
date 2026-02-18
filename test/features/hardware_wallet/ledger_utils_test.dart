// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-13: Tests for hardware wallet model extended coverage
//       + derivation path / BIP32 utility logic
//
// Tests added here complement hardware_wallet_model_test.dart.
// Strategy: test model classes and utility logic directly without
// instantiating any platform-dependent services.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/hardware_wallet/models/hardware_wallet_models.dart';

// ---------------------------------------------------------------------------
// Local BIP-32 path utility (mirrors what ledger_service would use internally)
// ---------------------------------------------------------------------------

/// Parse a BIP-32 derivation path string into a list of uint32 components.
/// Hardened segments (marked with ') have bit 31 set (0x80000000).
List<int> parseBip32Path(String path) {
  final segments = path.split('/');
  if (segments.isEmpty || segments[0] != 'm') {
    throw ArgumentError('Path must start with "m"');
  }
  final result = <int>[];
  for (final seg in segments.skip(1)) {
    final hardened = seg.endsWith("'");
    final index = int.parse(hardened ? seg.substring(0, seg.length - 1) : seg);
    result.add(hardened ? index + 0x80000000 : index);
  }
  return result;
}

/// Chunk a byte list into segments of at most [maxSize] bytes.
List<List<int>> chunkBytes(List<int> bytes, {int maxSize = 255}) {
  if (bytes.isEmpty) return [];
  final chunks = <List<int>>[];
  for (var i = 0; i < bytes.length; i += maxSize) {
    final end = (i + maxSize < bytes.length) ? i + maxSize : bytes.length;
    chunks.add(bytes.sublist(i, end));
  }
  return chunks;
}

// ---------------------------------------------------------------------------
void main() {
  group('HardwareWalletAccount', () {
    group('shortAddress', () {
      test('long address is truncated to first8...last6 format', () {
        const addr = '0x1234567890abcdef1234567890abcdef12345678';
        final account = HardwareWalletAccount(
          address: addr,
          coinType: 'ETH',
          derivationPath: "m/44'/60'/0'/0/0",
        );

        final short = account.shortAddress;
        expect(short, '0x123456...345678');
        expect(short, contains('...'));
        expect(short.length, lessThan(addr.length));
      });

      test('short address (≤14 chars) is returned as-is', () {
        final account = HardwareWalletAccount(
          address: '0x1234',
          coinType: 'ETH',
          derivationPath: "m/44'/60'/0'/0/0",
        );
        expect(account.shortAddress, '0x1234');
      });

      test('exactly 14 char address is returned unchanged', () {
        const addr = '0x12345678ABCD'; // 14 chars
        final account = HardwareWalletAccount(
          address: addr,
          coinType: 'ETH',
          derivationPath: "m/44'/60'/0'/0/0",
        );
        expect(account.shortAddress, addr);
      });
    });

    group('displayName', () {
      test('returns name when provided', () {
        final account = HardwareWalletAccount(
          address: '0xAddr',
          coinType: 'ETH',
          derivationPath: "m/44'/60'/0'/0/0",
          name: 'My Main Account',
          index: 0,
        );
        expect(account.displayName, 'My Main Account');
      });

      test('returns "coinType Account N+1" when name is null', () {
        final account = HardwareWalletAccount(
          address: '0xAddr',
          coinType: 'ETH',
          derivationPath: "m/44'/60'/0'/0/3",
          index: 3,
        );
        expect(account.displayName, 'ETH Account 4');
      });

      test('index 0 displays as "Account 1"', () {
        final account = HardwareWalletAccount(
          address: '0xAddr',
          coinType: 'BTC',
          derivationPath: "m/84'/0'/0'/0/0",
          index: 0,
        );
        expect(account.displayName, 'BTC Account 1');
      });
    });

    group('fromJson / toJson round-trip', () {
      test('all fields survive round-trip', () {
        final json = {
          'address': '0x1234567890abcdef1234567890abcdef12345678',
          'coinType': 'ETH',
          'derivationPath': "m/44'/60'/0'/0/0",
          'name': 'Primary',
          'index': 2,
        };
        final account = HardwareWalletAccount.fromJson(json);
        final result = account.toJson();

        expect(result['address'], json['address']);
        expect(result['coinType'], json['coinType']);
        expect(result['derivationPath'], json['derivationPath']);
        expect(result['name'], json['name']);
        expect(result['index'], json['index']);
      });
    });
  });

  // -------------------------------------------------------------------------
  group('HardwareWalletSignResponse', () {
    group('.success() factory', () {
      test('success field is true', () {
        final resp = HardwareWalletSignResponse.success(
            signature: '0xSig', txHash: '0xHash');
        expect(resp.success, isTrue);
      });

      test('signature is set', () {
        final resp =
            HardwareWalletSignResponse.success(signature: '0xMySig');
        expect(resp.signature, '0xMySig');
      });

      test('txHash is optional', () {
        final resp =
            HardwareWalletSignResponse.success(signature: '0xSig');
        expect(resp.txHash, isNull);
      });

      test('error field is null on success', () {
        final resp =
            HardwareWalletSignResponse.success(signature: '0xSig');
        expect(resp.error, isNull);
      });
    });

    group('.error() factory', () {
      test('success field is false', () {
        final resp = HardwareWalletSignResponse.error('Device locked');
        expect(resp.success, isFalse);
      });

      test('error message is stored', () {
        final resp = HardwareWalletSignResponse.error('Signing failed');
        expect(resp.error, 'Signing failed');
      });

      test('signature is null on error', () {
        final resp = HardwareWalletSignResponse.error('Error');
        expect(resp.signature, isNull);
      });
    });
  });

  // -------------------------------------------------------------------------
  group('HardwareWalletError.userFriendlyMessage', () {
    final cases = {
      HardwareWalletError.bluetoothDisabled:
          'Please enable Bluetooth on your device',
      HardwareWalletError.deviceNotFound: 'Hardware wallet not found',
      HardwareWalletError.connectionFailed: 'Failed to connect',
      HardwareWalletError.connectionTimeout: 'Connection timed out',
      HardwareWalletError.appNotOpen: 'Please open the corresponding app',
      HardwareWalletError.userRejected: 'Transaction was rejected',
      HardwareWalletError.signingFailed: 'Failed to sign transaction',
      HardwareWalletError.invalidTransaction: 'Invalid transaction data',
      HardwareWalletError.deviceLocked: 'Hardware wallet is locked',
      HardwareWalletError.unsupportedCoin: 'This coin is not supported',
    };

    for (final entry in cases.entries) {
      test('code "${entry.key}" contains expected message fragment', () {
        final error = HardwareWalletError(
          code: entry.key,
          message: 'raw message',
        );
        expect(
          error.userFriendlyMessage.toLowerCase(),
          contains(entry.value.toLowerCase()),
          reason:
              'error code ${entry.key} should produce message containing "${entry.value}"',
        );
      });
    }

    test('unknown code returns raw message field', () {
      final error = HardwareWalletError(
        code: 'UNKNOWN_ERROR_CODE',
        message: 'Custom raw message',
      );
      expect(error.userFriendlyMessage, 'Custom raw message');
    });
  });

  // -------------------------------------------------------------------------
  group('LedgerApps.getAppName', () {
    test('ETH → Ethereum', () {
      expect(LedgerApps.getAppName('ETH'), LedgerApps.ethereum);
      expect(LedgerApps.getAppName('ETH'), 'Ethereum');
    });

    test('BNB → Ethereum (same app)', () {
      expect(LedgerApps.getAppName('BNB'), 'Ethereum');
    });

    test('MATIC → Ethereum', () {
      expect(LedgerApps.getAppName('MATIC'), 'Ethereum');
    });

    test('BTC → Bitcoin', () {
      expect(LedgerApps.getAppName('BTC'), 'Bitcoin');
    });

    test('LTC → Bitcoin', () {
      expect(LedgerApps.getAppName('LTC'), 'Bitcoin');
    });

    test('SOL → Solana', () {
      expect(LedgerApps.getAppName('SOL'), 'Solana');
    });

    test('ATOM → Cosmos', () {
      expect(LedgerApps.getAppName('ATOM'), 'Cosmos');
    });

    test('DOT → Polkadot', () {
      expect(LedgerApps.getAppName('DOT'), 'Polkadot');
    });

    test('TRX → Tron', () {
      expect(LedgerApps.getAppName('TRX'), 'Tron');
    });

    test('unknown coin → null', () {
      expect(LedgerApps.getAppName('UNKNOWN_COIN'), isNull);
      expect(LedgerApps.getAppName('XRP'), isNull);
    });

    test('input is case-insensitive (lowercased)', () {
      // The implementation calls toUpperCase() internally
      expect(LedgerApps.getAppName('eth'), 'Ethereum');
      expect(LedgerApps.getAppName('btc'), 'Bitcoin');
    });
  });

  // -------------------------------------------------------------------------
  group('HardwareWalletDevice.copyWith', () {
    final base = HardwareWalletDevice(
      id: 'dev-001',
      name: 'Ledger Nano X',
      type: HardwareWalletType.ledgerNanoX,
      firmwareVersion: '2.1.0',
      isConnected: false,
    );

    test('copyWith with no args returns equivalent device', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.name, base.name);
      expect(copy.type, base.type);
      expect(copy.isConnected, base.isConnected);
    });

    test('copyWith overrides isConnected', () {
      final connected = base.copyWith(isConnected: true);
      expect(connected.isConnected, isTrue);
      expect(connected.id, base.id); // unchanged
    });

    test('copyWith overrides firmwareVersion', () {
      final updated = base.copyWith(firmwareVersion: '2.2.0');
      expect(updated.firmwareVersion, '2.2.0');
    });

    test('copyWith does not mutate original', () {
      base.copyWith(isConnected: true, name: 'Changed');
      expect(base.isConnected, isFalse);
      expect(base.name, 'Ledger Nano X');
    });
  });

  // -------------------------------------------------------------------------
  group('BIP-32 derivation path utilities', () {
    group('parseBip32Path', () {
      test("m/44'/60'/0'/0/0 produces correct component values", () {
        final components = parseBip32Path("m/44'/60'/0'/0/0");

        // Hardened: 44 + 0x80000000
        expect(components[0], 44 + 0x80000000);
        // Hardened: 60 + 0x80000000
        expect(components[1], 60 + 0x80000000);
        // Hardened: 0 + 0x80000000
        expect(components[2], 0 + 0x80000000);
        // Non-hardened: 0
        expect(components[3], 0);
        // Non-hardened: 0
        expect(components[4], 0);
      });

      test("m/84'/0'/0'/0/0 (BTC native segwit) produces 5 components", () {
        final components = parseBip32Path("m/84'/0'/0'/0/0");
        expect(components.length, 5);
        expect(components[0], 84 + 0x80000000);
      });

      test('non-hardened index at end is correct', () {
        final components = parseBip32Path("m/44'/60'/0'/0/5");
        expect(components[4], 5);
      });

      test('throws ArgumentError for path not starting with "m"', () {
        expect(() => parseBip32Path("44'/60'/0'/0/0"), throwsArgumentError);
      });

      test('path with index > 0 for account level', () {
        final components = parseBip32Path("m/44'/60'/2'/0/0");
        expect(components[2], 2 + 0x80000000);
      });
    });

    group('chunkBytes', () {
      test('empty list returns empty list of chunks', () {
        expect(chunkBytes([]), isEmpty);
      });

      test('list shorter than maxSize returns one chunk', () {
        final bytes = List.generate(100, (i) => i);
        final chunks = chunkBytes(bytes, maxSize: 255);
        expect(chunks.length, 1);
        expect(chunks[0], bytes);
      });

      test('list exactly maxSize returns one chunk', () {
        final bytes = List.generate(255, (i) => i % 256);
        final chunks = chunkBytes(bytes, maxSize: 255);
        expect(chunks.length, 1);
      });

      test('list longer than maxSize is split into multiple chunks', () {
        final bytes = List.generate(300, (i) => i % 256);
        final chunks = chunkBytes(bytes, maxSize: 255);
        expect(chunks.length, 2);
        expect(chunks[0].length, 255);
        expect(chunks[1].length, 45);
      });

      test('all chunks together reconstruct the original list', () {
        final bytes = List.generate(600, (i) => i % 256);
        final chunks = chunkBytes(bytes, maxSize: 255);
        final reconstructed = chunks.expand((c) => c).toList();
        expect(reconstructed, bytes);
      });

      test('custom maxSize is respected', () {
        final bytes = List.generate(10, (i) => i);
        final chunks = chunkBytes(bytes, maxSize: 3);
        expect(chunks.length, 4); // 3+3+3+1
        expect(chunks[0].length, 3);
        expect(chunks[3].length, 1);
      });
    });
  });
}
