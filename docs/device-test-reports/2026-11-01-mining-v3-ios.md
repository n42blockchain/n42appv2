# iOS Mining V3 桥接与本地测试网验收

日期：2026-11-01。应用分支：`feat/mining-v3-ios`。SDK 分支：`feat/mobileverify-ios-bindings`。

## 实现范围

- iOS `n42/mobileverify` 通道接入 Go V3 SDK，包含密钥、公钥、会话、注册、区块验证、证书、健康状态及原生挖矿启停/状态接口。
- SDK 使用独立、可供 Objective-C 绑定的 V3 facade。设备 arm64 和模拟器 arm64/x86_64 均包含在 XCFramework 内。源码版本、工具链与文件校验值见 [SDK-PROVENANCE.json](../../plugins/flutter_mining/ios/Frameworks/SDK-PROVENANCE.json)。
- iOS 设置允许选择 V1/V2/V3。退出 V3 会停止运行或后台暂停的会话，也会取消尚未完成的启动。
- 默认临时测试网：`http://192.168.0.217:21100`，chain：`mainnet_qmdb_staggered`。`MINING_V3_URL` 构建参数和用户已保存的自定义 URL 仍然有效。连接面板提供“使用本地测试网”，按保存后才生效。
- iOS 进入后台停止原生验证工作，回到前台恢复用户尚未停止的会话。保留会话 ID、区块列表及计数；有效时长排除后台暂停时间。手动停止后不会自动恢复。
- 后续节点列表或 bootnode 发现接口尚未接入，等待节点列表或明确的发现协议。当前没有虚构收益金额。

## 验证结果

| 检查 | 结果与边界 |
| --- | --- |
| Go facade 与原生 miner 定向测试 | 通过；`go vet ./cmd/mobileverifyios` 通过 |
| Swift host 生命周期、并发取消与会话测试 | 9 项通过 |
| Flutter V3、设置和版本切换定向测试 | 56 项通过 |
| Flutter 插件通道与数据解析测试 | 11 项通过 |
| 定向 Dart 静态分析 | 无 error/warning，4 条已有 `prefer_initializing_formals` 提示 |
| iOS 设备及模拟器 Swift 类型检查 | 通过 |
| 插件示例完整模拟器构建 | 通过，实际 CocoaPods 编译、链接与隐私资源打包 |
| iOS 27.1 模拟器连接真实局域网测试节点 | 10 项验收检查通过，详见下文 |
| 主应用未签名设备构建 | 通过，`flutter build ios --debug --no-codesign --no-pub`，产物 `build/ios/iphoneos/Runner.app` |
| iPhone 真机运行 | 未验证；当前 `devicectl` 中的 iPhone 不可用 |

环境：Flutter 3.47.5 / Dart 3.13.4，Go 1.26.8，Xcode 27.1 (27A9275)。模拟器为本任务新建的 iPhone Duo / iOS 27.1，未使用其他开发者的模拟器。

测试对应应用功能提交 `6a1c9e082`（主应用版本 `2.5.3+73075`）。插件示例显式使用测试版本 `1.0.0+1`。主应用未签名构建同样使用功能版本 `2.5.3+73075`。之后的验收工具/文档提交仍由钩子递增主应用版本；未上传发行包。

## 模拟器运行证据

[完整公共结果](mining-v3-ios-2026-11-01/simulator-results.json) · [结束画面](mining-v3-ios-2026-11-01/simulator-passed.png) · [Swift 测试](mining-v3-ios-2026-11-01/swift-host-tests.log) · [Go 测试](mining-v3-ios-2026-11-01/go-tests.log) · [静态分析](mining-v3-ios-2026-11-01/dart-analysis.log)

- 旧平台通道、缺少参数、没有会话和未知方法的处理均通过。
- 新生成的临时身份注册为 device index `10`；测试前 registry 为 `10`，注册后为 `11`。私钥仅保存在测试进程内存，没有写入报告或日志。
- 单次探针验证区块 `14390308`，`31` 笔交易，原生耗时 `18ms`。该次立即查询证书为空，接口正常返回；不能把空查询当作已有证书。
- 随后的原生 miner 实际验证并取得证书。停止时累计验证 `16` 块、证书计数 `9`。
- 真实切换到系统设置再返回：墙钟经过 `15488ms`，原生有效时长增加 `9053ms`，排除后台时间 `6435ms`。会话和计数保留。
- 手动停止后再次切换后台/前台，仍停止、未挂起待恢复，累计有效时长固定为 `31106ms`。最终测试阶段为 `passed`。

## 复现方式

在 `plugins/flutter_mining/example` 执行，使用专用且已启动的模拟器 UUID。此测试会在所选测试网注册一个新临时身份，并切换该模拟器的前台应用。

```sh
flutter pub get
flutter build ios --simulator --debug --no-pub \
  --target integration_test/mobileverify_ios_smoke_app.dart \
  --dart-define=MINING_V3_IOS_SMOKE=true --build-name=1.0.0 --build-number=1
xcrun simctl install "$SIMULATOR_UUID" build/ios/iphonesimulator/Runner.app
python3 integration_test/drive_mobileverify_ios_smoke.py "$SIMULATOR_UUID" \
  --output /tmp/n42-ios-smoke-results.json
```

未设置 opt-in 参数时，测试应用不发起注册或挖矿。驱动只读取公共结果，完成后矿工停止。

## 隐私与后续验收

隐私资源随插件打包：有效时长使用系统单调时钟，声明 SystemBootTime 的 `35F9.1` 原因；注册用公共验证者身份按设备标识及应用功能用途声明。原因依据为 [Apple required-reason API 文档](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)。这不代表已完成 App Store 隐私审查。

主应用首次构建因隔离工作区缺少忽略的 Firebase 配置失败，复用本机既有 `GoogleService-Info.plist` 后重跑成功；配置未提交。构建保留现有 Rust SDK 的最低 iOS 版本与若干搜索路径警告，这次未修改这些模块。

仍需可用 iPhone 上验收首次局域网授权、锁屏/系统中断、长时运行、电量与发热，以及主应用完整 UI 流程。本报告的模拟器通过不等于真机通过。
