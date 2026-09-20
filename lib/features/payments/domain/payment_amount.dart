import 'payment_asset.dart';

/// A non-negative payment amount stored exactly in the asset's smallest units.
///
/// This object performs no rounding, conversion, fiat/crypto equivalence, or
/// network calls. Zero is valid here; a transfer policy may require a positive
/// amount. Asset precision must come from a reviewed registry.
final class PaymentAmount {
  factory PaymentAmount({required PaymentAsset asset, required BigInt units}) {
    if (units.isNegative) {
      throw ArgumentError.value(units, 'units', 'Amount cannot be negative');
    }
    return PaymentAmount._(asset, units);
  }

  const PaymentAmount._(this.asset, this.units);

  /// Parses an ASCII decimal amount without ever passing through a double.
  ///
  /// Signs, whitespace, grouping separators, exponent notation, missing integer
  /// or fractional digits, and excess fractional digits are rejected. Even
  /// trailing zeroes beyond the asset precision are rejected rather than being
  /// silently truncated. Leading integer zeroes are accepted and normalized.
  factory PaymentAmount.parse(String value, {required PaymentAsset asset}) {
    final match = _decimalPattern.matchAsPrefix(value);
    if (match == null || match.end != value.length) {
      throw FormatException('Expected an unsigned decimal amount', value);
    }
    final fraction = match.group(2) ?? '';
    if (fraction.length > asset.decimals) {
      throw FormatException('Amount exceeds the asset precision', value);
    }
    final scale = BigInt.from(10).pow(asset.decimals);
    final wholeUnits = BigInt.parse(match.group(1)!) * scale;
    final fractionUnits = fraction.isEmpty
        ? BigInt.zero
        : BigInt.parse(fraction.padRight(asset.decimals, '0'));
    return PaymentAmount._(asset, wholeUnits + fractionUnits);
  }

  static final _decimalPattern = RegExp(r'([0-9]+)(?:\.([0-9]+))?');

  final PaymentAsset asset;
  final BigInt units;

  /// Formats exactly without scientific notation or locale separators.
  ///
  /// By default insignificant fractional zeroes are omitted. Set
  /// [trimTrailingZeros] to false to retain the asset's full precision.
  String format({bool trimTrailingZeros = true}) {
    if (asset.decimals == 0) return units.toString();
    final digits = units.toString().padLeft(asset.decimals + 1, '0');
    final split = digits.length - asset.decimals;
    final whole = digits.substring(0, split);
    var fraction = digits.substring(split);
    if (trimTrailingZeros) {
      fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    }
    return fraction.isEmpty ? whole : '$whole.$fraction';
  }

  @override
  bool operator ==(Object other) =>
      other is PaymentAmount &&
      asset.id == other.asset.id &&
      asset.decimals == other.asset.decimals &&
      units == other.units;

  @override
  int get hashCode => Object.hash(asset.id, asset.decimals, units);
}
