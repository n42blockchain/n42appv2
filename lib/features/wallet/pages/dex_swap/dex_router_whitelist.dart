/// 客户端 DEX router 白名单。
///
/// swap 报价里的 `routerAddr`（交易 `to` / approve 的 spender）来自后端
/// `api.n42.ai/swap`。若后端被攻破或响应被中间人篡改，攻击者可把 router 换成
/// 恶意合约、把 calldata 换成掏空授权额度的调用——用户过一次密码即被导走资金。
/// 因此在签名/广播前，必须由客户端独立校验 router 是否属于已知聚合器路由，
/// 不能盲信后端返回值。
///
/// 白名单收录后端 `backend/swap/services/` 实际使用的路由：
///   - Uniswap SwapRouter02（`uniswap.go` 硬编码，各 EVM 链同址）
///   - 1inch AggregationRouterV6（1inch 返回 `Tx.To`，各链经 CREATE2 同址）
/// 新增聚合器/路由时同步更新此表。
class DexRouterWhitelist {
  DexRouterWhitelist._();

  /// 允许的 router / spender 地址（全部小写、去 0x 便于比对）。
  static final Set<String> _allowed = {
    // Uniswap SwapRouter02
    '68b3465833fb72a70ecdf485e0e4c7bd8665fc45',
    // 1inch AggregationRouterV6
    '111111125421ca6dc452d289314280a0f8842a65',
  }.map((a) => a.toLowerCase()).toSet();

  /// [addr] 是否为受信任的 router / spender。
  static bool isTrusted(String? addr) {
    if (addr == null) return false;
    var clean = addr.trim().toLowerCase();
    if (clean.startsWith('0x')) clean = clean.substring(2);
    if (clean.length != 40) return false;
    return _allowed.contains(clean);
  }
}
