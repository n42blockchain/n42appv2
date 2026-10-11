# 本次验收记录

2026-10-10，Flutter 3.47.5 / Dart 3.13.4。

- 新增 `scripts/verify_wallet_reliability.sh` 实际执行通过，退出码 0。
- 定向回归 468 项通过，测试退出码 0。
- 全仓 `flutter analyze --no-pub --no-fatal-infos` 退出码 0；48 项 info，无 error/warning。
- 改动文件格式检查、`git diff --check`、脚本 `bash -n` 通过。
- 默认 Flutter 的 Dart 3.12.2 不能解析项目要求；最终结果来自兼容 SDK，未降低项目约束。

修复已通过本地验收：缺失、非整数、非正数或非法字符串的主网 chain ID 不再默认签为 Ethereum；已有 N42 主网94/测试网1142、字符串 ID 与 RPC 选择回归通过。

证据：`summary.json` 记录 base HEAD、退出码和未压缩内容 SHA256；`change.patch.gz` 记录本次受测代码；`tests.log.gz`、`analyze.log.gz` 和 `toolchain.txt.gz` 保存输出。本次未运行全套 coverage，不作70%覆盖率结论。

尚未通过：跨设备恢复、链上 Agent 额度/白名单/撤销、重复付款端到端幂等、后台杀进程恢复、链重组与索引漏报、设备 P95、供应商订单/KYC/收费闭环、真实用户对照、官网/双商店身份反链。详见 PLAN.md 的场景、角色与关闭条件。

保留原有未跟踪文档和历史验收材料。未更新 Chat cache、商店、官网或发布包。
