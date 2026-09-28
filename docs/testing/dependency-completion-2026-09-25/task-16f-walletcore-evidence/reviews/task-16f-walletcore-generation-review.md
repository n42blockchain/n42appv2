# Wallet Core generation recipe independent review

**Range:** `9b8bf717cb751fcd8333950c51c2e40a2d91086c..34dcdfb0cb9e787ad6567cc819ee83949f3e7652`  
**Verdict:** **CHANGES REQUIRED** for the bounded generation recipe. The running first generation is evidence gathering, not a completed candidate or a reason to alter that process.

## Finding

1. **Generation inherits unpinned, unrecorded tool inputs** — `scripts/walletcore_android_generate.py:72-77,132-141`. `generator_environment()` copies every parent variable except four prefixes and eleven names, then records only eleven selected values. The tagged `tools/generate-files` calls Ruby `codegen/bin/coins` and `codegen/bin/codegen`, Perl comment conversion, and the Rust/Cargo native build. Inherited `RUBYOPT`/`RUBYLIB` can load code or libraries before the tagged Ruby scripts; `PERL5OPT`/`PERL5LIB` can change Perl execution; `CPATH`, `C_INCLUDE_PATH`, `CPLUS_INCLUDE_PATH`, `CFLAGS`, `CXXFLAGS`, and target-specific compiler/archiver variables can change compiled input or tool selection. These variables survive the filter, are neither pinned nor rejected by preflight, and are absent from `generation-environment.json`. Thus identical pinned source, locks and tool hashes can produce different generated/native bytes depending on the invoking shell. Use a narrow explicit environment allowlist with the required system variables and task-owned overrides, or reject build-affecting inherited variables and record all allowed inputs. Add a focused negative control for at least one Ruby/Perl and one compiler-path/flag variable. Keep the active run and its logs intact; this finding concerns accepting the recipe as reproducible for a final candidate.

## Verified within this slice

- The recipe invokes the pinned preflight as a subprocess and requires exit zero plus a receipt for the exact source commit before starting generation (`:115-124`). The prior preflight fix invalidates stale success receipts. The actual `generation-preflight-process.json` records `passed: true`, `built_candidate: false`, the official/source/tool hashes and all four ABI names.
- The wrapper restricts Cargo cwd to the tagged `rust` and `codegen-v2` workspaces, checks **both** original lock hashes before each call, and inserts `--locked` before `--` program arguments (`:40-59`). The tagged Android route uses one four-target Rust build then `codegen-v2` Cargo run. The first recorded Cargo call has the pinned task-owned Cargo binary, `--locked`, and all four Android targets. It does not yet prove the later `codegen-v2` call completed.
- The child `PATH`, `PREFIX`, Cargo/Rustup homes, Rust binaries, jobs=2, NDK 28.2, SDK, JDK 17 and Boost path select task-owned or explicitly named tools (`:78-103`). Tagged `tools/rust-bindgen` uses `find_android_ndk` and API 28 wrappers from that NDK; no source algorithm, proto or API change is in the diff. Successful generator status and four Rust archive hashes are required before the script reports success (`:137-153`).
- The exact review diff matches the commit range, covers only the generator, its tests and a hook-only `pubspec.yaml` build bump; `git diff --check` is clean. The preserved focused logs report 2/2 tests in normal and `-O` Python, covering `--locked` placement and failed-preflight exit rejection. I did not rerun tests or touch the active native build.

## Boundary

The first generation was still compiling locked Rust dependencies when this review began. No completed archives, JNI, `.so`, AAR, 16 KB property, cryptographic parity or runtime result is claimed here. NDK 28.2/CMake 3.22.1 are documented maintained candidate inputs; the supplier's exact producer toolchain remains unknown. The report is confined to the generation recipe and its existing evidence.
