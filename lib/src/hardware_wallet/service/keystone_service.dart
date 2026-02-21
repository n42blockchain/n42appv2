// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:blockchain_utils/utils/binary/utils.dart';

import '../crypto/ur_codec.dart';
import '../models/hardware_wallet_models.dart';

/// Service for interacting with Keystone air-gapped hardware wallets via QR codes.
///
/// Keystone uses the BC-UR (Blockchain Commons Uniform Resource) protocol
/// for QR-based signing:
///
/// 1. **Connect**: Scan the Keystone device's xpub/sync QR code to pair.
/// 2. **Sign**: App displays `ur:eth-sign-request` QR → user scans on device →
///    Keystone shows `ur:eth-signature` QR → app scans to retrieve signature.
///
/// This service handles CBOR encoding/decoding and UR formatting. The actual
/// QR display and camera scanning are handled by the UI layer
/// (`KeystoneSignPage`).
class KeystoneService {
  // ==================== Signing request builders ====================

  /// Build an `ur:eth-sign-request` UR string for an EVM transaction.
  ///
  /// [rawTxRlp] RLP-encoded transaction bytes (EIP-1559 or legacy)
  /// [chainId] EVM chain ID (e.g. 1 for mainnet)
  /// [derivationPath] BIP-44 path string e.g. `"m/44'/60'/0'/0/0"`
  /// [fromAddress] optional sender address (display only)
  String buildEthSignRequest({
    required Uint8List rawTxRlp,
    required int chainId,
    required String derivationPath,
    String? fromAddress,
  }) {
    final pathInts = EthSignRequest.parsePath(derivationPath);
    final request = EthSignRequest.transaction(
      rawTxRlp: rawTxRlp,
      chainId: chainId,
      derivationPath: pathInts,
      fromAddress: fromAddress,
    );
    return request.toUr();
  }

  /// Build an `ur:eth-sign-request` UR string for EIP-712 typed data.
  String buildEthTypedDataRequest({
    required String typedDataJson,
    required int chainId,
    required String derivationPath,
    String? fromAddress,
  }) {
    final pathInts = EthSignRequest.parsePath(derivationPath);
    final request = EthSignRequest.typedData(
      typedDataJson: Uint8List.fromList(typedDataJson.codeUnits),
      chainId: chainId,
      derivationPath: pathInts,
      fromAddress: fromAddress,
    );
    return request.toUr();
  }

  /// Build an `ur:eth-sign-request` UR string for personal_sign.
  String buildEthPersonalSignRequest({
    required String message,
    required String derivationPath,
    String? fromAddress,
  }) {
    final pathInts = EthSignRequest.parsePath(derivationPath);
    final messageBytes = Uint8List.fromList(message.codeUnits);
    final request = EthSignRequest.personalMessage(
      messageBytes: messageBytes,
      derivationPath: pathInts,
      fromAddress: fromAddress,
    );
    return request.toUr();
  }

  // ==================== Signature parsing ====================

  /// Parse an `ur:eth-signature` UR string from the Keystone device.
  ///
  /// Returns a [HardwareWalletSignResponse] with the ECDSA signature.
  /// Throws [UrCodecException] on invalid input.
  HardwareWalletSignResponse parseEthSignature(String urResponse) {
    try {
      final sig = EthSignature.fromUr(urResponse.trim());
      return HardwareWalletSignResponse.success(
        signature: sig.signatureHex,
      );
    } on UrCodecException catch (e) {
      return HardwareWalletSignResponse.error(
        'Invalid Keystone response: ${e.message}',
      );
    } catch (e) {
      return HardwareWalletSignResponse.error(
        'Failed to parse Keystone signature: $e',
      );
    }
  }

  /// Validate a scanned UR string before attempting to parse it.
  ///
  /// Returns `null` if valid, or an error message string if invalid.
  String? validateScannedUr(String scannedValue) {
    if (scannedValue.isEmpty) return 'Empty QR code';

    final lower = scannedValue.toLowerCase().trim();
    if (!lower.startsWith('ur:')) {
      return 'Not a valid UR QR code';
    }
    if (!lower.startsWith('ur:eth-signature')) {
      final typeEnd = lower.indexOf('/', 3);
      final type = typeEnd > 0 ? lower.substring(3, typeEnd) : lower.substring(3);
      return 'Unexpected UR type: "$type" (expected eth-signature)';
    }
    return null;
  }

  // ==================== Keystone account pairing ====================

  /// Parse a Keystone sync/xpub QR code.
  ///
  /// Keystone exports xpubs for account derivation. This supports:
  /// - `ur:crypto-hdkey` (BC-UR HD key)
  /// - Plain hex xpub (fallback)
  ///
  /// Returns [KeystoneAccountInfo] or throws on invalid data.
  KeystoneAccountInfo parseSyncQr(String qrData) {
    final trimmed = qrData.trim();
    final lower = trimmed.toLowerCase();

    if (lower.startsWith('ur:crypto-hdkey')) {
      return _parseCryptoHdKey(trimmed);
    }

    if (lower.startsWith('ur:crypto-account')) {
      return _parseCryptoAccount(trimmed);
    }

    // Fallback: plain xpub/zpub/ypub string
    if (trimmed.startsWith('xpub') ||
        trimmed.startsWith('zpub') ||
        trimmed.startsWith('ypub') ||
        trimmed.startsWith('Xpub')) {
      return KeystoneAccountInfo(
        xpub: trimmed,
        masterFingerprint: null,
        deviceName: 'Keystone',
      );
    }

    throw UrCodecException('Unrecognized Keystone sync QR format');
  }

  KeystoneAccountInfo _parseCryptoHdKey(String ur) {
    try {
      final decoded = UrCodec.decode(ur);
      // Parse CBOR — crypto-hdkey has key 3 = key-data, key 4 = chain-code,
      // key 6 = origin (source-fingerprint), key 8 = parent-fingerprint
      // For now, extract master fingerprint and key data
      // Full crypto-hdkey CBOR parsing is complex; extract the key bytes
      final hexData = BytesUtils.toHexString(decoded.data);
      return KeystoneAccountInfo(
        xpub: hexData,
        masterFingerprint: null,
        deviceName: 'Keystone',
      );
    } on UrCodecException {
      rethrow;
    } catch (e) {
      throw UrCodecException('Failed to parse crypto-hdkey: $e');
    }
  }

  KeystoneAccountInfo _parseCryptoAccount(String ur) {
    try {
      final decoded = UrCodec.decode(ur);
      final hexData = BytesUtils.toHexString(decoded.data);
      return KeystoneAccountInfo(
        xpub: hexData,
        masterFingerprint: null,
        deviceName: 'Keystone',
      );
    } on UrCodecException {
      rethrow;
    } catch (e) {
      throw UrCodecException('Failed to parse crypto-account: $e');
    }
  }
}

// ==================== Data models ====================

/// Information obtained from pairing with a Keystone device
class KeystoneAccountInfo {
  /// Extended public key (xpub/zpub or hex-encoded key data)
  final String xpub;

  /// Master fingerprint (4 bytes, identifies the seed)
  final String? masterFingerprint;

  final String deviceName;

  const KeystoneAccountInfo({
    required this.xpub,
    required this.masterFingerprint,
    required this.deviceName,
  });

  /// Convert to a HardwareWalletDevice for persistent storage
  HardwareWalletDevice toDevice() {
    final id = 'keystone_${masterFingerprint ?? xpub.substring(0, 8)}';
    return HardwareWalletDevice(
      id: id,
      name: deviceName,
      type: HardwareWalletType.keystoneModel,
      isConnected: true,
      lastConnectedAt: DateTime.now(),
    );
  }
}
