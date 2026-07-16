# N42 2026 代码核验与 AI 自动化测试计划

> 更新：2026-07-16
> 适用：N42 Wallet、N42 Chat、Live、Mining；iOS/Android 发布候选包。
> 依据：当前 `lib/`、实际编译的 `packages/n42_chat/`、`docs/2026钱包市场竞品对比分析报告.md`、`docs/2026_Chat市场竞品对比.md`。后两份报告中的“附录 C / 权威层”优先于正文历史声称。
> 结果口径：只有“用户可达 + 有效调用链 + 满足外部条件”的功能才可标通过。不得把页面、占位 Toast、纯本地模拟或未接线服务计为已交付。

## 1. 自动化分级

| 标记 | 执行方式 | 可替代人工的范围 |
|---|---|---|
| `UT` | Dart 单元、属性和 HTTP mock 测试 | 规则、金额精度、序列化、错误映射、状态机 |
| `IT` | Flutter `integration_test`，语义 Key/文本选择器 | 单账号、可控后端的完整页面流程 |
| `AI-1` | AI 编排 Android 模拟器或真机点击、截图、日志、语义树 | 安装、登录、导航、表单、视觉回归、无真实资产风险流程 |
| `AI-2` | 两个 Android 设备/账号的 AI 编排 | 消息、群聊、QR、跨设备同步、来电/接听 |
| `AI-3` | Android AI + 受控测试链/Mock 服务 | 广播前验证、DEX/Bridge 报价、WalletConnect、DApp 交互 |
| `人工-iOS` | iPhone 由测试人员点击，录屏和 Xcode 日志留证 | 当前约定下，所有 iOS 系统授权、Face ID、相机、分享、通话和最终签名 |
| `人工安全` | 最小金额测试账户，人工最终确认 | 助记词/私钥、真实交易、授权、硬件签名、法币、生产推送 |

AI 可以判断页面是否可见、按钮是否可点、文案和截图是否符合预期；不能自行批准真实链上交易、导出秘密、使用生物识别或绕过 iOS 系统确认。没有稳定 Key 的组件必须先补 Semantics/Key，不能长期依赖坐标点击。

## 2. 当前自动化基线与准入

| 项目 | 现状 | 要求 |
|---|---|---|
| `flutter test --coverage` | 已有单元/组件测试 | CI 必跑，保持主工程 70% 门槛 |
| `flutter test integration_test/` | `app_test.dart`、`wallet_flow_test.dart` 目前为 `expect(true, true)` 占位 | 不计入覆盖率；以下 `IT` 用例落地后才可作为发布证据 |
| Android 安装点击 | 可由 `adb`、Flutter driver/语义树、UIAutomator 和截图完成 | 每个候选 APK 自动安装、冷启动、采集 logcat、导出测试报告 |
| iOS 点击 | 本轮按约定人工执行 | 由测试人员在 iPhone 点击；保留录屏、崩溃日志和版本号 |
| 真实链上 | 受余额、RPC、Gas、第三方服务影响 | 默认测试网/白名单小额；生产网需人工安全确认 |

### 2.1 环境与数据

1. 准备两个独立 Chat 账号 A/B、两个独立测试钱包、测试网 RPC、已配置的测试 Token 和可回收最小 Gas。
2. 需要 LiveKit 的通话/直播/语音房准备独立 LiveKit 与 JWT；需记录服务端版本和区域。
3. 云 AI、GIF、法币、DeBank、Push、ENS、DEX、LI.FI 等用例必须记录 key/后端状态；未配置时验证“明确降级提示”，不能报功能通过。
4. Android 使用至少一台实体机及一台干净模拟器；iOS 使用连接的实体 iPhone，由人工完成点击。
5. 不在脚本、测试日志、截图或文档保存助记词、私钥、密码、恢复密钥和生产 Token。

## 3. Wallet 代码核验用例

| ID | 用例与预期 | 代码/比较依据 | 状态 | 自动化 |
|---|---|---|---|---|
| W-01 | 全新安装、升级覆盖、冷启动。未登录/已登录路由正确，启动不白屏、不循环跳转。 | `splash_page.dart`、`home_page.dart` | 可用 | AI-1, 人工-iOS |
| W-02 | 创建、助记词导入、私钥导入、Keystore 导入/导出、观察钱包；错误格式、取消、重复钱包均有确定反馈。 | `create_wallet/`、`wallet_manage/`、`wallet_backup_*` | 可用 | UT, IT, AI-1；秘密展示人工安全 |
| W-03 | 备份门禁：未完成助记词备份时发送/敏感操作按产品规则拦截；完成后恢复可用。 | 钱包创建和备份链路 | 可用 | IT, AI-1；人工安全 |
| W-04 | 多钱包切换、重命名、删除确认、余额隐藏、地址簿增删改和观察钱包不可签名。 | `wallet_action_provider_*`、`watch_only_wallet_utils.dart` | 可用 | UT, IT, AI-1 |
| W-05 | 逐链验地址、余额、收款、发送入口：ETH/BTC/SOL/TRX 为 P0；TON/APT/SUI/ALGO/DOT 为 P1；其余已配置链抽样。 | `sender_factory.dart`、各 `*_sender.dart` | 部分 | UT, AI-3；每条真实发送人工安全 |
| W-06 | Token 列表刷新、网络筛选、排序、Pin/隐藏、手动添加、搜索和返回；名称不得截断，重置筛选一次完成。 | `wallet_page.dart`、`wallet_action_provider_token.dart`、`wallet_action_provider_sort.dart` | 可用 | IT, AI-1 |
| W-07 | 价格和余额刷新：稳定币/USDT 价格不能沿用缓存的错误资产价格；网络失败显示刷新/重试和时间，不把旧值伪装为最新。 | `market_api.dart`、`market_api_payload_utils.dart` | 条件 | UT, IT, AI-1（mock）；真实源人工复核 |
| W-08 | N42 原生币为 `N`；`S Coin`/`SCoin` 是 11x 系统、发行在 N42 链的 Token，必须按合约/链识别，不能显示为 ETH；转入历史与 explorer 一致。 | `tokenview_*`、`aggregated_token.dart` | 部分 | UT, AI-3；需确认正式合约和索引服务 |
| W-09 | 收款页：链 Tab、二维码、复制、分享、地址完整展示、扫描入口和空金额均可用；分享 URI 包含正确链/地址。 | `wallet_receive_qr_content.dart`、`eip681.dart` | 可用 | UT, IT, AI-1；分享目标人工-iOS |
| W-10 | 收款金额：空金额表示付款方输入；预填金额表示付款方可见并按 URI 付款。只接受当前资产 `decimals` 范围内的小数（常见 EVM 资产最多 18 位）。 | `decimal_amount.dart`、`eip681.dart` | 可用 | UT, IT, AI-1 |
| W-11 | 扫码付款：扫描 EIP-681/BIP21/普通地址，链和资产不匹配时阻止或明确警告；相机拒权可恢复。 | `scan_page.dart`、收款/发送页 | 可用 | IT, AI-1；人工-iOS 相机 |
| W-12 | 发送地址：空、格式错、不同链、自己地址、地址簿、扫码粘贴、ENS 解析；不可把错误地址送入签名。 | `validation/address_validator.dart`、`ens/` | 可用 | UT, IT, AI-1 |
| W-13 | 发送金额：空、0、负数、超余额、整数/小数、最小单位、手工填最大值；精度不得超过当前资产 `decimals`（18 位资产拒绝第 19 位）。 | `decimal_amount.dart`、发送页 | 可用 | UT, IT, AI-1 |
| W-14 | `Max` 状态机：空值、超余额、已删除金额、有效金额下均能重新填入正确最大可转金额；对原生币须扣除 Gas。 | 发送页金额控制器、`coin_gas.dart` | 可用 | UT, IT, AI-1 |
| W-15 | 费用：EIP-1559/Gas 估算、手动 Gas、余额不足、RPC 521 等失败显示可理解错误；不能显示 0 Gas 后仍允许危险提交。 | `evm_sender.dart`、`gas_settings_page.dart` | 条件 | UT, IT, AI-3 |
| W-16 | 支付确认：只要求当前启用的密码/手势/生物认证，不得同时强制三种；取消不广播，成功返回 tx hash。 | 安全设置、发送确认链路 | 可用 | IT, AI-1；生物认证人工-iOS/安全 |
| W-17 | EVM 真实广播：chainId 与 signer 一致，确认后记录、详情、区块浏览器与链上 hash 一致；失败不得显示成功。 | `evm_sender.dart`、`transaction_api.dart` | 条件 | UT, AI-3；人工安全 |
| W-18 | 交易记录、详情、Explorer：入/出方向、金额、手续费、hash、分页和刷新与链一致。 | `transaction_record_iterms_provider.dart`、`browser_txhash.dart` | 条件 | IT, AI-1/AI-3 |
| W-19 | 自定义 EVM 链：添加 RPC/chainId/symbol/decimals，RPC 校验、余额、Gas、nonce、发送均走该 RPC；错误 RPC 可恢复。 | `wallet_chain_registry.dart`、`chain_url_registry.dart`、`evm_sender.dart` | 部分 | UT, AI-3；真实发送人工安全 |
| W-20 | DEX：Token 选择、fallback 列表、金额/滑点、报价、approve+swap、历史；后端 token/quote 404 时可见错误且不签名/不广播。 | `dex_swap/`、`dex_swap_api.dart` | 条件 | UT, IT, AI-3 |
| W-21 | 限价单：创建、取消、查询；仅验证本地到价提醒，不将其称为自动成交。 | `dex_limit_order_*` | 条件 | UT, IT, AI-1 |
| W-22 | Bridge：源/目标链、报价、授权、签名广播、持久化历史和状态。LI.FI 不可用时不产生假成功。 | `bridge/`、`lifi_api.dart` | 条件 | UT, AI-3；人工安全 |
| W-23 | Staking：ETH/Lido 仅在测试账户验证真实广播；SOL/ATOM 当前只能查询/构建，必须明确“不支持钱包内广播”。 | staking 页面、`evm_sender.dart` | 部分 | AI-3；人工安全 |
| W-24 | Aave：市场加载、Supply/Withdraw/Borrow/Repay、授权不足时两步执行；无测试余额时验证禁用和原因。 | `pages/lending/` | 条件 | UT, AI-3；人工安全 |
| W-25 | Portfolio/行情/提醒：DeFi 持仓仅在 `DEBANK_API_KEY` 配置时显示；价格提醒是前台轮询，不能验收为后台 Push。 | `portfolio_page.dart`、市场页 | 条件 | UT, AI-1 |
| W-26 | AA：Simple/Safe/Biconomy/Kernel/EIP-7702 创建、批量 UserOp 和回执。Paymaster、Session Key、Passkey、社交恢复只验证限制提示，不按真实代付/上链恢复通过。 | `aa/`、`aa_transfer_handler.dart` | 部分 | UT, AI-3；人工安全 |
| W-27 | WalletConnect 和内置 DApp：连接/拒绝、EIP-712、交易签名、断开；内置 Provider 的 connect/sign/send 双向回调，阻断钓鱼域名。 | `wallet_connect/`、浏览器 Provider、`dapp_security_badge.dart` | 条件 | UT, AI-3；人工安全 |
| W-28 | 批量转账 CSV：表头、地址、金额、重复/错误行、费用、预览、逐项结果；真实执行需小额测试链。 | `batch_transfer_*` | 条件 | UT, IT, AI-3 |
| W-29 | 硬件钱包：Keystone/Ledger/Trezor 仅验配对、发现、账户导入；当前软件发送不应冒充硬件签名。 | `hardware_wallet/` | 部分 | AI-1；设备签名不验收 |
| W-30 | 安全：应用锁、手势、TOTP、钓鱼/交易模拟/地址标签/Root 越狱提示；Face ID/指纹和密码导出使用人工安全验证。 | `security/`、`tx_simulation_card.dart` | 可用 | UT, AI-1；人工-iOS/安全 |
| W-31 | ENS：搜索、注册、续费、子域、解析与失败处理；后端托管写操作和余额消耗需测试环境。 | `pages/ens/` | 条件 | UT, AI-3；人工安全 |
| W-32 | Mining V1/V2：状态、计划、全节点、后台限制、收益/错误；杀进程和权限变化后状态一致。 | `mining/`、`mining_v2/` | 条件 | IT, AI-1；人工-iOS 后台 |
| W-33 | 不纳入通过：BTC 自托管质押、独立空投发现/领取、法币出金、真实 MPC、硬件签名、真实 Paymaster。 | 钱包 2026 对比报告 §3/§7/§9/§11 | 未实现/不可达 | 产品待办，不做功能通过 |

## 4. Chat、Live 与社交代码核验用例

| ID | 用例与预期 | 代码/比较依据 | 状态 | 自动化 |
|---|---|---|---|---|
| C-01 | Chat 登录：邮箱/MXID/已配置 SSO、错误密码、登出、重启恢复、多账号切换。测试凭据仅从受控的本地密钥环境读取，不写入文档、脚本或日志。 | `auth/`、`account_switch_page.dart` | 条件 | IT, AI-1；人工-iOS |
| C-02 | 主应用 Wallet/Chat Tab 互跳后仍留在 N42，不应跳至 11x App；冷/热启动 Deep Link 路由一致。 | `chat_tap_dedup.dart`、`chat_push_routing.dart`、Deep Link | 可用 | IT, AI-1 |
| C-03 | 两账号单聊：文本、回执、输入中、编辑历史、撤回、回复、转发、反应、收藏、置顶、定时发送、草稿。 | `chat_page*.dart`、chat BLoC | 可用 | AI-2 |
| C-04 | 富媒体：相册/相机图片、编辑、视频、语音、Video Note、文件、位置、联系人、GIF、静态/Lottie/WebM 贴纸；权限拒绝、取消和下载失败均可恢复。 | `media/`、`expression_panel.dart` | 条件 | AI-2；人工-iOS 相机/文件 |
| C-05 | Poll/Quiz、代码块、Markdown、白板实时笔画；第二设备即时收到且不会把白板事件刷入消息列表。 | `poll_create_sheet.dart`、`whiteboard_page.dart` | 可用 | UT, AI-2 |
| C-06 | 群/频道/Space：创建、邀请、退出、角色、公告、Topic、文件/相册、公开/邀请规则、Token Gate 拒绝和通过。 | `group/`、`space/`、`token_gate_*` | 条件 | AI-2；链验需 AI-3 |
| C-07 | 会话/联系人：排序、未读、静音、置顶、文件夹、隐藏会话、黑名单、好友、搜索、联系人权限。 | `conversation/`、`contact/`、`chat_folder/` | 可用 | AI-1/AI-2 |
| C-08 | 搜索：当前会话和跨会话全文、联系人、群组、结果跳转；离线/归档失败应退化但不能崩溃。 | `global_search_page.dart`、`ArchiveSearchService` | 可用 | UT, AI-1 |
| C-09 | E2EE：两端消息加解密、SAS 验证、SSSS 备份/恢复、新设备缺会话密钥的可理解提示与恢复路径。 | Matrix/Olm/Megolm、`sas_verification_page.dart` | 条件 | AI-2；人工安全 |
| C-10 | Chat Lock/隐私：锁定会话、PIN/生物解锁、Deep Link 仍需验证、查看一次/自毁消息、截屏保护平台差异。 | `chat_lock_page.dart`、security pages | 部分 | AI-1；人工-iOS 生物/截屏 |
| C-11 | 1v1/群语音视频：邀请、接听/拒绝、静音、扬声器、前后摄像头、挂断、未接记录、群通话。出现 `Failed to join meeting: token` 时必须显示可重试/配置错误，不能空白。 | `call_manager.dart`、`call_screen.dart`、LiveKit | 条件 | AI-2；人工-iOS 音视频 |
| C-12 | 屏幕共享和虚拟背景：Android 运行时权限、启动/停止、对端可见；iOS 屏幕共享/背景图属于人工验证。实时字幕、通话 E2EE、美颜不按已交付验收。 | VoIP/虚拟背景实现、Chat 对比附录 C | 部分 | AI-2 Android；人工-iOS |
| C-13 | Voice Room/Live：创建、加入、听众/主持人、举手、静音/踢出、退出；直播的开播、观众、弹幕、礼物、预测结果按独立 LiveKit 环境验收。 | `voice_room/`、`lib/features/live/` | 条件 | AI-2；人工-iOS |
| C-14 | Moments/Stories/Video Feed：图文/视频发布、可见范围、点赞评论转发、24h 到期、删除、滚动/播放。 | `moment/`、`story/` | 可用 | AI-2 |
| C-15 | 聊天内钱包桥：转账、收款请求、商户二维码、Tip、NFT 赠送；发送前显示钱包确认，成功写回真实 hash。 | `wallet_bridge.dart`、`transfer/` | 条件 | AI-3；人工安全 |
| C-16 | 红包与订阅：当前红包/订阅为本地状态，不得验收为链上资金或真实支付；仅验 UI、状态恢复和明确说明。 | `red_packet/`、`subscription/` | 部分 | UT, AI-1 |
| C-17 | AI：摘要、改写、智能回复、翻译、图片理解、AI 贴纸、TTS；无 AI key 时提示未配置或降级；端侧 Gemma 需模型 URL/HF Token 后真机出词。 | `ai/`、`local_llm_settings_page.dart` | 条件 | UT, AI-1；模型实测人工 Android |
| C-18 | Mini App、Bot、Bridge：静态 Mini App 启动、Bot 命令/出站 Webhook；mautrix Bridge 需服务端，不将静态清单称作真实应用商店。 | `mini_app/`、`bridge/` | 条件 | AI-1/AI-2 |
| C-19 | Push：前后台消息、@、来电、点击导航、角标清除、DND；链上通知的 Push 服务失败应显示可定位错误。 | `app_push_*`、on-chain notification | 条件 | AI-2 Android；人工-iOS APNs |
| C-20 | 设置与体验：主题、语言、字体、背景、自动下载、存储清理、导出、无障碍 Semantics、横竖屏和大字体不溢出。 | settings pages、Semantics 覆盖 | 可用 | IT, AI-1；人工-iOS VoiceOver |
| C-21 | 不纳入通过：聊天 Passkey 登录、MLS 生产切换、实时字幕、通话 E2EE、数据分级、积分/排行/兑换、治理和社交图谱（默认开关未启用）。 | Chat 对比报告附录 C | 不可达 | 产品待办，不做功能通过 |
| C-22 | 外部依赖：GIF、云 AI/STT、法币、Bridge、Egress、LiveKit 均缺省不可用；缺配置时验证降级提示，配置齐全后才可做正向验收。 | `N42ChatConfig`、外部依赖清单 | 条件 | AI-1/AI-2 |

## 5. AI 自动化实施顺序

1. 先把占位 `integration_test` 替换为 W-01、W-06、W-12 至 W-16、C-01、C-02、C-03、C-07、C-20 的真实语义驱动流程；这些用例不得再用无条件 `expect(true, true)`。
2. 在 Android 实体机执行 AI-1：安装、冷启动、钱包首页、Token 搜索/刷新、收款、金额和 Max、设置、Chat 登录/导航、单机 UI 回归。失败自动保留截图、语义树、logcat、网络状态。
3. 在两 Android 设备执行 AI-2：消息/媒体/群组、二维码、E2EE/SAS、通话/语音房、动态、Push。每项要求 A/B 两端时间戳和录屏。
4. 在测试链与 Mock 后端执行 AI-3：余额/价格异常、DEX 404、RPC 521、chainId、Gas、WalletConnect/DApp、Bridge/AA；默认禁止真实主网广播。
5. iPhone 由测试人员按同一 ID 人工点击。优先回归启动、收款、Max、发送确认、二维码/分享、Chat 登录、媒体权限、通话、Push、Face ID 和崩溃恢复。

## 6. 发布出口与报告字段

P0 必须全部通过：W-01/02/03/05(ETH)、W-06/09/12-18、W-30、C-01/02/03/09/11/19、升级与冷启动。任何真实资产相关 P0 未满足测试资金或服务端条件时，发布报告必须标“未验证”，不能以自动化绿灯替代。

每次报告至少记录：候选版本与 commit、设备/OS、账号类型、链和 RPC、测试数据来源、用例 ID、自动化等级、截图/录屏/日志链接、结果、缺陷 ID、外部依赖状态。将“功能未实现”“外部服务不可用”“脚本失败”“产品缺陷”分开统计。

## 7. 历史清单的处理

`docs/functional_test_checklist.md` 保留为完整功能目录和人工检查表。本文件补足了它未描述的边界、依赖、AI 自动化标记和 2026 对比核验结论；两者冲突时，以本文件的“状态”列为准。
