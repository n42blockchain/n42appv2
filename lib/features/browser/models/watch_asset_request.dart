import 'package:wallet/wallet.dart';

/// A validated asset suggestion. Caller metadata remains untrusted display data.
class WatchAssetRequest {
  final EthereumAddress address;
  final int chainId;
  final String? suggestedSymbol;
  final int? suggestedDecimals;

  const WatchAssetRequest._({
    required this.address,
    required this.chainId,
    this.suggestedSymbol,
    this.suggestedDecimals,
  });

  factory WatchAssetRequest.parse(
    List<dynamic> params,
    int activeChainId, {
    Set<int>? supportedChainIds,
  }) {
    Never invalid(String message) => throw {'code': -32602, 'message': message};
    if (params.length != 1 || params.single is! Map) {
      invalid('Expected one asset suggestion');
    }
    final request = params.single as Map;
    if (request['type'] != 'ERC20') {
      throw {'code': 4200, 'message': 'Unsupported asset type'};
    }
    final options = request['options'];
    if (options is! Map) invalid('Missing asset options');
    final rawAddress = options['address'];
    if (rawAddress is! String ||
        !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(rawAddress)) {
      invalid('Expected a checksummed token contract address');
    }
    late final EthereumAddress address;
    try {
      address = EthereumAddress.fromHex(rawAddress, enforceEip55: true);
      if (address.eip55With0x != rawAddress) {
        invalid('Invalid token contract checksum');
      }
    } on ArgumentError {
      invalid('Invalid token contract checksum');
    }
    final requestedChain = options['chainId'] ?? activeChainId;
    if (requestedChain is! int ||
        requestedChain <= 0 ||
        requestedChain > 9007199254740991) {
      invalid('Invalid asset chain ID');
    }
    if (!(supportedChainIds ?? {activeChainId}).contains(requestedChain)) {
      throw {
        'code': 4902,
        'message': 'Asset chain is not supported by this wallet',
      };
    }
    final symbol = options['symbol'];
    if (symbol != null &&
        (symbol is! String ||
            symbol.trim().isEmpty ||
            symbol.length > 32 ||
            RegExp(r'[\x00-\x1f\x7f]').hasMatch(symbol))) {
      invalid('Invalid suggested token symbol');
    }
    final decimals = options['decimals'];
    if (decimals != null &&
        (decimals is! int || decimals < 0 || decimals > 255)) {
      invalid('Invalid suggested token decimals');
    }
    // Caller-provided image URLs are deliberately not downloaded. Contract
    // metadata must be verified by the native flow before showing approval.
    return WatchAssetRequest._(
      address: address,
      chainId: requestedChain,
      suggestedSymbol: symbol as String?,
      suggestedDecimals: decimals as int?,
    );
  }
}
