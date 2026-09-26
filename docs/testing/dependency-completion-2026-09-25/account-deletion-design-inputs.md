# Task16 account deletion design inputs

Research date: 2026-09-26. Read-only source investigation; this is an implementation brief for review, not a deployed-service or test-pass claim. Official Chat worktree: `/Users/jieliu/.codex/worktrees/n42-chat-dependency-completion`. No production deletion, installation or tests were performed.

## Confirmed defect and affected files

Chat `OPEN_ISSUES.md:211–217` records SEC-004: non-password deactivation UIA remains incomplete.

- `lib/src/presentation/pages/settings/security_settings_page.dart:1081–1127`: attempts deactivation, retries only when no password was supplied, `response.statusCode == 401`, and raw response advertises password. Password dialog recursively starts another deactivation without preserving the challenge session. SSO/custom stages are rejected. Success then logs out, optionally purges local data and returns to the first route.
- `lib/src/core/utils/matrix_uia_utils.dart`: parses a raw body and asks whether any flow contains a stage. It does not model completed stages, next eligible stages, session or flow progress.
- `lib/src/data/datasources/matrix/matrix_auth_datasource.dart:357–385`: already accepts `AuthenticationData? auth`; builds `AuthenticationPassword` if only a password is supplied, calls SDK `deactivateAccount`, then deletes local room-key snapshots for the identity. This is a usable integration seam.
- Registration in the same datasource at 243 already handles `MatrixException.raw` because generated SDK endpoints may have no attached HTTP response. Deactivation retains the older response-only bug and can miss even password challenges.
- Existing focused tests: `test/unit/utils/matrix_uia_utils_test.dart` and `test/unit/datasources/registration_uia_test.dart`. `test/integration/registration_live_test.dart` uses deactivation for cleanup; it is not non-password UIA acceptance. No dedicated security-settings deletion test was found by the focused file search.

Current deletion confirmation also trims passwords; preserve actual password characters when implementing retry. Its remote-erasure copy promises server purge too broadly. Explain requested erasure and applicable retention/federation limits based on the actual service policy.

## Matrix SDK 13 source evidence

Official `matrix 13.0.0` published archive SHA256: `fd8629c8e5c0d39e77208d0f50b68fd7b483340c38da1ecc324fc388835ff02e`. Source read directly from the published archive, without dependency resolution or installation. [Published version](https://pub.dev/packages/matrix/versions/13.0.0).

- `lib/matrix_api_lite/generated/api.dart:1550–1574`: `Future<IdServerUnbindResult> deactivateAccount({AuthenticationData? auth, bool? erase, String? idServer})`, POST `/_matrix/client/v3/account/deactivate`. It does not automatically render or complete UIA.
- `lib/matrix_api_lite/model/matrix_exception.dart:69,84–113`: `MatrixException.fromJson`, `raw`, `session`, `requireAdditionalAuthentication`, `authenticationFlows`, `authenticationParams`, `completedAuthenticationFlows`. Use decoded fields, not an obligatory `response`.
- `lib/matrix_api_lite/model/auth/authentication_data.dart`: nullable `type` and `session`, plus additional fields. `AuthenticationData(session: session)` represents a completed out-of-band stage retry.
- `lib/src/utils/uia_request.dart:22–103`: `UiaRequest<T>`, `nextStages`, `params`, `session`, `completeStage`, `cancel`, and loading/waitForUser/done/fail states. The caller must put the session in submitted auth; `completeStage` does not add it automatically.
- `lib/src/client.dart:865–884`: `uiaRequestBackground` dispatches challenges through `onUiaRequest`. A consuming UI listener is required. Do not assume calling the helper alone provides a browser/password flow.

SDK-helper caveat: `UiaRequest._run` sets `state=done` before assigning `result`; `uiaRequestBackground` reads result in the state callback. Review this ordering before selecting that wrapper for typed result handling. A narrow local coordinator around the datasource is an alternative; preserve SDK source rather than patching it without need. The helper also retains the first session with `??=`; explicitly test expired/replaced sessions and bounded retries.

## Protocol contract and proposed flow

The stable Matrix specification provides ordered UIA stages and browser fallback. SSO UIA uses fallback, not ordinary login-token acquisition. For an unsupported stage, open the homeserver's `/_matrix/client/v3/auth/<auth type>/fallback/web?session=<session ID>`. After completion retry the original operation with session-only auth. [Stable Matrix client-server specification](https://spec.matrix.org/v1.18/client-server-api/#user-interactive-authentication-api).

Proposed implementation:

1. Freeze client/account/homeserver identity and erase choices for the operation; reject stale callbacks after logout/account switching. Start unauthenticated UIA discovery using the current authorized client.
2. Decode the actual challenge and choose a viable flow. Submit only eligible next stages; preserve session and completed stages. Password requests carry the original account identifier and exact entered password. Handle wrong password as retryable without destroying local state.
3. For SSO/custom stages use the protocol fallback URL, with proper URI encoding and trusted homeserver origin. Browser completion is a signal to retry, never proof of account deletion. Embedded integration may expose the specified `onAuthDone`; browser messaging must validate origin/source and operation identity. External browser return/manual resume must still retry the server operation rather than manufacture success.
4. Keep cancellation, timeout, malformed challenge, unsupported fallback and network failure recoverable. Bound retries and prevent concurrent duplicate deletion operations. Never substitute dummy/password stages that the server did not offer.
5. Only authoritative deactivation success permits success UI and final cleanup. Separate server success from retryable local cleanup failure. Preserve identity-specific cleanup; do not delete other accounts or wallet assets. Audit whether ordinary logout after snapshot deletion can recreate retained room-key state, and whether global `purgeLocalData` affects other saved accounts, before reusing that path.

There is no generic proof that a passkey login corresponds to a particular UIA stage. `auth_methods_service.dart` describes passkey management and an unopened standalone login entry; its native channel is `n42.chat/passkey`. Obtain actual challenge evidence for every exposed login method. Custom passkey verification is server-defined unless served through standard fallback; do not invent a Matrix authentication type or accept local biometric success as server authentication.

### Native OAuth account management is a separate branch

Matrix v1.18 says OAuth-aware clients must not call the legacy deactivation endpoint when the server supports the OAuth API; they must use the account-management URL when available, optionally with `action=org.matrix.account_deactivate`. SDK generated `GetAuthMetadataResponse` includes `accountManagementUri` and supported actions. Confirm actual login mode/server discovery before choosing this branch; do not treat every Google/Apple social login as native Matrix OAuth. [Deactivation specification](https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3accountdeactivate).

Opening account management is not verified deletion. Completion/status evidence and safe session cleanup require the actual server integration contract.

## Host and web deletion boundaries

Host `lib/features/auth/domain/repositories/auth_repository.dart:71` declares password-only `deleteAccount`; focused searches did not find a corresponding implementation. `lib/features/utils/chat_logout_compat.dart` invokes Chat logout, which is not deletion. Confirm ownership and deletion scope for host UUID, Matrix account, identity/passkeys, loyalty/purchase records and other services. Matrix deactivation alone does not prove all host service data is deleted.

No verified independent web deletion-request URL or backend contract was found in the inspected app/web/docs paths. Existing audit marks this unverified. A homeserver UIA fallback URL containing an ephemeral session is not automatically the publicly accessible deletion-request resource required for the Play listing. Provide a real deployed request path, authentication/recovery handling, retention explanation and service owner. [Google account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en), [Apple review guidelines](https://developer.apple.com/app-store/review/guidelines/).

Do not invent an API, show fake deletion success, equate local wallet removal with account deletion, or destroy recoverable wallet ownership. Financial/purchase records and immutable chain data need an accurate retention explanation and applicable organizational policy; the client cannot prove erasure of federated copies.

## Targeted implementation acceptance

- Real SDK HTTP fixture returning `MatrixException.fromJson` without `response`: password challenge still works; exact password and session preserved.
- No-UIA success; password error then retry; multiple alternative flows; multi-stage completed list; malformed/empty flows; expired/replaced session; rate limit/network failure.
- SSO browser success followed by server rejection remains failure; cancel/timeout does not purge. Spoofed browser message, wrong origin, stale account callback and double submission cannot deactivate the wrong account.
- Fallback unknown stage remains fail-closed if the server cannot perform it; actual supported passkey/SSO challenge exercised using disposable accounts, not production users.
- OAuth-discovered account management follows the supported server contract; opening a URL alone never records confirmed deletion.
- Server success followed by logout/purge failure is represented accurately and recoverably; account-specific snapshots, saved sessions, push registration and cached data are cleaned without deleting unrelated wallets/accounts.
- Host service deletion/retention verified independently of Matrix success. Public web request path works without the installed app; Play console URL matches deployed service.
- Native Android/iOS browser return, password manager/passkey behavior and accessibility tested on the release integration. Historical password-registration cleanup tests are insufficient.

## Evidence that source inspection cannot supply

Actual production UIA flows and fallback behavior for all login methods; native OAuth deployment status; auth-provider credential revocation requirements; full host identity/service deletion contracts; lawful retention and federation behavior; web deletion deployment/ownership; console listing configuration; disposable-account end-to-end and native release acceptance. These remain explicit gates, not inferred successes.
