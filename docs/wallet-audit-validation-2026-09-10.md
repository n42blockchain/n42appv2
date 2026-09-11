# 钱包功能审计验证记录

后续进展见[第二轮实现与验证记录](wallet-followup-implementation-2026-09-10.md)：本地历史完整导出、DEX 原生 value 与 AA 账户流程已继续修复；本文保留首轮审计时点的发现。

验证对象为本次工作区代码，配套[研究与审计报告](wallet-industry-research-and-functional-audit-2026-09-10.md)及[公开页面引用清单](wallet-feature-wiring-inventory-2026-09-10.md)。这是代码与自动化验证记录，不是实机、正式服务或链上资金操作的验收证书。

## 环境

- 本地 Flutter 3.44.8、Dart 3.12.2。
- CI 的 Flutter 版本已同步到 3.44.8；原有覆盖率 70% 门槛保留。
- `n42_chat` 在当前 package config 中解析到 `packages/n42_chat/` 本地镜像；未修改聊天包源码，也未将主仓测试当作聊天独立仓的验收。
- 没有运行签名发布、部署 swap 服务或发起真实资产交易。

## 命令与结果

| 检查 | 命令 | 结果 |
|---|---|---|
| 静态分析 | `flutter analyze --no-fatal-infos` | 通过，0 errors、0 warnings、139 infos；info 未作为失败处理 |
| 主套件与覆盖率 | `ulimit -n 8192; flutter test --no-pub --coverage --concurrency=2` | 通过，3,632 项，5 分 19 秒；LCOV 19,891 / 121,149 = 16.42%，未达 70% |
| swap 服务 | `cd backend/swap && go test ./...` | handlers、services 全部通过；其余包没有测试文件 |
| 报价与确认专项 | `flutter test --no-pub test/features/wallet/dex_quote_confirmation_test.dart` | 3 项通过，包括 320px/1.4 倍文字的长金额报价卡 |
| 历史只读与金额精度 | `flutter test --no-pub test/features/wallet/transactions/btc_history_widget_test.dart` | 2 项通过，精确金额及只读路由验证 |
| 视觉渲染 | `flutter test --no-pub test/screenshots/wallet_audit_screenshot_test.dart` | 6 项通过：个人页、兑换确认、本地记录空状态，各有亮/暗主题 |
| 本地化 | `flutter pub run intl_utils:generate` | 通过，生成文件由工具刷新 |
| 入口清单 | `python3 scripts/audit_feature_wiring.py --check` | 通过；扫描 978 个非生成 Dart 源文件、274 个测试文件、232 个公开页面/页面组件 |
| 全仓格式 | `dart format --output=none --set-exit-if-changed lib test` | 未通过：1310 个文件中 313 个有既有格式差异；与本次工作区修改文件交集为零，未执行全仓格式重写 |
| 补丁检查 | `git diff --check` | 通过 |

首次全套运行受本机默认 open-files 软限制 256 影响，出现 `Too many open files`。提高当前测试进程的文件句柄上限并降低并发后重跑。没有修改系统全局设置，也没有修改测试断言或覆盖率门槛绕过失败。一次中途复跑在追加只读路由保护时遇到旧编译缓存与新测试构造参数不一致，已通过停止代码修改、重新启动完整套件进行验证；最终结果仅引用静止代码快照的运行。

## 新增回归范围

本次新增 29 项回归/视觉测试，最终主套件已全部纳入，覆盖以下行为：

- 数据库层在两种历史表中合并秒/毫秒时间戳，用户隔离、状态筛选先于分页。
- BTC 模型 getter 的真实渲染；跨钱包历史详情只读，不进入带交易替换操作的 EVM 详情页。
- 非 EVM 地址存储和读取保持大小写；历史列表及只读摘要保持原始金额精度和资产单位。
- DeFi 失败后重试、超过十项展开、切换钱包丢弃旧响应。
- 个人页交易记录导航；语言选择写入当前 locale；USD 信息不会再误入语言设置。
- 报价确认返回实际展示对象；相同订单 ID 也不能替代对象一致性检查；到达失效时间即拒绝。
- 原始 token 单位按正确精度显示，最低到账向下取整；旧整数报价保留小数滑点；1 wei 和大整数不经 double。
- 授权弹窗展示 token/spender/额度；取消不进入身份验证页面。此项没有模拟真实生物识别成功或广播。
- 1inch v6 输出字段、USDC 6 位精度、缺失 decimals 拒绝；后端不伪造低 price impact。
- AA 浏览器网络选择；永续市场详情单位；320/390/768 顶栏布局。
- 真实应用主题的六张 widget 截图，另含窄屏和大字体报价卡检查。

测试文件见 `test/features/home/profile/`、`test/features/wallet/` 下本次新增文件，以及 `test/features/widgets/app_home_top_bar_test.dart`、`test/screenshots/wallet_audit_screenshot_test.dart`。后端测试位于 `backend/swap/services/inch_test.go` 与 `backend/swap/handlers/quote_test.go`。

## 视觉核验边界

[截图目录](device-test-reports/evidence/2026-09-10-wallet-ui/)包含六张 PNG。截图在 390×844 逻辑尺寸、2 倍像素密度下生成，使用实际 ThemeAdapter 亮暗主题和测试字体。已人工查看个人页、确认页及空记录页，没有观察到文字叠压、缺字方块或底部确认操作溢出。

这些图片使用固定测试数据；本地记录图展示空状态。不能据此证明真实资产数据、摄像头、蓝牙、系统认证、推送或后台恢复已通过。新增本地记录页沿用原始记录网络，并限制为只读摘要；交易替换仍需进入相应钱包的资产页。

## 保留的原有工作区改动

本轮开始前已有 iOS 项目、`evm_sender.dart` 手续费保留、IPA 脚本、版本检查脚本及相关测试/设备报告改动。本次未覆盖或回滚这些内容。没有创建 Git commit；如后续提交，应将本次变更与原有工作区修改分别复核。

## 发布限制

- 覆盖率远低于既有 70% 门槛；全套测试通过不表示 CI coverage gate 通过。全仓格式检查也有 313 个未改动文件的既有差异，CI 格式门槛仍需独立处理。
- 硬件 signer 主钱包接入、Solana DEX、原生币 swap value、AA 报价账户、独立授权撤销中心仍有明确缺口。
- 尚无本轮新代码的 iOS/Android 实机、真实硬件和链上回执证据。
- 新增本地化文本覆盖英文和仓库现有繁体中文资源；其他语言使用既有 fallback，尚非全部语种人工翻译。
- 客户端与 swap 服务的金额契约修改应在同一可控环境联调，再按各自发布流程上线。
