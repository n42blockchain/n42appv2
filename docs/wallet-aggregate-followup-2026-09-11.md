# 聚合稳定币详情与覆盖率补齐（2026-09-11）

接续[前序遗漏复核](wallet-gap-audit-2026-09-11.md)，本批补齐聚合稳定币详情入口、分网络余额与刷新，并修复查询失败被当作零余额的问题。范围是项目预配置的 USDT／USDC；不代表所有同名代币、跨链桥或支付路径均已支持。

## 产品与入口

| 入口／操作 | 当前行为 |
|---|---|
| 首页聚合 USDT／USDC 行 | 点击进入实际分网络详情，替换原 coming-soon 提示 |
| 首页已有普通 USDT／USDC | 原资产详情新增“各网络余额”入口；按链、合约和精度识别预配置资产，不按名称识别 |
| 分网络详情 | 展示已知余额合计、网络余额、合约和收款地址；区分加载中、查询失败、缓存余额与未启用账户 |
| 收款／网络入口 | 打开现有代币收款二维码页和对应网络资产页；收款描述不复制私钥 |
| 刷新 | 详情按钮、下拉刷新及首页刷新接入聚合查询；相同在途请求合并；按钮加载时禁止重复点击 |
| 首次查询失败 | 首页和详情用“—”表达未知；真实查询成功返回零才显示零；有缓存时保留并标注刷新失败 |
| 切换账户或网络 | 丢弃过期请求结果，立即隐藏与当前地址不符的余额；测试网、自定义链和不匹配的 EVM chainId 不参与主网聚合 |

已有普通稳定币会抑制同名聚合首页行，因此仅修复聚合行的点击仍会让真实设备缺少入口。本批为普通稳定币补第二条入口，详情使用独立余额视图，不向首页资产列表再插一份，也不重复计入钱包总资产。

界面提供英文／繁体中文，窄屏 320 宽与两倍文字测试覆盖未知、缓存、操作按钮及滚动。原首页紧凑行高和简短行情提示保留。

## 余额读取与精度

- EVM 使用只读 `eth_call` 查询 `balanceOf`，校验账户／合约格式和响应；HTTP、RPC 和数据错误不再折算成零。
- SPL 根据 mint 查询持有者的全部代币账户，校验 owner、mint、精度和重复账户后汇总整数 amount，修复原先只取首个账户的问题。返回有效空列表才视为零。接口的账户列表及过滤语义见 [Solana 官方 RPC 文档](https://solana.com/docs/rpc/http/gettokenaccountsbyowner)。
- TRC20 使用 `wallet/triggerconstantcontract`，校验 Base58Check 地址；ABI 参数去掉 `41` 网络前缀后，把 20 字节地址补齐为 32 字节。读取调用无需签名或广播，编码依据 [TRON 官方文档](https://developers.tron.network/docs/smart-contract-interaction)。修复限定于本次聚合读取器，不表示项目其他 TRON 调用方已全部迁移。
- 混合精度余额先用 BigInt 对齐并求和，代币数量显示不经 double；保留 18 位代币的小数和大整数。美元估值沿用现有浮点展示。
- 每次 HTTP 请求 10 秒超时并关闭 client，模型单链等待上限 15 秒；成功、失败和缓存状态按链独立更新。

## 验证与覆盖率

独立 `wallet_aggregate` 模块 **84 项通过，597/702 行（85.04%）**，覆盖 7 个源码文件。读取器和新增 provider 扩展各为 100% 行覆盖，详情页为 91.78%。这仅表示这些测试执行到的源码行，不表示所有网络接口在线，也不能代替全项目覆盖率。[模块明细](testing/module-coverage-aggregate-2026-09-11.md)。

```sh
python3 scripts/module_coverage.py test wallet_aggregate \
  --baseline docs/testing/coverage-after-gap-audit-2026-09-11.json
flutter test --no-pub --coverage --concurrency=2 --reporter expanded
flutter analyze --no-fatal-infos
```

覆盖重点包括：混合精度、有效零与失败、缓存重试、相同请求合并、超时、切换账户后的晚响应、主网资格、同名伪代币排除、独立详情不重复估值、复制地址、真实收款路由、来源资产移除、普通币种入口及首页未知余额。

最终全量套件 **4,013 项全部通过，7 分 14 秒**，比前一批新增 42 项。完整 LCOV 为 **24,795/122,163 行（20.30%）**，前值 19.82%，增加 0.48 个百分点，仍未达到 70%。全量套件内的聚合范围为 603/702（85.90%），与独立模块的 85.04% 分开记录。[全量明细](testing/coverage-aggregate-full-2026-09-11.md)。

`flutter analyze --no-fatal-infos` 返回成功：0 error、0 warning、160 info，其中仍含新增文件的大括号风格提示。11 个本批 Dart 文件的格式检查无改动；Python 脚本测试 8 项通过。入口清单已重新生成并通过 `--check`，新页有首页聚合行与普通资产详情两处生产引用；静态引用另有实际路由测试验证。

小米导航 **98 秒通过**，iPhone 13 Pro Max 导航 **85 秒通过**，计时均不包含构建，并包含用于截图的 12 秒暂停。两台设备都有普通 USDC，因此实际验收路径是：首页普通 USDC → 资产详情 → 各网络余额 → ETH 收款二维码 → 返回 → ETH 网络资产页 → 返回首页。聚合首页行的直接入口由 widget 测试覆盖。两端均同时通过已有首页紧凑行、手动刷新、部分行情文案和安全侧栏导航；本次排除需要另行登录的 Chat。

真机截图确认 ETH／BNB 的有效零余额能正常显示，iPhone 的 MATIC 查询失败显示“—”及失败文案，顶部标注“已知余额”。这证明部分可用时的呈现，不代表全部预配置 RPC 可用。两端行情仍为部分报价，不宣称行情完整。

[小米分网络详情](device-test-reports/evidence/2026-09-11-aggregate/android-detail.png) · [iPhone 分网络详情](device-test-reports/evidence/2026-09-11-aggregate/ios-detail.png)。截图为集成测试 Debug 模式；小米保留原系统指针叠层。

物理测试均使用 `--no-uninstall`，沿用本机既有的私有鉴权配置；没有卸载或重置用户钱包。仅归档固定检查标记与结果，原始日志不进入仓库。最终源码范围以 [SHA-256 清单](device-test-reports/evidence/2026-09-11-aggregate/source-sha256.json)记录。

两台手机最后均覆盖安装并启动 **2.4.8+2026072637 / Profile / lib/main.dart** 普通入口，没有遗留集成测试入口。最终首页截图已复核：紧凑币种列表、部分行情提示、收发与底部导航正常。小米保留原系统指针叠层和备份提醒。完整结果见[结构化验收记录](device-test-reports/evidence/2026-09-11-aggregate/validation.json)。

[小米普通版首页](device-test-reports/evidence/2026-09-11-aggregate/android-after.png) · [iPhone 普通版首页](device-test-reports/evidence/2026-09-11-aggregate/ios-after.png)。

## 验收边界与后续缺口

本批不广播主网交易。分网络收款与查看入口已接通，但未新增自动跨链归集、合并支付或聚合发送选择。主网付款仍按用户要求留待线下真人操作。当前范围也不包含测试网付款闭环。

硬件钱包生产 signer、独立 ERC-20／NFT／Permit2 授权撤销中心、部分深链分支、链上预测及 Sui App 付款仍按[前序缺口台账](wallet-gap-audit-2026-09-11.md)跟进。聚合读取修复不表示这些模块完成；CI 的 70% 门槛保持不变。
