// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/services.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

import '../models/hardware_wallet_models.dart';

/// Service for interacting with Trezor hardware wallets via USB.
///
/// Communicates with the native platform (iOS/Android) through
/// `MethodChannel('hardware_wallet')` using `trezor_`-prefixed method names.
///
/// Native-side responsibilities:
/// - USB HID transport via TrezorLink (Android) or TrezorKit (iOS)
/// - Protobuf message encoding/decoding
/// - Device enumeration and selection
///
/// This Dart layer provides a clean, typed async API that abstracts away the
/// native transport details.
class TrezorService {
  static const MethodChannel _channel = MethodChannel('hardware_wallet');

  /// Connect to a Trezor device via USB.
  ///
  /// Returns a [HardwareWalletDevice] on success.
  /// Throws [HardwareWalletError] on failure.
  Future<HardwareWalletDevice> connect() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'trezor_connect',
      );
      if (result == null) {
        throw HardwareWalletError(
          code: HardwareWalletError.connectionFailed,
          message: 'Trezor connect returned null',
        );
      }
      return _parseDeviceInfo(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  /// Disconnect from the currently connected Trezor device.
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod<void>('trezor_disconnect');
    } on PlatformException catch (e) {
      AppLogger.w('TrezorService', 'disconnect error: ${e.message}');
    }
  }

  /// Get the address for a given coin at the specified derivation path.
  ///
  /// [coinType] e.g. `'ETH'`, `'BTC'`, `'SOL'`
  /// [derivationPath] e.g. `"m/44'/60'/0'/0/0"`
  /// [display] if `true`, the address is shown on the device for confirmation
  Future<String?> getAddress({
    required String coinType,
    required String derivationPath,
    bool display = false,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('trezor_getAddress', {
        'coinType': coinType.toUpperCase(),
        'derivationPath': derivationPath,
        'display': display,
      });
      return result;
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  /// Sign an Ethereum transaction.
  ///
  /// [derivationPath] e.g. `"m/44'/60'/0'/0/0"`
  /// [txData] map with keys: nonce, gasPrice OR (maxFeePerGas + maxPriorityFeePerGas),
  ///   gasLimit, to, value, data, chainId
  Future<HardwareWalletSignResponse> signEthTransaction({
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) async {
    return _invokeSign('trezor_signEthTx', {
      'derivationPath': derivationPath,
      'txData': txData,
    });
  }

  /// Sign a Bitcoin transaction (PSBT).
  ///
  /// [psbtHex] hex-encoded PSBT bytes
  Future<HardwareWalletSignResponse> signBtcTransaction({
    required String derivationPath,
    required String psbtHex,
  }) async {
    return _invokeSign('trezor_signBtcTx', {
      'derivationPath': derivationPath,
      'psbtHex': psbtHex,
    }, signatureKey: 'signedPsbtHex');
  }

  /// Sign a Solana transaction.
  ///
  /// [txBase64] base64-encoded serialized Solana transaction
  Future<HardwareWalletSignResponse> signSolanaTransaction({
    required String derivationPath,
    required String txBase64,
  }) async {
    return _invokeSign('trezor_signSolTx', {
      'derivationPath': derivationPath,
      'txBase64': txBase64,
    });
  }

  /// Sign an EIP-712 typed data payload.
  Future<HardwareWalletSignResponse> signTypedData({
    required String derivationPath,
    required String typedDataJson,
  }) async {
    return _invokeSign('trezor_signTypedData', {
      'derivationPath': derivationPath,
      'typedDataJson': typedDataJson,
    });
  }

  /// Sign a personal_sign message.
  Future<HardwareWalletSignResponse> signMessage({
    required String derivationPath,
    required Uint8List messageBytes,
  }) async {
    return _invokeSign('trezor_signMessage', {
      'derivationPath': derivationPath,
      'messageHex': messageBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
    });
  }

  /// Sign a generic chain transaction (ATOM, DOT, TRX, etc.)
  Future<HardwareWalletSignResponse> signChainTransaction({
    required String coinType,
    required String derivationPath,
    required Map<String, dynamic> txData,
  }) async {
    return _invokeSign('trezor_signChainTx', {
      'coinType': coinType.toUpperCase(),
      'derivationPath': derivationPath,
      'txData': txData,
    });
  }

  /// Check if a Trezor device is currently connected via USB
  Future<bool> isConnected() async {
    try {
      return await _channel.invokeMethod<bool>('trezor_isConnected') ?? false;
    } on PlatformException {
      return false;
    }
  }

  // ==================== Private helpers ====================

  /// Common sign invocation: calls [method] with [args], extracts signature
  /// from [signatureKey] (default `'signature'`) and optional `txHash`.
  Future<HardwareWalletSignResponse> _invokeSign(
    String method,
    Map<String, dynamic> args, {
    String signatureKey = 'signature',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        method,
        args,
      );
      if (result == null) {
        return HardwareWalletSignResponse.error('No signature returned');
      }
      final map = Map<String, dynamic>.from(result);
      return HardwareWalletSignResponse.success(
        signature: map[signatureKey] as String? ?? '',
        txHash: map['txHash'] as String?,
      );
    } on PlatformException catch (e) {
      final err = _mapPlatformException(e);
      return HardwareWalletSignResponse.error(err.userFriendlyMessage);
    }
  }

  static const _trezorOneTypes = {'trezor_one', 'trezorone', '1'};

  HardwareWalletDevice _parseDeviceInfo(Map<String, dynamic> result) {
    final typeStr = result['type'] as String? ?? 'trezorModelT';
    final type = _trezorOneTypes.contains(typeStr.toLowerCase())
        ? HardwareWalletType.trezorOne
        : HardwareWalletType.trezorModelT;

    return HardwareWalletDevice(
      id: result['id'] as String? ?? 'trezor_usb',
      name: result['name'] as String? ?? 'Trezor',
      type: type,
      firmwareVersion: result['firmware'] as String?,
      isConnected: true,
      lastConnectedAt: DateTime.now(),
    );
  }

  HardwareWalletError _mapPlatformException(PlatformException e) {
    final code = e.code;
    switch (code) {
      case 'TREZOR_NOT_FOUND':
        return HardwareWalletError(
          code: HardwareWalletError.deviceNotFound,
          message: e.message ?? 'Trezor not found',
        );
      case 'TREZOR_PIN_REQUIRED':
        return HardwareWalletError(
          code: HardwareWalletError.connectionFailed,
          message: e.message ?? 'PIN required',
          details: 'pin_required',
        );
      case 'TREZOR_PASSPHRASE_REQUIRED':
        return HardwareWalletError(
          code: HardwareWalletError.connectionFailed,
          message: e.message ?? 'Passphrase required',
          details: 'passphrase_required',
        );
      case 'USER_REJECTED':
      case 'TREZOR_USER_REJECTED':
        return HardwareWalletError(
          code: HardwareWalletError.userRejected,
          message: e.message ?? 'User rejected on device',
        );
      case 'USB_PERMISSION_DENIED':
        return HardwareWalletError(
          code: HardwareWalletError.connectionFailed,
          message: e.message ?? 'USB permission denied',
          details: 'usb_permission',
        );
      default:
        return HardwareWalletError(
          code: HardwareWalletError.connectionFailed,
          message: e.message ?? 'Trezor error: $code',
          details: e.details?.toString(),
        );
    }
  }
}
