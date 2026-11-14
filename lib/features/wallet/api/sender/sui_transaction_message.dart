import 'dart:convert';
import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';
import 'package:pointycastle/digests/blake2b.dart';

/// A Sui gas budget is already denominated in MIST, not gas-price units.
final suiTransferGasBudget = BigInt.from(2000000);

/// Sui transaction digest of BCS TransactionData bytes (base64): Base58 of
/// Blake2b-256 over the "TransactionData::" intent name and the bytes. It is
/// known before submission, so an unknown outcome can still be tracked.
String suiTransactionDigest(String transaction) {
  final input = BytesBuilder()
    ..add(utf8.encode('TransactionData::'))
    ..add(base64Decode(transaction));
  return Base58Encode(
    Blake2bDigest(digestSize: 32).process(input.toBytes()).toList(),
  );
}

/// Native signing returns the original bytes and the serialized signature.
/// Never substitute unsigned bytes for a missing signature.
class SuiSignedTransaction {
  final String transaction;
  final String signature;
  const SuiSignedTransaction._(this.transaction, this.signature);

  static SuiSignedTransaction? parse(String value) {
    final parts = value.split('|');
    if (parts.length != 2) return null;
    try {
      final tx = base64Decode(parts[0]);
      final sig = base64Decode(parts[1]);
      if (tx.isEmpty ||
          base64Encode(tx) != parts[0] ||
          sig.length != 97 ||
          sig.first != 0 ||
          base64Encode(sig) != parts[1]) {
        return null;
      }
      return SuiSignedTransaction._(parts[0], parts[1]);
    } on FormatException {
      return null;
    }
  }
}
