# Task16F.3 Vodo fixture fix round 1 review

Range: `c9b7d676755588903edff227b7d6ba3b0172cd1d..ed9d78f4b177259fbb2b4b6b6bc2c7bfa5ac3ae9`.

**Spec verdict: PASS for this scoped fix. Quality verdict: PASS. Both original P2 findings ADDRESSED; no new blocking findings.**

## Finding closure

### P2: strict pre/post state missing — ADDRESSED

`run_vodo_release_fixture.py:39` records each actual emulator-5560 command, exit and output. `require_strict` explicitly requires page size16384, fatal linker, package compatibility disabled, airplane1 and empty routes before Flutter invocation. Its `finally` captures the post snapshot even after a fixture failure; properties are never changed. The verifier independently requires both snapshots and successful fixture exit/expected release invocation/offline switches.

Run2 receipt has all ten observations with exit0 and expected values, including the previously absent `pm.16kb.app_compat.disabled=true`. It binds the runtime log hash, source hashes, selected AAR/probe, invocation and resulting APK. Retained controls show semantically wrong page size, enabled compatibility and missing property rejection under normal and optimized Python. Full-runner controls establish rejection before the Flutter command, rather than only unit-testing an unused helper. Historical run1 remains explicitly weaker evidence.

### P2: local/installed APK and process map identity missing — ADDRESSED

The Dart fixture streams the actual mapped base.apk through SHA256 from inside the same process and emits its PID/path/digest. The runner compares that installed digest with the locally produced APK. `verify_vodo_release_fixture.py:130` then checks installed PID and path against the FRB executable mapping, installed digest against the supplied local APK, and all three against the receipt. Existing AAR/member-byte and ZIP-range checks remain.

Independently rehashed local run2 APK to `f1abe0b14e095896dd7428b54972cdd85693771778e214f9bf35b63447cfe285`, equal to both receipt and device-computed digest. Runtime PID13968 and exact installed `/data/app/.../base.apk` path match both log markers. Wrong installed hash, path and PID controls update the related receipt/log hash consistently and fail at the intended semantic checks in both Python modes.

## Reviewed evidence and limits

- All **seven** receipt source hashes independently match committed blobs at `ed9d78f4…`, including runner, verifier, fixture, vector, Gradle and pubspec/lock. Receipt `git_head=c9b7…` correctly denotes the base before those working-source changes were committed; it is not used as a false claim that the base already contained the new runner. The runtime log hash also matches.
- Retained runner output reports success; actual Flutter log reports **1/1**, with release map, installed digest and legacy/fresh crypto success. Reported release AAR/member remain `7878472e…` / `3807e8f…`; debug host mode is not promoted to an app release build.
- Controls retain verifier14/14, strict-helper8/8 and full-preflight6/6 expected outcomes. No acceptance branch relies on Python `assert`. `crypto` remains version3.0.7; the harness changes its dependency classification to direct for the APK digest use, without a runtime SDK upgrade.
- Whole fixture audit remains **13 checked / five non-Vodo failures**. No whole APK, main-app release, other-ABI runtime or remaining supplier-native acceptance follows from this fix.
- Durable archive remains the next separately reviewed group. Preserve this exact run2 APK (the reported deterministic gzip plan is suitable subject to archive verification), AAR, receipt, log, source bindings, negative-control source/output and historical weaker runs. This verdict does not pre-approve the uncommitted archive.

Read-only static source/artifact review; no device execution, rebuild or test rerun. One initial independent hash helper used an unavailable Python `hashlib.file_digest`; a streaming SHA256 read completed successfully instead. No tracked files were changed.
