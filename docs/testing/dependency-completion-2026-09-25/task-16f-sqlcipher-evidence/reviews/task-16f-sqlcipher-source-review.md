# Task16F.5 SQLCipher Stage1 independent source review

## Verdict

- **Specification: NOT YET PASS** — one remaining environment-control defect in the reusable build recipe.
- **Code quality: CHANGES REQUESTED** — one P2 below. The candidate4 static evidence and JNI helper change otherwise satisfy this source-stage scope.
- Reviewed `ed91d345cea30cd9112b7ca0517b1de11c8ad77b..cf39240f9f6429e8bba90198146f429f0e11ad15`. No builds, tests, device actions or native tool execution were repeated. Read-only source/log/hash/ELF parsing only.

## P2 — Remove inherited MAKEFILES before both generation and native make

**Location:** `scripts/build_sqlcipher_android.py:147–149` (`child_environment`), used at `:265–266` and `:279–289`; `OVERRIDE_KEYS` at `:62–70` lacks MAKEFILES.

The recipe removes SQLCIPHER_CFLAGS and MAKEFLAGS but forwards MAKEFILES unchanged. GNU make loads the named additional makefiles before its selected makefile. A caller environment such as `MAKEFILES=/path/to/local.mk` can therefore reintroduce `override SQLCIPHER_CFLAGS := ...`, override generator rules/compiler variables, or add other build rules after the Python sanitation but outside the verified source trees. Both `/usr/bin/make` generation commands and ndk-build inherit this value; the pinned NDK launcher does not unset it. Consequently clean source, pinned compiler bytes and explicit ABI/API arguments do not enforce the intended crypto/features defaults for this future invocation. This is the documented [GNU make MAKEFILES behavior](https://www.gnu.org/s/make/manual/html_node/MAKEFILES-Variable.html), not a requirement to hash every SDK file.

**Minimal correction:** remove MAKEFILES alongside existing make environment selectors before either child path. Extend the existing environment test with an inherited MAKEFILES value; a small no-native make control can verify an extra makefile is consumed before the fix and not consumed afterward. No full native rebuild is required for this environment-only correction. There is no evidence candidate4 was built with this override, and its retained outputs should not be relabeled invalid.

## Previously raised issues addressed

- The three exact wrapper/core/LibTomCrypt revisions are checked independently; the stale wrapper core gitlink is explicitly superseded by official4.19 core. Source/notice hashes and the full clean Git trees are checked. `--ignored` now rejects stale ignored bootstrap/generated files before configure, including jimsh0.
- NDK API/ABI selection is now explicit command-line make arguments, avoiding the NDK's clearing of APP_* environment values. Actual four candidate4 logs identify each intended ABI and API23.
- Selected NDK tools and source.properties now have enforced hashes. Host generation selects the actual Xcode compiler, CC_FOR_BUILD, Tcl and SDK; actual logs use that compiler rather than only recording the /usr/bin shim. The final expanded selected-tool checks were added after candidate4 and separately recorded; the report accurately discloses this instead of claiming an unchanged full rebuild. This is a bounded selected-tool/source recipe, not complete SDK byte hermeticity.
- Each configure/make child exit propagates; stale JNI amalgamation is rejected; generated sqlite3.c/h are checked and hashed. SQLCIPHER_CFLAGS is removed, preserving the wrapper's LibTomCrypt/SQLite defaults on the recorded build.

## JNI helper and source patch

Read candidate4/source.patch and the exact selected NDK string.h: GNU Bionic strerror_r returns char* only when __USE_GNU and API>=23; otherwise it returns POSIX int. The maintained helper uses that condition, returns the pointer on GNU success or the supplied buffer when POSIX status is0, and retains snprintf errno fallback on failure. Actual API21 and API23 syntax-only logs both exit0. No global Bionic-int assumption remains. This does not change JNI registration, Java API or database crypto defaults.

The patch contains only the final common-page-size addition alongside existing max-page-size and this helper correction. GNU_RELRO is measured in each output; the report correctly does not invent an added explicit relro linker token. Source patch hash `adf307a44c063a70bf0860da3e73c68b5109682f1ca8db8e51eb7f0409312585` matches the candidate manifest.

## Candidate4 static evidence checked

Independently hashed candidate manifest `69b7f8103d8bcba6dbd1f705365f500f6228fc72cdb50501e2a678ecc7264b51`, generated C/header, and all four native binaries. Generated C9,755,243B `8640c653…`, header692,778B `8a9d1bff…` match recorded values.

| ABI | Bytes | SHA256 |
|---|---:|---|
| armeabi-v7a | 1087160 | `37500a62790118ab388bbc2fc248ab338363b83fc8132a47809584365fd13a72` |
| arm64-v8a | 2177712 | `9d1bb9723058f51d92e89da58b8b49229babbeebc9f89631b41037dad5289789` |
| x86 | 2236340 | `a3af830956de4f15fe7a088d77b743488d783d9a519d321d29a91dd0a472240d` |
| x86_64 | 2238600 | `ae0edf387d026526c2e2062c3de99eebb6859eaf45690ff3188f6e76e7adb8a2` |

Independently parsed ELF program headers: all three LOAD segments per ABI have alignment>=16384 and congruent file/virtual offsets; each RELRO end modulo16384 is0. This four-ABI arithmetic is distinct from the repository audit's two ELF64 checks.

Independently compared retained dynamic-symbol tables: all four retain identical320-name sqlite3_*/sqlcipher_*/JNI_OnLoad sets. Full sets match for arm64/x86/x86_64. Armv7 differs by exactly one weak libc++ constructor name, confirmed WEAK in both raw tables. Historical21-armv7-member consumer scan reports no undefined use of the removed symbol and no DT_NEEDED on libsqlcipher; this is a bounded static observation, not complete C++/runtime compatibility. SONAME and libdl/liblog/libc/libm dependencies are preserved. Candidate API notes are23; absent original x86 notes are correctly treated as unknown.

Final focused recipe tests9/9 and retained API syntax checks pass. Candidate1/2 native failures, candidate3 preflight typo and intermediate test-fixture failure are accurately separated from candidate4 success. No runtime/FFI/Java database behavior follows from these checks.

## Remaining later slices

AAR selection and non-native preservation, unified host/plugin dependency resolution, Java/FFI synthetic encrypted database compatibility, strict-device identity receipts and package audits remain subsequent agreed gates. No production database/account, app integration, device run or full-app native closure is approved by this source-only review. Durable source/artifact/log preservation remains required at the planned evidence slice.

## Fix round1 — final verdict at 2bf7a0ca7ddea695704567367e86d905506bf438

**Specification: PASS for Stage1. Code quality: PASS. Original P2: ADDRESSED.** This supersedes the initial not-yet-pass verdict above.

Scoped review of `cf39240f9..2bf7a0ca7ddea695704567367e86d905506bf438` finds only the MAKEFILES sanitation entry, corresponding existing-test input, and normal pubspec hook increment. `child_environment()` now removes MAKEFILES before the common generation environment is created; that sanitized dictionary is also copied into each native make environment, without reintroducing the variable. The fix therefore covers both amalgamation generation and ndk-build. No new breakage was identified in this narrow change.

Read retained `recipe-test-red7.log`: the corrected focused test fails specifically because MAKEFILES survives the pre-fix environment. Read `recipe-test-fix1.log`: all9 focused tests pass after the fix. This is a direct environment-boundary control; it does not claim to execute an injected makefile. The earlier misspelled test selector is accurately identified as a harness error in the updated report. No checks were rerun by this review.

Candidate4 predates this environment-only guard and the expanded tool-byte guard; the report preserves that provenance. The accepted candidate hashes, native source patch, static ABI results and later runtime/selection gates remain as recorded above. No unchanged native rebuild is needed to close this finding.
