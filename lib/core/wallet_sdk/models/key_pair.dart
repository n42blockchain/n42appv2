/// Hex-encoded private/public key pair.
class KeyPair {
  final String privateKey;
  final String publicKey;

  const KeyPair({required this.privateKey, required this.publicKey});

  bool get isEmpty => privateKey.isEmpty && publicKey.isEmpty;

  @override
  String toString() => 'KeyPair(pub: ${publicKey.length > 8 ? '${publicKey.substring(0, 8)}...' : publicKey})';
}
