# 覆盖率续跑（2026-09-24）

本批继续覆盖 Chat、Go 服务端配置和 Flutter 配置。LCOV 保持各仓库原始口径；Chat 非生成代码与 Chat 核心路径单列为诊断视图。主程序 70% 质量门槛仍以最近一次完整 CI 口径结果为准。

## Chat 独立仓库

- 仓库：`../n42_chat_audit_20260912`，分支 `fix/chat-entry-audit-20260912`，基线提交 `38af33fc`；本批新增安全测试提交 `942a4ed1`（`test: validate markdown link protocols`）。
- 命令：`ulimit -n 4096; flutter test --no-pub --coverage --concurrency=4 --reporter expanded`
- 结果：6,593 项通过、0 失败、1 项跳过。跳过项为 `test/live/live_media_smoke_test.dart`，需要有效实时媒体凭据。
- 原始 `lib/` 覆盖率：33,395 / 133,072 行，648 个文件记录，25.0954%。
- 非生成 `lib/src/` 诊断视图：32,065 / 80,663 行，621 个文件，39.7518%。
- Chat 核心路径诊断视图：5,434 / 19,279 行，28.19%。该范围只用于定位测试空白，不替代原始覆盖率。
- 新增 `markdown_message_link_security_test.dart`，验证 HTTPS 消息链接可打开，`javascript:` 链接不会交给 URL launcher。单测 1/1 通过，也包含在上述全量结果中。
- 全量 LCOV：[`chat-full.lcov.gz`](chat-full.lcov.gz)，解压后的 SHA-256：`d45b3e28c50e46877d999a95a282d485855908c8ee2406801507b3b4d27ac38a`。运行日志在本机 `/tmp/n42_chat_audit_full_20260924.log`。
- 运行前后 `.flutter-plugins-dependencies` 和 `example/pubspec.lock` 的哈希一致；保留了仓库原有未提交状态。

## Go 服务端配置

| 模块 | 结果 |
| --- | --- |
| `backend/social-auth` | 全模块测试通过，18.4%；`loadConfig`、`envOr` 100%，`mustEnv` 75% |
| `backend/swap` | 全模块测试通过，34.3%；根包 59.2%，`getEnv` 100%，`mustEnv` 75% |

补强的子进程用例分别验证缺少必填环境变量时退出码为 1，且输出完整变量名诊断。`mustEnv` 的退出分支在子进程中执行，因此不会计入父测试进程的 Go 覆盖率文件；这是 Go 子进程覆盖率口径的限制，不代表该行为未经断言。

本批只改 `backend/social-auth/config_test.go` 和 `backend/swap/main_test.go`，未改服务端生产代码。其他 Go/Python 服务模块的历史结果见[前一批报告](../coverage-expansion-2026-09-23/README.md)。

## Flutter 配置

生产默认环境与 `ENV=development` 各运行配置目标测试，均为 56 项通过；另以带末尾斜线的代理 base URL 和仅 host 的 base URL 各运行 1 项边界测试，均通过。配置运行使用以下隔离的测试 Dart defines 覆盖网络配置分支：

```text
BTC_TESTNET_RPC=http://test.invalid
BTC_MAINNET_RPC=http://main.invalid
MINING_WS_URL=ws://dev.invalid
MINING_RPC_URL=http://dev.invalid
```

多次构建环境的 LCOV 按源文件和行号取覆盖并集，结果如下：

| 文件 | 覆盖行 | 覆盖率 |
| --- | ---: | ---: |
| `app_config.dart` | 20 / 21 | 95.24% |
| `rpc_config.dart` | 12 / 13 | 92.31% |
| `api_keys_config.dart` | 4 / 5 | 80.00% |
| `proxy_config.dart` | 61 / 67 | 91.04% |
| **合计** | **97 / 106** | **91.51%** |

新增断言覆盖所选环境下的 API 与 ID Hub chain、iOS/Android swap 开关、代理 URL 末尾斜线归一化和 host-only origin 边界。未覆盖行主要是不可实例化配置类的私有构造函数、代理 path 自身带末尾斜线分支，以及没有被读取的 `_tokenChecked` 静态字段及其 debug 警告函数。`_tokenChecked` 当前只有声明，没有读取点；是否要在应用初始化中触发该警告应作为独立配置行为修复评估，本批没有改变启动行为。

配置并集 LCOV：[`dart-config-variants.lcov.gz`](dart-config-variants.lcov.gz)，解压后的 SHA-256：`f049ae146c794a7480bc4b977de4710933abbe90003796187966db327dfeddde`。定向 Dart analyze 无问题，`git diff --check` 通过。

## Flutter 钱包发送 Max

`send_logic_guard_test.dart` 新增 5 项 Max 金额回归测试，覆盖 XRP 预留余额、原生币 Max 手续费重估、异步估算期间保留用户编辑、代币全余额及手续费仍加载时不重复估算。XRP 用例先复现余额 20 XRP、手续费 1 XRP 时错误地发送 19 XRP，再验证 Max 扣除 10 XRP 预留后为 9 XRP；修复在转账额计算中应用 Ripple 预留值。

`wallet_chain_send_logic.dart` 在本次完整 LCOV 中为 125 / 327 行（38.2263%），上一份主程序全量 LCOV 中为 95 / 324 行（29.3210%）。定向 `dart analyze` 无问题。

## Flutter 钱包备份确认

`backup_three_interaction_test.dart` 新增 6 项测试（5 项真实页面交互测试和 1 项旧入口兼容测试），使用全内存安全存储平台和合成钱包数据：空密码、无效密码和不匹配确认都不会写入；安全存储写入失败时页面保持打开、退出 loading 并允许重试；保存等待期间的重复点击只写入一次；成功时确认合成密码确实写入后才退出；旧 `saveWalletInfo` 在存储失败时仍按兼容契约吞错。

RED 测试发现 `saveWalletInfo` 扩展方法会捕获并吞掉安全存储错误，导致页面将失败写入当作成功并退出。新增 `saveWalletInfoOrThrow` 共用原写入逻辑但向调用方传递错误，备份确认页改用该严格入口；其他现有调用仍保留原有吞错兼容行为。失败后可恢复重试的回归测试 RED→GREEN。

`backup_three.dart` 在最新全量 LCOV 中为 101 / 111 行（90.9910%）。生产代码未使用真实钱包、助记词、密码或密钥。Dart analyze 无问题。

## Flutter 钱包资产与助记词导入

本轮分三次独立提交，新增 8 项真实页面/Provider 路径测试，测试数据和平台通道均为合成内容。

- 账户隔离：通过真实 `WalletActionProvider.getWalletInfo()` 和模拟安全存储，验证新登录账户创建自己的 `Account1`，且 `AstranetWallet` 旧记录保留。临时恢复旧匿名钱包迁移逻辑时测试按预期失败，恢复隔离实现后通过。
- 资产发现：两个 widget 测试覆盖 Ethereum/Solana 合成 USDC 结果、搜索及所选网络筛选，以及 API 错误提示并结束 loading。`WalletCoinAddAll` 增加可选 `TokenViewApi` 注入；生产调用仍使用默认 API，没有发出网络请求。
- 助记词导入：五个 widget 测试覆盖空剪贴板启动、空格/tab/换行规范化、无效词组、重复钱包拒绝、进入密码设置页和等待校验时离页。手动输入和剪贴板文本现在共用任意连续空白折叠逻辑。

| 文件 | 上轮覆盖 | 本轮覆盖 | 本轮行数变化 |
| --- | ---: | ---: | ---: |
| `wallet_action_provider_wallet.dart` | 27 / 282 (9.5745%) | 63 / 282 (22.3404%) | +36 |
| `wallet_coin_add_all.dart` | 0 / 153 (0%) | 145 / 153 (94.7712%) | +145 |
| `wallet_coin_add_all_data.dart` | 0 / 164 (0%) | 121 / 165 (73.3333%) | +121（增加 1 行） |
| `wallet_coin_add_all_logic.dart` | 0 / 304 (0%) | 25 / 304 (8.2237%) | +25 |
| `import_one.dart` | 0 / 144 (0%) | 133 / 144 (92.3611%) | +133 |

## COV-01 状态

钱包资产、导入交互提交后，按 CI 文件句柄上限完整运行 `ulimit -n 4096; flutter test --no-pub --coverage --concurrency=4 --machine`：5,780 个可见测试通过、0 失败、0 跳过；另有 462 个隐藏加载/设置事件通过，共 6,242 个成功的 machine `testDone` 事件，`done.success=true`。较上一轮新增 8 个可见测试和 3 个隐藏事件。全量 LCOV 为 64,779 / 132,409 行、927 个文件（48.9234%）；相比上轮的 48.2123% 提高 0.7111 个百分点。原始分母保留，70% 质量门槛仍未达到，COV-01 继续开放。

主程序全量 LCOV：[`main-full.lcov.gz`](main-full.lcov.gz)，解压后的 SHA-256：`39b34f14c0e7d16317952768334701b7c9cb76dedc6b4508be03f43f9e4dd22b`；gzip 归档 SHA-256：`dfc897896f17d9d086b3ab8563a5b94edacb6ec8613e33d3114f971599c829c3`。归档已验证与 `coverage/lcov.info` 字节一致。
