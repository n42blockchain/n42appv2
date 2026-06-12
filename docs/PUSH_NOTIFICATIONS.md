# 消息通知架构

宿主（n42appv2）与 n42_chat 插件共同承担推送展示。本文档是两仓库通知链路的
唯一全景图；改动任何一条路径前先读「不变量」一节。

相关代码：
- 宿主：`lib/features/utils/app_push_utils.dart`（+ `app_push_navigation.dart`、
  `chat_push_routing.dart`、`chat_tap_dedup.dart`）
- n42_chat：`lib/src/core/notifications/firebase_push_service.dart`、
  `push_dedup_store.dart`

## 全景

```
                Sygnal 推送网关 (Matrix)            宿主后端
                       │                              │
                  FCM / APNs ◄────────────────────────┘
                       │
     ┌─────────────────┼──────────────────────┐
     │ 前台 onMessage   │ 后台 onBackgroundMessage │ 系统托盘（带 notification
     │ (双监听)         │ (全局唯一,宿主注册)       │  payload 时由 OS 直接展示)
     ▼                 ▼                      ▼
 宿主 listener     宿主 handler            （无代码参与）
 n42_chat listener     │ isChatPushPayload?
     │                 ├─ 是 → FirebasePushService.handleBackgroundMessage
     │                 └─ 否 → device_login 本地通知 / 角标
     │
     │   Matrix sync timeline（第三条展示路径，仅主 isolate 存活时）
     │       └─ _handleSyncUpdate → _showNotificationForEvent
     ▼
 ┌────────────────────────────────────────────┐
 │ PushDedupStore（SharedPreferences, 跨isolate）│ ← 所有展示路径弹通知前
 │ 键: event_id ?? messageId（dedupKeyFor 派生）  │   必须 tryMarkNotified
 └────────────────────────────────────────────┘
     ▼
 flutter_local_notifications（宿主与插件共享同一单例）
```

## 消息归属（唯一分流规则）

`chat_push_routing.dart` 的 `isChatPushPayload`：payload 含非空 `room_id`，
或 `type` 以 `m.call.` 开头 → 归 n42_chat；否则归宿主。

- 宿主的三个 handler（前台/后台/冷启动）全部经此函数分流。
- n42_chat 的前台/后台 handler 对**无 room_id 的消息直接 return**：
  不展示、不消耗去重标记。归属是硬性分工，不依赖监听器注册顺序。

## 三条展示路径与去重

同一条 Matrix 消息最多从三条路径到达，全部经 `PushDedupStore` 收敛为一条通知：

| 路径 | 触发条件 | 去重键 |
|---|---|---|
| FCM 前台 `onMessage` | app 前台 | `event_id ?? messageId` |
| Matrix sync timeline | 主 isolate 存活（含刚切后台的窗口期） | `event_id` |
| FCM 后台 isolate | data-only 推送 + app 后台/被杀 | `event_id ?? messageId` |

iOS 额外规则：**前台系统展示（alert/sound）恒为关闭**（宿主与插件两侧都设
`alert: false`），前台一律手动弹本地通知；后台由 APNs 系统托盘展示（iOS
pusher 不用 `event_id_only`，Sygnal 直接下发完整 alert）。

## 不变量（修改代码时必须保持）

1. **去重键统一派生**：`PushDedupStore.dedupKeyFor(eventId, messageId)`。
   event_id 优先（跨通道一致），messageId 兜底（仅防同通道 FCM 重发）。
2. **标记顺序**：`tryMarkNotified` 必须是「确定要弹」前的最后一道检查。
   所有会静默返回的前置条件（room 判空、activeRoom、静音、免打扰）都要在
   标记**之前**——先标记再静默返回会让其他通道的同一事件被永久抑制（丢通知）。
3. **fail-open**：去重存储异常时放行（宁可重复，不丢通知）。
4. **通知 ID = 键的 FNV-1a 稳定哈希**（`notificationIdForKey`）：同一事件
   竞态双弹时原地覆盖；进程重启不会覆盖通知栏里的其他通知。
5. **resume catch-up 闸门**：sync 路径跳过 `originServerTs` 早于「最近一次
   回前台时刻 − 30s」的事件（后台期间的消息已由 FCM/APNs 展示过；iOS 下
   Dart 未被唤醒、去重存储无标记，只能靠时间闸门）。
6. **badge 先去重后递增**（宿主前台路径）。

## 点击路由

| 点击来源 | 处理入口 | 路径 |
|---|---|---|
| FCM 系统通知（app 后台） | 宿主 `onMessageOpenedApp` | `_routeRemoteNotificationTap`：call 忽略 / chat 排队 flush / 宿主导航 |
| FCM 系统通知（冷启动） | 宿主 `getInitialMessage` | 同上（同一个路由函数） |
| 本地通知（app 存活） | n42_chat `_onNotificationResponse`（后初始化者覆盖共享单例的回调） | 有 room_id → chat 跳转；无 → `hostFallbackNotificationTapHandler` 转交宿主 |
| 本地通知（冷启动） | n42_chat `getNotificationAppLaunchDetails` replay（进程内仅一次） | 同上 |

宿主侧 `chat_tap_dedup.dart` 提供 8 秒窗口的 tap 去重，防止「FCM tap +
n42_chat tap 回调」对同一会话双重打开。

## 已知限制（代码层无法根治）

- 国产 ROM 杀进程 / 无 GMS 设备：FCM data-only 推送送不到，需厂商推送通道
  或电池优化白名单引导（产品决策，未实现）。
- iOS 后台由 APNs 展示的消息，其 event_id 不会进入去重存储，回前台后的
  重复抑制完全依赖 resume 闸门（不变量 5）。

## 测试地图

- n42_chat：`test/unit/services/push_dedup_store_test.dart`（存储语义）、
  `push_notification_dedup_test.dart`（三路径去重、tap 回退路由、resume
  闸门、审计回归）、`firebase_push_service_test.dart`（CallKit/注册流程）。
- 宿主：`test/features/utils/chat_push_routing_test.dart`（归属分流）、
  `push_notification_dedup_test.dart`（payload 路由 + 去重契约）、
  `chat_tap_dedup_test.dart`（tap 窗口）。
