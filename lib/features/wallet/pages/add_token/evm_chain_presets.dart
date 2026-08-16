/// 热门 EVM 兼容链预设（「添加链」表单的一键填充建议）。
///
/// 仅收录**内建注册表没有**的知名 EVM 链（内建 36 条见
/// wallet_chain_configs_part*，新增预设前先去重）。预设只负责把表单填好，
/// 提交仍走完整校验（https 强制、chainId 判重、RPC 探活、`eth_chainId`
/// 交叉校验）——即使某个预设 RPC 日后失效或迁移，也会在提交时被拦下，
/// 不会把坏链写进钱包。
///
/// 注意：这与 2026-08-15 删除的死系统 `popular_chain_presets`（依赖从未
/// 可达的 CustomChainService）无关——本文件服务于真实可达的
/// `WalletChainAdd` 路径。
class EvmChainPreset {
  final String name;
  final String symbol;
  final int chainId;
  final String rpcUrl;
  final String explorerUrl;
  final int decimals;

  const EvmChainPreset({
    required this.name,
    required this.symbol,
    required this.chainId,
    required this.rpcUrl,
    required this.explorerUrl,
    this.decimals = 18,
  });
}

const List<EvmChainPreset> evmChainPresets = [
  EvmChainPreset(
    name: 'CELO',
    symbol: 'CELO',
    chainId: 42220,
    rpcUrl: 'https://forno.celo.org',
    explorerUrl: 'https://celoscan.io/',
  ),
  EvmChainPreset(
    name: 'MOONBEAM',
    symbol: 'GLMR',
    chainId: 1284,
    rpcUrl: 'https://rpc.api.moonbeam.network',
    explorerUrl: 'https://moonscan.io/',
  ),
  EvmChainPreset(
    name: 'AURORA',
    symbol: 'AURORA',
    chainId: 1313161554,
    rpcUrl: 'https://mainnet.aurora.dev',
    explorerUrl: 'https://explorer.aurora.dev/',
  ),
  EvmChainPreset(
    name: 'METIS',
    symbol: 'METIS',
    chainId: 1088,
    rpcUrl: 'https://andromeda.metis.io/?owner=1088',
    explorerUrl: 'https://explorer.metis.io/',
  ),
  EvmChainPreset(
    name: 'CORE',
    symbol: 'CORE',
    chainId: 1116,
    rpcUrl: 'https://rpc.coredao.org',
    explorerUrl: 'https://scan.coredao.org/',
  ),
  // 注意：表单把 symbol 同时用作 mKey 与计价单位，gas 币为 ETH 的 L2
  // （Zora/Mode/Manta 等）会与内建 ETH 撞 key，故预设只收 gas 币拥有
  // 独立 symbol 的链。
  EvmChainPreset(
    name: 'X LAYER',
    symbol: 'OKB',
    chainId: 196,
    rpcUrl: 'https://rpc.xlayer.tech',
    explorerUrl: 'https://www.oklink.com/xlayer/',
  ),
  EvmChainPreset(
    name: 'MOONRIVER',
    symbol: 'MOVR',
    chainId: 1285,
    rpcUrl: 'https://rpc.api.moonriver.moonbeam.network',
    explorerUrl: 'https://moonriver.moonscan.io/',
  ),
  EvmChainPreset(
    name: 'ROOTSTOCK',
    symbol: 'RBTC',
    chainId: 30,
    rpcUrl: 'https://public-node.rsk.co',
    explorerUrl: 'https://explorer.rootstock.io/',
  ),
];
