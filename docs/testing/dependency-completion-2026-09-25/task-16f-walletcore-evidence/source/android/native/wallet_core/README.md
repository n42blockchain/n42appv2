# Wallet Core 4.8.4 Android JNI candidate

`maven/com/trustwallet/wallet-core/4.8.4/wallet-core-4.8.4.aar` is a maintained
relink of the four published Android JNI members. It keeps the original 4.8.4
coordinate, all nine non-native AAR ZIP members (four files and five directory
records) and their extracted bytes,
including `classes.jar` and `AndroidManifest.xml`. The companion
`wallet-core-proto:4.8.4` JAR, POM, module metadata and both published source
JARs are copied byte-for-byte. The core module metadata changes only the two
API/runtime AAR file size and digest records; its source variant and all
dependencies remain published values.

The native source is Wallet Core tag 4.8.4 commit
`d40d24a63d92619167903369308bf0e2f7eb3a59`. The Android final shared
link alone adds `-Wl,-z,max-page-size=16384` and
`-Wl,-z,common-page-size=16384`. This build uses pinned task-owned generator
inputs and NDK 28.2/CMake 3.22.1 rather than claiming to reproduce the
publisher's unknown build run. `scripts/build_walletcore_maven.py` pins the
published artifacts, stripped JNI candidates and audit manifests before
staging the module. The build receipts and exact member comparison are under
`.superpowers/sdd/dependency-completion-20260925/task-16f-walletcore-build/`.

The selected AAR SHA-256 is
`560cf86e132e4b4ee18afb70daf670e12e8fd34684a03eb38b9e49e39cd0f57d`.
Both 64-bit JNI members pass the repository's ELF LOAD/GNU_RELRO 16 KB audit.
The four stripped JNI members retain the published SONAME, NEEDED libraries,
all 435 `Java_wallet_core_jni_*` exports, and the full same-ABI GLOBAL export
name sets. Generated Java and proto public descriptors match the published
classes. APK ZIP alignment, API-26 loading and synthetic crypto behavior need
separate device evidence.

`licenses/` retains byte-identical Wallet Core, TrezorCrypto, Protobuf and
Boost source license/notice files used by this native build. The task-owned
Cargo package graph and license inventory also cover the Rust inputs; these
files are a source inventory, not a final legal clearance claim.
