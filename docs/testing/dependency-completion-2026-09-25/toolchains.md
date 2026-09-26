# Continuation toolchains — 2026-09-25

Task 11 starts from app `e54045fe9`. User approval in the continuation plan supersedes the original frozen toolchains. Go, Rust, Java and global/default tool installations are unchanged.

## Official sources and selected stable tools

- Flutter official website source: https://github.com/flutter/website/blob/main/sites/docs/lib/src/models/flutter_release_model.dart . Its `baseReleasesUrl` is https://storage.googleapis.com/flutter_infra_release/releases/ . The legacy extra `/flutter/` URL returned HTTP 404; the current official JSON succeeded.
- Flutter JSON: https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json . Stable ARM64 Flutter **3.47.5**, Dart **3.13.4**, release **2026-09-18**, framework **6a19cca56475dbfba1478ee68d7bd0c2ef891da1**. Selection recorded in `flutter-selected.json`.
- Download: https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.47.5-stable.zip . Computed SHA256 matched official **d4dd908b5f8f65515831b6d68ae33307a813f2b68947dded7a1994ee5ea7cead** before extraction.
- Node official index: https://nodejs.org/dist/index.json . Latest supported LTS **24.21.0**, Krypton, released **2026-09-07**. Official schedule https://github.com/nodejs/Release/blob/main/schedule.json shows support through **2028-04-30**, entering maintenance **2026-10-20**. Selection and schedule retained beside this report.
- Node download: https://nodejs.org/dist/v24.21.0/node-v24.21.0-darwin-arm64.tar.gz . Computed SHA256 matched official SHASUMS256.txt **bed7eea5325e1108f32ce5228ddd6a5f0f08a499ee42aa7442aea583702f6057** before extraction.
- Android official repository: https://dl.google.com/android/repository/repository2-3.xml . Selected packages explicitly have `channel-0`: platform **37.0 revision 2**, latest stable minor platform **37.2 revision 1**, build tools **37.0.0**, command line tools **23.0**, platform tools **37.0.1**. Archive names, official SHA1 and independently computed SHA256 are retained in `android-verified.json`. Each archive was downloaded from `https://dl.google.com/android/repository/` and its SHA1 verified. No preview package was selected.

## Invocation paths

```sh
/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter
/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/dart
/Users/jieliu/.codex/toolchains/node-v24.21.0-darwin-arm64/bin/node
/Users/jieliu/.codex/toolchains/node-v24.21.0-darwin-arm64/bin/npm
/Users/jieliu/.codex/toolchains/android-sdk-37/cmdline-tools/23.0/bin/sdkmanager
```

For npm subprocesses prepend the versioned Node `bin` to the command-local PATH. For Android builds select `ANDROID_HOME=/Users/jieliu/.codex/toolchains/android-sdk-37` and set the worktree-local `android/local.properties` SDK path consistently. This new SDK contains the packages listed above; downstream native builds must select/install their required NDK/CMake versions explicitly. Existing Android SDK licenses were copied into the isolated root. No `flutter config`, shell profile, Homebrew or nvm default was changed.

Installation used the official archives under `~/.codex/toolchains/downloads`, and `sdkmanager --sdk_root=/Users/jieliu/.codex/toolchains/android-sdk-37 --channel=0` with the exact package IDs above. API 37 packages are available for Task 14; this task does not change compile/target SDK. Android requirements must be checked against the final graph rather than inferred from the obsolete secure-storage 11.0 SDK requirement.

## Unmodified manifest baseline

`flutter pub get` using the selected absolute SDK path **passed (exit 0)** before any manifest edit. Contrary to the expected solver failure, no constraint override was needed. The resulting lockfile changed exactly seven SDK-pinned transitive versions: intl 0.20.3, matcher 0.12.20, meta 1.19.0, test 1.31.1, test_api 0.7.12, test_core 0.6.18, vector_math 2.4.3. Full output is `toolchain-baseline-pub-get.log`; 94 packages remain outside current constraints for later tasks.

The root SDK floors and all four existing Flutter CI pins now match Flutter 3.47.5 / Dart 3.13.4. The existing HIG workflow Node declaration now pins 24.21.0. Product dependencies/source and Go/Rust declarations were not migrated here. Coverage expansion remains deferred and the 70% gate remains unchanged.

`flutter analyze --no-fatal-infos` **failed (exit 1)**: 70 issues, comprising 23 errors, 12 warnings and 35 informational diagnostics. All 23 errors are in the standalone `packages/n42_jmt_verify` package and start with missing package URI resolution (its standalone pub get has not been bootstrapped in this fresh worktree). The 12 warnings are new `unawaited_return_in_try_block` diagnostics in host live/wallet code. Raw output is `toolchain-baseline-analyze.log`. This is an observed baseline, not an accepted final failure; later tasks must bootstrap local packages and repair remaining diagnostics. No product fix was attempted. The analyzer process was launched against the unmodified manifests; SDK floor declarations were edited while that analysis was running, without changing dependencies or source.

Verification: Flutter --version reported stable 3.47.5/Dart 3.13.4; Node --version reported v24.21.0. Android install returned exit 0; cmdline-tools 23.0 sdkmanager delegates to Android CLI 1.0.16406183. `git diff --check` passed. The seven lock changes above are all increases relative to base e54045fe9; no downgrade occurred in this task.
