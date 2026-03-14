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

N42_CHAT_TWITTER_API_KEY = your-twitter-api-key
N42_CHAT_TWITTER_API_SECRET = your-twitter-api-secret
N42_CHAT_TWITTER_REDIRECT_URI = n42://auth/twitter

N42_CHAT_WECHAT_APP_ID = wx1234567890abcdef
N42_CHAT_WECHAT_UNIVERSAL_LINK = https://your.domain.com/app/
```

## 2. Google Sign-In

Required:

- Replace `ios/Runner/GoogleService-Info.plist` with one that contains:
  - `CLIENT_ID`
  - `REVERSED_CLIENT_ID`
- Add `REVERSED_CLIENT_ID` to `CFBundleURLTypes` in `ios/Runner/Info.plist`

Minimal URL scheme entry:

```xml
<dict>
  <key>CFBundleTypeRole</key>
  <string>Editor</string>
  <key>CFBundleURLName</key>
  <string>google-signin</string>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>com.googleusercontent.apps.xxxxx</string>
  </array>
</dict>
```

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
