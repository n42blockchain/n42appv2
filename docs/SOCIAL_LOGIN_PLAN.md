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

### 3.3 精确接入点（基于代码，供下一批直接实现）

登录走 **BLoC 链路**（非直接调用），照 Twitter 现成模板逐处加：

| 层 | 文件:锚点 | 加什么（照现有 provider） |
|---|---|---|
| Event | `presentation/blocs/auth/auth_event.dart:275`（`AuthTwitterLoginRequested`）| `AuthDiscordLoginRequested`/`GitHub`/`Telegram`（带 `homeserver`）|
| Bloc handler | `presentation/blocs/auth/auth_bloc.dart:887`（`_onTwitterLogin`）+ `:56` on() 注册 | `_onDiscordLogin`：`authService.signInWithDiscord()` → `_authRepository.loginWithSocialToken(provider:'discord', idToken: code)` → `_completeAuthenticatedFlow` |
| Repository | `data/repositories/*auth*.dart:790`（`loginWithSocialToken` 的 provider switch，:821 起）| 加 `discord`/`github`/`telegram` case，调新 API 方法。**baseUrl 分流见下** |
| API | `data/datasources/remote/social_auth_api.dart`（`_loginWithSocialToken` 通用方法已 provider 参数化）| 加 `loginWithDiscord/GitHub/Telegram` 包装，或直接用通用方法 |
| Service | `services/auth/auth_methods_service.dart:175`（`initialize`）+ `signInWithTwitter` 模式 | `initialize` 加 `discordClientId` 等参数 + `_discordClientId` 字段；`isDiscordAvailable()`；`signInWithDiscord()`=**WebView OAuth2**（见下） |
| UI | `presentation/widgets/auth/social_login_buttons.dart:214`（Twitter 按钮）+ `:555`（`_handleTwitterSignIn`）| 加按钮（gating `enableDiscordLogin && isDiscordAvailable`）+ `_handleDiscordSignIn`（发 `AuthDiscordLoginRequested`）+ loading 字段 |
| Config(chat) | `n42_chat_config.dart:488`（`enableFacebookLogin`）| `enableDiscordLogin/GithubLogin/TelegramLogin`（默认 false）+ `socialAuthBaseUrl`（指向 `backend/social-auth`）|
| Config(宿主) | `core/platform/chat_social_auth_config.dart` + `core/app/chat_initialization.dart` | 加 `discordClientId` 等字段 + dart-define（`CHAT_DISCORD_CLIENT_ID` 等）+ `enableDiscordLogin: discordConfigured` |

**baseUrl 分流（关键）**：`SocialAuthApi` 默认 `api.n42.network`（旧五家）。新三家须指向自建
`backend/social-auth`——repository 持第二个 `SocialAuthApi(baseUrl: config.socialAuthBaseUrl)`
实例，对 `discord/github/telegram` 用它；旧五家继续用默认实例。

**WebView OAuth2 组件（新，Discord/GitHub 共用）**：新建
`presentation/pages/auth/oauth_webview_page.dart`——用 `webview_flutter`（已在依赖）打开
`authorizeUrl`，`NavigationDelegate.onNavigationRequest` 拦截前缀 `n42app://oauth/callback`，
从 query 取 `code`，`Navigator.pop(code)`。`signInWithDiscord()` 组装 authorize URL
（client_id + redirect_uri + scope + state）→ push 该页拿 code → 包成 `SocialLoginResult(accessToken: code)`。
后端 `backend/social-auth` 收 code→换 token（client_secret 在后端）。

**Telegram**：无标准 OAuth2，用 `oauth.telegram.org/auth?bot_id=...` 的 Login Widget（同 WebView 拦截
`tgAuthResult`），或深链到 Telegram App；拿到 `id/hash/auth_date/...` 传后端校验 hash。

## 四、后端（✅ 仓内自建 `backend/social-auth` 已实现）

> **2026-07-06 更新**：新三家的后端已在本仓自建完成——`backend/social-auth`（Go 纯标准库，
> 编译/vet/单测通过）。它实现 `POST /v1/user/loginSocial`，校验 Discord/GitHub OAuth2 与
> Telegram Login Widget 后，经 Matrix Synapse shared-secret registration **无状态签发 Matrix 账号**
> （localpart/password 由 identity 确定性派生，不存库），返回与 App 对齐的 `data.matrix_*`。
> 部署/env 见 `backend/social-auth/README.md`。App 侧把新三家 `baseUrl` 指向本服务即可
> （旧五家仍走外部 `api.n42.network`，或扩展 `providers.go` 的 `verifyProvider` 整体接管）。

外部 `api.n42.network` 的 `POST /v1/user/loginSocial` 现支持
`provider ∈ {google, apple, facebook, twitter, wechat}`。本仓 `backend/social-auth`
**补齐** `provider ∈ {discord, github, telegram}` 的处理：

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

- **批 1（已完成）**：现状审计（本文档）+ Facebook iOS 基建（Info.plist）。
- **批 1.5（已完成）**：后端 `backend/social-auth` 自建（Discord/GitHub/Telegram 的 loginSocial +
  Matrix 签发，编译/单测通过）。
- **批 2（✅ 已完成 2026-07-06）**：Discord + GitHub 前端全链——事件/Bloc handler/仓库分流/
  SocialAuthApi 方法/config 字段/`OAuthWebViewPage`（WebView OAuth2 授权组件）/登录按钮全部落地，
  gating 默认关（`enableXxxLogin && client id 已配 && socialAuthBaseUrl 已配` 三条缺一按钮隐藏）。
  `flutter analyze` 全绿。
- **批 3（✅ 已完成 2026-07-06，与批 2 合并交付）**：Telegram Login Widget 前端——
  `oauth.telegram.org/auth` WebView + fragment `tgAuthResult`(base64url JSON) 解析 → 事件 → 后端验 hash。
- **批 4（待外部）**：外部就绪（client id/bot id + 部署 social-auth + Facebook iOS 后台）后逐家真机验 + 配 dart-define 开 gating。

> **批 2/3 前端实现落点（2026-07-06）**：
> - chat：`social_auth_api.dart`(+loginWithDiscord/Github/Telegram)、`auth_repository_impl.dart`
>   (+3 case + 第二个 `SocialAuthApi` 后端实例)、`injection.dart`(按 `socialAuthBaseUrl` 注入后端实例)、
>   `auth_event.dart`(+3 事件)、`auth_bloc.dart`(+3 handler)、`bloc_message_keys/helper`(+3 错误键)、
>   `n42_chat_config.dart`(+enableXxxLogin/discordClientId/githubClientId/telegramBotId/oauthRedirectUri/socialAuthBaseUrl)、
>   **新建** `presentation/pages/auth/oauth_webview_page.dart`、`social_login_buttons.dart`(+3 按钮+handler+Telegram 结果解析)。
> - 宿主：`chat_social_auth_config.dart`(+3 家 configured getter + 后端基址)、
>   `chat_initialization.dart`(+dart-define `N42_CHAT_DISCORD_CLIENT_ID`/`N42_CHAT_GITHUB_CLIENT_ID`/
>   `N42_CHAT_TELEGRAM_BOT_ID`/`N42_CHAT_SOCIAL_AUTH_BASE_URL` + 接线)。
> - **回调无需注册 OS scheme**：`n42app://oauth/callback` 由 WebView `NavigationDelegate` 内部拦截，不外派到系统。
> - **注意**：这是"骨架就位待 client_id"代码，未真机验证；批 4 配齐外部依赖后才可真用。

### 前端接入的剩余外部前置（批 2/3 真用前）
1. 注册 Discord App / GitHub OAuth App / Telegram Bot，拿 client id/secret / bot token。
2. 部署 `backend/social-auth`，配 `MATRIX_SHARED_SECRET` 等 env（见其 README）。
3. App 侧新三家 `baseUrl` 指向部署地址。
