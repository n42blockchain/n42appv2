/// Result of a transaction signing operation.
class SigningResult {
  /// Hex-encoded signed transaction hash/data
  final String rawTx;

  /// Whether signing succeeded
  bool get success => rawTx.isNotEmpty;

  const SigningResult({required this.rawTx});

  const SigningResult.empty() : rawTx = '';

  @override
  String toString() => 'SigningResult(success: $success, len: ${rawTx.length})';
}

/// Result of a byte-array transaction signing operation (e.g. Solana, Aptos).
class ByteArraySigningResult {
  final bool success;
  final String signHash;

  const ByteArraySigningResult({
    required this.success,
    required this.signHash,
  });

  const ByteArraySigningResult.empty()
      : success = false,
        signHash = '';

  factory ByteArraySigningResult.fromMap(Map<dynamic, dynamic> map) {
    return ByteArraySigningResult(
      success: map['result'] == true,
      signHash: (map['signHash'] as String?) ?? '',
    );
  }
}
