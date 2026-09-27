# Task16F.3 Vodo recipe fix round 1 review

Range: `fd0dd4f6d60659a0d98bdce941c611b990edd50d..4a26a4a1e691e69696f1b593e6d9f72927e40a9a`.

**Spec verdict: PASS for this scoped fix. Quality verdict: PASS. All three prior P2 findings ADDRESSED; no new blocking findings.**

| Prior finding | Status | Reviewed fix and evidence |
|---|---|---|
| Shared offline policy changes Apple/non-Android builds | ADDRESSED | Removed crate-global `rust/cargokit.yaml`; `builder.dart:185` injects `--locked --offline` only when `target.android != null`. Existing non-Android extra flags remain unchanged. New tests call actual `RustBuilder.build` command construction for Android debug/profile/release and a non-Android Linux target. Combined retained Dart GREEN is 10/10; earlier command RED captures missing Android arguments. Apple source builds are not claimed to have been executed. |
| Actual Rust wrapper inputs not pinned | ADDRESSED | `scripts/build_vodo_android.sh:42` now checks the complete seven-file crate inventory and each digest before metadata or Gradle. Changed/missing/extra inputs and symlinks reject explicitly; this examines working files, not only Git HEAD. Independent static checks found all seven hashes and every recipe `check_sha` pin equal the committed inputs. Temporary-source tests show modified wrapper/missing/extra inputs fail, while unchanged input reaches fake Cargo and Gradle. |
| Cargo compiler/wrapper aliases survive cleanup | ADDRESSED | `scripts/build_vodo_android.sh:97` clears all three `CARGO_BUILD_RUSTC*` selectors before metadata and Gradle. The focused test checks environments captured by both children and verifies an unrelated sentinel survives. Retained behavioral RED shows the alias present in the child; final Python GREEN is 4/4. |

## Evidence and regression scope

- Read `task-16f-vodo-guard-red2.log`, `task-16f-vodo-fix-guard-final.log`, `task-16f-vodo-fix-dart-green.log` and actual `task-16f-vodo-fix-preflight-green.log`. The latter reports all seven Rust inputs, selected real NDK clang hash, Rust/Cargo 1.97.1 and successful locked offline metadata. The report properly separates the earlier stale-builder-hash failure from the subsequent behavioral RED.
- Python source-inventory gates use explicit `SystemExit`, independent of optimized assertions. Tests use temporary copies and a disclosed synthetic compiler-hash stub; they do not misrepresent that stub as real NDK verification. Actual preflight supplies the real-tool evidence.
- Independently rehashed committed recipe to `ecbeb5c177bba8dae5c385d24605de891889f6dacebbf969c5f8c7b540fa6dc0` and compressed upstream patch to `6d8c01d123915e868034ab3f87f531dda37f2fb832574f8decb08cbbf15a7d03`. The patch contains the stated four remaining upstream source edits and no removed global YAML. Provenance wording and pins follow the fix.
- No Rust runtime/binding or selected binary change is introduced. ABI/page-flag behavior remains within the previously reviewed scope. The historical release AAR/static 2/2 evidence predates these guard fixes; the updated report states that clearly and does not claim a new full native rebuild or release-member runtime verification.

This closes only the three recipe findings and their introduced-change review. Crypto/FRB runtime, release-member fixture binding and final whole-app APK/AAB acceptance remain subsequent gates. No tests, native builds or device runs were repeated during this read-only review.
