# Task 16F Reown WCPay source review fix 1

Prepared 2026-09-27/28 after the independent source review in `task-16f-reown-source-review.md`. Tracked fix commit: `4d953741b` (`fix: pin WCPay binding inputs and OpenSSL helper`). The normal pre-commit hook bumped `pubspec.yaml` from `2.4.8+2026072931` to `2.4.8+2026072932`; no dependency or business flow changed. No push, AAR selection, native relink, app build or device operation was performed in this fix.

## Review findings resolved

1. `--baseline-bindings` now checks both official release file bytes **before** creating the output directory or starting Cargo. Pinned SHA256: `generated-yttrium.kt` `92458f5d5dcc13410f27b733b6c8771164a7e392118ca83313928642b64766ad`; `generated-uniffi_yttrium.kt` `5bf20f4f39126830d1ecc00f43498c079ae06f1fc8dcd5db4141d0c97f168f84`. The hashes are also included in preflight and build manifests. `verify_baseline_bindings` supplies the checked file paths to the final comparison.
2. Child build environment now clears every inherited `OPENSSL_*` variable, including `OPENSSL_CONFIG_DIR`, `OPENSSL_RUST_USE_NASM`, `OPENSSL_SRC_PERL`, `OPENSSL_DIR` and `OPENSSL_NO_VENDOR`. The pinned vendored `openssl-src` reads `OPENSSL_SRC_PERL` or fallback `PERL`; the recipe overrides `PERL` with `/usr/bin/perl` and verifies that binary SHA256 `53bce3db7e095b596fa42626b55edc63e3388d7afecf45a0b1ecc5211721c812` in tool preflight. This closes the identified inherited-helper path without changing target flags, source or features.

## Verification

- `python3 -m unittest discover -s test/scripts -p test_reown_wcpay_build.py -v`: 6 tests passed. The added test mutates each baseline binding in turn and verifies SHA rejection; the environment test injects each named OpenSSL control plus a hostile `PERL` and verifies scrub/pin behavior.
- `python3 -m py_compile scripts/build_reown_wcpay_android.py` and staged `git diff --check` passed.
- End-to-end no-build preflight against archived official binding files exited 0. Separate runs with either file altered each exited 1 with `byte mismatch`; none created the output directory. Exact commands, stdout, stderr and results are retained in `task-16f-reown-build/fix1-evidence-run2/receipt.json` and adjacent files. That positive preflight includes the new Perl and official binding hashes.
- The first ad hoc evidence harness attempted a wrong test alias (`generated-uniffi.kt`) and failed with `FileNotFoundError` before completing its three cases; its partial `fix1-evidence` directory is retained. The corrected `fix1-evidence-run2` completed all three cases. This was a harness setup error, not a native or recipe preflight failure.

The four candidate `.so` hashes and corrected generated Kotlin evidence in `task-16f-reown-source-report.md` remain unchanged. The additional guards were verified after candidate1 was built, so this report makes no claim of a fresh native relink with the final script. AAR selection, actual Gradle choice, JNA runtime, 16 KB device behavior and final package audits remain for the next reviewed stage.
