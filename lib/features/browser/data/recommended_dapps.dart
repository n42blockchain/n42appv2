/// Recommended DApp directory — curated list of popular Web3 DApps.
///
/// Each entry contains: name, URL, description, category, and an optional icon URL.
/// Categories are used for tab/section filtering in the DApp discovery page.
class DAppCategory {
  final String key;
  final String labelEn;

  const DAppCategory._(this.key, this.labelEn);

  static const popular = DAppCategory._('popular', 'Popular');
  static const dex = DAppCategory._('dex', 'DEX');
  static const defi = DAppCategory._('defi', 'DeFi');
  static const nft = DAppCategory._('nft', 'NFT');
  static const bridge = DAppCategory._('bridge', 'Bridge');
  static const tools = DAppCategory._('tools', 'Tools');

  static const List<DAppCategory> all = [
    popular,
    dex,
    defi,
    nft,
    bridge,
    tools,
  ];
}

class RecommendedDApp {
  final String name;
  final String url;
  final String description;
  final DAppCategory category;
  final bool isPopular;

  const RecommendedDApp({
    required this.name,
    required this.url,
    required this.description,
    required this.category,
    this.isPopular = false,
  });
}

class RecommendedDApps {
  RecommendedDApps._();

  static const List<RecommendedDApp> all = [
    // ── DEX ──────────────────────────────────────────────────────────
    RecommendedDApp(
      name: 'Uniswap',
      url: 'https://app.uniswap.org',
      description: 'Largest decentralized exchange on Ethereum',
      category: DAppCategory.dex,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'PancakeSwap',
      url: 'https://pancakeswap.finance',
      description: 'DEX on BNB Chain, Ethereum & more',
      category: DAppCategory.dex,
      isPopular: true,
    ),
    RecommendedDApp(
      name: '1inch',
      url: 'https://app.1inch.io',
      description: 'DEX aggregator for best swap rates',
      category: DAppCategory.dex,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'SushiSwap',
      url: 'https://www.sushi.com/swap',
      description: 'Multi-chain DEX and DeFi platform',
      category: DAppCategory.dex,
    ),
    RecommendedDApp(
      name: 'Curve',
      url: 'https://curve.fi',
      description: 'Stablecoin exchange with low slippage',
      category: DAppCategory.dex,
    ),

    // ── DeFi ─────────────────────────────────────────────────────────
    RecommendedDApp(
      name: 'Aave',
      url: 'https://app.aave.com',
      description: 'Lending and borrowing protocol',
      category: DAppCategory.defi,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'Lido',
      url: 'https://stake.lido.fi',
      description: 'Liquid staking for ETH',
      category: DAppCategory.defi,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'Compound',
      url: 'https://app.compound.finance',
      description: 'Algorithmic interest rate protocol',
      category: DAppCategory.defi,
    ),
    RecommendedDApp(
      name: 'Yearn',
      url: 'https://yearn.fi',
      description: 'Yield optimization vaults',
      category: DAppCategory.defi,
    ),
    RecommendedDApp(
      name: 'EigenLayer',
      url: 'https://app.eigenlayer.xyz',
      description: 'Restaking protocol for Ethereum',
      category: DAppCategory.defi,
    ),

    // ── NFT ──────────────────────────────────────────────────────────
    RecommendedDApp(
      name: 'OpenSea',
      url: 'https://opensea.io',
      description: 'Largest NFT marketplace',
      category: DAppCategory.nft,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'Blur',
      url: 'https://blur.io',
      description: 'Pro NFT marketplace & aggregator',
      category: DAppCategory.nft,
    ),
    RecommendedDApp(
      name: 'Zora',
      url: 'https://zora.co',
      description: 'NFT minting and collecting',
      category: DAppCategory.nft,
    ),

    // ── Bridge ───────────────────────────────────────────────────────
    RecommendedDApp(
      name: 'Stargate',
      url: 'https://stargate.finance',
      description: 'Cross-chain bridge powered by LayerZero',
      category: DAppCategory.bridge,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'Across',
      url: 'https://across.to',
      description: 'Fast cross-chain bridge',
      category: DAppCategory.bridge,
    ),
    RecommendedDApp(
      name: 'Orbiter Finance',
      url: 'https://www.orbiter.finance',
      description: 'Cross-rollup bridge for L2',
      category: DAppCategory.bridge,
    ),

    // ── Tools ────────────────────────────────────────────────────────
    RecommendedDApp(
      name: 'Etherscan',
      url: 'https://etherscan.io',
      description: 'Ethereum blockchain explorer',
      category: DAppCategory.tools,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'DeBank',
      url: 'https://debank.com',
      description: 'DeFi portfolio tracker',
      category: DAppCategory.tools,
      isPopular: true,
    ),
    RecommendedDApp(
      name: 'Revoke.cash',
      url: 'https://revoke.cash',
      description: 'Token approval manager',
      category: DAppCategory.tools,
    ),
    RecommendedDApp(
      name: 'Dune Analytics',
      url: 'https://dune.com',
      description: 'On-chain data analytics',
      category: DAppCategory.tools,
    ),
  ];

  /// Get DApps by category. For [DAppCategory.popular] returns all with isPopular=true.
  static List<RecommendedDApp> byCategory(DAppCategory category) {
    if (category.key == DAppCategory.popular.key) {
      return all.where((d) => d.isPopular).toList();
    }
    return all.where((d) => d.category.key == category.key).toList();
  }
}
