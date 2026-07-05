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

## 结论

- PASS：构建/安装/冷启动、A 组错位前置、A3 内置浏览器 `personal_sign` active 账户签名。
- BLOCKED：A1/A2 缺少外部 WalletConnect DApp pairing session；A4 缺少已创建/已 funded AA 账户；B1/B2 缺少 EVM native/ERC20 余额。
- 本轮未发现 `miningIndex != selectedIndex` 时内置浏览器签名误用 mining wallet 的回归。

## 后续补测条件

- 提供可扫码的 WalletConnect EVM DApp session，用于 A1 `personal_sign` 与 `eth_sendTransaction`。
- 提供 Solana/TRON WalletConnect DApp session，用于 A2。
- 给测试钱包注入小额 EVM native gas 与 18 decimals ERC20，用于 B1/B2 和 A4 完整广播验证。
