# Chat 追赶计划与宿主集成（2026-10-30）

## 交付

Chat 源码在独立工作树 `../n42_chat_weekly_20261030` 修改，以宿主原 pin `a4951b13` 为基线，避免覆盖既有安全分支。

- `0e945fc4`：群内追赶面板、会话提及筛选、本地日历建议与确认、针对性测试。
- `b936d405ecac7a95ea67dd8cc054447565b9bd43`：追赶计划、分层验收矩阵、生产证据检查器、SDK 导入 CI 门禁和实测日志。
- Chat 两项提交均已推送到 `origin/feat/chat-catch-up-20261030`。宿主 pubspec 与 lockfile 固定到 `b936d405...`；`flutter pub get` 仅改变 Chat 依赖。package_config 实际指向该 SHA 的 Git 缓存，没有使用未跟踪的 `packages/n42_chat/` 镜像。

[完整实施计划](https://github.com/n42blockchain/n42_chat/blob/b936d405ecac7a95ea67dd8cc054447565b9bd43/docs/plans/2026-10-30-chat-catch-up.md)和[验收矩阵](https://github.com/n42blockchain/n42_chat/blob/b936d405ecac7a95ea67dd8cc054447565b9bd43/docs/testing/weekly-2026-10-30/ACCEPTANCE.md)与模块源码一起版本化。

## 已实现及边界

- 永久消息置顶复用已有 Matrix 状态事件，本轮增加保留已有列表、无过期字段及重复操作的回归验证。
- 群聊顶栏新增追赶入口，按置顶、结构化提及、直接回复分类，跳回原文并支持加载更早消息。只筛选已加载消息；回复以原消息 ID 和本人 MXID 匹配，不按昵称推断。排除撤回、阅后即焚和其他房间事件。
- 会话“提及”筛选使用服务器高亮计数；不承诺完整的未读回复覆盖。
- 显式 ISO 时间与时区可生成本地日历建议。确认页显示 UTC/本地时区与起止时间，再调用已有 iOS EventKit / Android ACTION_INSERT 编辑器；不发送正文、联系人或钱包参数。Android 返回成功只表示打开编辑器，不表示已经保存。
- 新增生产指标检查器，未测量字段保留 null，未测量或无证据时阻止宣称通过。SDK 门禁记录 13 个既有 presentation 直接导入，不增加新的 SDK 依赖，不宣称已经完成解耦。

## 验证

工具链：Flutter 3.47.5。

- 宿主聊天初始化、钱包桥行为/拒绝/桥接测试：70 passed，exit 0。
- 宿主 `flutter analyze --no-pub --no-fatal-infos`：exit 0，无 error/warning，53 条既有 info。
- Chat 新功能及置顶针对性测试：23 passed；小屏幕追赶面板组件：1 passed；Python 两组门禁测试合计 4 passed。
- Chat 全量：7,732 passed / 4 skipped / 2 failed。两个既有浅/深色 golden 分别有 4/6 像素差异，在未修改的 `a4951b13` 独立工作树同样复现。未刷新基线或放宽阈值，完整回归不标为全绿。
- Chat 全量分析无 error/warning；新增文件定向分析 No issues found。

原始宿主日志与校验值在同名目录。没有执行签名、资金广播、App Store/TestFlight 上传或生产部署。

## 尚未完成

受控历史补发、完整未读回复索引、群 Status、Apple Suggested Actions/自然语言行动建议尚未实现。计划明确了权限重检、选择性重新加密、确认快照、群内审计、未知发送结果对账及逐步 SDK 解耦顺序；普通转发不算选择性历史补发。

3 设备/20 人/10,000 条消息、30 次恢复、撤销设备新密钥、推送日志泄漏及真实钱包确认需要受控环境和设备证据。20–30 人追赶实验、行动建议精确率和完成率实验未运行。不得以本轮单测推断这些指标达标。新增文案英文、简体和繁体中文已提供，其他语言暂回退英文。

原有未跟踪计划文件与 `packages/n42_chat/` 保留原状。宿主提交 hook 会自动递增构建号；这不代表已构建或发布。
