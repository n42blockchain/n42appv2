/// Converts a decimal SUI amount to base units without rounding or truncating
/// any non-zero fractional digits beyond the coin precision.
///
/// Extra trailing zeroes are harmless and are accepted. Returns `null` when
/// non-zero precision would be lost so the caller can reject the amount.
BigInt? suiAmountToBaseUnits(String amount, int decimals) {
  if (decimals < 0) throw ArgumentError.value(decimals, 'decimals');
  final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(amount);
  if (match == null) return null;

  final whole = match.group(1)!;
  final fraction = match.group(2) ?? '';
  if (fraction.length > decimals &&
      fraction.substring(decimals).contains(RegExp(r'[1-9]'))) {
    return null;
  }

  final baseFraction = fraction.length > decimals
      ? fraction.substring(0, decimals)
      : fraction;
  final units = '$whole${baseFraction.padRight(decimals, '0')}';
  return BigInt.parse(units);
}
