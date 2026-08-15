# 真机八测 · 测试网入口复测 + 链上确认 — 2026-08-15

## 范围与结论

- 测试基线：`master@cac31701f410b657cce3a9daf3d60818ecf49c86`，测试开始时与 `origin/master` 一致。
- 执行原则：只验证、诊断和记录；未修改业务代码，未提交、未推送。
- 七测发现的三个钱包先决 FAIL 在 Android 真机上全部闭环：入口由 `supportTest` 驱动、旧钱包字段迁移进入通用路径、`CoinModel.supportTest` 正确。
- Android 实际打开 10 个链详情页：MATIC/BNB/TRX/SOL/ETH/N/BTC/DOT 显示切换行，ZIL/ATOM 不显示；MATIC/BNB/TRX/SOL/ETH 均实际点击 Testnet 并把运行时与持久化状态切为测试网。
- iPhone 13 Pro Max 的当前 Debug 测试包构建和安装成功，但 Flutter 启动测试时先被 Mac 侧 Xcode Automation 拒绝（`osascript: -2`），LLDB 路径又无法完成附加；手机保持解锁、已配对，普通 `devicectl` 启动可用。iOS 入口复测标 BLOCKED，不以共享 Dart 代码冒充双端 PASS。
- 测试 gas 仍未取得：三个 EVM 地址的 Sepolia/BSC Testnet 余额均为 0；Google Cloud faucet 需要登录；Polygon 当前官方文档已改为第三方 faucet 清单；Solana Testnet airdrop 返回 internal error/429；Nile 地址未激活。
- 因此 A/A2/B/C/D 没有产生链上交易，没有 tx hash、calldata、receipt、allowance、tokenId/value 或到账金额证据，继续 BLOCKED。
- chat 三项中发现新的真实接线 FAIL：Space 投票图标出现，但点击后 `GetIt` 找不到 `GovernanceBloc`，提案列表打不开。Social Graph 入口出现；无钱包提示处理器源码存在，但本轮真机点击因自动化未滚入命中区域而未完成，保留 STATIC CONFIRMED。照片背景入口、复制和持久化通过设备内夹具验证，系统相册 UI 与真实会话背景视觉效果未冒充 PASS。

状态定义：`PASS` 为当前提交真机行为符合预期；`FAIL` 为当前提交真机可复现不符合预期；`STATIC CONFIRMED` 为源码/自动化边界已确认但没有完成外部闭环；`BLOCKED` 为缺少测试资产、外设或被外部服务/测试工具阻断。

## 设备与构建

| 设备 | 系统/连接 | 构建/安装 | 结果 |
|---|---|---|---|
| Android `25098RA98C`，序列号 `38f4f08a` | Android 16 / HyperOS `OS3.0.302.0.WPQCNXM` / USB | cac31701 integration Debug 首轮安装成功 | 钱包探针完成；第二次覆盖安装又被 HyperOS `INSTALL_FAILED_USER_RESTRICTED` 拒绝 |
| iPhone 13 Pro Max (`iPhone14,3`) | iOS 26.6 (`23G71`) / USB / 已解锁、已配对、Developer Mode | cac31701 integration Debug 构建、安装成功 | Flutter 测试启动 BLOCKED（Xcode Automation/LLDB） |
| Keystone | 无设备 | 未执行 | BLOCKED |

结束前已重新生成普通构建：

```text
Android build/app/outputs/flutter-apk/app-debug.apk
SHA-256 171f01308208e6c29620715a4dcde61120c4593ad7dfaccfa1050b33161d55c0
覆盖安装结果：INSTALL_FAILED_USER_RESTRICTED（未能替换首轮 integration 包）

iOS build/ios/Profile-iphoneos/Runner.app/Runner
SHA-256 2401906505283dac58e073210c16e18ce14b24669796b4228414a2e44684401f
安装结果：成功；已通过 devicectl 启动
```

integration 探针使用现有测试钱包的公开地址，不读取或输出助记词/私钥。迁移验证先通过正式 `saveWalletInfo` 持久化七测的旧值组合，再调用完整 `initWallet → _syncNewChains → buildCoinModel`，不是直接调用纯函数。临时探针已在写报告前删除。

## 1. 先决检查复测

### 1.1 Android 入口与切换：PASS

| 链 | 切换行 | 实际点击 Testnet | 运行时结果 | 状态 |
|---|---|---|---|---|
| MATIC | 出现 | 是 | `isTest=true`，Amoy `80002`，PublicNode RPC | PASS |
| BNB | 出现 | 是 | `isTest=true`，BSC Testnet `97` | PASS |
| TRX | 出现 | 是 | `isTest=true`，Nile endpoint | PASS |
| SOL | 出现 | 是 | `isTest=true`，`https://api.testnet.solana.com` | PASS |
| ETH | 出现 | 是 | `isTest=true`，Sepolia `11155111`，PublicNode RPC | PASS |
| N | 出现 | 未改变网络 | 回归入口存在 | PASS |
| BTC | 出现 | 未改变网络 | 回归入口存在 | PASS |
| DOT | 出现 | 未改变网络 | 回归入口存在 | PASS |
| ZIL | 不出现 | 不适用 | `supportTest=false` | PASS（有意变化） |
| ATOM | 不出现 | 不适用 | `supportTest=false` | PASS |

真机原始日志：

```text
EIGHT_ENTRY MATIC visible=true
EIGHT_SWITCH MATIC isTest=true chainId=80002
  service=https://polygon-amoy-bor-rpc.publicnode.com

EIGHT_ENTRY BNB visible=true
EIGHT_SWITCH BNB isTest=true chainId=97
  service=https://data-seed-prebsc-1-s1.binance.org:8545

EIGHT_ENTRY TRX visible=true
EIGHT_SWITCH TRX isTest=true chainId=0
  service=https://nile.trongrid.io/jsonrpc

EIGHT_ENTRY SOL visible=true
EIGHT_SWITCH SOL isTest=true chainId=0
  service=https://api.testnet.solana.com

EIGHT_ENTRY ETH visible=true
EIGHT_SWITCH ETH isTest=true chainId=11155111
  service=https://ethereum-sepolia-rpc.publicnode.com

EIGHT_ENTRY N visible=true
EIGHT_ENTRY BTC visible=true
EIGHT_ENTRY DOT visible=true
EIGHT_ENTRY ZIL visible=false
EIGHT_ENTRY ATOM visible=false
EIGHT_STEP network entry visibility and switching: PASS
```

页面操作过程中市场代理返回若干 `401`，余额/行情逻辑回退缓存，但没有影响切换行构建、点击、`isTest` 持久化或测试网 endpoint 选择；报告不把这些无关 401 定性为入口回归。

### 1.2 旧钱包迁移：PASS（Android 完整持久化路径）

构造与七测一致的旧状态：

```text
BNB supportTest=false
TRX supportTest=false
ATOM supportTest=true, isTest=true
```

保存后重新执行完整钱包初始化，结果：

```text
EIGHT_MIGRATION result
  BNB=true
  TRX=true
  ATOM=false/isTest=false
  ATOM model=false
EIGHT_STEP legacy supportTest migration: PASS
```

这同时验证：

1. BNB/TRX 已由权威配置覆盖旧 `false`；
2. ATOM 顶层值迁移为 `false`；
3. 停在已关闭测试网的 ATOM 被拉回主网；
4. `buildCoinModel` 得到 `modelSupportTest=false`，入口消失不再是旧白名单巧合。

### 1.3 iOS：BLOCKED

当前提交 iOS Debug 构建与设备安装成功。启动测试的两条路径均未进入 Dart 测试体：

```text
Xcode Automation path:
Error executing osascript: -2
Could not run build/ios/iphoneos/Runner.app on 00008110-001C11A12692801E

LLDB path:
LLDB is taking longer than expected to start debugging the app
```

设备侧检查为 `passcodeRequired=false`、`unlockedSinceBoot=true`，`devicectl` 可直接启动 `ai.n42.www`；阻塞点是 Mac 的 Flutter/Xcode 测试附加，不是手机锁屏或 USB 未授权。故本节不冒充 iOS PASS。

## 2. 测试 gas / faucet

### EVM

本轮 Android 测试地址：

```text
0x7cE6bFBBd953edb494025aFC13130a0bCb455176
```

同时复查七测地址：

```text
Android 0x03F4BBF2363613bFe89b3c2EF4902C5f373B1690
iOS     0xfD51087808C2713B05D35988c48cd76807A6D2A3
```

三个地址在 Sepolia、BSC Testnet 的 `eth_getBalance` 均返回 `0x0`。

- Google Cloud 官方页面确认提供 Sepolia/Holesky faucet，但页面要求 Google 登录；当前执行环境没有可用的已认证 Google 浏览器/CLI 会话，未绕过登录：<https://cloud.google.com/products/blockchain-rpc>。
- Polygon 当前官方文档明确写明原官方 faucet 已停止，改列 Alchemy、QuickNode、GetBlock、StakePool 等第三方入口；这些入口需要账户、社交登录或钱包连接：<https://docs.polygon.technology/tools/gas/matic-faucet>。
- 尝试文档搜索结果中的 Triangle Amoy faucet 时，服务直接返回 HTTP 503 `Service Suspended`，没有取得 POL。

### Solana Testnet

```text
Address: AMW542MwgUpgtEaaLHb5NyeJC5Nu5a1sC9mQTRDwX3xe
getBalance: 0
requestAirdrop 0.1 SOL: -32603 Internal error
requestAirdrop 0.01 / 0.001 SOL: 429 faucet limit or dry
```

Solana 官方文档也说明公共 Testnet RPC 有速率限制且可能间歇不可用：<https://solana.com/docs/references/clusters>。

### TRON Nile

```text
Address: TVWTsdu4xRyXCmNKhkzTFLg7AaJqxt1fmx
POST /wallet/getaccount: {}
```

地址未激活、无 Nile TRX/TRC20；未绕过网页验证码。

## 3. 链上确认

| 项目 | 状态 | 说明 |
|---|---|---|
| A Android ERC20 Approve | BLOCKED | Sepolia/BSC 测试 gas 为 0，没有 tx input、receipt 或 allowance |
| A iOS 对照 | BLOCKED | iOS 测试启动工具链阻断且地址无 gas |
| A2 中文 memo | BLOCKED | 无测试 gas；UTF-8 编码回归通过但不替代链上 data |
| B ERC721 / ERC1155 | BLOCKED | 无 gas、测试 NFT 与 mint/transfer receipt |
| C TRON 1.5 TRC20 | BLOCKED | Nile 地址未激活且无测试资产 |
| C 6 位 SPL | BLOCKED | Testnet SOL 为 0，airdrop 失败，也无 6 位 SPL |
| D ATOM | BLOCKED | 无可用 ATOM 测试网及主网测试资产 |

本轮没有 tx hash，不能核验 `095ea7b3`、revert、allowance、tokenId/value、金额精度或 memo 链上还原。

## 4. chat 三项交付

### 4.1 Space 治理入口：FAIL

- Android 真机 Space 详情页 AppBar 确认出现 `Icons.how_to_vote_outlined`，`tooltip=Governance`。
- 实际点击后提案列表没有打开，Flutter 抛出 provider/GetIt 异常。

原始日志：

```text
EIGHT_CHAT governanceIcon=true
EIGHT_STEP Space governance entry: FAIL

Bad state: Tried to read a provider that threw during the creation of its value.
Bad state: GetIt: Object/factory with type GovernanceBloc is not registered inside GetIt.

#5 _SpaceDetailScaffold._buildHeader...
#10 _ProposalsListPageState._loadProposals...
```

初步定性为 chat 宿主接线，而非页面布局：

1. `space_detail_page.dart` 无条件展示治理按钮并在点击时执行 `getIt<GovernanceBloc>()`；
2. `injection.dart` 只在 `enableGovernance=true`、治理数据源/仓库存在时注册 `GovernanceBloc`；
3. `lib/core/app/chat_initialization.dart` 构造 `N42ChatConfig` 时没有启用 `enableGovernance`，其默认值为 `false`。

因此入口“可见”但执行依赖未接线。按任务要求只记录，不修改。

### 4.2 Social Graph：入口 PASS / 无钱包提示 STATIC CONFIRMED / 有钱包路径存在同类风险

- Android 真机 Social Hub 已渲染 `Social Graph` 卡片：`EIGHT_CHAT socialGraphEntry=true`。
- 探针为验证“无钱包提示”临时注销 `IWalletBridge`，但首次 `ensureVisible` 后没有额外 pump，点击坐标仍在屏幕外；Flutter 明确打印 hit-test warning，处理器没有收到点击。因此没有把提示标 PASS。
- 源码 `_openSocialGraph` 在无地址时明确显示 `Connect a wallet to view your social graph` SnackBar，计 STATIC CONFIRMED。
- 另一个需要修复侧关注的接线风险：宿主同样没有设置 `enableSocialGraph=true`，正常有钱包路径会执行 `getIt<SocialGraphBloc>()`，而该 Bloc 只在开关启用、仓库已注册时存在。入口却是无条件显示，结构与 Governance FAIL 相同。

### 4.3 From Photos：部分 PASS

Android 真机使用设备内临时 PNG 与 `ImagePickerPlatform` 夹具执行页面后的全部应用内流程：

```text
EIGHT_CHAT fromPhotosEntry=true
EIGHT_CHAT photoSaved=true
  copied=/data/user/0/ai.n42.www/app_flutter/chat_backgrounds/...
  exists=true
EIGHT_CHAT photoReopenAndResume=true
EIGHT_STEP photo chat background persistence: PASS
```

验证范围：

| 验证点 | 状态 |
|---|---|
| 设置页出现 `From Photos` | PASS（Android 真机渲染） |
| 选图结果复制到 App Documents | PASS（设备文件存在） |
| 偏好值使用 `image_` 稳定路径 | PASS |
| 关闭并重新打开设置页仍显示 `Change photo` | PASS |
| App pause/resume 后仍保留 | PASS |
| 系统相册选择器 UI | BLOCKED（本轮用设备内 picker 夹具） |
| 真实会话页面肉眼确认背景 | BLOCKED |
| 杀进程后的完整冷启动 | STATIC CONFIRMED（持久化文件与偏好存在，但未完成 UI 冷启动闭环） |

首轮夹具 PNG 编码无效，Flutter 曾打印一次 `Could not decompress image`；该异常来自临时测试图片而不是用户相册文件。随后夹具已改为 `package:image` 生成的有效 PNG，但 Android 第二次覆盖安装被 HyperOS 拒绝，故不把背景视觉效果升级为 PASS。

## 自动化回归

```text
flutter test \
  test/features/wallet/chain_testnet_config_guard_test.dart \
  test/features/wallet/chain_testnet_migration_test.dart \
  test/features/wallet/evm_msg_data_test.dart \
  test/features/wallet/chain/rpc_override_sync_test.dart

25 tests passed

cd packages/n42_chat
flutter test test/unit/theme/chat_background_presets_test.dart

5 tests passed
```

## 本轮缺陷与后续优先级

1. **P0 chat 治理入口可见但必然缺依赖**：宿主需启用并配置 Governance，或入口必须按能力开关隐藏；当前点击真机 FAIL。
2. **Social Graph 有钱包路径同样可能缺依赖**：建议在交付前补真实点击测试，并让入口与 `SocialGraphBloc` 可用性一致；无钱包 SnackBar 单独保留。
3. **iOS 自动化环境阻塞**：Mac 侧需允许执行环境控制 Xcode，或修复 LLDB 附加；手机授权本身正常。
4. **链上项仍缺测试资产**：最直接方式是向上述当前 Android 地址发 Sepolia ETH/Amoy POL，或为七测两个地址提供满足 faucet 条件的资金；取得 gas 后才能继续 A/A2/B。

## 仓库状态

- 分支保持 `master@cac31701` 基线。
- 未修改业务代码；仅新增本报告。
- 临时 integration 探针已删除。
- 未创建提交，未推送。
