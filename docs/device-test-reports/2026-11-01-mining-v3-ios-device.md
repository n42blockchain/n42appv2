# iOS Mining V3 真机补充验收

日期：2026-11-01。分支：`feat/mining-v3-ios`。设备：USB iPhone 13 Pro Max，iOS 27.0.1，开发者模式已启用。测试节点：`http://192.168.0.217:21100`。

## 桥接真机验收

签名的独立验收应用 `mining.ai.n42.www.flutterMiningExample`，版本 `1.0.0+2`，功能来源 `8ecc29924`。安装保留手机原有主应用与数据。

10 项验收全部通过：[公共结果 JSON](mining-v3-ios-device-2026-11-01/bridge-results.json) · [真机完成画面](mining-v3-ios-device-2026-11-01/bridge-passed.png)。

| 检查 | 实际结果 |
| --- | --- |
| 旧平台通道、错误参数、没有会话、未知方法 | 均返回预期值或错误 |
| 密钥、公钥和会话身份 | 成功，私钥未输出或写入报告 |
| 节点健康、注册 | 成功，测试前 registry 11，新设备 index 11 |
| 最新区块、执行验证、证书查询 | 区块 14409051，21 笔交易，20ms；即时证书查询为空，接口正常返回 |
| 原生 miner 持续验证与证书 | 停止时累计验证 23 块，证书计数 21 |
| 前后台切换 | 会话与计数保留；墙钟 55378ms，有效时长增加 19931ms，排除后台 35447ms |
| 手动停止后再切后台/前台 | 保持停止，不自动恢复，有效时长固定为 41979ms |

首次请求曾返回 `no route to host`。随后在系统设置确认验收应用的“本地网络”已启用，重启验收后成功。没有通过关闭安全保护或修改网络路由绕过授权。未记录首次系统授权弹窗的操作，因此不宣称已验证首次点击授权的全过程。

## 持续验证与锁屏恢复

新增验收工具提交 `084cbd9fa`：首次局域网连接等待最多 30 秒，增加可选的 `MINING_V3_IOS_SOAK_SECONDS`，每次运行清理本测试自己的旧继续标记。签名验收应用版本为 `1.0.0+3`。

[完整公共结果](mining-v3-ios-device-2026-11-01/soak-and-lock-results.json) · [真机完成画面](mining-v3-ios-device-2026-11-01/soak-and-lock-passed.png) · [静态分析](mining-v3-ios-device-2026-11-01/smoke-analysis.txt)

- 前台持续 `301683ms`，新增验证 `151` 块、证书计数 `151`，验证失败 `0`；运行会话和计数未重置。
- 通过 Device Hub 的 Lock 操作真实锁屏；系统确认设备已锁定。用户在设备上完成解锁后，原会话成功恢复。
- 锁屏恢复检查的墙钟间隔 `143283ms`，有效时长增加 `90135ms`，排除后台 `53148ms`。
- 停止后再次切换后台/前台仍停止，有效时长固定为 `413866ms`。最终累计验证 `210` 块、证书计数 `200`，验收阶段为 `passed`，11 项检查通过。
- [电源观察](mining-v3-ios-device-2026-11-01/power-observations.json)：测试前后均为 USB 外接电源、100% 电量。这个环境不能用来计算电池续航，未采集实际温度或热状态数据。

## 主应用流程

签名 Release 主应用 `2.5.3+73078` 已成功构建并安装，覆盖安装保留原有数据；[构建结果](mining-v3-ios-device-2026-11-01/main-release-build.txt)。

- 设置的 V1/V2/V3 均可选择；[V1](mining-v3-ios-device-2026-11-01/settings-v1.png)、[V2](mining-v3-ios-device-2026-11-01/settings-v2.png)、[V3](mining-v3-ios-device-2026-11-01/settings-v3.png)。
- V2 页面正常显示状态和收益卡片（未执行锁仓交易）；[V2 页面](mining-v3-ios-device-2026-11-01/page-v2.png)。V1 当前显示空态，不据此声称 V1 历史节点的端到端挖矿已通过。
- 将节点临时改为 `http://192.168.0.217:21101` 保存，结束主应用进程并重新启动后，V3 选择和自定义端口仍保留；[重启后画面](mining-v3-ios-device-2026-11-01/custom-node-restarted.png)。该端口仅用于验证配置持久化，未连接挖矿。之后已恢复 `21100`。
- 主应用 V3 实际运行 `00:10:46`，累计验证 `304` 块、证书计数 `294`；[运行画面](mining-v3-ios-device-2026-11-01/main-v3-active.png)。运行中节点输入和保存禁用，提示先暂停；[设置锁定](mining-v3-ios-device-2026-11-01/node-locked-while-running.png)。切换 V3→V2→V3 后 worker 已停止，时长与计数保留；[切换后停止状态](mining-v3-ios-device-2026-11-01/version-switch-stopped.png)。
- 无效地址被表单拦截。真机发现提示文本单行截断，提交 `80e364cfa` 允许多行；节点设置 [3 项测试](mining-v3-ios-device-2026-11-01/node-settings-tests.txt)及[定向分析](mining-v3-ios-device-2026-11-01/node-settings-analysis.txt)通过。最终包真机确认完整错误提示换行显示；[修复后画面](mining-v3-ios-device-2026-11-01/node-validation-wrapped.png)。

## 最终签名包复验

已构建并覆盖安装 `2.5.3+73082`，App 功能提交 `711bf01d3`，SDK 提交 `537fed759c4d504ace2323119ed59190359f5d34`。[最终安装包来源与 SHA256](mining-v3-ios-device-2026-11-01/final-artifact.json)。只做本机签名安装，没有上传 TestFlight。

- 修复原生区块日志时区：SDK 明确输出 UTC 与 `logTimeUtc` 元数据，Flutter 转为手机本地时间。旧 SDK 没有该字段时保持原有显示行为。
- 真机最新区块显示 `13:18:06` 等本地时间，与手机状态栏 `1:18` 下午一致；[区块列表](mining-v3-ios-device-2026-11-01/final-blocks-local-time.png)。已获证书筛选正常显示绿色 Certified；[证书列表](mining-v3-ios-device-2026-11-01/final-certified-blocks.png)。
- 最终包复用安全存储中的 Device 13，启动后验证和证书计数持续增长。手动暂停后时长固定 `00:00:50`、验证 `25` 块、证书计数 `15`，成功率 `100%`，平均验证 `14ms`；[最终暂停画面](mining-v3-ios-device-2026-11-01/final-paused.png)。手机保留 V3 与本地测试网 `21100`，worker 已停止。
- 自动验证：[43 项 V3 测试](mining-v3-ios-device-2026-11-01/clock-dart-result.txt)、[11 项插件测试](mining-v3-ios-device-2026-11-01/clock-plugin-tests.txt)、[Go 定向测试与 vet](mining-v3-ios-device-2026-11-01/clock-go-tests.txt)通过。UTC 跨日和夏令时回退用例在 `TZ=America/Toronto` 下通过。[静态分析](mining-v3-ios-device-2026-11-01/clock-analysis.txt)没有错误或警告，保留 4 条现有 `prefer_initializing_formals` 提示。

本报告提交触发版本钩子递增到 `73083`；实测签名包仍为上述 `73082`，报告提交未再修改运行时代码。

## 验收边界

5 分钟通过不能替代多小时稳定性、脱离 USB 的续航测量、真实温度/热压力、电话等系统中断测试。

多节点目录和 bootnode 自动发现仍需实际节点列表或发现接口。当前默认本地测试网和用户自定义 URL 已可用。
