# 数字钱包产品研究与 N42 功能审计

后续进展见[第二轮实现与验证记录](wallet-followup-implementation-2026-09-10.md)：本地历史完整导出、DEX 原生 value 与 AA 账户流程已继续修复；本文保留首轮审计时点的发现。

## 结论与交付范围

N42 的主要短板是现有能力的闭环质量：入口名称与目的页不一致、报价确认与实际提交之间存在状态竞争、部分财务数据使用错误的单位，以及高级模块只有独立实现而没有接入主钱包。增加页面数量不能解决这些问题。近期产品重点应是让每一个可见操作具有明确的账户、网络、授权范围、金额、等待状态和结果。

本次交付包含代码修复、公开页面构造引用清单、竞品功能基准、剩余缺口和验收条件。全模块源码盘点与关键资金路径审计已执行，**这不等同于全部链、全部设备、全部外部服务均完成端到端验收**。没有真实硬件签名记录、链上交易回执或服务可用性证据的项目继续标记为待验证。

最终全量自动化测试有 **3,632 项通过**，包含本次新增的 29 项回归/视觉测试。当前 LCOV 行覆盖率为 **16.42%（19,891 / 121,149）**，明显低于仓库 CI 的 70% 门槛。测试通过不能被解释为覆盖率达标或安全审计通过。详细命令和最终静态分析结果见配套[验证记录](wallet-audit-validation-2026-09-10.md)。

源码范围包含主应用 `lib/` 中的钱包、设置、浏览器、WalletConnect、AA、跨链、质押、硬件钱包、身份、收益、空投、积分、挖矿、直播与共享基础设施，并抽查原生签名和 swap 后端。页面级引用证据见[完整入口清单](wallet-feature-wiring-inventory-2026-09-10.md)。聊天是独立 git 依赖；当前开发环境解析到本地缓存镜像，主仓审计不能替代聊天仓库及其发布版本的独立验收。

## 行业产品基准

### 竞争重点

主流钱包的价值正在从“能够签名”转向“用户能理解并可靠完成交易”。比较产品时应以具体操作作为最小单位，例如“USDC 精确授权后兑换”“硬件钱包拒绝签名后返回表单”“跨链源链成功但目标链超时后的恢复”，而不是把一个菜单名称当成一个已完成的功能。

MetaMask 的模拟界面显示预期资产变化，其文档也明确区分普通链下模拟与特定智能账户场景的链上强制验证。普通模拟不构成实际执行一致性的保证。N42 应展示模拟来源、结果可用性及未识别合约的状态，不能将未知显示为低风险。[^1]

Rabby 的官方开源项目聚焦 EVM、多链交互和交易前安全检查。值得借鉴的是账户与链上下文以及签名前的信息组织；官网推荐语或支持链数量不能代替每条链读写功能的验收。[^2]

Phantom 把兑换入口、滑点和优先费设置组织在同一操作流程中；其安全指引特别提示核对完整地址、警惕垃圾空投和避免直接从交易历史复制收款地址。N42 的交易历史必须保留原始地址大小写，安全界面应可展开完整地址。[^3][^4]

MetaMask 明确将断开 DApp 连接与撤销链上授权区分开来。关闭会话不会自动取消合约的代币支出权限；撤销授权是需要链上确认和手续费的操作。N42 目前有会话管理和单次 approve，但缺乏独立的授权盘点及撤销闭环。[^5]

Ledger 的 Clear Signing 文档强调在可信设备屏幕上展示可理解的交易内容。软件弹窗展示金额，并不等于硬件实际签署的原始交易具有相同含义。N42 的 Ledger/Trezor/Keystone 适配层还需要与主钱包账户和签名流程统一。[^6]

### 竞品—功能细节—本项目映射

| 产品或协议 | 有来源支持的功能细节 | N42 的代码现状 | 应采用的产品要求 |
|---|---|---|---|
| MetaMask | 交易模拟、资产变化预览；增强验证具有账户与网络条件[^1] | 风险解析与模拟结果组件存在 | 来源/错误/未知分开；确认内容与签名内容绑定 |
| MetaMask | 连接管理与链上授权撤销是不同动作[^5] | WalletConnect 会话页存在；没有独立授权撤销页 | 安全区分别展示会话与授权；撤销必须跟踪链上结果 |
| MetaMask | Gas included / sponsorship 有适用交易和网络条件[^7] | AA、Paymaster 与 gas-free 开关存在 | 显示付款账户、收费资产、额度及失败回退；不承诺全链免费 |
| Phantom | Swap 可调滑点、优先费，跨网络流程有独立路由[^3] | DEX 与 bridge 分离；SOL 报价适配存在 | 逐链区分报价支持与实际签名/广播支持 |
| Phantom | 安全指引包含完整地址检查与垃圾空投防护[^4] | 地址标签、NFT 垃圾过滤存在 | 保留完整可复制地址；过滤可解释、可撤销 |
| Rabby | EVM 账户、多链交互及安全检查的开源实现[^2] | EVM 链配置、网络页、交易分析组件存在 | 验收以具体账户/网络/操作矩阵计数，不以配置数量计数 |
| OKX Wallet | 跨链路由比较强调成本、时间与到账过程[^8] | bridge provider 有报价、approval、轮询与交易列表 | 源链和目标链状态分开；超时可恢复、可查看浏览器 |
| Trust Wallet | watch-only 仅允许观察，不能通过充值解锁支出[^9] | 观察钱包导入、主发送页保护存在 | 钱包类型贯穿所有签名入口；导出/备份文案区分类型 |
| Safe | 智能账户由 owner、阈值及可扩展模块组成[^10] | 多种 AA 账户类型、会话密钥、恢复相关代码存在 | 将账户创建、部署、授权生效、撤销和恢复逐项验收 |
| Ledger | Clear Signing 强调可信设备上的可读交易内容[^6] | 设备管理和签名适配存在；主钱包分派未闭环 | 签名主体、派生路径和设备指纹必须一致 |
| 1inch | v6 的输出字段为 `dstAmount`，代币字段为 `dstToken`[^11] | 后端曾解析 `toAmount`，且默认输出 18 位精度 | 用版本化 DTO；原始整数作为金额交换标准 |
| Hyperliquid | info 接口提供市场、账户和持仓数据[^12] | 原生页面提供只读行情/持仓/订单 | 行情详情可查看；下单和撤单应明确保持未支持 |

上述事实核对以 2026-09-10 获取的官方页面为准。没有明确发布日期的页面按当日内容使用；不据此推断某个历史版本已经具备该功能。1inch 的迁移说明用于核实 v6 字段契约，不代表已验证线上 API key、配额或服务开通情况。

### 功能完整性的六个层次

一个功能应分别登记：业务模型、服务实现、页面组件、用户入口、可恢复操作状态、真实结果。只有同时具备这些条件，才应对外称为“支持”。例如硬件账户导入本地列表满足部分数据与页面层要求，但在主钱包选择账户后无法调用相应设备签名，就不能等同于硬件钱包收发闭环。

同样，聚合器返回了报价不等于客户端能够执行。Solana 的序列化交易不是 EVM calldata；ERC-20 的授权额度不是原生币 `value`；AA 智能账户与其 owner EOA 也不是同一个资金来源。产品界面必须反映这些差别，底层发送参数则必须强制约束它们。

## 核心操作体验设计

### 创建、导入与恢复

入口至少应区分助记词钱包、私钥钱包、观察钱包、硬件钱包、MPC 与智能账户。每类账户需要说明可恢复凭据及可执行操作。观察钱包应始终显示观察标记；硬件账户应展示设备与派生路径；MPC 应解释登录方式和恢复依赖，不能简单称为“无风险免备份”。

恢复验收应使用新安装环境：导出备份、删除应用数据、恢复账户、核对地址、核对网络、再进行测试网签名。仅验证 JSON 可解析或助记词格式正确不足以证明恢复可用。备份失败、错误密码、取消生物识别、系统权限拒绝，都应能够返回上一步且不丢失已输入的非敏感内容。

### 收款、扫码与发送

收款页应突出网络与资产，二维码携带的网络、合约和金额必须在发送端重新确认。相同 EVM 地址可以出现在多个网络，地址格式正确不能证明网络正确。带 memo、destination tag 或最小余额要求的链，需要在确认页显示对应规则。

发送表单应校验精度、余额、手续费保留额和原生币费用余额。MAX 应使用最小单位整数运算，确认页与最终签名使用同一套数值。广播成功只表示节点接受，随后仍需要 pending、confirmed、failed、replaced 的结果跟踪。

本次新增的账户级本地交易页采用两个本地账本合并后分页，避免先分页后筛选导致旧记录不可达。记录显示网络类型，打开只读交易摘要及对应网络浏览器。跨钱包本地记录没有 signer 与派生路径，不能借用当前钱包加速或取消另一钱包的交易；需要这些操作时应切换到所属钱包的资产详情。页面说明它是本地记录；不假装掌握所有链的完整历史。

### DEX 与跨链

报价应由账户、链、输入资产、输出资产、输入金额、滑点共同标识。任一字段变化，都应立即使旧报价失效。后台返回较旧请求时不得覆盖新表单；确认页显示的报价与实际执行对象必须相同。报价过期采用实际时间判断，不能只依赖可能在后台暂停的倒计时。

授权应展示 token 合约、spender、网络和额度。默认精确额度，无限授权作为主动选项。用户取消授权确认或身份验证时，不得继续调用 sender。approval 广播后应重新检查 allowance，不能仅收到 hash 就显示完全可交易。

跨链应分别显示源链执行、桥接中、目标链到账和失败恢复。余额、最低到账量、费用与超时应来自可解释的数据来源。固定 gas 文字可作为粗略说明，不能代替发送前的 RPC 估算；缺失价格影响时显示未知，不输出未经计算的低风险结论。

### 安全、授权与硬件

安全中心应有可独立使用的三个入口：账户认证设置、已连接应用、链上代币授权。当前新增个人页 WalletConnect 入口及区别说明，降低把“断开”误认为“撤销”的风险。完整授权撤销功能仍需索引服务、ERC-20/ERC-721/ERC-1155/Permit2 区分和撤销结果跟踪。

硬件签名不应作为主钱包无法签名时的无提示备用路径。每次交易明确选择账户类型；设备不连接、用户拒绝、QR 分片不足或签名地址不符时返回可恢复状态。设备签名与软件签名共享交易摘要和签名后校验，但不能自动切换签名主体。

### 响应速度与界面一致性

高频列表应分页或惰性构建。查询应允许最新请求覆盖旧请求，重试时区分“数据不存在”和“数据服务不可用”。表单 debounce 只能延后新查询，不能延后旧数据失效。

窄屏、大字体、长钱包名称和长合约地址是常态。固定高度确认页应改为可滚动内容与固定底部操作区；顶栏应给标题明确的可用宽度；详情字段允许换行。深色主题必须使用实际主题验证，不能仅凭颜色常量判断可读性。

## 全功能审计矩阵

“有入口”仅表示已找到构造或导航路径。“待端到端”表示本次没有该功能的真实设备和真实服务闭环证据。所有公开页面及调用文件见[入口索引](wallet-feature-wiring-inventory-2026-09-10.md)。

| 功能域 | 当前入口与实现 | 审计结论及验收缺口 |
|---|---|---|
| 启动与登录 | splash、auth、`main.dart` 初始化 | 有入口；冷启动、注销重登和离线恢复需设备验证 |
| 助记词创建/导入 | `create_wallet/`、钱包列表 | 有页面与流程；新安装恢复及原生密钥操作待端到端 |
| 私钥/Keystore | `wallet_manage/keystore/` | 有入口及辅助测试；逐链格式和错误密码需设备验证 |
| 加密备份 | `wallet_backup/` | 有流程；个人页文案改为加密备份，避免误称只备份助记词 |
| 观察钱包 | `add_watch_wallet_page.dart` | 有入口与保护测试；仍需逐一核验高级签名入口 |
| MPC/社交登录 | `create_mpc_wallet.dart`、core 社交认证 | 依赖第三方配置；未证明新环境恢复闭环 |
| 钱包切换/资产列表 | `wallet_page.dart`、wallet list | 有入口；长标题与顶栏按钮重叠已修复 |
| 网络与自定义 RPC | `manage_chains_page.dart`、add_token | 有入口；读、写、测试网支持必须分别登记 |
| 资产发现/自定义代币 | token discovery、add_token | 有入口；依赖代币数据源，错误与空结果需逐服务检查 |
| 收款二维码 | `wallet_receive_qr.dart` | 有入口；支付请求含金额与合约的实际扫码需设备验证 |
| 多链发送 | `send/`、sender factory | 有入口及较多单测；不是全部链上场景已验证 |
| BTC 本地交易 | history list、BTC model | 已修复废弃动态字段导致的运行错误 |
| 非 EVM 地址历史 | `TransationRecordModel` | 已停止对 from/to 强制小写；旧的损坏记录仍须重新同步 |
| 全部本地交易 | 新增 `wallet_activity_page.dart` | 已从个人页直达，用户隔离、状态筛选、合并分页可测；摘要为只读 |
| 单币筛选/CSV 导出 | `transaction_history_list*` | 有入口；筛选和导出仍受已加载分页影响，见剩余问题 |
| pending 加速/取消 | EVM transaction detail | 有实现与相关测试；账户、nonce 和双费用上限须设备验收 |
| 地址簿/ENS 收款解析 | address book、ENS widgets | 有入口；大小写、同名跨链及失败提示需持续验证 |
| ENS 生命周期 | ENS 搜索、注册、续期、管理、子域名 | 有入口；子域名静态 show 是扫描误报，注册依赖链上状态 |
| 资产组合/DeFi | portfolio、DeFi positions | 有入口；已修复错误吞掉、查看更多空操作与旧账户响应污染 |
| Gas 与提醒 | gas tracker | 已增加个人页直达；通知权限与后台提醒待设备验证 |
| 批量转账/CSV | batch_transfer | 已增加个人页直达；多币种余额/手续费与部分失败需端到端 |
| NFT 列表/详情/批量发送 | nft pages | 有入口与工具测试；垃圾过滤、ERC-1155 数量需真实样本 |
| DEX EVM | `dex_swap_home.dart` 与后端 | 已修复确认报价漂移、金额精度、默认授权和授权认证 |
| DEX Solana | Jupiter adapter、遗留 SOL 分支 | 报价与执行链路不匹配，不能视为完成支持 |
| DEX 原生币 value | sender 与 AA ExecuteCall | 当前路径 value 为零；不能据选择列表宣称原生币兑换可用 |
| 限价单 | limit order UI、后台 monitor | 有入口与服务；执行授权、到期、取消和通知须完整验证 |
| AST/N42 兑换 | ast_swap | 有入口；与 DEX 是不同服务契约，需单独验收 |
| 跨链桥 | bridge 页面/provider | 有报价、授权、轮询测试；真实桥服务与到账待端到端 |
| 稳定币收益/借贷 | Earn → StablecoinEarn → Lending/Aave | 有导航闭环；多链 allowance、赎回、健康因子待设备验证 |
| 质押 | staking pages/provider | 部分链有实现；DOT 明确未支持且入口隐藏，不能计为完成 |
| 永续合约 | Earn → Perps | 只读；本次补市场详情、修正 OI 单位，不包含下单/撤单 |
| AA 创建/部署/发送 | AA home、account detail、AA sender | 有入口；历史从假空列表改为账户所属网络浏览器入口 |
| AA 批量/Paymaster | aa batch、paymaster page | 有页面；gas-free 扣款账户与 quote recipient 需专项验收 |
| Session Key/恢复 | session key pages、recovery service | 有 UI/服务；需证明链上生效、限制执行和撤销，不只本地持久化 |
| 硬件账户管理 | hardware_wallet pages/provider | 有扫描/配对/账户列表；独立导入未接主钱包 signer |
| Keystone QR 签名 | `keystone_sign_page.dart` | 页面存在，生产调用缺失；需要真实 QR 往返与签名校验 |
| DApp 浏览器 | browser pages、request handler | 有入口与安全测试；WebView 权限、弹窗和生命周期需设备验证 |
| WalletConnect | 顶栏、个人页、扫码、深链 | 有会话入口；断开不等于撤销授权 |
| 链上授权中心 | 未找到独立页面及完整撤销入口 | 缺失；应作为下一个安全功能交付 |
| 消息签名/身份 | message_sign、ID Hub | 有页面/深链；服务端挑战、域隔离、过期和重放需验收 |
| AI 钱包助手 | 钱包顶栏 → wallet assistant | 有入口；只读/建议范围，不应宣传为自动资金代理 |
| 行情/新闻/提醒 | market pages、news | 有入口；价格/新闻来源、离线状态、推送权限需验收 |
| 挖矿 V1/V2 | 主导航与独立挖矿页 | 有入口；邀请/节点深链分支仍仅记录日志 |
| 积分/空投 | 侧栏与 Earn | 有页面/服务与测试；依赖奖励后端和签名挑战 |
| 聊天/直播 | 主导航、chat 初始化、main_live | 有主仓集成；聊天独立仓、登录与媒体权限需分别验证 |
| 直播预测 | Matrix 仓库与链上配置分派 | 默认虚拟积分；链上仓库仍抛 UnimplementedError |
| 设置/主题/版本 | 个人页、设置页、About | 修复语言不生效、货币误跳、假版本号和返回入口 |
| 原生平台/构建 | iOS/Android 等平台目录 | 本次未重新签名构建全部平台；CI SDK 已对齐 pubspec |

## 入口扫描候选的人工复核

自动索引出现 11 个“无外部构造调用”的候选。人工复核后，不能将它们全部视为缺失功能：

| 候选 | 复核证据 | 结论 |
|---|---|---|
| `KeystoneSignPage` | 只有构造声明与注释示例；`needsKeystoneQr` 由 provider 返回而无页面调用方消费 | 真实签名接入缺口，见 R01 |
| `EnsCreateSubdomainSheet` | `ens_management_page.dart` 调用静态 `.show()` | 有入口；构造扫描未识别静态入口 |
| `WalletConnectSheet` | `browser_page.dart:120`、`browser_page_widgets.dart:252` 调用 `.show()` | 浏览器已有连接入口，非漏接 |
| `BatchButtonContent` | `batch_transfer_bottom_bar.dart:113` 同文件构造 | 内部组成部分，不需要独立菜单 |
| `BatchTransferListItem` / `BatchStatusBadge` | `batch_transfer_list_widgets.dart:39,186` 同文件构造 | 列表行与状态组件已有使用 |
| `CoinPercentageBadge` | `wallet_coin_item.dart:290` 同文件构造 | 资产列表内部徽标 |
| `WalletSkeletonCoinRow` | `wallet_page_helpers.dart:115` 同文件构造 | 加载状态内部组件 |
| `WalletPageRiverpod` | 没有生产构造；主导航使用 `WalletPage()` | 未启用的替代实现；不能重复增加钱包主入口 |
| `MiningPlans` | 没有生产构造；`select_plan.dart` 使用 `SelectMiningPlans()` | 存量替代页面，计划选择功能已有实际路径 |
| `ShowImage` | 无生产构造 | 通用备用组件，不能单凭类存在推断需要独立产品入口 |

其他页面存在引用也只证明静态调用关系；配置隐藏、深链参数、权限拒绝、空数据和真实服务失败仍需按完整操作流程验证。

## 已修复问题与实现证据

| 编号 | 优先级 | 触发场景与原问题 | 修改后的行为 | 主要证据 |
|---|---|---|---|---|
| F01 | P0 | DEX 确认页停留时后台刷新，回调读取新报价 | 回调携带实际展示对象，发送前验证相同对象和有效期 | `dex_swap_action_buttons.dart`、`dex_quote_validity.dart` |
| F02 | P0 | 清空金额、换币或换链后旧异步报价仍可能生效 | 立即清空并递增请求代次；旧响应不覆盖 | `dex_swap_home.dart` |
| F03 | P0 | 1inch v6 解析旧 `toAmount`，USDC 按 18 位显示 | 使用 `dstAmount` / `dstToken.decimals`，原始整数贯穿 DTO | 后端 `inch.go`、`models.go`、quote precision tests |
| F04 | P1 | backend 把所有 price impact 固定写成 `<1%` | 删除虚构值，保留来源数据或显示未知 | 后端 `handlers/quote.go`、quote handler tests |
| F05 | P1 | 默认无限授权，approve 直接进入 sender | 默认精确额度；合约/网络/额度确认后进入既有身份验证 | `dex_approval_confirmation.dart`、approval widget test |
| F06 | P1 | 100 个代币在 0.5% 滑点下最低到账被算成 99 | 精确计算为 99.5；原始单位路径向下取整到代币最小单位 | `dex_quote_model.dart`、precision tests |
| F07 | P1 | BTC 历史读取不存在的 `InputsAddress` 等字段 | 使用真实模型 getter，不再触发动态字段错误 | `wallet_chain_info_transactions_item.dart`、BTC widget test |
| F08 | P1 | Solana/Tron 历史 from/to 被持久化为小写 | 原样保存与读取完整地址；EVM 校验展示逻辑仍可忽略大小写 | `transaction_address_case_test.dart` |
| F09 | P1 | 个人页交易历史打开钱包列表 | 直接进入用户隔离的本地跨币种交易记录；只读详情避免错用当前 signer | activity repository/page、repository/navigation tests |
| F10 | P1 | DeFi 请求失败伪装成空资产，旧钱包响应污染新钱包 | 错误传播并可重试；切换钱包后丢弃旧请求 | datasource、DeFi widget tests |
| F11 | P2 | DeFi 超过 10 个协议后“查看全部”无操作 | 可展开全部协议并收起 | `defi_positions_section.dart` |
| F12 | P2 | AA 历史“查看全部”空回调，始终显示无数据 | 跳转 AA 所属链浏览器，明确外部历史来源 | `aa_account_explorer.dart`、network tests |
| F13 | P2 | 永续市场行点击无反馈，OI 资产量被标美元 | 新增只读行情详情；美元 OI 按 mark price 转换 | `perp_market_details_sheet.dart` |
| F14 | P2 | 钱包长名称与顶栏右侧按钮叠压 | 标题占剩余宽度并省略，操作按钮保留独立空间 | top bar tests：320/390/768 宽度 |
| F15 | P2 | DEX 确认页及长金额报价卡溢出 | 摘要可滚动，确认/取消固定在安全区域；报价行和授权选项换行 | confirm widget、视觉与回归测试 |
| F16 | P2 | 个人页语言选择仅 pop，未写入 locale | 接收返回值、更新 locale provider，并显示当前语言 | profile navigation tests |
| F17 | P2 | 货币打开语言页；版本写死 2.0.0；评分仅感谢提示 | 货币显示 USD 当前能力；版本进入真实 About；评分打开商店 | profile 页面与导航 |
| F18 | P2 | Gas/批量/组合/连接管理入口分散 | 个人页集中直达既有功能 | profile 页面、入口清单 |
| F19 | P1 | CI 固定 Flutter 3.41.9，低于 pubspec 最低要求 | 四个 workflow 与 README 对齐 Flutter 3.44.8 / Dart 3.12.2 | `.github/workflows/` |
| F20 | P1 | 历史金额先转换 double，长精度数值被舍入 | 列表与只读详情从原始单位精确格式化并附资产单位 | `wallet_chain_info_transactions_item.dart`、history widget tests |

P0/P1 表示问题对资金确认、金额表达或可发布性的影响优先级，不代表已发生资产损失。全部修改仅在工作区交付；swap 服务未部署，应用未发布。README 已增加审计入口，并纠正硬件签名、DOT 质押、DEX 与完整历史的过度完成标记及固定 APY 示例。

## 尚未闭环的问题与交付要求

### R01：硬件签名主链路

`HardwareWalletProvider.importAccount` 将地址与派生路径写到独立的 `hardware_wallet_imported_accounts` 列表。生产代码没有消费 `needsKeystoneQr` 并打开 `KeystoneSignPage` 的调用链。主钱包的 `WalletInfo` / sender 分派尚未以统一账户模型持有硬件 signer。

下一项交付应包含持久化的 signer 类型与设备引用、主钱包选择硬件账户、发送摘要、设备请求、拒绝/重试、签名后恢复地址验证及广播。验收至少覆盖 Ledger EVM、Keystone QR EVM，并在支持列表中诚实标出未完成链。单独添加“签名”菜单不能解决该问题。

### R02：Solana DEX 与原生币兑换

Jupiter 返回 base64 序列化交易且 `routerAddr` 为空。当前主 DEX 执行先做 EVM router 白名单检查，再走 calldata sender；这不是可用的 Solana swap 执行器。原生 EVM swap 与 AA batch 还将交易 value 固定为零，不能覆盖需要附带 ETH 的路由。

下一项交付需要单独的 Solana 交易解析、账户和指令校验、blockhash 有效期、签名与广播；原生币路径需要经过验证的 value 字段和费用上限。AA 模式应使用智能账户地址获取报价，确保 recipient、allowance owner 与资金来源一致。以上必须通过本地模拟及测试网/可控环境回执验收。

### R03：全量链上授权中心

目前未发现一套从安全入口到 allowance/NFT operator 列表、精确额度编辑、批量撤销、交易状态的完整流程。钱包已有的 approve、WalletConnect 断开和安全评分组件都不能替代它。

建议先支持 ETH、Base、Arbitrum 的 ERC-20 授权，按链展示 spender、额度和来源。撤销完成以 receipt/allowance 回读为准；Permit2 和 NFT operator 独立建模。索引覆盖不足时允许手动 token+spender 检查，但不能把“未查到”显示成“无风险”。

### R04：单币历史筛选、导出与本地数据恢复

现有单币历史页对 `allRecords` 做筛选，而该列表按 50 条分页；首批记录被全部过滤后，页面可能没有继续加载的入口。CSV 导出也针对当前已加载列表，不能声称导出完整历史。本次新账户级页面的状态筛选在数据库分页前完成，但没有重写单币日期/方向筛选和完整 CSV 导出。

需将筛选下推查询层，导出按明确范围逐页读取，输出精确金额并防止文本单元格被解释为公式。此前已被小写转换损坏的非 EVM 地址不能可靠逆转；应通过可信链上历史重新同步，不能凭猜测恢复地址。

### R05：配置条件与平台差异

DeFi 区块在未设置 `DEBANK_API_KEY` 时隐藏，因此有组件和重试测试并不证明发布包可见。MPC、Paymaster、价格提醒、空投、积分、跨链和推送也依赖服务配置。生产发布需要一份不包含密钥值的能力配置清单。

iOS 目前主动隐藏 DEX/swap 入口，Earn 主导航也与 Android 不同。本次保留了这些现有产品条件；平台入口清单应单独验收。不能把 Android 可到达的 Earn 子页面自动算作 iOS 已提供。

### R06：深链与直播预测

`main.dart` 的 groupMining/fullNode 深链分支目前仅记录日志，没有进入目标业务页。需要校验深链参数、登录后恢复目标、导航到具体计划/节点，并处理无效或过期数据。

直播预测默认使用 Matrix 同步的虚拟积分仓库；配置链上合约后会选择仍包含 `UnimplementedError` 的 `ChainPredictionRepository`。配置值存在不能被当作链上功能完成。真实资金版本需要完整合约交互、精确整数金额、授权、结算与争议处理的独立交付。

### R07：覆盖率和真实设备证据

行覆盖率 16.42% 低于 70% 门槛。应先补签名授权、广播错误、网络隔离、备份恢复和页面生命周期等高风险行为测试，随后扩大覆盖。不得为使 CI 变绿而降低门槛或把未覆盖业务大范围排除。全仓只读格式检查另发现 313 个未改动文件需要格式化；本次修改文件不在其中，未将无关格式重写混入功能修复。

本次截图是使用真实 Flutter 主题、固定测试数据生成的 widget 渲染，不是实机证明。蓝牙设备、摄像头 QR、Face ID、iOS/Android 权限、推送、后台恢复和链上交易仍需单独设备报告。

## 后续实施顺序与验收门槛

| 阶段 | 交付项 | 完成条件 |
|---|---|---|
| 发布前 | 本次客户端+swap 服务契约变更 | 同一环境校验 `dstAmount`、raw output 与 6/8/9/18 位代币显示；未知风险不可变成 0 |
| 发布前 | DEX 剩余执行缺口 | SOL 与 native value 使用独立可验证执行器；AA 报价主体正确；没有错链/错账户回退 |
| 发布前 | 身份验证与 signer 权限矩阵 | 软件/观察/硬件/MPC/AA 逐入口允许或拒绝；取消时 sender 调用次数为零 |
| 发布前 | 恢复与备份 | 全新安装恢复到同一地址；错误密码、损坏备份、取消认证均有反馈 |
| 下一轮 | 授权撤销中心 | 可查询、展示、撤销、回读；断开会话与撤销不会混淆 |
| 下一轮 | 硬件账户主流程 | 设备账户出现在主钱包；正确设备/路径签名；拒绝与重试可恢复 |
| 下一轮 | 单币完整历史与 CSV | >50 条、跨日期、失败/待确认过滤正确；导出范围与行数一致 |
| 下一轮 | 深链和平台入口 | 矩阵逐入口有设备截图/导航日志；登录后恢复目标 |
| 持续 | UI 与性能 | 320/390/768 宽度、横屏、大字体、亮暗主题、空/错/加载状态均可操作 |
| 持续 | 质量门槛 | 主套件与相关 native/integration 通过；覆盖率达到既有门槛 |

法币支付、银行卡、发行稳定币及更多托管/恢复服务涉及外部合作、服务准入和业务决策。它们作为行业能力登记，不应以空按钮或纯客户端占位方式宣布完成。近期优先补齐资金链路与安全中心，再评估新增业务品类。

## 视觉证据

截图尺寸为 390×844 逻辑像素，使用固定测试数据，无真实余额和密钥。

| 页面 | 亮色 | 深色 |
|---|---|---|
| 个人页与快捷入口 | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/profile-light.png) | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/profile-dark.png) |
| DEX 确认页 | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/swap-confirm-light.png) | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/swap-confirm-dark.png) |
| 账户本地交易页 | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/activity-light.png) | [截图](device-test-reports/evidence/2026-09-10-wallet-ui/activity-dark.png) |

## 来源

以下均为官方产品、开发者文档或官方开源仓库；访问日期为 2026-09-10。未标注发布日期的条目不推断其发布时间。

[^1]: MetaMask. [What are transaction simulations?](https://support.metamask.io/manage-crypto/transactions/simulations/). 交易模拟、账户/网络范围及链下模拟的限制。
[^2]: RabbyHub. [Rabby official repository](https://github.com/RabbyHub/Rabby). 官方 EVM 钱包源码与产品定位。
[^3]: Phantom. [Swap crypto in Phantom](https://help.phantom.com/hc/en-us/articles/5985106844435-Troubleshooting-swap-issues). 兑换、滑点、优先费与条件性 gasless 流程。
[^4]: Phantom. [Security tips for Phantom users](https://help.phantom.com/articles/13515761228051). 完整地址核对、钓鱼和垃圾空投风险。
[^5]: MetaMask. [How to revoke smart contract allowances/token approvals](https://support.metamask.io/more-web3/learn/how-to-revoke-smart-contract-allowances-token-approvals). 授权撤销、断开连接和费用的差别。
[^6]: Ledger. [Clear Signing overview](https://developers.ledger.com/docs/clear-signing/overview). 可信设备上的可读交易签名。
[^7]: MetaMask. [How to use gas included transactions](https://support.metamask.io/manage-crypto/transactions/metamask-gas-station/)；[Understanding gas sponsorship](https://support.metamask.io/manage-crypto/transactions/gas-sponsorship). 费用代付与支持条件。
[^8]: OKX Wallet. [What's OKX Bridge and how do I swap tokens across chains?](https://web3.okx.com/help/whats-okx-bridge-and-how-do-i-swap-tokens-across-chains). 跨链产品流程与路由比较。
[^9]: Trust Wallet. [Watch-only wallet addresses](https://trustwallet.com/ru/blog/academy/chto-takoe-koshelek-tolko-dlya-prosmotra-watch-only). 官方俄语版本，页面标注 2026-08-19；观察地址不能支出。
[^10]: Safe. [What is Safe?](https://docs.safe.global/home/what-is-safe). 智能账户、owner 与模块架构。
[^11]: 1inch. [Migration from v5.2 to v6.0](https://business.1inch.com/portal/documentation/apis/swap/classic-swap/migration/migration-v52-v60)；[Classic Swap API schema](https://business.1inch.com/portal/documentation/apis/swap/classic-swap/methods/v6.1/1/swap/method/get). v6 字段更名及输出代币元数据。
[^12]: Hyperliquid. [Info endpoint: Perpetuals](https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api/info-endpoint/perpetuals). 市场上下文及账户查询的数据结构。
