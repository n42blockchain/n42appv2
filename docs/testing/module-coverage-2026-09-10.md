# 分模块补覆盖率：第一批（2026-09-10）

后续进展见[第二批：DEX 执行、Bridge 与 WalletConnect](module-coverage-batch2-2026-09-10.md)。本文保留第一批完成时的历史数据。

本批按“交易历史 → DEX → 核心安全”推进。覆盖率基线来自此前完整测试集的 3,647 个通过用例；保存在 [基线快照](coverage-baseline-2026-09-10.json)。全量对比及每个文件的覆盖行数见 [覆盖率明细](module-coverage-details-2026-09-10.md)。

## 完整验收结果

| 范围 | 本批前 | 本批后 | 当前覆盖行数 |
|---|---:|---:|---:|
| 交易历史（6 文件） | 81.58% | 99.04% | 414 / 418 |
| DEX 全模块（20 文件） | 50.00% | 53.56% | 992 / 1,852 |
| 核心安全（18 文件） | 43.61% | 76.27% | 919 / 1,205 |
| 全项目（含生成代码） | 17.24% | 17.70% | 21,491 / 121,410 |

重点子范围：历史数据层 **100%**、历史页面 **98.50%**、DEX 兑换页 **62.11%**、安全存储 **100%**、签名解码 **98.16%**、敏感内存 **98.11%**、DApp 安全服务 **89.87%**。子范围包含在上表模块中，不另外相加。

- 完整 Flutter 测试：**3,711 项全部通过**，用时 5 分 35 秒，较基线净增 64 项。
- 模块独立运行：history 27 项、dex 87 项、security 186 项全部通过。不同测试集可能执行其他模块的代码，因此独立 security 结果为 75.60%，上表采用最终完整测试集的 76.27%。
- `flutter analyze --no-pub --no-fatal-infos`：**0 error、0 warning**，139 条既有 info，无新增诊断。
- Python 覆盖率统计测试：**4 项通过**。本批 12 个 Dart 文件格式检查通过；`git diff --check` 与 UI 入口清单一致性检查通过。
- 本轮未执行真机、硬件钱包或链上广播验收。

复核日志：`/tmp/n42-coverage-full-tests.log`、`/tmp/n42-coverage-analyze.log`、`/tmp/n42-coverage-module-tests.log`、`/tmp/n42-coverage-security-module-final.log`。这些临时日志不入库，持久证据为本文、基线 JSON 与生成明细。

## 范围与统计口径

- **history**：`wallet/data/transaction_history*.dart` 与 `wallet/pages/transactions/transaction_history*.dart`，共 6 个文件，覆盖本地资产交易历史查询、筛选和导出。
- **dex**：`wallet/pages/dex_swap/`、`wallet/models/dex/` 与 `wallet/api/dex_swap_api.dart`，共 20 个文件。兑换页只是其中一个子范围，不将页面覆盖率当作整个 DEX 的覆盖率。
- **security**：`core/security/` 全部 18 个文件，包括安全存储、签名解码、敏感内存、DApp 风险检查及既有安全服务。

保留生成代码和原 CI 的 70% 门槛。模块结果不相加；模块测试产生的 LCOV 单独存放于 `coverage/modules/`，不覆盖 `coverage/lcov.info`。完整测试结果才能用于报告全项目覆盖率。代码格式和修复会改变部分可执行行数，明细同时记录分子、分母。

## 已补行为验证

### 交易历史

新增 11 个用例，验证：

- 非法分页参数、非法方向、筛选条件保留与清除、未知交易状态。
- BTC 无 outputs 时的历史收款地址回退、bech32 地址匹配、最小单位金额精度、CSV 公式字符防护。
- 方向、状态、日期选择器返回值、日期清除与全部重置都传到数据仓库；刷新失败后仍能重试。
- CSV 导出使用选定账户和筛选快照，文件包含 UTF-8 BOM，分享参数包含 CSV 类型和有效定位区域。
- 导出中禁用筛选；写入失败删除部分文件并恢复操作；离开页面后取消导出；系统分享失败显示错误并解除忙碌状态。

测试使用真实临时文件，通过平台通道模拟路径和分享接口；未调用系统分享应用。Material 日期范围控件在默认 Ahem 测试字体下使用平板宽度测试，其他导出交互使用 390 × 844 视口。

### DEX

新增 13 个兑换页用例，验证：

- 金额变化立刻作废确认中的报价；旧金额响应不能覆盖新报价。
- 滑点变化重新请求报价；同值设置不重复请求；旧滑点响应被丢弃。
- 钱包地址变化使用新地址报价；网络变化清空代币和金额，丢弃旧网络响应。
- 测试网资产、不同链的代币、非法原生币交易 value 均被拒绝。
- 报价服务失败后修改金额可以恢复；离开页面后忽略迟到响应。
- 后端给出不可信 router，或可信 router 的 calldata 指向其他收款人时，在签名前拦截。

这些用例使用可控制完成顺序的报价服务，没有使用真实私钥或广播交易。授权成功、EOA/AA 广播回执、限价单生命周期仍是下一批 DEX 的主要缺口。

### 核心安全

新增 26 个签名解码和敏感内存用例、7 个 DApp 安全用例，并把安全存储原有 3 个占位用例替换为 10 个行为测试：

- 原生币金额从 1 wei 到超出 double 精确范围的大数；有限/无限授权、NFT 授权与撤销、Permit/Permit2/Safe/Seaport 数据、未知方法与异常消息。
- UTF-8 敏感字符串往返、调用者与包装器缓冲区隔离、销毁后擦除、重复销毁、已销毁值禁止访问、不同长度及首尾差异的字节比较。
- Token/UUID 登录条件、Unicode 用户资料、损坏 JSON、多钱包凭证/助记词/私钥隔离、Passkey 设置与凭证、按 DID 隔离的身份令牌。
- 退出登录删除所有用户秘密和安全设置，同时保留设备 ID；完整重置连设备 ID 一起清除。
- HTTPS/HTTP 风险缓存隔离、可信域名边界、钓鱼域名及子域、可疑域名、缓存容量淘汰、敏感 RPC 调用历史的持久化与按来源清理。

安全存储测试调用真实 `SecureStorage` 服务，底层使用插件的内存适配器。100% 服务行覆盖不代表已验证 iOS Keychain、Android 硬件加密或系统权限。

## 测试发现并修复的问题

| 问题 | 复现 | 修复 |
|---|---|---|
| 签名预览的 ETH 金额错误 | 1.5 ETH 显示为 `1.5.500000 ETH`；大额金额丢失精度，1 wei 被截断 | 使用 BigInt 整除和余数，保留全部 18 位精度，只去掉尾随零 |
| 敏感字符串非 ASCII 内容损坏 | 中文及表情的 UTF-16 code units 被直接写入单字节数组 | 编解码统一为 UTF-8，并验证销毁后原缓冲区已擦除 |
| DApp 风险缓存混用协议 | 先访问可信 HTTPS 域名，同域 HTTP 页面沿用“已验证”评级；反向访问也会污染结果 | 缓存键包含协议和域名，两个访问顺序均有回归测试 |

涉及生产代码仅为这三个安全文件。本批新增/替换共 67 个 Dart 行为用例，净增 64 个；另有 4 个 Python 测试验证覆盖率统计没有重复计数、没有排除生成代码，且模块报告不会冒充全量结果。

## 复跑方式

```sh
# 分别运行模块；报告在 coverage/modules/<模块>.md
python3 scripts/module_coverage.py test history
python3 scripts/module_coverage.py test dex
python3 scripts/module_coverage.py test security

# 全量验收，保留原覆盖率门槛
ulimit -n 8192
flutter test --no-pub --coverage --concurrency=2
flutter analyze --no-pub --no-fatal-infos

# 从完整测试的 LCOV 生成全项目及模块对比
python3 scripts/module_coverage.py report \
  --output docs/testing/module-coverage-details-2026-09-10.md

# 验证统计脚本
python3 -m unittest discover -s test/scripts -p 'test_*.py'
```

脚本按源码行去重，模块测试失败时不生成成功报告，并列出基线中存在而当前 trace 缺失的文件。分组定义和测试文件匹配规则在 [module_coverage.py](../../scripts/module_coverage.py) 内，可继续按模块扩充。

## 后续批次

| 顺序 | 模块 | 优先验证的行为 |
|---|---|---|
| 1 | DEX 执行与限价单 | 授权确认后的账户变化、签名取消、EOA/AA 发送失败与回执、限价单创建/撤销/恢复 |
| 2 | 跨链 Bridge | 报价失效、源链余额与费用、授权/发送/目标链状态、恢复历史任务、失败重试 |
| 3 | WalletConnect / Browser | 会话权限、链与账户切换、请求来源隔离、签名拒绝、断连与页面入口 |
| 4 | 剩余核心安全 | GoPlus 网络异常与缓存、TOTP 标准向量、钓鱼警告交互、设备安全平台异常 |
| 5 | 质押 / Earn / 硬件钱包 | 产品加载与交易状态、硬件签名取消/断连、设备授权与地址校验 |

当前尚未达到全项目 70%。后续按完整台账推进，避免用少数高覆盖文件代表整个钱包模块。
