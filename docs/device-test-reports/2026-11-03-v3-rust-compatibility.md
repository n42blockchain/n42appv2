# V3 与 Rust 节点兼容性确认

日期：2026-11-03。App 运行时代码基线 `e38653737`；验收工具修复 `156fabf3d` 已合入 `master`。

## 结论

V3 运行时代码、iOS 原生桥接与 SDK 和本轮真机测试版本一致。iOS XCFramework 的全部 provenance 校验值通过，SDK 源码提交为 `537fed759c4d504ace2323119ed59190359f5d34`。

本轮使用当前 N42-rs `2b75d4062aa2e3612653a310e453a7a488c0543a` 编译节点，手机运行 Go V3 SDK。独立测试链使用 `mainnet_qmdb` 执行规则，四个 Rust 验证节点、一个 QMDB 执行层和区块包 sidecar。

## 配置要求

节点与 SDK 必须使用一致的分叉规则。主应用默认仍是 `mainnet_qmdb_staggered` 和旧局域网入口 `http://192.168.0.217:21100`，不能据此直接连接本轮测试链。构建本轮测试环境的应用时明确指定：

```sh
--dart-define=MINING_V3_CHAIN=mainnet_qmdb \
--dart-define=MINING_V3_URL=http://192.168.0.56:21103
```

用户已保存的自定义节点地址优先于构建默认值，需要在 V3 连接设置中确认。Chain 通过构建参数选择，修改 URL 不会自动修改 chain。

以上地址仅用于本机独立测试，验收后测试网已停止。`mainnet_qmdb` 不是其他生产链的通用替代配置。将 Shanghai/Cancun 提前到第 1 块的本地 genesis 与原 `mainnet_qmdb_staggered` SDK preset 不一致，空块可能通过而交易块失败。

## 本轮验证

- 本主工作区的 V3 测试 43 项、插件通道测试 8 项全部通过。
- 合入后的验收工具静态分析无问题；`git diff --check` 通过。
- iPhone 13 Pro Max / iOS 27.0.1，独立验收应用 Release `1.0.0+8`：11 项检查通过。
- 带转账负载持续 `300190ms`，新增验证 99 块、证书 98 块，失败 0。
- 前后台切换保留会话并排除约 15 秒后台时间；手动停止后再次切换前后台仍停止。
- 修复验收工具仅检查成功计数增长、可能漏掉后续验证失败的问题；现在持续运行及生命周期结束均要求失败数为 0。

[完整节点报告与公共证据](https://github.com/n42blockchain/N42-rs/blob/59a73a08c1c42aa261f6d9be5e289c86e526ba36/docs/device-test-reports/2026-11-03-mobileverify-v3-ios.md)。

本轮未重新构建并安装完整主应用，真机结果来自使用相同运行时插件与 SDK 的独立验收应用。主应用既有安装与数据保留。Android、生产链、锁屏、长时运行、耗电与温度不在本轮验收范围；未上传 TestFlight。提交钩子递增主应用版本号不代表生成了新的真机或发行包。
