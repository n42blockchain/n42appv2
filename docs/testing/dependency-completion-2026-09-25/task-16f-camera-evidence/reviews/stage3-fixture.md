# Task16F.4 Camera Stage3 independent fixture review

## Verdict

- **Specification: PASS for the isolated synthetic JNI fixture slice.**
- **Code quality: PASS.** No actionable finding remains in this increment.
- Reviewed `e5a58ebcec83b4b8df809404823b8e1ffb592aa8..0bf7a55842b2cbecbe2e64dd612590895b8f740a` and final run2 evidence. No builds, tests or device actions were repeated.

## Production boundary and fixture behavior

The isolated Java Activity invokes the real public `SurfaceUtil.getSurfaceInfo` on a real Surface backed by SurfaceTexture, with explicit 321×247 default buffer size. It validates returned dimensions/positive format, then records values, its own PID, nonce, installed sourceDir/APK SHA256, classloader native lookup and executable `/proc/self/maps` rows. Exceptions produce FAIL; no production Camera JNI or app hook is introduced. The native result is not mocked or replaced by expected constants.

Separate baseline/candidate package IDs, install and clear before launch, and force-stop after each phase prevent reuse of the same loaded library. Receipt commands show success. Final verification additionally rejects equal PIDs, nonces or APK hashes. Fixtures use the same Java implementation, API23/target37 and uncompressed native packaging.

The runner uses the dedicated emulator selector on each adb call. Strict/offline snapshots are validated before and after each phase, plus final state. `finally` reasserts the dedicated emulator's strict/offline settings and persists the receipt even on failure. `run_camera_surface_fixture.py:113` now rejects an existing output directory before any device access: the pre-read stale verification-file concern is **ADDRESSED**. Retained reused-output negative exits1 with that reason. Run1 was a successful earlier fixture run, not a failed native call; run2 binds the final guarded runner.

## Independently checked run2 binding

Receipt SHA256: `22965e65e33a6225cb0188a73e3b971a6cbf465b63b23bf1675f8b10c03e7775`.

All seven receipt source SHA256 values equal the respective final committed blobs. Receipt HEAD is correctly the Stage2 parent because fixture code was uncommitted during execution; exact source hashes, subsequently matched to Stage3, supply the source binding without relabeling the historical HEAD.

| Phase | Local / installed APK SHA256 | PID | Result |
|---|---|---:|---|
| baseline | `31132b7641236c1a659e140e97380d209a3d1125e28140bf2647104164d9b33b` | 14562 | format1 / 321×247 |
| candidate | `147e8d2e9b293f36affdc9b65f0f4c1ec36122d467671c115eca8a61deebc9ed` | 14683 | format1 / 321×247 |

Independently hashed both retained APKs (1,584,981 / 1,584,960 bytes). In-process installed APK hashes match those bytes. The recorded fetched JSON equals the parsed result. Each pm path, classloader lookup and executable map uses its own installed base.apk path; nonces differ.

Independently parsed ZIP local headers and ELF program headers: both arm64 member data offsets are 1,359,872 (`0x14c000`). Baseline member SHA is `a5c9d1928ea92ec7a94dff8cf666e7739cd734198b9f0ae1d4e28ea3c86516ba`, candidate is frozen Stage1 `320168d04f1bd40d8200d00e20e982aabc1c3f343958007268fc86437ae27ad7`. Their executable PT_LOADs begin at file offset0, with file sizes2480/2496. The observed executable maps each start at APK offset0x14c000 and span16,384 bytes, which correctly matches page-rounded file mapping despite the ELF members being only4896/4912 bytes. No header patching or false requirement that a whole mapped page fit within the ELF member is used.

Both phases' pre/post and final snapshots record successful commands with PAGE_SIZE16384, linker fatal, package compatibility disabled true, airplane1 and empty IPv4 route. Installation, badging, zipalign, clear, start, result fetch and force-stop all have exit0. Strict restoration commands also exit0.

## Retained checks and limits

Tracked fixture builds both pass; baseline Java compilation executed, candidate Java was up-to-date with the same implementation. Run2 exits0. Normal and optimized offline verifier results pass. The negative-control script mutates semantic fields directly and checks exact failure reasons: wrong installed APK hash, wrong executable map offset, shared PID and false strict property each reject with exit1 in normal and optimized modes (8 outcomes). Checks use explicit exceptions, not Python assertions; these negatives are not incidental manifest-hash failures.

The official baseline also ran successfully under the strict fixture conditions. Its existing GNU_RELRO static failure remains a separate release-audit result; no old-runtime-crash claim is made. This is arm64 synthetic SurfaceInfo and loader evidence only: no arm32/x86 runtime, hardware camera, permissions, preview, scanner, full app release APK/AAB or store acceptance follows. The historical whole-app30-failure count remains unchanged until a new package audit. Durable compact evidence is the next agreed slice; preserve both APKs, run2 receipt/logs, source hashes, build logs and semantic controls there. No additional runtime gate is introduced by this review.
