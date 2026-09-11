# 第 5 批：WalletConnect 页面与风险提示

## 范围与修复

本批增加 21 项 Widget 测试，沿生产目录分别放在 `test/features/wallet_connect/pages/` 和 `test/features/wallet_connect/widgets/`。

- 连接页：空入口从旧 loading 状态恢复；深链接首帧后触发配对；退出清除 `pageOpen`；粘贴链接去除空白后传给配对动作。
- 错误及连接状态：错误文本可见，关闭时清理上下文；已连接页面的断开入口对接正确动作，不重新发起配对。
- 交易及消息请求：确认、取消分别调用正确的方法；进行中的请求继续显示明细并隐藏确认/取消按钮，不产生额外签名调用。
- 风险提示：普通转账、无法解码的调用、无限授权、零额度撤销、Permit 多条警告；繁体中文、深色模式、320 宽度与两倍字体下无布局溢出。
- 加载遮罩：页面及实际 `WalletConnectSheet.show` 弹出面板中，加载时下方操作不可点击；结束加载后恢复操作。

新增加载遮罩测试最初失败：`LoadingPage` 只绘制中间的进度指示器，`Positioned.fill` 本身不会阻止点击穿透。已在 WalletConnect 页面和面板的遮罩中加入 `AbsorbPointer`，阻止加载期间触发下层断开/签名动作。修复限制在这两个调用处，不改变全应用共用的进度组件行为。

## 统计与验证

模块套件 **197 项通过**，此前同一模块为 176 项；新增加 21 项。

WalletConnect 整体 **373 / 1991（18.73%）→ 628 / 1991（31.54%）**，增加 255 个已执行源码行、12.81 个百分点。风险提示组件达到 **98 / 98（100%）**。详见[模块独立 LCOV 报告](module-coverage-batch5-wallet-connect-2026-09-10.md)。

`scripts/module_coverage.py` 的 WalletConnect 测试发现改为递归 `**/*_test.dart`，确保新建的 `pages/`、`widgets/` 测试进入模块套件。模块 trace 独立保存在 `coverage/modules/wallet_connect.info`，不覆盖全量 `coverage/lcov.info`；没有移除低覆盖文件，也没有下调 CI 的 70% 门槛。

完整回归 **3,908 项通过**（新增 21 项），用时 7 分 02 秒。全项目行覆盖率 **22,848 / 121,651（18.78%）→ 23,134 / 121,651（19.02%）**，增加 286 个已执行源码行。完整套件中的 WalletConnect 仍为 **628 / 1,991（31.54%）**；分母保留全部源码和生成代码，距离 CI 的 70% 门槛仍有明显差距。见[全量 LCOV 报告](module-coverage-batch5-2026-09-10.md)。

`flutter analyze --no-fatal-infos`：139 info、0 warning、0 error；改动文件定向分析无问题。覆盖率统计脚本的 4 项 Python 测试、UI 入口清单再生成及一致性检查、`git diff --check` 均通过。

这些 Widget 测试使用可观测的测试 provider 隔离网络和签名，只验证页面呈现及操作对接；不等于实际 relay 配对、账户认证或链上支付通过。真实手机上的导航和原生签名检查单独记录在[双真机验收报告](../device-test-reports/2026-09-10-device-retry-acceptance.md)。
