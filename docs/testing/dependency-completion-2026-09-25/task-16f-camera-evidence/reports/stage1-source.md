# Task16F.4 Camera Core Stage1 source and final-link report

Status: scoped source candidate ready for independent review; **no AAR selection, app build, emulator run, or camera HAL claim yet**. Base app commit `e750596a0fc82981edca81c90bec58990d9bdd2e`. All task outputs below are ignored W files; candidate4 is the current Stage1 binary, candidates 1–3 remain historical failures/intermediates.

## Source and recipe boundary

- Published baseline: cached official `androidx.camera:camera-core:1.6.1` AAR SHA256 `a36f1c323851b51215ba476640e1eb4153882b0c368c0376e9fb905e689df84a`. Its eight native member hashes are `task-16f-camera-build/baseline-members.json`; Java `SurfaceUtil` JNI descriptor is retained in `baseline/surfaceutil-javap.txt` (`(Landroid/view/Surface;)[I`). No other CameraX component is selected or changed in Stage1.
- Tracked `android/native/camera_core_surface/upstream/` is the exact Google AndroidX revision `987b9ac8585b31424a397206c492196dd163997b` source, validated by Git tree/blob IDs and SHA256. Critical C++ SHA256 is **`dd3f02712e359fa0b987bfef17661686fa130666674fca2d91405b50ab309779`**; the older `0ef...` prep claim is superseded. `jni.lds` SHA256 `b578ca...`; pristine official Apache notice SHA256 `809fa1...`. `README.md` records full identities.
- Maintained standalone overlay builds only `surface_util_jni` from untouched C++ and `jni.lds`. The upstream top-level CMake configures unrelated libyuv image processing. Recipe `scripts/build_camera_surface_android.sh` pins API23, four published ABIs, NDK28.2.13676358, CMake3.22.1, Ninja/clang++/ld.lld/llvm-strip/toolchain/overlay hashes; strips candidate members with pinned `llvm-strip --strip-unneeded`. It clears inherited compiler, CMake, header and library path selectors before CMake. This is a maintained overlay, not a byte-for-byte reproduction of the supplier's build.
- `c++_static` supplies upstream `<cassert>`; candidate DT_NEEDED proves no extra C++ shared-library dependency. The NDK's `--no-undefined` remains active. Additional `--undefined-version` only permits upstream `jni.lds` to name optional absent `JNI_OnLoad`/`JNI_OnUnload`; it does not relax unresolved symbol checking. Exact sole versioned JNI export is verified below.

## Commands and results

All paths relative to app worktree unless noted. No native source file was modified to get the link.

1. Functional baseline static RED: `python3 scripts/audit_android_native.py <cached-camera-core-1.6.1.aar>` exited **1**, exactly `jni/arm64-v8a/libsurface_util_jni.so` and `jni/x86_64/libsurface_util_jni.so` fail ELF LOAD/GNU_RELRO 16 KB. Raw `task-16f-camera-build/baseline-audit-command.log`. This is a static failure, not evidence of an observed runtime crash.
2. Initial `python3 -m unittest test.scripts.test_camera_surface_build -v` RED was a missing recipe (test harness absent), raw `source-guard-red.log`. Later source guard mutation controls reject changed C++, extra source file, and wrong SDK. Final same command exits **0, 5/5** in `source-guard-final2.log`, including no-build child environment control for CPATH/CPLUS_INCLUDE_PATH/C_INCLUDE_PATH/LIBRARY_PATH.
3. Initial `bash scripts/build_camera_surface_android.sh --build --out-dir <W/candidate>` exits **1** because `ANDROID_STL=none` omits `<cassert>`; `candidate-build.log`, `candidate/build-armeabi-v7a.log`. Candidate2 exits **1** because the pinned AndroidX `jni.lds` names absent optional JNI_OnLoad/Unload and NDK defaults `--no-undefined-version`; `candidate2-build.log`, `candidate2/build-armeabi-v7a.log`. Both are preserved, not relabeled as GREEN.
4. Final `bash scripts/build_camera_surface_android.sh --build --out-dir <W/candidate4>` exits **0**, all four ABIs; raw `candidate4-build.log` and per-ABI `candidate4/{configure,build}-<abi>.log`, unstripped CMake output plus stripped `candidate4/jni/<abi>/libsurface_util_jni.so`. Relevant compiler/link command lines include API23, `c++_static`, `--no-undefined`, `--undefined-version`, max/common page 16384, RELRO and now. No inherited header/library override was present in this environment; guard also clears them for later runs.
5. `python3 scripts/audit_android_native.py <W/candidate4/surface-only-static-probe.zip>` exits **0**, 2/2 ELF64 LOAD/GNU_RELRO checks, raw `candidate4-audit-command.log`. The ZIP is a static audit wrapper of four candidate surface members, **not** a Maven AAR or installable app.
6. `python3 <W/task-16f-camera-build/compare_stage1.py>` and `python3 -O` both exit **0**, full JSON in `compare-stage1-final.json` and `compare-stage1-final-optimized.json`. The comparison reads actual `llvm-readelf` from baseline/candidate members for all four ABIs: identical ordered DT_NEEDED (`libandroid.so`, `libm.so`, `libdl.so`, `libc.so`), SONAME, exactly one `Java_androidx_camera_core_impl_utils_SurfaceUtil_nativeGetSurfaceInfo@@VERS_1.0` export, Android API23 note; baseline arm64/x64 alignment false and final candidate true. Wrong arm64 member negative controls exit **1** in normal and `-O` modes, `compare-negative*.err`.

Final stripped candidate members:

| ABI | SHA256 | bytes | ELF64 LOAD+RELRO 16 KB |
|---|---|---:|---|
| armeabi-v7a | `ec14d0aab102b2f7a3ea53d83ae5f3b79866601e59331562fce8316b9fb7fa67` | 3,528 | not applicable |
| arm64-v8a | `320168d04f1bd40d8200d00e20e982aabc1c3f343958007268fc86437ae27ad7` | 4,912 | pass |
| x86 | `36d59bd71bd5261955fd54db849f3c7a02d9054e00bfde52af3433ec3da0c969` | 3,748 | not applicable |
| x86_64 | `c68cbb19d6d90aef62251daf6d3eadd81f00044c3ff68500990c7fcd7380a750` | 4,896 | pass |

## Still required after Stage1 review

Select an explicit maintained local Maven AAR at the same `camera-core:1.6.1` coordinate, replacing only four surface members and preserving the other four JNI/image-processing members, Java/resources/manifest and complete `.module` variant checksums/dependency constraints. Prove normal Gradle resolves this exact local module only. Then run valid old/new `SurfaceUtil.getSurfaceInfo` in separate fresh processes on dedicated offline strict-16KB emulator5560 with installed APK/member/PID/map and pre/post environment receipts; compare format/width/height. The static Stage1 result does not prove runtime behavior, app packaging, ZIP alignment, camera capture or final whole-app ELF closure (owned checkpoint still has 30 remaining failures).
