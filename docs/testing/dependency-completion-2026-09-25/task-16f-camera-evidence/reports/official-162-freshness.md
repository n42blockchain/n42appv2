# CameraX 1.6.2 freshness check for the maintained native repair

Read-only check, 2026-09-27. No Gradle resolution/build, app or SDK edit,
device call, or global cache write. Exact official 1.6.2 Maven POMs, Gradle
module metadata, Camera Core AAR and sources JAR were downloaded into the
ignored `task-16f-camera-162-freshness/` directory; SHA-256 and origin URLs
are in its `manifest.json`. The existing Stage 1 relinked native candidate
remains a **1.6.1-source** candidate until selected and tested in a maintained
artifact.

## Decision

**Target the maintained Camera Core AAR at stable 1.6.2 before app
integration, and select the CameraX family at 1.6.2.** The official
[CameraX release notes](https://developer.android.com/jetpack/androidx/releases/camera#1.6.2)
list 1.6.2 on August 26, 2026; its documented fix removes a JSpecify type
annotation causing a downstream JDK 21+ compilation crash. This fixes a
real Java artifact issue even though the native surface library is unchanged.
Keeping a maintained 1.6.1 Core AAR would leave an unnecessary stable
version gap; upgrading *only* the version without the relink would retain
the recorded GNU_RELRO failure.

There is no demonstrated version constraint preventing 1.6.2. The current
`mobile_scanner:7.4.2` cached `android/build.gradle.kts:82-83` requests
`camera-lifecycle:1.6.1` and `camera-camera2:1.6.1` as ordinary
`implementation` dependencies. No app Gradle rule or lock for CameraX was
found. Official 1.6.2 module metadata declares `requires: 1.6.2`, never
`strictly`, for its atomic CameraX family. [Gradle's documented `require`
semantics](https://docs.gradle.org/current/userguide/rich_versions.html)
allow conflict resolution to a higher version, while its default conflict
resolution selects the highest requested version. Therefore an app-level
normal CameraX 1.6.2 dependency/constraint and the maintained
`camera-core:1.6.2` artifact should promote the scanner's requests to the
1.6.2 family. This is a **metadata-based compatibility inference**, pending
actual `releaseRuntimeClasspath` dependencyInsight, Kotlin compilation and
scanner tests; it is not a claim of a completed upgrade.

## Exact metadata and Java/native comparison

Official Google Maven files inspected:

| Module 1.6.2 | POM SHA-256 | `.module` SHA-256 | Runtime CameraX edges |
| --- | --- | --- | --- |
| [camera-core](https://dl.google.com/dl/android/maven2/androidx/camera/camera-core/1.6.2/) | `cddb5bb0653654d8b7c2833484f4684d881dc7509411132e73a5fb4b167fd13c` | `bee75b4ef561862030702a51f692057e034ae1f600f3091b2a5e5a89856ab410` | 9 CameraX family constraints at 1.6.2. Its 18 non-CameraX runtime dependencies have identical name/version requirements to retained Core 1.6.1 module metadata. |
| [camera-camera2](https://dl.google.com/dl/android/maven2/androidx/camera/camera-camera2/1.6.2/) | `23020a27494b69f7b77c3c1598923789bfada5c145d31d0893fae1ee895213df` | `4694b995fbb4934e5e1e3cedabef426e799a510cfc179b659c4e9632f6b2fe75` | Requires Core and camera2-pipe 1.6.2; 9 family constraints. |
| [camera-lifecycle](https://dl.google.com/dl/android/maven2/androidx/camera/camera-lifecycle/1.6.2/) | `7562a6960db6bd8f46441c3467a2b51d33b98ece1c118ac30538dd6c54b49ce0` | `bd7fd00cb9de0f2ce8c3400b52504cf7691590bb29a1550a71b58255e483ff47` | Requires Core 1.6.2; 9 family constraints. |
| [camera-camera2-pipe](https://dl.google.com/dl/android/maven2/androidx/camera/camera-camera2-pipe/1.6.2/) | `c3bc970a6a0657ff9b6df2cd8241098746f8e54bc5b74e56899050d76fdb9f66` | `5470741b0a6fe88e560e7d929097e2ec60e7406aef09b48ab900b0befa102c0f` | Requires `featurecombinationquery:1.6.2`; 9 family constraints. |

The official Core 1.6.2 AAR SHA-256 is
`ebd66f090414f4c12f23a55b5023aeee1b096da8a06c02a0b6fb3520c4ddadf6`.
It and the selected 1.6.1 AAR contain the same 28 ZIP entries. All **eight**
JNI `.so` entry bytes are identical across versions, including four
`libsurface_util_jni.so` and four `libimage_processing_util_jni.so` members.
The failing arm64 surface SHA-256 is
`a5c9d1928ea92ec7a94dff8cf666e7739cd734198b9f0ae1d4e28ea3c86516ba`;
x86_64 is `e5311942b4fce0f7f2505d41150cf9921e558a6368929cb73127450f74dd4fe4`
at **both** versions. Original 1.6.2 JNI therefore still needs the same
16 KB RELRO repair; no native source or behavior change was observed at the
artifact-byte level.

The 1.6.2 AAR preserves the 1.6.1 manifest, `proguard.txt`, and AAR metadata
entry bytes. Its `classes.jar` differs (1.6.1 SHA-256
`9fd34cd0d07b81e462b613068b2fa10474b7a3eb2727374babccbc2b2c1c90e4`;
1.6.2 `5854c5d0793b7170ee13c457bc7014f6808a2f00e8272f87e5d4fa10d531b776`).
Static inspection found **751 class names in each**, no added/removed
classes, and exactly nine changed class bytes: `SurfaceRequest` and its eight
existing nested classes. `/usr/bin/javap -public -s` gives identical public
method/field descriptors for all nine changed classes. The official 1.6.2
sources JAR SHA-256 is
`9803a0c47248a567c99dbc1b95e07afb8ccc5a7e097ce3f76dd126be3a53ee44`;
both Core sources JARs have 371 files, with only
`androidx/camera/core/SurfaceRequest.java` changed. Its diff removes a
`CallbackToFutureAdapter.@NonNull Completer` type-use annotation and adds a
comment explaining the JDK 21+ issue. This supports a narrow Java change,
but is not proof of whole-scanner runtime compatibility.

## Minimal integration adjustment and evidence limits

Use the **official 1.6.2 Core AAR as the package base** and replace only
its four byte-identical-original `surface_util_jni` members with the
source-relinked Stage 1 outputs after their ABI/hash checks. Preserve 1.6.2
`classes.jar` so the JSpecify compiler fix survives; preserve the other
four image-processing JNI members and every other AAR entry. Publish/select
the maintained Core artifact with accurate 1.6.2 POM/module checksums and
the original dependency/atomic-family constraints, without editing Gradle's
global cache or keeping a stale official AAR checksum. Add the minimum
app-level 1.6.2 CameraX version request and prove the release runtime graph
selects Core, camera2, camera2-pipe, lifecycle and any other included
CameraX modules all at 1.6.2. Because the Stage 1 relink used pinned
1.6.1-boundary source, label that native provenance explicitly even when
packaged with official 1.6.2 Java. The byte-identical official native
members make reuse a plausible narrow path, not proof of source identity or
runtime equivalence.

Follow with the existing Stage 1 native ELF/JNI comparison and offline
`SurfaceUtil.getSurfaceInfo` fixture against the actual maintained 1.6.2
AAR, then scanner Kotlin compile, final APK/AAB member mapping and strict
16 KB audit. Existing `integration_test/wallet_scanner_camera_device_test.dart`
and `integration_test/chat_scanner_camera_device_test.dart` still require a
camera-capable device for camera permission/preview/lifecycle acceptance.

The 1.6.2 [release-note commit endpoint](https://developer.android.com/jetpack/androidx/releases/camera#1.6.2)
is `9046f07948c1e7a89aaec581463730f4d666611b`. Google Gitiles exact
directory and CMake file requests returned HTTP 503 in this bounded check,
and the GitHub mirror did not resolve that endpoint SHA. Thus the exact
1.6.2 C++ Git blob identity was **not** independently established here.
Maven's byte-identical JNI across 1.6.1/1.6.2 is the direct artifact fact;
the retained 1.6.1-boundary pinned C++ remains the maintained native source
input. No whole-family resolution, Java/Kotlin compile, synthetic JNI runtime
or actual camera runtime was executed in this read-only task.
