# T22 第三轮关键执行路径 P0/P1 真机验证

日期：2026-07-05  
分支：`fix/competitor-report-audit`  
基线：`master@bfb57779` (`fix(wallet): 第三轮关键执行路径 P0/P1/P2 修复(签名账户+金额精度)`)

## 环境

- Android 真机：`38f4f08a` / `25098RA98C` / Android 16
- App 包名：`ai.n42.www`
- 安装包：`build/app/outputs/flutter-apk/app-debug.apk`
- 账号前置：钱包内存在 `Account1` 与 `Account2`

## 构建与基础验证

| 项目 | 结果 | 备注 |
|---|---|---|
| `git fetch origin` + 分支同步 | PASS | 本地分支同步到 `bfb57779` |
| `flutter pub get` | PASS | 依赖解析成功 |
| `flutter analyze --no-fatal-infos` | PASS | `No issues found!` |
| `flutter test test/features/wallet_connect test/core/wallet/aa_constants_test.dart test/core/wallet/aa_errors_test.dart test/features/aa test/core/utils/chain_util_test.dart` | PASS | 586 tests passed |
| `flutter build apk --debug --target-platform android-arm64 --no-pub` | PASS | debug APK 构建成功 |
| ADB 覆盖安装 + 冷启动 | PASS | `adb install ... Success`，启动进入钱包页 |

## A 组：签名账户一致性

### A0 前置条件

结果：PASS

- 钱包列表确认存在 `Main Wallet / Account1` 和 `Wallet / Account2`。
- 将 active wallet 切为 `Account1`。
- 进入 `Verification` 页，打开 `Select Verify Wallet`，将 verify/mining wallet 切为 `Account2`。
- 回到钱包首页后确认顶部仍为 `Account1`，形成 `selectedWalletIndex=Account1` 与 `miningIndex=Account2` 的错位前置。

### A1 WalletConnect EVM `personal_sign` / `eth_sendTransaction`

结果：BLOCKED_BY_DAPP_SESSION

- Wallet 首页 WalletConnect 入口实测进入 `Scan QR code` 扫码页。
- 当前设备无已连接 WalletConnect session，页面不提供手输/paste WC URI 入口。
- 因缺少外部 DApp pairing QR/URI，本轮无法触发 WalletConnect EVM `personal_sign` 或 `eth_sendTransaction` 真机签名。
- 代码路径复核：`wallet_connect_connection.dart` 的签名私钥路径已改为按 `selectedWalletIndexProvider` 取当前 active 钱包，而不是 `miningWalletIndex`。

### A2 WalletConnect 非 EVM Solana/TRON 签名

结果：BLOCKED_BY_DAPP_SESSION

- 与 A1 相同，缺少外部非 EVM WalletConnect DApp session/QR。
- 未触发 Solana/TRON 签名请求，不能声称 PASS 或 FAIL。

### A3 内置浏览器 DApp 签名回归

结果：PASS

实测步骤：

1. 通过侧边栏进入 `Browser`，确认内置 WebView 正常打开。
2. 本机临时启动 HTTPS DApp 测试页，经 `localtunnel` 加载到内置浏览器。
3. 测试页等待 `window.ethereum` 注入后调用：
   - `eth_requestAccounts`
   - `personal_sign`
4. App 弹出 `Sign Message` 确认页，来源为测试 DApp，方法为 `personal_sign`。
5. 点击 `Confirm` 后，测试页回传签名并在本机离线恢复地址。

验签结果：

- DApp 返回 account：`0xEa311dDcF42397dF0007A160baf59E2Aa1ee25AA`
- 离线 ecrecover：`0xEa311dDcF42397dF0007A160baf59E2Aa1ee25AA`
- 结果：`match = true`

结论：在 `active=Account1`、`mining=Account2` 的错位前置下，内置浏览器 `personal_sign` 使用 active wallet `Account1` 签名，未复现误用 mining wallet 私钥的问题。

### A4 AA 多账号 owner/signer

结果：BLOCKED_BY_AA_ACCOUNT_AND_FUNDS

- 将 active wallet 切为非主账号 `Account2`，满足非主账号前置。
- `Account2` 钱包首页 Smart Wallet 状态显示 `Gasless`。
- 进入 Smart Account 页面后显示 `No smart accounts yet`，点击 `Create Smart Account` 后进入创建表单。
- 表单可见 counterfactual 地址：`0x889bb2e6f1a83db762ccb92f0f1ad04e69c7a1e4`，并提示首次交易时自动部署。
- 当前未创建/部署 Account2 的 smart account，且钱包 ETH/USDT/USDC 余额均为 0，无法继续执行 AA 交易广播验证。

## B 组：金额精度

### B1 EVM native MAX 高精度余额

结果：BLOCKED_BY_BALANCE

- 钱包首页 `Account1` 与 `Account2` 均显示总资产 `$0.00`。
- ETH 行显示 `0`，无 EVM native 余额。
- 因缺少非整数高精度 ETH 余额，无法验证 MAX 金额是否误报 insufficient balance。

### B2 ERC20 18 decimals MAX

结果：BLOCKED_BY_BALANCE

- USDT 行显示 `0.00`，USDC 行显示 `0`。
- 因缺少 ERC20 余额，无法验证 18 decimals MAX 精度路径。

## c176 补测：WalletConnect 桌面 DApp A1/A2

补测来源：`origin/codex-n42@c176bede`，对应修复基线 `d1654106`。本地分支已同步到 `d1654106` 后继续补测。

### 补测中发现并修复的问题

- `d1654106` 已新增 WalletConnect URI 粘贴入口，但钱包首页 WC 图标在无 session 时仍直接进入扫码页，导致粘贴入口不可达。已改为打开 `WalletConnectPage("")`，由该页提供 Cancel / Paste / Scan。
- `wc:` deep link 原本只 fire `EventPublicType.walletConnect`，本仓库未发现有效 listener，导致桌面 DApp URI 能被系统收到但不能稳定进入 WC pairing 页。已改为 deep link 直接 push `WalletConnectPage(wcUri)`。
- 空 URI 打开 `WalletConnectPage` 时 provider 初始态是 `loading`，页面会停在 `Pairing, please wait.`。已在空 URI 且初始 loading 时切到 `disconnect`。
- Android Solana `solana_signMessage` 原来把 DApp 的 base64 message 直接传给 native `signMessage`；native 实际期望 hex message bytes，导致签名无法通过 Ed25519 校验。已在 Dart 侧先 base64 decode，再转 hex 传 native。

### 补测构建与安装

| 项目 | 结果 | 备注 |
|---|---|---|
| `flutter analyze --no-fatal-infos` | PASS | `No issues found!` |
| `flutter test test/features/wallet_connect` | PASS | 160 tests passed |
| `flutter build apk --debug --target-platform android-arm64 --no-pub` | PASS | debug APK 构建成功 |
| ADB 覆盖安装 | PASS | `adb install -r -t -d -g ... Success` |

### A1 EVM `personal_sign`

结果：PASS

- 桌面 Node WalletConnect DApp 使用 `@walletconnect/sign-client` 生成 `wc:` URI，经 `adb shell am start -a android.intent.action.VIEW -d <wc-uri>` 拉起 App。
- App proposal 页显示测试 DApp，网络为 Ethereum。
- 点击 `Connect` 后，App 弹出 `Message sign` 确认页，地址为 active wallet `Account1`。
- 点击 `Confirm` 后，DApp 离线 `ecrecover` 校验通过：
  - DApp account：`0xEa311dDcF42397dF0007A160baf59E2Aa1ee25AA`
  - Recovered：`0xEa311dDcF42397dF0007A160baf59E2Aa1ee25AA`
  - `match=true`

结论：在 active=`Account1`、verify/mining=`Account2` 的错位前置下，WalletConnect EVM `personal_sign` 使用 active wallet `Account1` 签名，未误用 mining wallet。

未补测：A1 `eth_sendTransaction` 仍需要 gas/funds，本轮继续 BLOCKED_BY_BALANCE。

### A2 Solana `solana_signMessage`

结果：PASS

- 桌面 Node WalletConnect DApp 生成 Solana namespace proposal：`solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ` / `solana_signMessage`。
- App proposal 页显示测试 DApp，网络为 Solana。
- 点击 `Connect` 后，App 弹出 `Message sign` 确认页，地址为 `G3cJyGGSU6zQ6MSzCtXf6Fk7aBe1yhW7X7AFsi5aoTi7`。
- 点击 `Confirm` 后，DApp 使用返回签名对原始 UTF-8 message bytes 做 Ed25519 校验：
  - Account：`G3cJyGGSU6zQ6MSzCtXf6Fk7aBe1yhW7X7AFsi5aoTi7`
  - Signature bytes：64
  - Pubkey bytes：32
  - `verified=true`

结论：Solana WalletConnect message signing 已可被桌面 DApp 验签，非 EVM A2 至少 Solana 路径通过。TRON 未提供桌面 DApp，本轮未覆盖。

## 结论

- PASS：构建/安装/冷启动、A 组错位前置、A3 内置浏览器 `personal_sign` active 账户签名、c176 补测 A1 WalletConnect EVM `personal_sign`、c176 补测 A2 Solana `solana_signMessage`。
- BLOCKED：A1 `eth_sendTransaction` 缺少 gas/funds；A2 TRON 未提供桌面 DApp；A4 缺少已创建/已 funded AA 账户；B1/B2 缺少 EVM native/ERC20 余额。
- 本轮未发现 `miningIndex != selectedIndex` 时内置浏览器签名误用 mining wallet 的回归。
- c176 补测修复了 WalletConnect URI 入口不可达、`wc:` deep link 未落到 WC 页面、空 URI 页卡 loading、Solana message 编码不匹配 native signer 的问题。

## 后续补测条件

- 给测试钱包注入小额 EVM native gas，用于 A1 `eth_sendTransaction`。
- 提供 TRON WalletConnect DApp session，用于 A2 TRON。
- 给测试钱包注入小额 EVM native gas 与 18 decimals ERC20，用于 B1/B2 和 A4 完整广播验证。
