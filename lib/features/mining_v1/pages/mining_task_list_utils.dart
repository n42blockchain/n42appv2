BigInt? parseMiningNumericValue(dynamic rawValue) {
  final raw = rawValue?.toString().trim() ?? '';
  if (raw.isEmpty) return null;
  if (raw.startsWith('0x') || raw.startsWith('0X')) {
    return BigInt.tryParse(raw.substring(2), radix: 16);
  }
  return BigInt.tryParse(raw);
}

String? buildPreviousMiningBlockCursor(dynamic blockNumber) {
  final parsed = parseMiningNumericValue(blockNumber);
  if (parsed == null || parsed <= BigInt.zero) return null;
  return '0x${(parsed - BigInt.one).toRadixString(16)}';
}

String formatMiningBlockNumber(dynamic blockNumber) {
  return parseMiningNumericValue(blockNumber)?.toString() ?? '';
}
