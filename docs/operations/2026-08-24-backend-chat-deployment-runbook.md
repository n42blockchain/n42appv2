# N42 全后台与 Chat 插件部署盘点及运维手册

> 审计日期：2026-08-24（America/Toronto）
>
> 代码基线：`master@72b4a2d0`
>
> 适用范围：N42 Wallet 主应用、vendored `packages/n42_chat`、仓内 Go 后端、
> Matrix/RTC/推送及 `api.n42.ai` 生产网关。
>
> 本文不包含任何真实密钥；命令中的 `<...>` 必须从 Secret Manager 注入。

## 1. 结论先行

当前不是“所有后台均已部署”的状态。基础钱包 API、Matrix 聊天、Matrix 推送入口、
TURN、官方 MatrixRTC、N42 RPC 与 ID Hub 可达；下列项目尚未部署、路由错误或发布配置
没有进入正式包。

### 1.1 P0：发布或登录前必须处理

| 项目 | 2026-08-24 实测 | 影响 | 运维动作 |
|---|---|---|---|
| 正式包构建配置 | iOS/TestFlight 脚本及 GitHub Release 双端均未传 `--dart-define` | Proxy、AI、GIF、翻译、语音、DeBank、部分社交登录等配置不会进入正式包 | 建立受控的 release define allowlist，并在构建前做缺项门禁；禁止直接把整个 `.env` 注入客户端 |
| GitHub Release 流水线 | 固定 Flutter 3.41.9（Dart 3.11.5），但项目要求 Dart ≥3.12.2；引用的 `ios/ExportOptions.plist` 不存在 | tag 发布会在依赖解析或 iOS 导出阶段失败，不能视为可用的自动发布 | 与受控生产 Flutter 版本对齐，改用现有/生成的 ExportOptions，并做一次 dry-run |
| Chat 社交登录 | `social-auth.n42.ai`、`api.n42.network` 均无 DNS | Google/Apple 等旧五家后端不可达；Discord/GitHub/Telegram 自建后端也不可达 | 部署 `backend/social-auth`，建立 DNS/TLS；决定旧五家迁移或恢复旧域名 |
| Matrix SSO | `/_matrix/client/v3/login` 仅返回 password/token/application_service，无 `m.login.sso` | App 虽开启 `enableSsoLogin`，生产 homeserver 实际不支持 SSO | 配置 Tuwunel OIDC/SSO 后再开放入口，或正式包关闭 SSO |
| 直播发布权限 | `/livekit/jwt` POST 返回 301，尾斜杠路径 404；客户端会回退官方 `/sfu/get` | 直播可能能播放，但官方 MatrixRTC 无主播/观众发布权限区分，观众理论上可拿发布权 | 将 `backend/livekit-jwt` 精确部署到 `/livekit/jwt`，不得重定向、不得补尾斜杠 |
| Swap Go 后端 | `GET /swap/v1/dex/tokens?chain=ETH` 返回 404 | 新 DEX 聚合、历史、限价单、价格预警不可用 | 部署 `backend/swap`，网关剥离 `/swap` 前缀；上线前补鉴权 |
| Swap 鉴权 | 代码仅按客户端提交的 `uuid` 做归属，无 token 校验 | 可越权读写订单/预警；虽然服务不持用户私钥，仍是隐私与状态完整性问题 | 在服务中或 API 网关强制验证 `UUID`/`Token`，不能只依赖 CORS |
| Loyalty | `/loyalty/...` 返回 404，仓内 README 也标明尚未部署 | 签到、任务、积分、排行全部不可用 | 先部署并验证合约，再部署 PostgreSQL 与 `backend/loyalty`，给 relayer 少量 N42 Gas |
| Passkey | MSC3824 challenge 路径返回 404 | Chat Passkey 注册/登录不可用 | 在 homeserver 部署相符扩展，或关闭 Passkey UI；不要只看 `/versions` 的 feature flag |

### 1.2 P1：上线后立即处理

| 项目 | 实测 | 影响/动作 |
|---|---|---|
| Airdrop 聚合 | `/airdrop/v1/airdrops` 返回 404，仓内无对应后端 | 需要单独实现/部署，或隐藏入口 |
| Activity/Mining API | 代表路由返回 502 | 检查 `api.n42.ai` upstream、端口与服务进程；恢复前应用会显示活动/挖矿网络错误 |
| Onramper | `/otc/r/onramper/url` 返回 502 | 法币购买入口不可用；修 upstream 或临时关闭入口 |
| NFT Market | 代表路由 `/nft-market/v1/image/url` 返回 404 | 核对旧 NFT 服务是否下线、路径是否变更；不要把 404 当“空数据” |
| 7 个 Chat mini-app | `swap/bridge/nft/shop/creator/portfolio/charts.n42.world` 全部无 DNS | 内置入口均为死链接；部署站点或从目录移除 |
| Universal Link | `n42.network`、`n42.app` 无 DNS | WeChat Universal Link、频道链接及 AASA/Asset Links 不可用 |
| 后端 CI/CD | GitHub CI 没有 Go/合约测试、镜像构建、镜像扫描或部署 job | 将 `scripts/run_automated_tests.sh` 中已有的 Go/Forge 检查接入 CI，并增加镜像发布与回滚 |
| 可观测性 | 无统一 metrics、readiness、告警和 dashboard | 落地 §10 的最低监控集；`/health` 只表示进程存活不能替代依赖健康 |

### 1.3 已确认在线

- Matrix/Tuwunel：`m.si46.world`，`/_matrix/client/versions` HTTP 200，服务端为
  Tuwunel 1.8.2。
- Matrix federation discovery：`m.si46.world/.well-known/matrix/server` 返回
  `m.si46.world:8448`，8448 TLS 可握手。
- Matrix 密码/Token 登录：登录 flows 可发现。
- Matrix Push Gateway：`POST /_matrix/push/v1/notify` 能进入参数校验，空请求返回
  400 而非 404。
- MatrixRTC 官方授权服务：`POST /livekit/jwt/sfu/get` 能进入参数校验，空请求返回
  `M_BAD_JSON`。
- LiveKit SFU 反代入口：`/livekit/sfu` HTTP 200。
- TURN：`turn.si46.world:443` TCP/TLS 可连接。
- API Proxy：未带令牌返回 401，说明网关路由在线；还需带生产令牌做功能验收。
- Market、Wallet、User Center 代表接口均 HTTP 200；Face 代表 POST 空请求返回 400，
  说明路由存在。
- ID Hub：`https://id.n42.ai/health` HTTP 200；challenge 空请求返回结构化 400。
- N42 RPC：主网 `eth_chainId=0x5e`（94），测试网 `0x476`（1142）。
- 四个仓内 Go 服务均 `go test ./...` 通过，四个 Dockerfile 均可从零构建。

## 2. 服务关系与责任边界

```text
N42 Wallet / packages/n42_chat
├─ api.n42.ai (Nginx/API Gateway)
│  ├─ 已有旧服务：market / wallet / user / face / proxy
│  ├─ 待恢复：activity / otc / nft-market
│  └─ 待部署：swap / loyalty / airdrop（airdrop 代码不在本仓）
├─ id.n42.ai (独立 ID Hub；代码不在本仓)
└─ m.si46.world (Chat)
   ├─ Tuwunel homeserver + Matrix media
   ├─ Matrix push gateway → FCM / APNs
   ├─ MatrixRTC auth service → LiveKit SFU
   ├─ backend/livekit-jwt（待部署，直播角色限权）
   └─ TURN turns:turn.si46.world:443

社交登录
├─ backend/social-auth（Discord/GitHub/Telegram；待部署）
└─ api.n42.network（Google/Apple/Facebook/Twitter/WeChat；当前 DNS 缺失）
```

下列功能没有独立后台，不应另建服务：

- Chat E2EE、SQLCipher 归档、全局归档搜索：设备本地。
- Moments、Story/Watch、Nearby、Listen、频道发现、直播弹幕/礼物/预测事件：Matrix
  房间事件与媒体；Nearby/Listen 不需要额外 REST 服务。
- 当前直播礼物与预测是 play-money/Matrix 事件，不是链上资金服务。
- 图片 OCR：端侧 ML Kit/Vision；无云端 OCR 后端。
- 治理：Snapshot 公共 GraphQL/Hub，宿主已直接启用。
- 自毁消息、隐藏/加锁搜索和通知过滤：客户端安全边界；推送网关仍必须只发送
  不含明文的 Matrix 通知载荷。

## 3. 仓内可部署后端

### 3.1 `backend/livekit-jwt`

用途：用 Matrix access token 验证 `whoami`、房间成员关系与直播房创建者，然后签发
短时 LiveKit JWT。直播房只有创建者可发布；普通群通话仍允许所有成员发布。

必需环境变量：

| 变量 | Secret | 说明 |
|---|---:|---|
| `MATRIX_HOMESERVER` | 否 | 固定 `https://m.si46.world` |
| `LIVEKIT_API_KEY` | 是 | 与生产 LiveKit 一致 |
| `LIVEKIT_API_SECRET` | 是 | 只进 Secret Manager |
| `TOKEN_TTL` | 否 | 默认 `15m`，允许范围 1m–1h |
| `PORT` | 否 | 默认 8080 |

关键代理契约：路径必须精确，不能 301/308，不能把 POST 改成 GET，也不能将 access
token 转发到其他 host。

```nginx
location = /livekit/jwt {
    proxy_pass http://n42-livekit-jwt:8080/livekit/jwt;
    proxy_set_header Authorization $http_authorization;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

部署验收：

1. 无 token 请求返回 401 JSON，不能返回 301/404/HTML。
2. 主播 token 中 `video.canPublish=true`。
3. 观众用 `role=broadcaster` 伪造、以及完全省略 `role` 两次请求，token 中均应
   `canPublish=false`、`canSubscribe=true`。
4. 普通群通话双方仍能发布音视频。
5. 对照 `backend/livekit-jwt/ROLE_ENFORCEMENT.md` 执行完整矩阵。

缺口：服务没有独立 `/healthz`/`/readyz`；部署系统可暂以“无 token 返回 401”作为
liveness，readiness 应另加 Matrix 与 LiveKit 配置检查。

### 3.2 `backend/social-auth`

用途：Discord/GitHub/Telegram 身份校验后，经 Matrix shared-secret registration
签发稳定 Matrix 账号。生产 homeserver 虽是 Tuwunel，不是 Synapse，但实测
`GET /_synapse/admin/v1/register` 能返回 nonce，兼容接口存在。

必需/按 provider 启用的环境变量：

| 变量 | Secret | 注意 |
|---|---:|---|
| `MATRIX_HOMESERVER` | 否 | `https://m.si46.world` |
| `MATRIX_SHARED_SECRET` | 是 | 必须与 homeserver 配置完全一致 |
| `MATRIX_PASSWORD_SECRET` | 是 | **必须备份，不能直接轮换**；轮换会使已有派生账号无法登录 |
| `DISCORD_CLIENT_ID` | 否 | Discord OAuth App |
| `DISCORD_CLIENT_SECRET` | 是 | 仅后端 |
| `GITHUB_CLIENT_ID` | 否 | GitHub OAuth App |
| `GITHUB_CLIENT_SECRET` | 是 | 仅后端 |
| `TELEGRAM_BOT_TOKEN` | 是 | BotFather，另需 `/setdomain` |
| `CORS_ORIGINS` | 否 | Web 使用时严格列出；原生 App 不依赖 CORS |
| `TELEGRAM_AUTH_TTL_SECONDS` | 否 | 默认 86400 |

上线步骤：

1. 创建 `social-auth.n42.ai` DNS 与 TLS。
2. 镜像以 commit SHA 标记并以非 root 用户运行；当前 scratch Dockerfile 未显式
   `USER`，部署层先强制 `runAsNonRoot`。
3. 只开放 443；`/_synapse/admin/v1/register` 不应暴露给公网代理之外的任意调用方。
4. 对 `/v1/user/loginSocial` 加 IP/设备/provider 级限流和失败告警。
5. `GET /health` 必须 200；再分别完成三家真实 OAuth 回调和重复登录一致性测试。

旧五家当前仍固定走 `https://api.n42.network`，而该域名无 DNS。必须二选一：

- 恢复旧服务与 DNS；或
- 扩展 `backend/social-auth/providers.go` 支持旧五家，并将 Chat 的两个
  `SocialAuthApi` 都统一指向新域名。

仅部署新三家不会修复 Google/Apple 等旧登录。

### 3.3 `backend/swap`

用途：1inch/Jupiter/Uniswap 聚合报价、交易提交记录、限价单状态、价格预警和链上
确认监视。服务不保存用户私钥，限价单触发后也不能代签成交。

依赖与环境变量：

- PostgreSQL：`DB_DSN`，要求 TLS、独立用户、PITR。
- `INCH_API_KEY`。
- `ETH_RPC`、`BSC_RPC`、`POLYGON_RPC`、`ARB_RPC`、`OP_RPC`。
- 可选 `COINGECKO_BASE`、`COINGECKO_API_KEY`、`PUSH_WEBHOOK_URL`、
  `CORS_ORIGINS`、`PORT`。
- README 还列出 `SOL_RPC`，但当前 `main.go` 未读取；这是文档/实现不一致，
  运维不能认为配置后 Solana 确认监视就会自动生效。

网关必须剥离 `/swap` 前缀，因为 Go 路由自身从 `/v1/dex` 开始：

```nginx
location /swap/ {
    proxy_pass http://n42-swap:8080/;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

上线红线：当前服务没有 token 鉴权。在挂公网前，网关或服务必须校验宿主已有的
`UUID`/`Token`，并将已验证用户写入可信 header；不得接受客户端 body/query 中的
任意 `uuid` 作为身份。价格 webhook 必须签名，接收端要去重。

健康检查 `GET /health` 当前只检查进程，不检查 PostgreSQL、RPC、1inch、CoinGecko。
readiness 至少检查 DB；上游状态应做独立 synthetic probe，不能因单一第三方抖动
将整个 Pod 摘除。

### 3.4 `backend/loyalty` + `contracts/loyalty`

正确上线顺序：

1. 在 N42 testnet（1142）部署 `N42LoyaltyPoints`，验证源码与 owner/operator。
2. 给 relayer 地址仅充值可控上限的测试网 Gas，跑签到/任务/推荐/重放测试。
3. 主网（94）重新部署并验证；合约 owner 建议多签，relayer 只持 operator 权限。
4. 建 PostgreSQL，启用 TLS/PITR，部署 `backend/loyalty`。
5. 设置 `LOYALTY_CONTRACT_ADDRESS`、`N42_RPC_URL`、`AUTH_VERIFY_URL`。
6. `RELAYER_PRIVATE_KEY` 与 `INTERNAL_API_TOKEN` 只进 Secret Manager；后者至少 32 字符。
7. 外部保留 `/loyalty/v1/*`，内部奖励路由只允许可信服务网络访问。

该服务的 `/healthz` 也只代表进程。readiness 需要 DB ping、RPC chain ID、合约 bytecode
存在、relayer Gas 余额阈值；交易失败率与 pending 时长必须告警。

## 4. Chat/Matrix 基础设施

### 4.1 Homeserver

生产为 Tuwunel 1.8.2。最低运维资产：

- homeserver 主数据库、配置、server signing key、media store 的备份与恢复演练；
- 磁盘容量、`/_matrix/client/v3/sync` 延迟、5xx、房间/媒体增长监控；
- 注册速率、登录失败、异常设备创建、媒体上传大小限制与滥用治理；
- Federation discovery 与 8448 TLS 本轮通过；仍需持续监控 federation transaction
  失败、队列积压和远端签名校验，不能只依赖端口存活；
- E2EE 明文不在服务端，备份 homeserver 不能替代用户 recovery key/key backup。

当前登录 flows 没有 `m.login.sso`。运维启用 OIDC/SSO 后，应先确认：

```bash
curl -fsS https://m.si46.world/_matrix/client/v3/login | jq '.flows'
```

结果必须出现 `m.login.sso`，再开启客户端入口。

### 4.2 Push Gateway、FCM、APNs

客户端注册的 app ID 是：

- Android：`ai.n42.www.android`
- iOS：`ai.n42.www.ios`

推送服务必须配置完全一致的两项。运维需确认：

1. Sygnal/网关持有当前 FCM service account 与 APNs `.p8`、Key ID、Team ID、Topic。
2. APNs 生产环境 Topic 与 `ai.n42.www` 一致；iOS app ID 的 `.ios` 后缀是 Matrix
   pusher app ID，不是 APNs bundle ID。
3. 用真实账号在 Matrix `GET /pushers` 中看到当前设备 token 与正确 app ID。
4. 前台、后台存活、进程被杀三态均送达；隐藏/加锁会话不应弹出内容。
5. 网关不得记录完整 push token、Matrix access token 或消息明文。

仓库中 Firebase 配置文件被正确忽略，本机存在不代表 CI/运维机器具备。CI 必须从
Secret Manager 临时生成 `android/app/google-services.json` 与
`ios/Runner/GoogleService-Info.plist`，构建后销毁。

### 4.3 TURN、MatrixRTC、LiveKit

- `turns:turn.si46.world:443` TCP/TLS 本轮可达；还需用 coturn 测试工具分别验证
  UDP、TCP、TLS relay，而不是只做端口探测。
- 官方 MatrixRTC `/livekit/jwt/sfu/get` 在线，LiveKit `/livekit/sfu` 在线。
- `/.well-known/matrix/client` 当前只公布 `livekit_service_url`，客户端由此派生官方
  token 与 SFU 地址。
- 直播角色必须由 §3.1 legacy 服务强制；官方回退只能作为普通群通话兼容路径。
- 监控 LiveKit room/participant 数、连接失败、ICE failure、egress 带宽、CPU、丢包，
  以及 JWT 401/403/502 和 `publish denied` 日志。

### 4.4 Passkey

客户端调用的 MSC3824 路径当前 404。`/_matrix/client/versions` 中出现相关 unstable
flag 不足以证明端点已部署。上线必须完成注册 challenge、complete、login challenge、
login、credentials 五条路径的真实凭据测试，并配置正确 RP ID/Origin；否则关闭入口。

## 5. `api.n42.ai` 网关与旧服务

### 5.1 2026-08-24 无凭据探测结果

| 服务 | 代表路由 | HTTP | 定性 |
|---|---|---:|---|
| Market | `/market/v1/r/targetCoinMarketsList?coin=BTC` | 200 | 在线 |
| Wallet/ENS | `/wallet/v1/ens/resolve?domain=vitalik.eth` | 200 | 在线 |
| User Center | `/user/v1/r/static/app/version?...` | 200 | 在线，但返回的版本样例仍为 1.0.0，需核对业务数据 |
| Face | `/face/detect_face` 空 POST | 400 | 路由在线，参数校验生效 |
| Proxy | `/proxy/v1/market/trending` 无 token | 401 | 在线，鉴权生效；需带生产 token继续验收 |
| Swap | `/swap/v1/dex/tokens?chain=ETH` | 404 | 未部署/未路由 |
| Loyalty | `/loyalty/...` | 404 | 未部署/未路由 |
| Airdrop | `/airdrop/v1/airdrops` | 404 | 未部署/未路由 |
| Activity | `/activity/v1/...` | 502 | upstream 故障 |
| Onramper | `/otc/r/onramper/url` | 502 | upstream 故障 |
| NFT Market | `/nft-market/v1/image/url` | 404 | 路由或旧服务不一致 |

404 的 base URL 本身不一定异常，因此表中均选了代码实际使用的代表业务路径；上线
验收仍应使用有效参数和测试账号完整验证响应 schema，不能只看 HTTP 200。

### 5.2 网关统一要求

- TLS 1.2+、HSTS、合理 request/body 限制、真实客户端 IP、统一 request ID。
- 上游 connect/read/write timeout、熔断、限流和每路由独立 5xx 告警。
- `/healthz` 为进程存活，`/readyz` 为依赖就绪；不要把需鉴权的业务路由当健康检查。
- 面向 App 的错误保持 JSON，不返回 Nginx HTML；严禁在响应中泄漏 upstream 地址。
- CORS 只影响浏览器，不是鉴权；原生 App 可绕过 CORS。
- 写接口必须鉴权、幂等并带审计日志；资金相关响应必须由客户端再次校验链、合约、
  router、金额与 calldata。

## 6. Release 配置与密钥边界

### 6.1 当前缺口

- `scripts/prepare_android_release.sh` 会把 `.env` 中**所有**非空 `KEY=value` 都变成
  `--dart-define`，容易把服务端 secret 塞进客户端。
- `scripts/prepare_ios_release.sh`、`scripts/build_ipa.sh` 和根 `build_ipa.sh` 均不加载
  `.env`。
- `.github/workflows/release.yml` 的 Android/iOS 构建均不传 dart-defines。
- 因此本地 Android、CI Android、TestFlight 三类包的功能集合可能完全不同。
- 所有 GitHub workflow 固定 Flutter 3.41.9，其自带 Dart 3.11.5；根应用和 Chat 当前
  都要求 Dart `>=3.12.2`，clean runner 上会在 `pub get` 阶段失败。
- Release workflow 引用不存在的 `ios/ExportOptions.plist`（仓内只有
  `ios/ExportOptions-AppStore.plist`），且虽读取 `APP_STORE_CONNECT_API_KEY` secret，
  却没有把 `.p8` 写入 altool 能发现的位置；自动 iOS 上传链路不完整。
- 当前 `.env.example` 缺 `AIRDROP_API_BASE_URL`、`LOYALTY_API_BASE_URL`、
  `N42_CHAT_DISCORD_CLIENT_ID`、`N42_CHAT_GITHUB_CLIENT_ID`、
  `N42_CHAT_TELEGRAM_BOT_ID`、`N42_CHAT_SOCIAL_AUTH_BASE_URL`、`WC_PROJECT_ID` 等新项。

### 6.2 必须采用 allowlist

建议由 CI 在临时目录生成 `release-defines.json`，只允许经过审查的客户端配置：

- 公开 base URL、OAuth client ID、Telegram bot ID、WeChat app ID；
- `AI_BASE_URL`、`AI_MODEL`、`AZURE_SPEECH_REGION` 等非敏感配置；
- 必要 feature flag；
- 暂时需要的受限 client key 必须在供应商后台限制 bundle ID/package、API、额度和域名。

以下内容不得作为长期方案进入 App：

- 后端 OAuth client secret、Matrix shared secret/password secret；
- LiveKit API secret、relayer/deployer 私钥、数据库 DSN、internal token；
- MoonPay server secret、IPFS 写凭据、未限制的 AI/Google Speech/Translate/Azure/
  DeBank/Alchemy/HuggingFace token；
- FCM service account、APNs `.p8`；
- 通用静态 `PROXY_AUTH_TOKEN` 只能作为过渡方案，因为客户端二进制可被提取；应迁移
  为短时 token、设备证明或登录态换票，并配置最小权限/速率/可轮换。

构建门禁至少验证：

1. 目标环境、bundle/package、API base URL 正确。
2. 必选公开配置齐全，禁用项不显示 UI。
3. 黑名单 secret 名称没有出现在 dart-defines、构建日志、IPA/APK/AAB 字符串中。
4. iOS/Android 对同一功能使用同一份 schema 化配置。
5. 产物生成 SBOM、SHA-256、签名/entitlement 报告并与 commit SHA 绑定。
6. CI 使用与生产构建相同且满足 Dart 约束的 Flutter toolchain；任何 tag 发布前先在
   clean runner 完成不上传的 archive/export dry-run。

## 7. Chat 插件源代码发布一致性

主应用 `pubspec.yaml` 声明 Git ref `edbb27f...`，但已提交的
`pubspec_overrides.yaml` 将 `n42_chat` 覆盖为 `packages/n42_chat`。因此：

- Wallet 正式包实际编译 vendored `packages/n42_chat`；改 Git ref 不会改变产物。
- 独立仓 `../n42_chat` 当前 `main@491e595` 与 vendored 目录存在多处差异；vendored
  还独有 Nearby/Listen/friendly display name 等主应用集成代码，独立仓也有其独有改动。
- 运维不能把“独立 chat 仓已推送”等同于“Wallet 中 chat 已发布”。

发布时必须在构建日志打印并归档：Wallet commit、vendored Chat tree hash、
`pubspec.lock` hash。建立单一同步方向和自动 diff 门禁；在未完成同步前，不要移除
`pubspec_overrides.yaml`，否则 clean build 会静默换成另一份 Chat 源码。

## 8. Mini-app 与外部 SaaS

### 8.1 内置 mini-app

以下域名当前全部无 DNS：

- `swap.n42.world`
- `bridge.n42.world`
- `nft.n42.world`
- `shop.n42.world`
- `creator.n42.world`
- `portfolio.n42.world`
- `charts.n42.world`

每个入口上线前需有 DNS/TLS、CSP、`frame-ancestors`/WebView 策略、钱包桥 origin
allowlist、隐私政策和健康检查。未部署的入口应从生产目录隐藏，不能展示可点击空壳。

### 8.2 Chat 直接依赖的第三方

| 功能 | 第三方 | 无配置行为 | 运维要求 |
|---|---|---|---|
| AI | OpenAI-compatible/Groq | 规则降级或功能不可用 | 优先后端代理，限模型/额度/日志脱敏 |
| 翻译 | Google；MyMemory fallback | 可走免费 fallback | 敏感消息默认不应无提示外发；设置隐私说明 |
| STT | Google/Azure | 不注册/不可用 | 音频属敏感数据，密钥走后端、设置留存策略 |
| GIF | Giphy/Tenor | 面板提示未配置 | 使用受限 client key 或代理 |
| Social Graph | DeBank/Alchemy | DeBank 无 key 时入口关闭 | 限额、缓存、地址隐私告知 |
| Governance | Snapshot | 公共服务直连 | 监控失败率；签名前显示域名/内容 |
| Push Protocol | EPNS public API | 轮询失败 | 只读、限频、缓存 |
| Fiat ramp | MoonPay/Transak | 未配置提示 | 仅使用 publishable key，服务端 secret 不进 App |
| 地图 | OpenStreetMap tiles | 直接访问 | 遵守 tile usage policy，量大需自建/采购 |

## 9. 标准部署顺序

1. **冻结发布配置 schema**：先修 §6，保证测试包与正式包使用同一份可审计配置。
2. **备份与恢复演练**：Matrix DB/media/signing key、PostgreSQL、关键不可轮换 secret。
3. **恢复 Chat 登录**：部署 social-auth/DNS，明确旧五家去向；关闭未支持的 SSO/Passkey。
4. **部署直播限权**：精确挂载 `/livekit/jwt`，双账号验收伪造 role 与省略 role。
5. **部署 Swap**：PostgreSQL、鉴权、RPC/1inch、网关前缀、synthetic swap quote。
6. **部署 Loyalty**：测试网合约 → 主网合约 → relayer/API；设置 Gas 与失败告警。
7. **恢复旧网关服务**：Activity、Onramper、NFT；实现 Airdrop 或隐藏入口。
8. **处理 mini-app**：逐个部署，否则移除生产目录。
9. **接入 CI/CD、监控、告警、日志和回滚**。
10. **双端真机验收**：登录、消息/媒体/E2EE、三态推送、群通话、直播、钱包写操作。

每一步单独发布、单独回滚；不要一次性同时切 Matrix、LiveKit、Push 与 App 配置。

## 10. 最低监控、备份与值班要求

### 10.1 建议 SLO

- 用户登录/Matrix sync/API 核心读接口月可用性 ≥ 99.9%。
- 核心 API p95 < 800 ms；Matrix sync 长轮询按协议单独统计。
- Push 提交成功率、APNs/FCM 接收率、RTC join 成功率均建立基线和告警。
- relayer 交易成功率、pending 时间、Gas 余额；Swap quote 成功率与上游分布。

### 10.2 必须告警

- 任一生产 DNS 解析失败、TLS 剩余 < 21 天、证书链错误。
- API 5xx > 2%/5 分钟，登录失败突增，Matrix sync/media 5xx。
- PostgreSQL 连接耗尽、磁盘 > 75%/85%、备份失败、复制延迟。
- Push Gateway provider rejection、invalid token 激增。
- LiveKit/TURN join/ICE failure、JWT 401/403/502、观众意外获 publish grant。
- Loyalty relayer Gas 低于阈值、合约 paused/operator 变化。

本轮证书实测到期日均约为 2026-10-06（`m.si46.world`、`api.n42.ai`、
`id.n42.ai`、N42 explorer/RPC 域名）。应确认自动续期与失败告警，不能等临近到期
人工处理。

### 10.3 备份

- PostgreSQL：每日全量 + 连续 WAL/PITR；至少每月恢复演练。
- Matrix：数据库、media、配置、server signing key 一致性快照。
- 不可轮换/高影响 secret：`MATRIX_PASSWORD_SECRET`、Matrix signing key、合约 owner
  恢复材料；双人审批、离线副本。
- 镜像：保存 digest、SBOM、签名、commit、配置 schema 版本；保留至少两个可回滚版本。

## 11. 上线验收命令

以下均不得在工单或聊天中粘贴真实 token；输出也要脱敏。

```bash
# Matrix 基础与登录能力
curl -fsS https://m.si46.world/_matrix/client/versions | jq .
curl -fsS https://m.si46.world/_matrix/client/v3/login | jq .flows

# Matrix/RTC 发现
curl -fsS https://m.si46.world/.well-known/matrix/client | jq .

# Legacy LiveKit：部署后无 token 必须是 401 JSON，不得 301/404
curl -i -X POST https://m.si46.world/livekit/jwt \
  -H 'Content-Type: application/json' -d '{}'

# 仓内服务内部健康
curl -fsS http://n42-swap:8080/health
curl -fsS http://n42-loyalty:8080/healthz
curl -fsS http://n42-social-auth:8090/health

# 生产业务路由（部署后）
curl -fsS 'https://api.n42.ai/swap/v1/dex/tokens?chain=ETH'
curl -fsS 'https://api.n42.ai/airdrop/v1/airdrops?page=1&page_size=1'

# N42 chain ID
curl -fsS https://rpc.n42.world -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"eth_chainId","params":[]}'
```

需凭据的验收不要只做 curl：必须用 Android+iOS 真机各完成一次登录、发消息/图片、
三态推送、群通话；直播需主播/观众两账号做权限对抗；Swap/Loyalty 需测试网链上 hash。

## 12. 尚需运维提供才能关单的信息

代码仓无法证明以下生产内部状态，运维上线时必须补齐到部署记录：

- `api.n42.ai` 当前 Nginx upstream/服务版本、主机/集群、owner 与回滚镜像。
- Tuwunel 数据库/media 路径、备份最近成功时间与恢复演练结果。
- Push Gateway 实现与版本、FCM/APNs credential 最近轮换日期、两个 app ID 映射。
- LiveKit 与 TURN 的版本、拓扑、容量、region、录制/日志留存策略。
- Proxy 带有效 token 的全路由 synthetic 结果。
- Loyalty 合约地址、验证链接、owner/operator、relayer 地址与 Gas 告警阈值。
- Swap PostgreSQL、鉴权实现、PUSH webhook 接收方和签名方案。
- Activity/Onramper/NFT 的 502/404 责任人和预计恢复时间。
- 各第三方 API 账户 owner、配额、账单告警和退出/降级策略。

## 附录 A：本机开发环境观察（不代表生产）

本机 Docker 中旧 `n42-id-hub-app-1` 正在重启循环，原因是其 PostgreSQL/Redis
容器已停止，应用报 `P1001 Can't reach database server at postgres:5432`；重启次数已
超过 33,000。生产 `https://id.n42.ai/health` 当前仍为 200，因此这是本机残留开发栈，
不是生产故障。应由本机维护者选择：完整启动依赖后修复，或停止该 compose 项，避免
持续消耗 CPU/日志；不要删除 volume，除非已确认数据可丢弃或已有备份。

## 附录 B：本轮验证证据

- `go test ./...`：`livekit-jwt`、`social-auth`、`swap`、`loyalty` 全通过。
- 四个 Dockerfile：均可 `docker build --pull` 成功。
- 网络探测时间：2026-08-24 01:50–02:00 EDT；HTTP 状态只反映该时间点。
- 未使用真实用户 access token、OAuth code、推送 token、数据库或 relayer 密钥。
