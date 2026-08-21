# N42 Live · 直播客户端架构文档

> 面向维护者与接手工程师。本文件说明直播 App 客户端（含弹幕、预测市场）的架构、设计、
> 数据流、文件职责、预期行为、服务端要求与接口、构建/测试方式、以及已知坑与待办。
>
> 相关文档：链上预测合约对接规格见同目录 [`prediction/CHAIN_INTEGRATION.md`](prediction/CHAIN_INTEGRATION.md)。

---

## 1. 概述

N42 Live 是 N42 钱包仓库内的一个**手机直播客户端**，形态参考抖音竖屏直播间：

- **一个 App 两种角色**：① 用本机摄像头**开播推流**（单主播）；② 其他用户**纯观看 + 发文字弹幕**。
- 经典**一对多广播**（主播 1，观众 N，观众只发文字不推视频），不是视频会议。
- 叠加 **Polymarket 式预测市场**：主播开预测，观众用（测试）代币买结果份额，主播实时开局按结果结算。
  预测当前用 **Matrix 事件溯源同步**（`MatrixPredictionRepository`，play-money 跨设备一致；详见 §6）。
- **视觉礼物广播**：观众送礼物经 Matrix 事件广播全房（emoji 飞行动画 + "X 送出 Y"），纯视觉无真实价值（详见 §5.3）。
- **复用现有基础设施**：视频复用 `n42_chat` 自部署的 LiveKit（WebRTC SFU），弹幕复用 `n42_chat` 的 Matrix。
- **同仓独立入口**：独立 `lib/main_live.dart` 入口，与主钱包 App 共享 `core/`、主题、l10n；成熟后再合入主 App 底部 tab。

### 开发期运行
```bash
flutter run -t lib/main_live.dart      # 独立启动直播 App
flutter test test/features/live        # 运行测试
flutter analyze lib/features/live      # 静态检查
```

---

## 2. 顶层架构与数据流

```
                       ┌─────────────────────── N42 Live 客户端 ───────────────────────┐
                       │                                                                │
[主播手机] camera/mic ──┤ livekit_client(发布) ─┐                  ┌─ livekit_client(订阅) ├── [观众手机 ×N]
                       │                       ▼                  ▲                     │
                       │            自部署 LiveKit SFU  wss://livekit.m.si46.world      │
                       │            JWT 端点 https://m.si46.world/livekit/jwt           │
                       │            （经 /.well-known/matrix/client MSC4143 自动发现）   │
                       │                                                                │
[弹幕/进场/列表] ───────┤ n42_chat(Matrix) ── homeserver m.si46.world                   │
                       │   每个直播间 = 一个 Matrix room；观众匿名注册进房              │
                       │   watchMessages / sendTextMessage / watchMemberJoinEvents      │
                       │                                                                │
[预测市场] ─────────────┤ PredictionRepository（接口）                                   │
                       │   ├─ MockPredictionRepository（内存 LMSR AMM，当前默认）        │
                       │   └─ ChainPredictionRepository（链上托管合约，待接，另一 repo） │
                       └────────────────────────────────────────────────────────────────┘
```

**核心设计点**：一个 **Matrix room 同时承载视频与弹幕**——LiveKit 房间名由 Matrix room id 推导
（`buildLiveKitRoomName`），二者天然配对，无需额外的房间映射服务。

---

## 3. 分层与目录结构

```
lib/main_live.dart                        # 独立入口：Firebase → ProviderContainer → 启动 LiveApp
lib/features/live/
├── ARCHITECTURE.md                       # 本文件
├── live.dart                             # 模块对外导出 barrel
├── presentation/
│   ├── pages/
│   │   ├── live_app.dart                 # MaterialApp.router（复用 ThemeAdapter / l10n / go_router）
│   │   ├── live_home_page.dart           # 直播广场（输入 roomId 进房 / 加载列表 / 开播入口）
│   │   ├── live_room_page.dart           # 观看端直播间（视频铺底 + 各叠加层）
│   │   └── go_live_page.dart             # 开播端（权限→建房→发布→控制）
│   ├── router/live_router.dart           # go_router 子路由 /live、/live/room/:id、/live/go
│   └── widgets/
│       ├── live_player_view.dart         # LiveKit VideoTrackRenderer 渲染层
│       ├── danmu_overlay.dart            # 透明弹幕滚动层（自动滚到底）
│       ├── danmu_input_bar.dart          # "说点什么…"输入（发送节流）
│       ├── live_top_bar.dart             # 顶部：主播头像/名/关注/在线人数/关闭
│       ├── live_side_actions.dart        # 右侧竖排：点赞/礼物/分享
│       ├── like_burst.dart               # 双击点赞飘心动画（controller + layer）
│       └── enter_room_banner.dart        # "xxx 来了"进场横幅
├── services/
│   ├── live_bootstrap.dart               # 初始化 + 匿名登录（single-flight 单飞）
│   ├── live_video_service.dart           # LiveKit 加入/发布/订阅（唯一耦合 n42_chat src 的文件）
│   └── live_chat_service.dart            # Matrix 弹幕：进房/收发/进场流/房间列表
└── prediction/                           # 预测市场子模块（详见 §6）
    ├── CHAIN_INTEGRATION.md
    ├── domain/{prediction_market.dart, prediction_repository.dart}
    ├── data/mock_prediction_repository.dart
    ├── providers/prediction_providers.dart
    └── widgets/{prediction_card, trade_sheet, create_prediction_sheet, resolve_prediction_sheet}.dart

test/features/live/prediction/mock_prediction_repository_test.dart   # 结算单元测试（11 例）
```

**架构约定**：沿用主 App 的 feature 分层（presentation / services / domain-data）与 Riverpod 状态管理。
页面多为 `StatefulWidget`；需要 Riverpod 的子组件（预测相关）用 `ConsumerWidget/ConsumerStatefulWidget`，
依赖 `main_live.dart` 顶层的 `UncontrolledProviderScope(liveProviderContainer)`。

---

## 4. 视频子系统（复用 LiveKit）

### 4.1 设计
- **不新建流媒体服务器**。直接复用 `n42_chat` 自部署的 LiveKit SFU（WebRTC），它原用于 n42_chat 的视频通话。
- `livekit_client`/`flutter_webrtc` 原为 `n42_chat` 的传递依赖，本模块将 `livekit_client` 提升为**直接依赖**显式使用。
- 主播以 `enableVideo=true` 发布摄像头/麦克风轨道；观众以 `enableVideo=false` 仅订阅，延迟 <500ms。

### 4.2 关键实现（`live_video_service.dart`）
该文件是**唯一对 `n42_chat` 内部实现（`src/`）的耦合点**，集中管理 implementation import：
- `package:n42_chat/src/services/voip/livekit_service.dart` —— `LiveKitService`（经 `N42Chat.callManager.liveKitService` 暴露）。
- `package:n42_chat/src/core/utils/livekit_call_utils.dart` —— 房间名和 MatrixRTC 响应解析。
- `package:n42_chat/src/services/voip/matrix_rtc_token_service.dart` —— Matrix OpenID + `/sfu/get` 换票及受控旧服务回退。
- `package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart` —— `MatrixClientManager`（取 Matrix `Client` 换 LiveKit token）。

加入流程 `_join(matrixRoomId, broadcaster)`：
1. `ensureLiveChatReady()` + `ensureAnonymousLogin()`（见 §7）。
2. `N42Chat.initializeCallManager()`（触发 `/.well-known` 的 LiveKit 配置发现，幂等）。
3. 校验 `callManager.config.hasLiveKitConfig`，取 `liveKitService`。
4. 取 Matrix `Client`（`GetIt.instance<MatrixClientManager>().client`）拿 `userID`/`accessToken`。
5. `_fetchToken(...)`：直播角色请求优先走可限制 `broadcaster/viewer`
   权限的旧 N42 Bearer-token 协议。若服务端明确返回 301/308/404/405/410
   表示旧路由已迁移，才向 Matrix homeserver 获取短期 OpenID token，再向
   `{N42Chat.liveKitJwtUrl}/sfu/get` POST Matrix room ID、OpenID 和 device ID；使用响应的
   `url/jwt` 连接。401/403、网络异常或非法响应均不会触发回退。
6. `liveKitService.joinMeeting(roomName, token, enableVideo, enableAudio)`。
   > 注意：**绕开 `CallManager.joinMeeting`**——后者成功后会强制导航到 n42_chat 自带的 `GroupCallScreen`（网格通话 UI），
   > 不符合"主播全屏 + 弹幕叠加"的需求；故直接驱动底层 `LiveKitService`，UI 自绘。

对外只暴露 UI 友好的访问器（隐藏 n42_chat src 类型）：`listenable`（`Listenable`）、`primaryVideoTrack`、
`localVideoTrack`、`participantCount`、`isMuted`、`switchCamera()`、`toggleMicrophone()`、`leave()`、`dispose()`。

**取消安全**：`_join()` 在权限申请/网络换 token/`joinMeeting` 等每个耗时 await 后都检查内部 `_disposed`
标志；页面若在这些阶段被销毁（如权限弹窗时用户提前退出），join 完成后会检测到该标志并立即清理刚建立
的连接、不赋给 `_service`——否则会孤立一条无人再调用 `leave()` 的会话（主播端场景下即摄像头/麦克风
被永久占用，只能杀进程才能停止；这是曾经的真实 bug）。页面应调用 `dispose()`（非 `leave()`）做终态
退出：它同时设置 `_disposed=true` 并离会，幂等、可安全重复调用。`leave()` 现也对 `leaveMeeting()` 做
异常兜底（失败静默，对齐 `LiveChatService.leave` 的处理）。

`live_player_view.dart` 用 `ListenableBuilder` 监听会话，渲染 `VideoTrackRenderer(track, fit: cover)`；
`showLocal` 区分主播自预览（本地轨道）与观众（远端主播轨道）。

---

## 5. 弹幕子系统（复用 Matrix）

### 5.1 设计
- 每个直播间 = 一个 **Matrix room**；弹幕走该 room 的 timeline。
- `n42_chat` 的仓库接口**未从公共入口导出**，但其内部 `getIt` 即全局 `GetIt.instance`，故经
  `GetIt.instance<IMessageRepository>()` 访问（接口类型经 implementation import 引入，集中于 `live_chat_service.dart`）。
- `n42_chat` **无原生游客只读模式**——任何读写都需 Matrix uid，故无钱包观众走 `registerAnonymously` 匿名建号。

### 5.2 关键实现（`live_chat_service.dart`）
- `join(roomId)`：`ensureLiveChatReady` + `ensureAnonymousLogin` + `IConversationRepository.joinConversation`。
- `watchDanmu(roomId) → Stream<List<LiveDanmu>>`：`IMessageRepository.watchMessages` 过滤文本、按时间升序、
  取最近 100 条（`maxDanmu`，避免高频弹幕整列表重建）。
- `send(roomId, text)`：`IMessageRepository.sendTextMessage`。
- `watchEnter(roomId) → Stream<String>`：`IGroupRepository.watchMemberJoinEvents`（进场横幅）。
- `discoverPublicLiveRooms()`：查询 Matrix 公共目录，筛选专用 `n42.live.directory:v1:<ts>` topic 心跳，
  使未加入直播房的观众也能发现正在播的公开房；`watchRooms()` 保留为已加入房间的本地缓存/兼容入口。
  匿名账户仅加入直播间，故已加入会话即直播间）。

UI：`danmu_overlay`（半透明滚动、自动到底）、`danmu_input_bar`（发送节流 `minInterval` 默认 800ms 防刷屏）、
`enter_room_banner`（取 Matrix uid 本地名，淡入淡出 3s）。

### 5.3 直播事件通道（礼物 / 预测同步复用）
弹幕用纯文本 timeline；**结构化事件**（礼物、预测同步）复用同一 timeline，载荷为
`n42live:<JSON>` 的文本消息（哨兵前缀），弹幕流过滤掉它们。`LiveChatService` 暴露
`sendEvent` / `watchEvents`（有序日志，供预测重放）/ `watchNewEvents`（去重、首帧不补历史，供礼物一次性动画）。
- **礼物（TikTok 式内部金币经济，`gift_economy.dart`）**：`{t:'gift', g:<giftId>}` → 全房 `GiftOverlay`
  播 emoji 飞行 + "X 送出 Y"。金币计价由共享目录 `gift_catalog` 的 `coinPrice` **权威推导**（不信任事件
  载荷价格，防伪造低价）；**金币余额是全局钱包**（跨直播间统一，不按房间隔离）= 初始额 + 本地充值 −
  本人在**全部已知房间**内经重放判定为有效的送礼花费；**主播收益**（某房间）= 该房间内被判定有效的
  礼物金额总和。
  - **防伪造边界**：任何人都能绕过送礼 UI 直接广播 gift 事件（Matrix 无法阻止已加入房间者广播消息），
    但所有客户端对同一份事件日志跑同一套**确定性重放**——按发送者、按时间线顺序，运行余额从
    `initialCoins` 起逐笔扣减，超出余额的礼物一律判**无效**：不计入任何人的收益/花费统计，也不会触发
    `GiftOverlay` 动画。跨端一致，无需服务端仲裁。
  - **未知 giftId 一律忽略**（不计价、不播动画），而非回退固定价格——回退价一旦与目录后续新增的真实
    价格不同，"认识"与"不认识"该礼物的客户端会对同一批事件算出不同收益，破坏跨版本一致性；忽略则
    只会让旧客户端的数字暂时偏低，绝不会算错。
  - 金币为 play-money；`recharge` 现为本地展示性 mock（只影响本端显示的余额数字，不参与跨端可验证的
    重放校验——私有充值天然无法被他人验证，是"无权威账本"架构的固有限制）；真实代币充值/提现是后续
    接缝（接钱包 sender 后替换）。
- **直播判活（isLive）**：主播状态写入**自定义 Matrix state event**（`n42.live.status`，非 `m.room.topic`）
  ——避免与房间真实公告字段冲突（此前复用 topic 时，若主播用聊天原生"群信息"页编辑话题会误摧毁判活
  标记）；内容 `{'live': bool, 'ts': <毫秒>}`，30s 心跳 + 90s TTL，停播/崩溃后自动失活。读写走
  `Client.getRoomById`/`setRoomStateWithKey`（与 `topic` 同样存于本地已同步的 `room.states`，零额外
  订阅成本）。观众端 `watchIsRoomLive` 为**持续订阅**（非一次性判定）：双路触发——房间任意状态变化
  （含心跳本身）+ 5s 定期兜底重算（应对房间彻底安静、无后续事件时 TTL 到期仍需自然生效）；直播列表
  只列在播房、观众进死房或主播中途下播都显示"直播已结束"，且能随后自愈刷新。

---

## 6. 预测市场子系统

### 6.1 设计决策
| 维度 | 决策 |
|---|---|
| 市场模型 | **Polymarket 式份额交易（AMM）**。客户端 mock 用 **LMSR**；价格=隐含概率，各结果价格之和≈1 |
| 信任模型 | **链上托管合约 + 主播开奖**：资金锁合约，主播（resolver）只能裁定结果、**不能卷款** |
| 交付范围 | 客户端 UX + `PredictionRepository` 接口（stub）；真实合约/后端在另一个 repo |
| 链/代币 | 先测试网 + 测试 ERC20（mock 用 `tUSDC`） |

### 6.2 领域模型（`prediction/domain/prediction_market.dart`）
- `PredictionMarket`：id / roomId / question / outcomes / status / collateral / createdAt / closesAt / resolvedOutcomeId / totalVolume。
- `MarketOutcome`：id / label / price(0..1)。
- `MarketStatus`：open / closed / resolved / cancelled。
- `UserPosition`：marketId / shares(outcomeId→份额) / claimed。
- `TradeQuote`：outcomeId / collateralIn / shares / avgPrice / priceAfter。
- `CollateralToken`：symbol / decimals。

> 金额在 MVP stub 用 `double`（人类可读单位）以简化 AMM；接真实合约时 `ChainPredictionRepository` 改用
> **base-unit `BigInt` + decimals**（实体不变，仅内部表示）。

### 6.3 仓库接口（`prediction/domain/prediction_repository.dart`）
```
watchBalance() / watchMarkets(roomId) / watchMarket(id) / watchPosition(id)   // 实时流
createMarket / closeMarket / resolveMarket / cancelMarket                      // 主播(resolver)
quoteBuy / buy / sell / redeem                                                 // 观众交易
collateral                                                                     // 结算代币
```

### 6.4 Mock 实现（`prediction/data/mock_prediction_repository.dart`）
- 内存 **LMSR**（Logarithmic Market Scoring Rule）：`price_i = softmax(q_i/b)`，成本 `C(q)=b·logsumexp(q/b)`；
  买入按预算二分求份额，卖出退成本差。`b=50`。
- 开奖：赢家份额 **1:1** 赎回结算代币，输家归零；取消退**净投入本金**。测试代币初始 1000 `tUSDC`。
- 单进程内存态（主播创建/开奖与观众下注共享），适合单机演示。流推送用一个广播 tick + "先发当前快照再随 tick 重算"。
- **LMSR 行为注记（产品需知）**：它是份额边际定价，"投钱多 ≠ 价格高"——在便宜的长尾结果上等额买入会换到更多份额、
  价格抬升更猛，与平注池(parimutuel)直觉不同。若要"押注多者即热门"的直觉赔率，需改 parimutuel 模型。

### 6.4b Matrix 事件溯源实现（`data/prediction_replay.dart` + `matrix_prediction_repository.dart`，当前默认）
跨设备同步靠**事件溯源**：每个动作（create/buy/sell/resolve/cancel/close）作为一条事件经直播间
Matrix room 的 timeline 广播；各端用纯函数引擎 `PredictionReplay` 按**同一时间线顺序**重放进同一套
LMSR 状态机，得到一致的价格/持仓/结算（`prediction_replay_test.dart` 覆盖确定性/多用户/结算/
过期/守护/resolver 鉴权）。
- `MatrixPredictionRepository`：per-room 常驻订阅维护 `_latest` 重放态，`_changes` tick 驱动所有 `watch*`；
  `marketId` 内嵌 `roomId`（`~` 分隔）以便仅有 marketId 时反解房间；余额 = 初始 + 各房 `tradeDelta(我)` +
  本地已赎回；`redeem` 仅本端入账不广播，`claimed` 为本地视角。
- **resolver 鉴权**：`_MarketState.resolverId` 取自建市事件的 `sender`；重放引擎对 resolve/cancel/close
  这三个终结性动作校验 `e.sender == resolverId`，非建市者伪造的同类事件会被**所有客户端一致丢弃**（不
  改变状态）——堵住"任意用户伪造开奖结果让自己赢"这一此前存在的完整性漏洞。`MatrixPredictionRepository`
  在发送前也做同样的客户端预检（立即报 `PredictionError.notResolver`，不浪费网络往返），并对非法状态
  转移（如对已取消市场开奖）显式抛 `invalidState`（对齐 mock 行为，而非静默丢弃让用户以为操作生效了）；
  真正的强制边界始终在重放层，预检只是即时反馈。
- **边界与限制**：买/卖事件内含 `minShares`/`minCollateral`，重放层会按最终时间线状态强制执行滑点保护；
  非法结果、非有限金额和异常建市载荷会被丢弃。每个用户在每个直播房有 `initialBalance` 的试玩额度，
  超额买单会被所有客户端一致拒绝。它不是跨房账户余额、更不是链上资产；真实资金与统一余额仍须
  `ChainPredictionRepository` 及托管合约。持续订阅归零时会释放对应房间的重放状态。
  **Matrix 同步链路需两机真机验证**（Codex T14 已验自动化通过，设备闸门待解除）。

### 6.5 Providers（`prediction/providers/prediction_providers.dart`）
`predictionRepositoryProvider`（单例，**当前返回 `MatrixPredictionRepository`**——经 Matrix 房间 timeline
事件溯源同步，play-money 跨设备一致；`MockPredictionRepository` 仅单机/单测用；接链时改返回
`ChainPredictionRepository`）、
`predictionBalanceProvider`、`roomMarketsProvider.family`、`marketProvider.family`、`positionProvider.family`。
> Riverpod 取值用 `.asData?.value`（本仓库 Riverpod 版本无 `valueOrNull`）。

### 6.6 UI
- 观众端 `prediction_card`（嵌 `live_room_page` 顶部）：问题 / 各结果价格% / **实时倒计时（到点本地停盘，不依赖后端再推送）** /
  我的持仓 / 开奖后赎回。点结果打开 `trade_sheet`（选结果、输金额、实时报价份额/均价/成交后价、买入含 1% 滑点保护、卖出）。
- 主播端 `go_live_page` 的"开预测/开奖"按钮（`_BroadcasterPredictionButton`，按是否存在活跃市场切换）：
  `create_prediction_sheet`（问题+结果项≥2+可选截止时长）、`resolve_prediction_sheet`（停盘 / 选赢家开奖含二次确认 / 取消退款）。

---

## 7. 身份与登录（`live_bootstrap.dart`）

- `ensureLiveChatReady()`：幂等初始化 `N42Chat`（homeserver `m.si46.world`，**关闭 E2E 加密**——公开直播间无需，
  且简化匿名观众接入；**不接推送**）。
- `ensureAnonymousLogin()`：无钱包观众以匿名身份 `registerAnonymously` 登录。
- **两者均加 single-flight 单飞**：视频与弹幕会并发触发初始化/登录，若不共享同一进行中的 Future，会重复匿名注册
  产生多个账户/身份（曾是真实 bug，已修）；失败后允许下次重试。

> 生产中真实下注身份应为**钱包地址**（`ChainPredictionRepository` 对接），匿名 Matrix 身份仅用于弹幕/视频阶段。

---

## 8. 预期行为（验收口径）

| 场景 | 预期 |
|---|---|
| 观众进房 | 输入/点选 roomId → 全屏播放主播画面（<1s）+ 实时弹幕 + 在线人数；无钱包自动匿名进房 |
| 发弹幕 | 输入发送（800ms 节流）→ 本端与其他端实时显示；新成员触发"xxx 来了" |
| 点赞 | 双击屏幕或点右侧♥ → 彩色爱心上浮淡出（本地即时反馈） |
| 开播 | 授权摄像头/麦克风 → 创建 Matrix 房 → 发布音视频；可前后摄/静音切换、复制房号分享、同屏看弹幕 |
| 开预测 | 主播填问题+结果+可选截止 → 观众端卡片实时出现；倒计时到点显示"待开奖"并禁止下注 |
| 下注 | 选结果输金额 → 实时报价 → 买入扣余额、价格随成交移动；可卖出 |
| 开奖结算 | 主播选赢家 → 赢家份额 1:1 赎回 tUSDC、输家归零；取消则退本金 |

资金结算正确性由 `test/features/live/prediction/mock_prediction_repository_test.dart`（11 例）背书。

---

## 9. 服务端要求

### 9.1 Matrix Homeserver（`m.si46.world`，Tuwunel）
- 开启**匿名注册**（`registerAnonymously`）。
- 直播间为**非加密公开房**（客户端建房时 `enableEncryption=false`）。
- 现有能力即可：room 创建/加入、timeline 收发、成员事件。

### 9.2 LiveKit SFU + JWT 端点
- SFU：`wss://livekit.m.si46.world`；JWT 签发：`https://m.si46.world/livekit/jwt`。
- 经 `/.well-known/matrix/client` 的 `org.matrix.msc4143.rtc_foci`（type=livekit）或 `n42.livekit` 暴露，供客户端自动发现。
- 兼容的 legacy JWT 请求（Bearer Matrix accessToken）体含
  `room/identity/name/video/role/conversation_id`，需返回含 `token` 的 JSON。
  生产环境当前可仅部署 MatrixRTC `/sfu/get`，客户端会在 legacy 路由
  明确不存在时改用短期 OpenID 换票。
- 🔴 **上线前必做（安全）**：JWT 服务必须按 `role` 签发 grant，并验证 broadcaster 是该直播房的授权创建者：
  主播 `canPublish=true`，观众 `canPublish=false`。客户端已传 `role`；此仓库没有该外部 JWT 服务的部署源码，
  必须在服务端完成并以 viewer token 实测拒绝发布，否则观众仍可能抢推流。

### 9.3 预测市场托管合约（测试网，另一个 repo）
详见 [`prediction/CHAIN_INTEGRATION.md`](prediction/CHAIN_INTEGRATION.md)：
- `PredictionMarket` 托管合约：`createMarket / buy / sell / closeMarket / resolveMarket(仅 resolver) / redeem / cancelMarket`，
  事件 `MarketCreated/Trade/MarketClosed/MarketResolved/MarketCancelled/Redeemed`。
- 资金锁合约，resolver=建市主播地址，只能裁定结果不能转账；建议含开奖争议期 + 多签/预言机兜底。
- 结算用测试 ERC20（tUSDC）。客户端 `ChainPredictionRepository` 经钱包 `sender_factory`（EVM `ChainSender`）发交易、
  经 `chain_api` 读状态/事件，金额改 BigInt base-unit。

### 9.4 直播目录后端（可选，P1）
- 提供 `{matrixRoomId, title, broadcasterId, isLive}` 列表与绑定。
- 可由 LiveKit `on_publish` webhook 触发建/标直播间。当前 MVP 用 Matrix 公共目录 topic 短心跳发现；生产目录应改为
  有签名的服务端记录，避免客户端时钟和公开 state 写权限成为权威来源。

---

## 10. 依赖与平台配置

- 新增直接依赖（`pubspec.yaml`）：`livekit_client: ^2.7.0`、`get_it: ^9.2.1`（`flutter_webrtc` 随 livekit 传递引入）。
- 权限（已具备，因 n42_chat VoIP）：Android `CAMERA`/`RECORD_AUDIO`/`INTERNET`；iOS `NSCameraUsageDescription`/`NSMicrophoneUsageDescription`。
- 复用：`flutter_riverpod`、`go_router`、`permission_handler`、`n42_chat`（git 依赖）。

---

## 11. 已知坑 / 风险 / 待办

**接手必读的坑**
1. **n42_chat 实现导入**：仓库接口/LiveKit 类型未从 `package:n42_chat/n42_chat.dart` 导出，经 implementation import
   访问，全部集中在 `live_video_service.dart` / `live_chat_service.dart` / `live_bootstrap.dart`。n42_chat 升级时优先核这三处。
2. **绕开 CallManager**：视频用底层 `LiveKitService`，勿改回 `CallManager.joinMeeting`（会跳自带通话 UI）。
3. **单例会话**：`CallManager/LiveKitService/VoIPConfig` 为单例，多个 `LiveVideoService` 包裹同一底层会话；
   当前单房可用，做画中画/多房前需加守护。
4. **Riverpod 取值**：用 `.asData?.value`，本版本无 `valueOrNull`。
5. **LMSR 行为**：见 §6.4，"投钱多≠价高"是 AMM 正确行为，非 bug。

**风险/优化**
- 匿名账号增生：每个新观众/列表加载触发 `registerAnonymously`；建议持久化复用一个匿名凭据（n42_chat `restoreSession` 配合）。
- `watchMessages` 全量返回：已截 100 条，规模化可加 throttle。

**以下三项此前列为"较低优先级"，已修复（2026-07-01）**：
- ✅ **`primaryVideoTrack` 主播身份锚定**（`live_video_service.dart`）：原取"第一个有画面的非本地参与者"，
  房间内出现多个发布者（如 §9.2 角色权限尚未落地、观众也能推流）时可能选错/未授权画面。现锚定到
  Matrix `m.room.create` 事件的 `sender`（`_broadcasterId`，房间创建者、homeserver 权威写入、不可变更，
  不依赖本模块自维护状态）；`primaryVideoTrack` 优先精确匹配该身份，匹配不到（如创建事件尚未同步）才
  退回原宽松兜底，不会因锚点缺失导致完全无法显示画面。
- ✅ **`MatrixPredictionRepository` 的 marketId 路由双信任级别**：原展示层信任 `room` 字段、路由信任
  `marketId` 字符串前缀（`_roomIdOf`）两条不同信任级别的判断路径，攻击者可在自己所在房间广播一条
  `marketId` 前缀伪装成其他房间的伪造 create 事件，诱导受害者对无关房间发送交易。现 `PredictionReplay`
  加 `trustedRoomId`（调用方实际物理订阅的房间——Matrix 服务端保证房间隔离，这是唯一真正可信的信号）：
  建市事件的 `marketId` 房间前缀必须与之一致才被接受，不一致则整条 create 事件被拒绝、该市场永不存在
  于任何房间的重放态中（从源头堵住伪造，而非仅在路由/查找时才发现找不到）。`_MarketState.roomId` 也
  改为优先取 `trustedRoomId`（可信）而非事件载荷的 `room` 字段（攻击者可任意设置）。`_roomIdOf` 逻辑
  统一收敛到 `PredictionReplay.roomIdFromMarketId`（单一实现，路由解析与校验用同一函数，不会出现两处
  逻辑不一致）。
- ✅ **预测订阅不逐房释放**：`_subs`/`_latest` 原只在整个仓库 `dispose()`（近似 App 生命周期）时统一清理，
  访问过的房间越多订阅越积越多。现加 `_watcherCounts` 引用计数：`watchMarkets`/`watchMarket`/
  `watchPosition` 用 `try/finally` 在流被取消订阅时调用 `_releaseWatcher`，计数归零才真正取消该房间
  订阅、清理重放态；一次性动作（buy/sell/quoteBuy/createMarket/`_sendAction`）不参与计数，避免被无关
  操作提前释放仍在用的房间。配套把 `roomMarketsProvider`/`marketProvider`/`positionProvider` 改为
  `.autoDispose.family`，使 Riverpod 在无 widget 监听时真正取消订阅（否则 `finally` 永不触发，修复无效）。

**待办（多为出仓/服务端/硬件）**
- 🔴 LiveKit JWT 按 `role` 锁 `canPublish`（§9.2）；MatrixRTC 官方换票
  契约不接收本项目的自定义 `role`，服务端需结合 Matrix 房间权限或扩展
  签发服务完成主播发布限权。
- 🔴 预测真实合约 + `ChainPredictionRepository`（§9.3 / CHAIN_INTEGRATION.md）。
- ✅ T29 已完成两台 iPhone 真机联调：MatrixRTC 视频、直播列表、跨端弹幕、
  礼物、预测下注/开奖/赎回及主动下播判活均已跑通；Android 仍受设备侧
  `INSTALL_FAILED_USER_RESTRICTED` 阻塞。
- 产品决策：AMM(LMSR) vs 平注池(parimutuel)。
- P2：礼物真实充值/提现（需先做"主播绑定钱包地址"）/ 关注社交图 / 内容审核 / LiveKit Egress→HLS-CDN
  大基数 / 合入主 App 底部 tab。

---

## 12. 测试与质量

- 单元测试：`flutter test test/features/live/`（42 例）：
  - `prediction/mock_prediction_repository_test.dart`（15 例，定价归一化、买入推价、quote 一致、买卖对账、
    赢家 1:1 赔付/输家归零、取消退本金、停盘/余额/过期守护、终态状态机守护）。
  - `prediction/prediction_replay_test.dart`（18 例，同上 + 确定性重放、多用户独立、**resolver 鉴权**：
    非建市者伪造 resolve/cancel/close 被拒、建市者本人正常生效；**房间归属鉴权**：`roomIdFromMarketId`
    解析、`trustedRoomId` 一致时建市生效、marketId 伪装成其他房间的 create 事件被拒、`trustedRoomId`
    为 null 时跳过校验）。
  - `gift_tally_test.dart`（9 例，礼物确定性重放：收益/花费聚合、跨房间统一余额、**超额送礼被判无效**、
    不同发送者互不影响、未知礼物忽略、确定性）。
- 静态检查：`flutter analyze lib/features/live`（应零问题）；提交前 `dart format lib/features/live`。
- 真机验证：两台设备分别以主播（publisher token）/观众（viewer token）进同一 roomId，核验视频<1s、弹幕实时、
  下注→开奖→赎回闭环；观众用 viewer token 尝试推流应被拒（验证 §9.2 角色权限，待服务端实现）。

---

## 13. 提交规范

见仓库根 `CLAUDE.md`：Conventional Commits；作者模板
`GIT_COMMITTER_NAME="Nyxen" GIT_COMMITTER_EMAIL="40690755+MiraWells@users.noreply.github.com" --author="Nyxen <...>"`；
提交信息不含 "Claude"。本功能开发分支：`feat/live-prediction-market`。
