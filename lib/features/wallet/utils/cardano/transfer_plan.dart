/// Checked public amounts from WalletCore's ADA-only transaction planner.
class CardanoTransferPlan {
  final BigInt amount;
  final BigInt fee;
  final BigInt change;
  final BigInt available;
  const CardanoTransferPlan._(
    this.amount,
    this.fee,
    this.change,
    this.available,
  );

  factory CardanoTransferPlan.parse(
    Object? raw, {
    required BigInt requested,
    required BigInt available,
    required bool sendMax,
  }) {
    if (raw is! Map) throw const FormatException('Missing Cardano plan');
    BigInt integer(String field) {
      final text = raw[field];
      if (text is! String || !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(text)) {
        throw const FormatException('Invalid Cardano plan amount');
      }
      final value = BigInt.parse(text);
      if (value > BigInt.parse('9223372036854775807')) {
        throw const FormatException('Cardano plan amount overflow');
      }
      return value;
    }

    final amount = integer('amount');
    final fee = integer('fee');
    final change = integer('change');
    final used = integer('available');
    if (amount <= BigInt.zero ||
        fee <= BigInt.zero ||
        used > available ||
        amount + fee + change != used ||
        (sendMax
            ? used != available || change != BigInt.zero || amount > requested
            : amount != requested)) {
      throw const FormatException('Cardano plan does not match request');
    }
    return CardanoTransferPlan._(amount, fee, change, used);
  }
}
