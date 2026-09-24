# 覆盖率扩展与全量复测（2026-09-23）

本轮继续推进主程序 COV-01、Chat 独立仓库覆盖率、服务端配置覆盖和主程序配置覆盖。LCOV 按原始 CI 口径归档；Chat 的非生成代码统计单独标为诊断视图，不与原始百分比混用。

## 主程序全量

- 命令：`ulimit -n 4096; flutter test --no-pub --coverage --concurrency=4 --machine`
- 结果：6,214 项通过，0 失败，0 跳过。
- 覆盖率：63,682 / 132,331 行，927 个源文件，48.1233%。
- 70% 质量门槛：未通过；现有差距为 21.8767 个百分点。没有通过排除文件或更改统计范围提高数值。
- 全量运行发现附件面板首屏回归：无条件的 `Quick Reply` 占据第 3 个槽位，使 `Apps` 落到第 9 项。将 `Apps` 调整到前 8 项后，分页回归测试 7/7 通过，并重新执行上述全量测试。
- 修复提交：`be7d520ec`（`fix: prioritize apps in chat attachment panel`）。
- LCOV：[`main-full.lcov.gz`](main-full.lcov.gz)。解压后可用 `lcov --summary` 或覆盖率工具检查；原始 LCOV SHA-256 记录于 [`summary.json`](summary.json)。

## Chat 正式仓库

- 仓库：`../n42_chat_audit_20260912`，分支 `fix/chat-entry-audit-20260912`。
- 命令：`ulimit -n 4096; flutter test --no-pub --coverage --concurrency=4 --reporter expanded`
- 结果：6,585 项通过，1 项因凭据条件跳过，0 失败。
- 原始覆盖率：33,271 / 133,071 行，648 个源文件记录，25.0024%。
- 诊断视图（`lib/src/`，排除 `.g.dart`、`.freezed.dart` 与 `/l10n/`）：31,941 / 80,662 行，621 个文件，39.5986%。此视图只用于定位后续测试空白，不是 CI 总覆盖率。
- 修复包括 SSO 身份提供商字段类型防护及过期测试夹具更新；4 个相关文件通过 Dart analyze。
- Chat 提交：`8d735268e`（`fix: harden SSO metadata and refresh coverage fixtures`）。该提交位于 Chat 独立审计分支；本轮没有移动主程序的 Chat Git pin。
- LCOV：[`chat-full.lcov.gz`](chat-full.lcov.gz)。

## 主程序配置测试

配置目标测试共 274 项通过、0 失败，Dart analyze 无问题：

| 文件 | 覆盖行 | 覆盖率 |
| --- | ---: | ---: |
| `app_config.dart` | 17 / 21 | 80.95% |
| `rpc_config.dart` | 12 / 13 | 92.31% |
| `api_keys_config.dart` | 4 / 5 | 80.00% |
| `proxy_config.dart` | 60 / 67 | 89.55% |

此次新增代理 base path 边界测试和 API key 配置入口测试，并修复 `/proxy-evil` 被错误识别为 `/proxy` 子路径的授权边界问题。测试环境通过 Dart defines 覆盖开发 URL 警告路径。针对性 LCOV 为 [`config-targeted.lcov.gz`](config-targeted.lcov.gz)。

## 服务端覆盖

所有新增后端测试仅使用本地测试与 loopback HTTP，不依赖第三方生产服务。

| 模块 | 测试后总覆盖率 / 配置结果 |
| --- | --- |
| Go `livekit-jwt` | 72.8%；`loadConfig` 100% |
| Go `loyalty` | 22.1%；`loadConfig`、`env` 100% |
| Go `social-auth` | 18.4%；`loadConfig`、`envOr` 100%，`mustEnv` 75%；同时修正 homeserver 空白处理和非正 TTL 接受问题 |
| Go `swap` | 模块聚合 34.3%，根包 59.2%；CORS middleware、router、环境解析主要分支达到 100% |
| Python `ai-proxy` | `server.py` 95%；19 项测试通过 |
| Python `payment-sandbox` | 96%；47 项测试通过 |

Go 各模块使用 `go test -coverprofile=... ./...` 复测通过。AI proxy 和 payment sandbox 使用各自 unittest suite 验证。

## 证据与限制

- [`summary.json`](summary.json) 保存各范围的计数、覆盖率与 LCOV SHA-256。
- 主程序原始覆盖率 48.1233%，COV-01 仍开放。下一批应针对实际未覆盖的业务分支设计行为测试；不以仅执行代码的空断言测试凑比例。
- 主程序 Chat 镜像测试包含在主程序全量口径中；Chat 正式仓库报告是独立仓库/独立 LCOV，不与主程序百分比相加。
- 测试覆盖率只证明所执行路径，不替代设备验收、支付供应商沙盒或生产准入验收。
