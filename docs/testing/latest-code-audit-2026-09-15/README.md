# 最新代码审计与修复 — 2026-09-15

基线：钱包 `cd120b4c`，Chat Git 依赖 `4b146b688a46c48653155d9e49e0778b15d77814`。审阅最新联系人、生物识别、密钥恢复改动，以及近期浏览器会话保护的执行链路。本轮修改在钱包源码中，Chat Git 依赖及缓存镜像未变更。

## 已修复

| 优先级 | 问题与触发条件 | 修复 |
|---|---|---|
| P1 | 签名确认等待期间切换钱包、网络或离开页面，旧逻辑只丢弃响应，仍可能读取变化后的私钥、签名或发送交易。 | 每个请求捕获页面、钱包与链状态，在批准后、读取私钥后及广播前复核；切链再切回也使原请求失效。另校验私钥派生地址与请求地址一致。 |
| P1 | 在 Polygon 等非主网调用 `eth_signTransaction` 时，没有传入链 ID，签名库默认使用 `1`。 | 显式传入当前链 ID；通过固定测试私钥验证完整签名结果。 |
| P2 | 网站连接钱包 A 后切换到 B，按域名保存的授权会直接向网站暴露 B 的地址。 | 授权绑定域名和具体地址；新钱包需独立授权，确认期间切换钱包会拒绝旧连接请求。 |

## 验证

- `flutter test --no-pub test/features/browser test/features/chat/chat_testflight_feedback_regression_test.dart --reporter expanded`：374 项通过。
- `flutter analyze --no-pub --no-fatal-infos`：0 错误、0 警告，155 条既有 info。
- 新增 30 项回归，覆盖批准期间切链/切回、换钱包、原模型地址变化、页面刷新/导航/关闭、读取私钥期间请求失效、私钥地址不匹配、非主网签名、连接授权隔离。交易测试使用固定测试私钥和本机回环 RPC，验证成功广播及 nonce 查询后失效不广播两条路径。
- 四个修改的 Dart 文件通过格式检查；`git diff --check` 通过。

本机默认 Xcode 尚未确认许可，原生测试资源构建最初失败。测试改用已安装的 `/Library/Developer/CommandLineTools`，并通过临时 PATH 中的 `xcrun` 包装器为原生构建 hook 显式选择该工具链；没有修改系统工具链选择或接受许可。

## 上游检查与真机

GitHub Chat `main` 当前为 `491e595cc686d2a9095a70363b4c068ed1f88a36`，钱包锁定版本为 `4b146b688a46c48653155d9e49e0778b15d77814`。上游差异为 252 个文件、约 3,382 行新增和 21,593 行删除，包含核心服务、路由、设置页面及大量测试删除，不能作为无风险的小版本升级；本轮未改动 `pubspec.yaml`/`pubspec.lock`，需另开迁移评审。

已连接 Android 真机 `25098RA98C`（Android 16 / API 36）。执行 `flutter test integration_test/app_test.dart -d 38f4f08a --no-pub`：APK 构建、安装、启动、生命周期暂停/恢复全部通过，`1` 项通过。尚未执行需要专用账号、Face ID/指纹交互或真实 Matrix/链服务的真机场景。

## 验证边界

未运行全钱包测试套件、覆盖率统计、iOS/Android 真机测试或发布构建。未向真实链广播交易，未声称完成全部代码或外部服务审计。最新 Chat 回归使用钱包实际 Git 依赖运行；Face ID 系统交互、Matrix 服务端策略和双端恢复仍沿用[原验收边界](../face-id-contact-2026-09-15/README.md)。
