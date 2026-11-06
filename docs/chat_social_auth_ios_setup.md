# iOS Chat Social Auth Setup

This project already reads chat social auth settings from:

- `Runner/Info.plist`
- `ios/Flutter/ChatSocialAuth.xcconfig` via `Debug.xcconfig` and `Release.xcconfig`

## 1. Create the local xcconfig

Copy:

- `ios/Flutter/ChatSocialAuth.xcconfig.example`

to:

- `ios/Flutter/ChatSocialAuth.xcconfig`

Then fill:

```xcconfig
N42_CHAT_GOOGLE_CLIENT_ID = your-google-ios-client-id.apps.googleusercontent.com
N42_CHAT_GOOGLE_SERVER_CLIENT_ID = your-google-web-client-id.apps.googleusercontent.com
N42_CHAT_GOOGLE_REVERSED_CLIENT_ID = com.googleusercontent.apps.your-google-ios-client-id

N42_CHAT_TWITTER_API_KEY = your-twitter-api-key
N42_CHAT_TWITTER_API_SECRET = your-twitter-api-secret
N42_CHAT_TWITTER_REDIRECT_URI = n42://auth/twitter

N42_CHAT_WECHAT_APP_ID = wx1234567890abcdef
N42_CHAT_WECHAT_UNIVERSAL_LINK = https://your.domain.com/app/
```

## 2. Google Sign-In

Required:

- Register an iOS OAuth client for N42's `ai.n42.www` bundle and a server/web client.
- Fill all three Google values in the ignored local xcconfig. The registered
  URL scheme must be the reversal of the **iOS** client ID.
- `Runner/Info.plist` now consumes `N42_CHAT_GOOGLE_REVERSED_CLIENT_ID`; do not add
  a duplicate URL entry. The checked-in fallback is inert and will not enable login.
- A Firebase plist is also accepted for the iOS client ID if it contains `CLIENT_ID`,
  but its matching URL scheme still needs configuration. The current Firebase
  plist has no OAuth client ID.

See [the current acceptance record](testing/social-login-2026-11-05/README.md)
for Apple, Facebook Limited Login, embedded-wallet setup and remaining checks.

## 3. Twitter / X

Required:

- Fill `N42_CHAT_TWITTER_API_KEY`
- Fill `N42_CHAT_TWITTER_API_SECRET`
- Register callback URL `n42://auth/twitter` in the Twitter developer console

The project already declares the `n42` URL scheme, so no extra iOS URL scheme
is needed if you keep `n42://auth/twitter`.

## 4. WeChat

Required:

- Fill `N42_CHAT_WECHAT_APP_ID`
- Fill `N42_CHAT_WECHAT_UNIVERSAL_LINK`
- Register the same universal link in the WeChat open platform console

The project already includes:

- `LSApplicationQueriesSchemes` for `weixin` and `weixinULAPI`

Still required manually:

- Add the universal link domain to `ios/Runner/Runner.entitlements`

Example:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:your.domain.com</string>
</array>
```

## 5. Validation checklist

- Google button visible only when Google client config is present
- Twitter button visible only when both API key and secret are present
- WeChat button visible only when App ID is present and WeChat is installed
- SSO remains independent of the native social auth config
