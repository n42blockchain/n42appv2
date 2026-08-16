# Chat 发送扩展栏与 E2EE 会话密钥真机验证

- 日期：2026-08-15
- 宿主分支：`master`
- n42_chat 分支：`feat/chat-plugin-source-sync`
- n42_chat 提交：`c87d359a49e3297af5a5eedb96555572c6c45952`
- iOS：iPhone 13 Pro Max（iPhone14,3），iOS 26.6，USB
- Android：Redmi 25098RA98C（kunzite），Android 16 / API 36，USB
- 状态定义：PASS / FAIL / STATIC CONFIRMED / BLOCKED

## 结论

| 项目 | 状态 | 结果 |
|---|---|---|
| iOS Profile 构建、签名、覆盖安装、启动 | PASS | Apple Development 签名成功，`ai.n42.www` 覆盖安装并启动 |
| iOS 从宿主进入 Chat、进入真实会话 | PASS | 真机驱动首次运行进入已有会话 `test00002QQ` |
| iOS 打开发送扩展栏 | PASS | 附件按钮可点击，扩展栏实际渲染；首屏为 Photos / Take Photo / Location / Contact / File / Poll / Event / Apps |
| iOS 扩展栏布局 | PASS | 小屏无溢出，输入栏、分页点、最近媒体区域均在可视范围 |
| 最近媒体选择与最多 9 项 | STATIC CONFIRMED | Widget 测试覆盖选择顺序、上限和窄屏；本轮真机只确认区域加载与布局，未执行真实媒体发送 |
| 缺失 Megolm key 主动恢复 | STATIC CONFIRMED | 新增测试确认向其他设备发 `m.room_key_request`，并在 key 到达后以同 eventId 即时刷新明文 |
| 历史缺 key 消息恢复 | BLOCKED | 原发送设备/在线备份没有可提供的旧 session，密文无法凭空恢复；不得冒充 PASS |
| 缺 key 的 UI 表现 | PASS | 不再把 SDK 错误正文渲染成绿色普通消息；改为中性锁图标 `encrypted` 占位，真机渲染断言与截图通过 |
| Android Debug 构建 | PASS | `app-debug.apk` 构建成功 |
| Android 安装及扩展栏真机验证 | BLOCKED | `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`，设备未安装 `ai.n42.www` |

## E2EE 修复定性

用户提供的现场照片显示同一会话连续出现 `The sender has not sent us the session key.`，且当前用户自己的事件被绿色气泡包裹。确认是三个问题叠加：

1. Matrix SDK 初次解密失败时默认只尝试在线 key backup；没有 backup 时不会继续向其他设备请求。
2. 仓库只监听 `/sync`，没有把 `Timeline.onUpdate`（session key 到达后重解密）传给消息流。
3. 未解密事件按 eventId 缓存五分钟；即使 timeline 已替换为明文，旧错误仍可能留在 UI。另有 mapper 将 SDK 的错误正文误判为普通文本，导致自己的历史事件显示成绿色气泡。

修复后：缺失 session 会以一分钟退避主动向房间设备请求；key 到达会触发消息流刷新；未解密事件不缓存；`m.bad.encrypted` 固定映射为中性加密占位且不保留 SDK 错误正文。已经永久丢失且无任何设备/备份持有的旧 key 仍不可恢复，这是 E2EE 的协议边界。

## 自动化与构建证据

- n42_chat 定向测试：28 项 PASS（event mapper、Megolm 恢复、发送扩展栏、最近媒体）。
- 宿主聊天 SSO / 社交认证回归：47 项 PASS。
- iOS 真实会话扩展栏驱动：首次运行 `All tests passed`。
- iOS 最终加密占位真机渲染：`All tests passed`，并断言页面不存在 `session key` 错误正文。
- 定向 analyze：无 error；仓库原有 `prefer_initializing_formals` / `close_sinks` info 不阻断。

## 截图与现场证据

- [用户现场：连续缺失 session key](evidence/2026-08-15-chat-e2ee-missing-session-key.jpg)
- [iOS 宿主启动成功](evidence/2026-08-15-chat-extension-ios-launch.png)
- [iOS 真实会话发送扩展栏](evidence/2026-08-15-chat-extension-ios.png)
- [iOS 最终中性加密占位 + 扩展栏](evidence/2026-08-15-chat-e2ee-placeholder-ios.png)
- [Android 当前设备桌面（App 未安装）](evidence/2026-08-15-chat-extension-android-home.png)

## 备注

第一次 iOS 驱动保留了原有 Chat 登录态，因此完整真实会话链路 PASS。Flutter Driver 测试包退出后清理了该测试安装的数据；最终映射修复后的再次完整导航运行停在未登录状态，未把它记录为 PASS。最终 UI 修复使用同一台 iPhone、同一 Profile 构建对真实 `MessageItem` 与 `ChatMorePanel` 做设备渲染和截图验证。
