# Task16F.3 Vodo controlled recipe review

Range: `76750e3235b4ddd092f6932ca8e114db931da436..fd0dd4f6d60659a0d98bdce941c611b990edd50d`.

**Spec verdict: CHANGES REQUIRED. Quality verdict: CHANGES REQUIRED.** Three bounded P2 findings follow. They concern reproducible future builds and platform scope; the retained successful AAR is not shown to have used incorrect inputs.

## Findings

### P2 — Android offline policy changes Apple and other source build routes

Location: `packages/flutter_vodozemac/rust/cargokit.yaml:1` (all seven added lines); consumer `cargokit/build_tool/lib/src/builder.dart:174` and `:185`.

The new crate-level configuration adds `--locked --offline` for debug/profile/release without a platform condition. `BuildEnvironment.fromEnvironment` loads this same file for every platform, and `RustBuilder.build` adds those flags unconditionally. Both `ios/flutter_vodozemac.podspec:32` and `macos/flutter_vodozemac.podspec:31` invoke `build_pod.sh` against this Rust crate; Linux/Windows CMake routes also consume it. A fresh Apple CocoaPods source build which previously fetched required crates will now refuse an unprovisioned cache. Guarding the compiler check with `isAndroid` does not contain this separate configuration change. The provenance statement that the Apple build route is unchanged is therefore inaccurate.

**Required:** scope locked/offline enforcement to the actual Android command construction, preserving other platforms' prior flags and behavior. Add command-level tests covering Android debug/release (and profile if distinct) plus a non-Android source route; no Apple/native full build is needed solely to verify this flag-selection fix. Update recipe/provenance hashes accordingly.

### P2 — Frozen-source recipe does not bind the actual Rust wrapper source

Location: `scripts/build_vodo_android.sh:27`–`:43`.

The preflight hashes Cargo metadata, generated bridge and build helpers, but not `rust/src/lib.rs`, `rust/src/bindings.rs` or `rust/src/ios_ffi_bindings.rs`. `lib.rs` explicitly compiles all three modules. Changing an existing wrapper operation in `bindings.rs` leaves every current preflight hash valid and proceeds through metadata to Gradle. Thus the recipe does not enforce its stated frozen runtime source while reporting a pinned source build. Checking generated FRB code does not constrain the functions it calls.

**Required:** bind the complete owned Rust build-input file set/tree, including actual wrapper source, with explicit rejection before Cargo/Gradle on changed/missing/extra source inputs. Avoid silently trusting only HEAD when the build consumes working files. Add a no-native-build negative control modifying an actual wrapper input and proving the later build command was not reached, plus unchanged-input positive coverage. Preserve the existing compiler/library evidence as historical output.

### P2 — Cargo compiler-selector aliases survive the environment sanitizer

Location: `scripts/build_vodo_android.sh:66`–`:72`; version probe at `:54` and actual Cargokit probe `builder.dart:142`.

The script unsets `RUSTC`, `RUSTC_WRAPPER` and `RUSTC_WORKSPACE_WRAPPER`, but leaves `CARGO_BUILD_RUSTC`, `CARGO_BUILD_RUSTC_WRAPPER` and `CARGO_BUILD_RUSTC_WORKSPACE_WRAPPER`. Cargo recognizes these alternative configuration variables. The gate invokes `rustup run stable rustc --version` directly, which does not exercise Cargo's selected compiler/wrapper. A inherited alternate selector can therefore survive the check and be used by subsequent Cargo compilation. This defeats the actual-compiler route constraint despite a correct printed stable version. [Official Cargo configuration reference](https://doc.rust-lang.org/cargo/reference/config.html#buildrustc).

**Required:** clear or explicitly reject these compiler/wrapper aliases before metadata/Gradle, with selective inherited-variable controls proving they cannot reach the build child. Preserve unrelated legitimate integration options; no broad environment prohibition or unchanged full native rebuild is necessary for this fix. There is no evidence that the recorded successful AAR used any such override.

## Accepted evidence and unchanged behavior

- Real `RustBuilder.prepare` now checks the Android NDK version and actual stable rustc version before Cargo preparation, and rejects absent installed Android targets instead of installing them. The condition is Android-specific. Existing page flags and armv7 support are unchanged.
- Host `android/cargokit_options.yaml` disables precompiled binaries. The retained `task-16f-vodo-build2.log` says `Precompiled binaries are disabled`, builds armv7/aarch64/x86_64 and ends `BUILD SUCCESSFUL in 1m 10s`. The rejected four-target release attempt is correctly identified as Flutter rejecting x86 release; x86 debug remains a separate pending observation, not an accepted runtime claim.
- The launcher adds `--offline` only when explicitly requested, including its invalid-snapshot retry. The real-launcher negative log shows omission of the required argument; retained GREEN is 1/1. Toolchain RED shows wrong compiler and wrong NDK accepted by the prior code; combined GREEN reports 6/6. The positive/negative tests do not cover the three gaps above.
- The recipe explicitly checks SDK-selected NDK revision and clang SHA, without claiming that a different configured SDK path built this artifact. Final preflight records pinned rustc/cargo and successful locked offline metadata. Historical failed metadata/preflight is disclosed despite its misleading old filename.
- Retained AAR audit reports two checked 64-bit members and zero LOAD/GNU_RELRO failures. This is bounded static AAR evidence, not crypto/FRB runtime or final app package acceptance. The build predates only later input-check additions, which the report discloses.
- Compressed upstream patch independently hashes to `af20c79c410c73fde2a7d2d2a7351cd7cd97912669f6d1640017368ac2d4c8ff`, containing exactly the five stated source/config members. No Rust crypto source, generated bindings or Apple framework binary is changed by this commit; the platform regression above is in shared build policy.

Read committed snapshot and retained logs only. No builds, tests or device actions were rerun, and no uncommitted fixture work was reviewed.
