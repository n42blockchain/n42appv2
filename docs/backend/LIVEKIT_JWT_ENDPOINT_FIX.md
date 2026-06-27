# 后端修复说明：LiveKit JWT 端点 301→404（阻塞群组视频通话 / 屏幕共享 A/B）

> 提出：2026-06-27（客户端侧）｜优先级：高（阻塞 #9 屏幕共享真机 A/B 与一切群组视频通话）
> 影响服务：`m.si46.world` 的 LiveKit JWT 签发端点 + `.well-known`

## 一、现象

客户端发起群组音视频通话时，需先向 LiveKit **JWT 服务端点** 换取访问令牌。当前：

- `GET/POST https://m.si46.world/livekit/jwt` → **301 重定向**到 `https://m.si46.world/livekit/jwt/`（加尾斜杠）
- `https://m.si46.world/livekit/jwt/`（带尾斜杠）→ **404 Not Found**

结果：客户端拿不到 token，无法进入 `GroupCallScreen`，群组视频/屏幕共享无法验证。

> 301 还有副作用：HTTP 规范下 301 常把 **POST 降级为 GET 并丢弃请求体**，即使 `/jwt/`
> 存在也会丢掉房间/身份参数。**端点必须直接命中、不要重定向**。

## 二、客户端契约（请按此实现/修复服务端）

### 1. 发现（`.well-known`）
客户端 `GET {homeserver}/.well-known/matrix/client`，读取（MSC4143）：

```jsonc
{
  "org.matrix.msc4143.rtc_foci": [
    {
      "type": "livekit",
      "livekit_service_url": "https://m.si46.world/livekit/jwt",  // ← JWT 服务 URL
      "livekit_alias": "..."
    }
  ]
}
```

- 兼容回退键：`n42.livekit`。
- 客户端据 `livekit_service_url` 派生 WS：把末段 `jwt` 换为 SFU，例如
  `https://m.si46.world/livekit/jwt` → `wss://m.si46.world/livekit/sfu`。
  **请确保该 SFU WS 同样可直连。**

### 2. 取 token 请求
客户端先 POST，失败再 GET（同一 URL）：

- Header：
  - `Authorization: Bearer <Matrix accessToken>`（用户的 Matrix 访问令牌，服务端需校验）
  - `Accept: application/json`、`Content-Type: application/json`
- POST body（JSON）：
  ```json
  {
    "room": "<roomName>",
    "identity": "<participantId>",
    "name": "<participantName>",
    "video": true,
    "conversation_id": "<conversationId>",
    "metadata": "{\"conversation_id\":\"...\",\"video\":true}"
  }
  ```
- GET 回退：上述字段作为 query 参数。

### 3. 期望响应
`200 OK` + JSON，token 字段名任一即可（客户端按以下顺序取）：

```json
{ "token": "<livekit-jwt>" }      // 或 "jwt" / "access_token" / "accessToken"
```

可附带 `url`/`ws_url`（LiveKit SFU WS 地址）；不附则用上面的派生规则。

## 三、根因与修复

**根因**：反向代理 / 应用路由对 `/livekit/jwt` 强制加尾斜杠重定向（301），而带尾斜杠的
路径没有注册处理器（404）。

**任一修复即可**：

1. **首选**：在 `/livekit/jwt`（**无尾斜杠**）直接注册 `POST` 与 `GET` 处理器，
   **不做 301 重定向**；校验 `Authorization` Matrix token，签发 LiveKit JWT 返回 JSON。
2. 或：让 `.well-known` 的 `livekit_service_url` 指向**能直接命中、不重定向**的规范 URL。
3. 反向代理（nginx/traefik 等）：去掉对该路径的 `merge_slashes`/自动加斜杠重定向；
   `proxy_pass` 保留 `Authorization` 头与请求体；放行 `POST`。

附带检查：
- CORS（若 Web 端用）：允许 `Authorization`、`Content-Type`，方法 `GET,POST,OPTIONS`。
- SFU WS（`wss://.../livekit/sfu`）可直连、证书有效。

## 四、验收（修好后跑）

```bash
# 1. 端点不重定向、直接 200（带合法 Matrix token）
curl -i -X POST https://m.si46.world/livekit/jwt \
  -H "Authorization: Bearer <MATRIX_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"room":"test","identity":"@a:m.si46.world","name":"A","video":true,"conversation_id":"c1"}'
# 期望：HTTP/1.1 200，body 含 {"token":"..."}；不得出现 301 / 404

# 2. .well-known 暴露的 URL 与上面一致且可直连
curl -s https://m.si46.world/.well-known/matrix/client | jq '.["org.matrix.msc4143.rtc_foci"]'
```

客户端侧验收：两台真机/两账号进同一群 → 发起视频通话能进入 `GroupCallScreen` → A 端
屏幕共享，B 端可见（#9 T8 的剩余真机 A/B）。

## 五、关联

- 阻塞项：#9 屏幕共享真机 A/B（客户端接线已完成：`docs/device-test-reports/2026-06-27-screen-share.md`）。
- 客户端取 token 代码：`packages/n42_chat/lib/src/services/voip/call_manager.dart`、
  URL 规范化/派生：`packages/n42_chat/lib/src/core/utils/livekit_call_utils.dart`、
  发现：`packages/n42_chat/lib/src/core/services/n42_call_facade.dart`。
- 旁注（与本端点无关，进度记录）：Codex 已交付 **T9 OpenMLS 移动端打包**（`9a064049`）
  与 **T10 iOS 本地 AI 验证**（`34518b21`），均编译级通过、已验收。
