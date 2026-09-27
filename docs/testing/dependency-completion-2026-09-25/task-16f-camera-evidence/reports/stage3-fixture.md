# Task16F.4 Camera Surface synthetic runtime report

Status: scoped old/new synthetic Surface JNI comparison **PASS** on dedicated emulator5560; no real camera HAL, app scanner, final release APK/AAB or store proof. Stage2 maintained-module commit `e5a58ebcec83b4b8df809404823b8e1ffb592aa8`; Stage3 fixture source commit `0bf7a55842b2cbecbe2e64dd612590895b8f740a`. The final fixture source is under `tools/android_native_smoke/camera_surface_fixture/`, `run_camera_surface_fixture.py`, and `verify_camera_surface_fixture.py`; seven exact source SHA256 values are bound in final run2 receipt and were recomputed against the committed files after the hook. All device actions addressed only emulator5560 and synthetic packages `ai.n42.fixture.camera.baseline` / `.candidate`.

## Inputs and build

- Official baseline 1.6.2 AAR SHA256 `ebd66f090414f4c12f23a55b5023aeee1b096da8a06c02a0b6fb3520c4ddadf6`; maintained 1.6.2 AAR SHA256 `a31d23a4774d90e5219c9ac4b43db41f72b61185de7ddcc99a9b0c69df158883`. The same fixture Java class calls the public official 1.6.2 `SurfaceUtil.getSurfaceInfo` using `SurfaceTexture(0)` with `setDefaultBufferSize(321, 247)` and an actual `Surface`; it records format/width/height from `SurfaceInfo`, installed APK SHA/path, classloader native lookup, executable APK maps, PID and process nonce. It does not invoke a camera device or process QR content.
- Tracked fixture project `assembleDebug` with `ANDROID_HOME=/opt/homebrew/share/android-commandlinetools`, pinned Gradle wrapper `android/gradlew`, `--offline --no-daemon`, and `-PcameraFixtureAar=<official or maintained AAR> -PcameraFixtureAppId=<separate package>`: baseline exit0 `fixture-tracked-baseline.log`, candidate exit0 `fixture-tracked-candidate.log`. Both are targetSdk37/minSdk23, four ABIs, direct ZIP-mapped native members, `zipalign -c -P 16 -v 4` pass. Exact tracked-source APKs equal earlier W prototype APKs bytewise:
  - baseline `fixture-baseline-tracked.apk` 1,584,981 bytes SHA256 `31132b7641236c1a659e140e97380d209a3d1125e28140bf2647104164d9b33b`; arm64 JNI SHA256 `a5c9d1928ea92ec7a94dff8cf666e7739cd734198b9f0ae1d4e28ea3c86516ba`.
  - candidate `fixture-candidate-tracked.apk` 1,584,960 bytes SHA256 `147e8d2e9b293f36affdc9b65f0f4c1ec36122d467671c115eca8a61deebc9ed`; arm64 JNI SHA256 `320168d04f1bd40d8200d00e20e982aabc1c3f343958007268fc86437ae27ad7`.

## Final runtime run2

`python3 tools/android_native_smoke/run_camera_surface_fixture.py --baseline-apk <W/fixture-baseline-tracked.apk> --candidate-apk <W/fixture-candidate-tracked.apk> --out-dir <W/runtime-run2>` exited **0** (`runtime-run2.log`). The runner rejects an existing output directory before device access; `reused-output-negative.log` exit1 proves prior run1 cannot leave a stale verification beside a later failed run. Historical run1 (`runtime-run1/`, `runtime-run1.log`) passed before that runner robustness fix and is preserved as separate evidence, not relabeled as the final source run.

Run2 receipt `runtime-run2/camera-runtime-receipt.json` SHA256 `22965e65e33a6225cb0188a73e3b971a6cbf465b63b23bf1675f8b10c03e7775` has contemporaneous per-phase pre/post and final snapshots: `PAGE_SIZE=16384`, linker compatibility `fatal`, package compatibility disabled `true`, airplane mode `1`, empty IP route, all commands exit0. The runner reasserts strict/offline state in `finally` and leaves both synthetic apps installed but force-stopped. Device computed installed APK hashes match the exact local APKs; `pm path`, classloader lookup and executable APK map all name each phase's own `/data/app/.../base.apk`. The verifier parses each APK local ZIP header (uncompressed arm64 JNI member data offset `1,359,872`, divisible by16,384) and the actual ELF executable PT_LOAD, then binds a page-rounded **16,384-byte** executable map at that ZIP offset. It does not incorrectly require the full mapped page to fit inside the 4.9 KB ELF member.

| Phase | PID | installed APK SHA prefix | arm64 JNI SHA prefix | SurfaceInfo |
|---|---:|---|---|---|
| Official baseline | 14562 | `31132b76` | `a5c9d192` | format1, width321, height247 |
| Maintained candidate | 14683 | `147e8d2e` | `320168d0` | format1, width321, height247 |

PIDs and process nonces differ; both are distinct fresh package processes. The old baseline's known static GNU_RELRO endpoint failure did **not** cause a crash in this synthetic invocation. This does not make the old library pass the release ELF alignment audit.

## Offline replay and limits

`python3 tools/android_native_smoke/verify_camera_surface_fixture.py --receipt <W/runtime-run2/camera-runtime-receipt.json> --baseline-apk <W/fixture-baseline-tracked.apk> --candidate-apk <W/fixture-candidate-tracked.apk>` and `python3 -O` both exit0, `verify-run2-normal.log`, `verify-run2-optimized.log`. Four altered receipt controls—wrong installed APK hash, wrong executable map offset, same PID, and false strict property—each reject with exit1 and the intended reason in both modes (`verify-run2-negative-controls.log`, mutation script/JSON retained). All seven behavior-bearing fixture source SHA256 values were independently recomputed equal to receipt values after source commit `0bf7a5584`. The exact AAR/APK/member hashes above bind the source and binary selection to this run.

This fixture establishes a native SurfaceInfo call and 16 KB loader/map identity only. It does not exercise `mobile_scanner` camera permission, preview, capture, hardware, orientation or real device camera HAL. The last measured whole-app release has 30 native failures including Camera's two; a fresh app release APK/AAB audit and other supplier repairs are separate later gates.
