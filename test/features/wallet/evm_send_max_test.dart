import 'package:flutter_test/flutter_test.dart';

/// Mirrors the send-max reconciliation in EvmSender._sendSerialized.
///
/// The sender signs with a x1.2 gas buffer while the send page computes the
/// max transferable amount from its own 1.0x estimate. Without reconciliation
/// the balance check rejects a max send the UI had just offered the user.
BigInt? reconcile({
  required BigInt value,
  required BigInt balance,
  required BigInt fee,
}) {
  final maxSendable = balance - fee;
  var v = value;
  if (v <= balance && maxSendable > BigInt.zero && v >= maxSendable) {
    v = maxSendable;
  }
  if (v + fee > balance) return null; // genuine shortfall
  return v;
}

void main() {
  final balance = BigInt.from(1000);

  test('max send computed with a smaller fee is settled against the real fee', () {
    // UI offered balance - fee(1.0x); sender signs with fee(1.2x).
    final result = reconcile(
      value: balance - BigInt.from(100),
      balance: balance,
      fee: BigInt.from(120),
    );
    expect(result, BigInt.from(880), reason: 'must send balance - actual fee');
    expect(result! + BigInt.from(120) <= balance, isTrue);
  });

  test('exact full balance is settled the same way', () {
    expect(
      reconcile(value: balance, balance: balance, fee: BigInt.from(120)),
      BigInt.from(880),
    );
  });

  test('ordinary small transfer is untouched', () {
    expect(
      reconcile(value: BigInt.from(10), balance: balance, fee: BigInt.from(120)),
      BigInt.from(10),
    );
  });

  test('value above balance is still a shortfall', () {
    expect(
      reconcile(value: BigInt.from(2000), balance: balance, fee: BigInt.from(120)),
      isNull,
    );
  });

  test('fee alone exceeding balance is a shortfall, not a negative send', () {
    expect(
      reconcile(value: balance, balance: balance, fee: BigInt.from(1200)),
      isNull,
    );
  });
}
