import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';

/// Chain facts captured from the exact signed bytes before broadcast. They let
/// the history poller later prove, from chain state only, that a pending
/// ADA/XLM/EGLD/NEAR transfer can never be included.
///
/// Values are kept as decimal strings to avoid int64 limits on web builds.
class MemoExpiryProof {
  static const version = 1;

  /// Stellar: the envelope sequence number and the latest closed ledger seen
  /// before signing (the transaction cannot be applied at or before it).
  static String stellar({required BigInt sequence, required int ledger}) =>
      _encode('XLM', {'seq': sequence.toString(), 'ledger': '$ledger'});

  /// Cardano: the invalid-hereafter slot (TTL) from the signed body.
  static String cardano({required BigInt ttl}) =>
      _encode('ADA', {'ttl': ttl.toString()});

  /// MultiversX: the account nonce used by the signed transaction.
  static String multiversx({required BigInt nonce}) =>
      _encode('EGLD', {'nonce': nonce.toString()});

  /// NEAR: access-key nonce, signing public key and the height of the
  /// reference block whose hash is embedded in the signed transaction.
  static String near({
    required BigInt nonce,
    required String publicKey,
    required BigInt height,
  }) => _encode('NEAR', {
    'nonce': nonce.toString(),
    'publicKey': publicKey,
    'height': height.toString(),
  });

  static String _encode(String chain, Map<String, String> fields) =>
      jsonEncode({'v': version, 'chain': chain, ...fields});

  /// Decode a stored proof for [chain]. Any malformed, foreign or future
  /// version is ignored: without a proof the record simply stays pending.
  static Map<String, String>? decode(String? raw, String chain) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map || data['v'] != version || data['chain'] != chain) {
        return null;
      }
      final result = <String, String>{};
      for (final entry in data.entries) {
        if (entry.key is String && entry.value is String) {
          result[entry.key as String] = entry.value as String;
        }
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Parse a non-negative decimal field.
  static BigInt? unsigned(Map<String, String> proof, String key) {
    final text = proof[key];
    if (text == null || !RegExp(r'^(0|[1-9][0-9]{0,30})$').hasMatch(text)) {
      return null;
    }
    return BigInt.parse(text);
  }
}

/// Sequence number of a signed Stellar envelope (XDR, base64). Supports
/// ENVELOPE_TYPE_TX_V0 and ENVELOPE_TYPE_TX; anything else returns null.
BigInt? stellarEnvelopeSequence(String encoded) {
  try {
    final bytes = base64Decode(encoded);
    final data = ByteData.sublistView(bytes);
    var offset = 0;
    final type = data.getUint32(offset);
    offset += 4;
    if (type == 0) {
      offset += 32; // sourceAccountEd25519
    } else if (type == 2) {
      final muxed = data.getUint32(offset);
      offset += 4;
      if (muxed == 0) {
        offset += 32;
      } else if (muxed == 0x100) {
        offset += 8 + 32;
      } else {
        return null;
      }
    } else {
      return null;
    }
    offset += 4; // fee
    if (offset + 8 > bytes.length) return null;
    final high = BigInt.from(data.getUint32(offset));
    final low = BigInt.from(data.getUint32(offset + 4));
    final sequence = (high << 32) | low;
    // int64 sequence numbers are positive for any usable account.
    if (high >= BigInt.from(0x80000000) || sequence <= BigInt.zero) {
      return null;
    }
    return sequence;
  } catch (_) {
    return null;
  }
}

/// TTL (body key 3, invalid-hereafter slot) of a signed Cardano transaction
/// given as hex (optionally 0x-prefixed). Returns null when absent or invalid.
BigInt? cardanoSignedTtl(String encoded) {
  try {
    final hex = encoded.startsWith('0x') ? encoded.substring(2) : encoded;
    if (hex.isEmpty || hex.length.isOdd) return null;
    final bytes = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    final reader = _CborReader(bytes);
    final (txMajor, txLength) = reader.head();
    if (txMajor != 4 || txLength == null || txLength < 3) return null;
    final (bodyMajor, bodyLength) = reader.head();
    if (bodyMajor != 5 || bodyLength == null) return null;
    BigInt? ttl;
    for (var i = 0; i < bodyLength; i++) {
      final (keyMajor, key) = reader.head();
      if (keyMajor != 0 || key == null) return null;
      if (key == 3) {
        if (ttl != null) return null;
        final (valueMajor, value) = reader.head();
        if (valueMajor != 0 || value == null) return null;
        ttl = BigInt.from(value);
      } else {
        reader.skip();
      }
    }
    return ttl;
  } catch (_) {
    return null;
  }
}

/// Nonce and reference block hash (base58) of a canonical NEAR V0 signed
/// transaction. Other envelope versions return null.
(BigInt, String)? nearSignedNonceAndBlock(String encoded) {
  try {
    final bytes = base64Decode(encoded);
    final data = ByteData.sublistView(bytes);
    if (bytes.length < 2 || bytes[1] != 0) return null;
    var offset = 0;
    int account() {
      final size = data.getUint32(offset, Endian.little);
      if (size < 2 || size > 64) throw const FormatException();
      return offset + 4 + size;
    }

    offset = account();
    final keyType = bytes[offset];
    offset +=
        1 +
        switch (keyType) {
          0 => 32,
          1 => 64,
          _ => throw const FormatException(),
        };
    final low = BigInt.from(data.getUint32(offset, Endian.little));
    final high = BigInt.from(data.getUint32(offset + 4, Endian.little));
    offset += 8;
    offset = account();
    if (offset + 32 > bytes.length) return null;
    final block = Base58Encode(bytes.sublist(offset, offset + 32));
    return ((high << 32) | low, block);
  } catch (_) {
    return null;
  }
}

/// Minimal definite/indefinite-length CBOR walker (RFC 8949) used only to
/// locate the TTL field; it never interprets values it skips.
class _CborReader {
  final Uint8List bytes;
  int offset = 0;
  _CborReader(this.bytes);

  int _byte() {
    if (offset >= bytes.length) throw const FormatException('Truncated CBOR');
    return bytes[offset++];
  }

  /// Returns the major type and argument; the argument is null for
  /// indefinite length (additional information 31).
  (int, int?) head() {
    final initial = _byte();
    final major = initial >> 5;
    final info = initial & 0x1f;
    if (info < 24) return (major, info);
    if (info == 31) {
      if (major < 2 || major > 5) throw const FormatException('Bad CBOR');
      return (major, null);
    }
    final size = switch (info) {
      24 => 1,
      25 => 2,
      26 => 4,
      27 => 8,
      _ => throw const FormatException('Bad CBOR'),
    };
    var value = 0;
    for (var i = 0; i < size; i++) {
      value = (value << 8) | _byte();
    }
    if (value < 0) throw const FormatException('CBOR value too large');
    return (major, value);
  }

  bool _isBreak() => offset < bytes.length && bytes[offset] == 0xff;

  void skip([int depth = 0]) {
    if (depth > 64) throw const FormatException('CBOR too deep');
    final (major, argument) = head();
    switch (major) {
      case 0 || 1:
        return;
      case 2 || 3:
        if (argument == null) {
          while (!_isBreak()) {
            skip(depth + 1);
          }
          offset++;
        } else {
          if (offset + argument > bytes.length) {
            throw const FormatException('Truncated CBOR');
          }
          offset += argument;
        }
      case 4 || 5:
        final items = major == 5 ? 2 : 1;
        if (argument == null) {
          while (!_isBreak()) {
            for (var i = 0; i < items; i++) {
              skip(depth + 1);
            }
          }
          offset++;
        } else {
          for (var i = 0; i < argument * items; i++) {
            skip(depth + 1);
          }
        }
      case 6:
        skip(depth + 1);
      default:
        // Simple values and floats carry their payload in the argument.
        return;
    }
  }
}
