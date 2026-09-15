# 项目文档索引

本目录在 Git 中统一使用 `docs/`。Mac 上 `Docs/` 与其指向同一目录，不应复制成两份。日期型报告保存当时的验证结果；产品计划和路线图不代表功能已交付。

| 主题 | 建议入口 |
|---|---|
| Chat 当前结果、入口审计、真机证据 | [Chat 交付索引](chat-audit-2026-09-12/README.md) |
| Chat 各轮覆盖率与修复 | [合并历史记录](chat-audit-2026-09-12/COVERAGE_HISTORY_2026-09.md) |
| Chat 行业对比 | [市场竞品对比](2026_Chat市场竞品对比.md) |
| 钱包功能与 UI 对接 | [功能入口清单](wallet-feature-wiring-inventory-2026-09-10.md) · [验证报告](wallet-audit-validation-2026-09-10.md) |
| 钱包本地化与深链接 | [本地化审计](localization-audit-2026-09-11.md) · [深链接跟进](deep-link-followup-2026-09-11.md) |
| 测试运行与质量策略 | [自动化测试](AUTOMATED_TESTING.md) · [QA 计划](QA_TEST_PLAN.md) |
| 宿主覆盖率阶段证据 | [WalletConnect 覆盖率提升](testing/wallet-connect-coverage-2026-09-14/README.md) · [完整缺口审计](testing/coverage-gap-audit-full-2026-09-11.md) · [发布后回归](testing/coverage-postrelease-2026-09-11.md) |
| 双端正式发布标准与当前阻塞 | [发布清单](RELEASE_CHECKLIST.md) · [2026-09-14 发布审查](release-audit-2026-09-14/README.md) |
| TestFlight 历史发布 | [2026-09-11 发布记录](testing/testflight-release-2026-09-11.md) |
| 设计系统与模块边界 | [设计系统](DESIGN_SYSTEM.md) · [模块化计划](MODULARITY_PLAN.md) |
| 外部服务配置 | [依赖清单](EXTERNAL_DEPENDENCIES.md) · [配置指引](api-keys-setup-guide.md) |
| 分支和文档维护 | [2026-09-14 整理记录](maintenance/cleanup-2026-09-14.md) |

## 阅读顺序

先看主题索引中的当前状态，再查对应日期的详细报告和机器证据。Chat 的已知未决事项统一在正式插件 `OPEN_ISSUES.md` 维护；本仓库报告链接到该台账。截图、压缩日志、lcov 和哈希均保留原路径，旧覆盖率报告链接会指向合并正文。
