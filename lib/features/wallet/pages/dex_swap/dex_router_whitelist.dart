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

/// Result of inspecting a swap calldata's output recipient.
enum SwapRecipientCheck {
  /// Selector recognized and the recipient is the expected owner (or a
  /// safe self-reference constant).
  ok,

  /// Selector recognized but the recipient is a concrete third-party address:
  /// a tampered backend response trying to redirect the swap output.
  mismatch,

  /// Selector not recognized (e.g. 1inch variants, Uniswap multicall/Universal
  /// Router). The router whitelist remains the primary defense; the caller
  /// should log and proceed rather than block a legitimate swap.
  unknown,
}

/// Independent, client-side inspection of DEX swap calldata.
///
/// The router whitelist ([DexRouterWhitelist]) only proves the transaction
/// `to` is an official aggregator router. The output recipient, however, is
/// encoded inside the calldata (Uniswap SwapRouter02 `recipient`, 1inch
/// `dstReceiver`). A compromised or man-in-the-middled backend can keep the
/// router address honest while pointing the recipient at an attacker, routing
/// the swapped tokens out through a trusted router. This guard decodes the
/// recipient for the Uniswap SwapRouter02 exactInput*/exactOutput* selectors
/// the backend actually emits and confirms it is the wallet owner.
///
/// Coverage is intentionally partial: unrecognized selectors return
/// [SwapRecipientCheck.unknown] rather than a false [mismatch], so that new
/// aggregator payloads are never blocked by an incomplete decoder. Extending
/// coverage (notably 1inch `dstReceiver`) is tracked as follow-up.
class DexSwapCalldataGuard {
  DexSwapCalldataGuard._();

  // Uniswap SwapRouter02 selectors → 0-based 32-byte word index (after the
  // 4-byte selector) that holds the `recipient` address.
  static const Map<String, int> _recipientWordBySelector = {
    '04e45aaf': 3, // exactInputSingle(struct) — recipient is the 4th field
    '5023b4df': 3, // exactOutputSingle(struct)
    'b858183f': 2, // exactInput(struct{bytes path, recipient, ...})
    '09b81346': 2, // exactOutput(struct{bytes path, recipient, ...})
  };

  // Recipients that are safe self-references rather than a payout address:
  // 0x0 (defaults to caller on some routers), ADDRESS_THIS (0x1) and
  // MSG_SENDER (0x2) sentinels used by SwapRouter02.
  static const Set<String> _selfRecipients = {
    '0000000000000000000000000000000000000000',
    '0000000000000000000000000000000000000001',
    '0000000000000000000000000000000000000002',
  };

  /// Checks that [calldata]'s output recipient is [expectedOwner].
  static SwapRecipientCheck checkRecipient(
    String calldata,
    String expectedOwner,
  ) {
    var data = calldata.trim().toLowerCase();
    if (data.startsWith('0x')) data = data.substring(2);
    if (data.length < 8) return SwapRecipientCheck.unknown;

    final selector = data.substring(0, 8);
    final wordIndex = _recipientWordBySelector[selector];
    if (wordIndex == null) return SwapRecipientCheck.unknown;

    final wordStart = 8 + wordIndex * 64;
    final wordEnd = wordStart + 64;
    if (data.length < wordEnd) return SwapRecipientCheck.unknown;

    final word = data.substring(wordStart, wordEnd);
    // An address occupies the low 20 bytes (last 40 hex chars) of the word.
    final recipient = word.substring(24);

    var owner = expectedOwner.trim().toLowerCase();
    if (owner.startsWith('0x')) owner = owner.substring(2);

    if (recipient == owner || _selfRecipients.contains(recipient)) {
      return SwapRecipientCheck.ok;
    }
    return SwapRecipientCheck.mismatch;
  }
}
