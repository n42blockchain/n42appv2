# social-auth — N42 Chat 第三方登录后端(仓内自建)

补齐 **Discord / GitHub / Telegram** 三家社交登录:校验第三方凭据 → 经 Matrix
Synapse **shared-secret registration** 无状态签发 Matrix 账号 → 返回 App 侧
`SocialAuthApi` 期望的 `data.matrix_*` 登录态。

> 现有五家(google/apple/facebook/twitter/wechat)由外部 `api.n42.network` 承载。
> 本服务只做增量三家;如需整体接管,扩展 `providers.go` 的 `verifyProvider` 即可。

## 接口

`POST /v1/user/loginSocial`

请求(与 `packages/n42_chat/.../social_auth_api.dart` 对齐):

```jsonc
// Discord / GitHub —— 推荐传 code(后端用 client_secret 换 token,secret 不落客户端)
{ "provider": "discord", "code": "<oauth2 code>", "redirect_uri": "n42app://oauth/callback" }
// 或直接传 access_token(前端已换取时)
{ "provider": "github", "access_token": "<token>" }
// Telegram Login Widget 回传字段
{ "provider": "telegram", "id": "42", "hash": "<hmac>", "auth_date": "1720200000",
  "username": "alice", "first_name": "Alice" }
```

响应:

```json
{ "code": 200, "msg": "ok", "data": {
  "matrix_user_id": "@s_discord_ab12..:m.si46.world",
  "matrix_access_token": "syt_...",
  "matrix_device_id": "ABCDEFG",
  "matrix_homeserver": "https://m.si46.world",
  "provider": "discord", "email": "...", "username": "..."
}}
```

失败:`401`(校验失败)/ `400`(参数)/ `500`(签发失败)。

## 账号映射(无状态)

- `localpart = s_<provider>_<sha256(provider:uid)[:24]>` — 稳定、合法字符集、跨 provider 防撞。
- `password  = HMAC-SHA256(MATRIX_PASSWORD_SECRET, provider:uid)` — 确定性,后端不存库。
- 首次 shared-secret 注册(注册即返回登录态);已存在回退密码登录。

## 环境变量

| Env | 必需 | 说明 |
|---|---|---|
| `PORT` | 否(默认 8090) | 监听端口 |
| `MATRIX_HOMESERVER` | ✅ | 如 `https://m.si46.world` |
| `MATRIX_SHARED_SECRET` | ✅ | Synapse `registration_shared_secret`(homeserver.yaml) |
| `MATRIX_PASSWORD_SECRET` | ✅ | 后端私有盐,派生社交账号密码。**务必保密、勿轮换**(轮换会使已注册账号无法再登录) |
| `DISCORD_CLIENT_ID` / `DISCORD_CLIENT_SECRET` | Discord 用 | Discord Developer Portal → OAuth2 |
| `GITHUB_CLIENT_ID` / `GITHUB_CLIENT_SECRET` | GitHub 用 | GitHub → Developer settings → OAuth Apps |
| `TELEGRAM_BOT_TOKEN` | Telegram 用 | @BotFather;域名需绑定(`/setdomain`) |
| `TELEGRAM_AUTH_TTL_SECONDS` | 否(默认 86400) | Login Widget `auth_date` 有效期 |
| `CORS_ORIGINS` | 否 | 逗号分隔的允许来源 |

## 外部依赖(未就绪则对应 provider 不可用)

1. **Matrix homeserver** 开启 shared-secret registration(`registration_shared_secret` 已配)。
2. **Discord App / GitHub OAuth App / Telegram Bot** 注册,拿 client id/secret / bot token。
3. App 侧把新三家的 `baseUrl` 指向本服务(或整体切换)。前端集成见 `docs/SOCIAL_LOGIN_PLAN.md` §3。

## 本地运行

```bash
cd backend/social-auth
MATRIX_HOMESERVER=https://m.si46.world \
MATRIX_SHARED_SECRET=xxx MATRIX_PASSWORD_SECRET=yyy \
DISCORD_CLIENT_ID=... DISCORD_CLIENT_SECRET=... \
go run .
```

零外部 Go 依赖(纯标准库)。`go test ./...` 覆盖 Telegram hash 校验、账号派生、Synapse mac 逻辑。
