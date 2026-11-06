import 'dart:convert';

/// Metadata returned by the native signer for the same signing input.
class StellarSignedTransaction {
  final String encoded;
  final String txHash;
  StellarSignedTransaction._(this.encoded, this.txHash);

  factory StellarSignedTransaction.parse(String raw) {
    final data = jsonDecode(raw);
    if (data is! Map ||
        data['encoded'] is! String ||
        data['txHash'] is! String) {
      throw const FormatException('Missing Stellar signing metadata');
    }
    final encoded = data['encoded'] as String;
    final hash = data['txHash'] as String;
    if (encoded.isEmpty ||
        base64Encode(base64Decode(encoded)) != encoded ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash)) {
      throw const FormatException('Invalid Stellar signing metadata');
    }
    return StellarSignedTransaction._(encoded, hash.toLowerCase());
  }
}
