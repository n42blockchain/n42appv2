# TestFlight upload — 2.4.8 (2026072629)

- Date: 2026-08-21 (America/Toronto)
- Source: `master@4ce208c9`
- Bundle ID: `ai.n42.www`
- Team: `CFRXH38L48`
- Deployment target: iOS 16.0
- IPA: `build/ios/ipa/N42Wallet.ipa` (154 MB)
- SHA-256: `5089ef1d730407d097d281e3b2e2de40af50e325b04778a9d936abe64ed7a41f`

## Result

`xcodebuild -exportArchive` completed the App Store Connect upload successfully:

```text
Progress 99%: Uploaded package is processing.
Progress 99%: Upload succeeded.
Uploaded Runner
** EXPORT SUCCEEDED **
```

The build has been accepted for TestFlight processing. App Store Connect emitted
non-blocking missing-dSYM warnings for the precompiled `WebRTC.framework` and
`flutter_vodozemac.framework` binaries.

## Release validation

```text
Final IPA code signature: valid on disk / satisfies Designated Requirement
application-identifier: CFRXH38L48.ai.n42.www
aps-environment: production
get-task-allow: false
provisioning profile: iOS Team Store Provisioning Profile: ai.n42.www
profile expiration: 2027-02-10
SQLCipher strings: sqlite3_key, sqlcipher_export, cipher_version present
```

## Archive fix

The first clean Release Archive exposed an Xcode 26 build-planning failure: an
absolute `-force_load` SQLCipher product path was checked before CocoaPods built
the static framework. The release now anchors SQLCipher with
`-Wl,-u,_sqlite3_key` followed by `-framework SQLCipher`. This preserves the
encrypted archive database symbols without declaring a not-yet-produced file as
a build input.
