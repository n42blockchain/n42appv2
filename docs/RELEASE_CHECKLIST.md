# N42 Wallet 正式发布检查清单

适用范围：钱包全应用（含 Chat），iOS App Store 与 Android Google Play。检查结果见[发布审查报告](release-audit-2026-09-14/README.md)、[覆盖率与会话修复](testing/wallet-connect-coverage-2026-09-14/README.md)、[浏览器授权回归](testing/browser-coverage-2026-09-15/README.md)及最新[Chat TestFlight 反馈修复](chat-audit-2026-09-12/testflight-feedback-2026-09-15/README.md)；存在阻塞项时不得把本清单作为发布批准。

## 质量门禁

- [ ] 当前发布源码的完整 Flutter 测试通过；保留机器报告和完整覆盖率。
- [ ] 原始全项目行覆盖率达到 **70%**；不排除生成代码、不调整门槛掩盖缺口。
- [ ] `flutter analyze --no-fatal-infos` 无错误、无警告。
- [ ] `dart format --output=none --set-exit-if-changed lib test` 通过。
- [ ] 钱包/Chat 本地化结构、占位符及经过审查的同文基线通过。
- [ ] Python 发布脚本回归、四个 Go 后端 `go test ./...` / `go vet ./...` 通过。
- [ ] CI 所有必要任务均成功；失败、取消、跳过不能作为成功。

本清单不预勾选。`.github/workflows/ci.yml` 提供可复用检查；Release 流程依赖该检查。当前 70% 覆盖率未达标，发布流水线应阻止分发。

## 版本与配置

版本唯一来源是 `pubspec.yaml` 的 `X.Y.Z+BUILD`，构建应保留提交时的版本；Git 发布标签必须为完全匹配的 `vX.Y.Z+BUILD`。提交钩子仍会递增构建号，正式验收必须对应最终提交及构建号。

- [ ] `pubspec.lock` 已提交，`flutter pub get --enforce-lockfile` 通过。
- [ ] Chat Git pin、实际解析代码和缓存镜像一致。
- [ ] 私有运行配置由 `--dart-define-from-file` 提供，禁止执行配置文件或打印其内容。
- [ ] 生产服务配置、身份认证、推送、恢复/注销、真实资金相关流程使用专用账号/测试资产完成验收。
- [ ] 测试、演示与未完成能力没有误导性的真实资产或成功承诺。

## Android

Google Play 自 2026-08-31 起要求普通移动应用的新提交以 API 36 或以上为目标。[官方要求](https://developer.android.com/google/play/requirements/target-sdk)

- [ ] Release AAB 构建成功，包名、版本号、target SDK 和不可调试属性正确。
- [ ] `android/key.properties`、签名密钥不进入版本库；CI 使用 release 环境的 secrets。
- [ ] WalletCore Maven 认证使用 `WALLET_CORE_USER` / `WALLET_CORE_KEY` 或本地配置。
- [ ] 检查 64 位 ELF 与 APK ZIP 的 16 KB 对齐，并在 16 KB 环境验证启动/关键功能；静态对齐不替代设备测试。[官方说明](https://developer.android.com/guide/practices/page-sizes)
- [ ] 对目标设备的拆分包测量下载大小，不能把包含多 ABI 和符号的 AAB 总大小当作用户下载量。
- [ ] Google Play 内部测试实际安装包通过启动、升级保留数据、后台推送、媒体/通话权限和核心钱包回归。

## iOS

App Store Connect 自 2026-04-28 起要求 Xcode 26 或更高以及 iOS 26 SDK 或更高。[官方要求](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)

- [ ] Release 无签名构建通过；此项只证明编译，不证明可提交商店。
- [ ] 使用有效分发证书及 Runner/NotificationExtension 两份 profile 导出正式 IPA。
- [ ] 主应用和所有扩展版本一致，生产 APNs entitlement 正确，禁用调试 entitlement。
- [ ] PrivacyInfo、用途描述、App Privacy 声明与实际服务端数据行为一致。
- [ ] TestFlight 实际包完成升级数据保留、锁屏通知隐私、登录/恢复/注销、钱包和 Chat 验收。

## 统一构建入口

```sh
# 构建脚本不上传、不改营销版本或构建号，不改写 iOS entitlements。
bash build_release.sh android --dart-define-from-file /private/release.json
bash build_release.sh ipa --dart-define-from-file /private/release.json
# apk / aab / all 也可用；兼容的 prepare_*.sh 委托到同一入口。
```

未指定配置且存在 `.env` 时，将其作为 Flutter 数据文件传入，不通过 shell 执行。归档后的 IPA 默认本地导出，`manageAppVersionAndBuildNumber=false`。商店上传是独立步骤。

GitHub Release 环境还需要 Android 签名/Play 服务账号、iOS 证书及扩展 profiles、App Store Connect API 私钥和运行配置。应为 `release` 环境配置所需审核与分支限制；仓库 YAML 本身不证明远端已完成配置。

## 必备发布证据

- [ ] 源码提交、版本号、依赖清单、测试/分析/覆盖率报告。
- [ ] AAB/IPA 哈希、签名、manifest/entitlement 及设备验收记录。
- [ ] 隐私政策、用户协议、截图、审核账号、供应商及地域配置核对。
- [ ] 服务监控、错误告警、数据迁移验证、回滚与客服方案。
- [ ] 所有阻塞项关闭；Chat 未决事项以[正式插件台账](https://github.com/n42blockchain/n42_chat/blob/fix/chat-entry-audit-20260912/OPEN_ISSUES.md)为准。
