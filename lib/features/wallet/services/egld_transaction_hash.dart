import 'dart:convert';
import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:pointycastle/digests/blake2b.dart';

/// Hashes the signed, ordinary transaction JSON returned by WalletCore.
///
/// MultiversX hashes Protobuf bytes, not JSON or the signing payload. Field
/// numbers and sign/magnitude value encoding follow sdk-core's ProtoSerializer.
/// Unsupported guarded/relayed transactions must use their own complete codec;
/// silently dropping their fields would produce an incorrect recovery hash.
class EgldTransactionHash {
  static String compute(String signedJson) {
    final decoded = jsonDecode(signedJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid signed MultiversX transaction');
    }
    final tx = decoded;
    const fields = {
      'nonce',
      'value',
      'receiver',
      'sender',
      'gasPrice',
      'gasLimit',
      'data',
      'chainID',
      'version',
      'signature',
      'options',
    };
    if (tx.keys.any((key) => !fields.contains(key))) {
      throw const FormatException('Unsupported MultiversX transaction fields');
    }
    int number(String name, {int minimum = 0, int maximum = 9007199254740991}) {
      final value = tx[name];
      // Bound JSON numbers to exact integers on both native and Web platforms.
      if (value is! int || value < minimum || value > maximum) {
        throw FormatException('Invalid MultiversX $name');
      }
      return value;
    }

    String string(String name) {
      final value = tx[name];
      if (value is! String || value.isEmpty) {
        throw FormatException('Invalid MultiversX $name');
      }
      return value;
    }

    final nonce = number('nonce');
    final value = string('value');
    if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value)) {
      throw const FormatException('Invalid MultiversX value');
    }
    final amount = BigInt.parse(value);
    var amountHex = amount.toRadixString(16);
    if (amountHex.length.isOdd) amountHex = '0$amountHex';
    final receiver = _address(string('receiver'));
    final sender = _address(string('sender'));
    final gasPrice = number('gasPrice', minimum: 1);
    final gasLimit = number('gasLimit', minimum: 1);
    final chain = utf8.encode(string('chainID'));
    final version = number('version', minimum: 1, maximum: 0xffffffff);
    final signature = string('signature');
    if (signature.length != 128 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(signature)) {
      throw const FormatException('Invalid MultiversX signature');
    }
    final options = tx.containsKey('options')
        ? number('options', maximum: 1)
        : 0;
    if (options != 0 && version < 2) {
      throw const FormatException('MultiversX options require version 2');
    }
    var data = <int>[];
    if (tx.containsKey('data')) {
      final encoded = tx['data'];
      if (encoded is! String) throw const FormatException('Invalid data');
      data = base64Decode(encoded);
      if (base64Encode(data) != encoded) {
        throw const FormatException('Noncanonical MultiversX data');
      }
    }

    final bytes = <int>[];
    void varint(BigInt value) {
      while (value >= BigInt.from(128)) {
        bytes.add((value & BigInt.from(127)).toInt() | 128);
        value >>= 7;
      }
      bytes.add(value.toInt());
    }

    void integer(int field, int value) {
      varint(BigInt.from(field << 3));
      varint(BigInt.from(value));
    }

    void blob(int field, List<int> value) {
      varint(BigInt.from((field << 3) | 2));
      varint(BigInt.from(value.length));
      bytes.addAll(value);
    }

    // The node omits nonce zero, but always encodes value (zero is [0, 0]).
    if (nonce != 0) integer(1, nonce);
    blob(2, [0, ..._hex(amountHex)]);
    blob(3, receiver);
    blob(5, sender);
    integer(7, gasPrice);
    integer(8, gasLimit);
    if (data.isNotEmpty) blob(9, data);
    blob(10, chain);
    integer(11, version);
    blob(12, _hex(signature));
    if (options != 0) integer(13, options);
    return Blake2bDigest(digestSize: 32)
        .process(Uint8List.fromList(bytes))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static List<int> _hex(String text) => [
    for (var i = 0; i < text.length; i += 2)
      int.parse(text.substring(i, i + 2), radix: 16),
  ];

  static List<int> _address(String text) {
    final decoded = bech32.decode(text);
    if (decoded.hrp != 'erd' || text != text.toLowerCase()) {
      throw const FormatException('Invalid MultiversX address prefix');
    }
    final bytes = <int>[];
    var accumulator = 0;
    var bits = 0;
    for (final word in decoded.data) {
      accumulator = ((accumulator << 5) | word) & 0xffff;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        bytes.add((accumulator >> bits) & 255);
      }
    }
    if (bytes.length != 32 ||
        bits >= 5 ||
        ((accumulator << (8 - bits)) & 255) != 0) {
      throw const FormatException('Invalid MultiversX address bytes');
    }
    return bytes;
  }
}
