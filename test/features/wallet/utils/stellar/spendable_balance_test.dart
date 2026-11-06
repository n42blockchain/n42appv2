import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/stellar/spendable_balance.dart';

void main() {
  Map<String, dynamic> account() => {
    'sequence': '7',
    'subentry_count': 0,
    'num_sponsoring': 0,
    'num_sponsored': 0,
    'balances': [
      {
        'asset_type': 'native',
        'balance': '10.0000000',
        'selling_liabilities': '0.0000000',
      },
    ],
  };
  Map<String, dynamic> ledger({int reserve = 5000000, int fee = 100}) => {
    '_embedded': {
      'records': [
        {'base_reserve_in_stroops': reserve, 'base_fee_in_stroops': fee},
      ],
    },
  };
  test('minimum reserve and fee are retained for ordinary account', () {
    final funds = StellarSpendableBalance.parse(account(), ledger());
    expect(funds.balance, BigInt.from(100000000));
    expect(funds.reserve, BigInt.from(10000000));
    expect(funds.spendable, BigInt.from(89999900));
    expect(funds.nextSequence, BigInt.from(8));
  });
  test(
    'subentries sponsorship liabilities and current ledger parameters compose',
    () {
      final data = account()
        ..addAll({
          'subentry_count': 4,
          'num_sponsoring': 3,
          'num_sponsored': 2,
        });
      data['balances'][0]['selling_liabilities'] = '1.2500000';
      final funds = StellarSpendableBalance.parse(
        data,
        ledger(reserve: 6000000, fee: 300),
      );
      expect(funds.reserve, BigInt.from(42000000));
      expect(funds.liabilities, BigInt.from(12500000));
      expect(funds.spendable, BigInt.from(45499700));
    },
  );
  test('fully sponsored account can have zero reserve', () {
    final funds = StellarSpendableBalance.parse(
      account()..['num_sponsored'] = 2,
      ledger(),
    );
    expect(funds.reserve, BigInt.zero);
    expect(funds.spendable, BigInt.from(99999900));
  });
  test('underfunded account has no positive spendable balance', () {
    final data = account();
    data['balances'][0]['balance'] = '0.5';
    expect(
      StellarSpendableBalance.parse(data, ledger()).spendable,
      lessThan(BigInt.zero),
    );
  });
  for (final field in [
    'sequence',
    'subentry_count',
    'num_sponsoring',
    'num_sponsored',
    'balances',
  ]) {
    test('missing $field fails rather than assuming zero', () {
      expect(
        () => StellarSpendableBalance.parse(account()..remove(field), ledger()),
        throwsFormatException,
      );
    });
  }
  for (final value in [-1, true, 1.5, '01', '4294967296']) {
    test('bad reserve count $value fails', () {
      expect(
        () => StellarSpendableBalance.parse(
          account()..['subentry_count'] = value,
          ledger(),
        ),
        throwsFormatException,
      );
    });
  }
  test('negative sponsorship units and sequence overflow fail', () {
    expect(
      () => StellarSpendableBalance.parse(
        account()..['num_sponsored'] = 3,
        ledger(),
      ),
      throwsFormatException,
    );
    expect(
      () => StellarSpendableBalance.parse(
        account()..['sequence'] = '9223372036854775807',
        ledger(),
      ),
      throwsFormatException,
    );
  });
  test('missing or duplicate native balance and liabilities fail', () {
    final data = account();
    data['balances'][0].remove('selling_liabilities');
    expect(
      () => StellarSpendableBalance.parse(data, ledger()),
      throwsFormatException,
    );
    data['balances'] = [];
    expect(
      () => StellarSpendableBalance.parse(data, ledger()),
      throwsFormatException,
    );
    data['balances'] = [...account()['balances'], ...account()['balances']];
    expect(
      () => StellarSpendableBalance.parse(data, ledger()),
      throwsFormatException,
    );
  });
  for (final value in [
    null,
    {},
    {
      '_embedded': {'records': []},
    },
    ledger(reserve: 0),
    ledger(fee: 0),
    ledger(fee: 2147483648),
  ]) {
    test('invalid ledger $value fails', () {
      expect(
        () => StellarSpendableBalance.parse(account(), value),
        throwsFormatException,
      );
    });
  }
  test('exact decimal conversion retains one stroop and int64 maximum', () {
    expect(StellarSpendableBalance.stroops('0.0000001'), BigInt.one);
    expect(
      StellarSpendableBalance.stroops('922337203685.4775807'),
      BigInt.parse('9223372036854775807'),
    );
  });
  for (final value in [
    '0.00000001',
    '-1',
    '01',
    '1e2',
    '1\n',
    '922337203685.4775808',
    1,
    true,
  ]) {
    test('invalid decimal $value fails without rounding', () {
      expect(
        () => StellarSpendableBalance.stroops(value),
        throwsFormatException,
      );
    });
  }
}
