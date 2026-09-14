# 钱包 Chat 依赖集成 — 2026-09-14

钱包正式 Git 依赖从 `c1d222e3ea9c49a5f8bc51444154eb4026d689ef` 更新为 `ebaa003b3dd882be9f951cb73c88633fa618f76c`，包含收藏单记录持久化、邮箱验证码/链接验证与绑定失败重试修复。

`flutter pub get` 仅改变 n42_chat 的解析版本。`pubspec.yaml`、`pubspec.lock` 和常规 package config 均指向新提交；没有使用临时 package config。769 个 lib/assets 文件在 Git 解析目录、缓存镜像与[源码清单](CHAT_SOURCE_MANIFEST_2026-09-12.json)之间逐一哈希一致，相关 7 个测试文件同步自同一 Git 提交。

常规钱包测试新增入口 `test/features/chat/chat_favorites_email_regression_test.dart`，复用 104 项收藏与邮箱行为回归，并通过 package 导入检查实际 Git 依赖。没有添加新的测试依赖。

| 验证 | 结果 |
|---|---|
| 钱包 Chat 与质量检查 | 457 项通过 |
| 钱包静态分析 | 0 错误、0 警告，155 条既有 info |
| Git 源码、镜像及清单 | 769 个源码/资源文件一致 |

[机器统计](wallet-integration-2026-09-14/summary.json)、[依赖解析日志](wallet-integration-2026-09-14/pub-get.log.gz)、[钱包回归日志](wallet-integration-2026-09-14/tests.log.gz)、[静态分析日志](wallet-integration-2026-09-14/analyze.log.gz) 已归档。

此前候选检查的 498 项包含临时引入的页面与 AuthBloc 测试；本次 457 项为常规钱包入口的持久化/服务/仓库及既有检查，范围不同。插件 6,411 项通过、1 项跳过的完整回归沿用[邮箱重试验证证据](EMAIL_RETRY_2026-09-14.md)，已核对修复源码哈希相同，本次不声称重跑了插件全套测试。

本次完成依赖集成；没有新增真机构建或真实邮箱/账号验收。多邮箱语义、SSO/多步骤 UIA 和丢失响应恢复仍以正式 Chat `OPEN_ISSUES.md` 的 AUTH-001 为准。
