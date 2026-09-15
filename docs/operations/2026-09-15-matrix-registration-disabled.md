# Matrix registration disabled — 2026-09-15

## Observed failure

The user reports `M_FORBIDDEN: Registration has been disabled` from registration
against `https://m.si46.world` after the TestFlight upload. No submitted password
or personal email is retained in this report or used to access an account.

Read-only probes on September 15 returned:

- `GET /_matrix/client/versions`: HTTP 200.
- `GET /_matrix/client/v3/login`: password, token and application-service flows;
  no SSO flow advertised.
- `GET /_matrix/client/v1/register/m.login.registration_token/validity`, with a
  deliberately invalid probe token: HTTP 403, `M_FORBIDDEN: Server does not allow
  token registration`.

These probes do not create an account. Login discovery and username availability
do not prove registration is enabled. The registration rejection itself is the
user's observed server response, not a successful automated registration test.

Both normal and anonymous registration call `MatrixAuthDataSource.register`
directly. ID Hub is used by the separate wallet/DID login flow. The user's
conditional authorization to disable unified login therefore does not require
turning it off to diagnose or repair this registration rejection.

## Server recovery plan — not executed

Production deployment access has been requested. Before changing anything:

1. Identify the actual Matrix service/container and installed Tuwunel version.
   Inspect the effective `allow_registration` setting, including environment and
   command-line overrides; check whether a registration token or token file is
   configured without printing its contents. Back up the active configuration.
2. Restore the intended registration policy. For invitation-only registration,
   Tuwunel requires `allow_registration = true` and a configured registration
   token/token file. Keep the invite secret server-side and distribute it through
   the approved invitation process; do not embed it in the application. A valid
   invite cannot override `allow_registration = false`.
3. Apply the change through the deployment's supported reload/restart mechanism,
   after checking the installed version's documentation. Confirm that runtime
   overrides did not retain the disabled setting.
4. Verify the registration challenge advertises the intended UIA flow. With a
   dedicated authorized test account, confirm invalid/missing invitations fail,
   valid registration succeeds, and the new account can log out and log in.
   Recheck existing-account login and Chat session behavior.
5. If the intended policy is public registration or server-managed account
   provisioning instead, confirm that policy before changing access controls.
   Neither is enabled by this client patch.

The upstream [Tuwunel configuration example](https://github.com/matrix-construct/tuwunel/blob/main/tuwunel-example.toml)
documents the registration switch and token options; the exact deployed version
must be checked before applying them. Its defaults are not evidence of this
server's active configuration.

## Client follow-up

Chat commit `916f4c3ef0422da648c51bf5f8f0cf3ea9364b6c` classifies explicit disabled
registration responses separately from generic HTTP 403 errors. The registration
page explains that the server administrator must enable registration, with 26
locale resources, including Simplified and Traditional Chinese. It does not
suggest a password change or automatically retry through another login method.

Validation: 56 registration/authentication/widget tests and 30 auth contract tests
passed. Chat analysis reports zero errors/warnings and 173 existing infos. Seven
new cases cover normal/anonymous disabled responses and English/Simplified Chinese/
Traditional Chinese presentation. Generic forbidden responses retain their server
error behavior. The wallet dependency and source mirror are updated to this pin.
The normal wallet Chat feedback suite passes 118 cases; wallet analysis reports
zero errors/warnings and 155 existing infos. All 771 lib/assets files match the
resolved Git dependency and the source manifest. These targeted checks do not
constitute a new full-suite coverage run or live-server acceptance.
The [test summary and archived logs](../testing/registration-disabled-2026-09-15/summary.json)
preserve the targeted validation evidence.

The uploaded build `2.4.8+2026072656` predates this explanatory text. Server-side
registration remains unresolved until the deployment policy is corrected and
verified. Canonical issue tracking remains Chat `OPEN_ISSUES.md`, item `QA-009`.
