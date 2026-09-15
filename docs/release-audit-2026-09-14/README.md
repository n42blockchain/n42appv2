# 钱包全应用双端发布审查 — 2026-09-14

最新验证：见[2026-09-15 Chat TestFlight 反馈修复](../chat-audit-2026-09-12/testflight-feedback-2026-09-15/README.md)，钱包全量 4,870 项测试通过，覆盖率仍为 45.96%；最终 Chat pin 的追加回归、精确版本和真机验收边界见该报告。之前的[浏览器覆盖率与授权回归](../testing/browser-coverage-2026-09-15/README.md)保留阶段快照。

后续更新：[WalletConnect 覆盖率提升](../testing/wallet-connect-coverage-2026-09-14/README.md)记录本报告之后的 4,721 项测试、45.74% 覆盖率和 3 项会话修复。以下数字、源码哈希与双端构建证据保留为当时快照；原构建成品不包含后续修复，不能作为最新源码验收证据。

**结论：当前不能批准正式发布。** 已修复本轮发现的代码与发布流程缺陷，双端 Release 编译通过，但完整覆盖率仍为 **45.23% / 70%**，并有真实分发/设备验收及 Chat 已知生产问题未关闭。

范围为钱包全应用（含 Chat），iOS App Store 和 Android Google Play。基线提交为 `8ecdb286`，修复尚在工作区，版本 `2.4.8+2026072654`。没有提交、推送发布修复、创建发布标签、上传商店、安装设备或执行真实资金操作。

## 本轮修复

1. **生产 TLS 失败回调**：以前未命中 pinnedHosts 的主机会直接接受不可信证书；现在所有生产 TLS 校验失败都拒绝，不能再由旧指纹覆盖证书链/域名/有效期失败。正常连接继续由平台信任库校验。旧 fingerprint 常量不是已启用的证书 pinning。
2. **敏感数据容器脱敏**：先判断敏感键再遍历值，避免 tokens 列表、seed/authorization 对象泄漏到诊断文本。新增回归在旧脱敏实现上失败。现有 secureLog 只在 Debug 输出，本报告不声称发生过生产日志泄漏。
3. **Android 发布目标**：targetSdk 35 → 36。构建成品 manifest 确认 API 36、包名 `ai.n42.www`、不可调试、版本正确。[Google Play 当前要求](https://developer.android.com/google/play/requirements/target-sdk)
4. **发布门禁**：Release 依赖可复用 CI；完整覆盖率保留 70%；测试计数读取真实机器事件，兼容 Flutter daemon 消息；构建/后端任务失败或跳过不能变成成功。原有 benchmark 的 sleep 模拟不再被包装成真机启动/内存达标。
5. **统一构建入口**：旧入口实际构建 Debug APK，把 `2.4.8+123` 改成 `2.4.9`，并执行 `.env`。新入口构建 Release，保留完整版本，将配置作为 Flutter 数据文件传入，错误参数/缺配置/缺签名提前失败。两个 prepare 脚本委托到同一入口，不再改写 iOS entitlements。
6. **iOS 导出与 CI 配置**：修复不存在的 ExportOptions 引用；使用本地导出、禁止自动改版本，上传独立执行；加入 iOS 26 SDK 检查、扩展 profile、App Store API 私钥文件和失败后清理。远端 secrets、证书及环境审核是否配置，仍需实际确认。[Apple SDK 要求](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)
7. **质量一致性**：修复 284 个非生成 Dart 文件的格式漂移，补充法语 `Points` 的单项同文审查记录，重新生成 UI 引用清单。未手工修改生成的 Dart 文件。新增 Android ELF 对齐审查工具及发布脚本回归。

## 最终验证

| 检查 | 结果与边界 |
|---|---|
| 完整 Flutter 测试 | **4611 通过，0 失败，0 跳过**；修复前基线为 4606 通过 |
| 行覆盖率 | **59123/130725（45.23%）**，70% 门禁正确返回失败；未筛掉生成代码 |
| 静态分析 | 0 错误、0 警告，155 条既有 info |
| Python 脚本回归 | 39 通过；覆盖版本、私密配置传参、错误停止、机器报告和 ELF 校验 |
| Go 后端 | swap / social-auth / loyalty / livekit-jwt 的 test 与 vet 全通过 |
| 工作流/格式/本地化 | actionlint 1.7.7、shell 语法、Dart 格式、钱包/Chat 本地化及入口清单检查通过 |
| Android Release AAB | 构建成功，537,337,041 bytes；bundletool validate 通过；JAR 签名校验通过并有自签名/无时间戳等警告，不能代替 Play 验收 |
| Android 16 KB 静态检查 | 55 个 64 位 ELF 对齐通过；指定 ARM64 拆分包内 31 个原生条目 ZIP 对齐通过；**未运行 16 KB 设备** |
| Android 设备下载量估算 | ARM64 / API 36 / 480dpi / en 配置为 **155,458,176 bytes**；AAB 含多 ABI 和调试符号，537 MB 不是该设备下载量 |
| iOS Release | Xcode 26.6 / iphoneos26.5 下无签名构建通过；主应用与通知扩展均为 2.4.8+2026072654，隐私 manifest 已打包；**未验证正式签名 IPA** |

Android 初次 `--no-pub` 构建命中了旧的 integration_test 插件注册文件；重新按构建模式生成依赖后通过。统一入口的原生构建允许 Flutter 重新生成对应模式的注册信息。ARM64 APKS 只用于结构/大小测量，使用工具的测试签名，没有安装或作为发布包交付。

[机器统计与源码/证据哈希](summary.json)记录完整命令、AAB/Runner 可执行文件哈希与工具版本。重点证据：[完整测试](final-tests.jsonl.gz)、[完整覆盖率](final.lcov.gz)、[静态分析](analysis.log.gz)、[Android 构建](android-release.log.gz)、[iOS 构建](ios-release.log.gz)、[脚本回归](python-tests.log.gz)、[旧脱敏失败](redaction-before.log.gz)、[旧构建入口行为](builder-before.json)。

## 仍阻塞正式发布

- **REL-008：覆盖率不足。** 当前分母不变时，距离 70% 尚缺 32,385 条已执行源码行。需补真实业务路径测试，优先资金、授权、恢复、WalletConnect、桥接与低覆盖页面；不能用批量调用生成代码或降低门槛代替质量工作。
- **REL-009：分发与设备验收。** 需要最终签名 IPA、Play/TestFlight 实际包及双端真机验收，覆盖升级保留数据、后台/锁屏、权限、恢复/注销、钱包和 Chat；现有历史设备记录不自动适用于本次源码。
- **REL-010：Chat 生产问题。** 后台 APNs 隐私（SEC-005）、非密码账号注销（SEC-004）、邮箱真实服务/多邮箱/丢失响应恢复（AUTH-001）仍按[正式 Chat 台账](https://github.com/n42blockchain/n42_chat/blob/fix/chat-entry-audit-20260912/OPEN_ISSUES.md)维护。此报告不复制上游完整问题清单，也不宣称全部功能已完成。
- **REL-011：发布配置与材料。** 生产服务与专用验收账号、隐私声明和服务端实际数据处理、商店材料、远端 release 环境配置、监控/回滚方案，需要服务与发布负责人补验。代码存在用途描述和 privacy manifest 不等于商店合规已获确认。

执行标准见[发布检查清单](../RELEASE_CHECKLIST.md)。本次进行了全应用测试、静态/入口检查，以及关键网络安全和发布链路审查；未声称逐行业务证明、全部线上功能验收或正式商店批准。
