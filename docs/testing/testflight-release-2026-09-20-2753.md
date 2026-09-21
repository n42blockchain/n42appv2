# TestFlight and Android test release — 2026072753

- App: **2.4.8 (2026072753)**; bundle `ai.n42.www`.
- Source: `b4d8a04c7d153dce1c9b3375677cee0e2d925612`; tag `v2.4.8+2026072753` pushed to `n42blockchain/n42appv2`.
- Chat pin: `d2e3167c86c06a56ad471d67404eeb0691a0a864`; 792 library/assets files match the cache mirror.

## Included work and limits

Includes the preceding UI/payment implementation and three separate final commits: designated-recipient local red packets, isolated pending-record storage foundation, and wallet network setup interaction tests. Payment features remain local simulation, with developer-only lab entries disabled in release. Pending storage is a foundation and is not yet wired into the lab pages. No provider sandbox, public testnet, or real payment acceptance is claimed.

## Validation

- Combined payment and wallet network interaction tests: **156 passed**.
- Payment backend full suite: **47 passed**.
- Full Flutter analysis: **0 errors, 0 warnings**, 275 style infos.
- Current-source full Flutter suite and coverage were not rerun. Last measured coverage remains **46.8233%**, below the 70% goal and excluding newer batches. This is a user-requested TestFlight test build, not evidence that the production release checklist passed.
- IPA main app and notification extension versions match 2026072753. Deep/strict signature verification passed; distribution team/application identifiers, production APNs, main app/keychain groups and disabled debugging checked.
- APK signature verified, package/version matched, and debuggable flag absent. No physical-device acceptance performed in this release task.

## Artifacts

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| IPA | 162653797 | `cd61da1b40d9f4076144313a0f22f7dc0c11fa11be1fee749b0d54f49a0e2bb0` |
| APK | 847047998 | `4c5d60f7ea67663f7dbd55e23cda2734953a7de16031f2a5594b49fcab801b3c` |

APK: `~/Downloads/N42Wallet-2.4.8-2026072753-release.apk`, with `.sha256` sidecar.
Android certificate SHA-256: `caceef05f3323baef7e080aadcb994118dec86c8cdf620ee80793b3622ea109d`.

## TestFlight upload

Xcode upload returned exit 0 with `Upload succeeded`, `Uploaded Runner`, and `EXPORT SUCCEEDED` at **2026-09-20 20:19:23 local build-host time**. Apple reported the package processing; completion and tester availability remain unverified.

Non-blocking missing dSYM warnings remain for WebRTC.framework and flutter_vodozemac.framework, which may limit crash symbolication.

Raw build/upload logs remain local. This documentation commit naturally advances the development build number; the tag and delivered artifacts remain **2026072753**.
