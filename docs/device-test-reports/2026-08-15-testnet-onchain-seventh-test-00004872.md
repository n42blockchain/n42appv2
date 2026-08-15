# 真机七测 · 链上确认 — 2026-08-15

## 范围与结论

- 测试基线：`master@00004872fd9c2c5710a914b1caf7f8a2f745fd84`，与 `origin/master` 一致。
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- 用户要求重试 Android 后，`adb install -r -t` 返回 `Success`，App 已启动且进程存活；Android 安装不再 BLOCKED。
- Android 与 iOS 真机均确认 Sepolia、Amoy、BSC Testnet、Solana Testnet、TRON Nile 的运行时端点可达，返回的 chainId/健康状态正确。本轮替换的两个 PublicNode RPC 修复有效。
- 但“App 内可切到五个测试网”的先决条件仍为 **FAIL**：网络切换入口只对白名单 `N/ETH/BTC/DOT/ZIL` 显示，MATIC、BNB、TRX、SOL 均没有入口；旧钱包的 `supportTest` 同步又被错误地放进 Sonic 专用条件，BNB/TRX 的旧值没有迁移。
- 两台真机新建 EVM 测试地址在 Sepolia、Amoy、BSC Testnet 的余额全部为 0，BSC 主网余额也为 0。当前 BSC 官方 faucet 要求地址先持有 0.002 BNB 主网资产，因此不能领取测试 gas。
- 综上，本轮没有产生链上交易，A/A2/B/C/D 不能从 STATIC CONFIRMED/BLOCKED 升级为链上 PASS；没有 tx hash、allowance、到账金额或链上截图。本文没有用 RPC 可达或编码单测冒充链上确认。

状态定义：`PASS` 为当前提交真机行为符合预期；`FAIL` 为当前提交真机或确定性执行路径不符合预期；`STATIC CONFIRMED` 为源码/自动化边界已确认但没有完成外部闭环；`BLOCKED` 为缺少测试资产、外设或被外部服务阻断。

## 设备与构建

| 设备 | 系统/连接 | 构建/安装 | 结果 |
|---|---|---|---|
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 (`23G71`) / USB / 已解锁并允许 / Developer Mode | integration Debug 探针；结束前恢复当前提交 Profile | 真机探针 PASS |
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / HyperOS `OS3.0.302.0.WPQCNXM` / USB | integration Debug 与普通 Debug；重试安装成功 | 真机探针 PASS，普通 App 已启动 |
| Keystone | 无设备 | 未执行 | BLOCKED |

结束前已在两台真机覆盖安装并启动当前提交的普通构建：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 0482e4f2d99a422136e2d2197f86deac2542fae17ce13c2bcb2b550cf5af0b69

iOS build/ios/iphoneos/Runner.app/Runner (Profile)
SHA-256 94fc99e31c15edd9b76080c00a63aa909676abc6eabd723a9036567a872fae53
```

临时 integration 探针会重装 App 并创建临时测试钱包；只记录了公开地址，没有导出私钥或助记词。临时探针在报告前已删除。

## 先决检查

### 运行时配置与端点：PASS

Android 与 iOS 新建钱包得到一致配置，并从真机直接发出 RPC 请求：

| 链 | 运行时配置 | Android | iOS |
|---|---|---|---|
| ETH | Sepolia，`chainId_test=11155111`，`https://ethereum-sepolia-rpc.publicnode.com` | `0xaa36a7` / PASS | `0xaa36a7` / PASS |
| MATIC | Amoy，`chainId_test=80002`，`https://polygon-amoy-bor-rpc.publicnode.com` | `0x13882` / PASS | `0x13882` / PASS |
| BNB | BSC Testnet，`chainId_test=97` | `0x61` / PASS | `0x61` / PASS |
| TRX | Nile | 最新区块 `70089513` / PASS | 最新区块 `70089699` / PASS |
| SOL | `https://api.testnet.solana.com` | `getHealth=ok` / PASS | `getHealth=ok` / PASS |
| ATOM | `supportTest=false`、测试 endpoint 为空 | 配置符合预期 | 配置符合预期 |

真机原始日志摘要：

```text
Android:
SEVEN_RPC SEPOLIA status=200 result=0xaa36a7
SEVEN_RPC AMOY status=200 result=0x13882
SEVEN_RPC BSC_TEST status=200 result=0x61
SEVEN_RPC SOL_TEST status=200 result=ok
SEVEN_RPC TRON_NILE status=200 block=70089513

iOS:
SEVEN_RPC SEPOLIA status=200 result=0xaa36a7
SEVEN_RPC AMOY status=200 result=0x13882
SEVEN_RPC BSC_TEST status=200 result=0x61
SEVEN_RPC SOL_TEST status=200 result=ok
SEVEN_RPC TRON_NILE status=200 block=70089699
```

PublicNode 当前公布的端点与 App 配置一致：

- Sepolia：<https://ethereum-sepolia-rpc.publicnode.com>
- Polygon Amoy：<https://polygon-amoy-bor-rpc.publicnode.com>

### App 内测试网入口：FAIL

| 验证点 | 状态 | 证据 |
|---|---|---|
| ETH → Sepolia | STATIC CONFIRMED | ETH 位于网络切换白名单，运行时 chainId/RPC 正确；未把自动化路由检查冒充人工点击 PASS |
| MATIC → Amoy | FAIL | 运行时配置正确，但 `supportedNetworkSwitch` 不包含 `MATIC`，操作面板不构建网络切换行 |
| BNB → BSC Testnet | FAIL | 运行时配置正确，但白名单不包含 `BNB` |
| TRX → Nile | FAIL | 运行时配置正确，但白名单不包含 `TRX` |
| SOL → Testnet | FAIL | 运行时配置正确，但白名单不包含 `SOL` |
| ATOM 不显示测试网入口 | PASS（表象）/ FAIL（模型） | 白名单不含 ATOM，因此入口不显示；但运行时 `CoinModel.supportTest` 仍错误为 `true`，不是 `supportTest` 正确驱动的结果 |

确定性代码路径：

```text
lib/features/wallet/pages/wallet_chain_info_actions.dart:201-205
const supportedNetworkSwitch = {'N', 'ETH', 'BTC', 'DOT', 'ZIL'};
```

因此任务要求的 MATIC/BNB/TRX/SOL 切换入口不会出现。该结论不是网络波动或设备操作问题。

### 已有钱包配置迁移：FAIL

在 iPhone 上以本轮之前已存在的钱包启动，App 打印完成 `Synced chains and service URLs` 后，运行时仍为：

```text
BNB storedSupportTest=false
TRX storedSupportTest=false
ATOM storedSupportTest=false, modelSupportTest=true
```

而当前权威配置的 BNB/TRX 已是 `supportTest=true`。根因定位：

1. `wallet_action_provider_wallet.dart:177-226` 中同步 `mainnetChainID/testnetChainID/supportTest` 以及强制回主网的逻辑，位于 `chainKey == CoinType.S.name` 的 Sonic 修复条件内部；普通链永远不会执行。
2. `wallet_action_provider_token.dart:30-35` 用 `CoinModel.fromMap(chain['baseInfo'])` 构建模型，仅复制 `showList/isTest/addrType` 等字段，没有复制顶层 `supportTest`，所以 ATOM 模型保留默认 `true`。

因此：新建钱包拿到最新值不代表旧钱包迁移成功；“已关闭测试网时自动拉回主网”的通用行为也没有真正生效。本轮按要求只记录，不修代码。

## 测试资产与 faucet

两端临时 EVM 地址：

```text
Android 0x03F4BBF2363613bFe89b3c2EF4902C5f373B1690
iOS     0xfD51087808C2713B05D35988c48cd76807A6D2A3
```

通过对应 RPC 查询：

| 网络 | Android | iOS |
|---|---:|---:|
| Sepolia | 0 ETH | 0 ETH |
| Polygon Amoy | 0 POL | 0 POL |
| BSC Testnet | 0 tBNB | 0 tBNB |
| BSC Mainnet（faucet 门槛对照） | 0 BNB | 0 BNB |

BSC 官方 faucet 当前页面注明测试地址需先持有 `0.002 BNB` 主网资产，随后才可领取测试币：<https://www.bnbchain.org/en/testnet-faucet>。两地址均不满足门槛，且 App 内 BNB 测试网入口仍缺失，故未取得 gas。

## A. Android calldata 链上确认

### ERC20 Approve：BLOCKED（链上）/ STATIC CONFIRMED（编码）

- Android 重试安装成功，不再受 `INSTALL_FAILED_USER_RESTRICTED` 阻断。
- Sepolia、BSC Testnet RPC 都已真机确认正常，但两端 gas 余额均为 0；BSC 官方 faucet 的主网余额门槛也不满足。
- App 内 BNB 网络切换入口缺失，无法按任务步骤切到 BSC Testnet。
- 因此没有签名或广播 approve，没有 `095ea7b3` 链上 input、receipt 和 allowance 证据。
- `evm_msg_data_test` 确认 calldata 去除 `0x` 后原样传递，approve selector 解码为 `09 5e a7 b3` 而非 ASCII `30 39...`；这只计 STATIC CONFIRMED。

### A2. 中文 memo：BLOCKED（链上）/ STATIC CONFIRMED（编码）

- Android+iOS 都没有可用测试 gas，未广播中文 memo 转账。
- 自动化确认 UTF-8 → hex → UTF-8 可还原中文且双端使用同一路径；没有 tx hash/data，不能算链上 PASS。

## B. NFT ERC721 / ERC1155：BLOCKED

- 两端均没有测试网 gas、ERC721 或 ERC1155；MATIC/BNB 测试网入口缺失。
- 未执行 mint/transfer，没有 tokenId、value、receipt 或收方到账证据。

## C. TRON / Solana 金额精度：BLOCKED

- TRON Nile 与 Solana Testnet RPC 的真机可达性为 PASS。
- App 内 TRX/SOL 网络切换入口均缺失。
- 临时钱包没有 Nile TRX/TRC20 或 Testnet SOL/6 位 SPL；未广播 1.5 TRC20 或 SPL 转账，不能验证到账精度和 preflight。

## D. ATOM 广播：BLOCKED

- ATOM 权威配置已关闭测试网且 endpoint 为空，无法借测试网构造失败/成功交易。
- 没有 ATOM 主网测试资产，未执行余额不足/gas 过低交易，也未执行正常空 memo 转账。
- `CoinModel.supportTest=true` 的运行时错误已在上文单独标为 FAIL，不能把“入口因硬编码白名单恰好不显示”视为同步逻辑已修复。

## G / Keystone

| 项目 | 状态 | 说明 |
|---|---|---|
| G AA | BLOCKED | 无可用 Smart Wallet 与测试网 gas |
| Keystone | BLOCKED | 无 Keystone 真机和固件版本 |

## 回归测试

```text
flutter test \
  test/features/wallet/chain_testnet_config_guard_test.dart \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/wallet/chain/rpc_override_sync_test.dart

18 tests passed
```

Android 与 iOS 临时 integration 探针最后一轮均 `All tests passed`；探针验证的是运行时配置和端点，不代表链上交易 PASS。

## 缺陷定性与建议修复点

1. **测试网切换 UI 与 `supportTest` 脱节（先决条件 FAIL）**

   `wallet_chain_info_actions.dart` 使用固定链白名单。建议统一由 `coinModel.supportTest` 和有效 testnet endpoint/chainId 驱动；否则新增/恢复测试网只改配置仍不可用。

2. **`supportTest` 同步误缩进到 Sonic 专用分支（旧钱包迁移 FAIL）**

   将通用字段同步及 `supportTest=false && isTest=true` 回主网逻辑移出 `CoinType.S` 条件，并增加普通链旧值迁移测试。

3. **顶层 `supportTest` 未进入 `CoinModel`（模型 FAIL）**

   `buildCoinModel()` 应显式复制该字段；增加 ATOM `false`、BNB/TRX `true` 的模型构建测试。

4. **RPC 修复有效**

   Sepolia/Amoy PublicNode、BSC Testnet、Nile、Solana Testnet 均双端真机可达。本轮问题定性为 provider 同步/UI 入口与测试资产，不是 RPC、calldata 或原生安装层。

按任务要求只记录上述问题，没有修改业务代码。

## 仓库状态

- 分支保持 `master@00004872`，与 `origin/master` 一致。
- 未修改业务代码；仅新增本报告。
- 之前未跟踪的六份真机报告保持原样。
- 未创建提交，未推送。
