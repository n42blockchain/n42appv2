# 真机六测 · 测试网链上验证 — 2026-08-15

## 范围与结论

- 测试基线：`master@173fe0618b9a15ddb868cabe57e0be4ce03605d4`，与 `origin/master` 一致。
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- Android 安装阻塞本轮已经解除，Android 与 iOS 真机探针均通过。
- 结论：本轮未能把 A/B/C/D 推进为链上 PASS。原因不再只是主网资产不足，而是发现两个更前置的测试网 RPC 配置 FAIL：App 的 Sepolia RPC 已停服，App 的 Amoy RPC 域名当前无法解析。BSC Testnet、Solana Testnet、TRON Nile 可连接，但新建测试钱包无 gas/token，且可自动调用的 Solana faucet 返回 429、TRON faucet 要求 reCAPTCHA。
- Polygon 的 `chainId_test=80002` 已在 Android+iOS 新建钱包的运行时确认，Mumbai 旧值没有回潮；但余额查询和发送被失效 RPC 阻断，因此 E 整项为 FAIL，不能仅凭 chainId 报 PASS。integration runner 清除了本地状态，未保留一个 173fe061 之前的旧钱包样本，所以 `_syncNewChains` 的原位旧数据迁移不冒充已验证。
- 本轮没有产生链上交易，故没有 tx hash、allowance、到账金额或链上截图。下文附双端原始 RPC 日志，不冒充链上验证。

状态定义：`PASS` 为当前提交真机行为符合预期；`FAIL` 为当前提交真机可复现不符合预期；`STATIC CONFIRMED` 为源码/自动化边界已确认但没有完成真机外部闭环；`BLOCKED` 为缺少测试资产、外设或被 faucet/外部服务阻断。

## 设备与构建

| 设备 | 系统/连接 | 构建/安装 | 结果 |
|---|---|---|---|
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 / USB / 已解锁并允许 | integration Debug 探针；结束前恢复 Profile | 真机探针 PASS |
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / API 36 / USB | `ai.n42.www 2.4.8 (2026072608)` 安装成功 | 安装阻塞解除，真机探针 PASS |
| Keystone | 无设备 | 未执行 | BLOCKED |

结束前已在 iPhone 安装并启动当前提交的 Profile `2.4.8 (2026072604)`：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 4acb2ebc672fb81e0b82631b85209d18c6bb6e58d7ceb06f4b8ee7359fc587b8

iOS build/ios/iphoneos/Runner.app/Runner (Profile)
SHA-256 6581f96d20394f4021ed73945450050dc5d7f88971bfbe97dfee2b9c35271ed4
```

integration runner 会重装 App，并记录 `fresh install detected, Keychain cleared`；本轮测试地址均为临时新建测试钱包的公开地址，没有导出私钥或助记词。

## 测试网运行时配置

Android 与 iOS 在真实 App 初始化、钱包迁移完成后得到相同配置：

| 链 | Android / iOS 运行时 | 状态 |
|---|---|---|
| ETH | `chainId_test=11155111`，`https://eth-sepolia.public.blastapi.io` | chainId 正确；RPC FAIL |
| BNB | `chainId_test=97`，`https://data-seed-prebsc-1-s1.binance.org:8545` | RPC PASS，返回 `0x61` |
| MATIC | `chainId_test=80002`，`https://rpc-amoy.polygon.technology` | 新建钱包配置 PASS；RPC FAIL |
| BASE | `chainId_test=0`，但 `service_test=https://mainnet.base.org` | fail-closed chainId 生效；记录该不一致 |
| TRX | `https://nile.trongrid.io/jsonrpc` | Nile 配置已进入运行时 |
| SOL | `https://api.testnet.solana.com` | Testnet 配置已进入运行时 |
| ATOM | `chainId_test=0`，`service_test` 为空 | 无可用测试网 |

### 双端真机 RPC 原始证据

Android：

```text
SIX_RPC APP_SEPOLIA status=403 body={
  "error": {
    "code": -32000,
    "message": "Blast API is no longer available. Please update your integration to use Alchemy's API instead: https://alchemy.com"
  }
}
SIX_RPC APP_BSC_TEST status=200 body={"jsonrpc":"2.0","id":1,"result":"0x61"}
SIX_RPC APP_AMOY ERROR=SocketException: Failed host lookup:
  'rpc-amoy.polygon.technology' (errno = 7)
SIX_RPC OFFICIAL_CURRENT_AMOY status=200
  body={"id":1,"jsonrpc":"2.0","result":"0x13882"}
```

iOS：

```text
SIX_RPC APP_SEPOLIA status=403 body={
  "error": {
    "code": -32000,
    "message": "Blast API is no longer available. Please update your integration to use Alchemy's API instead: https://alchemy.com"
  }
}
SIX_RPC APP_BSC_TEST status=200 body={"jsonrpc":"2.0","id":1,"result":"0x61"}
SIX_RPC APP_AMOY ERROR=SocketException: Failed host lookup:
  'rpc-amoy.polygon.technology' (errno = 8)
SIX_RPC OFFICIAL_CURRENT_AMOY status=200
  body={"id":1,"jsonrpc":"2.0","result":"0x13882"}
```

同一设备、同一时间访问 Polygon 当前官方 RPC `https://polygon-amoy.drpc.org` 成功返回 `0x13882`，因此 App Amoy 失败不是手机网络或 DNS 总体异常。Polygon 当前 RPC 参考：<https://docs.polygon.technology/pos/reference/rpc-endpoints>。

## A. Android calldata 链上确认

### ERC20 approve / transfer：BLOCKED（链上）/ STATIC CONFIRMED（编码）

- Android 已可安装并运行，不再是设备权限阻塞。
- Sepolia 路径在签名之前即被 App RPC 403 阻断。
- BSC Testnet RPC 正常，但 Android 与 iOS 新钱包的 tBNB 余额均为 `0`；官方 faucet 需要网页表单、Discord 或 Telegram 会话，本轮环境没有可自动完成的有效 faucet 会话。
- 因此没有批准或广播 approve/transfer，没有 tx input、receipt 或 allowance 可供链上核验。
- `evm_msg_data_test` 真机前回归通过：approve selector 解码为 `09 5e a7 b3`，而非旧 ASCII `30 39 35 65...`；这仍只算 STATIC CONFIRMED。

```text
BSC Testnet chainId = 97
Android test wallet balance = 0
iOS test wallet balance = 0
```

BNB 官方 faucet 说明：<https://docs.bnbchain.org/bnb-smart-chain/developers/faucet/>。

### A2. 中文 memo：BLOCKED

- Android+iOS 都缺少可用测试网 gas，未广播中文 memo 转账。
- UTF-8 → hex → UTF-8 的中文单测通过，但不能替代链上 data 还原。

## B. NFT ERC721 / ERC1155：BLOCKED

- 两端均无测试网 NFT 与 gas；Sepolia App RPC 又已停服。
- 没有执行 mint、ERC721 transfer 或 ERC1155 transfer，因此没有 tokenId/value/收方到账证据。
- NFT model/batch transfer 相关回归通过，只能保留为 STATIC CONFIRMED。

## C. TRON / Solana 金额精度：BLOCKED

### TRON Nile

- Android+iOS 运行时均指向 Nile。
- 对两个真机测试地址调用 Nile `getaccount` 均返回 `{}`，地址未激活、余额为零。
- TRON 官方 Nile faucet 要求输入地址并完成 reCAPTCHA；本轮不绕过验证码，因此未取得 TRX/TRC20 测试资产。
- 未广播 1.5 TRC20，不能验证到账精度。

官方说明：<https://developers.tron.network/docs/getting-testnet-tokens-on-tron>。

### Solana Testnet

- `getBalance` 对 Android+iOS 测试地址均成功，余额为 `0`，说明 Testnet RPC 可读。
- 通过官方 JSON-RPC `requestAirdrop` 分别请求 1 SOL、0.5 SOL、0.1 SOL，返回 internal error 或 429：

```text
code=429
You've either reached your airdrop limit today or the airdrop faucet has run dry.
Please visit https://faucet.solana.com for alternate sources of test SOL
```

- 无 SOL gas，更无 6 位 SPL 测试 token，未执行转账或 preflight。
- Solana 官方说明公共 Testnet RPC/faucet 受限且可能间歇不可用：<https://solana.com/docs/references/clusters>。

## D. ATOM：BLOCKED，并发现运行时配置缺口

- 权威 `wallet_chain_configs_part1.dart` 中 ATOM 为 `supportTest:false`、`service_test:""`，不存在可用 ATOM 测试网。
- 但 Android+iOS 的 `CoinModel` 运行时均打印 `supportTest=true`。原因是 `buildCoinModel()` 使用 `CoinModel.fromMap(chain['baseInfo'])`，没有把顶层 `supportTest` 复制给模型，`CoinModel.supportTest` 保留默认 `true`。
- 网络切换 UI 当前也没有读取 `supportTest` 隐藏测试网按钮。这会让无测试网的链仍可能显示“测试网络”，随后拿空 endpoint 执行。
- 本轮没有 ATOM 测试资产，不能构造失败广播或正常 memo；D 保持 BLOCKED。该运行时配置缺口仅记录，未修改。

## E. Polygon Amoy：FAIL

| 验证点 | 状态 | 证据 |
|---|---|---|
| 新建钱包运行时为 Amoy chainId 80002 | PASS | Android+iOS 均打印 `chainId_test=80002`，无 Mumbai 80001 |
| 旧钱包原位迁移 | BLOCKED | integration 重装清除了旧本地状态，没有可复用的迁移前样本 |
| UI 明文显示 Amoy/80002 | STATIC CONFIRMED | 运行时值已确认；未把配置日志冒充为人工目视 UI PASS |
| App 配置 RPC 可用 | FAIL | 双端均 `Failed host lookup: rpc-amoy.polygon.technology` |
| 余额可查 | FAIL | App RPC 无法建立连接；官方当前 dRPC 对照可查且余额为 0 |
| 发送测试转账 | BLOCKED | App RPC FAIL 且无 POL gas |

本轮提交只防止了死 chainId 回潮，没有守护 RPC 可解析/可返回正确 chainId。建议后续把 Amoy RPC 更新为 Polygon 当前端点，并增加带超时的部署前端点健康检查；不建议把实时网络请求塞进普通单元测试。

## G / Keystone

| 项目 | 状态 | 说明 |
|---|---|---|
| G AA | BLOCKED | 无可用 Smart Wallet 与测试网 gas |
| Keystone | BLOCKED | 无 Keystone 真机和固件版本 |

## 本轮新增缺陷定性

1. **ETH Sepolia RPC 配置 FAIL（P0 测试阻塞）**

   `RpcConfig.ethSepoliaRpc` 仍是已停服的 Blast API；`syncRpcOverridesToChainUrlMap()` 又会把它覆盖进权威表。双端真实请求均返回 403。

2. **Polygon Amoy RPC 配置 FAIL（P0 测试阻塞）**

   chainId 80002 正确，但 `rpc-amoy.polygon.technology` 当前无法解析；同机官方当前 dRPC 正常返回 80002。

3. **`supportTest` 未进入运行时 CoinModel（配置/UI 缺口）**

   ATOM/BASE 等顶层 `supportTest:false` 没有被 `buildCoinModel()` 复制，运行时仍为默认 true；网络切换行也未据此禁用测试网。

按任务要求只记录，不改代码。上述缺陷都不属于 calldata/fountain/签名 crypto 层。

## 回归测试

```text
flutter test \
  test/features/wallet/chain_testnet_config_guard_test.dart \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/browser/dapp_request_handler_test.dart \
  test/features/nft/nft_model_test.dart \
  test/features/wallet/nft_batch_transfer_utils_test.dart \
  --no-pub

114 tests passed
```

Android 与 iOS 临时 integration 探针最后一轮均 `All tests passed`；临时夹具已删除。

## 仓库状态

- 分支保持 `master@173fe061`，与 `origin/master` 一致。
- 未修改业务代码；仅新增本报告。
- 之前未跟踪的五份真机报告保持原样。
- 未创建提交，未推送。
