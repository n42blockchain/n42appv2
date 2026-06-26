/// 不支持 EIP-1559 的 EVM 链（使用固定 gasPrice 模型）。
/// 默认所有 EVM 链支持 1559，此处列出例外。
///
/// - GO     : GoChain，旧架构，无 1559
/// - OKT    : OKC，固定 gasPrice 模型
/// - KCS    : KuCoin Chain，自定义费用模型
/// - VIC    : Viction (TomoChain)，PoSV 共识，无 1559
/// - ETC    : Ethereum Classic，明确拒绝 EIP-1559
///
/// 已移除的历史条目：
/// - KLAY   : Klaytn 升级为 Kaia（2024）后已支持 1559
/// - METIS  : Metis 已升级支持 1559
const _noEip1559Chains = {'GO', 'OKT', 'KCS', 'VIC', 'ETC'};

bool get1559WithChainSymbol(String symbol) =>
    !_noEip1559Chains.contains(symbol);
