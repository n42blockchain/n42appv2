# 直播发布权限（canPublish）服务端限权方案

面向运维。目标：**观众拿不到可推流的 LiveKit token**，只有该直播间的主播能推流。

当前生产状态是「未限权」——任何进入直播间的人，token 里都带 `CanPublish=true`，
理论上可以抢推流覆盖主播画面。本文给出改法、部署步骤和验证方法。

---

## 1. 为什么客户端已经传了 `role` 却挡不住

客户端在申请 token 时会带 `role=broadcaster|viewer`，但**这个字段不能作为授权依据**：
它由客户端自己填，观众把它改成 `broadcaster` 是零成本的事。

真正的问题在服务端：`handler.go` 里签发 token 时写死了

```go
CanPublish: boolPointer(true),   // 无论 role 是什么
```

`role` 只被塞进 metadata 做展示，没有参与任何决策。所以**两条签发路径都不限权**
（详见 §5），限权必须在服务端重做。

## 2. 判据：按房间判，不按客户端说的 role 判

⚠️ **这一点在初版方案里是错的，审计时发现并已改正，记录在此避免重蹈覆辙。**

初版的逻辑是「带 role 的请求才做校验，不带 role 的放行」。这留下一个直接绕过：
**攻击者只要不写 `role` 字段，就落进放行分支拿到推流权**。这样的限权只挡得住
老老实实传 `role=viewer` 的官方客户端，挡不住任何主动攻击者，等于没限权。

正确判据不看客户端传了什么，只看**房间本身**：

| 房间类型 | 判定方式 | 谁能推流 |
|---|---|---|
| **公开房**（`join_rule=public`）＝直播间 | 查 `m.room.create` 的创建者 | 只有创建者（主播） |
| **私有房**（invite 等）＝群通话 | 不查创建者 | 所有已加入成员 |

依据是客户端的建房方式：直播间必须公开（`publicChat`/`JoinRules.public`）才能让
陌生观众按房号加入；承载群通话的聊天房是邀请制。这条区分由服务端自己读
`m.room.join_rules` 得出，客户端无法影响。

在公开房内，显式传 `role=viewer`（或任何非 broadcaster 值）仍会进一步降权，
但**不传 role 不再等于放行**。

**主播 = 该房间 `m.room.create` 事件的创建者。**

这个字段由 homeserver 在建房时写入，客户端无法伪造；直播间是主播开播时创建的，
所以创建者恒等于主播。Flutter 客户端锚定主播视频轨用的也是同一字段
（`live_video_service.dart` 的 `_broadcasterId`），两端判据一致，不会打架。

判定规则：

| 房间 | 请求带的 role | 创建者 | 结果 |
|---|---|---|---|
| 公开 | `broadcaster` | 等于请求者 | ✅ 可推流 |
| 公开 | `broadcaster` | 不等于请求者（伪造） | ❌ 只能观看 |
| 公开 | `viewer` / 未知值 | 任意 | ❌ 只能观看 |
| 公开 | **不带 role** | 不等于请求者 | ❌ 只能观看（**堵住绕过**） |
| 公开 | 不带 role | 等于请求者 | ✅ 可推流 |
| 公开 | 任意 | 查不到创建者 | ❌ 只能观看（失败关闭） |
| **私有** | 任意 | 不查 | ✅ 可推流（群通话） |
| 公开 | 任意 | join_rule 读取失败 | ❌ 按公开房从严处理 |

**失败方向的选择**：读不到 join_rule 时按「公开房」处理，即适用更严格的
仅创建者规则。这样失败最多让一个群通话参与者暂时用不了麦克风，
而不会让任何人劫持直播画面。

## 3. 代码改动（已完成，在本目录）

- `matrix.go`：新增 `RoomCreator()`，调
  `GET /_matrix/client/v3/rooms/{roomId}/state/m.room.create/` 取创建者。
  兼容 room v11+（该版本不再有 `creator` 字段，改用事件的 `sender`）。
- `handler.go`：新增 `canPublishFor()` 实现上表；签发改为
  `CanPublish: boolPointer(request.canPublish)`，决策在服务端完成，
  `canPublish` 是私有字段、不从请求体解析，客户端塞不进来。
- `handler_test.go`：新增 7 项测试，覆盖伪造 role、未知 role、无 role、
  创建者查不到，以及**解析真实签发的 JWT 断言 `CanPublish=false` 而
  `CanSubscribe=true`**（确保限权真的进了签名，不只是结构体字段）。

验证方式：把限权改回硬编码 `true`，伪造用例立即失败——测试确实咬得住。

`go test ./...` 全绿。

## 4. 部署步骤

```bash
cd backend/livekit-jwt
go test ./...                    # 应全绿
docker build -t n42-livekit-jwt:role-enforced .
```

环境变量沿用现有配置（见 `README.md`），本次改动**没有新增配置项**。

上线后确认服务在 `/livekit/jwt` 路径上应答 POST（GET 契约仍兼容）。

> **注意**：本服务需要用请求者的 Matrix access token 去查房间 state。
> 这与它已有的 `whoami` / 成员校验用的是同一个 token 和同一个 homeserver，
> 不需要额外授予服务任何权限，也不需要 admin token。

## 5. 关于生产当前用的是哪个服务（关键，请先确认）

`m.si46.world` 目前对外提供的是 **Element MatrixRTC Authorization Service**
（`/livekit/jwt/sfu/get`），不是本目录这个 legacy 服务。这带来一个限制：

**官方 MatrixRTC 契约不接收自定义 `role` 字段**，它只认 Matrix 房间成员身份，
给所有成员签发同等 token。也就是说——**只要走官方端点，就没有任何办法区分主播和观众。**

客户端的取舍是：带 role 的请求**优先走 legacy 端点**，只有 legacy 明确不存在
（301/308/404/405/410）才回退官方端点。因此：

- **部署本服务到 `/livekit/jwt` → 客户端自动走它，限权立即生效，无需改客户端、无需发版。**
- 不部署 → 客户端回退官方端点 → 直播能用但**不限权**（即今天的状态）。

所以推荐路径就是把这个服务部署起来。若组织上决定长期只维护官方服务，
那么限权需要另做：要么在官方服务前加一层代理按房间状态改写 grant，
要么 fork 官方服务加入房间创建者判定——两者都比部署本服务成本高。

## 6. 上线验收（务必实测，别只看代码）

需要两个账号、两台设备（或一台 + 一个浏览器）。

1. **主播能推流**：A 开播，B 进房。B 应能看到 A 的画面。
2. **观众推不了流**（核心项）：用 B 的身份申请一次 token，把返回的 JWT
   贴到 <https://jwt.io> 解开，确认 `video.canPublish` 为 `false`、
   `video.canSubscribe` 为 `true`。
3. **伪造 role 挡得住**：手工发一个请求，`identity` 用 B、`role` 填
   `broadcaster`、`conversation_id` 填 A 的房间（**再把 `role` 整个删掉重发一次，
   两次的 `canPublish` 都必须是 `false`**——省略 role 曾经是一条绕过）：

   ```bash
   curl -X POST https://m.si46.world/livekit/jwt \
     -H "Authorization: Bearer <B 的 Matrix access token>" \
     -H "Content-Type: application/json" \
     -d '{"room":"mx__live_m_example","identity":"@b:m.example",
          "conversation_id":"!live:m.example","role":"broadcaster","video":true}'
   ```

   解开返回的 JWT，`canPublish` 必须是 `false`。**这一项通过才算真正限权。**
   （`room` 的算法：`mx_` 前缀 + `conversation_id` 里所有非字母数字字符替换成 `_`。
   例：`!live:m.example` → `mx__live_m_example`。不匹配会返回 `invalid_request`。）
4. **群通话没被误伤**：正常打一通聊天群通话，双方都能出声出画。

## 7. 回滚

改动只在这一个服务内，回滚即部署上一个镜像。回滚后行为退回「不限权」，
直播功能本身不受影响。

## 8. 遗留

- 本方案把「主播」定义为建房者。若将来要做**连麦**（观众上麦发言），
  需要扩展判据，例如主播在房间 state 里维护一份允许发布的名单，
  服务端读该 state 决定 `canPublish`。当前实现留了扩展点：
  判定集中在 `canPublishFor()` 一个函数里。
- LiveKit 侧的 grant 由 LiveKit server 强制执行，不需要额外配置。
