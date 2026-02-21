# Claude Code 项目配置

## Git 提交规则

- **重要**: 所有 git 提交不要包含 "Claude" 或 "Co-Authored-By: Claude" 等字样
- 提交信息只需要描述修改内容，不需要署名

## 项目结构

- 主项目: C:\N42\n42appv2 (Flutter 应用)
- Chat 插件: D:\n42\n42_chat (聊天功能模块)

## Session Continuation

When continuing from a previous session, immediately summarize the prior state in 2-3 sentences and begin executing — do NOT re-explore the entire codebase. Ask the user to confirm the plan only if something is ambiguous.
