# MatrixRTC 多人通话换票修复说明

> 2026-07-14 纠错：此前将 `/livekit/jwt` 基地址的 `301 -> /livekit/jwt/` 和基地址
> `404` 误判为 JWT 服务未部署。生产复核证明服务正常，真正根因是客户端把服务基地址
> 当成了 token 端点。

## 生产现状

`.well-known/matrix/client` 发布：

```json
{
  "org.matrix.msc4143.rtc_foci": [
    {
      "type": "livekit",
      "livekit_service_url": "https://m.si46.world/livekit/jwt"
    }
  ]
}
```

2026-07-14 实测：

| 请求 | 结果 | 含义 |
|---|---|---|
| `GET /livekit/jwt/healthz` | `200` | MatrixRTC Authorization Service 正常 |
| `GET /livekit/jwt/sfu/get` | `405` | 路由存在，只允许 POST |
| 空 JSON `POST /livekit/jwt/sfu/get` | `400 M_BAD_JSON` | 协议处理器正常校验请求 |
| `GET /livekit/sfu` | `200` | LiveKit SFU 可达 |

服务基地址本身不是 token API。官方反向代理使用 `/livekit/jwt/` 前缀并剥离该前缀，
因此访问无斜杠基地址时出现 301 不代表通话故障。

## 正确客户端流程

1. 从 Matrix homeserver 调用
   `POST /_matrix/client/v3/user/{userId}/openid/request_token` 获取短期 OpenID 凭据。
2. 向 `{livekit_service_url}/sfu/get` POST：

```json
{
  "room": "!matrixRoomId:server",
  "openid_token": {
    "access_token": "short-lived-openid-token",
    "token_type": "Bearer",
    "matrix_server_name": "server",
    "expires_in": 3600
  },
  "device_id": "MATRIX_DEVICE_ID"
}
```

3. 使用响应中的 `url` 和 `jwt` 连接 LiveKit。不得自行假设 SFU URL，也不得把 Matrix
   access token 直接发给 Authorization Service。

当前客户端实现在
`packages/n42_chat/lib/src/services/voip/matrix_rtc_token_service.dart`。旧 N42 自建
Bearer-token 服务只在官方 `/sfu/get` 明确返回 404/405 时兼容回退；OpenID 或网络失败时
不得发送 Matrix 长期 access token。

## 验收

```bash
curl -fsS https://m.si46.world/livekit/jwt/healthz

curl -sS -o /dev/null -w '%{http_code}\n' \
  -X POST -H 'Content-Type: application/json' -d '{}' \
  https://m.si46.world/livekit/jwt/sfu/get
# 期望 400；说明路由存在且拒绝缺字段请求。
```

最终验收仍需两台真机、两个 Matrix 账号在同一群组完成语音和视频 A/B：三人加入/退出、
静音、摄像头切换、前后台、断网重连和屏幕共享。
