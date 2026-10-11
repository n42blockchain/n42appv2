# N42 钱包周报评估、执行与验收

日期：2026-10-10。范围：当前 n42appv2 Flutter 宿主及其锁定的 Chat 依赖。

## 取舍

优先采用信任边界披露、交易可靠性和现有入金/会话审查。Agent 自动支付、MoonPay Headless 和原生 Swift/Kotlin SDK 暂不直接引入：当前代码不足以证明链上策略闭环、供应商合同及原生宿主需求。EIP-7906 仍是 Draft，不能宣传为现有链的执行保证。

已核对官方来源：[EIP-7906](https://eips.ethereum.org/EIPS/eip-7906)、[MetaMask Agent 指南](https://metamask.io/news/metamask-agent-wallet-quickstart)、[Trust Wallet MoonPay 公告](https://trustwallet.com/blog/product/trust-wallet-integrates-moon-pay-headless-to-make-buying-crypto-simpler)。供应商案例提供方向，不能代替 N42 验收。

## P0：信任边界（第一阶段，仓库评估已执行）

负责角色：钱包研发维护清单，安全负责人确认恢复证据，发布负责人核对商店身份。跨设备恢复和身份反链完成后才关闭此项。

| 模式 | 当前证据 | 恢复、退出和撤销边界 | 验收状态 |
|---|---|---|---|
| 本地助记词/私钥 | `lib/core/security/secure_storage.dart`、wallet backup 页面及 payload 测试；EvmSender 经 Trustdart 签名 | 有本地备份代码；必须在另一设备导入并逐链比对地址，再离线恢复签名。App 删除、设备损坏、系统云备份须单独测试 | 本地回归见 RESULT；跨设备恢复未验 |
| Passkey / AA | `lib/core/passkey/`、`lib/features/wallet/aa/`、social recovery calldata 构造 | Passkey 不等同于可导出私钥；退出取决于具体已部署账户、owner/guardian 和 bundler/RPC 替代路径 | 有实现，未证明已部署账户的恢复/退出 |
| Session key / 未来 Agent | `session_key_repository.dart` 的撤销仅更新 SQLite；管理页调用本地仓库 | 本地 revoked 不能证明链上撤销。Agent 不得读取主钱包助记词；必须独立小额钱包、链上白名单/额度/到期、receipt 确认撤销 | 禁止据模型测试宣称策略已生效；Agent 未接入 |
| MPC / TEE / OEM | 本次未建立可用生产路径证据 | 若引入，先说明持钥方、导出格式、服务停止恢复、账户冻结和退出条件 | 不作为当前已支持模式宣传 |
| MoonPay 入金 | 当前 Chat git pin `a3da656f92889ec2f6b1bc3de24694d66dffcb4f`，实际 package_config 指向 pub cache；FiatRampService 构建 URL，FiatRampPage 用 WebView 打开 | 第三方支付/KYC 与链上资产控制分开；可发布 key 由宿主注入。旧 `features/pay/moonpay` 文档不代表现有路径 | 已确认是 widget WebView，未集成 Headless；实际订单未验 |

官方身份：本次读取的 [App Store 页面](https://apps.apple.com/us/app/n42-wallet/id6738644072) 显示发布者 SI46WORLD DIGITAL TECHNOLOGY INC.，开发者网站/隐私链接指向 si46.world，版权为 Tronizon Technology Inc.，描述提及 n42.ai。页面版本为 1.0.16；与本地开发版本不能等同。网页抓取可能有缓存。n42.ai 本次正文未解析，官网双向链接与 Google Play 发布身份仍未验。需发布负责人核对主体关系，在官网列出 app ID、Android package ID、商店链接及法律主体，并从商店反链。

建议商店安全文案："助记词/私钥钱包由用户保管备份。丢失备份可能无法恢复资产。智能账户的恢复方式取决于已启用的恢复配置。法币购买由第三方提供，受地区、KYC、费用和服务可用性限制。" 删除无法解释算法与密钥用途的“384-bit”安全承诺；不以此宣称抗量子。本次没有发布外部文案。

## P0：交易质量门（第二阶段，已执行修复和本地门）

负责角色：钱包研发修复请求状态与幂等问题，QA 用测试链和设备执行故障矩阵。先补齐端到端失败语料，再作发布门；本地门现在可执行。

已修复：EvmSender 缺少主网 chain ID 时曾默认 1；现在两种网络都先拒绝缺失/无效 ID，且不再把小数 ID 截断。新增通过 sender 入口的回归测试，验证失败发生在 RPC/签名前。

执行 `FLUTTER_BIN=/path/to/compatible/flutter scripts/verify_wallet_reliability.sh`。使用 Dart >=3.13 的项目兼容 Flutter，先有有效依赖解析。本地门包含精确金额、gas 预留、nonce 串行化、WalletConnect 请求/会话/回连、receipt 轮询、重试、备份和 secure storage。结果记录实际退出码；模型测试不代表端到端能力。

后续必须补齐的端到端语料：

| 场景 | 操作 | 通过条件 |
|---|---|---|
| gas 竞态 | 确认页等待估算时刷新 fee、切链/切账户、延迟返回旧响应 | 最新确认内容与签名一致；旧响应不能覆盖新意图 |
| RPC 切换 | 主 RPC 超时/返回其他 chain ID，换备用 RPC | 不向错误链广播；未知广播结果先查原 hash，不自动重建付款 |
| 模拟过期 | 模拟后更改 allowance/余额/合约状态 | 显示模拟局限；重新预检或拒绝；不得承诺必成功 |
| 双击/重试 | 同一付款意图重复提交，广播成功但响应丢失 | 至多一次付款；串行队列不是幂等，不能据此验收为 0 重复 |
| 后台恢复 | 签名前/广播后进入后台并杀进程再启动 | 持久化意图/hash；恢复 receipt 查询，不重新付款 |
| receipt 重组/事件漏报 | 先收到 receipt 后撤销区块、暂停索引事件 | pending/confirmed 状态随规范链校正；以 receipt/余额交叉核对 |

每个场景记录 chain ID、脱敏意图 ID、各阶段时间、hash、receipt 区块与余额变化。测试集错误链/收款方/金额/重复付款为 0 才通过。fixture hash/假签名不能作真实链证据。设备 P95：同设备、同构建模式、同网络，每组至少 100 次，从确认页导航开始到可确认并显示完整交易信息；先采当前基线，再测变更，P95 <= 基线×1.10。当前没有设备基线，不作延迟验收声明。

## P1：真实入金与跨端会话（第三阶段，待外部条件）

负责角色：支付/商务提供 sandbox 和 Headless 接入条件，Chat 源仓库维护者实现订单闭环，产品/QA 组织对照用户。先完成 sandbox 与当前基线，再开始连续两周试点。

入金先在供应商 sandbox 验证缺 key、拒付、用户退出、重复支付、回跳丢失、费用变化、目标地址和订单回查。为每个订单持久化唯一引用，完成态由供应商订单状态和目标链到账共同确认。当前 WebView 不具有已证明的订单闭环；修改应在 n42_chat 的源仓库完成并更新 git pin，不能编辑 cache mirror。

真实用户对照分两步：先收集当前 widget 基线，再获得 Headless 接入许可后试点。按地区、OS、是否首次 KYC 分组，每组至少 30 个符合条件的用户；统计首笔到账/开始入金、KYC 放弃/KYC 开始、开始到到账的中位数/P95、费用完整可见/全部报价、失败可恢复/可恢复失败。用户主动退出单列；禁止无订单状态直接提示重新付款。完成率改善至少 10 个百分点，费用可见率 100%，无重复扣款/错误地址，且连续两周方向一致才评估扩大；小样本只用于探索，不宣称统计显著。

连接矩阵：iOS 回切、Android 回切、移动浏览器深链、桌面二维码分别覆盖首次连接、App 后台、网络切换、relay 中断、过期 QR、用户拒绝、会话过期、切账户/切链。每格至少 30 次；连接成功/有效发起，回连成功/仍有效会话回连，另记 P95、失败原因和重试次数。无静默错链/错账户为硬门；首次成功率目标 >=95%，回连 >=95%。Swift/Kotlin 宿主若不属于当前交付范围，记录 N/A 并附产品范围依据，不能用 Flutter 单元测试替代。

Agent 实验仅在独立测试钱包上开展：提示注入、跨白名单、滚动24h额度边界、二次确认丢失、服务中断、密钥退出六类。缺批准或数据时默认拒绝；到期/撤销后链上执行必须失败。未完成退出和链上策略验收前不启用真实资金自动支付。

## 交付与未完成项

本阶段交付：适用性评估、信任边界清单、chain ID 修复、可重跑本地门和验收记录。完整产品验收仍需设备、测试链故障注入、商店管理权限、供应商 sandbox/合同与真实用户。以上缺口保持未通过；不据单元测试宣称全部质量门完成。

## 后续执行进展（2026-10-10）

发送页异步确认与gas在途阻断、详情旧响应隔离、receipt异常处理与持续重组观察已实施。受控Widget场景验收见 [后续记录](followup/RESULT.md)。进程恢复/广播幂等、真实链与余额一致性、设备P95、供应商订单及用户试点继续保持未验状态。

## 本次范围关闭（2026-10-10）

用户要求完结后，明确指示跳过外部验收配置步骤。本地新增广播前持久化hash、当前确认防重入、未知响应保留原hash、SQLite重开查询恢复、直连RPC链校验、固定金额不隐式扣减，以及Session Key本地状态披露。当前交付范围与跳过项见 [完结记录](completion/ACCEPTANCE.md)，最终自动化结果见同目录summary.json。前两轮记录保留为历史证据，不代表最终累计计数。
