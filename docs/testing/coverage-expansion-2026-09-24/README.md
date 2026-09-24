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

## COV-01 状态

2026-09-24 后续完整主程序运行按 CI 文件句柄上限执行 `ulimit -n 4096; flutter test --no-pub --coverage --concurrency=4 --machine`：6,224 项通过、0 失败、0 跳过，机器输出包含 `success: true` 的 `done` 事件。全量 LCOV 为 63,710 / 132,404 行、927 个文件（48.1179%）。覆盖率高价值路径持续补强，但 70% 质量门槛仍未达到，COV-01 继续开放。

主程序全量 LCOV：[`main-full.lcov.gz`](main-full.lcov.gz)，解压后的 SHA-256：`ddf14e398d2747c97d5b86e02958a609ad00121459a6a7f8fc373c74a66ad3a9`；gzip 归档 SHA-256：`64a4e93f9bff41ac5f9b07606b0f9f2069c04aaa4608b5750856817014e8a279`。
