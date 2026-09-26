# Task16B offline Android TLS certificate fixture

This is a test-only derivative of rustls-platform-verifier v0.5.3. It never calls N42 `runClient`, contacts a network endpoint, changes production trust roots, or ships in the production AAR.

## Inputs and isolation

- Upstream verifier tag `v/0.5.3`, commit `670de1a872b68c2a0a31a6c491e04bc95d5de5e8`; test source clone: `rust-sdk-rebuild/verifier-v0.5.3`. Registry crate `rustls-platform-verifier 0.5.3` original checksum `19787cda76408ec5404443dc8b31795c87cd8fec49762dc75fa727740d34acc1` copied into `rust-sdk-rebuild/source-git/third_party/rustls-platform-verifier-0.5.3-fixture` for fixture-only modification.
- Exact supplier certificate generator: `rustls-platform-verifier/src/tests/verification_mock/ca.go` at the pinned tag, SHA-256 `6c3bec898f4a94cfc7ee0cd53d2aa416ae431d1f2f134c855b98fd9b2fdc80a2`; `go.mod` SHA `3bf442f18319221c7cebaf98d445500491db07a6d0a66141fd78a5d85e68fc16`; `go.sum` SHA `1f819b83f096791863d20089b4c9232b43036a75ef12591c90bfff9ea96b2501`. `go run ca.go` in the copied `src/tests/verification_mock` directory used Go 1.26.5 and its pinned `golang.org/x/crypto` pseudo-version. The generator creates ephemeral ECDSA keys and stores public DER certificates/OCSP responses only. Its output is random, so the hashes below identify this exact fixture run rather than a bit-for-bit reproducible generator result.
- Public DER anchor SHA-256: `root1.crt` `e50cca1d3a9f553981809842b9b3956e65643ede7a13f9d5b7b676a70aa70642`; `root1-int1.crt` `beea3ecdd143e8b99c65c6e91f2f16fb6e0b7a1198dd61947a1c74c29e03fed3`; valid `example.com` leaf `e14a5ca95d63b8240e7002cecb7cf18d4ed6dd77dda1f40135b096211d240159`. The generated root is valid 2026-09-25 20:22 UTC through 2027-09-26 20:22 UTC; leaf expires in 2028. The fixture-only fixed verification time is Unix `1790454120` (2026-09-26 20:22 UTC).
- The supplier's published JVM companion AAR SHA `667292cadd8fa589229dd0f716541236a761f29b774930868d218175633830fd` contains no `addMockRoot` or `clearMockRoots`; those methods were removed in its release build. In `N42_SMOKE_TLS_CERT_FIXTURE=1`, the harness compiles the pinned supplier Kotlin `android/rustls-platform-verifier/src/main/java` with fixture `BuildConfig.TEST=true`, and excludes the published companion AAR. The production harness build uses the published AAR.
- Fixture-only Rust feature `tls-fixture = ["rustls-platform-verifier/ffi-testing"]` and local verifier patch enable the supplier's `CertificateVerifierTests` JNI entries in the same `libmobile_sdk.so` as the real Android initializer. Fixture-only Cargo update added `android_log-sys 0.3.2`, `android_logger 0.15.1`, and `env_filter 0.1.3`; this lock is separate. The successful pre-expired-case fixture AAR SHA is `bc8b8962df31a35fe67c37104de1202dd2451f7b5b31a77908252b929f8e7ac4`.

## Results and expected certificate decisions

On disposable `emulator-5560` (`PAGE_SIZE=16384`, linker compat `fatal`, package compat disabled `true`), `tls-cert-fixture-runtime-fresh.log` reports Flutter integration test 1/1 passed. `tls-cert-fixture-logcat-fresh.log` records 20/20 supplier verifier cases passing:

The final harness also passed 1/1 with the pinned Flutter 3.47.5 executable and explicit `N42_SMOKE_TLS_VERIFIER_SOURCE` (`tls-cert-fixture-runtime-final-pinned.log`), using the same fixture AAR SHA above. An attempted rerun through the system Flutter failed dependency resolution because its Dart 3.12.2 is below this harness's >=3.13.4 constraint (`tls-cert-fixture-runtime-final.log`); one wrong guessed pinned executable path exited 127 before test startup. Neither failure is a native result.

| Expected result | Cases |
| --- | ---: |
| Accept a valid mock-root chain | 7 |
| Reject revoked certificate | 3 |
| Reject unknown issuer with mock-root test context | 3 |
| Reject wrong DNS/IP host | 3 |
| Reject wrong extended-key-usage | 3 |
| Reject the mock root under the default system trust path | 1 |

The 19 mock-root cases call the supplier's actual `Verifier::verify_server_cert`; the separate default-store case rejects the untrusted public DER through the Android JVM certificate verifier. All cases ran after the production JNI initializer supplied application Context to the same Rust verifier crate instance. The test-only fake root and `ffi-testing` logic must be excluded from production.

The first fixture attempt against the published JVM companion aborted because its test-only mock-root methods were absent (`tls-cert-fixture-runtime.log`, Android logcat `NoSuchMethodError`, process SIGABRT). The second attempt with supplier test Kotlin but the supplier's old bundled certificates returned `Expired`: the old root expired 2025-08-05 and leaf 2026-08-05 (`tls-cert-fixture-runtime-testcompanion.log`). These failures are fixture input failures, not evidence of a production library load failure. Fresh public certificates corrected the dates without changing production trust behavior.

## Production separation

The final production source removes the `tls-fixture` feature and local verifier override. Its `Cargo.lock` SHA-256 is `7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca`, identical to `rust-sdk-rebuild/Cargo.lock.pre-tls-fixture`. Both final production ABIs export `Java_ai_n42_tls_MobileSdkTlsVerifier_initializeNative`, and neither exports `CertificateVerifierTests` symbols. The production AAR uses the published companion JVM AAR, with no fixture Kotlin source or mock roots. Actual production WSS transport remains unrun because `runClient` would initiate validator work; this fixture proves the pinned verifier's offline certificate decisions and the same-library initializer route, within the stated test-only feature difference.

## New identity-bound replay

The tracked `native-sdk-evidence/tls-runtime.log` is the final focused strict16KB debug harness run, with fixture AAR SHA `bc8b8962df31a35fe67c37104de1202dd2451f7b5b31a77908252b929f8e7ac4`, Flutter 3.47.5, pre/post device properties, debug APK SHA, exact NDK-stripped native member equality, source hashes and the 20 supplier verifier logcat decisions. The complete test-only fixture source patch, separate lock, 17 public cert/OCSP bytes, pinned crate checksum, supplier Kotlin commit and rebuild commands are tracked in `tools/android_native_smoke/tls_fixture_v0_5_3/`. The production AAR still has no fixture test symbols, mock roots or `ffi-testing` feature.
