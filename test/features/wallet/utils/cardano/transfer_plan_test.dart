import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/transfer_plan.dart';

void main() {
  Map<String, Object> ordinary() => {
    'amount': '1000000',
    'fee': '200000',
    'change': '8800000',
    'available': '10000000',
  };
  CardanoTransferPlan parse(Object? raw, {bool max = false}) =>
      CardanoTransferPlan.parse(
        raw,
        requested: BigInt.from(max ? 10000000 : 1000000),
        available: BigInt.from(10000000),
        sendMax: max,
      );
  test('exact ordinary and Max accounting', () {
    expect(parse(ordinary()).amount, BigInt.from(1000000));
    final max = parse({
      ...ordinary(),
      'amount': '9800000',
      'change': '0',
    }, max: true);
    expect(max.amount + max.fee, max.available);
  });
  for (final field in ['amount', 'fee', 'change', 'available']) {
    for (final value in [
      null,
      1,
      '-1',
      '01',
      '1.0',
      '1e6',
      '9223372036854775808',
    ]) {
      test('reject $field=$value', () {
        expect(
          () => parse({...ordinary(), field: value}),
          throwsFormatException,
        );
      });
    }
  }
  test('reject wrong requested amount and inconsistent accounting', () {
    expect(
      () => parse({...ordinary(), 'amount': '1000001', 'change': '8799999'}),
      throwsFormatException,
    );
    expect(() => parse({...ordinary(), 'change': '0'}), throwsFormatException);
    expect(() => parse(ordinary(), max: true), throwsFormatException);
    expect(() => parse(null), throwsFormatException);
    expect(
      () => parse({...ordinary(), 'fee': '0', 'change': '9000000'}),
      throwsFormatException,
    );
  });
}
