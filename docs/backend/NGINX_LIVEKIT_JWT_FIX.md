# 运维手册：修复 m.si46.world 的 LiveKit JWT 端点 301→404（Nginx）

> 对象：`m.si46.world` IDC 服务器运维 ｜ 优先级：高
> 影响：群组视频通话 / 屏幕共享（#9）拿不到 LiveKit token，无法进入通话。
> 配套：客户端契约见同目录 `LIVEKIT_JWT_ENDPOINT_FIX.md`。

## 一、问题

```
POST/GET https://m.si46.world/livekit/jwt        → 301（Location: /livekit/jwt/）
         https://m.si46.world/livekit/jwt/        → 404
```

客户端（`.well-known` 的 `livekit_service_url` = `https://m.si46.world/livekit/jwt`）
对该 URL 发 **POST**（带 `Authorization: Bearer <matrix token>` + JSON body）。301 会把
POST 降级成 GET 并丢弃 body，且尾斜杠路径 404——两步都坏。**端点必须无重定向直达。**

## 二、诊断（在服务器上跑）

```bash
# 1. 看 301 的 Location 与最终 404
curl -i https://m.si46.world/livekit/jwt
curl -i https://m.si46.world/livekit/jwt/

# 2. 导出运行中的 nginx 配置，定位 livekit 相关 location
nginx -T 2>/dev/null | grep -nE "location|livekit|proxy_pass|return 30|rewrite|merge_slashes|absolute_redirect" | grep -iA3 livekit

# 3. 确认 token 服务本身是否在跑、监听哪个端口（lk-jwt-service / 自建）
ss -ltnp | grep -iE ':(8080|8081|7880|3002)'    # 端口按实际
systemctl status lk-jwt-service 2>/dev/null || docker ps | grep -iE "jwt|livekit"
```

## 三、根因（三选一，按诊断结果定）

1. **最常见**：`location /livekit/jwt/`（带尾斜杠）或 `location /livekit/`（目录式）导致
   nginx 对无斜杠路径发 301 补斜杠；而带斜杠路径未正确反代 → 404。
2. `proxy_pass` 末尾带 `/` 改写了路径，token 服务实际监听 `/jwt`（无斜杠）对不上。
3. token 服务（lk-jwt-service / 自建签发服务）**根本没部署或挂了** → 任何路径都 404，
   301 来自占位 location。

## 四、修复（Nginx 配置）

在 `m.si46.world` 的 server 块里，用**精确匹配、无重定向**的 location 反代到 token 服务
（把 `<TOKEN_SVC_PORT>` 换成第二步查到的真实端口）：

```nginx
# LiveKit JWT 签发端点：精确路径、禁止补斜杠重定向、透传 POST/Authorization
location = /livekit/jwt {
    proxy_pass http://127.0.0.1:<TOKEN_SVC_PORT>;   # 注意：proxy_pass 不带末尾 /，保持原路径
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Authorization $http_authorization;   # 必须透传 Matrix token
    proxy_pass_request_body on;
    proxy_redirect off;          # 不要把上游可能的重定向透出
    absolute_redirect off;       # 关掉 nginx 自身的绝对/补斜杠重定向
    # 如 Web 端跨域需要：
    # add_header Access-Control-Allow-Origin  $http_origin always;
    # add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
    # add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
    # if ($request_method = OPTIONS) { return 204; }
}
```

要点：
- `location = /livekit/jwt`（精确）避免被目录式 location 的补斜杠规则命中。
- `proxy_pass` **不要**写成 `http://127.0.0.1:port/`（带斜杠会改写路径）。若 token 服务
  实际路径不是 `/livekit/jwt` 而是例如 `/jwt` 或 `/token`，用 `rewrite ... break;` 显式改写，
  例如：`rewrite ^/livekit/jwt$ /token break;`，**不要用 301/302**。
- 若服务器开了 `merge_slashes off;` 或全局 `absolute_redirect on;`，本 location 内显式
  `absolute_redirect off;` 覆盖。
- 同时确认 SFU WS 直连：`wss://m.si46.world/livekit/sfu`（客户端由 jwt URL 派生），其
  `location /livekit/sfu` 需 `proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade";`。

### 若根因是 token 服务未部署
部署标准 **lk-jwt-service**（Element Call / matrixRTC 用的 LiveKit JWT 服务）或自建签发服务，
监听内网端口后按上面反代。注意其默认对外路径可能与客户端期望的 `/livekit/jwt` 不同，用
`rewrite`/`proxy_pass` 对齐；签发逻辑需校验传入的 Matrix `Authorization` token、用 LiveKit
API key/secret 生成带 `room`/`identity`/`VideoGrant` 的 JWT，返回 `{"token":"..."}`。

## 五、生效与验收

```bash
nginx -t && nginx -s reload          # 或 systemctl reload nginx

# 期望：200，body 含 token，且无 301/404
curl -i -X POST https://m.si46.world/livekit/jwt \
  -H "Authorization: Bearer <真实 MATRIX_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"room":"t","identity":"@a:m.si46.world","name":"A","video":true,"conversation_id":"c1"}'
```

通过后通知客户端侧做 #9 两机 A/B（A 共享屏幕、B 可见）。

## 六、回滚

改动只在该 server 块新增/调整一个 `location = /livekit/jwt`。回滚即删除该 location 或
还原备份的 `nginx.conf`，`nginx -s reload`。建议改前 `cp nginx.conf nginx.conf.bak.$(date +%F)`。
