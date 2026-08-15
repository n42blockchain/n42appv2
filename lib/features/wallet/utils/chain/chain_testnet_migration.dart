/// 已有钱包的测试网开关迁移（供 `_syncNewChains` 对**每条链**调用）。
///
/// `supportTest` 决定该链是否暴露测试网切换入口。历史上它不参与同步，已创建
/// 的钱包会永远保留建钱包时的旧值：链后来打开测试网（BNB/TRX 2026-08 修正）
/// 或关闭测试网（ATOM）都传导不到运行时。第一次修复时该逻辑被误放进
/// `chainKey == CoinType.S.name` 的 Sonic 专用分支——七测真机证实旧钱包的
/// BNB/TRX 永远不更新。现提取为纯函数并单测锁定，任何链都必须走到。
///
/// 返回是否发生了修改（调用方据此决定是否落盘）。
bool syncChainTestnetFlags(Map storedChain, Map chainConfig) {
  var changed = false;

  if (chainConfig.containsKey('supportTest') &&
      storedChain['supportTest'] != chainConfig['supportTest']) {
    storedChain['supportTest'] = chainConfig['supportTest'];
    changed = true;
  }

  // 若该链已不支持测试网，必须把停留在测试网的钱包拉回主网，否则会卡在
  // 一个没有入口可切回、且 RPC/chainId 均不可用的状态。
  if (chainConfig['supportTest'] == false && storedChain['isTest'] == true) {
    storedChain['isTest'] = false;
    changed = true;
  }

  return changed;
}
