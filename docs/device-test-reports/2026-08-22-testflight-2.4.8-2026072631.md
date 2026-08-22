# TestFlight upload — 2.4.8 (2026072631)

- Uploaded: 2026-08-22 00:07 (America/Toronto)
- Source baseline: `master@9fa3aa05`
- Release fix: `bcd93bc1`
- Bundle ID: `ai.n42.www`
- Team: `CFRXH38L48`
- Deployment target: iOS 16.0
- IPA: `build/ios/ipa/N42Wallet.ipa` (154 MB)
- SHA-256: `02f6fd32bdc5f00289d2f8e91470362f6a61e7016bc2c40dd2eb2113c892d4a9`

## Result

```text
Progress 99%: Uploaded package is processing.
Progress 99%: Upload succeeded.
Uploaded Runner
** EXPORT SUCCEEDED **
```

This is the final TestFlight build for this release. Build `2026072629` was also
accepted earlier, but was superseded after three security-audit commits landed on
`master` during its upload. Testers should select `2026072631`.

## Validation

```text
App Store distribution signature: PASS
CFBundleShortVersionString: 2.4.8
CFBundleVersion: 2026072631
aps-environment: production
get-task-allow: false
SQLCipher: sqlite3_key / sqlcipher_export / cipher_version present
```

App Store Connect emitted non-blocking missing-dSYM warnings for the precompiled
`WebRTC.framework` and `flutter_vodozemac.framework` binaries. The application
binary itself was accepted and entered processing.
