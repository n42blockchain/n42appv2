# flutter_vodozemac 0.8.1 Android compatibility source

This directory retains the published `flutter_vodozemac` 0.8.1 runtime and build sources, including its Rust crate, cargokit, platform integrations, prebuilt Apple framework and AGPL-3.0 license. The published pub.dev archive SHA-256 is `209e7661da113a5f889ae55d574c48f245145def64df9a9fcac04d147e6f9d4e` ([version page](https://pub.dev/packages/flutter_vodozemac/versions/0.8.1)). README, changelog and package development files are omitted.

The unmodified cargokit script failed during the first AGP 9.4.1/API 37 debug build at `plugin.gradle:173`: it parsed the legacy compile SDK string `android-37.0` as an integer. The first source change reads AGP's integer `compileSdk` property directly. The Android Cargokit environment now supplies both `max-page-size=16384` and `common-page-size=16384` to the final Rust linker for arm64 and x86_64, while preserving the existing hash style, libgcc workaround and 32-bit branch. The Dart and Rust runtime code, Flutter Rust Bridge bindings and Apple artifacts are unchanged. The focused `test/android_page_flags_test.dart` checks the emitted encoded flags.

`UPSTREAM_FILES_SHA256.json` records every retained pristine upstream file and is unchanged. `N42_PATCH.diff.gz` is the two-file upstream-relative source patch; its SHA-256 is `4b97313cc664b64d03e0ecfcd73e50bec11132c3bbc90f200f7893da1b166caa`. The earlier one-file patch SHA-256 was `e32321063679f1caf938517938665af4842a1a304f8533422ac7583f34562dda`.

Remove this override when an official package release supports AGP 9.4/API 37 and the required Android final-link alignment with the same behavior.
