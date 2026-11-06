import 'dart:convert';

/// A Sui gas budget is already denominated in MIST, not gas-price units.
final suiTransferGasBudget = BigInt.from(2000000);

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
