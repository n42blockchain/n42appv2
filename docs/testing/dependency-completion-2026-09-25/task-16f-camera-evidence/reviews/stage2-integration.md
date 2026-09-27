# Task16F.4 Camera Stage2 independent integration review

## Verdict

- **Specification: PASS for this Maven selection / compilation slice.**
- **Code quality: PASS.** No actionable finding in the reviewed increment.
- Range: `272b46e93a35fee9a00e0c5a0c293a471f000ba7..e5a58ebcec83b4b8df809404823b8e1ffb592aa8`.
- Read-only review of committed source/artifacts and retained logs; no build, test or device rerun. Prior native source review remains accepted.

## Artifact and metadata checks

Independently read the six Maven artifacts directly from the final commit and confirmed they equal the reviewed working bytes. Maintained AAR SHA256 is `a31d23a4774d90e5219c9ac4b43db41f72b61185de7ddcc99a9b0c69df158883`; module SHA256 is `2f4f84adb17530643754c4f1c83dc6677ae771b09987112f0cf152f521cda347`.

Compared the committed AAR against pinned official 1.6.2: same ordered 28-member inventory, exactly four surface JNI members changed, and all four match the accepted candidate4 hashes. The other 24 members remain byte-identical, including official 1.6.2 Java, resources, manifest, notices and image-processing JNI. The original POM, source JAR, sample source JAR and version metadata remain byte-identical.

Independently recomputed size/SHA512/SHA256/SHA1/MD5 for both API/runtime AAR metadata entries. These are the only semantic changes in `.module`; all dependencies, constraints, attributes and auxiliary variants are preserved. The 9 API / 18 runtime dependency counts and 9 family constraints per variant remain intact.

`scripts/build_camera_core_maven.py:22–135` uses explicit failure checks (not optimization-sensitive assertions), pins official AAR/POM/module inputs, checks referenced auxiliary artifacts, validates the complete candidate ABI/hash set, refuses an existing destination, and post-checks every AAR member. It rejects missing/duplicate API/runtime variants. Candidate hashes are explicitly supplied via the tracked manifest; this is a frozen-artifact packaging recipe, not a claim that every native rebuild is byte-identical. The small native build-ID variance does not invalidate the selected exact hashes.

## Actual Gradle selection and compile evidence

- `android/build.gradle.kts:7–17` restricts the exclusive local repository to exactly `androidx.camera:camera-core:1.6.2`; `android/app/build.gradle.kts:163–164` explicitly requests that coordinate. Other CameraX modules continue using normal official repositories.
- Read `dependency-insight-core.log` and the actual component-filtered `print_camera_artifacts.gradle` inspector. `selected-artifacts5.log` reports the tracked Core AAR path and exact `a31d23…` hash in app `releaseRuntimeClasspath`; camera2, camera2-pipe and lifecycle resolve to official 1.6.2 AARs. The inspector filters the real graph; it does not inject dependency substitutions. Earlier generic-view/offline inspection failures are disclosed separately.
- `maven-test-final.log`: four focused tests pass, including wrong candidate hash, missing member, missing/duplicate variants and preservation/checksum checks. Initial missing-script RED is honestly identified as absent implementation; it is not advertised as behavioral mutation evidence.
- `maintained-aar-audit.log`: four ELF64 members checked, zero failures, exit0. This includes the unchanged image-processing members; it is not ZIP/device acceptance.
- `check-aar-metadata.log` passes with the relevant check up-to-date. `app-release-javac.log` records successful app release Java compilation, 625 tasks / 106 executed, 2m28s, with normal dependencies including Flutter release AOT and Kotlin compilation. The report correctly acknowledges this expanded task graph and does not call it an APK/AAB build.
- Synthetic fixture candidate Java compilation executed and passed; baseline Java compilation was up-to-date against preserved official Java bytes. Neither log demonstrates native execution. Hook build number 2914→2915 followed compilation and is not presented as a fresh build.

## Remaining acceptance

This review accepts the maintained Maven artifact and its actual app dependency/compile integration. Synthetic old/new JNI runtime, strict-device receipts, installed APK/member/PID/map bindings, final app package/ZIP checks and durable evidence remain pending slices. No physical-camera/HAL, store, whole-app native closure or cross-output-path binary reproducibility claim is accepted. The retained historical whole-package checkpoint still has 30 failing members; this source integration alone does not establish a new whole-package count.
