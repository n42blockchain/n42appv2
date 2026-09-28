# Wallet Core 4.8.4 maintained Android AAR packaging checkpoint

## Inputs and JNI strip

This stage uses the independently accepted exact-tag generation and four-ABI
links in `task-16f-walletcore-build-report.md`; it does not relink or change
crypto/Java/proto source. NDK 28.2 `llvm-strip` SHA-256
`438848c3cb13a8fa7607507779465f3e3426637eb2e9c605cde44e49c8539f1f`
ran `--strip-all` on task-owned **copies** of the four unstripped candidates.
`task-16f-walletcore-build/candidate-stripped/strip-manifest.json` (SHA-256
`10d13a583bb8e9b26ad3eac7c6c3d4b45ea0bfc3606c7f159dea0581a41db817`)
records each before/after path, byte count, hash, tool and flag; individual
`{ABI}-strip.log` files show exit 0. The resulting JNI member bytes are:

| ABI | Stripped bytes | SHA-256 |
| --- | ---: | --- |
| arm64-v8a | 17,693,184 | `f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d` |
| armeabi-v7a | 12,613,620 | `70de897add9f5a4d661b0429e29a41f9f167ce00a4c4cc680c03b2952cd0370e` |
| x86 | 20,416,716 | `fdd8161a94c389fe992826769756dfd59c81b94f48b5f55c9018ec3620e03f8d` |
| x86_64 | 19,166,392 | `abee03b7fbbdb90a6bdeec7fdf857ef2fb60df9b8ffc6f6d7dbb56af8332d1f3` |

`candidate-stripped/audit/summary.json` (SHA-256
`b9fc268ef4c0575ebc18432a8119710c46e3d96f92ed300759362ea506402e8c`)
and per-ABI NDK `llvm-readelf` transcripts show each stripped output retains
the published same-ABI complete GLOBAL/JNI export sets, SONAME
`libTrustWalletCore.so`, NEEDED `liblog.so`, `libm.so`, `libdl.so`, `libc.so`,
16 KB LOAD congruence and GNU_RELRO end alignment. Both 64-bit stripped
outputs pass the repository ELF64 LOAD/RELRO function. Native import tuple
parity was proved on the unstripped outputs in the source/build review;
stripping does not claim device loading or API-26 runtime behavior.

## Published metadata and exact source artifacts

The published AAR, core POM/module, proto JAR/POM/module are pinned by hashes
in `scripts/build_walletcore_maven.py`. Both published source variants were
absent from the initial Gradle artifact cache. Anonymous GitHub Packages
download returned HTTP 401; Maven Central returned HTTP 404. A task-owned
standalone Gradle 9.8 resolver then used the project's existing GitHub Packages
repository and already configured `android/local.properties` credentials
internally, without printing or copying credential values. The first resolver
using this worktree's local properties failed with `Username must not be null`;
the existing main-project properties resolved both exact source classifiers.
The copied `wallet-core-4.8.4-sources.jar` is 77,500 bytes/SHA-256
`226c2847b6a4fc0e930eb4283e5224509527eb91644d5a1ec41ef60d1fbda0f4`;
`wallet-core-proto-4.8.4-sources.jar` is 942,338 bytes/SHA-256
`cf637bfd06879e9cfa35cd47f6a2ea56f2ea8ab987fe4410f9dcfa14ad268d12`.
Both match their published `.module` size/hash exactly. Resolver commands and
success/failure logs remain under `task-16f-walletcore-build/`; no credentials
are stored there.

The core POM still depends on `wallet-core-proto:4.8.4`. The proto POM still
requires `protobuf-javalite:3.22.3`. The real app separately declares
`protobuf-javalite:4.36.2`, which **actually resolves to 4.36.2** on both
release compile and runtime classpaths; this stage does not misstate the
published POM requirement as the app's selected runtime. All 141 generated
JNI/proto Java source files compile with pinned JDK 17 `javac --release 8`
against the app-selected 4.36.2 JAR (SHA-256
`8f4f93d08cb37130ecb0bc69d376d7d27c36ff04ddb1bb27430b06caa9fa062e`),
exit 0 in `java-api-compare/app-runtime-javac.log`. Prior published-descriptor
comparison used 3.22.3 and remains a separate result. Synthetic runtime
serialization and signing paths are still pending.

## Exact AAR and local Maven repository

`scripts/build_walletcore_maven.py` pins the official inputs, stripped JNI
hashes, strip/audit manifests, POM dependency coordinates and all `.module`
referenced source artifacts. It stages the **same 4.8.4 coordinates** under
`android/native/wallet_core/maven`. The maintained AAR is 29,994,963 bytes,
SHA-256 `560cf86e132e4b4ee18afb70daf670e12e8fd34684a03eb38b9e49e39cd0f57d`.
`tracked-packaging-report.json` records all **13 ZIP entries**: exactly four
JNI members differ; four non-native files (`R.txt`, manifest, `classes.jar`,
AAR metadata) and five directory entries keep their published extracted
bytes. The task-owned staging run and tracked run produced byte-identical
reports and AAR hash. `maintained-aar-zip-test.log` has no ZIP errors;
`maintained-aar-elf-audit.json` passes both 64-bit members. The core `.module`
updates only the API/runtime AAR size and hash fields; its source variant and
dependencies are unchanged. Core POM/sources and all four proto module files
(JAR, POM, module, sources) retain official bytes. No app business path or
published cache artifact was edited.

`android/build.gradle.kts` adds one exact-version `exclusiveContent` route
for `com.trustwallet:wallet-core:4.8.4` and
`com.trustwallet:wallet-core-proto:4.8.4`; other versions and repositories
retain their existing resolution path. `android/app/build.gradle.kts` remains
unchanged. An isolated Gradle resolver first selected the maintained AAR and
published proto JAR. The **real app project** subsequently selected exactly
one of each on both `releaseCompileClasspath` and `releaseRuntimeClasspath`:
the AAR path under `android/native/wallet_core/maven` with the hash above,
and proto JAR SHA-256
`95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b`.
`app-selection.log` lines 542–547 and 557 record exact paths, bytes, hashes,
actual 4.36.2 protobuf resolution and Gradle success.

For the real app probe, an APFS task-owned clone of Flutter SDK 3.47.5 used
the same Git commit `6a19cca56475dbfba1478ee68d7bd0c2ef891da1` and the
same byte hashes for all 47 Flutter Gradle plugin source/config files
(canonical graph SHA-256
`99ffd972cdce05f207210cb64ec1c6312a8c3f05aff3e77339170ea176d8d554`);
there are no absolute symlinks into the shared SDK. The worktree's ignored
`android/local.properties` was redirected to the clone only during each
probe and restored to its original SHA-256 in `finally`; task-owned Gradle
home/cache was used. The earlier relative init-script failure, included-build
`:app` lookup failure, and unfiltered all-project artifact variant ambiguity
are preserved in their original logs. The successful probe uses the existing
coordinate-filtered `artifactView` pattern.

`app-compile-kotlin-dry-run.log` shows actual `:app:compileReleaseKotlin`
would pull **935** skipped task lines, including
`:app:compileFlutterBuildRelease`; no actual full app/AOT compile was run for
this native-only stage. The offline JNI fixture will compile and invoke the
published Java/proto API and JNI directly in the next stage.

## Tests, source notices and boundary

`packaging-tests-red.log` shows the missing package recipe before
implementation. Normal and `python3 -O` focused suites each pass **3/3** in
`packaging-tests-green.log` and `packaging-tests-optimized.log`; controls
reject an extra JNI member and altered published file/metadata bytes, and
verify source-variant/dependency retention. `py_compile` and tracked diff
whitespace validation passed. `android/native/wallet_core/licenses/` contains
six exact upstream license/notice files; `license-copy-manifest.json` binds
their paths, bytes and SHA-256. The task-owned Cargo license inventory records
the broader Rust package graph, including 37 external root-Rust source trees
without a root license file. This is a source inventory, not final legal
clearance.

No full app APK/AAB, ZIP-aligned installed native load, API-26 device check,
synthetic crypto-vector comparison, real wallet/account/payment call or
production signing was performed. The four-ABI static and exact Gradle
selection evidence is ready for independent packaging review before the
separate synthetic JNI fixture stage.

Packaging commit `eadc6d0ff16832fb08ac83bce6d5dc5950bad2c5`
(`build: package pinned Wallet Core Android AAR`) has an English/ASCII subject
and the normal hook bumped only `pubspec.yaml` from `2.4.8+2026072948` to
`2.4.8+2026072949`. Staged `git diff --cached --check` passed before commit;
tracked status is clean afterward. The commit has not been pushed and awaits
independent review. The task-owned build/source/Gradle logs and Flutter clone
have been retained, not cleaned up.

## Packaging recipe review fix 1

Independent review accepted the current AAR and real-app Gradle selection but
found that the recipe hashed official inputs before reopening their paths to
parse or package them. The fix makes `verified_file` return one checked byte
buffer. Official AAR ZIP parsing uses `ZipFile(BytesIO(buffer))`; POM/module and
strip/audit JSON parsing, four candidate JNI replacements, retained artifact
writes and metadata checks consume the corresponding checked buffers. The
output AAR is still audited against the checked official ZIP members. The
original native links, strip outputs and tracked Maven bytes were not changed.

The new deterministic regression swaps every synthetic official artifact,
strip manifest/audit and JNI file immediately after `verified_file` returns;
the complete `build_repo` output still contains only the checked bytes. A
smaller ZIP/JNI swap control also covers `repackage_aar` directly. Initial
`packaging-fix1-red.log` failed 1 assertion and 3 errors against the previous
path-returning recipe; `packaging-fix1-green.log` and
`packaging-fix1-optimized.log` each pass 5/5 with the fix, and `py_compile`
passes. The corrected recipe regenerated a task-owned Maven repository with
exit 0 in `packaging-fix1-rebuild.json`; `packaging-fix1-equality.json` shows
all 8 files byte-identical to the tracked maintained repository, including
the AAR SHA-256 `560cf86e132e4b4ee18afb70daf670e12e8fd34684a03eb38b9e49e39cd0f57d`.
No four-ABI relink, real-app Gradle rerun, APK build or device run was needed
for this guard correction. The original app selection evidence remains bound
to exactly these tracked repository bytes. Fix commit
`89e214c2a6f30c0a5ee7c7c26682eeb110207df0` has an English subject; the
normal hook bumped `pubspec.yaml` from `2.4.8+2026072949` to
`2.4.8+2026072950`. The committed diff passes whitespace validation and the
tracked worktree is clean. This fix awaits independent review and has not been
pushed by this agent.
