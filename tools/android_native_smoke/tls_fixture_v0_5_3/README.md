# Test-only Android TLS verifier fixture

This folder reconstructs the **separate test fixture** used to exercise `rustls-platform-verifier 0.5.3` certificate decisions in the same `libmobile_sdk.so` as N42's Android initializer. It is not an app dependency and must not replace the production MobileSdk AAR. The production source/lock and AAR remain in `../mobile_sdk_v0_2_2/` and `android/app/libs/`.

## Inputs

- Maintained production N42 source produced by `../mobile_sdk_v0_2_2/rebuild.sh` from supplier `mobile-sdk-v0.2.2` commit `2099ec735a658ba1db97c49b77a6c58c1fc82920` and the checked-in production lock SHA-256 `7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca`.
- Official unchanged v0.2.2 AAR SHA-256 `97ab0b5e9665998f4387e09b812db4b05116ab9d49244182ccd2e8a1cba75646`, used for Java entries; selected maintained production AAR SHA-256 `ec2dce904f925ca044089164e6b7e7821ded77788c214676a18ed357f27e87a5`, used for production x86_64 native entries.
- Registry `rustls-platform-verifier 0.5.3` crate archive SHA-256 `19787cda76408ec5404443dc8b31795c87cd8fec49762dc75fa727740d34acc1` from `https://static.crates.io/crates/rustls-platform-verifier/rustls-platform-verifier-0.5.3.crate`. The fixture-specific `Cargo.lock` SHA-256 is `1770eaa733bb4a624069624b51c83bd62723fcdab3feae118c3980b01c6cbf49` and adds `ffi-testing` dependencies only to this test graph.
- Supplier Kotlin source at [rustls-platform-verifier `v/0.5.3`](https://github.com/rustls/rustls-platform-verifier/tree/v/0.5.3), exact commit `670de1a872b68c2a0a31a6c491e04bc95d5de5e8`. The published companion AAR does not contain its test-only mock-root methods, so fixture mode compiles this pinned source with the harness's `BuildConfig.TEST=true` and omits the published companion. Production mode uses the published companion, with no test source.

The 17 `.crt`/`.ocsp` files in `certs/` are **public synthetic certificates and responses**, not private keys. `certs.sha256` pins the exact run inputs; `prepare.sh` verifies each before use. They were generated on 2026-09-26 from the supplier's unchanged `src/tests/verification_mock/ca.go` under the pinned crate using Go 1.26.5 and its pinned `go.mod`/`go.sum` (`golang.org/x/crypto` pseudo-version `ae814b36b871`). The generator writes only public `.crt`/`.ocsp` files; its ephemeral private keys stay in memory. Its output is random and time-dependent, so regenerating yields new hashes. The archived public bytes plus `verification-time.patch` fix the recorded run at Unix `1790454120` (2026-09-26 20:22 UTC). The root is valid 2026-09-25 20:22 through 2027-09-26 20:22 UTC; the leaf expires in 2028. The patch changes only the verifier's test clock, SHA-256 `d56aa7d97c79bbaf8170374ca00b2d84708606a9111f787ef64d03ae69f83296`.

## Reconstruct and run

Use **absolute paths** and an isolated task directory. Fetch/verify the crate archive without a floating version:

```sh
curl --fail --location --output /absolute/task/rustls-platform-verifier-0.5.3.crate \
  https://static.crates.io/crates/rustls-platform-verifier/rustls-platform-verifier-0.5.3.crate
shasum -a 256 /absolute/task/rustls-platform-verifier-0.5.3.crate
./prepare.sh /absolute/task/maintained/source \
  /absolute/task/rustls-platform-verifier-0.5.3.crate
./build.sh /absolute/task/maintained/source /absolute/task/official-v0.2.2.aar \
  /absolute/app/android/app/libs/mobile-sdk-android.aar /absolute/ndk/28.2.13676358 \
  /absolute/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/lib \
  /absolute/new/fixture-build
```

`prepare.sh` copies the verified registry source, applies only the test-time patch and archived public certs, adds `tls-fixture = ["rustls-platform-verifier/ffi-testing"]` to the mobile-sdk manifest, patches that verifier to the copied local source, installs the separate fixture lock, then does a locked offline fetch. It rejects nonproduction source locks and existing fixture directories. The preparation was replayed against a separate maintained-source proof checkout: 53 verifier source files matched the recorded local fixture byte-for-byte, except Cargo's cache-only `.cargo-ok` marker, and the lock hash matched. `build.sh` compiles arm64-v8a with this test feature, adds the selected production x86_64 payload, retains official nonnative AAR entries, and audits the fixture AAR's LOAD/GNU_RELRO alignment. Its output is **not** expected to be bit-identical on another host. The recorded fixture AAR SHA-256 was `bc8b8962df31a35fe67c37104de1202dd2451f7b5b31a77908252b929f8e7ac4`.

For the Android harness, fetch the exact supplier Kotlin source into its own checkout, verify `HEAD=670de1a872b68c2a0a31a6c491e04bc95d5de5e8`, then set `N42_SMOKE_TLS_VERIFIER_SOURCE` to that checkout. Set `N42_SMOKE_TLS_CERT_FIXTURE=1` and `N42_SMOKE_MOBILE_AAR` to the fixture AAR. The tracked `../run_mobile_sdk_fixture.sh tls` runner checks source commit, selected AAR digest, per-run strict16KB emulator properties, Flutter test result, all 20 certificate decisions and packaged native member identity after NDK stripping. For a freshly rebuilt fixture AAR, set `N42_SMOKE_EXPECTED_TLS_AAR_SHA256` to its newly recorded digest. The fixture only calls offline verification JNI methods and never calls `runClient`.
