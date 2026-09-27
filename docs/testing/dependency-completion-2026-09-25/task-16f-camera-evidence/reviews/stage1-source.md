# Task16F.4 Camera Stage1 independent source review

## Verdict

- **Specification: PASS for the source/recipe slice.**
- **Code quality: PASS.** No actionable finding remains in this committed scope.
- Reviewed `e750596a0fc82981edca81c90bec58990d9bdd2e..272b46e93a35fee9a00e0c5a0c293a471f000ba7`. No native builds, tests or device runs were repeated. Review used committed source, retained outputs and independent read-only hashes.

## Source and build controls

- `scripts/build_camera_surface_android.sh:28–49` checks the exact four-file upstream inventory and bytes with explicit failure, including untouched C++ `dd3f0271…`, version script `b578ca06…`, original CMake `6506d3c4…`, and license `809fa1ed…`. Independently checked committed blob bytes against these hashes and the worktree. The authoritative recovered Git object identities supersede the earlier inconsistent C++ prep hash.
- `android/native/camera_core_surface/CMakeLists.txt:6–25` builds only the original surface source, preserves the version script and JNI boundary, and places max/common-page-size=16384, RELRO and NOW on the final link. It avoids rebuilding unrelated libyuv/image-processing code. `--undefined-version` permits optional absent JNI_OnLoad/Unload names; actual candidate4 link commands still contain `--no-undefined`. This is accurately described as a maintained overlay, without supplier binary-reproduction claims.
- `scripts/build_camera_surface_android.sh:60–83` pins the overlay, NDK revision, compiler/linker/strip, CMake, Ninja and toolchain hashes, restricts build source to the tracked directory, and rejects an existing output directory. Critical comparisons have explicit failure branches.
- `scripts/build_camera_surface_android.sh:87–107` clears the identified compiler/CMake/include/library environment selectors before child invocation; in particular CPATH, CPLUS_INCLUDE_PATH, C_INCLUDE_PATH and LIBRARY_PATH are now cleared. The four-ABI loop selects API23, c++_static and Release, keeps unstripped outputs, and strips copied candidate members using the pinned tool.
- Pristine Apache notice trailing blank lines are source data preserving its exact hash, not a product-formatting defect. No Java, Maven metadata, app selection or existing JNI artifact changed in this commit; pubspec is the normal hook increment.

## Evidence checked

- Retained `source-guard-final2.log`: 5/5 pass, including changed C++, unexpected source, wrong SDK, and the extracted actual unset-directives child-environment control. The latter verifies sanitization directives without invoking a native build; source inspection confirms their placement before CMake. Initial missing-recipe RED is correctly identified as harness absence rather than behavioral failure.
- Candidate1 missing cassert and candidate2 optional version-name failures remain historical failures. Candidate4 is the accepted build. Its four verbose final-link records retain the expected flags and static C++ selection. The actual JNI members independently hash to:

| ABI | Bytes | SHA256 |
|---|---:|---|
| armeabi-v7a | 3528 | `ec14d0aab102b2f7a3ea53d83ae5f3b79866601e59331562fce8316b9fb7fa67` |
| arm64-v8a | 4912 | `320168d04f1bd40d8200d00e20e982aabc1c3f343958007268fc86437ae27ad7` |
| x86 | 3748 | `36d59bd71bd5261955fd54db849f3c7a02d9054e00bfde52af3433ec3da0c969` |
| x86_64 | 4896 | `c68cbb19d6d90aef62251daf6d3eadd81f00044c3ff68500990c7fcd7380a750` |

- Baseline audit exits1 on exactly the two surface ELF64 members; candidate4 static wrapper audit exits0, 2/2. The wrapper is explicitly not an installable APK/Maven AAR.
- Read `compare_stage1.py`: subprocess readelf errors propagate; explicit exceptions protect comparisons under Python optimization. Retained normal/optimized JSON is identical. All four ABIs retain API23 note, `libsurface_util_jni.so` SONAME, sole `Java_androidx_camera_core_impl_utils_SurfaceUtil_nativeGetSurfaceInfo@@VERS_1.0` export, and ordered dependencies libandroid/libm/libdl/libc. No extra shared C++ dependency is introduced. Wrong-arm64 controls fail on the semantic alignment condition in normal and optimized modes.

## Acceptance boundary

Only source preparation and static candidate qualification are accepted. The environment-control test is not a malicious-tool substitution/full-build test. No runtime compatibility, arm32 execution, camera HAL, maintained Maven resolution, app packaging/ZIP alignment or whole-app completion is inferred. Baseline static failure does not establish a runtime crash. Later slices must preserve non-surface members and dependency metadata and bind separate old/new JNI processes to installed artifacts and strict-device receipts. Current ignored logs/artifacts require the already-planned durable evidence slice; its absence is not a defect in this source-only commit.
