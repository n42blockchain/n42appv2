import 'dart:convert';

/// Checked amounts returned by the native planner used for this signature.
class CardanoSignedTransfer {
  final String encoded;
  final String txHash;
  final BigInt amount;
  final BigInt fee;
  CardanoSignedTransfer._(this.encoded, this.txHash, this.amount, this.fee);

  factory CardanoSignedTransfer.parse(
    String raw, {
    required BigInt requested,
    required BigInt available,
    required bool sendMax,
  }) {
    final dynamic data = jsonDecode(raw);
    if (data is! Map) {
      throw const FormatException('Missing Cardano signing plan');
    }
    BigInt integer(String field) {
      final value = data[field];
      if (value is! String || !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value)) {
        throw const FormatException('Invalid Cardano signing plan amount');
      }
      return BigInt.parse(value);
    }

    final amount = integer('amount');
    final fee = integer('fee');
    final change = integer('change');
    final used = integer('available');
    final encoded = data['encoded'];
    final txHash = data['txHash'];
    if (txHash is! String ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(txHash) ||
        encoded is! String ||
        !RegExp(r'^0x([0-9a-fA-F]{2})+$').hasMatch(encoded) ||
        amount <= BigInt.zero ||
        fee <= BigInt.zero ||
        used > available ||
        amount + fee + change != used ||
        (sendMax
            ? (used != available || change != BigInt.zero || amount > requested)
            : amount != requested)) {
      throw const FormatException(
        'Cardano signing plan does not match request',
      );
    }
    return CardanoSignedTransfer._(encoded, txHash.toLowerCase(), amount, fee);
  }
}
