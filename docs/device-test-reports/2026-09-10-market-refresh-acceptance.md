# 第 6 批：行情刷新与真机代理鉴权

接续[双机验收记录](2026-09-10-device-retry-acceptance.md)，本批处理“请求失败却显示刚刚更新”及测试包代理 401 的实际原因。

## 已完成的代码修复

- `WalletActionProvider.getCoinInfo` 只有收到可用行情后才记录成功时间；30 秒内复用缓存不刷新时间，请求失败保留旧价格及其原始更新时间。
- 首次无可用报价显示“价格暂时无法取得”；有旧价格但刷新失败时明确提示正在显示已保存价格。正常时间标签明确指向“价格”，避免被理解成所有链余额都已更新。
- 并发调用共享一次行情请求；15 秒超时结束等待，迟到的响应不会再次写入价格。异常后恢复下拉刷新的加载状态，`initCoinInfo` 等待刷新完成。
- 拒绝空响应、无币种标识、缺失价格、负价格及 NaN/Infinity；保留合法的零价格和混合响应中的有效条目。
- 新增币种不会被前一组币种的 30 秒缓存阻止查询；时钟回拨不会让缓存永久有效；销毁后的 provider 不再应用迟到行情或启动新请求。
- 钱包尚未初始化时不排入余额队列，避免空钱包索引触发异步读写。
- 资产卡的人民币估值与价格提示改为可换行布局，支持窄屏与大字体。英文、繁体中文 ARB 已更新，并使用 `intl_utils:generate` 重新生成本地化文件。

## 401 的原因与只读验证

`ProxyConfig` 使用 `String.fromEnvironment` 读取 `PROXY_AUTH_TOKEN`，默认空值。前一轮测试构建没有传入该参数；项目根目录 `.env` 虽然已有有效配置，但不会自动填充编译期常量。

在 Mac 上对同一个 `https://api.n42.ai/proxy/v1/market/trending` 端点进行只读对照：

| 请求 | HTTP 状态 | 返回记录 |
|---|---|---|
| 无 Authorization | 401 | 无 |
| 使用本机现有代理令牌 | 200 | 15 条热门币 |

[脱敏对照结果](evidence/2026-09-10-market-refresh/proxy-auth-comparison.json)不包含令牌。没有修改服务器鉴权规则，也没有更换接口来隐藏认证失败。

本轮真机使用仓库外、权限 0600 的 JSON 文件，仅包含代理地址和令牌；Flutter 命令只引用文件路径。没有将整个 `.env` 注入构建，没有把令牌输出到日志或提交仓库。

`scripts/test_device.sh` 新增可选 `N42_DEVICE_DEFINES_FILE`，拒绝不存在的文件，仍强制 `--no-uninstall`。4 项新增脚本测试覆盖默认参数、带空格文件路径、不输出凭据、拒绝覆盖卸载参数；加上原覆盖率脚本测试共 **8 项通过**。

## 测试与真机进展

新增 21 项真实 provider 测试、8 项资产卡 Widget 测试，共 **29 项通过**；不使用复制生产逻辑的假实现。外部行情接口注入测试响应，覆盖缓存、鉴权失败、重试、并发、超时、销毁、非法价格和 UI 状态。

本批独立模块套件含既有钱包初始化门禁，共 **35 项通过**。明确范围为 `wallet_action_provider.dart`、`wallet_action_provider_market.dart`、`wallet_board.dart`，独立模块覆盖率 **42.99%（233 / 542）**；见[模块报告](../testing/module-coverage-batch6-wallet-refresh-2026-09-10.md)。该数字不能代表整个钱包模块。

带最新修复及代理配置的 Android、iPhone 导航测试均已通过：分别用时 **71 秒、63 秒**，两个平台的实际行情代理检查均返回 **15 条热门币**。检查包括钱包、行情、侧栏页面及返回操作，显式排除需独立登录凭据的 Chat；分别保留[Android 步骤](evidence/2026-09-10-market-refresh/android-navigation.txt)与[iPhone 步骤](evidence/2026-09-10-market-refresh/ios-navigation.txt)。

完整回归 **3,937 项全部通过**，新增 29 项，用时 7 分 33 秒。全项目覆盖率 **19.02% → 19.22%（23,389 / 121,704）**；全量套件中的本批刷新范围为 **45.76%（248 / 542）**，基线为 5.61%。分母包含新增代码与生成本地化代码，没有排除低覆盖文件，也未修改 CI 的 70% 门槛。见[完整 LCOV 报告](../testing/module-coverage-batch6-2026-09-10.md)。

`flutter analyze --no-pub --no-fatal-infos` 为 139 info、0 warning、0 error；改动文件定向分析无问题。脚本 8 项测试、UI 入口清单再生成及一致性检查、`git diff --check` 均通过。

Android 已完成包含正确代理配置的普通 Profile 版本覆盖安装和启动，版本 **2.4.8+2026072637**。[截图](evidence/2026-09-10-market-refresh/android-normal-app.png)显示“Prices just updated”，收发入口和代币列表正常，余额同步指示已结束；这不代表每条链余额都成功联网获取。iPhone 同版本普通 Profile 应用也已完成覆盖安装和启动，构建退出码为 0。[iPhone 截图](evidence/2026-09-10-market-refresh/ios-normal-app.png)确认“Prices just updated”以及钱包入口正常显示，无系统权限弹窗；截图时余额仍在同步，未将其记录为全部余额已验证。两台设备均保留正常 `lib/main.dart` 入口，没有停留在集成测试入口。

## 范围限制

本批行情代理 200 不代表所有链余额接口均可用。此前的 Sui JSON-RPC 协议迁移、原生签名协议差异、部分链余额缓存回退和应用内资金转账闭环仍需继续处理。没有执行主网交易、代币授权或付款，没有清空现有应用存储。

本轮 Android 日志还出现 BASE 代币发现代理的 HTTP 502。补齐鉴权后，这属于继续暴露出来的上游服务问题，未计为成功；不将“无 401”写成“所有代理功能可用”。
