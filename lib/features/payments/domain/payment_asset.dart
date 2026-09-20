/// A payment asset's identity, independent of its display symbol.
///
/// This is a local identifier, not a CAIP serialization or an asset allowlist.
/// EIP-155 chain references and contract addresses are canonicalized. Other
/// namespaces preserve network/address case because their encodings may be
/// case-sensitive. A null contract identifies the network's native asset.
final class PaymentAssetId {
  factory PaymentAssetId({
    required String namespace,
    required String network,
    required String? contract,
  }) {
    final canonicalNamespace = namespace.toLowerCase();
    if (!_matches(_namespacePattern, canonicalNamespace)) {
      throw ArgumentError.value(namespace, 'namespace', 'Invalid namespace');
    }
    if (!_matches(_referencePattern, network)) {
      throw ArgumentError.value(
        network,
        'network',
        'Invalid network reference',
      );
    }
    if (contract != null && !_matches(_referencePattern, contract)) {
      throw ArgumentError.value(
        contract,
        'contract',
        'Invalid asset reference',
      );
    }

    var canonicalNetwork = network;
    var canonicalContract = contract;
    if (canonicalNamespace == 'eip155') {
      if (!_matches(_chainIdPattern, network) ||
          BigInt.parse(network) <= BigInt.zero) {
        throw ArgumentError.value(
          network,
          'network',
          'Expected positive EIP-155 chain ID',
        );
      }
      canonicalNetwork = BigInt.parse(network).toString();
      if (contract != null) {
        if (!_matches(_evmAddressPattern, contract)) {
          throw ArgumentError.value(
            contract,
            'contract',
            'Expected 20-byte EVM address',
          );
        }
        canonicalContract = contract.toLowerCase();
      }
    }
    return PaymentAssetId._(
      canonicalNamespace,
      canonicalNetwork,
      canonicalContract,
    );
  }

  const PaymentAssetId._(this.namespace, this.network, this.contract);

  static final _namespacePattern = RegExp(r'[a-z][a-z0-9-]{0,31}');
  static final _referencePattern = RegExp(r'[a-zA-Z0-9_-]{1,128}');
  static final _chainIdPattern = RegExp(r'[0-9]+');
  static final _evmAddressPattern = RegExp(
    r'0x[0-9a-f]{40}',
    caseSensitive: false,
  );

  static bool _matches(RegExp pattern, String value) {
    final match = pattern.matchAsPrefix(value);
    return match != null && match.end == value.length;
  }

  final String namespace;
  final String network;
  final String? contract;

  bool get isNative => contract == null;

  /// Unambiguous stable key for local maps and comparisons.
  String get canonicalId => contract == null
      ? '$namespace:$network/native'
      : '$namespace:$network/contract:$contract';

  @override
  bool operator ==(Object other) =>
      other is PaymentAssetId &&
      namespace == other.namespace &&
      network == other.network &&
      contract == other.contract;

  @override
  int get hashCode => Object.hash(namespace, network, contract);

  @override
  String toString() => canonicalId;
}

/// Metadata supplied by a reviewed asset registry, never inferred from symbol.
///
/// Construction validates representation only. It does not establish issuer
/// authenticity, network support, or approval for a payment operation.
final class PaymentAsset {
  factory PaymentAsset({
    required PaymentAssetId id,
    required String symbol,
    required int decimals,
  }) {
    if (decimals < 0 || decimals > 255) {
      throw RangeError.range(decimals, 0, 255, 'decimals');
    }
    if (symbol.trim().isEmpty) {
      throw ArgumentError.value(symbol, 'symbol', 'Display symbol is required');
    }
    return PaymentAsset._(id, symbol.trim(), decimals);
  }

  const PaymentAsset._(this.id, this.symbol, this.decimals);

  final PaymentAssetId id;
  final String symbol;
  final int decimals;
}
