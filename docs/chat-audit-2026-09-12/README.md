# Chat 审计交付与设备证据

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
flutter drive --driver=test_driver/chat_audit_device_test.dart --target=integration_test/chat_audit_device_test.dart -d <android-device> --no-pub
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

截图中的菜单背景属于隔离测试页面，并非完整会话截图。测试后已成功编译正常 `lib/main.dart` 入口的 Debug APK（build 2026072642），但两次恢复覆盖安装都被小米系统拒绝：`INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`。设备仍保留本轮测试入口，需要保持解锁并允许“通过 USB 安装”提示后再次覆盖安装；没有卸载或清除应用数据。

## iPhone 验收状态

USB iPhone 13 可识别；本轮未安装成功。Xcode 编译后在签名 N42Extension 时返回 `errSecInternalComponent`。对两张 Apple Development 证书分别用临时可执行文件探测签名，也都失败；`security show-keychain-info` 返回 `User interaction not allowed`。因此是本次 Mac 进程访问私钥失败，不能以此前已授权或构建编译完成代替验收。

需要 Mac 端解锁“登录”钥匙串，并允许对应 Apple Development 私钥被 codesign 使用；此后重跑同一驱动目标。没有修改签名证书或导出私钥。

## 明确未闭环项

- 在线 GIF 与 AI 私聊：当前构建缺少直接提供方配置/本地模型 URL；本轮恢复入口和状态，不代表服务已上线。
- 群 AI：缺 Matrix bot 身份、响应服务及上下文政策（AUTO-002）。
- 贴纸包跨用户分享/导入仍为仓库桩方法（MEDIA-005）。
- 独立 Settings 的部分账号回调未统一（INTEGRATION-002）。
- 539 个直接 UI 文案候选仍待逐模块审查（QA-006）；26 份 ARB 完整不能代替此项。
- 通话、通知、加密、多账号跨端链路仍按正式插件 OPEN_ISSUES.md 逐项验收。

正式插件 [审计分支](https://github.com/n42blockchain/n42_chat/tree/fix/chat-entry-audit-20260912) 保存实现与完整测试；宿主 `pubspec.yaml`、`pubspec.lock` 和本目录源文件哈希清单记录精确集成版本。

## Git 源集成复核

最终锁定 `cbc7bd1a128d841ff667708e513fc1ca0b708f9e`；移除已跟踪的 n42_chat 路径覆盖，其他原生插件覆盖保留。`flutter pub get` 仅改变 Chat 一项依赖，锁文件为 Git 来源。实际解析包与缓存的 764 个 lib/assets 文件路径和 SHA-256 完全一致；见 [源码清单](CHAT_SOURCE_MANIFEST_2026-09-12.json)。INTEGRATION-001 的宿主源码分叉在此集成中关闭。

改用 Git 依赖后追加运行定位、AI 页面、表情面板、GIF 生命周期及精简菜单测试，18 项通过。全量宿主覆盖率仍使用前述完整运行，不用这个小集合替代。

本目录插件报告来自同一提交；入口索引相对链接已适配宿主缓存路径，正式工具与完整插件测试保留在 Chat 仓库。
