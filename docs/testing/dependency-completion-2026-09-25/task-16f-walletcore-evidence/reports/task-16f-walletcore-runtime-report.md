# Wallet Core 4.8.4 synthetic JNI fixture source checkpoint

Prepared 2026-09-28. This is the **source/build stage only**. No emulator
install, JNI execution, business signing result or production app build is
claimed. The exact two APKs and runner are ready for independent source review
before any dedicated-device run.

## Fixture calls and isolation

`tools/android_native_smoke/walletcore_fixture/` is a standalone Java Android
application, not the Flutter app. Its release variant uses a task-owned
synthetic RSA keystore (`CN=Wallet Core Synthetic Fixture`, SHA-256
`01083a606e5c1b34569db06e43607040efe8acbfbc0336f74f85593db4752132`),
not production signing. Both APKs use one source tree and the same exact
published `wallet-core-proto:4.8.4` JAR SHA-256
`95659a930e640196ace64743377d013f9cc71cdbfe471c1279fa9f7d65812a4b`
plus the **actual app-selected** `protobuf-javalite:4.36.2` JAR SHA-256
`8f4f93d08cb37130ecb0bc69d376d7d27c36ff04ddb1bb27430b06caa9fa062e`.
Only the published vs maintained Wallet Core AAR changes between phases;
their `classes.jar` member SHA-256 is the same
`5e86c61d0121af19c1bcf99043b21a6e4c8fa479bb6d1c9a20967eadb8bb6d4b`.
The final APK manifests have `extractNativeLibs=false`; `aapt dump
permissions` returns only each package name and **no INTERNET permission**.

The app invokes the exact tagged HDWallet mnemonic, entropy, seed and Bitcoin
address assertions; Ethereum legacy and ERC20 EIP-1559 `AnySigner.sign`
goldens; and the tagged valid `BitcoinCompiler.CompileWithSignaturesV2`
one-input P2PKH preimage/signature/encoded/txid goldens. It then reproduces
the app's BitcoinV2 P2WSH `TransactionCompiler` call shape with test-only
inputs, recording each stage and actual error/output without requiring a
successful transaction. The latter is separate from the tagged valid vector:
the app passes preimage-output bytes to `compileWithSignatures` while the tag's
valid compiler example passes the serialized original signing input. The
source TODO on P2WSH inputs is not treated as a blanket P2WSH failure; only
actual device results can characterize the app route. Exact vectors and
source callsites are in `task-16f-walletcore-runtime-brief.md`. No business,
crypto, IAP or subscription code was edited.

The Activity emits tagged JSON `BEGIN` with installed APK hash/classloader
path and fresh runner token **before** library loading, `LOADED` with `/proc`
executable maps after loading, five bounded `CASE` records, and `END`.
Records bind phase, token and PID; each is bounded below logcat's truncation
limit. A baseline load failure can therefore keep installed APK/PID evidence
without pretending that tagged calls ran. The candidate must load and pass
the four tagged golden cases, while the app-shaped case is reported as its
actual parsed result or stage-tagged failure. Full old/new result parity is
required if the baseline loads and passes; a baseline failure is recorded as
unavailable parity, never inferred from static ELF alignment alone.

## Build epoch and static APK evidence

`scripts/build_walletcore_fixture.py` verifies exact AAR, proto and Javalite
hashes, both AAR `classes.jar` members and ARM64 JNI members before staging
checked bytes to task-owned input files. It builds offline using AGP 9.4.1,
Gradle 9.8.0, JDK 17, two workers, isolated output/project cache and the
task-owned Gradle home. AAPT2 9.4.1's original JAR is read-only from the
existing global cache, pinned to SHA-256
`eb93ce9d0fa121333f12395b3ab30822c5cdb9155737f20d342fe71809757059`;
the exact executable SHA-256
`a6d0102e909213b2bbc50f5bf6e082a9727c029c4a48fca02fbaebbf87e65155`
is copied under `task-16f-walletcore-build/fixture-tools/aapt2` and supplied
through the AGP override. No global cache was written. The recipe checks
staged input and source hashes again after the build. The build epoch manifest
is `tools/android_native_smoke/walletcore_fixture/fixture-build-epoch.json`,
SHA-256 `7972005cc581a681c2921b101eacb8e49157eaf424c9f05479abef1b3e471ac9`.
It truthfully records that the fixture source was uncommitted when compiled;
the eventual reviewed commit must contain exact compiled source bytes.

| Current APK | APK SHA-256 | ARM64 member SHA-256 | ZIP data offset | ELF64 LOAD/RELRO |
| --- | --- | --- | ---: | --- |
| Published baseline, `task-16f-walletcore-fixture-build/baseline5/walletcore-baseline.apk` | `ac812aa92dcbd548cf255fe7fa16d1bb6a87d3cc2b7148877fedc2eab9ddcd19` | `d01ca3db4312b3b64e3f8feddf581c3be8d25d729456873bb9042ed8c2d447e7` | 2,048,000, divisible by 16,384 | fails static alignment |
| Maintained candidate, `task-16f-walletcore-fixture-build/candidate3/walletcore-candidate.apk` | `86f81f61703dbdb31d52ce0c643fb03cc0797dc09a095e20cf72066724259f90` | `f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d` | 2,048,000, divisible by 16,384 | passes static alignment |

The ARM64 bytes in these APKs exactly equal their respective pinned AAR
members; AGP did not change those members in this fixture. Local ZIP headers
show stored members with executable `PT_LOAD` mappings at offset 2,048,000;
candidate executable mapping length is 17,317,888 bytes, baseline 17,301,504.
Both `:app:assembleRelease` fixture builds exited 0. Per-APK `zipalign -c
-P 16 -v 4`, `apksigner verify --verbose`, `aapt dump badging`, and `aapt dump
permissions` each exited 0; logs are beside the APKs. These are synthetic
release-variant APKs signed with the fixture key, not release app artifacts.

Historical build failures are preserved: `baseline/gradle.log` stopped at
uncached offline AGP AAPT2; `baseline2/gradle.log` reached Java compilation
but stopped at uncached offline `lint-gradle:32.4.1`. The exact task-owned
AAPT2 override resolved the first, and fixture-only
`lint.checkReleaseBuilds=false` avoided the unrelated missing lint tool. The
successful intermediate `baseline3/candidate1` and `baseline4/candidate2`
APKs and their distinct source hashes remain as build-history evidence.
Only `baseline5/candidate3` are accepted by the pinned runtime verifier.

## Runner, focused checks and boundary

`run_walletcore_fixture.py` is fixed to `emulator-5560`; it validates pinned
APK, build epoch, exact reviewed Git source and device-tool hashes **before**
any `adb` mutation. It establishes PAGE_SIZE=16384, fatal linker compatibility,
package compatibility disabled, airplane mode on, Wi-Fi off and empty IP
route; checks each pre/post and final snapshot; checks no packaged permission;
installs each APK, clears it, pulls back the installed APK for a second host
hash, then launches separate fresh PID/token phases. The verifier binds local,
pulled and in-process installed APK hash, package manager/classloader path,
ARM64 member hash, ZIP data offset, executable maps and raw logcat framing.
It rejects stale/foreign/malformed/truncated/duplicate records and missing
cases. Candidate golden calls and, when available, old/new complete result
parity are checked from the raw records. Receipts are kept on any failure.

Focused `test_build_walletcore_fixture.py` and `test_walletcore_fixture.py`
normal and `python3 -O` suites each pass **11/11** in
`task-16f-walletcore-build/fixture-source-tests-{green,optimized}.log`.
Controls include a wrong exact APK rejected before any `adb` call, changed
source/tool pin, altered AAR class/member, wrong strict/offline state, foreign
token/PID, truncated/missing records, missing executable maps, changed
installed APK hash, injected INTERNET permission, failed candidate golden,
parity mismatch and baseline native-load failure preservation. `py_compile`
passed for recipe/runner/verifier/tests. No device command was run for this
source checkpoint. Full Flutter app APK/AAB, API-26 device behavior, real
account/payment/network/broadcast and final license clearance remain outside
this fixture result.

Hold for independent source review before running on the dedicated emulator.

The source stage was split into two English commits with normal hooks:
`19c859c90960aff4846d5d7b8d9b6dbbe93cdf6d` builds/pins the exact
fixture APK epoch and bumps `pubspec.yaml` from `2.4.8+2026072950` to
`2.4.8+2026072951`; `0af4663dbdeb03527b5ad3afec2f143ef8386f63` adds
the strict runner/verifier and bumps it to `2.4.8+2026072952`. The later
Git-source-identity regression was deliberately red before the second commit
(`fixture-git-epoch-red.log`: the then-current commit lacked the runner) and
passed after it. The definitive normal and `python3 -O` suites are
`fixture-source-tests-final.log` and `fixture-source-tests-final-optimized.log`,
each **12/12 PASS**; `py_compile`, committed whitespace check and tracked-clean
status also passed. Neither commit was pushed by this agent. Device execution
still awaits independent source review.

## Source review fix 1: JSON receipt mapping pairs

Independent review found a real replay defect before device execution:
`member_and_executable_offsets` returned Python tuples. The runner's
in-memory verification compared those tuples successfully, while a receipt
written as JSON and loaded later held lists and failed the same comparison.
The exact RED regression serialized/reloaded a candidate phase receipt and
raised `candidate: recorded native ZIP mapping differs` in
`fixture-json-roundtrip-red.log`. The runner now emits LOAD offset/length pairs
as JSON lists, and the verifier compares against the same canonical list
shape. No fixture Java, native AAR, APK, epoch or device state changed. The
targeted regression passed in `fixture-json-roundtrip-targeted-green.log`.

Fix commit `9e755995b78c08275e390a87914a04ce69d8fb34`
(`fix: preserve Wallet Core map pairs through JSON`) has an English subject;
the normal hook bumped `pubspec.yaml` to `2.4.8+2026072953`. Definitive
`fixture-json-roundtrip-final.log` and
`fixture-json-roundtrip-final-optimized.log` each pass **13/13**; `py_compile`,
committed whitespace check and tracked-clean status pass. A pre-commit whole
suite run correctly failed only the Git-reviewed-source epoch test because
the changed runner was not yet committed; the post-commit suites pass. This
fix has not been pushed by this agent and runtime remains held for review.

## Actual dedicated-device run 1, 2026-09-28

After independent review and exact remote verification of all three fixture
source commits, the reviewed runner executed only the two pinned APKs on
`emulator-5560`. The command exited 0; its stdout is
`task-16f-walletcore-build/fixture-runtime-run1.log`. The complete JSON
receipt and verifier result are in `task-16f-walletcore-runtime-run1/` as
`walletcore-runtime-receipt.json` and `walletcore-runtime-verification.json`.
The receipt binds Git HEAD `9e755995b78c08275e390a87914a04ce69d8fb34`,
the pinned build epoch SHA-256
`7972005cc581a681c2921b101eacb8e49157eaf424c9f05479abef1b3e471ac9`,
current fixture source/tool hashes and both exact APK SHA-256 values recorded
above. It includes actual install, package-manager path, pulled installed APK,
logcat, process and map evidence rather than an inferred static result.

| Phase | Fresh PID | Pulled installed APK SHA-256 | Loaded ARM64 member SHA-256 | Device status |
| --- | ---: | --- | --- | --- |
| Published baseline | 19272 | `ac812aa92dcbd548cf255fe7fa16d1bb6a87d3cc2b7148877fedc2eab9ddcd19` | `d01ca3db4312b3b64e3f8feddf581c3be8d25d729456873bb9042ed8c2d447e7` | PASS |
| Maintained candidate | 19382 | `86f81f61703dbdb31d52ce0c643fb03cc0797dc09a095e20cf72066724259f90` | `f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d` | PASS |

Both phases used distinct fresh tokens, exact installed APK/classloader paths,
and direct executable `/proc/self/maps` mappings of each installed `base.apk`
at file offset `001f4000` (2,048,000). Their pinned ZIP ARM64 member data
offset is also 2,048,000, divisible by 16,384. PAGE_SIZE was 16,384,
`bionic.linker.16kb.app_compat.enabled` was `fatal`, package compatibility was
disabled, airplane mode was `1`, Wi-Fi was `0`, and `ip route` was empty in the
initial, each pre/post and final snapshots. Both synthetic manifests had no
INTERNET permission. The official baseline JNI fails the static 16 KB
`PT_LOAD`/`GNU_RELRO` test, **but it actually loaded and completed this
specific strict emulator run**; static failure alone did not predict a runtime
crash here. The maintained JNI passes that static test and also loaded and
completed.

The four tagged goldens passed in each phase: HDWallet entropy/seed/key and
Bitcoin address, Ethereum legacy, Ethereum EIP-1559 and the valid tagged
Bitcoin compiler vector. Verifier result is `candidate_passed: true`,
`baseline_status: PASS`, `parity: all five cases equal`. The fifth, app-shaped
BitcoinV2 P2WSH observation is **not a successful transaction**: both phases
returned `preimageError: OK`, zero `hashPublicKeys`, then
`compilerError: Error_invalid_params` with message
`empty signatures or publickeys`; encoded output was empty. This captures an
existing synthetic route behavior for separate business analysis. Equal
old/new output proves maintenance parity for these inputs, not correctness of
the app's P2WSH flow or any live payment/transaction.

The standalone verifier reread the written JSON receipt and exact APKs in
normal and `python3 -O` modes; both exited 0 (`verify-normal.log`,
`verify-optimized.log`). Five copied receipt tamper controls each exited 1 in
both modes (`tamper/*.log`): changed pulled APK SHA, changed strict linker
mode, changed native map offset, changed event PID and changed golden result.
The last three were rejected at the raw-logcat-to-parsed-record equality
boundary; the first two were rejected at their specific installed-byte and
strict-state checks. No APK/native rebuild, other emulator, network call,
production app install or production signing key was used.

This result covers ARM64 JNI execution on one dedicated 16 KB emulator and
the static four-ABI build/package evidence. It does not prove API-26 runtime,
full Flutter app APK/AAB delivery, every wallet route or final source/license
clearance. The fixture was signed only with its task-owned synthetic key.
