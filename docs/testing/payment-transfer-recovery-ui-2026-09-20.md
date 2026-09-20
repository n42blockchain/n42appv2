# P13 — 本地转账未知结果恢复 UI

日期：2026-09-20。状态：实现及窄测试完成，待主代理审查提交。

## 修改范围

只改 `lib/features/payments/presentation/local_payment_lab_page.dart`、对应 `test/features/payments/presentation/local_payment_lab_page_test.dart` 与本文。没有修改红包页、SDK、host 或提交。

## 行为

- 发起转账前，按当前 synthetic token 在页面内存保存不可变原请求快照：key、asset、recipient、amount。
- 未确认请求锁定输入；重试读取原快照并使用原 key，不能改参后创建新 key。
- `Check original result` 只调用 `recoverRequest` 的 GET 查询；成功后至多额外 GET 刷新余额，不提交转账。
- completed 必须是 transfer 收据且 recipient/asset/amount 与原快照逐项相同，才展示结果并清 pending。unresolved、404、查询异常或不匹配收据继续保留原 key。
- 同页面换号清理可见旧余额/收据，按 token 保存各自 pending；切回恢复原输入与锁定状态。页面 generation 使旧查询成功或错误无法覆盖新会话。
- client 实例替换清所有 pending 与表单；离页/重启不保存恢复 key，页面明确提示这一限制。没有将 token 或 pending 写入持久存储。
- 已知转账成功后余额刷新失败，只提示 Refresh；不会把已成功转账恢复成待重试付款。

## 验证设计

新增 widget 测试覆盖 GET-only 已完成恢复、余额刷新失败、unresolved/404/收据不匹配保留原键、原 body 重试、换号切回 pending 快照、旧异步查询忽略，以及 client 替换清内存。保留原有正常转账、大字布局、余额刷新、换号与禁用入口测试。

```sh
flutter test --no-pub test/features/payments/presentation/local_payment_lab_page_test.dart
```

最终 **13/13 tests passed**，日志 `/tmp/n42-transfer-recovery-ui-tests.log`。新增 6 项测试，保留原 7 项。mock 已跟随主代理 SDK `/requests?key=...` 协议。此前一次并发 Flutter 共享 build 的 native_assets 文件缺失，经主代理安排串行测试窗口后通过；未执行 clean、未影响其他模块文件。
