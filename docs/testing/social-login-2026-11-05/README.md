# N42 social login integration — 2026-11-05

## Scope

N42 wallet host only; 11x and Mintus were read-only references. Their public capability endpoints advertise Google, Apple and Facebook, but their application IDs, account identities and credentials must not be reused for N42. Ordinary app/Matrix identity and an embedded wallet's signing identity remain separate.

## Implemented

- Google: iOS callback URL scheme can now be configured from `ios/Flutter/ChatSocialAuth.xcconfig`; native configuration reports the actual registered scheme. The host enables iOS/macOS Google only when it matches the iOS OAuth client ID, and Android requires the web/server client. Whitespace and unresolved environment placeholders do not activate a provider. Chat requires an actual Google ID token instead of substituting an access token and no longer logs the email address on success.
- Apple: keep the existing native entitlement and nonce flow; user cancellation now returns normally from Chat authentication.
- Facebook: preserve the classic Android payload. Limited Login uses its ID token and matching request nonce, never calls Graph with that token, and forwards `token_type=limited` and `nonce` through service, BLoC, repository and API. Only `public_profile` is requested. iOS activation is explicit because the external backend's Limited Login verifier is not yet confirmed.
- Embedded wallet: add Facebook alongside Google/Apple and existing options. Register the Web3Auth adapter lazily from explicit N42 build configuration. Serialize login attempts, invalidate late results after logout/disposal, validate secp256k1 keys, and replace the cached signer on account switch. No raw SDK errors are shown in the UI.
- Wallet UI: preserve existing providers, scroll on small screens, disable unavailable/repeated actions, treat cancellation normally, check the owning account after authorization, reuse an existing provider/address entry, and let the calling menu perform its own single pop.

## Configuration still required

### App/Chat identity

1. Register N42's iOS OAuth client for `ai.n42.www` and the Android signing certificate/package. Firebase configuration files in this checkout contain no Google OAuth client IDs; they are not sufficient to enable login.
2. Copy `ios/Flutter/ChatSocialAuth.xcconfig.example` to the ignored `ChatSocialAuth.xcconfig`. Set the iOS client ID, web/server client ID and matching reversed iOS client ID. `Runner/Info.plist` now consumes the reversed ID. Do not use the web client ID as the iOS callback scheme. Configure Android `n42_chat_google_server_client_id` or its existing `default_web_client_id` fallback.
3. Confirm N42 Apple entitlement/provisioning and the server audience/nonce verification. Existing Apple native integration remains enabled on supported platforms.
4. Before `--dart-define=N42_CHAT_FACEBOOK_IOS_ENABLED=true`, register N42's iOS bundle with the N42 Meta app and validate the external `https://api.n42.network/v1/user/loginSocial` implementation. It must verify the Limited Login JWT signature against Meta keys, issuer, N42 audience, expiry and exact nonce; reject malformed, wrong-app and wrong-nonce proofs. Client nonce comparison is not server token verification. Do not feed the ID token to Graph `debug_token` or `/me` as an access token.

The external login backend's source/configuration was not found in this workspace. The local `backend/social-auth` service currently handles Discord/GitHub/Telegram and has not been substituted for existing accounts. No provider registration, backend deployment or account migration is claimed.

### Embedded wallet identity

Use the existing Web3Auth 7.0.1 SDK (8.x requires a separate native SPM migration). Configure the N42 dashboard project, social connections, bundle/package, and exact `n42://auth` redirect. For a controlled development build:

```text
--dart-define=N42_MPC_ENABLED=true
--dart-define=N42_WEB3AUTH_CLIENT_ID=<N42 public client ID>
--dart-define=N42_WEB3AUTH_NETWORK=sapphire_devnet
```

The adapter also accepts `sapphire_mainnet` explicitly. The network and project determine wallet identity; do not silently change them for existing accounts. Missing/invalid configuration keeps the feature unavailable. Do not place a provider App Secret or private key in Dart defines.

This is **login/recovery integration, not production payment acceptance**. The existing `MpcTransferHandler` is a proof of concept, not an RPC broadcast path. It and the existing transaction-signing integration require separate completion before using real funds. This task does not enable the feature in production. The SDK currently returns a reconstructed private key in memory; this is not evidence of a threshold-signing-only architecture. Existing MPC marketing copy and transaction routing require review before rollout.

## Validation

- Final wallet host platform/configuration, SDK-channel and small-screen UI regression: **56 passed**.
- Chat SDK-channel/API/repository/BLoC regression: 67 tests passed, including Limited Login nonce mismatch and no-Graph assertions.
- Whole host and Chat analysis: no errors or warnings; existing informational lints remain.
- iOS unsigned Debug device build: **passed**, including pod installation and native Swift compilation (Xcode build 58.4 seconds). No signed archive or upload was performed.
- `plutil -lint ios/Runner/Info.plist`: passed.
- Chat immutable dependency: `bff9ae3fa8d9075463c28ca0ad4db8de77ee7c5a` on `fix/n42-social-login-20261105`.
- No real Google/Apple/Facebook authorization, first/repeat-account provisioning, physical-device restore, TestFlight upload or production deployment is claimed. Real-device QA remains deferred per prior user instruction.

## References

- MetaMask Flutter SDK: https://docs.metamask.io/embedded-wallets/sdk/flutter/
- MetaMask Facebook connection: https://docs.metamask.io/embedded-wallets/authentication/social-logins/facebook/
- Apple-platform Facebook Limited Login and nonce verification: https://firebase.google.com/docs/auth/ios/facebook-login

## Historical configuration search and 11x reuse

- Scanned 49 matching prior session records for populated N42 Google/Web3Auth assignments; none were found. Inspected all historical revisions of the host Firebase iOS/Android files: neither contained an N42 OAuth client. No committed/local `ChatSocialAuth.xcconfig` was found.
- 11x's controlled Google/Apple/Facebook provider files exist (mode 0600). Their values were not printed or copied into the wallet. These are Club web provider configurations, not N42 native registrations.
- The shared `n42-id-hub` has a working Club-specific social implementation, but `/v1/auth/social` still explicitly returns `not-implemented`. The Club Matrix session route requires a verified Club PDS session, and identity subjects are namespaced `club:<provider>:<subject>`. Simply changing N42's URL to that route cannot authenticate N42's existing native payload.
- Reuse option: retain the 11x developer projects and verifier implementation, add N42's own native registrations/callbacks and an N42-scoped service adapter. Preserve existing N42 account mappings; explicitly link accounts if shared Club identity is later desired. Embedded-wallet Web3Auth project configuration remains separate.

- Live Google Cloud check: the existing 11X Club project opens, but the console blocks access until the owner enables two-step verification. No client was created or changed. The user must complete this authentication-setting step personally; no security bypass was attempted.
- The older sibling `n42app` Firebase iOS/Android files likewise contain no OAuth clients.

## Source delivery

- `e26f09c14`: native app login configuration and immutable Chat dependency.
- `2c405bacd`: social wallet provider registration, Facebook, session isolation and UI recovery.
- The debug app was built at `2.5.3+73121` before commit hooks incremented the development build number. Subsequent runtime changes were formatting only. No TestFlight artifact was produced.
