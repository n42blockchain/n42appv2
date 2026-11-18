/// Checked Horizon account/ledger values for a single native payment.
/// Reserve follows CAP-0033. Selling liabilities are deducted separately.
class StellarSpendableBalance {
  final BigInt balance;
  final BigInt reserve;
  final BigInt liabilities;
  final BigInt fee;
  final BigInt nextSequence;

  /// Latest closed ledger observed while preparing the payment, when Horizon
  /// reported a well-formed one. The payment cannot be applied at or before it.
  final int? latestLedger;
  BigInt get spendable => balance - reserve - liabilities - fee;

  StellarSpendableBalance._(
    this.balance,
    this.reserve,
    this.liabilities,
    this.fee,
    this.nextSequence,
    this.latestLedger,
  );

  static final _int64Max = BigInt.parse('9223372036854775807');

  static BigInt _integer(Object? value, BigInt max) {
    if (value is! int && value is! String) {
      throw const FormatException('Invalid Stellar integer');
    }
    final text = value.toString();
    if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(text)) {
      throw const FormatException('Invalid Stellar integer');
    }
    final result = BigInt.parse(text);
    if (result > max) throw const FormatException('Stellar integer overflow');
    return result;
  }

  static BigInt stroops(Object? value) {
    if (value is! String ||
        !RegExp(r'^(0|[1-9][0-9]*)(\.[0-9]{1,7})?$').hasMatch(value)) {
      throw const FormatException('Invalid Stellar decimal amount');
    }
    final parts = value.split('.');
    final amount =
        BigInt.parse(parts.first) * BigInt.from(10000000) +
        BigInt.parse(parts.length == 1 ? '0' : parts[1].padRight(7, '0'));
    if (amount > _int64Max) {
      throw const FormatException('Stellar amount overflow');
    }
    return amount;
  }

  factory StellarSpendableBalance.parse(Object? account, Object? ledgerPage) {
    if (account is! Map || ledgerPage is! Map) {
      throw const FormatException('Missing Stellar account or ledger');
    }
    final embedded = ledgerPage['_embedded'];
    final records = embedded is Map ? embedded['records'] : null;
    if (records is! List || records.length != 1 || records.first is! Map) {
      throw const FormatException('Missing latest Stellar ledger');
    }
    final ledger = records.first as Map;
    final base = _integer(
      ledger['base_reserve_in_stroops'],
      BigInt.from(4294967295),
    );
    final fee = _integer(
      ledger['base_fee_in_stroops'],
      BigInt.from(2147483647),
    );
    if (base == BigInt.zero || fee == BigInt.zero) {
      throw const FormatException('Invalid Stellar network parameters');
    }
    final countMax = BigInt.from(4294967295);
    final entries = _integer(account['subentry_count'], countMax);
    final sponsoring = _integer(account['num_sponsoring'], countMax);
    final sponsored = _integer(account['num_sponsored'], countMax);
    final units = BigInt.two + entries + sponsoring - sponsored;
    if (units < BigInt.zero) {
      throw const FormatException('Invalid Stellar sponsorship counts');
    }
    final balances = account['balances'];
    if (balances is! List || balances.any((entry) => entry is! Map)) {
      throw const FormatException('Invalid Stellar balances');
    }
    final native = balances.where((entry) => entry['asset_type'] == 'native');
    if (native.length != 1) {
      throw const FormatException(
        'Missing or duplicate native Stellar balance',
      );
    }
    final balance = stroops(native.single['balance']);
    final liabilities = stroops(native.single['selling_liabilities']);
    final sequence = _integer(account['sequence'], _int64Max - BigInt.one);
    final ledgerSequence = ledger['sequence'];
    return StellarSpendableBalance._(
      balance,
      units * base,
      liabilities,
      fee,
      sequence + BigInt.one,
      ledgerSequence is int && ledgerSequence > 0 && ledgerSequence <= 4294967295
          ? ledgerSequence
          : null,
    );
  }
}
