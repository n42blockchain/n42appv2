# Registration UIA repair — 2026-09-18

## Confirmed cause

The user reproduced `Require additional authentication` on iOS
2.4.8 (2026072679); the Android build number was not supplied. A read-only
registration challenge probe of `https://m.si46.world` returned a normal
`m.login.dummy` flow. No invitation, email or server configuration change was
needed for that flow.

Matrix SDK 6.2.0's generated API calls `MatrixApi.unexpectedResponse`, which
constructs `MatrixException.fromJson`. Its decoded UIA fields are present but
`response` is null. Our registration handler required an attached HTTP 401
response, so it rethrew the valid challenge without submitting the dummy stage.
Previous tests used `MatrixException(http.Response(..., 401))`, hiding the defect.

## Repair

Chat commit `b6d29770445c1e95e4d7c3f224a0223e2e504376` uses the SDK's
`requireAdditionalAuthentication` and decoded `raw` fields. It preserves the
server session, supported-flow selection, token requirements and bounded retries.
Unsupported stages and real forbidden responses are still propagated. Both
normal and anonymous registration share this datasource.

The app pins this Git commit; its 779 mirrored lib/assets files were compared
byte-for-byte with the resolved Git dependency. The mirror alone is not the
runtime dependency.

## Verification

- New regression invokes the actual SDK `unexpectedResponse` method. It failed
  before the repair with the exact reported message and passed afterward.
- 11 datasource cases pass, including legacy and decoded challenges, missing
  token, unsupported authentication, malformed session and bounded retries.
- 96 focused datasource/repository/bloc/form tests pass.
- Chat analysis: zero errors/warnings, 214 informational diagnostics.
- Wallet Chat feedback regression: 413 passed; wallet analysis has zero
  errors/warnings and 196 informational diagnostics.
- Opt-in live smoke calls the production datasource with the SDK's real HTTP
  registration transport against `https://m.si46.world`: initial challenge,
  dummy stage, successful account creation, password login, and account
  deactivation all passed. Credentials were generated in memory and not logged.
  Existing user accounts and server configuration were not modified.

Repeat the live smoke from the Chat checkout only when creating a disposable
account is authorized:

```sh
N42_REGISTRATION_SMOKE_URL=https://m.si46.world flutter test --no-pub \
  test/integration/registration_live_test.dart --reporter expanded
```

The live test substitutes the SDK client initialization layer and therefore
does not verify native secure storage, encryption initialization or screen
navigation. Registration on the user's iOS and Android devices remains a release
acceptance step. Build 2026072679 does not contain this repair.
