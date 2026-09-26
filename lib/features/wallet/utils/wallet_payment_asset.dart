/// Compares asset identifiers using chain-aware address casing rules.
///
/// EVM contract addresses are case-insensitive. Identifiers from other chains
/// (such as Solana mints) remain case-sensitive.
bool sameWalletPaymentAssetId(String? left, String? right) {
  final normalizedLeft = left?.trim();
  final normalizedRight = right?.trim();
  if (normalizedLeft == null ||
      normalizedRight == null ||
      normalizedLeft.isEmpty ||
      normalizedRight.isEmpty) {
    return false;
  }

  const evmContract = r'^0x[0-9a-fA-F]{40}$';
  final evmContractPattern = RegExp(evmContract);
  if (evmContractPattern.hasMatch(normalizedLeft) &&
      evmContractPattern.hasMatch(normalizedRight)) {
    return normalizedLeft.toLowerCase() == normalizedRight.toLowerCase();
  }
  return normalizedLeft == normalizedRight;
}

/// Validates a positive decimal amount without floating-point conversion.
///
/// This rejects scientific notation, signs, zero, and values with more
/// fractional digits than the asset supports.
bool isPositiveWalletPaymentAmountForDecimals(String amount, int decimals) {
  final normalized = amount.trim();
  if (decimals < 0 || !RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) {
    return false;
  }

  final decimalPoint = normalized.indexOf('.');
  if (decimalPoint >= 0 && normalized.length - decimalPoint - 1 > decimals) {
    return false;
  }
  return normalized.replaceAll('.', '').contains(RegExp(r'[1-9]'));
}
