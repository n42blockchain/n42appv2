# Claude Code 项目配置

## Git 提交规则

- **重要**: 所有 git 提交不要包含 "Claude" 或 "Co-Authored-By: Claude" 等字样
- 提交信息只需要描述修改内容，不需要署名

## 项目结构

- 主项目: C:\N42\n42appv2 (Flutter 应用)
- Chat 插件: D:\n42\n42_chat (聊天功能模块)
- 区块链节点: /Users/jieliu/Documents/n42/minto/ (Rust 主节点 + Go Erigon fork)
- 技术栈: Rust（主链节点）、Go（Erigon fork）、TypeScript/Flutter/Dart（前端/移动端）
- **开始工作前确认当前目录属于哪个子项目**

## Session Continuation

When continuing from a previous session, immediately summarize the prior state in 2-3 sentences and begin executing — do NOT re-explore the entire codebase. Ask the user to confirm the plan only if something is ambiguous.

## Workflow Rules

- Prefer implementation over planning. When the user says "continue" or "继续", they want execution, not more planning.
- If a plan already exists (check for plan files first), start coding immediately.
- Only write a new plan if explicitly asked.

## Git Operations

- 提交模板：`GIT_COMMITTER_NAME="Nyxen" GIT_COMMITTER_EMAIL="40690755+MiraWells@users.noreply.github.com" git commit --author="Nyxen <40690755+MiraWells@users.noreply.github.com>" -m "message"`
- Push 到 Gitee 时可能触发邮箱隐藏拒绝错误，主动检查 git remote 配置。Push 失败时立即重写 commit author 信息，不要反复调试。

## Code Quality

- 生成代码后立即运行静态分析（flutter analyze / go vet / cargo check 等），不等用户询问。

## Communication

- 用户使用中文（普通话）交流，始终用中文回复，除非用户切换到英文。
- "直接"、"继续" 等简短指令表示立即执行，无需进一步澄清。
