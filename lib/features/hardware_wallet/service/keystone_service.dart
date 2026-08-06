// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:typed_data';

import 'package:blockchain_utils/utils/binary/utils.dart';

import '../crypto/ur_codec.dart';
import '../crypto/ur_fountain.dart';
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
  // ==================== 多帧（fountain）支持 ====================

  /// 为展示侧构造动画 QR 编码器。
  ///
  /// 传入 build*Request 产出的单帧 UR：payload 不超过 [maxFragmentLen]
  /// 时 [UrEncoder.isSinglePart] 为 true（静态展示即可）；超过则由
  /// fountain 分帧，UI 以定时器轮播 `nextPart()` 直到对端扫毕。
  UrEncoder createUrEncoder(String singlePartUr, {int maxFragmentLen = 200}) {
    final decoded = UrCodec.decode(singlePartUr);
    return UrEncoder(
      decoded.type,
      decoded.data,
      maxFragmentLen: maxFragmentLen,
    );
  }

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
      typedDataJson: Uint8List.fromList(utf8.encode(typedDataJson)),
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
    final messageBytes = Uint8List.fromList(utf8.encode(message));
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
      return HardwareWalletSignResponse.success(signature: sig.signatureHex);
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
    // 精确取出 type 段比较：前缀匹配会把 'eth-signature-xxx'
    // 之类的其他类型误判通过。
    final typeEnd = lower.indexOf('/', 3);
    final type = typeEnd > 0 ? lower.substring(3, typeEnd) : lower.substring(3);
    if (type != 'eth-signature') {
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
    // fingerprint 缺失时回退 xpub 前缀；xpub 不足 8 字符不得 substring 越界
    final fallback = xpub.length >= 8 ? xpub.substring(0, 8) : xpub;
    final id = 'keystone_${masterFingerprint ?? fallback}';
    return HardwareWalletDevice(
      id: id,
      name: deviceName,
      type: HardwareWalletType.keystoneModel,
      isConnected: true,
      lastConnectedAt: DateTime.now(),
    );
  }
}

/// 多帧扫码会话：把逐帧扫码结果喂给 [receive]，同时兼容单帧 UR 与
/// fountain 多帧动画 QR（Keystone 大 payload，如 crypto-account 同步）。
///
/// 完成后 [completedUr] 重建为单帧 UR 字符串，直接交给既有的
/// `parseEthSignature` / `parseSyncQr` 解析——单帧与多帧共用一条
/// 解析与校验路径。
class KeystoneScanSession {
  final UrDecoder _decoder = UrDecoder();
  String? _lastRaw;

  bool get isComplete => _decoder.isComplete;

  /// 首帧到达后为总帧数；此前为 null
  int? get expectedPartCount => _decoder.expectedPartCount;

  /// 已集齐的纯片段数
  int get receivedPartCount => _decoder.receivedPartCount;

  /// [0,1] 估算进度（完成恒为 1）
  double get progress => _decoder.estimatedPercentComplete;

  /// 解码失败原因（校验和不匹配等）；正常进行中为 null
  String? get error => _decoder.error;

  /// 喂入一帧扫码结果；返回该帧是否被采纳。
  /// 动画 QR 连续识别到同一帧时直接忽略（返回 false）。
  bool receive(String raw) {
    if (raw == _lastRaw) return false;
    _lastRaw = raw;
    return _decoder.receivePart(raw);
  }

  /// 完成后重建单帧 UR（未完成或解码失败返回 null）
  String? get completedUr {
    final r = _decoder.result;
    if (r == null) return null;
    return UrCodec.encode(r.type, r.data);
  }
}
