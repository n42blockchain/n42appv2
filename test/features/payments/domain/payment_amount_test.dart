import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/domain/payment_amount.dart';
import 'package:n42_wallet/features/payments/domain/payment_asset.dart';

PaymentAsset asset({
  int decimals = 6,
  String network = '1',
  String symbol = 'TEST',
}) => PaymentAsset(
  id: PaymentAssetId(
    namespace: 'eip155',
    network: network,
    contract: '0x1111111111111111111111111111111111111111',
  ),
  symbol: symbol,
  decimals: decimals,
);

void main() {
  test('parses stablecoin fractional values into exact smallest units', () {
    final token = asset();
    expect(PaymentAmount.parse('0.1', asset: token).units, BigInt.from(100000));
    expect(PaymentAmount.parse('0.000001', asset: token).units, BigInt.one);
    expect(
      PaymentAmount.parse('123.456789', asset: token).units,
      BigInt.from(123456789),
    );
    expect(PaymentAmount.parse('00012.3400', asset: token).format(), '12.34');
  });

  test(
    'large amounts remain exact beyond JavaScript and double integer limits',
    () {
      final token = asset(decimals: 18);
      const input = '900719925474099312345678901234567890.123456789012345678';
      final amount = PaymentAmount.parse(input, asset: token);
      expect(
        amount.units,
        BigInt.parse('900719925474099312345678901234567890123456789012345678'),
      );
      expect(amount.format(), input);
      expect(amount.format(trimTrailingZeros: false), input);
    },
  );

  test(
    'zero is representable with canonical and fixed precision formatting',
    () {
      final amount = PaymentAmount.parse('0.000000', asset: asset());
      expect(amount.units, BigInt.zero);
      expect(amount.format(), '0');
      expect(amount.format(trimTrailingZeros: false), '0.000000');
    },
  );

  test('zero-decimal assets accept integers and reject fractional syntax', () {
    final token = asset(decimals: 0);
    expect(PaymentAmount.parse('42', asset: token).units, BigInt.from(42));
    expect(
      PaymentAmount.parse('42', asset: token).format(trimTrailingZeros: false),
      '42',
    );
    expect(
      () => PaymentAmount.parse('42.0', asset: token),
      throwsFormatException,
    );
  });

  test('excess precision is rejected including apparently harmless zeroes', () {
    for (final value in ['0.0000001', '1.0000000', '999.1234567']) {
      expect(
        () => PaymentAmount.parse(value, asset: asset()),
        throwsFormatException,
        reason: value,
      );
    }
  });

  test(
    'invalid numeric formats are never rounded or interpreted implicitly',
    () {
      for (final value in [
        '',
        '-1',
        '-0',
        '+1',
        '1e6',
        '1E-6',
        'NaN',
        'Infinity',
        '.1',
        '1.',
        '1,000',
        '1_000',
        ' 1',
        '1 ',
        '1\n',
        '1.2.3',
        '١',
        '１',
        '0x10',
      ]) {
        expect(
          () => PaymentAmount.parse(value, asset: asset()),
          throwsFormatException,
          reason: value,
        );
      }
      expect(
        () => PaymentAmount(asset: asset(), units: -BigInt.one),
        throwsArgumentError,
      );
    },
  );

  test('formatting preserves leading fractional zeros and optional scale', () {
    final amount = PaymentAmount(asset: asset(), units: BigInt.from(120));
    expect(amount.format(), '0.00012');
    expect(amount.format(trimTrailingZeros: false), '0.000120');
    final whole = PaymentAmount.parse('12', asset: asset());
    expect(whole.format(), '12');
    expect(whole.format(trimTrailingZeros: false), '12.000000');
  });

  test(
    'maximum supported precision can represent its smallest unit exactly',
    () {
      final token = asset(decimals: 255);
      final smallest = '0.${'0' * 254}1';
      final amount = PaymentAmount.parse(smallest, asset: token);
      expect(amount.units, BigInt.one);
      expect(amount.format(), smallest);
      expect(
        () => PaymentAmount.parse('${smallest}0', asset: token),
        throwsFormatException,
      );
    },
  );

  test(
    'amount equality binds network, precision, and units, not display symbol',
    () {
      final first = PaymentAmount.parse('1.5', asset: asset());
      final renamed = PaymentAmount.parse(
        '1.5',
        asset: asset(symbol: 'RENAMED'),
      );
      expect(first, renamed);
      expect(first.hashCode, renamed.hashCode);
      expect(
        first,
        isNot(PaymentAmount.parse('1.5', asset: asset(network: '8453'))),
      );
      expect(
        first,
        isNot(PaymentAmount(asset: asset(decimals: 18), units: first.units)),
      );
      expect(first, isNot(PaymentAmount.parse('1.500001', asset: asset())));
    },
  );

  test(
    'integer units round-trip through both display formats for common scales',
    () {
      final values = [
        BigInt.zero,
        BigInt.one,
        BigInt.from(10),
        BigInt.from(123456789),
        BigInt.parse('123456789012345678901234567890123456789'),
      ];
      for (final decimals in [0, 2, 6, 8, 18, 255]) {
        final token = asset(decimals: decimals);
        for (final units in values) {
          final original = PaymentAmount(asset: token, units: units);
          expect(
            PaymentAmount.parse(original.format(), asset: token),
            original,
          );
          expect(
            PaymentAmount.parse(
              original.format(trimTrailingZeros: false),
              asset: token,
            ),
            original,
          );
        }
      }
    },
  );
}
