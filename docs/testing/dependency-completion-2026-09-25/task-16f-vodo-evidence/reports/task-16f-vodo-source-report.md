# Vodo Task16F.3 source flag slice

- Base: `a361ee277de3ced1e74298194a3adb00389c7332`.
- Commit for review: `76750e323` (`fix: align Vodo Android RELRO pages`); normal hook bumped `pubspec.yaml` from `2.4.8+2026072906` to `2.4.8+2026072907`.
- Scope: Cargokit Android encoded linker flags, focused test, vendored upstream-relative patch/provenance. Runtime Rust, Dart bindings, Apple frameworks, 32-bit branch, and pristine upstream hash manifest remain unchanged.
- RED: from `packages/flutter_vodozemac/cargokit/build_tool`, `/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/dart test test/android_page_flags_test.dart`; exit 1, both 64-bit tests fail because generated flags omit `common-page-size`, 32-bit test passes. Raw `task-16f-vodo-flags-red.log` SHA-256 `e8900a6bdb813152fe94a2a0c8bbe671ceeae4d11c3f66773c1cf0a48ef7679c`.
- GREEN: same command after patch; exit 0, 3/3 tests pass. Raw `task-16f-vodo-flags-green.log` SHA-256 `09941905e8925f87e0a29bafa9ac74a1ddef87f6488330a625605c3f7d97513e`.
- `dart analyze lib/src/android_environment.dart test/android_page_flags_test.dart` exit 0 with one pre-existing info: the vendored file's initial library doc comment lacks a library directive. No new error/warning.
- `git diff --cached --check` passed before commit; `gzip -dc N42_PATCH.diff.gz | patch --dry-run --reverse -p1 -d .` passed for both modified vendored source files. New patch SHA-256 `4b97313cc664b64d03e0ecfcd73e50bec11132c3bbc90f200f7893da1b166caa`; pristine Rust `Cargo.lock` SHA-256 `6ebe0a5c46e39aa243ba06754bfbaef22c56ba110e7868c44b3abfde2f875d61`.

This is **source flag construction only**. Native binaries, actual linker flags, ELF alignment, Android crypto behavior, and final APK/AAB packaging remain pending.
