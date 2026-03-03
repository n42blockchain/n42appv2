# N42 生产就绪性与成熟度审计报告

**审计日期：** 2026-03-02
**审计范围：** n42appv2（主钱包 App）+ n42_chat（聊天插件）

---

# 第一部分：n42appv2 主钱包 App

**代码规模：** 907 个 `.dart` 文件，约 262,804 行（含生成文件）

## 全局指标

| 指标 | 数值 |
|------|------|
| 总 `.dart` 文件数 | 907 |
| 含 TODO/FIXME/HACK 的文件数 | 26 |
| TODO/FIXME/HACK 总行数 | 71 |
| `debugPrint` 调用总次数 | 428（127 个文件） |
| 裸 `print()` 语句 | 0（已全部替换为 debugPrint） |
| `stub`/`UnimplementedError` 文件 | 10 |
| 空 `catch {}` 块 | 11 处 |
| 测试文件数 | 120 |

---

## 各模块评级

### core/network — 🟡 基本就绪

- 文件：12 个，1,746 行
- TODO：0，debugPrint：7 次（合理的错误日志）
- 重试拦截器、熔断器、Dio 封装完整
- 测试覆盖：`api_client_test`、`retry_interceptor_test`、`circuit_breaker_test`

### core/security — 🟡 基本就绪

- 文件：16 个，2,903 行
- TODO：0，debugPrint：29 次（安全事件日志，尚可接受）
- 测试：6 个测试文件覆盖核心安全类
- 问题：`device_security.dart:183` 有一处空 `catch (_) {}`

### core/config — 🔴 存在严重问题

- 文件：3 个，598 行
- **P0 问题 1：** `api_keys_config.dart:144` 有明文硬编码 Groq API Key（`gsk_Dszun...`），会被编译进 APK 可被反编译提取
- **P0 问题 2：** `app_config.dart:147` Mining WebSocket 默认使用明文 `ws://` + 裸 IP（`ws://5.161.252.59:8546/`），无加密
- **P0 问题 3：** 测试环境 API 端点使用裸 IP + `http://`，TODO 标记"生产前替换"但未完成
- TODO 数量：11 处（均指向生产配置）

### core/storage — 🟢 生产就绪

- 文件：3 个，1,143 行，TODO：0，debugPrint：4 次

### core/utils — 🟢 生产就绪

- 文件：7 个，755 行，TODO：0，debugPrint：2 次

### core/api_hub — 🟡 基本就绪

- 文件：14 个，1,261 行，debugPrint：13 次（偏多）
- 功能完整，无 TODO

### core/di、core/error、core/routing — 🟢 生产就绪

---

### features/wallet/ — 🟠 需要改进（最大模块）

- 文件：441 个，110,133 行
- **TODO/FIXME：42 处**（全项目最多），debugPrint：184 次

**关键问题：**

| # | 问题 | 位置 |
|---|------|------|
| 1 | TransferHandlerFactory 中 12 条链（BTC/SOL/TRX/APT/DOT/ATOM/XRP/TON/ALGO/XTZ/FIL/ZIL）的 handler 全部返回 `notYetMigrated` | `wallet/api/transfer/handlers/` |
| 2 | `wallet_service_impl.getBalance()` 返回占位数据 | `wallet_service_impl.dart:187` |
| 3 | `refreshCoin(String symbol)` 方法体为空 | `wallet_providers.dart:422` |
| 4 | `n42_wallet_bridge.dart:108` — `// TODO: 实现实际转账逻辑` | `n42_wallet_bridge.dart` |
| 5 | AA 模块 `account_deployer.dart:107` 多种账户类型部署未实现（throw UnimplementedError） | `account_deployer.dart` |
| 6 | AA 模块 `signature_builder.dart:138` 签名恢复未实现 | `signature_builder.dart` |
| 7 | `market_coin_info_sections.dart` 10 处 i18n 硬编码英文 | `market_coin_info_sections.dart` |
| 8 | `transaction_state_resolver.dart:54` — 部分链类型未处理 | `transaction_state_resolver.dart` |

- 测试：24 个，主要覆盖 model/entity 层，Provider 和 API 层覆盖不足

### features/wallet_connect/ — 🟢 生产就绪

- 文件：14 个，2,789 行，TODO：0
- 拆分为 state/connection/session/signing 四层，架构清晰
- 测试：6 个

### features/bridge/ — 🟡 基本就绪

- 文件：11 个，3,488 行，TODO：0
- LI.FI 跨链桥完整实现，测试：3 个
- 注意：ERC-721 bridge 为 stub

### features/mining_v1/ — 🟠 需要改进

- 文件：37 个，5,826 行，debugPrint：31 次（偏多）
- 无 TODO，但 debug 日志量过大

### features/mining_v2/ — 🟡 基本就绪

- 文件：36 个，6,650 行，TODO：1
- ~~WebSocket/HTTP URL 为裸 IP 且无 TLS~~ → 已统一至 `AppConfig` 管理
- ~~`connectWebSocket` 调用已移除的 `genBlockVerifyResult` 导致闪退~~ → 已迁移至 `runClient()` 路径
- 仍依赖旧的 `WalletActionProvider` 创建钱包

### features/mining/ — 🟡 基本就绪

- 文件：7 个，1,019 行，TODO：0，debugPrint：0，测试：4 个

### features/browser/ — 🟡 基本就绪

- 文件：23 个，4,373 行，TODO：0，debugPrint：5 次
- 2 处空 `catch(e) {}`（JS 桥接中故意静默）
- 测试：2 个

### features/hardware_wallet/ — 🟡 基本就绪

- 文件：19 个，5,675 行，TODO：0，debugPrint：16 次
- 支持 Ledger（完整 APDU）、Trezor、Keystone（UR codec）
- 测试：2 个

### features/staking/ — 🟡 基本就绪

- 文件：15 个，4,546 行，TODO：0，debugPrint：0
- 支持 DOT/ATOM/SOL staking
- 测试：2 个

### features/loyalty/ — 🟠 需要改进

- 文件：14 个，4,084 行
- **核心问题：API 异常时 fallback 到 mock 数据**（`_getMockAccount`、`_getMockTasks`），用户无法区分真实/假数据
- 测试：1 个

### features/airdrop/ — 🟠 需要改进

- 文件：10 个，2,903 行
- **`getTrendingAirdrops()` 失败后返回 6 条硬编码空投数据**（LayerZero、EigenLayer 等），与真实数据无法区分
- 测试：3 个

### features/home/ — 🟡 基本就绪

- 文件：43 个，9,357 行，TODO：0，debugPrint：10 次，测试：2 个

### features/login/ — 🟢 生产就绪

- 文件：18 个，3,774 行，TODO：0，debugPrint：6 次
- 支持账号注册/登录/重置密码/社交登录，测试：2 个

### features/settings/ — 🟢 生产就绪

- 文件：3 个，261 行，TODO：0，debugPrint：0

### features/splash/ — 🟢 生产就绪

- 文件：2 个，486 行，TODO：0
- 13 种语言随机标语（中英 50% + 其他 11 语言 50%），每次仅显示单语

### features/profile/ — 🔴 未就绪

- 文件：2 个，528 行
- **15 处 TODO**：所有导航方法（钱包管理、地址簿、交易记录、安全设置、备份钱包、语言、货币、主题等）均为空方法体
- 用户点击任何功能项均无反应，基本是带 UI 骨架的空壳
- 测试：0 个

### features/notification/ — 🟡 基本就绪

- 文件：2 个，352 行，功能完整

### features/earn/ — 🟡 基本就绪

- 文件：6 个，1,662 行，TODO：0

### features/widgets/（共享 UI）— 🟢 生产就绪

- 文件：34 个，3,944 行，TODO：0

---

## n42appv2 关键风险汇总

### P0 — 发布前必须修复

| # | 问题 | 位置 | 状态 |
|---|------|------|------|
| 1 | Groq API Key 硬编码在源码中，编译进二进制可被反编译提取 | `lib/core/config/api_keys_config.dart:144` | ✅ 已修复 |
| 2 | Mining WebSocket 默认使用明文 `ws://` + 裸 IP | `app_config.dart:147`, `mining_api.dart:16` | ✅ 已修复 |
| 3 | profile 模块所有功能按钮为空方法，用户点击无反应 | `lib/features/profile/pages/profile_home_page_widgets.dart` | ✅ 已修复 |

### P1 — 重要但不阻塞发布

| # | 问题 | 位置 | 状态 |
|---|------|------|------|
| 4 | 12 条链的 TransferHandler 返回 `notYetMigrated`（旧路径仍可用但架构分裂） | `wallet/api/transfer/handlers/` | 🔄 独立排期 |
| 5 | `wallet_service_impl.getBalance()` 返回占位数据 | `wallet_service_impl.dart:187` | ✅ 已修复 |
| 6 | `refreshCoin()` 空实现 | `wallet_providers.dart:422` | ✅ 已修复 |
| 7 | loyalty API 异常时 fallback 到 mock 数据 | `loyalty_api.dart` | ✅ 已修复 |
| 8 | airdrop trending 失败返回硬编码项目数据 | `airdrop_api.dart` | ✅ 已修复 |
| 9 | AA 签名恢复 throw UnimplementedError | `signature_builder.dart:138` | ✅ 已修复 |
| 10 | 测试环境 API URL 使用裸 IP + http:// | `app_config.dart` | ✅ 已修复 |

### P2 — 代码质量

| # | 问题 | 位置 | 状态 |
|---|------|------|------|
| 11 | 11 处空 `catch {}` 块 | 全库分散 | ✅ 已修复 |
| 12 | 428 次 debugPrint 调用 | 全库分散 | ✅ Top 10 文件已加 kDebugMode 守卫 |
| 13 | 10 处 i18n 硬编码英文 | `market_coin_info_sections.dart` | ✅ 已修复 |
| 14 | mining_v1/v2 debug 日志共 49 次 | mining 模块 | ✅ 已加 kDebugMode 守卫 |

### 审计后新增修复

| # | 问题 | 修复 |
|---|------|------|
| 15 | Mining V2 闪退：新 SDK 移除 `genBlockVerifyResult()`，`MyWebSocketListener` 调用崩溃 | `connectWebSocket` → `runMining()`（使用 `Api.runClient`）；新增 `MiningStopClient` 支持暂停 |
| 16 | AA `signature_builder.dart` `bytesToInt` 返回负数 BigInt 导致 ecRecover 断言失败 | `bytesToInt` → `bytesToUnsignedInt` |
| 17 | `wallet_service_impl.getBalance()` 使用 `wallet.chainType`（总是 'multi'）作为 blockchainType | 改为从 `chainUrlMap[coinType]['baseInfo']['blockchainType']` 查找 |
| 18 | 启动屏英文标语同时显示中文副标题，违反单语设计 | 移除 subText 混排；13 种语言各自独立展示 |

---

## n42appv2 测试覆盖

| 状态 | 模块 |
|------|------|
| ✅ 有测试 | core/network, core/security, wallet models/providers, AA, wallet_connect, browser, staking, mining, bridge, hardware_wallet, login, airdrop |
| ❌ 无测试 | profile, notification, settings, splash, earn, loyalty（仅 1 个） |

126 个测试文件（+6 新增）/ 907 个源文件 ≈ **14% 覆盖率**。新增 82 个测试覆盖 AA 签名/部署、AppConfig、市场 i18n、Loyalty API、钱包余额查询。

---

---

# 第二部分：n42_chat 聊天插件

**代码规模：** 550 个 `.dart` 文件，约 170,928 行

## 全局指标

| 指标 | 数值 |
|------|------|
| 总 `.dart` 文件数 | 550 |
| TODO/FIXME/HACK 总数 | 43 |
| `debugPrint`/`print()` 调用 | 1,736 |
| `UnimplementedError` 抛出 | 8 |
| 测试文件数 | 186 |
| 测试代码行数 | 56,820 |

---

## 各模块评级

### core/（62 文件，~16,100 行）— 🟡 基本就绪

**亮点：** theme、constants、extensions 干净完整

**关键问题：**

| # | 问题 | 位置 |
|---|------|------|
| 1 | `app_router.dart` 所有 14 条路由均渲染 `_PlaceholderPage`，路由守卫（auth guard）被注释掉 | `core/router/app_router.dart` |
| 2 | `injection.dart:579` Points API token 获取返回 `null`（永远无法认证） | `core/di/injection.dart:579` |
| 3 | `injection.dart:748` `_registerUseCases()` 方法体为空 | `core/di/injection.dart:748` |
| 4 | `auth_methods_service.dart` Email OTP 使用 `Future.delayed` 返回假数据 | `core/services/auth_methods_service.dart` |
| 5 | debugPrint 245 次，无 `kDebugMode` 保护 | core/ 全局 |

### data/（65 文件，~25,200 行）— 🟡 基本就绪

**亮点：** Matrix 集成层完整（23+ 文件覆盖 auth、rooms、groups、contacts、messages、media、moments、stories、spaces、search），错误处理 161 try / 158 catch，覆盖充分

**关键问题：**

| # | 问题 | 位置 |
|---|------|------|
| 1 | `matrix_search_datasource.dart:239-250` 搜索历史三个方法全部空实现 | `data/datasources/matrix/` |
| 2 | `snapshot_hub_datasource.dart:171` `_signMessage()` throw UnimplementedError，治理投票完全不可用 | `data/datasources/governance/` |
| 3 | `sticker_repository_impl.dart:38-41` 贴纸商店返回硬编码 sample 数据 | `data/repositories/` |
| 4 | `governance_repository_impl.dart:89` `getVotingPower()` 始终返回 0 | `data/repositories/` |
| 5 | 36 处 `return null;` / `return [];`，部分是 stub | 全局 |

- **测试：** 仅 `transfer_repository_impl_test` 和 `search_repository_impl_test`，核心的 Conversation/Message/Group/Moment Repository 零测试覆盖

### domain/（65 文件，~11,400 行）— 🟢 生产就绪

- 纯契约层，42 个 entity + 20 个 repository 接口，类型完善
- 测试：40+ entity 测试文件，覆盖优秀

### integration/（7 文件，~1,529 行）— 🟡 基本就绪

- Bridge 平台注册完整（16 个 Mautrix 桥平台）
- **问题：** `MockWalletBridge` 在 `lib/src/`（生产代码）而非 `test/`，含硬编码假地址和余额

### presentation/（324 文件，~109,600 行）— 🟠 需要改进

**最大模块，问题分散。**

| # | 问题 | 位置 |
|---|------|------|
| 1 | `discover_page.dart` 视频/直播/音乐/附近/小程序 全部 disabled TODO | `pages/discover/discover_page.dart` |
| 2 | `call_dialog.dart` 6 个控制按钮（静音/扬声器/摄像头/挂断）全是 no-op | `pages/chat/call_dialog.dart` |
| 3 | `create_moment_page.dart:430-438` 位置选择返回硬编码北京坐标 | `pages/moment/create_moment_page.dart` |
| 4 | `chat_page.dart:855` Bot 设置导航未接线 | `pages/chat/chat_page.dart` |
| 5 | `chat_page_more_features.dart:511,517` 优惠券/礼物发送为 TODO | `pages/chat/` |
| 6 | `conversation_list_page.dart:368` Story 链接 DM 创建为空 return | `pages/conversation/` |
| 7 | `group_members_page.dart:243` 从群成员创建 DM 未实现 | `pages/group/` |
| 8 | debugPrint 556 次（全模块最高） | 全局 |
| 9 | 2,461 处 `l10n?.key ?? 'English fallback'`（翻译缺失静默回退） | 全局 |

- **Bloc 层（79 文件）：** 结构良好，测试覆盖好
- **Widget/Page 测试：** 仅 7 个测试覆盖 169 个页面

### services/（9 文件，~5,150 行）— 🟠 需要改进

| # | 问题 | 位置 |
|---|------|------|
| 1 | `livekit_service.dart:534-542` 录音功能 `startRecording()` 直接返回 false | `services/voip/` |
| 2 | `webrtc_service.dart` 单文件 92 次 debugPrint | `services/voip/` |
| 3 | Email OTP 流程为假数据（Future.delayed + 硬编码 session token） | `services/auth/` |

### n42_chat.dart 公共 API 入口（1,474 行）— 🟠 需要改进

**关键 stub：**

```
routes()              → 返回 []（插件无法嵌入宿主 App 路由）
unreadCountStream     → 返回 Stream.empty()（未读角标永远不更新）
createDirectMessage() → 返回 ''（DM 创建不工作）
createGroup()         → 返回 ''（群聊创建不工作）
login/logout          → throw UnimplementedError（已文档化，可接受）
```

### l10n/ 本地化 — 🟡 基本就绪

- 14 种语言，英文基准 2,718 keys
- **非英/中语言缺失约 25-30% 的 key**（~830 条），用户将看到英文回退
- 中文 2,900 keys（比英文多，可能有多余 key）

### test/ 测试覆盖 — 🟡 基本就绪

| 领域 | 文件数 | 质量 |
|------|--------|------|
| Bloc 单元测试 | 64 | 高 — mocktail + bloc_test |
| Entity 单元测试 | 40+ | 高 — 行为覆盖全面 |
| Service 单元测试 | 15 | 中等 |
| Repository 测试 | 4 | 低 — 核心 Repo 未测试 |
| Datasource 测试 | 5 | 低 — Matrix datasource 零覆盖 |
| Widget/Page 测试 | 7 | 极低（169 页面仅 7 个测试） |

---

## n42_chat 关键风险汇总

### P0 — 集成阻塞

| # | 问题 | 位置 |
|---|------|------|
| 1 | `N42Chat.routes()` 返回空列表，14 条路由均为 PlaceholderPage | `n42_chat.dart:833`, `app_router.dart` |
| 2 | `N42Chat.unreadCountStream` 返回空 Stream | `n42_chat.dart:930` |
| 3 | `createDirectMessage()` 和 `createGroup()` 返回空字符串 | `n42_chat.dart:1015,1030` |
| 4 | Email OTP 认证为假数据 | `auth_methods_service.dart:605,632` |
| 5 | 治理投票 `_signMessage()` throw UnimplementedError | `snapshot_hub_datasource.dart:171` |
| 6 | 1,736 次 debugPrint 无 kDebugMode 保护（泄露用户 ID、房间 ID 到设备日志） | 全局 |
| 7 | `MockWalletBridge` 在生产代码中（含假地址假余额） | `integration/wallet_bridge.dart:281` |

### P1 — 功能缺失

| # | 问题 | 位置 |
|---|------|------|
| 8 | Discover 标签页大部分功能 disabled | `discover_page.dart` |
| 9 | 通话控制按钮全是 no-op | `call_dialog.dart` |
| 10 | 搜索历史不持久化 | `matrix_search_datasource.dart` |
| 11 | 贴纸商店返回假数据 | `sticker_repository_impl.dart` |
| 12 | 位置选择硬编码北京坐标 | `create_moment_page.dart` |
| 13 | `_registerUseCases()` 空方法体 | `injection.dart:748` |
| 14 | LiveKit 录音返回 false | `livekit_service.dart` |

### P2 — 翻译与日志

| # | 问题 |
|---|------|
| 15 | 非英/中语言缺失 ~830 个翻译 key |
| 16 | Auth bloc 中硬编码中文错误信息 |
| 17 | Data 层核心 Repository 零测试覆盖 |

---

---

# 第三部分：综合成熟度总览

## n42appv2 模块总览

| 模块 | 文件数 | 评级 | 关键问题 |
|------|--------|------|----------|
| core/config | 3 | 🔴 未就绪 | API Key 硬编码、明文 WS |
| core/network | 12 | 🟡 基本就绪 | — |
| core/security | 16 | 🟡 基本就绪 | 空 catch |
| core/storage | 3 | 🟢 就绪 | — |
| core/utils | 7 | 🟢 就绪 | — |
| core/api_hub | 14 | 🟡 基本就绪 | debugPrint 偏多 |
| wallet | 441 | 🟠 需改进 | 42 TODO，12 链 handler 未迁移 |
| wallet_connect | 14 | 🟢 就绪 | — |
| bridge | 11 | 🟡 基本就绪 | ERC-721 stub |
| mining_v1 | 37 | 🟠 需改进 | debug 日志过多 |
| mining_v2 | 36 | 🟡 基本就绪 | 已迁移至 runClient；旧依赖 |
| mining | 7 | 🟡 基本就绪 | — |
| browser | 23 | 🟡 基本就绪 | 空 catch |
| hardware_wallet | 19 | 🟡 基本就绪 | — |
| staking | 15 | 🟡 基本就绪 | — |
| loyalty | 14 | 🟠 需改进 | mock fallback |
| airdrop | 10 | 🟠 需改进 | 硬编码 trending |
| home | 43 | 🟡 基本就绪 | — |
| login | 18 | 🟢 就绪 | — |
| settings | 3 | 🟢 就绪 | — |
| splash | 2 | 🟢 就绪 | 13 语言单语标语 |
| profile | 2 | 🔴 未就绪 | 15 TODO 全空壳 |
| notification | 2 | 🟡 基本就绪 | — |
| earn | 6 | 🟡 基本就绪 | — |
| widgets | 34 | 🟢 就绪 | — |

## n42_chat 模块总览

| 模块 | 文件数 | 行数 | 评级 | 关键问题 |
|------|--------|------|------|----------|
| core/ | 62 | 16,122 | 🟡 基本就绪 | 路由全占位、DI useCase 空 |
| data/ | 65 | 25,202 | 🟡 基本就绪 | 治理投票断、搜索历史空、贴纸假数据 |
| domain/ | 65 | 11,385 | 🟢 就绪 | — |
| integration/ | 7 | 1,529 | 🟡 基本就绪 | Mock 在生产代码中 |
| presentation/ | 324 | 109,563 | 🟠 需改进 | 发现页空、通话控制空、位置硬编码 |
| services/ | 9 | 5,150 | 🟠 需改进 | 录音空、OTP 假、debugPrint 过多 |
| n42_chat.dart | 1 | 1,474 | 🟠 需改进 | 4 个公共 API 为 stub |
| l10n/ | 14 | ~13,000 | 🟡 基本就绪 | 5 语言缺 ~830 key |
| test/ | 186 | 56,820 | 🟡 基本就绪 | data 层零覆盖 |

## 优先修复建议

### 立即修复（发布前）

1. ~~移除 `api_keys_config.dart` 中硬编码的 API Key~~ ✅ 已完成
2. ~~Mining WS/HTTP 端点启用 TLS~~ ✅ 已统一至 AppConfig
3. 接线 `N42Chat.routes()`、`unreadCountStream`、`createDirectMessage()`、`createGroup()`
4. 清理 `MockWalletBridge` 从生产代码移至 test/
5. ~~为 debugPrint 添加 `kDebugMode` 保护~~ ✅ Top 10 文件已完成

### 短期改进（1-2 周）

6. ~~profile 模块接线各功能页导航~~ ✅ 已完成
7. ~~loyalty/airdrop mock fallback 改为显示错误提示~~ ✅ 已完成
8. 补充 data 层核心 Repository 测试
9. 完成非英/中语言翻译补全
10. 通话控制按钮接线 VoIP 服务

### 中期改进（1 月内）

11. 完成 12 条链 TransferHandler 迁移
12. ~~AA 模块 ECDSA recovery 接库~~ ✅ 已用 web3dart 实现
13. 治理投票 signTypedData 接钱包
14. Discover 标签页功能上线或移除入口
15. 补充 Widget/Page 层测试
