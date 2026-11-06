import 'dart:convert';
import 'dart:typed_data';

import '../../../wallet_connect/validation/aptos_raw_transaction.dart';

/// Bounded Move Coin type and BCS entry-function transfer builder.
/// Uses the original TypeTag variants supported by both native signing bridges.
class AptosCoinType {
  final List<int> _tag;
  AptosCoinType._(List<int> tag) : _tag = List.unmodifiable(tag);

  factory AptosCoinType.parse(String source) {
    if (source.isEmpty ||
        source.length > 4096 ||
        source.contains(RegExp(r'\s'))) {
      throw const FormatException('Invalid Aptos Coin type');
    }
    final parser = _TypeParser(source);
    final tag = parser.type(0);
    if (parser.offset != source.length || tag.first != 7) {
      throw const FormatException('Aptos Coin requires a complete struct type');
    }
    return AptosCoinType._(tag);
  }

  Uint8List transfer({
    required String sender,
    required String recipient,
    required BigInt sequence,
    required BigInt amount,
    required BigInt maxGas,
    required BigInt gasPrice,
    required BigInt expiration,
    required int chainId,
  }) {
    if (chainId < 1 ||
        chainId > 2 ||
        amount <= BigInt.zero ||
        maxGas <= BigInt.zero ||
        gasPrice <= BigInt.zero ||
        expiration <= BigInt.zero) {
      throw const FormatException('Invalid Aptos transfer parameters');
    }
    final raw = Uint8List.fromList([
      ..._address(sender), ..._u64(sequence),
      2, // TransactionPayload::EntryFunction
      ..._address('0x1'), ..._text('aptos_account'), ..._text('transfer_coins'),
      1, ..._tag, // one type argument: the full Coin type
      2, 32, ..._address(recipient), 8, ..._u64(amount),
      ..._u64(maxGas), ..._u64(gasPrice), ..._u64(expiration), chainId,
    ]);
    // Keep the same structural validation as WalletConnect/native raw signing.
    return AptosRawTransaction.parse(
      base64Encode(raw),
      expectedSender: sender,
      expectedChainId: chainId,
    ).bytes;
  }
}

List<int> _u64(BigInt value) {
  if (value < BigInt.zero || value >= (BigInt.one << 64)) {
    throw const FormatException('Aptos integer exceeds uint64');
  }
  return List.generate(
    8,
    (i) => ((value >> (8 * i)) & BigInt.from(255)).toInt(),
  );
}

List<int> _length(int value) {
  final result = <int>[];
  do {
    final byte = value & 127;
    value >>= 7;
    result.add(byte | (value == 0 ? 0 : 128));
  } while (value != 0);
  return result;
}

List<int> _text(String value) {
  final bytes = utf8.encode(value);
  return [..._length(bytes.length), ...bytes];
}

List<int> _address(String value) {
  if (value.contains(RegExp(r'\s')) ||
      !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(value)) {
    throw const FormatException('Invalid Aptos address');
  }
  final hex = value.substring(2).padLeft(64, '0');
  return [
    for (var i = 0; i < 64; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ];
}

class _TypeParser {
  final String source;
  int offset = 0;
  _TypeParser(this.source);
  bool consume(String text) {
    if (!source.startsWith(text, offset)) return false;
    offset += text.length;
    return true;
  }

  void require(String text) {
    if (!consume(text)) throw const FormatException('Malformed Move type');
  }

  String token(RegExp pattern) {
    final match = pattern.matchAsPrefix(source, offset);
    if (match == null) throw const FormatException('Malformed Move type');
    offset = match.end;
    return match.group(0)!;
  }

  List<int> type(int depth) {
    if (depth > 32) throw const FormatException('Move type nesting too deep');
    if (source.startsWith('0x', offset)) {
      final address = token(RegExp(r'0x[0-9a-fA-F]{1,64}'));
      require('::');
      final module = token(RegExp(r'[A-Za-z_][A-Za-z0-9_]{0,127}'));
      require('::');
      final name = token(RegExp(r'[A-Za-z_][A-Za-z0-9_]{0,127}'));
      final arguments = <List<int>>[];
      if (consume('<')) {
        do {
          if (arguments.length >= 64) {
            throw const FormatException('Too many Move type arguments');
          }
          arguments.add(type(depth + 1));
        } while (consume(','));
        require('>');
      }
      return [
        7,
        ..._address(address),
        ..._text(module),
        ..._text(name),
        ..._length(arguments.length),
        for (final arg in arguments) ...arg,
      ];
    }
    final name = token(RegExp(r'[a-z][a-z0-9]*'));
    if (name == 'vector') {
      require('<');
      final inner = type(depth + 1);
      require('>');
      return [6, ...inner];
    }
    const primitives = {
      'bool': 0,
      'u8': 1,
      'u64': 2,
      'u128': 3,
      'address': 4,
      'signer': 5,
      'u16': 8,
      'u32': 9,
      'u256': 10,
    };
    final tag = primitives[name];
    if (tag == null) throw const FormatException('Unsupported Move type');
    return [tag];
  }
}
