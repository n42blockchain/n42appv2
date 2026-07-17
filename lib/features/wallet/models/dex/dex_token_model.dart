class DexTokenModel {
  final String address;
  final String symbol;
  final String name;
  final String logoUri;
  final int decimals;
  final String chain;

  const DexTokenModel({
    required this.address,
    required this.symbol,
    required this.name,
    required this.logoUri,
    required this.decimals,
    required this.chain,
  });

  factory DexTokenModel.fromJson(Map<String, dynamic> json) => DexTokenModel(
    address: json['address'] as String? ?? '',
    symbol: json['symbol'] as String? ?? '',
    name: json['name'] as String? ?? '',
    logoUri: json['logo_uri'] as String? ?? '',
    decimals: json['decimals'] as int? ?? 18,
    chain: json['chain'] as String? ?? '',
  );
}

/// Small, audited token set used only when the DEX token-list service is down.
///
/// The swap quote remains server-authoritative; this fallback merely keeps token
/// selection usable while that service is unavailable. Addresses are canonical
/// mainnet contracts (or the native SOL mint) for the supported DEX chains.
class DexFallbackTokens {
  DexFallbackTokens._();

  static const _logoBase = 'https://api.n42.ai/market/v1/r/coinImage';

  static List<DexTokenModel> forChain(String chain) {
    switch (chain.toUpperCase()) {
      case 'ETH':
        return _evm(
          chain: 'ETH',
          nativeAddress: '0xC02aaA39b223FE8D0A0E5C4F27eAD9083C756Cc2',
          nativeSymbol: 'WETH',
          nativeName: 'Wrapped Ether',
          usdt: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
          usdc: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
        );
      case 'BSC':
        return _evm(
          chain: 'BSC',
          nativeAddress: '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c',
          nativeSymbol: 'WBNB',
          nativeName: 'Wrapped BNB',
          usdt: '0x55d398326f99059fF775485246999027B3197955',
          usdc: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
          stableDecimals: 18,
        );
      case 'POLYGON':
        return _evm(
          chain: 'POLYGON',
          nativeAddress: '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270',
          nativeSymbol: 'WMATIC',
          nativeName: 'Wrapped Matic',
          usdt: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
          usdc: '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359',
        );
      case 'ARB':
        return _evm(
          chain: 'ARB',
          nativeAddress: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
          nativeSymbol: 'WETH',
          nativeName: 'Wrapped Ether',
          usdt: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9',
          usdc: '0xaf88d065e77c8cC2239327C5EDb3A432268e5831',
        );
      case 'OP':
        return _evm(
          chain: 'OP',
          nativeAddress: '0x4200000000000000000000000000000000000006',
          nativeSymbol: 'WETH',
          nativeName: 'Wrapped Ether',
          usdt: '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58',
          usdc: '0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85',
        );
      case 'BASE':
        return _evm(
          chain: 'BASE',
          nativeAddress: '0x4200000000000000000000000000000000000006',
          nativeSymbol: 'WETH',
          nativeName: 'Wrapped Ether',
          usdt: '0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2',
          usdc: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
        );
      case 'SOL':
        return const [
          DexTokenModel(
            address: 'So11111111111111111111111111111111111111112',
            symbol: 'SOL',
            name: 'Wrapped SOL',
            logoUri: 'https://api.n42.ai/market/v1/r/coinImage/SOL.png',
            decimals: 9,
            chain: 'SOL',
          ),
          DexTokenModel(
            address: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
            symbol: 'USDC',
            name: 'USD Coin',
            logoUri: 'https://api.n42.ai/market/v1/r/coinImage/USDC.png',
            decimals: 6,
            chain: 'SOL',
          ),
          DexTokenModel(
            address: 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
            symbol: 'USDT',
            name: 'Tether USD',
            logoUri: 'https://api.n42.ai/market/v1/r/coinImage/USDT.png',
            decimals: 6,
            chain: 'SOL',
          ),
        ];
      default:
        return const [];
    }
  }

  static List<DexTokenModel> _evm({
    required String chain,
    required String nativeAddress,
    required String nativeSymbol,
    required String nativeName,
    required String usdt,
    required String usdc,
    int stableDecimals = 6,
  }) => [
    _token(
      address: nativeAddress,
      symbol: nativeSymbol,
      name: nativeName,
      chain: chain,
    ),
    _token(
      address: usdt,
      symbol: 'USDT',
      name: 'Tether USD',
      decimals: stableDecimals,
      chain: chain,
    ),
    _token(
      address: usdc,
      symbol: 'USDC',
      name: 'USD Coin',
      decimals: stableDecimals,
      chain: chain,
    ),
  ];

  static DexTokenModel _token({
    required String address,
    required String symbol,
    required String name,
    required String chain,
    int decimals = 18,
  }) => DexTokenModel(
    address: address,
    symbol: symbol,
    name: name,
    logoUri: '$_logoBase/$symbol.png',
    decimals: decimals,
    chain: chain,
  );
}
