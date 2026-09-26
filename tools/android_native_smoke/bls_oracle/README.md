# Offline MobileSdk BLS oracle

This is a test-only Android JNI library. It independently checks the actual `Api.generateBls12381Keypair()` result from the selected packaged MobileSdk AAR using pinned `blst 0.3.15`: deserialize the 32-byte secret, derive and compare its 48-byte public key, sign a fixed synthetic message, verify that signature, and reject a changed message. The keypair is generated inside the disposable fixture process and is never printed, saved or used with a network endpoint. This oracle is not an app dependency or part of the production AAR.

With Rust 1.97.1, cargo-ndk 4.1.2 and Android NDK 28.2.13676358, from this directory:

```sh
cargo +1.97.1 test --locked --offline
ANDROID_NDK_HOME=/absolute/ndk/28.2.13676358 \
  CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS='-C link-arg=-Wl,-z,max-page-size=16384 -C link-arg=-Wl,-z,common-page-size=16384' \
  cargo +1.97.1 ndk -t arm64-v8a -P 23 -o /absolute/task/jni \
    build --release --locked --offline
```

Set `N42_SMOKE_BLS_ORACLE_JNILIBS=/absolute/task/jni` when running the isolated Flutter harness `integration_test/native_mobile_sdk_bls_oracle_test.dart` on the disposable 16 KB emulator. The harness resolves the selected SDK AAR from `N42_SMOKE_MOBILE_AAR` or the app's tracked SDK location. `N42_SMOKE_BLS_ORACLE_JNILIBS` is never set for release app builds. The pinned lock SHA-256 for this test tool is `59a80fbfe33fe036a464c0fe8478d7cf84789a5bd058b40069c9905cb100ddcb`.
