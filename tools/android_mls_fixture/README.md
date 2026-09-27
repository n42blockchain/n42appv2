# Android MLS JNI fixture

This fixture runs the app's `MlsNativeBridge` JNI contract with synthetic identities and room data. It requires the dedicated `emulator-5560` Android 37 arm64 emulator with 16 KB pages, linker mode `fatal`, and application compatibility disabled. It has no network or app account dependency. The runner refuses a different device state and leaves the strict settings intact.

```sh
export ANDROID_SDK_ROOT=/Users/jieliu/.codex/toolchains/android-sdk-37
export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/28.2.13676358"
scripts/build_mls_android.sh /absolute/fresh/stage
tools/android_mls_fixture/run.sh /absolute/fresh/stage/arm64-v8a/libn42_mls.so /absolute/fresh/evidence
```

The build recipe pins the tracked `rust/n42_mls` tree and lock, Rust 1.97.1, cargo-ndk 4.1.2, NDK 28.2.13676358, and Android API 26. It runs locked and offline. The script creates a fresh staging directory and never copies binaries into the app. Review all four staged binaries, JNI exports, 64-bit LOAD and GNU_RELRO alignment, and the fixture before explicit selection.

The runner compiles the Java fixture with `javac --release 8` and Android build-tools 37.0.0 `d8`, pushes it and the selected library to `/data/local/tmp/n42-mls-fixture`, and starts a standalone Android `app_process`. It records the host/device library SHA256, DEX SHA256, exact mapped library path, strict device settings before and after, and each protocol check. It checks key-package generation, add/welcome, bidirectional messages, self-update/commit, and invalid input. Ciphertext and key-package bytes are randomized; the checks compare semantics, not arbitrary byte equality.

The arm64 fixture is a JNI source and runtime gate. It does not establish 32-bit runtime behavior, release APK selection, ZIP alignment, or full application behavior. Final whole-package APK/AAB acceptance follows the other Task16F native repairs.
