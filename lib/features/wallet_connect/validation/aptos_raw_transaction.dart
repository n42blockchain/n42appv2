import 'dart:convert';
import 'dart:typed_data';

/// Validated, immutable BCS RawTransaction for single-sender Aptos signing.
/// This is not a SignedTransaction or RawTransactionWithData envelope.
class AptosRawTransaction {
  final List<int> _bytes;
  final int chainId;
  final String sender;

  AptosRawTransaction._(Uint8List bytes, this.chainId, this.sender)
    : _bytes = List.unmodifiable(bytes);

  Uint8List get bytes => Uint8List.fromList(_bytes);

  /// Accept explicit 0x hex or base64. Do not guess ambiguous unprefixed hex.
  factory AptosRawTransaction.parse(
    String encoded, {
    required String expectedSender,
    required int expectedChainId,
  }) {
    if (encoded.length > 131074) {
      throw const FormatException('Transaction too large');
    }
    final Uint8List bytes;
    if (encoded.startsWith('0x') || encoded.startsWith('0X')) {
      final hex = encoded.substring(2);
      if (hex.isEmpty ||
          hex.length.isOdd ||
          RegExp(r'[^0-9a-fA-F]').hasMatch(hex)) {
        throw const FormatException('Invalid transaction hex');
      }
      bytes = Uint8List.fromList([
        for (var i = 0; i < hex.length; i += 2)
          int.parse(hex.substring(i, i + 2), radix: 16),
      ]);
    } else {
      bytes = base64Decode(encoded);
    }
    if (bytes.isEmpty || bytes.length > 65536) {
      throw const FormatException('Invalid transaction size');
    }
    final reader = _BcsReader(bytes);
    final senderBytes = reader.take(32);
    final sender = senderBytes
        .map((v) => v.toRadixString(16).padLeft(2, '0'))
        .join();
    var expected = expectedSender;
    if (expected.startsWith('0x') || expected.startsWith('0X')) {
      expected = expected.substring(2);
    }
    if (expected.isEmpty ||
        expected.length > 64 ||
        RegExp(r'[^0-9a-fA-F]').hasMatch(expected) ||
        sender != expected.toLowerCase().padLeft(64, '0')) {
      throw const FormatException(
        'Aptos sender does not match approved account',
      );
    }
    reader.take(8); // sequence number
    reader.payload();
    reader.take(24); // max gas, gas price, expiration (u64 LE)
    final chain = reader.byte();
    if (chain != expectedChainId || !reader.done) {
      throw const FormatException(
        'Wrong Aptos chain or trailing transaction bytes',
      );
    }
    return AptosRawTransaction._(bytes, chain, '0x$sender');
  }
}

class _BcsReader {
  final Uint8List bytes;
  int offset = 0;
  _BcsReader(this.bytes);
  bool get done => offset == bytes.length;
  int byte() => take(1).single;
  Uint8List take(int length) {
    if (length < 0 || length > bytes.length - offset) {
      throw const FormatException('Truncated BCS');
    }
    final start = offset;
    offset += length;
    return Uint8List.sublistView(bytes, start, offset);
  }

  int length() {
    var value = 0;
    for (var index = 0; index < 5; index++) {
      final next = byte();
      if (index == 4 && next > 15) {
        throw const FormatException('BCS integer overflow');
      }
      value |= (next & 127) << (7 * index);
      if (next & 128 == 0) {
        if (index > 0 && next == 0) {
          throw const FormatException('Noncanonical BCS integer');
        }
        return value;
      }
    }
    throw const FormatException('Invalid BCS integer');
  }

  void vector(void Function() item) {
    final count = length();
    // Every supported vector item consumes at least one byte.
    if (count > bytes.length - offset) {
      throw const FormatException('Invalid vector size');
    }
    for (var i = 0; i < count; i++) {
      item();
    }
  }

  void blob() => take(length());
  void identifier() {
    final value = utf8.decode(take(length()));
    final match = RegExp(
      r'(?:[a-zA-Z][a-zA-Z0-9_$]*)|(?:[_$][a-zA-Z0-9_$]+)|(?:<SELF>(?:_[0-9]+)?)',
    ).matchAsPrefix(value);
    if (match == null || match.end != value.length) {
      throw const FormatException('Invalid Move identifier');
    }
  }

  void typeTag([int depth = 0]) {
    if (depth > 64) throw const FormatException('Type nesting too deep');
    final tag = length();
    switch (tag) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 8:
      case 9:
      case 10:
        return;
      case 6:
        typeTag(depth + 1);
      case 7:
        take(32);
        identifier();
        identifier();
        vector(() => typeTag(depth + 1));
      default:
        throw const FormatException('Unsupported Move type');
    }
  }

  void entryFunction() {
    take(32);
    identifier();
    identifier();
    vector(typeTag);
    vector(blob);
  }

  void scriptArgument() {
    switch (length()) {
      case 0:
        take(1);
      case 1:
        take(8);
      case 2:
        take(16);
      case 3:
        take(32);
      case 4:
        blob();
      case 5:
        if (byte() > 1) throw const FormatException('Invalid boolean');
      case 6:
        take(2);
      case 7:
        take(4);
      case 8:
        take(32);
      default:
        throw const FormatException('Unsupported script argument');
    }
  }

  void payload() {
    switch (length()) {
      case 0: // Script
        blob();
        vector(typeTag);
        vector(scriptArgument);
      case 1: // Legacy module bundle
        vector(blob);
      case 2: // Entry function
        entryFunction();
      case 3: // Multisig: address, optional multisig transaction payload
        take(32);
        final option = byte();
        if (option == 1) {
          if (length() != 0) {
            throw const FormatException('Unsupported multisig payload');
          }
          entryFunction();
        } else if (option != 0) {
          throw const FormatException('Invalid BCS option');
        }
      default:
        throw const FormatException('Unsupported Aptos transaction payload');
    }
  }
}
