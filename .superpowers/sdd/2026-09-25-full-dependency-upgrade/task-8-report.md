# Task 8 — Rust MLS dependency upgrade

Completed 2026-09-25 on Rust 1.97.1 (`rustc 1.97.1`, `cargo 1.97.1`).

## Direct dependencies

| Crate | Before | After |
| --- | --- | --- |
| openmls | 0.8.1 | 0.9.0 |
| openmls_rust_crypto | 0.5.1 | 0.6.0 |
| openmls_basic_credential | 0.5.0 | 0.6.0 |
| openmls_traits | 0.5.0 | 0.6.0 |
| tls_codec | 0.4.2 | 0.5.0 |
| jni (Android) | 0.21.1 | 0.22.4 |

Published crate metadata reports Rust 1.91 for the OpenMLS family and Rust 1.85 for tls_codec and jni. The local 1.97.1 toolchain satisfies all direct MSRVs. Cargo updated the lockfile and resolved 209 package records, up from 175.

## API and behavior

The MLS engine compiled with OpenMLS 0.9 without call site changes. Its C API and RFC 9420 flows remain as before: key packages, Welcome, ciphertext messages, staged commits, and self update. Existing unit tests exercise peer join, bidirectional encryption, epoch advancement, and the C buffer ownership flow. OpenMLS 0.9 adds `OwnPendingCommit` and `OwnPrivateMessage` processing outcomes; this engine merges its own commits immediately and its `process_commit` entry point is for commits received from peers, so its staged commit handling remains appropriate. Device interoperability with older OpenMLS versions was not tested.

`jni` 0.22 requires native calls to accept `EnvUnowned` and enter `with_env` before JNI operations. All 11 native methods were migrated. Their exported names, Java argument and return types, null/error return values, and C buffer transfer/free pattern are preserved. `with_env` now catches panics at the JNI boundary and routes unexpected panics through the crate's runtime exception policy.

The provider and group map live only inside `MlsEngine` memory. README explicitly states that production persistence is future work. The `0-8-1-storage-format` feature is therefore unnecessary for this upgrade.

## Verification

| Check | Result |
| --- | --- |
| `cargo fmt --check` | Pass |
| `cargo test --all-targets` | Pass, 6 tests |
| `cargo check --all-targets` | Pass |
| `cargo clippy --all-targets -- -D warnings` | Pass |
| `ANDROID_NDK_HOME=... cargo check --target aarch64-linux-android --all-targets` | Pass |
| `ANDROID_NDK_HOME=... cargo clippy --target aarch64-linux-android --all-targets -- -D warnings` | Pass |
| `ANDROID_NDK_HOME=... cargo ndk --platform 26 --target arm64-v8a build --release` | Pass, `.so` linked |
| `cargo build --release` (macOS host) | Pass, `.a`, `.dylib`, `.rlib` produced; 13 C exports present |
| `./scripts/build_mls_android.sh` | Pass, four tracked app `.so` libraries regenerated |
| `./scripts/build_mls_ios.sh` | Pass, tracked device and simulator `.a` libraries regenerated |
| Android `llvm-nm -D --defined-only` | All 11 JNI and 13 C symbols present; JNI symbol set identical to baseline source |
| Android packaged artifact audit | Four expected ELF architectures, four changed SHA-256 hashes, 11 JNI and 13 C symbols in each |
| iOS packaged artifact audit | arm64 device and arm64/x86_64 simulator slices, both changed SHA-256 hashes, 13 C symbols observed in each slice; generated headers unchanged |
| `git diff --check` | Pass |

The app uses tracked `android/app/src/main/jniLibs/{arm64-v8a,armeabi-v7a,x86,x86_64}/libn42_mls.so` and `ios/N42Mls.xcframework` static archives. The standard packaging scripts rebuilt these app inputs after the source upgrade. The headers remained byte-identical, as the C ABI did not change. Apple's `nm` returns status 1 while scanning unrelated Rust 1.97 LLVM bitcode members with an older reader, but its output contains all 13 C exports in each iOS slice; the script's Xcode XCFramework assembly succeeded. Final app builds must validate iOS linking. No Android or iOS device runtime test was performed. Host tests exercise the MLS and C behavior.

## Lockfile audit

The resolved graph has a single OpenMLS 0.9 / provider 0.6 family, a single tls_codec 0.5, and a single jni 0.22.4. No newly introduced prerelease versions were found. The existing `wasi 0.11.1+wasi-snapshot-preview1` record remains. `cargo tree -d` shows duplicated digest, SHA, HMAC, HKDF, Curve25519, and related crypto generations because upstream OpenMLS/provider dependencies use both current post quantum and established RustCrypto lines. No direct duplicate OpenMLS version exists. Removed package names are `cesu8`, `libcrux-aesgcm`, `wasip2`, `wit-bindgen`, and obsolete Windows target crates; those are replaced by the upgraded JNI, libcrux, and transitive graph. Full lock diff and `cargo tree` output are in the compressed evidence archive.

## Evidence

`docs/testing/dependency-upgrade-final-2026-09-25/rust/evidence.tar.gz` contains complete host and platform command output, packaged artifact audits, symbol listings, dependency trees, and lockfile diff. The separate `lockfile.diff.gz` is also retained.
