# 分模块补覆盖率：第二批（2026-09-10）

后续进展见[第三批：核心安全与验证码绑定](module-coverage-batch3-2026-09-10.md)。本文保留第二批完成时的数据。

本批继续覆盖 DEX 执行与限价单、Bridge 生命周期、WalletConnect 会话管理。基线为第一批完成后的完整测试集：3,711 项通过、全项目行覆盖率 17.70%。[基线快照](coverage-baseline-batch2-2026-09-10.json)与[第一批报告](module-coverage-2026-09-10.md)保留历史口径。

## 验收结果

完整 LCOV 结果见[第二批覆盖率明细](module-coverage-batch2-details-2026-09-10.md)。

| 范围 | 本批前 | 本批后 | 已覆盖 / 可执行行 |
|---|---:|---:|---:|
| DEX 全模块 | 53.56% | 72.56% | 1,388 / 1,913 |
| Bridge 全模块 | 32.22% | 45.76% | 723 / 1,580 |
| WalletConnect 全模块 | 8.16% | 18.73% | 373 / 1,991 |
| 全项目（含生成代码） | 17.70% | 18.40% | 22,363 / 121,545 |

重点子范围：限价单两页 **99.06%**、DEX 兑换页 **72.18%**、Bridge Provider **93.76%**、WalletConnect 会话页 **88.78%**。这些子范围已经包含在各自模块中。

- 完整 Flutter 测试：**3,770 项全部通过**，用时 5 分 43 秒，较本批基线净增 **59 项**。
- 独立模块测试：DEX **107 项**、Bridge **76 项**、WalletConnect **176 项**全部通过。独立 trace 分别为 72.50%、34.75%、13.96%；上表使用完整测试集，包括其他测试对模块代码的执行，避免混用统计口径。
- 静态分析：**0 error、0 warning、139 条既有 info**，无新增诊断。
- 本批 16 个手写 Dart 文件格式检查、4 项 Python 统计测试、`git diff --check`、UI 入口清单一致性检查通过。
- 四张限价单截图已视觉检查。未进行真机、真实 SDK relay 或链上交易验收。

## DEX：提交、限价单与实际入口

本批新增 20 项行为用例：兑换页增加 8 项、限价单新增 12 项；另增加限价单深浅色共 4 项截图检查。

- 原生币兑换向 `ChainSender` 传递精确的 `valueWeiOverride`、选定钱包的派生路径与索引、链配置、calldata 和收款地址；用户取消、发送异常、缺失派生路径都不产生虚假历史。
- 广播成功后立即使旧报价失效。历史接口返回错误或抛异常时，展示“已提交，请勿重复提交”及交易哈希，禁止用旧确认再次发送。
- 提交使用开始时的用户身份。广播期间切换用户不会记到新用户；离开页面后到达的成功回执仍交给历史接口处理；空哈希不能成为成功记录。
- 限价单输入金额和价格后实时更新提交状态；拒绝零、负数、科学计数、NaN、超过代币精度的金额和相同代币（包括不同原生币别名）。提交保留完整十进制字符串及所选到期时间。
- 提交期间禁用输入、代币选择和到期选项；失败保留输入以便重试；切换链或用户后丢弃旧表单及迟到回调。
- 历史加载失败、损坏响应与空列表分别处理；提供重试；并发刷新只接受最新响应。撤销操作防止重复请求，使用当前页面所属用户，成功后刷新，失败后恢复按钮。
- 从兑换页实际点击 `Limit` → 历史图标 → 到价订单 `Go to Swap`，验证页面跳转和返回，检查 API 已传递到表单和历史页。此入口是用户手动兑换，不表示链上自动成交或已自动预填订单。
- 320 像素窄屏验证长代币名、精确金额、短交易哈希及到期选项无布局异常；390 × 844 逻辑像素截图验证深浅主题。

测试文件：[兑换执行与报价](../../test/features/wallet/pages/dex_swap/dex_swap_quote_flow_test.dart)、[限价单与路由](../../test/features/wallet/pages/dex_swap/dex_limit_order_flow_test.dart)。

## Bridge：报价、授权、广播与恢复

新增 19 项生命周期用例，结合既有授权和精度测试验证：

- 空代币列表不会调用 `.first` 崩溃；修改金额、链、代币、滑点或重置都会使旧报价失效；迟到报价不会覆盖新选择。
- 不合法或换算后为零的金额不调用报价接口；报价异常可重试。
- 执行互斥避免重复签名；准备交易、查询 allowance、获取授权交易、等待授权期间检查执行配置，变更后不继续发起旧交易。
- 原生币跳过 ERC-20 授权；充足的十六进制 allowance 跳过授权签名；不足时只授权精确所需额度，等待 allowance 生效后才广播跨链交易。模拟时钟覆盖授权超时。
- 签名取消、异常或空哈希不产生虚假待确认历史。广播期间修改表单仍按最初的链、代币、金额和地址保存；Provider 已释放后返回成功哈希仍可持久化，重新打开恢复为待确认任务。
- 同一哈希最多一个状态查询在途；终态不会被旧的 pending 响应覆盖；终态回调只触发一次。查询异常保留原状态供下次重试。
- 恢复历史后重启待确认轮询、终态停止继续查询；损坏 JSON 不留下部分恢复的交易。

测试文件：[跨链生命周期](../../test/features/bridge/bridge_execution_lifecycle_test.dart)。金额使用 `1.000000000000000001` 等精度边界。签名与 API 用可控适配器替代；没有真实授权、gas 消耗或链上广播。

## WalletConnect：会话 UI 与 SDK 失败处理

新增 16 项用例：8 项会话页交互、8 项真实 Provider 逻辑（SDK 边界替身）。

- 空会话保留扫码入口；链标签去重并保留未知链标识；过期状态及长 DApp 名可正常显示。
- 单个与全部断开均要求确认，取消无副作用；打开确认框即锁定重复操作，请求进行中禁用冲突按钮。
- 断开失败保留剩余会话并显示错误，按钮恢复后可重试；离开页面后的迟到异常不更新已释放视图。
- 修复 Provider 吞掉 SDK 断开错误的问题：单个失败向页面传递异常，不错误地清空当前会话；成功时只清理对应的活动上下文。
- 全部断开会继续处理每个初始会话；部分失败时保留失败项并向页面报告，允许重试。会话存储读取失败也向页面报告。
- 批量操作捕获 SDK 实例和会话列表；过程中建立的新会话或更换的 SDK 实例不受这次操作影响。

测试文件：[会话页面](../../test/features/wallet_connect/wc_session_list_page_test.dart)、[会话 Provider](../../test/features/wallet_connect/wc_session_disconnect_test.dart)。公共 SDK 会话 fixture 放在 [测试辅助文件](../../test/helpers/wallet_connect_session_fixture.dart)。不连接 Reown relay，不执行真实扫码或签名。

## UI 证据

四张图片均由 Flutter widget 渲染生成，已经人工视觉检查；不是截图像素差异基准测试。自动检查主要捕获布局异常。

- 限价单表单：[浅色](../device-test-reports/evidence/2026-09-10-coverage-batch2/limit-form-light.png)、[深色](../device-test-reports/evidence/2026-09-10-coverage-batch2/limit-form-dark.png)。
- 限价单历史：[浅色](../device-test-reports/evidence/2026-09-10-coverage-batch2/limit-orders-light.png)、[深色](../device-test-reports/evidence/2026-09-10-coverage-batch2/limit-orders-dark.png)。

## 口径、复跑与剩余缺口

模块定义在 [module_coverage.py](../../scripts/module_coverage.py)。DEX 包含全部兑换页面、模型和 API；Bridge 包含该 feature 的全部源码；WalletConnect 包含该 feature 的全部源码。页面、Provider 子范围不能代替模块整体，也不能重复相加。分模块 trace 保存在 `coverage/modules/`；全项目结果只读取完整测试的 `coverage/lcov.info`，不排除生成代码，不降低 CI 的 70% 门槛。

```sh
python3 scripts/module_coverage.py test dex --baseline docs/testing/coverage-baseline-batch2-2026-09-10.json
python3 scripts/module_coverage.py test bridge --baseline docs/testing/coverage-baseline-batch2-2026-09-10.json
python3 scripts/module_coverage.py test wallet_connect --baseline docs/testing/coverage-baseline-batch2-2026-09-10.json
ulimit -n 8192
flutter test --no-pub --coverage --concurrency=2
flutter analyze --no-pub --no-fatal-infos
python3 scripts/module_coverage.py report --baseline docs/testing/coverage-baseline-batch2-2026-09-10.json --output docs/testing/module-coverage-batch2-details-2026-09-10.md
python3 -m unittest discover -s test/scripts -p 'test_*.py'
python3 scripts/audit_feature_wiring.py --check
```

仍需逐模块推进的部分：

| 范围 | 尚未完成的验证或功能 |
|---|---|
| DEX | AA/硬件实际签名、ERC-20 授权链上回执、Solana 执行、兑换历史分页及 API 异常；限价单列表目前只取前 20 条；到价订单不会自动成交 |
| Bridge | 页面与余额/gas 端到端路径、真实路由和目标链到账；历史持久化尚未按用户分区，存储写入失败仍缺少持久重试队列 |
| WalletConnect | Reown relay 生命周期、扫码相机、完整签名审批、会话权限/账户切换与 Browser 来源隔离；读取会话列表失败仍沿用既有空列表回退 |
| 广播后记账 | DEX 历史接口失败有明确提示并防重复广播，但尚未实现跨重启的补记账队列；进程被系统直接终止无法由页面回调兜底 |
| 全项目 | 全部模块覆盖与原 70% 门槛仍未完成；本批结果不代表整个钱包已完成审计或真机验收 |

本批不修改签名材料、不使用真实私钥、不执行发布或 Git 提交。临时测试日志位于 `/tmp/n42-batch2-*.log`；持久证据为本报告、基线 JSON、完整覆盖率明细和截图。
