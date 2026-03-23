/// Typed representation of a wallet account derived from mnemonic or private key.
class WalletAccount {
  /// Coin identifier (e.g. 'ETH', 'BTC', 'SOL')
  final String coin;

  /// HD derivation path (e.g. "m/44'/60'/0'/0/0")
  final String path;

  /// Address type identifier (e.g. 'legacy', 'segwit', 'taproot')
  final String addressType;

  /// Primary address (legacy for BTC, default for others)
  final String address;

  /// All address variants keyed by type (e.g. {'legacy': '...', 'segwit': '...'})
  final Map<String, String> addresses;

  /// Hex-encoded public key (if available)
  final String? publicKey;

  /// Whether this account was imported (vs derived from HD wallet)
  final bool isImported;

  const WalletAccount({
    required this.coin,
    required this.path,
    required this.addressType,
    required this.address,
    this.addresses = const {},
    this.publicKey,
    this.isImported = false,
  });

  @override
  String toString() => 'WalletAccount($coin, $address)';
}
