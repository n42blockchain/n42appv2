# Chat 审计交付与设备证据

## 设置模块后续修复

正式插件代码提交：`16fe83a8bcd2493c296d73ba9f909b2e5d2a5b56`。独立设置路由与个人页已统一；聊天设置分类、账号操作认证传递、默认持久化、失败回滚和平台写入拒绝处理已接通。40 项新增测试与原有 About 回归共 41 项通过。固定提交全量 5,867 通过、1 项在线凭据测试跳过；设置页面覆盖率 13.93% → 42.05%，插件原始覆盖率 17.97% → 19.23%。宿主相关 109 项及新 Git 依赖设置回归 19 项通过，静态检查 0 错误、0 警告、155 条 info。详见 [设置审计](SETTINGS_AUDIT_2026-09-12.md)。

下面三张为本地 Widget 夹具，320×850 逻辑像素、1.6 倍文字，加载 Geeza Pro 字体以便审阅阿拉伯文；不是本轮真机截图。已检查文字排列、箭头方向和窄屏布局。两台真机当前安装与登录会话未改动。

| 设置首页 | 聊天设置 | 通知设置 |
|---|---|---|
| [截图](widget-settings-ar.png) | [截图](widget-chat-settings-ar.png) | [截图](widget-notification-settings-ar.png) |

正式未决项以 [Chat OPEN_ISSUES.md](https://github.com/n42blockchain/n42_chat/blob/fix/chat-entry-audit-20260912/OPEN_ISSUES.md) 为准。账户跨端切换及推送投递仍待真实服务验收，533 个直接文案候选仍需按模块复核。

以下保留首轮审计与设备验收记录。


日期：2026-09-12。此目录保存本轮可复核证据；计划见 [模块计划](../CHAT_PLUGIN_AUDIT_PLAN_2026-09-12.md)，竞品依据见 [产品对比](../2026_Chat市场竞品对比.md)。

## 自动化验证

- 正式插件 `flutter test --coverage`：5,826 通过、1 个需要在线凭据的 smoke 跳过（生产代码基线 `a3b4a13`）；测试警告清理另跑 333 项通过。最终定位修复另跑 2 项通过。
- 插件 `flutter analyze --no-pub --no-fatal-infos`：0 error、0 warning；173 条 info 保留。
- 宿主 `flutter test --no-pub --coverage --concurrency=4`：4,163 通过；59,112/130,694 行，45.23%。
- 宿主静态检查：最终 Git 依赖解析后为 0 error、0 warning、155 条 info；此前路径覆盖构建为 286 条 info。
- 插件原始覆盖率 23,507/130,813 = 17.97%；排除生成文件的参考视图 22,975/79,128 = 29.04%。完整模块表见 [覆盖率报告](COVERAGE_AUDIT_2026-09-12.md)。CI 门槛没有改变。

## Android 真机

USB 小米设备型号 25098RA98C，Android 16 / API 36。执行：

```sh
./scripts/run_chat_device_acceptance.sh <device-id>
```

通过。测试使用本地仓库夹具，不登录账号、不发真实消息；验证真实 Flutter 组件的入口、选中回调、菜单展开、阿拉伯语和无配置状态。不能据此认定真实 GIF 检索/对端贴纸收取/AI 生成已通过。

| 场景 | 截图 |
|---|---|
| 英文统一表情分栏 | [截图](android-expression-en.png) |
| 已安装贴纸选择 | [截图](android-stickers-en.png) |
| GIF 缺服务状态 | [截图](android-gif-unavailable-en.png) |
| 英文首层 / 更多操作 | [首层](android-menu-compact-en.png) · [展开](android-menu-expanded-en.png) |
| 阿拉伯语首层 / 更多操作 | [首层](android-menu-compact-ar.png) · [展开](android-menu-expanded-ar.png) |
| 阿拉伯语 AI 缺配置 | [截图](android-ai-unavailable-ar.png) |

截图中的菜单背景属于隔离测试页面，并非完整会话截图。初次恢复 Android 正常入口时，两次覆盖安装被系统拒绝；本次用户配合后 `adb install -r -t` 成功，已启动正常应用。用户随后登录 Chat，实际“我 → AI Assistant / Stickers”入口可打开；检查后回到消息列表，保留当前登录会话。真实账号截图仅留本机，没有提交到仓库。

## iPhone 重试结果

本次已通过 iPhone 13 真机本地 UI 验收，保存 8 张截图。签名失败已定位为 Background 执行会话：同一证书在 GUI Terminal 签名成功，不能再归因于用户未解锁钥匙串。第一次调试连接重置后，使用 GUI Terminal 与 `--disable-dds` 重跑通过。

**验收发生应用卸载事故：** Flutter drive 默认测试后卸载应用，本次日志确认了 iPhone 的卸载。这可能清除应用容器中的本地数据；恢复正常安装不等于恢复这些数据。已恢复并验证初始化标记，以避免下一次启动额外执行遗留钥匙串清理；没有读取/导出钱包私钥或助记词。正常 Profile 应用已覆盖安装，工具退出后主进程保持运行，初始化标记仍为 true。用户随后确认 iPhone Chat 已登录；两台手机的当前 Chat 登录均已完成。钱包与历史聊天数据的连续性仍须核实。修复脚本已强制 `--keep-app-running`，另有 10 项脚本与质量门禁回归通过。

详见 [重试与恢复记录](DEVICE_RETRY_2026-09-12.md)。后续使用上面的保留应用脚本，测试后覆盖安装正常入口；iOS 签名从 Mac 的 GUI Terminal 执行。

| iPhone 场景 | 截图 |
|---|---|
| 表情分栏 / 已安装贴纸 | [表情](ios-expression-en.png) · [贴纸](ios-stickers-en.png) |
| GIF 未配置 | [截图](ios-gif-unavailable-en.png) |
| 英文首层 / 展开 | [首层](ios-menu-compact-en.png) · [展开](ios-menu-expanded-en.png) |
| 阿拉伯语首层 / 展开 | [首层](ios-menu-compact-ar.png) · [展开](ios-menu-expanded-ar.png) |
| 阿拉伯语 AI 未配置 | [截图](ios-ai-unavailable-ar.png) |

## 明确未闭环项

- 在线 GIF 与 AI 私聊：当前构建缺少直接提供方配置/本地模型 URL；本轮恢复入口和状态，不代表服务已上线。
- 群 AI：缺 Matrix bot 身份、响应服务及上下文政策（AUTO-002）。
- 贴纸包跨用户分享/导入仍为仓库桩方法（MEDIA-005）。
- 独立 Settings 的部分账号回调未统一（INTEGRATION-002）。
- 539 个直接 UI 文案候选仍待逐模块审查（QA-006）；26 份 ARB 完整不能代替此项。
- 通话、通知、加密、多账号跨端链路仍按正式插件 OPEN_ISSUES.md 逐项验收。

正式插件 [审计分支](https://github.com/n42blockchain/n42_chat/tree/fix/chat-entry-audit-20260912) 保存实现与完整测试；宿主 `pubspec.yaml`、`pubspec.lock` 和本目录源文件哈希清单记录精确集成版本。

## Git 源集成复核

首轮锁定 `cbc7bd1a128d841ff667708e513fc1ca0b708f9e`；移除已跟踪的 n42_chat 路径覆盖，其他原生插件覆盖保留。`flutter pub get` 仅改变 Chat 一项依赖，锁文件为 Git 来源。实际解析包与缓存的 764 个 lib/assets 文件路径和 SHA-256 完全一致；最新设置模块升级后的 767 文件一致性结果见 [源码清单](CHAT_SOURCE_MANIFEST_2026-09-12.json)。INTEGRATION-001 的宿主源码分叉在此集成中关闭。

改用 Git 依赖后追加运行定位、AI 页面、表情面板、GIF 生命周期及精简菜单测试，18 项通过。全量宿主覆盖率仍使用前述完整运行，不用这个小集合替代。

本目录插件报告来自同一提交；入口索引相对链接已适配宿主缓存路径，正式工具与完整插件测试保留在 Chat 仓库。
