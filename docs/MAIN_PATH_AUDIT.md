# 主路径暗坑审计记录（2026-06-12）

对应 `CLEANUP_PLAN.md` 阶段 3。四条主路径并行审计（启动链 / 转账 /
WalletConnect / JS bridge），共 32 项原始发现；逐项裁决后**实修 10 项、
误报 9 项、记录待办 13 项**。通知路径的审计与修复见
`PUSH_NOTIFICATIONS.md`（更早完成，方法论来源）。

## 已修复（本轮提交）

### 转账资金路径（从严标准）
1. **金额精度**：`_parseValue` 原用 `BigInt.from((v * 1e18).round())`，
   double 53 位尾数在 v>9 即丢精度 → 新 `decimal_amount.dart` 十进制
   字符串移位，无损转换 + 多余位向零截断（宁少转不多转）。带 14 项测试。
2. **超时双花**：AA 转账 `waitForReceipt` 超时曾被报成「失败」——
   UserOp 已广播、可能上链，用户重试 = 同 nonce 第二笔。现单独捕获
   `ReceiptTimeoutError`，返回「已提交待确认，勿重发」语义 + userOpHash。
3. **nonce 并发竞态**：nonce 查询到广播之间无互斥，快速双击双花。
   新 `transfer_serializer.dart` per-`chain:address` 串行化，接入
   AA handler 与 EvmSender 发送入口。带 4 项并发测试。
4. **nonce 静默归零**：`_getNonce` 失败曾返回 `BigInt.zero`（必然
   nonce-too-low 或撞历史 nonce）→ 改为抛 `UserOperationBuildError` 中止。
5. **token decimals 默认 18**：ERC20 转账 `decimals ?? 18` 对 USDC
   （decimals=6）= 金额偏差 12 个数量级 → 严格解析（int/String），缺失或
   越界即报错；同时修复 String 型 decimals 的潜在 runtime cast 炸点。
6. 错误日志升级：AA 错误从 `w` 升 `e` 并带 stackTrace。

### 启动链
7. **AppPushUtils.init() 幂等守卫**（防 listener 双注册/回调覆盖）。
8. 钱包数据迁移失败日志 w→e（静默失败资金相关，必须可见）。

### 测试健康（审计过程中顺手发现）
9. `n_testnet_balance_rpc_test` 与实现语义脱节（实现已演进为「所有 EVM
   标准链走注册表规范 RPC」）→ 按现语义重写 4 用例。该测试曾
   **顺序依赖**（单跑失败、全量靠先行测试初始化才过）。
10. `benchmark_results/` 实为每次跑测试重新生成的产物 → 移出版本控制
    （`.gitignore`），更正阶段 1 的「数据刷新提交」误判。

## 标注（designed but not wired）

- `browser/js/ethereum_provider.dart`：**整个 in-page web3 provider 未接
  线**——`buildProviderScript` 零调用点、`N42Wallet` JavaScriptChannel 无人
  注册。DApp 实际经 WalletConnect 连接。`DAppRequestHandler`（含完善的
  方法白名单、eth_sign 拒绝）实现完整但不可达。已加文件头状态注释与
  接线步骤。
- `core/security/dapp_security_service.dart`：安全评分框架零调用（签名流
  程从不 `check()`）；PhishingDetector 在导航路径是活的。已加状态注释。

## 误报（裁决不修，留档防止重复审计）

- 启动链「configureDependencies 失败后续继续执行」：`await` 抛出即终止
  main()，fail-fast 正确。
- 启动链「后台 isolate 访问 globalProviderContainer」：后台路径已用
  `_updateBadgeCountBackground`（不碰 Riverpod），通知修复时已处理。
- 启动链「deepLinkServiceProvider 会重复创建」：Riverpod Provider 在
  container 生命周期内缓存，不随 rebuild 重建。
- 启动链「权限拒绝应 throw」「迁移失败应 throw」「钓鱼检测失败应
  throw」：用户拒绝权限是合法状态、启动期 throw 比降级更糟，全部驳回。
- WC「重连风暴」：`scheduleReconnect` 达上限后 early return 不再建
  Timer，已收敛。
- WC「keychain 清理与迁移竞态」：`await _clearKeychainOnFreshInstall()`
  在 `unawaited(_migrateWalletData())` 之前完成，顺序已保证。

## 记录待办（修复需配真机验证或属产品工程，未在本轮做）

| # | 路径 | 问题 | 条件 |
|---|------|------|------|
| W1 | WalletConnect | 事件订阅在 dispose 不取消（全局单例 dispose 罕见，实际触发窗口小） | 与 W2 一起做，配真机回归 |
| W2 | WalletConnect | 并发签名请求覆盖全局 `actionData`，拒绝可能误伤另一请求 → 需请求队列化（触及 UI 状态机） | 真机验证（Codex 任务可加） |
| W3 | WalletConnect | 冷启动会话恢复与新 pair 的竞态 | 同上 |
| T1 | 转账 | BTC 预取 UTXO 过期（多设备/长停留场景） | 需 UI 流程配合 |
| T2 | 转账 | AA gas 估算失败回退硬编码 150k/22Gwei（UI 层） | 需链级默认值表 |
| J1 | Browser | JS bridge 接线（产品功能工程，非清理） | 产品排期 |
| J2 | Browser | DAppSecurityService 接入签名流程 | 随 J1 |
| P1 | Prediction | 12 条 `_todo()` 全部为「占位等合约」，调用方 UI 可达、mock switch 设计良好，保留 | 合约团队交付 ABI 后切换 |
