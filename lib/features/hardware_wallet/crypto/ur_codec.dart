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

  /// Full bytewords word list (256 entries, BCR-2020-012).
  /// Each byte (0-255) maps to a unique 4-letter lowercase English word.
  static final List<String> _wordList = _officialWords.split(' ');

  /// BCR-2020-012 官方词表原文（32 行 × 8 词 = 256 词，索引即字节值）。
  /// 词表的 (首字母,末字母) 对同样全表唯一——这是 minimal（2 字母/字节）
  /// 编码成立的前提。修改任何一个词都会破坏与真机硬件钱包的互操作性。
  static const String _officialWords =
      'able acid also apex aqua arch atom aunt '
      'away axis back bald barn belt beta bias '
      'blue body brag brew bulb buzz calm cash '
      'cats chef city claw code cola cook cost '
      'crux curl cusp cyan dark data days deli '
      'dice diet door down draw drop drum dull '
      'duty each easy echo edge epic even exam '
      'exit eyes fact fair fern figs film fish '
      'fizz flap flew flux foxy free frog fuel '
      'fund gala game gear gems gift girl glow '
      'good gray grim guru gush gyro half hang '
      'hard hawk heat help high hill holy hope '
      'horn huts iced idea idle inch inky into '
      'iris iron item jade jazz join jolt jowl '
      'judo jugs jump junk jury keep keno kept '
      'keys kick kiln king kite kiwi knob lamb '
      'lava lazy leaf legs liar limp lion list '
      'logo loud love luau luck lung main many '
      'math maze memo menu meow mild mint miss '
      'monk nail navy need news next noon note '
      'numb obey oboe omit onyx open oval owls '
      'paid part peck play plus poem pool pose '
      'puff puma purr quad quiz race ramp real '
      'redo rich road rock roof ruby ruin runs '
      'rust safe saga scar sets silk skew slot '
      'soap solo song stub surf swan taco task '
      'taxi tent tied time tiny toil tomb toys '
      'trip tuna twin ugly undo unit urge user '
      'vast very veto vial vibe view visa void '
      'vows wall wand warm wasp wave waxy webs '
      'what when whiz wolf work yank yawn yell '
      'yoga yurt zaps zero zest zinc zone zoom';

  /// Build reverse lookup map (word → byte value)
  static final Map<String, int> _wordToIndex = {
    for (var i = 0; i < _wordList.length; i++) _wordList[i]: i,
  };

  /// (首字母+末字母) → 字节值，minimal 编码（2 字母/字节）的解码表。
  static final Map<String, int> _minimalToIndex = {
    for (var i = 0; i < _wordList.length; i++)
      '${_wordList[i][0]}${_wordList[i][3]}': i,
  };

  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// 多帧 UR 序号段：规范格式 `seq-total/`（如 `1-3/`），
  /// 兼容识别旧自有格式 `seq-of-total/`。
  static final RegExp _sequenceRegex = RegExp(r'^(\d+)-(?:of-)?(\d+)/(.+)$');

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

  /// Compute CRC-32 checksum as an unsigned 32-bit integer
  static int crc32Int(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc = _crc32Table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
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

  /// Encode bytes to bytewords string (space-separated full words,
  /// BCR-2020-012 "standard" style — 调试/展示用，UR 正文用 minimal)
  static String bytewordsEncode(Uint8List data) {
    return data.map((byte) => _wordList[byte]).join(' ');
  }

  /// Decode bytewords string to bytes (standard style)
  ///
  /// Throws [UrCodecException] if any word is not in the word list.
  static Uint8List bytewordsDecode(String encoded) {
    final words = encoded.toLowerCase().trim().split(_whitespaceRegex);
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

  /// Encode bytes to minimal bytewords（每字节 = 词的首末 2 字母，无分隔，
  /// BCR-2020-005 规定 UR 正文必须用此风格）
  static String bytewordsEncodeMinimal(Uint8List data) {
    final sb = StringBuffer();
    for (final byte in data) {
      final word = _wordList[byte];
      sb.write(word[0]);
      sb.write(word[3]);
    }
    return sb.toString();
  }

  /// Decode minimal bytewords to bytes
  ///
  /// Throws [UrCodecException] on odd length or unknown letter pair.
  static Uint8List bytewordsDecodeMinimal(String encoded) {
    final s = encoded.toLowerCase().trim();
    if (s.length.isOdd) {
      throw UrCodecException(
        'Invalid minimal bytewords: odd length ${s.length}',
      );
    }
    final result = Uint8List(s.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      final pair = s.substring(i * 2, i * 2 + 2);
      final idx = _minimalToIndex[pair];
      if (idx == null) {
        throw UrCodecException('Unknown byteword: minimal pair "$pair"');
      }
      result[i] = idx;
    }
    return result;
  }

  // ==================== UR encode/decode ====================

  /// Encode CBOR data as a UR string.
  ///
  /// Result format: `UR:{TYPE}/{minimal-bytewords(data + crc32)}`
  /// （大写输出以便 QR 使用高密度 alphanumeric 模式；UR 本身大小写不敏感）
  ///
  /// [type] should be lowercase, e.g. `'eth-sign-request'`
  static String encode(String type, Uint8List data) {
    return 'UR:${type.toUpperCase()}/${encodeBytewordsBody(data).toUpperCase()}';
  }

  /// 把 payload 编成 UR 正文：minimal bytewords(payload + CRC32)。
  /// （对应参考实现 `Bytewords::encode(minimal, ...)`，CRC 内含）
  static String encodeBytewordsBody(Uint8List data) {
    final checksum = crc32Bytes(data);
    final payload = Uint8List(data.length + 4);
    payload.setRange(0, data.length, data);
    payload.setRange(data.length, data.length + 4, checksum);
    return bytewordsEncodeMinimal(payload);
  }

  /// 解 UR 正文（minimal 或 standard bytewords），校验并剥离尾部 CRC32。
  static Uint8List decodeBytewordsBody(String body) {
    final trimmed = body.trim();
    final payload = _whitespaceRegex.hasMatch(trimmed)
        ? bytewordsDecode(trimmed)
        : bytewordsDecodeMinimal(trimmed);
    if (payload.length < 4) {
      throw UrCodecException('UR payload too short (missing CRC)');
    }
    final data = Uint8List.sublistView(payload, 0, payload.length - 4);
    final receivedCrc = Uint8List.sublistView(payload, payload.length - 4);
    final expectedCrc = crc32Bytes(data);
    if (!listEquals(receivedCrc, expectedCrc)) {
      throw UrCodecException('CRC-32 mismatch: data may be corrupted');
    }
    return data;
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
    var bodyStr = withoutPrefix.substring(slashIdx + 1).trim();

    // 多帧 UR（fountain 编码）：total==1 时片段即完整 payload，直接解；
    // total>1 需要 fountain 解码器（未实现）——显式报错优于把单个片段
    // 误当作完整消息解出错误数据。
    final seqMatch = _sequenceRegex.firstMatch(bodyStr);
    if (seqMatch != null) {
      final total = int.parse(seqMatch.group(2)!);
      if (total > 1) {
        throw UrCodecException(
          'Multi-part UR not supported '
          '(part ${seqMatch.group(1)} of $total)',
        );
      }
      bodyStr = seqMatch.group(3)!;
    }

    // 规范正文为 minimal bytewords（无空白）；含空白视为 standard
    // 全词风格（本 App 旧版本产出的格式，保留解码兼容）。
    return (type: type, data: decodeBytewordsBody(bodyStr));
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
  /// CBOR tag：RFC 9562 UUID（registry 要求 requestId 必须带此 tag）
  static const int uuidTag = 37;

  /// CBOR tag：BC-UR crypto-keypath（BCR-2020-007）
  static const int cryptoKeypathTag = 304;

  final Uint8List requestId;
  final Uint8List signData;
  final EthSignDataType dataType;
  final int? chainId;

  /// BIP-44 derivation path as integer list (hardened = 0x80000000 | index)
  final List<int> derivationPath;
  final String? address;
  final String? origin;

  /// 设备主密钥指纹（配对时从 crypto-account 获得）。Keystone 用它确认
  /// 请求归属；暂缺时省略 keypath 的 source-fingerprint 字段。
  final int? masterFingerprint;

  const EthSignRequest({
    required this.requestId,
    required this.signData,
    required this.dataType,
    this.chainId,
    required this.derivationPath,
    this.address,
    this.origin,
    this.masterFingerprint,
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

  /// Helper to create a CBOR int key
  static CborIntValue _key(int k) => CborIntValue(k);

  /// Encode to CBOR bytes
  /// derivationPath → crypto-keypath（tag 304）结构：
  /// `{1: [childIndex, hardened, ...], 2: source-fingerprint?}`
  /// Keystone registry 只认这个格式，裸 int 数组会被设备拒收。
  CborTagValue _buildCryptoKeypath() {
    final components = <CborObject>[];
    for (final i in derivationPath) {
      components.add(CborIntValue(i & 0x7FFFFFFF));
      components.add(CborBoleanValue(i & 0x80000000 != 0));
    }
    final keypathMap = <CborObject, CborObject>{
      const CborIntValue(1): CborListValue.definite(components),
      if (masterFingerprint != null)
        const CborIntValue(2): CborIntValue(masterFingerprint!),
    };
    return CborTagValue(CborMapValue.definite(keypathMap), const [
      cryptoKeypathTag,
    ]);
  }

  Uint8List toCbor() {
    final map = <CborObject, CborObject>{
      _key(EthSignRequestKeys.requestId): CborTagValue(
        CborBytesValue(requestId),
        const [uuidTag],
      ),
      _key(EthSignRequestKeys.signData): CborBytesValue(signData),
      _key(EthSignRequestKeys.dataType): CborIntValue(dataType.value),
      if (chainId != null)
        _key(EthSignRequestKeys.chainId): CborIntValue(chainId!),
      _key(EthSignRequestKeys.derivationPath): _buildCryptoKeypath(),
      if (address case final addr?)
        _key(EthSignRequestKeys.address): CborBytesValue(
          BytesUtils.fromHexString(
            addr.startsWith('0x') ? addr.substring(2) : addr,
          ),
        ),
      if (origin case final org?)
        _key(EthSignRequestKeys.origin): CborStringValue(org),
    };

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

    // 真机响应的 requestId 按 registry 规范带 UUID tag(37)；
    // 也兼容裸 bytes（旧实现/宽松设备）。
    Uint8List asBytes(CborObject v) {
      final unwrapped = v is CborTagValue ? v.value : v;
      if (unwrapped is! CborBytesValue) {
        throw UrCodecException('eth-signature field is not bytes');
      }
      return Uint8List.fromList(unwrapped.value);
    }

    for (final entry in cbor.value.entries) {
      final key = (entry.key as CborIntValue).value;
      switch (key) {
        case EthSignatureKeys.requestId:
          requestId = asBytes(entry.value);
        case EthSignatureKeys.signature:
          signature = asBytes(entry.value);
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
