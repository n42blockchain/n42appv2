// Copyright 2021-2026 N42 Inc. All rights reserved.

// Decimal representation of MaxUint256
final BigInt txRiskMaxUint256 = BigInt.parse(
  '115792089237316195423570985008687907853269984665640564039457584007913129639935',
);

/// Decode a 32-byte ABI-padded address (64 hex chars) to "0x..." form.
String txRiskDecodeAddress(String padded) {
  if (padded.length < 40) return '0x${padded.padLeft(40, '0')}';
  return '0x${padded.substring(padded.length - 40)}';
}

/// Returns true if the 64-char hex uint256 equals MaxUint256.
bool txRiskIsMaxUint256(String hex64) {
  try {
    final clean = hex64.replaceAll(RegExp(r'^0+'), '').toLowerCase();
    if (clean.isEmpty) return false;
    final bi = BigInt.parse(clean, radix: 16);
    return bi == txRiskMaxUint256;
  } catch (_) {
    return false;
  }
}

/// Returns true if a permit `value` field equals or exceeds MaxUint256.
bool txRiskIsUnlimitedPermitValue(dynamic value) {
  if (value == null) return false;
  try {
    return BigInt.parse(value.toString()) >= txRiskMaxUint256;
  } catch (_) {
    return false;
  }
}

/// Format a hex uint256 (64 chars) as a readable decimal or abbreviated form.
String txRiskFormatAmount(String hex64) {
  if (txRiskIsMaxUint256(hex64)) return 'Unlimited ∞';
  try {
    final clean = hex64.replaceAll(RegExp(r'^0+'), '');
    if (clean.isEmpty) return '0';
    final bi = BigInt.parse(clean, radix: 16);
    if (bi == BigInt.zero) return '0';
    final decimal = bi.toString();
    if (decimal.length > 20) {
      // Very large — likely raw token units; show abbreviated
      return '${decimal.substring(0, 6)}…${decimal.substring(decimal.length - 4)}';
    }
    return decimal;
  } catch (_) {
    return '0x${hex64.substring(0, 8)}…';
  }
}

/// Format hex wei value (e.g. "0x38d7ea4c68000") to human-readable ETH.
String txRiskFormatHexWei(String hexValue) {
  try {
    final clean = hexValue.startsWith('0x') ? hexValue.substring(2) : hexValue;
    if (clean.isEmpty || clean == '0') return '0 ETH';
    final wei = BigInt.parse(clean, radix: 16);
    if (wei == BigInt.zero) return '0 ETH';
    // 1 ETH = 10^18 wei — show up to 6 decimal places
    final divisor = BigInt.from(10).pow(18);
    final whole = wei ~/ divisor;
    final remainder = wei.remainder(divisor);
    if (remainder == BigInt.zero) return '$whole ETH';
    // Pad remainder to 18 digits, then take first 6 for display
    final fracStr = remainder.toString().padLeft(18, '0').substring(0, 6);
    final trimmed = fracStr.replaceAll(RegExp(r'0+$'), '');
    return '$whole.${trimmed.isEmpty ? '0' : trimmed} ETH';
  } catch (_) {
    return hexValue;
  }
}

/// Truncate an address to 0x1234…5678 format.
String txRiskFormatAddress(String addr) {
  if (addr.length <= 12) return addr;
  return '${addr.substring(0, 8)}…${addr.substring(addr.length - 6)}';
}

/// Format a Unix timestamp deadline into human-readable expiry.
String txRiskFormatDeadline(dynamic deadline) {
  try {
    final ts = int.parse(deadline.toString());
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day $hour:$minute';
  } catch (_) {
    return deadline.toString();
  }
}
