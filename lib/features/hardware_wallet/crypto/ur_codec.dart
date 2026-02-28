// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/uuid/uuid.dart';
import 'package:flutter/foundation.dart' show listEquals;

/// BC-UR (Uniform Resource) codec implementation
///
/// Implements the Blockchain Commons Uniform Resource encoding standard
/// used by Keystone and other air-gapped hardware wallets for QR-code
/// signing protocols.
///
/// Reference: https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md
///
/// Encoding pipeline:
///   CBOR data  →  CRC-32 appended  →  Bytewords  →  UR string
/// Decoding pipeline:
///   UR string  →  Bytewords decode  →  CRC-32 verify+strip  →  CBOR data
class UrCodec {
  UrCodec._();

  // ==================== Bytewords Table ====================

  /// Full bytewords word list (256 entries, BC-UR spec §2.1).
  /// Each byte (0-255) maps to a unique 4-letter lowercase English word.
  static const List<String> _wordList = [
    'able', 'acid', 'also', 'apex', 'aqua', 'arch', 'atom', 'aunt',
    'awry', 'axis', 'back', 'ball', 'barn', 'belt', 'beta', 'bias',
    'blue', 'body', 'boos', 'brew', 'brisk', 'bulb', 'buzz', 'calm',
    'cash', 'cats', 'chat', 'city', 'clap', 'clay', 'club', 'code',
    'cola', 'cook', 'cost', 'crux', 'curl', 'cusp', 'cyan', 'dark',
    'data', 'days', 'daze', 'dead', 'deal', 'dear', 'deck', 'deep',
    'deli', 'dice', 'diet', 'diff', 'digs', 'dunk', 'dusk', 'dust',
    'duty', 'each', 'edge', 'epic', 'even', 'exam', 'exit', 'eyes',
    'fact', 'fair', 'fern', 'figs', 'film', 'fine', 'fist', 'fizz',
    'flap', 'flew', 'flit', 'flow', 'flux', 'foxy', 'free', 'frog',
    'fuel', 'fund', 'gala', 'game', 'gems', 'gift', 'girl', 'glow',
    'good', 'gray', 'grim', 'grip', 'gush', 'gyro', 'half', 'hang',
    'hard', 'hawk', 'heat', 'high', 'hill', 'holy', 'hope', 'horn',
    'huts', 'icon', 'idea', 'inch', 'into', 'iron', 'item', 'jade',
    'jolt', 'jowl', 'judo', 'jugs', 'jump', 'junk', 'jury', 'keep',
    'keys', 'kick', 'kiln', 'king', 'kite', 'kiwi', 'knob', 'lamb',
    'lava', 'lazy', 'leaf', 'lean', 'left', 'legs', 'liar', 'lids',
    'limp', 'lion', 'list', 'logo', 'loud', 'love', 'luck', 'lung',
    'main', 'many', 'math', 'maze', 'mean', 'memo', 'menu', 'meow',
    'mild', 'mint', 'miss', 'monk', 'moon', 'more', 'most', 'move',
    'much', 'muse', 'musk', 'myth', 'navy', 'need', 'noon', 'nose',
    'note', 'numb', 'obey', 'oboe', 'odd', 'omen', 'open', 'oval',
    'owls', 'pact', 'paid', 'part', 'past', 'pave', 'pear', 'perp',
    'pick', 'pink', 'pipe', 'plan', 'play', 'plus', 'poem', 'pool',
    'pose', 'post', 'puff', 'pump', 'puns', 'puny', 'purr', 'quad',
    'quiz', 'race', 'ramp', 'real', 'redo', 'reef', 'rich', 'road',
    'rock', 'roof', 'room', 'ruin', 'runs', 'rust', 'safe', 'saga',
    'sand', 'scar', 'sets', 'silk', 'skew', 'slot', 'soap', 'solo',
    'some', 'song', 'sort', 'stab', 'stew', 'stop', 'stub', 'such',
    'surf', 'swan', 'taco', 'tail', 'task', 'taxi', 'tent', 'tied',
    'time', 'tiny', 'toil', 'tomb', 'tops', 'torq', 'town', 'trap',
    'tray', 'trim', 'trip', 'tuck', 'tuft', 'tuna', 'twin', 'ugly',
    'undo', 'unit', 'unto', 'urge', 'user', 'veto', 'vial', 'view',
    'visa', 'void', 'vows', 'waxy', 'webs', 'what', 'when', 'whiz',
    'wolf', 'work', 'yank', 'yawn', 'yell', 'yoga', 'yurt', 'zaps',
    'zeal', 'zero', 'zest', 'zinc', 'zone', 'zoom',
  ];

  /// Build reverse lookup map (word → byte value)
  static final Map<String, int> _wordToIndex = () {
    final m = <String, int>{};
    for (var i = 0; i < _wordList.length; i++) {
      m[_wordList[i]] = i;
    }
    return m;
  }();

  // ==================== CRC-32 ====================

  /// CRC-32 lookup table (ISO 3309 / ITU-T V.42 polynomial 0xEDB88320)
  static final Uint32List _crc32Table = _buildCrc32Table();

  static Uint32List _buildCrc32Table() {
    final table = Uint32List(256);
    for (var i = 0; i < 256; i++) {
      var c = i;
      for (var j = 0; j < 8; j++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      }
      table[i] = c;
    }
    return table;
  }

  /// Compute CRC-32 checksum (returns big-endian bytes)
  static Uint8List crc32Bytes(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc = _crc32Table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    final value = (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
    return Uint8List(4)
      ..[0] = (value >> 24) & 0xFF
      ..[1] = (value >> 16) & 0xFF
      ..[2] = (value >> 8) & 0xFF
      ..[3] = value & 0xFF;
  }

  // ==================== Bytewords encode/decode ====================

  /// Encode bytes to bytewords string (space-separated full words)
  static String bytewordsEncode(Uint8List data) {
    return data.map((byte) => _wordList[byte]).join(' ');
  }

  /// Decode bytewords string to bytes
  ///
  /// Throws [UrCodecException] if any word is not in the word list.
  static Uint8List bytewordsDecode(String encoded) {
    final words = encoded.toLowerCase().trim().split(RegExp(r'\s+'));
    final result = Uint8List(words.length);
    for (var i = 0; i < words.length; i++) {
      final idx = _wordToIndex[words[i]];
      if (idx == null) {
        throw UrCodecException('Unknown byteword: "${words[i]}"');
      }
      result[i] = idx;
    }
    return result;
  }

  // ==================== UR encode/decode ====================

  /// Encode CBOR data as a UR string.
  ///
  /// Result format: `UR:{TYPE}/{bytewords(data + crc32)}`
  ///
  /// [type] should be lowercase, e.g. `'eth-sign-request'`
  static String encode(String type, Uint8List data) {
    final checksum = crc32Bytes(data);
    final payload = Uint8List(data.length + 4);
    payload.setRange(0, data.length, data);
    payload.setRange(data.length, data.length + 4, checksum);

    final encoded = bytewordsEncode(payload);
    return 'UR:${type.toUpperCase()}/$encoded';
  }

  /// Decode a UR string.
  ///
  /// Returns a record `{type: String, data: Uint8List}`.
  /// Throws [UrCodecException] on malformed input or CRC mismatch.
  static ({String type, Uint8List data}) decode(String ur) {
    final lower = ur.toLowerCase().trim();
    if (!lower.startsWith('ur:')) {
      throw UrCodecException('Not a UR string: missing "UR:" prefix');
    }

    final withoutPrefix = lower.substring(3); // strip 'ur:'
    final slashIdx = withoutPrefix.indexOf('/');
    if (slashIdx < 0) {
      throw UrCodecException('Invalid UR: missing "/" separator');
    }

    final type = withoutPrefix.substring(0, slashIdx);
    final bodyStr = withoutPrefix.substring(slashIdx + 1);

    // Multi-part UR: skip  (e.g. "1-of-3/body" — not supported yet)
    final multipartMatch = RegExp(r'^\d+-of-\d+/(.+)$').firstMatch(bodyStr);
    final encodedBody = multipartMatch != null ? multipartMatch.group(1)! : bodyStr;

    final payload = bytewordsDecode(encodedBody);
    if (payload.length < 4) {
      throw UrCodecException('UR payload too short (missing CRC)');
    }

    final data = Uint8List.sublistView(payload, 0, payload.length - 4);
    final receivedCrc = Uint8List.sublistView(payload, payload.length - 4);
    final expectedCrc = crc32Bytes(data);

    if (!listEquals(receivedCrc, expectedCrc)) {
      throw UrCodecException('CRC-32 mismatch: data may be corrupted');
    }

    return (type: type, data: data);
  }
}

// ==================== Keystone eth-sign-request ====================

/// CBOR map keys for eth-sign-request (BC-UR registry)
class EthSignRequestKeys {
  static const int requestId = 1;
  static const int signData = 2;
  static const int dataType = 3;
  static const int chainId = 4;
  static const int derivationPath = 5;
  static const int address = 6;
  static const int origin = 7;
}

/// Data type for eth-sign-request
enum EthSignDataType {
  transaction(1),
  typedData(2),
  personalMessage(3);

  const EthSignDataType(this.value);
  final int value;
}

/// Represents a Keystone eth-sign-request
///
/// Encodes an ETH transaction signing request as a BC-UR `eth-sign-request`
/// CBOR structure, ready to display as a QR code on the app side.
class EthSignRequest {
  final Uint8List requestId;
  final Uint8List signData;
  final EthSignDataType dataType;
  final int? chainId;

  /// BIP-44 derivation path as integer list (hardened = 0x80000000 | index)
  final List<int> derivationPath;
  final String? address;
  final String? origin;

  const EthSignRequest({
    required this.requestId,
    required this.signData,
    required this.dataType,
    this.chainId,
    required this.derivationPath,
    this.address,
    this.origin,
  });

  /// Create a sign request for an ETH transaction
  factory EthSignRequest.transaction({
    required Uint8List rawTxRlp,
    required int chainId,
    required List<int> derivationPath,
    String? fromAddress,
    String origin = 'N42',
  }) {
    return EthSignRequest(
      requestId: _generateRequestId(),
      signData: rawTxRlp,
      dataType: EthSignDataType.transaction,
      chainId: chainId,
      derivationPath: derivationPath,
      address: fromAddress,
      origin: origin,
    );
  }

  /// Create a sign request for EIP-712 typed data
  factory EthSignRequest.typedData({
    required Uint8List typedDataJson,
    required int chainId,
    required List<int> derivationPath,
    String? fromAddress,
    String origin = 'N42',
  }) {
    return EthSignRequest(
      requestId: _generateRequestId(),
      signData: typedDataJson,
      dataType: EthSignDataType.typedData,
      chainId: chainId,
      derivationPath: derivationPath,
      address: fromAddress,
      origin: origin,
    );
  }

  /// Create a sign request for personal_sign message
  factory EthSignRequest.personalMessage({
    required Uint8List messageBytes,
    required List<int> derivationPath,
    String? fromAddress,
    String origin = 'N42',
  }) {
    return EthSignRequest(
      requestId: _generateRequestId(),
      signData: messageBytes,
      dataType: EthSignDataType.personalMessage,
      derivationPath: derivationPath,
      address: fromAddress,
      origin: origin,
    );
  }

  static Uint8List _generateRequestId() {
    // Generate a UUID v4 as 16 raw bytes
    final uuidStr = UUID.generateUUIDv4();
    // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    final hex = uuidStr.replaceAll('-', '');
    return Uint8List.fromList(BytesUtils.fromHexString(hex));
  }

  /// Parse a BIP-44 path string into derivation path array.
  ///
  /// Example: `"m/44'/60'/0'/0/0"` →
  /// `[0x8000002C, 0x8000003C, 0x80000000, 0, 0]`
  static List<int> parsePath(String path) {
    final parts = path.replaceFirst('m/', '').split('/');
    return parts.map((p) {
      final hardened = p.endsWith("'");
      final idx = int.parse(p.replaceAll("'", ''));
      return hardened ? (0x80000000 | idx) : idx;
    }).toList();
  }

  /// Encode to CBOR bytes
  Uint8List toCbor() {
    final map = <CborObject, CborObject>{
      CborIntValue(EthSignRequestKeys.requestId): CborBytesValue(requestId),
      CborIntValue(EthSignRequestKeys.signData): CborBytesValue(signData),
      CborIntValue(EthSignRequestKeys.dataType): CborIntValue(dataType.value),
    };

    if (chainId != null) {
      map[CborIntValue(EthSignRequestKeys.chainId)] = CborIntValue(chainId!);
    }

    // Derivation path as CBOR array
    map[CborIntValue(EthSignRequestKeys.derivationPath)] =
        CborListValue.definite(
          derivationPath.map((i) => CborIntValue(i) as CborObject).toList(),
        );

    if (address != null) {
      map[CborIntValue(EthSignRequestKeys.address)] =
          CborBytesValue(BytesUtils.fromHexString(
        address!.startsWith('0x') ? address!.substring(2) : address!,
      ));
    }

    if (origin != null) {
      map[CborIntValue(EthSignRequestKeys.origin)] = CborStringValue(origin!);
    }

    final cborMap = CborMapValue.definite(map);
    return Uint8List.fromList(cborMap.encode());
  }

  /// Encode as UR string (ready to display as QR code)
  String toUr() {
    return UrCodec.encode('eth-sign-request', toCbor());
  }
}

// ==================== Keystone eth-signature ====================

/// CBOR map keys for eth-signature (BC-UR registry)
class EthSignatureKeys {
  static const int requestId = 1;
  static const int signature = 2;
  static const int origin = 3;
}

/// Represents a Keystone eth-signature response
class EthSignature {
  final Uint8List requestId;
  final Uint8List signature;
  final String? origin;

  const EthSignature({
    required this.requestId,
    required this.signature,
    this.origin,
  });

  /// Parse from UR string scanned from Keystone device
  factory EthSignature.fromUr(String ur) {
    final decoded = UrCodec.decode(ur);
    if (decoded.type != 'eth-signature') {
      throw UrCodecException(
        'Expected eth-signature UR type, got: ${decoded.type}',
      );
    }
    return EthSignature.fromCbor(decoded.data);
  }

  /// Parse from raw CBOR bytes
  factory EthSignature.fromCbor(Uint8List data) {
    final cbor = CborObject.fromCbor(data.toList());
    if (cbor is! CborMapValue) {
      throw UrCodecException('eth-signature CBOR must be a map');
    }

    Uint8List? requestId;
    Uint8List? signature;
    String? origin;

    for (final entry in cbor.value.entries) {
      final key = (entry.key as CborIntValue).value;
      switch (key) {
        case EthSignatureKeys.requestId:
          requestId = Uint8List.fromList(
            (entry.value as CborBytesValue).value,
          );
        case EthSignatureKeys.signature:
          signature = Uint8List.fromList(
            (entry.value as CborBytesValue).value,
          );
        case EthSignatureKeys.origin:
          origin = (entry.value as CborStringValue).value;
      }
    }

    if (requestId == null || signature == null) {
      throw UrCodecException(
        'eth-signature missing required fields (requestId, signature)',
      );
    }

    return EthSignature(
      requestId: requestId,
      signature: signature,
      origin: origin,
    );
  }

  /// Get signature as 0x-prefixed hex string
  String get signatureHex {
    return '0x${BytesUtils.toHexString(signature)}';
  }

  /// Get v, r, s components from a 65-byte ECDSA signature
  ({int v, String r, String s}) get vrs {
    if (signature.length != 65) {
      throw UrCodecException(
        'Signature must be 65 bytes, got ${signature.length}',
      );
    }
    final r = BytesUtils.toHexString(signature.sublist(0, 32));
    final s = BytesUtils.toHexString(signature.sublist(32, 64));
    final v = signature[64];
    return (v: v, r: '0x$r', s: '0x$s');
  }
}

// ==================== Exception ====================

/// Exception for UR codec errors
class UrCodecException implements Exception {
  final String message;
  const UrCodecException(this.message);

  @override
  String toString() => 'UrCodecException: $message';
}
