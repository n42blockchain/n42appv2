# 直播发布权限（canPublish）服务端限权方案

面向运维。目标：**观众拿不到可推流的 LiveKit token**，只有该直播间的主播能推流。

当前生产使用官方 MatrixRTC 授权服务 0.9.0，本目录的 legacy 策略未接入该生产路径。**生产主播/观众发布权限尚未验收**。本目录的隔离测试通过，不代表其它签发端点也受同一策略约束。

---

## 1. 为什么客户端已经传了 `role` 却挡不住

客户端在申请 token 时会带 `role=broadcaster|viewer`，但**这个字段不能作为授权依据**：
它由客户端自己填，观众把它改成 `broadcaster` 是零成本的事。

旧版 legacy 服务曾把 `CanPublish` 写死为 `true`；本目录已改为服务端读取 Matrix 房间状态后决定权限。生产官方服务是另一条签发路径，不能用这里的修复推断其授权结果。

必须检查同一 SFU 接受的全部签发路径。只让正常客户端优先访问受控端点，不能阻止攻击者直接访问另一个端点。

## 2. 判据：按房间判，不按客户端说的 role 判

⚠️ **这一点在初版方案里是错的，审计时发现并已改正，记录在此避免重蹈覆辙。**

初版的逻辑是「带 role 的请求才做校验，不带 role 的放行」。这留下一个直接绕过：
**攻击者只要不写 `role` 字段，就落进放行分支拿到推流权**。这样的限权只挡得住
老老实实传 `role=viewer` 的官方客户端，挡不住任何主动攻击者，等于没限权。

正确判据不看客户端传了什么，只看**房间本身**：

| 房间类型 | 判定方式 | 谁能推流 |
|---|---|---|
| **直播间**（带 `n42.live.status` 标记） | 查 `m.room.create` 的创建者 | 只有创建者（主播） |
| **其它房间**（无该标记）＝群聊/群通话 | 不查创建者 | 所有已加入成员 |

`n42.live.status` 是主播开播时写入的专用 state event（结束时置 `live:false`，
标记本身保留），**它的存在与否**就是"这个房间是不是直播间"的权威答案。

> ⚠️ 第二次修正：中间版本曾用 `join_rule=public` 判直播间，也是错的，原因有二：
> ① `join_rule` 是群设置页上一个**用户可改的开关**，把直播间改成 invite 就能
> 解除限权；② 本仓库存在**公开的普通群聊**（`createGroupChat(encrypted:false)`
> 走 publicChat），在这类群里开群通话会导致除建群者外**全员被静音**，且客户端
> 无任何报错，表现为"进了会但没人听得见我"。改用 live 标记后这两个问题同时消失。

在公开房内，显式传 `role=viewer`（或任何非 broadcaster 值）仍会进一步降权，
但**不传 role 不再等于放行**。

**主播 = 该房间 `m.room.create` 事件的创建者。**

这个字段由 homeserver 在建房时写入，客户端无法伪造；直播间是主播开播时创建的，
所以创建者恒等于主播。Flutter 客户端锚定主播视频轨用的也是同一字段
（`live_video_service.dart` 的 `_broadcasterId`），两端判据一致，不会打架。

判定规则：

| 房间 | 请求带的 role | 创建者 | 结果 |
|---|---|---|---|
| 直播间 | `broadcaster` | 等于请求者 | ✅ 可推流 |
| 直播间 | `broadcaster` | 不等于请求者（伪造） | ❌ 只能观看 |
| 直播间 | `viewer` / 未知值 | 任意 | ❌ 只能观看 |
| 直播间 | **不带 role** | 不等于请求者 | ❌ 只能观看（**堵住绕过**） |
| 直播间 | 不带 role | 等于请求者 | ✅ 可推流 |
| 直播间 | 任意 | 查不到创建者 | ❌ 只能观看（失败关闭） |
| **非直播间** | 任意 | 不查 | ✅ 可推流（群通话） |
| 读取失败 | 任意 | — | ❌ 按直播间从严处理 |

**失败方向的选择**：只有 homeserver 明确回 404（标记不存在）才判定为非直播间；
其余情况（5xx、超时、200 但响应异常）一律按直播间从严处理。这样失败最多让一个
群通话参与者暂时用不了麦克风，而不会让任何人劫持直播画面。

**开播时序修正（2026-11-07）**：钱包创建公开直播房时，在同一个 `createRoom` 请求的 `initial_state` 中写入 `n42.live.status: {live:false}`。因此，首次申请 token 前标记已经存在；该房间从创建起即按直播间限权，且未写入开播心跳，不会提前显示正在直播。内部 TestFlight 73425 包含本修正，73424 不包含它。生产官方授权路径仍需要独立限权接入，不能由客户端标记代替服务端检查。

## 3. 代码改动（已完成，在本目录）

- `matrix.go`：新增 `RoomCreator()`，调
  `GET /_matrix/client/v3/rooms/{roomId}/state`，从 `m.room.create`、空 state key 的可信事件外层读取 `sender`。单条 state 内容不是事件外层；room v11+ 的内容不再包含 `creator`。
- `handler.go`：新增 `canPublishFor()` 实现上表；签发改为
  `CanPublish: boolPointer(request.canPublish)`，决策在服务端完成，
  `canPublish` 是私有字段、不从请求体解析，客户端塞不进来。
- `handler_test.go`：新增 7 项测试，覆盖伪造 role、未知 role、无 role、
  创建者查不到，以及**解析真实签发的 JWT 断言 `CanPublish=false` 而
  `CanSubscribe=true`**（确保限权真的进了签名，不只是结构体字段）。

验证方式：把限权改回硬编码 `true`，伪造用例立即失败——测试确实咬得住。

`go test ./...` 全绿。

## 4. 候选构建与上线前提

```bash
cd backend/livekit-jwt
go test ./...                    # 应全绿
docker build -t n42-livekit-jwt:role-enforced .
```

环境变量沿用现有配置（见 `README.md`），本次改动**没有新增配置项**。

候选服务兼容 `/livekit/jwt` 的 POST/GET；路径可达仅证明协议接通。上线前必须完成下一节的全部签发路径约束和回归，不能仅部署此端点就标记限权完成。

> **注意**：本服务需要用请求者的 Matrix access token 去查房间 state。
> 这与它已有的 `whoami` / 成员校验用的是同一个 token 和同一个 homeserver，
> 不需要额外授予服务任何权限，也不需要 admin token。

## 5. 生产签发路径必须统一受控

生产发现地址指向 Element MatrixRTC Authorization Service 的 `/livekit/jwt/sfu/get`。客户端带 `role` 时优先尝试 legacy，旧端点明确不存在时才回退官方协议；这个顺序只是兼容策略，**不是访问控制**。

只新增 `/livekit/jwt`，同时保留可为同一 SFU 房间签发更宽权限的官方端点，仍可绕过 legacy 策略。上线方案需要先列清所有入口，包括 legacy、standalone、启用的 C-S/S-S 路由及其它持有该 SFU 签发密钥的服务，并让直播发布判据在所有入口一致。也可采用独立 SFU/签发密钥隔离，但必须先验证旧客户端、发现配置和群通话兼容性。不要直接关闭现有群通话入口来伪造策略完成。

官方 [0.9.0 发布说明](https://github.com/element-hq/lk-jwt-service/releases/tag/v0.9.0) 的 standalone 成员校验有前提：以 application service 运行，且唯一 full-access homeserver 与关联服务器一致。这个成员校验不等于 N42 的“仅房间创建者可发布”。Tuwunel 的 AS 接入、成员拒绝、主播/观众及普通群通话都需要独立验证。生产没有配置或实测证据时不能宣称成立。

本次记录与离线工具不修改生产路由、签发密钥或服务配置。

## 6. 上线验收（务必实测，别只看代码）

需要两个账号、两台设备（或一台 + 一个浏览器）。

1. **主播能推流**：A 开播，B 进房。B 应能看到 A 的画面。
2. **观众推不了流**：分别向每个可达签发端点申请 B 的 token。在本机验证签名、有效期、预期 issuer/identity/room、`canPublish=false` 和 `canSubscribe=true`；不得把有效 JWT 或 API secret 上传第三方解码网站。随后以 B 尝试实际发布，确认 SFU 拒绝。仅查看 payload 不能证明签名有效或发布被拒绝。
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

   离线验证返回的 JWT，`canPublish` 必须是 `false`。还须重复测试官方及其它可达签发路径；任一路径得到更宽授权，整项验收仍失败。
   （`room` 的算法：`mx_` 前缀 + `conversation_id` 里所有非字母数字字符替换成 `_`。
   例：`!live:m.example` → `mx__live_m_example`。不匹配会返回 `invalid_request`。）
4. **群通话没被误伤**：正常打一通聊天群通话，双方都能出声出画。

### 本机 JWT 验证工具

从本目录构建，token 只从 stdin 输入；secret 从受控文件读取，不放入命令行、仓库或日志：

```bash
go build -o /tmp/n42-token-check ./cmd/token-check
/tmp/n42-token-check --secret-file /controlled/livekit-secret --issuer EXPECTED_API_KEY --identity EXPECTED_PARTICIPANT --room EXPECTED_SFU_ROOM --publish=false < /controlled/viewer-token.jwt
```

预期身份和房间必须来自测试场景，不能从待检查 token 自行抄出作为唯一依据。文件在本机受控保存。工具使用现有 LiveKit SDK 验签，要求当前有效、明确的媒体 grant，拒绝 room/ingress 管理及额外服务权限。输出只含校验结果，不回显 token、secret、身份或房间。它不证明生产路由没有旁路、不代表服务端实际拒绝推流，也不替代两端音视频与群通话回归。

## 7. 回滚

回滚必须同时核对镜像、路由和签发密钥配置。恢复旧签发路径可能重新暴露发布权限；应在记录中恢复“权限未验收”状态，不能以直播仍可用作为策略通过的证据。保留群通话兼容性及各端点负向验证结果。

## 8. 遗留

- 本方案把「主播」定义为建房者。若将来要做**连麦**（观众上麦发言），
  需要扩展判据，例如主播在房间 state 里维护一份允许发布的名单，
  服务端读该 state 决定 `canPublish`。当前实现留了扩展点：
  判定集中在 `canPublishFor()` 一个函数里。
- LiveKit 侧的 grant 由 LiveKit server 强制执行，不需要额外配置。

## 2026-11-07：房间创建者读取修正

`RoomCreator` 现从 `GET /rooms/{roomId}/state` 的 `m.room.create` 事件外层读取 `sender`，同时要求空 state key。不再把单条 state 接口返回的内容字段当成事件外层；旧服务端可能忽略 `format=event`，内容甚至可以伪装成完整事件。读取失败、错误事件或缺失发送者均拒绝推流授权。

隔离 Tuwunel 1.9.4 的 v11 房间已实测：单条 state 内容没有 creator/sender，完整 state 的事件发送者与创建账号一致；临时账号已停用。本修正仅在仓库 legacy 服务完成，生产仍是官方 MatrixRTC 授权服务。官方路径的主播/观众权限不能据此认定已完成限权。
