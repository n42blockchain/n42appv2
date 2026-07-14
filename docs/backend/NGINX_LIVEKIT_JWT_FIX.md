# MatrixRTC Authorization Service Nginx 运维手册

> 本文适用于生产采用的 Element `lk-jwt-service` 前缀代理。不要为
> `/livekit/jwt` 增加直接签发 token 的 exact location；该路径是服务基地址，客户端实际请求
> `/livekit/jwt/sfu/get`（兼容协议）或 `/livekit/jwt/get_token`（Matrix 2.0）。

## 推荐代理

```nginx
location /livekit/jwt/ {
    proxy_pass http://127.0.0.1:8080/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

`proxy_pass` 末尾的 `/` 用来剥离外部 `/livekit/jwt/` 前缀：

- 外部 `/livekit/jwt/healthz` -> 上游 `/healthz`
- 外部 `/livekit/jwt/sfu/get` -> 上游 `/sfu/get`
- 外部 `/livekit/jwt/get_token` -> 上游 `/get_token`

无斜杠 `/livekit/jwt` 被 Nginx 规范化为 `/livekit/jwt/` 可以接受，因为客户端不应向
基地址直接换票。

## 部署检查

```bash
nginx -t
systemctl status lk-jwt-service

curl -i https://m.si46.world/livekit/jwt/healthz
curl -i -X POST -H 'Content-Type: application/json' -d '{}' \
  https://m.si46.world/livekit/jwt/sfu/get
```

期望 healthz 为 200，空换票请求为 400 `M_BAD_JSON`。404 表示前缀代理错误；502/504 表示
上游服务不可达；200 但客户端仍无法连接时，应核对响应 `url` 指向的 SFU、LiveKit API
key/secret 是否一致，以及 SFU webhook 是否指向
`/livekit/jwt/sfu_webhook`。

## 自建旧服务

仓库 `backend/livekit-jwt/` 是 N42 旧 Bearer-token 兼容服务，不是当前生产
`lk-jwt-service`。只有明确部署该旧服务时，才使用其 README 中的 exact
`/livekit/jwt` 配置；两套协议不能混配。
