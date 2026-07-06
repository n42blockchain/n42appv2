# 第三方登录补齐方案（Chat）

> 2026-07-06 整理。Chat 社交登录经 `packages/n42_chat` 的 `AuthMethodsService` 发起，
> 用第三方 token 调**外部后端** `api.n42.network/v1/user/loginSocial` 换取 Matrix 账号凭据
> （`matrix_user_id`/`access_token`/`device_id`/`homeserver`）。UI 在
> `social_login_buttons.dart`，宿主经 `ChatSocialAuthConfig` + `N42ChatConfig` 注入 key 与开关。

## 一、现状盘点（已对接）

| Provider | 状态 | 依赖 / gating | 备注 |
|---|---|---|---|
| **Google** | ✅ 接通 | `googleConfigured`（`CHAT_GOOGLE_CLIENT_ID` dart-define）才显示 | `google_sign_in` 7.x |
| **Apple** | ✅ 接通 | `Platform.isIOS \|\| isMacOS` | `sign_in_with_apple`，平台原生无需 key |
| **Facebook** | ✅ Android / ⚠️ iOS 待启用 | `enableFacebookLogin: Platform.isAndroid` | Android 配全（app_id `903080600916838`）。**iOS Info.plist 已于本次补齐基建**，待启用见 §2 |
| **Twitter/X** | ⚠️ 老化风险 | `twitterConfigured`（key+secret）| `twitter_login` 用 **OAuth 1.0a**，X 免费档已限制，见 §2 |
| **WeChat** | ✅ 接通 | `weChatConfigured` + 设备装微信 | `fluwx` |
| **Wallet** | ✅ N42 特色 | `IWalletBridge` 已注册 | 钱包签名登录 |
| SSO（Matrix identity_providers） | ✅ | homeserver 有配置 | 通用 SSO |
| Email/用户名+密码 | ✅ | — | 直连 Matrix |

**结论**：主流五家 + 钱包 + 密码已覆盖，gating 均为“缺 key/平台不支持则隐藏”的正确降级。

## 二、修现有

### 2.1 Facebook iOS 启用（基建已补，待外部 + 一行 gating）
- **已完成（本次）**：`ios/Runner/Info.plist` 补 `FacebookAppID`/`FacebookClientToken`/`FacebookDisplayName`、
  `CFBundleURLSchemes` 加 `fb903080600916838`、`LSApplicationQueriesSchemes` 加
  `fbapi`/`fb-messenger-share-api`/`fbauth2`/`fbshareextension`。
- **待外部**：在 Facebook Developer 后台给该 App 添加 iOS 平台 + Bundle ID `ai.n42.www`。
- **启用开关**：外部配好后，把 `chat_initialization.dart:171`
  `enableFacebookLogin: Platform.isAndroid` 改为 `Platform.isAndroid || Platform.isIOS`。
  （现保持 Android-only，避免 iOS 后台未配时点击报错。）

### 2.2 Twitter/X OAuth 升级评估
- 现用 `twitter_login`（OAuth 1.0a，apiKey/apiSecret）。X 自 2023 起免费档不再发放 1.0a 登录权限，
  存量 App 亦可能被限。**需拿真 key 真机验一次**；若失效，迁移到 OAuth 2.0 PKCE
  （用 §3 的 WebView 通用方案，authorize `https://twitter.com/i/oauth2/authorize`）。

### 2.3 端到端一致性
- 各 provider 的 `signInWithX → SocialAuthApi.loginWithX → loginSocial → Matrix` 链路代码层完整；
  真机每家走一遍（依 key 可用性），确认“按钮显示 == 能登录成功”。

## 三、补新 Provider（Discord / GitHub / Telegram）

**通用方案**：Discord/GitHub 是标准 OAuth2 Authorization Code；复用 chat 已有的
`webview_flutter`（**零新依赖**）做授权页——打开 authorize URL、拦截 redirect 到
`n42app://oauth/<provider>`、取 `code`，交后端 `loginSocial` 换 Matrix。Telegram 用 Login Widget。

### 3.1 前端接入骨架（每家一致）
1. `n42_chat_config.dart`：加 `enableDiscordLogin`/`enableGithubLogin`/`enableTelegramLogin`（默认 false）。
2. `ChatSocialAuthConfig`（宿主）：加 `discordClientId`/`discordRedirectUri` 等字段 + `xxxConfigured` getter。
3. `chat_initialization.dart`：从 dart-define 读 client id，构造 config，设 `enableXxxLogin: xxxConfigured`。
4. `AuthMethodsService`：加 `isXxxAvailable()` + `signInWithXxx()`（WebView OAuth2 → code）。
5. `SocialAuthApi`：加 `loginWithXxx()` → `_loginWithSocialToken(provider: 'discord'|'github'|'telegram', ...)`。
6. `social_login_buttons.dart`：加按钮（gating `enableXxxLogin && isXxxAvailable`）+ `_handleXxxSignIn`。
7. `sso_brand.dart`：加品牌色/图标（Discord `#5865F2`、GitHub `#181717`、Telegram `#26A5E4`）。

### 3.2 OAuth 参数（外部注册后填）
| Provider | authorize endpoint | scope | 需注册拿到 |
|---|---|---|---|
| Discord | `https://discord.com/oauth2/authorize` | `identify email` | Client ID/Secret（Discord Developer Portal → App）|
| GitHub | `https://github.com/login/oauth/authorize` | `read:user user:email` | Client ID/Secret（GitHub → Settings → Developer settings → OAuth Apps）|
| Telegram | Login Widget / `oauth.telegram.org/auth` | — | Bot Token + domain 绑定（@BotFather）|

Redirect URI 统一 `n42app://oauth/callback`（已有 `n42app` scheme，Android/iOS 均注册）。

## 四、后端契约（外部 `api.n42.network`，本仓无代码 → 交外部团队）

`POST /v1/user/loginSocial` 现支持 `provider ∈ {google, apple, facebook, twitter, wechat}`。
**需新增** `provider ∈ {discord, github, telegram}` 的处理：

| provider | 前端提交字段 | 后端动作 |
|---|---|---|
| `discord` | `id_token`=OAuth2 access_token | 用 token 调 `https://discord.com/api/users/@me` 取 id/email，签发 Matrix 账号 |
| `github` | `id_token`=OAuth2 access_token | 调 `https://api.github.com/user`（+ `/user/emails`）取 id/email |
| `telegram` | 自定义 payload：`id`/`hash`/`auth_date`/`first_name`/`username` | 按 Telegram 文档用 Bot Token 校验 `hash`（HMAC-SHA256），验 `auth_date` 未过期 |

返回结构与现有一致（`data.matrix_user_id` 等）。**后端也可选择改为“前端只传 code、后端用 client_secret 换 token”**（更安全，client_secret 不落客户端）——推荐此方式，则前端提交 `code` + `redirect_uri`，§3.2 的 Secret 只存后端。

## 五、外部依赖清单（阻塞项）

补新 provider **前端做完也需以下外部就绪才能真用**（否则是“按钮显示但登录失败”的空壳，勿提前上线）：

1. **注册 App 拿 Client ID/Secret**：Discord App、GitHub OAuth App、Telegram Bot。
2. **dart-define 注入**（打包）：`CHAT_DISCORD_CLIENT_ID`、`CHAT_GITHUB_CLIENT_ID`、`CHAT_TELEGRAM_BOT_ID` 等。
3. **外部后端 `loginSocial` 加 3 个 provider 分支**（§4）。
4. Facebook iOS：后台加 iOS Bundle ID（§2.1）。

## 六、实施批次

- **批 1（本次）**：现状审计（本文档）+ Facebook iOS 基建（Info.plist）。
- **批 2**：Discord + GitHub 前端全链（§3，WebView OAuth2 模板），gating 默认关，待 client id。
- **批 3**：Telegram Login Widget 前端。
- **批 4**：外部就绪后逐家真机验 + 开 gating。
