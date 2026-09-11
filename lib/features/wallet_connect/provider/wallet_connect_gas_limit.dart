/// Reads the JSON-RPC gas cap, retaining the legacy gasLimit alias.
///
/// An explicitly malformed cap must never become null: web3dart treats null as
/// permission to estimate a different cap. Keep integers exact on mobile/web.
int? walletConnectGasLimit(Map<String, dynamic> transaction) {
  final value = transaction['gas'] ?? transaction['gasLimit'];
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Gas limit must be a quantity string');
  }
  final hex = value.startsWith('0x') || value.startsWith('0X');
  final digits = hex ? value.substring(2) : value;
  final pattern = hex ? RegExp(r'^[0-9a-fA-F]+$') : RegExp(r'^[0-9]+$');
  final parsed = pattern.hasMatch(digits)
      ? BigInt.tryParse(digits, radix: hex ? 16 : 10)
      : null;
  if (parsed == null || parsed > BigInt.from(9007199254740991)) {
    throw const FormatException('Invalid gas limit');
  }
  return parsed.toInt();
}
