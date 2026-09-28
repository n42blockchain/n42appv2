# Task16F Wallet Core 4.8.4 native repair inputs

Read-only preparation, 2026-09-26. No build, test, device, app/supplier source
edit, release operation or supplier contact. This narrows only the Wallet Core
row of `task-16f-engine-supplier-inputs.md`.

## Exact selected artifact and app contract

`android/app/build.gradle.kts:174` selects
`com.trustwallet:wallet-core:4.8.4`. The cached Maven AAR SHA-256 is
`04ea7ab9527beeb3f4d650b13108deb08ec8a857f4e62b86df3e953dfa9e4d87`;
its `classes.jar` SHA is
`5e86c61d0121af19c1bcf99043b21a6e4c8fa479bb6d1c9a20967eadb8bb6d4b`.
The published `wallet-core-proto:4.8.4` companion JAR SHA is
`95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b`.
The AAR/POM records this companion dependency and Gradle metadata reports
8.10.2, but neither records the full native build inputs or source commit.

| AAR JNI member | SHA-256 | Current static RELRO |
| --- | --- | --- |
| `arm64-v8a/libTrustWalletCore.so` | `d01ca3db4312b3b64e3f8feddf581c3be8d25d729456873bb9042ed8c2d447e7` | `LOAD` 0x4000; RELRO end `0x10d6000`, remainder `0x2000` |
| `armeabi-v7a/libTrustWalletCore.so` | `3b66dc5938fdb878e20e32ba057919607d089914660fa6d9d612beffb0f492ba` | Not part of the 64-bit failure count; preserve the working 32-bit ABI. |
| `x86/libTrustWalletCore.so` | `8416c51a3eb9df172dc3554fc855f91c4b0d8193b098d4fa50c6deacb93fcb37` | AAR member exists; app release does not ship x86. |
| `x86_64/libTrustWalletCore.so` | `213a17051219547795fd4b4a51de9fde760c84f5f19258027367e2d8e2eeb3f0` | `LOAD` 0x4000; RELRO end `0x123e000`, remainder `0x2000` |

The arm64/x86_64 member hashes match the release APK and AAB in
`task-16f-native-relro-inventory.json`; their build IDs are
`a47d6dc28e8e264f95c35b8f38bbb154eddcff58` and
`8d915ed681a345a1f167aa049d4fe4a183364545`. This is a static
[Android RELRO](https://developer.android.com/guide/practices/page-sizes)
failure, not a measured Wallet Core crash.

Wallet Core is live code: `TrustdartPlugin.kt:31` loads
`TrustWalletCore`; its method channel calls `KeyManagementHandler` for
mnemonics, HD derivation, addresses and keys, and
`TransactionSignerHandler` for messages and transactions. Those handlers use
`wallet.core.jni` classes including `HDWallet`, `PrivateKey`, `CoinType`,
`StoredKey`, `TransactionCompiler`, `AnySigner`, and many
`wallet.core.jni.proto` messages. Preserve the Java/JNI descriptors, native
exports, `wallet-core-proto` compatibility, the app's method results and
serialized signing bytes. Do not change derivation or signing algorithms to
fix ELF layout.

## Tagged source and build graph

The official [Wallet Core `4.8.4` tag](https://github.com/trustwallet/wallet-core/tree/4.8.4)
is commit `d40d24a63d92619167903369308bf0e2f7eb3a59` (a direct commit tag,
not an annotated tag). Its [complete Git tree](https://api.github.com/repos/trustwallet/wallet-core/git/trees/4.8.4?recursive=1)
has **no mode-160000 submodules**; `.gitmodules` is empty. The C++ TrezorCrypto
fork is vendored within this commit at `trezor-crypto/`; its `version` marker
is `ffa96205fb5e22b43e7b08a3dbc3cdeee0931de3`. The vendored tagged
bytes, not a fresh Trezor clone, are the frozen C++ source. The tagged
[`rust/Cargo.lock`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/rust/Cargo.lock)
SHA-256 is `2e0a91cecf4cc5305e000af96b3dd9c4baefe0171cf736bf06e59f016e5fd337`;
[`rust/wallet_core_rs/Cargo.toml`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/rust/wallet_core_rs/Cargo.toml)
produces `libwallet_core_rs.a` as `staticlib` with coin/signing features.
The code-generation workspace has a separate `codegen-v2/Cargo.lock` SHA
`00a85d477f89f73cefe844b29b3c1e0deebd57a67d7dab2e38acc768e173dd03`.

The source route is more than `tools/android-build`:

1. Tagged [Android CI](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/.github/workflows/android-ci.yml)
   installs JDK 17, Gradle 8.10.2, host dependencies, Rust, Android tools and
   internal dependencies; runs `tools/generate-files android`; then Gradle
   Android tests/build. The [release entry](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/tools/android-build)
   itself only runs `android/gradlew assembleRelease` and copies the AAR, so
   running it in a fresh checkout without generated inputs is insufficient.
2. [`tools/install-rust-dependencies`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/tools/install-rust-dependencies)
   names `nightly-2025-12-11`. [`tools/rust-bindgen`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/tools/rust-bindgen)
   sets `RUSTFLAGS=-Zlocation-detail=none`, uses
   `cargo build -Z build-std=std,panic_abort --release --lib` for
   aarch64/armv7/x86_64/i686 Android, generates the Rust C header with
   `cbindgen`, and runs `codegen-v2`. Its Cargo invocations do **not** specify
   `--locked`; a later rebuild must verify/freeze both lock files and actual
   resolved graphs rather than assume the tagged lock stayed unchanged.
3. [`tools/dependencies-version`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/tools/dependencies-version)
   names protobuf 3.20.3, GoogleTest 1.16.0, libcheck 0.15.2 and nlohmann
   JSON 3.11.3. [`tools/install-dependencies`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/tools/install-dependencies)
   builds protobuf/host plugins into `build/local`, and
   [`tools/generate-files`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/tools/generate-files)
   regenerates Java/JNI/protobuf/C++ files. `cmake/Protobuf.cmake` compiles
   protobuf 3.20.3 source into the native library. Boost comes from the host
   `brew --prefix boost` in tagged Android scripts; its exact published
   version and archive SHA are not fixed there.
4. [`android/wallet-core/build.gradle`](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/android/wallet-core/build.gradle)
   pins NDK `28.0.12674087`, CMake `3.18.1`, min SDK 23, release with
   `TW_UNITY_BUILD=ON`; root Android Gradle pins AGP 8.8.0 and Kotlin 2.1.0,
   wrapper Gradle 8.10.2. `tools/install-android-dependencies` separately
   installs NDK 23.1.7779620 for its emulator/tool flow, and
   `tools/android-sdk` finds the first API-28 clang under `ANDROID_NDK_HOME`
   for Rust. That Rust compiler selection is not inherently the same as
   Gradle's NDK 28.0.12674087: a controlled rebuild must bind both to
   explicit toolchain paths and record each compiler/linker version. The
   isolated app SDK currently has NDK 28.2.13676358; this differs from the
   tagged Gradle pin and would be a recorded toolchain change.

## Final shared link repair point

The tagged [top-level CMakeLists.txt](https://raw.githubusercontent.com/trustwallet/wallet-core/4.8.4/CMakeLists.txt)
creates `TrustWalletCore` **SHARED** for Android at lines 44–69. For each
`CMAKE_ANDROID_ARCH_ABI`, it picks the matching Rust static archive under
`rust/target/<rust-target>/release/libwallet_core_rs.a` and links it with
vendored TrezorCrypto, protobuf, Boost and Android `log`. This target is the
final ELF link. A narrow candidate adds
`target_link_options(TrustWalletCore PRIVATE "-Wl,-z,max-page-size=16384"
"-Wl,-z,common-page-size=16384")` only for Android, retaining RELRO and the
tagged JNI/crypto source. Existing `LOAD` alignment is already 0x4000, but
the explicit pair makes the intended linker inputs auditable. The candidate
must capture the actual CMake/NDK link command and prove the candidate's
arm64/x86_64 RELRO end aligns; this flag has **not** been applied or tested.
Changing the app Gradle flags cannot relink the published AAR.

## Deterministic compatibility gates for a later implementer

- Baseline both Maven AAR, four native member hashes, `classes.jar` and
  companion `wallet-core-proto` JAR. Compare Java class/method descriptors and
  JNI native exports against the candidate. Preserve all four AAR ABIs,
  including armv7; verify app R8 and `wallet-core-proto` with the app's selected
  protobuf-javalite runtime.
- Existing `tools/android_native_smoke/harness` BIP39/BIP32 vectors are
  **Web3j `MnemonicUtils`/`Bip32ECKeyPair`**, not Wallet Core JNI tests. They
  cannot establish Wallet Core behavioral parity. Add an isolated, synthetic
  old-Maven-versus-new-AAR fixture that actually loads `TrustWalletCore` and
  calls `HDWallet` mnemonic/seed/path/address and one or more app-used
  `AnySigner`/`TransactionCompiler` paths with fixed public test vectors.
  Compare derived keys/addresses and exact signature/transaction bytes, never
  real account keys or live RPC. Supplier tagged Android tests provide
  examples: `TestHDWallet.kt`, `TestMnemonic.kt`,
  `TestEthereumTransactionSigner.kt`, `TestBitcoinSigning.kt` and
  `TestSolanaSigner.kt` under
  [`android/app/src/androidTest`](https://github.com/trustwallet/wallet-core/tree/4.8.4/android/app/src/androidTest).
- Audit candidate `.so` and final APK/AAB for `LOAD` and
  `(GNU_RELRO VirtAddr + MemSiz) % 0x4000 == 0`; separately check package ZIP
  alignment, strict 16 KB native load and fixture operation with exact loaded
  member hashes and no compatibility fallback. Static ELF passing alone is
  insufficient. This repair cannot close the other native failures.

**Not yet deterministic:** the published AAR's exact build run/source commit,
Rust `libwallet_core_rs.a` hashes, selected Boost and external tarball hashes,
generator/cbindgen versions, actual Rust and C++ compiler paths, final linker
command, generated Java/JNI/protobuf hashes, and any resolver drift because
tagged scripts omit `--locked`. The immutable 4.8.4 tag and lock files are a
strong starting point, but they are not a byte-for-byte reproduction proof.
