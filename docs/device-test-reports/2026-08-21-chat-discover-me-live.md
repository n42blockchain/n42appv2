# Chat Discover / Me / 直播美颜真机验证报告

- 日期：2026-08-21（America/Toronto）
- 分支：`codex/discover-full`
- T29 功能基线：`codex/t29-live-full@7d3ca232`
- 最终重放基线：`master@12e5ad82`（含仅直播房主可发布的 LiveKit 安全修复）
- 设备：iPhone 13 Pro Max（iOS 26.6，USB，已解锁）
- Android：Redmi/HyperOS `25098RA98C`（Android 16 / API 36）

## 结论

本轮补齐 Chat Discover、Me 服务、直播基础美颜与用户友好昵称。iPhone Profile 包
完成签名、安装和启动；生产 Matrix 会话恢复成功，`.well-known` 正确发现
`https://m.si46.world/livekit/jwt` 与 `wss://m.si46.world/livekit/sfu`。随后在同一真机
运行集成视觉回归并生成四张原始分辨率截图，全部断言通过。

Android Profile APK 构建成功；覆盖安装仍被 HyperOS 系统取消：

```text
Failure [INSTALL_FAILED_USER_RESTRICTED: Install canceled by user]
```

未卸载现有 App，避免清除钱包与测试会话数据；Android UI 真机项保持 BLOCKED。

## 功能验证

| 模块 | 状态 | 结果 |
|---|---|---|
| Discover 完整入口 | **PASS** | Moments、Stories、Scan、Search、Live、Listen、Watch、Voice Room、Mini Programs、Games、Communities、Nearby、Channels 均正常布局，无 Coming Soon 占位。 |
| Listen | **PASS（自动化）** | Matrix Story 音乐源、搜索、收藏、播放/暂停、进度、上一首/下一首均已接线；跨设备音乐改为先上传 Matrix，事件不再携带本机文件路径。 |
| Watch | **PASS（路由）** | 进入现有真实短视频 feed，不再显示占位页。 |
| Nearby 隐私 | **PASS（自动化）** | 首次明确提示后才请求一次定位；只展示公开且含位置的 Moments 用户，删除/私密/无位置数据过滤，距离取整且不上传当前精确坐标。 |
| Channels | **PASS（自动化）** | 使用 Matrix public room directory，支持刷新、搜索、分类、加入并打开；移除硬编码假频道。 |
| Me / Services | **PASS** | N42 Bean、Transfer、Red Packet、Payment、Wallet、Card Pack 真机布局正常；红包接入联系人、直聊房间与真实自定义事件发送链。 |
| Me / Orders & Cards | **PASS（自动化）** | 显示本地红包活动；Card Pack 通过宿主回调，未配置时给出明确提示，不伪造成功。 |
| 友好昵称 | **PASS（自动化）** | 人类昵称保持原样；`u_xxxxx`、匿名、钱包/UUID 型账号转为稳定的 `N42 User ####` / `Live Guest ####`，底层 Matrix ID 仍保留用于路由与账号详情。 |
| 直播美颜面板 | **PASS** | 真机布局覆盖磨皮、美白、红润、原图/自然/暖阳/清冷/鲜明/黑白、滤镜强度、恢复原图、按住对比；无溢出。 |
| 美颜实际推流处理 | **STATIC CONFIRMED** | Android WebRTC VideoFrame 与 iOS WebRTC ExternalVideoProcessingDelegate 均接入实际发出帧；双端原生编译通过。本轮未再占用第二台已登录设备做远端逐滤镜视觉比对，不冒充双机 PASS。 |
| 美颜持久化 | **PASS（自动化）** | 磨皮/美白/红润/滤镜/强度保存到 SharedPreferences；再次开播恢复，恢复原图可清零。 |
| 摄像头控制 | **STATIC CONFIRMED** | 开关摄像头、前后切换、后摄闪光灯与麦克风入口已接线；切换镜头时自动关闭闪光灯。 |

直播创建、双机视频、弹幕、礼物、预测、结算与下播判活的既有真机结果见
[T29 报告](2026-08-21-t29-live-full.md)。本轮未修改这些 Matrix 事件协议和结算状态机。

## 真机截图

- [Discover：Live / Listen / Watch](assets/2026-08-21-chat-discover-live/chat-discover-top.png)
- [Discover：Nearby / Channels](assets/2026-08-21-chat-discover-live/chat-discover-nearby.png)
- [Me：Services](assets/2026-08-21-chat-discover-live/chat-me-services.png)
- [直播：美颜与滤镜](assets/2026-08-21-chat-discover-live/chat-live-beauty.png)

## 构建与回归

```text
iPhone Profile 签名安装与启动：PASS
iPhone integration visual test：4 screenshots / All tests passed
Android Kotlin compileProfileKotlin：PASS
Android Profile APK：PASS（906.4 MB）
Discover / Me / friendly-name 定向测试：20 passed
直播测试：52 passed
Chat 插件全量测试：433 passed
flutter analyze --no-fatal-infos：0 errors / 0 warnings（140 existing infos）
```

说明：Android APK 体积来自 Profile 包内包含多 ABI 与本地模型/密码学库，本报告未将
包体优化纳入功能任务。
