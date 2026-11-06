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

The live registration update below supersedes the earlier missing-Google-client and MFA observations. Registration is not backend or real-login acceptance.

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


## Live registration update — 2026-11-05

The owner completed Google two-step verification. The console now permits access
to `coherent-window-511904-h1` (11X Club). N42's Firebase project
`n42app-2c9be` still requires additional access. The user confirmed N42-only scope
and `https://n42.world` as its Web origin, then authorized the separate Google
Web and Android registrations. The existing 11X Web client was retained.

| N42 client | Client ID prefix (all end in `.apps.googleusercontent.com`) | Binding |
| --- | --- | --- |
| iOS | `86606369466-cngdfceh70c1mjrvg2a48tkl4h3rn17o` | `ai.n42.www`, team `CFRXH38L48`, store `6738644072` |
| Web/server | `86606369466-a6heb4762hoke2cte8s1kq97to4pijk3` | JavaScript origin `https://n42.world` |
| Android Release | `86606369466-04f5alkovev0a4n5gj4mu1msk5ap93vo` | `ai.n42.www`, local release certificate |
| Android Debug | `86606369466-spjg0eqvge93f82abn7mm3rsmdfjo0sg` | `ai.n42.www`, local debug certificate |

Android SHA-1 registrations were checked against `:app:signingReport`:

- Release: `BB:DB:5C:75:6E:B2:76:1D:96:9E:A6:5D:64:0F:32:91:26:02:5D:E6`.
- Debug: `6A:76:27:48:F6:6F:52:68:B0:5A:71:B7:79:73:43:1D:27:B4:67:AE`.
- Google Play app-signing certificate is not yet verified; these registrations
  do not establish Play-distributed build support.

The iOS plist was downloaded and its bundle/client/reversed-client values checked.
The Web JSON is protected at `~/.config/n42/secrets/google-web-client.json` (0600,
parent 0700); do not commit or print its secret. The downloaded JSON also has 0600
permissions. Only public client IDs were placed in ignored local
`ios/Flutter/ChatSocialAuth.xcconfig` and `android/local.properties`. Other machines
and CI still need these public values configured; no credential was added to Git.

The Web registration currently has **no redirect URIs**. It supports the registered
JavaScript origin and acts as the native server client identifier. A future
server authorization-code flow must implement and register its exact callback.
The site currently serves static content; a HEAD probe of
`/v1/auth/n42/capabilities` returned 404. No login UI, callback, account service,
Web deployment or authenticated session is claimed from this registration.
The provider consent branding remains that of the shared Cloud project.

New verification:

- Platform configuration tests: 34 passed (`/tmp/n42-google-registration-tests.log`).
- Xcode Debug build settings resolve the N42 iOS ID, reversed scheme and new
  N42 Web/server ID (`/tmp/n42-google-config-settings.log`); this was not a new app build.
- Gradle Debug and Release resource generation passed
  (`/tmp/n42-google-android-res.log`); both XML resources match the Web/server ID.
- Live Google list contains all four N42 clients and the unchanged 11X Web client.

Apple console: team `CFRXH38L48`, N42 `ai.n42.www` already has Sign In with Apple
selected and is a primary App ID. The Services IDs list contains only Club and
Mintus entries; N42 needs its own Services ID and server configuration for
Web/Android browser authorization. No Apple identifiers or keys were changed.

Meta console: opening the existing N42 App ID `903080600916838` redirects to the
app list; the current account sees only Mintus and 11X Club. The user was asked to
provide access to the existing N42 app, or choose a new app with migration review.
Do not silently replace the app ID or assume that Club approval covers N42.

Remaining: external N42 backend verification and existing account mapping;
Google consent branding review; Apple Web/Android service and callback;
Meta app access/configuration and Limited Login verification; Web login UI and
server deployment; real provider authorization and first/repeat login acceptance.


## Apple Services ID update — 2026-11-05

The next live check found `N42 Wallet Web Login` / `ai.n42.www.web` already
registered by the owner. Sign In with Apple was configured for the existing
primary App ID `CFRXH38L48.ai.n42.www`, domain `n42.world`, and return URL
`https://n42.world/v1/auth/n42/social/apple/callback`.

The owner completed Save while the browser was shared. Reopening the Services ID
confirmed Sign In with Apple is selected. Reopening Configure and expanding the
Website URLs selector confirmed the exact domain and return URL are persisted.
No Club or Mintus identifier was modified.

This is provider registration only: the N42 callback is not yet implemented or
deployed. It must validate state and nonce, exchange the one-time authorization
code on the server, verify Apple's signature/issuer/audience/expiry, then resolve
the existing N42 account mapping. Do not point it at the Club PDS provisioning
flow or treat a provider token as a wallet signing key.

The owner registered the prepared `N42 Wallet Login` key (`CYCTXT3C2G`) and
explicitly confirmed creation/download and controlled storage. Only Sign in with
Apple was selected, associated with `ai.n42.www`. Chrome confirmed the 257-byte
`.p8` download completed. Both Downloads and the controlled copy have mode 0600;
`~/.config/n42/secrets` has mode 0700.

Controlled files (never commit or print their contents):

- `~/.config/n42/secrets/AuthKey_CYCTXT3C2G.p8`
- `~/.config/n42/secrets/apple-provider.json`

Node's crypto module verified the key is P-256 and generated an ES256 client
secret for `ai.n42.www.web`, issuer `CFRXH38L48`, audience
`https://appleid.apple.com`. The generated signature was verified locally using
the corresponding public key. Expiration: **2027-02-04T03:06:58Z**; renew before
expiry. This signature self-check is not an Apple authorization-code exchange.
The config includes the registered callback, but has not been deployed. The
native iOS token audience remains `ai.n42.www` and must not be confused with
the Web Services ID audience.

## Independent N42 identity decision

The owner explicitly declined Amaze account inheritance. N42 must not import,
auto-link by email, or reuse historical Amaze Firebase/provider identities.
Historical bindings remain untouched. Any N42 identity backend must use a
separate binding namespace and must not call the legacy email-linking path.

- Removed the hard-coded Amaze Meta App ID and client token from both native
  platforms. N42 Meta values are now build configuration, with no legacy fallback.
- Facebook availability requires a configured N42 App ID and native client token;
  iOS additionally requires the matching URL scheme and the existing Limited
  Login backend opt-in. The known Amaze App ID is rejected even if supplied.
- Provider implementation remains available for the dedicated N42 registration.
- Prepared Meta creation: N42 Wallet, Facebook Login only, existing verified
  Si46world business. Final submission awaits action-time acceptance of Meta terms.
- N42 Firebase Identity Platform initialization returned HTTP 400
  `FAILED_PRECONDITION BILLING_NOT_ENABLED`. No billing was enabled. This attempt
  did not complete authentication initialization or change the legacy project.

Validation: 35 focused Flutter tests passed; targeted analyzer found no issues;
iOS plist validation and Swift syntax parse passed; Android Debug/Release resource
generation passed. No provider E2E, signed release, deployment, or account migration
is claimed for this batch.
