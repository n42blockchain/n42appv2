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

## Dedicated Meta registration completed

The owner created the independent N42 Wallet Meta app and confirmed continuation.
App ID: `1403945225096358`; business: Si46world digital technology inc.
The app remains unpublished. Only the Facebook Login use case and default
`public_profile` permission are configured; no additional profile permissions
were requested.

Saved and re-opened platform settings:

- Web: `https://n42.world/`, app domain `n42.world`.
- iOS: `ai.n42.www`, iPhone Store ID `6738644072`.
- Android: `ai.n42.www`, activity `ai.n42.www.MainActivity`; local Release and
  Debug certificate SHA-1 values from the Google registration above converted
  to Meta base64 key hashes. Play app-signing certificate remains unverified.
- Exact OAuth redirect: `https://n42.world/v1/auth/n42/social/facebook/callback`.
  Registration does not mean this server route is deployed.
- Automatic iOS events and Android purchase logging were disabled.

The dedicated client token and App Secret were saved only in mode-0600 files
`~/.config/n42/secrets/facebook-native.json` and `facebook-provider.json`.
The provider file pins the console's API version `v27.0`. Native local build
configuration was populated in ignored xcconfig/local.properties files; no
credential was committed. iOS Limited Login remains gated until backend verification.

Android Debug/Release generated resources and Xcode Debug settings were checked
against the dedicated native configuration. No signed build or real-user provider
login was run. The Meta console still requires app icon, privacy URL, deletion
instructions and category, plus its testing/review requirements before publication.
Server identity/session implementation and deployment remain outstanding.

## 2026-11-06: native Hub client integration

- Chat dependency: `53d709d46093dca6a9a4151230d22152ad0aeb48`.
- Opt-in build setting: `N42_NATIVE_AUTH_URL` (unset by default). This connects iOS Apple and Facebook Limited Login to the dedicated N42 backend, not the legacy gateway.
- Flow: server challenge → native OIDC proof → isolated Hub session → same-DID Matrix credentials → Chat token login. Temporary Hub grants are revoked after the Matrix exchange. Requests carrying proofs/tokens refuse redirects. Cancellation, stale account/logout context and missing ID tokens do not fall back to legacy account lookup.
- Plugin checks: 126 targeted tests passed; targeted analysis passed with informational lints. This includes the actual BLoC success path and existing configuration, SDK, API and wallet-login regressions.
- Remaining: Google authorization-code handoff, Android Facebook and Apple/Web UI handoff, deployed callbacks, provider and physical-device acceptance. Google `google_sign_in` 7.2.0 documents exactly-once initialization, so setting a new nonce by repeated singleton initialization is not supported. This build setting does not enable those unfinished paths.
- Production enablement is still off. Registered provider clients and mocked tests do not prove deployed login readiness.
- Host checks: 62 initialization/social-configuration tests passed; analysis of `chat_initialization.dart` found no issues. Only the pinned Chat Git ref changed in `pubspec.lock`.

## 2026-11-06: Google native authorization-code follow-up

- Backend `7e5914a`; Chat `1cb711cdf90b932a29910a5957801feaaa453e21`.
- The opt-in adapter now supports Google on iOS and Android. It requests the SDK's one-time `serverAuthCode` immediately after sign-in. It never reinitializes the Google singleton to change a nonce, and never substitutes an ID/access token when no code is returned.
- The backend's Google code exchange is separately disabled by default (`googleNativeCodeEnabled`). It requires the dedicated N42 Google server credentials. `googleNativeRedirectUri` must be validated against the actual provider exchange before enablement; it is never supplied by the app.
- Backend: 116 focused tests plus TypeScript/ESLint passed. Chat: 130 regression tests and one SDK-boundary test passed; targeted analysis has informational lints only.
- Still pending: Android Facebook, Android Apple browser handoff, Web UI integration, public callback deployment, provider-console completion and real-device/provider acceptance. No production login claim or TestFlight acceptance is implied by these commits.
- Primary guidance: https://developers.google.com/identity/sign-in/ios/offline-access and google_sign_in 7.2.0 `authorizeServer` API documentation.
- Wallet host: 62 initialization/configuration regression tests passed with the new immutable Git pin; no other dependency versions changed.

## 2026-11-06: Android browser handoff and standalone Web login

- Backend commits: `8f34847` (browser protocol/page), `cdfba5e` (Compose configuration forwarding). Chat pin: `1a54f54f7f598fcb20b35f02bbdf5cabe937f698`.
- Android Apple/Facebook use the system browser, one-use launch ticket, explicit browser approval and an app-held completion secret. Google keeps its native SDK server-code path. The host exposes Android Apple only when `N42_NATIVE_AUTH_URL` is set. Existing default enablement remains unchanged.
- Web identity page supports configured Google/Apple/Facebook login, DID display and sign-out. Tokens remain in page memory. This is not a full Web wallet transaction interface.
- Verification: 120 backend tests passed, including a disposable Redis 7 instance for atomic completion; TypeScript and ESLint passed. Chat passed 134 targeted tests and analysis with informational lints only. Wallet passed 62 initialization/configuration tests and targeted analysis with no issues. Only the Chat Git pin changed in the dependency lockfile.
- Safari rendered the Web page against local capability fixtures. No real provider authorization was performed.
- Built server image `n42-id-hub:n42-auth-cdfba5e` on the web host. Image ID: `sha256:a4f98ba1b4a5c788c9bbdf6e63803073ecb97f451a41b71b2c723cd390c4e9b6`. Source is isolated at `/home/ubuntu/releases/n42-id-hub/cdfba5e`; the active service and its uncommitted deployment configuration were preserved.
- The running service still lacks `N42_AUTH_CONFIG` and `N42_AUTH_HMAC_KEY`. A built image is not deployment or login acceptance. Public callback proxying, dedicated runtime configuration, Google callback registration, Meta publication prerequisites and real-provider/device acceptance remain open. No new TestFlight upload was performed.

## 2026-11-06: public deployment and live Web acceptance

- Dedicated listener: `n42-wallet-auth`, image `n42-id-hub:n42-auth-cdfba5e`, loopback port 18790. Public N42 auth/revoke routes are deployed; existing Club service and website remain available. Independent N42 runtime settings/HMAC are controlled outside Git. Backend deployment/evidence commits: `2429851`, `dd8c2d7`, `7c0dd68`.
- Google callback was saved and reopened in its dedicated client. Google, Apple and Facebook each completed two real Web logins with a stable provider-bound DID and two successful sign-outs. Read-only database counts confirm one binding/two sessions/two revoked sessions per provider. Provider identities are separate; no implicit linking or legacy migration.
- Facebook acceptance uses an authorized developer/test account. The app remains unpublished/unreviewed. Existing privacy/terms URLs and category were saved; working data-deletion instructions/process and publication requirements remain incomplete.
- Native Google server-code exchange remains disabled pending device acceptance. These Web checks do not establish native Matrix login, wallet signing or TestFlight acceptance.

## 2026-11-06: reference social-button layout

- Chat pin `beee7e5fa38a2a082497d5ed469a7eb97c3fc149`: compact Google/Facebook icons and labels on the left, wider Apple control on the right. Narrow/accessibility layouts wrap. Additional configured providers and existing sign-in callbacks remain intact.
- iOS host renders a real `ASAuthorizationAppleIDButton` with `.continue`, built-in black/white style and system-localized label. Flutter only passes enabled state and handles tap delivery through the existing authorization handler. It does not draw or restyle the Apple logo/title. Other platforms use the existing plugin's Apple button.
- Chat: 102 layout/config/auth tests passed. Wallet: 63 initialization/config/native-channel tests passed, including disabling native taps while busy and using the current callback after rebuilding. Targeted analysis passed with informational lints only. Swift source parse and iPhoneOS SDK type-check passed.
- Android Release build attempted before the layout update failed because generated `GeneratedPluginRegistrant.java` referenced `dev.flutter.plugins.integration_test`, absent from the Release classpath. No app was installed or uninstalled. Native visual/device acceptance and a new release artifact remain pending; no TestFlight upload was performed.

## 2026-11-06: native Release build verification

- Full iOS Release compilation passed with `N42_NATIVE_AUTH_URL=https://n42.world` and `N42_CHAT_FACEBOOK_IOS_ENABLED=true`, without code signing. `Runner.app` is `ai.n42.www`, version `2.5.3 (73133)`, and contains the dedicated Facebook application ID. This includes the native Apple control; installation and visual/device acceptance were not performed.
- Normal Flutter Release tooling regenerated the Android plugin registrant without the stale integration-test dependency. The first successful APK exposed a separate resource-shrinking issue: Google server-client configuration accessed via `getIdentifier()` was absent from the package.
- Added `n42_social_auth_keep.xml` to retain dynamically accessed provider resources. The rebuilt signed Android Release passed. Inspection of the actual APK confirmed the dedicated Google server-client value/resource and Facebook application ID/token resource are retained. No credential values were written into evidence logs.
- Verified APK: `2.5.3 (73133)`, SHA-256 `30e7962a3a5f91c3b74c67d303b808b96d93b6771add3fb4634659a8531892b9`. Signature verification passed against the registered N42 Release certificate. Build source was `538e4015f` plus the resource-retention XML. The commit hook increments the subsequent source build number; these artifacts remain build 73133.
- Native Google exchange remains disabled on the backend pending actual native authorization acceptance. No app was installed/uninstalled, and no TestFlight upload was performed. Meta publication and native Matrix login remain open.

## Android native-login build and live capabilities — batch 155

- Read-only live GET https://n42.world/v1/auth/n42/capabilities returns google_native_code=false, native_oidc_providers=[apple, facebook], web_providers=[google, apple, facebook]. This confirms the deployed Google-native gate is closed; no server setting was changed. Web availability does not establish native provider/Matrix acceptance.
- Android local server-client configuration matches the dedicated N42 Web OAuth client. An initial ad hoc presence check failed to trim property-name whitespace and falsely reported it absent; corrected comparison and the compiled APK resource both confirm presence. No credentials/configuration were changed or printed.
- Source fd5fe815c, Chat production pin b6ff2c46: Flutter 3.47.8, JDK 21, `flutter build apk --debug --no-pub --target-platform android-arm64 --dart-define=N42_NATIVE_AUTH_URL=https://n42.world` completed with exit 0 in 107.4 seconds. Artifact build/app/outputs/flutter-apk/app-debug.apk is ai.n42.www 2.5.3 (73274), target SDK 36, 714898505 bytes. SHA-256 29de39c62cd728b71445ac865496189924ad04e2c2951a096e7929a8010eac10. apksigner verify passes. Flutter arm64 and Falcon native libraries are packaged. Debug packaging still contains additional dependency ABIs; this is not a size-optimized release.
- Chat native API/BLoC suite: 16 pass (/tmp/n42-chat-b155-native.log). Build log: /tmp/n42-wallet-b155-android.log. Existing future built-in-Kotlin migration and Windows Facebook plugin warnings remain; they did not fail this Android build.
- No installation, real provider login, same-DID Matrix acceptance, release signing, TestFlight upload or production deployment was performed. Native Google activation still needs acceptance before enabling. Earlier release/native acceptance gaps remain open.

### Read-only Matrix registration compatibility check — 2026-11-07

- Public `m.si46.world/_matrix/federation/v1/version` reports Tuwunel 1.9.4.
- GET `/_synapse/admin/v1/register` returns HTTP 200 with a nonce. The nonce value was not recorded. The shared-secret registration route must not be classified as absent based only on the server implementation name.
- GET `/_matrix/client/versions` returns HTTP 200 with 27 advertised versions.
- These public GET checks do not prove authenticated registration, same-DID account reuse, E2EE initialization or native provider acceptance. No account was created and no production setting was changed. Native Google activation remains gated.
