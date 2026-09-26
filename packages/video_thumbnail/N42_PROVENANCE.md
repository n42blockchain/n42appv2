# video_thumbnail 0.5.6 Gradle 9 compatibility source

This directory retains the published `video_thumbnail` 0.5.6 Android, iOS and Dart runtime, plugin manifests and MIT license. The published pub.dev archive SHA-256 is `181a0c205b353918954a881f53a3441476b9e301641688a581e0c13f00dc588b` ([version page](https://pub.dev/packages/video_thumbnail/versions/0.5.6)). Examples, screenshots and package tests are omitted.

Only two compatibility changes are made: the Android plugin uses `mavenCentral()` where Gradle 9 removed `jcenter()`, and the Dart SDK upper bound permits the host's Dart 3.13.4. No thumbnail runtime implementation changes. `UPSTREAM_FILES_SHA256.json` records the pristine hash of each retained upstream file. `N42_PATCH.diff.gz` records the exact upstream-relative patch; its SHA-256 is `4ae9e19957a28f5b60d323f8f7c31bb708a78c650a80d9d2e33ea92997866a7d`.

Remove this source override when the official package publishes equivalent Gradle 9 and Dart 3 support.
