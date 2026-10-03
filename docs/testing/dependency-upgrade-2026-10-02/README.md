# Dependency upgrade record — 2026-10-02

This record covers the host application's pinned Chat map update and the first host dependency batch. The audit is a checkpoint, not a claim that every package is upgraded. The host `pubspec.yaml` and lockfile are the source of truth; `packages/n42_chat/` is a cache mirror and was not edited.

## Toolchain and baseline

- Acceptance toolchain: `/opt/homebrew/bin/flutter`, Flutter 3.44.8, Dart 3.12.2. No toolchain upgrade was used.
- Host baseline before the Chat pin: `65d10df95913388cc9b6560af3c45baea0af177a`.
- Chat source repository: `https://github.com/n42blockchain/n42_chat`.
- Chat map commit: `0270be3e7bf6f3f5a209b6b5505cceadf95c066e` (`build: upgrade flutter map dependencies`), based on the host-pinned Chat commit `3cc19c12a7c9bbf2031270acca8e3922730b55a5`. The commit was fetched from the Chat remote and verified before changing the host pin.
- Chat's separate example-lock refresh: `dd4a6bbd867740fdd9b149dc67b0f609d5408636`. It refreshes the package example's stale lockfile; it is separate from the host's Chat pin.

## Upgrade commits

| Repository | Commit | Change |
| --- | --- | --- |
| `n42_chat` | `0270be3e7bf6f3f5a209b6b5505cceadf95c066e` | `flutter_map` 7.0.2 → 8.3.2 and `latlong2` 0.9.1 → 0.10.1; adds a regression test proving a dragged map sends the visible center. |
| `n42_chat` | `dd4a6bbd867740fdd9b149dc67b0f609d5408636` | Refreshes only `example/pubspec.lock` so the example graph satisfies its manifest under `--enforce-lockfile`. |
| Host | `1e51a5e77cfc6a550b65c6eb2a8e166e0168485a` | Pins `n42_chat` to the verified map commit and updates the host lockfile. |
| Host | `b85bb9ca50716d7cfd4e334cd347e16296c921d8` | Upgrades the map's transitive projection/coordinate dependency family. |

The host Chat pin is intentionally the exact map commit `0270be3e…`; it does not silently advance to later Chat feature commits.

## Outdated audit

The full resolver snapshot was captured on 2026-10-02 after the Chat map pin and before the projection-family batch. It is preserved in [`pub-outdated-2026-10-02.json`](pub-outdated-2026-10-02.json); the human-readable command was `flutter pub outdated`. Pub returned exit code 1 because outdated packages were reported, not because dependency resolution failed. The audit used the fixed toolchain above.

The report contains 25 outdated direct dependencies, 8 outdated dev dependencies, and 68 outdated transitive dependencies. Of the direct entries, 24 have a newer `latest` version; none can be upgraded within the current manifest bounds and fixed SDK graph. Three entries have a `resolvable` version newer than current: `firebase_messaging` 16.5.0 → 16.7.0, `firebase_messaging_platform_interface` 4.9.3 → 4.10.0, and transitive `firebase_messaging_web` 4.2.4 → 4.2.5. Three transitive dependencies are locked below their currently allowed version: `mgrs_dart`, `proj4dart`, and `unicode`. `simple_sparse_list` is newly introduced by the upgraded graph.

Direct dependencies with a newer `latest` version in this snapshot:

| Package | Current | Latest | Notes |
| --- | ---: | ---: | --- |
| `cached_network_image` | 3.4.1 | 4.0.4 | Major upgrade; review widget/cache behavior. |
| `chewie` | 1.13.1 | 1.17.2 | Same major; review against video-player graph. |
| `connectivity_plus` | 7.3.1 | 7.3.2 | Patch candidate; fixed SDK resolver did not select it. |
| `cupertino_icons` | 1.0.9 | 2.0.0 | Major icon-font asset change; check rendered icons. |
| `device_info_plus` | 12.4.0 | 13.3.0 | Major native plugin update; requires platform builds. |
| `equatable` | 2.1.0 | 3.0.0 | Major Dart API update. |
| `file_picker` | 11.0.3 | 13.1.0 | Major platform/API update. |
| `firebase_messaging` | 16.5.0 | 16.7.0 | Coordinated Chat enum/API migration required. |
| `firebase_messaging_platform_interface` | 4.9.3 | 4.10.0 | Coordinated with Firebase Messaging and Chat. |
| `flutter_callkit_incoming` | 3.0.0 | 3.1.6 | Protected API pin; Chat source migration required. |
| `flutter_secure_storage` | 10.3.4 | 11.2.0 | Protected migration and native deployment-target constraints. |
| `flutter_vodozemac` | 0.6.0 | 0.8.1 | Coordinate with the Chat/Vodozemac source graph. |
| `go_router` | 17.5.0 | 18.0.2 | Major routing migration. |
| `google_mlkit_face_detection` | 0.14.0 | 0.15.1 | Native plugin graph/build validation required. |
| `google_mlkit_text_recognition` | 0.16.0 | 0.17.1 | Native plugin graph/build validation required. |
| `google_mlkit_translation` | 0.14.0 | 0.15.1 | Native plugin graph/build validation required. |
| `intl` | 0.20.2 | 0.20.3 | Fixed SDK resolver did not select the newer release. |
| `package_info_plus` | 9.0.1 | 10.2.2 | Major native plugin update. |
| `permission_handler` | 12.0.3 | 13.0.2 | Major native permission/API update. |
| `pinput` | 6.0.2 | 7.0.0 | Major widget API update. |
| `pro_image_editor` | 13.5.0 | 14.6.2 | Major editor API migration. |
| `share_plus` | 12.0.2 | 13.3.1 | Major API/platform migration. |
| `webview_flutter_wkwebview` | 3.26.1 | 3.27.0 | Local path override protects a host-specific implementation. |
| `xml` | 6.6.1 | 7.1.0 | Major namespace semantics/API change; RSS call sites need focused tests. |

The report also lists dev dependencies `build_runner` 2.15.1 → 2.16.1, `freezed` 3.2.5 → 4.0.2, `intl_utils` 2.8.14 → 2.8.16, `mockito` 5.6.4 → 5.8.1, `sqflite_common_ffi` 2.3.7+1 → 2.4.3, `sqlcipher_flutter_libs` 0.6.8 → 0.7.0+eol, `sqlite3` 2.9.4 → 3.7.0, and `vodozemac` 0.5.0 → 0.8.0. The latest SQLCipher package was marked end-of-life by Pub; it is not an automatic upgrade candidate.

## Completed map dependency batch

The host lockfile now resolves `flutter_map` 8.3.2, `latlong2` 0.10.1, `proj4dart` 3.0.0, `mgrs_dart` 3.0.0, `unicode` 1.1.9, and `simple_sparse_list` 0.1.4; obsolete `lists` 1.0.1 is removed. The four projection-family changes are lockfile-only at the host level. No wallet application source imports these projection packages; they are used beneath `flutter_map`.

The projection package changelogs were checked. `proj4dart` 3.0.0 and `mgrs_dart` 3.0.0 report dependency/tooling updates; the breaking `Projection('key')` change listed in the `proj4dart` changelog belongs to 2.0.0 and was already in the locked 2.1.0 baseline. `unicode` 1.1.9 follows the 1.0.0 API break from 0.x, but is consumed transitively by `mgrs_dart`; the host has no direct `unicode` imports. The map widget behavior test was rerun against this graph.

## Known compatibility blockers and deferred migrations

- **Firebase Messaging:** the host deliberately constrains `firebase_messaging` to `<16.6.0` and its platform interface to `<4.10.0`. The pinned Chat source lacks the `AuthorizationStatus.deniedPermanently` API expected by newer Messaging releases. Updating only the host constraint would break the coordinated Chat API boundary.
- **CallKit:** `flutter_callkit_incoming` is pinned to 3.0.0 because Chat calls `CallKitParams.textAccept` / `textDecline` and the old event enum. These APIs are absent or renamed in 3.1.x. Upgrade with a compatible Chat source migration and call-notification regression coverage.
- **Secure storage:** the host override stays on 10.3.4 to preserve migration of legacy cipher / `EncryptedSharedPreferences` values. The repository notes that v11 removes this migration path and requires compile SDK 37. Upgrade only with a data-migration plan and platform validation.
- **Vodozemac:** Chat's pinned source graph still uses the older Vodozemac API line. Host and dev pins must move with a compatible Chat source and crypto/session tests.
- **Other latest versions:** the direct and dev packages above have no newer currently resolvable version under the existing constraints/toolchain, or require an explicit major/API/native migration. They remain open upgrade work, not completed items. In particular, the plugin families need Android/iOS build checks; this audit does not certify their platform migrations.
- **XML 7:** the changelog documents namespace behavior/API changes. Existing callers use ordinary RSS DOM parsing in `lib/core/market/crypto_news_service.dart` and `lib/features/news/api/news_api.dart`; this is a plausible narrow next batch after focused namespace/RSS regression tests.

## Verification record

Toolchain for all commands: Flutter 3.44.8 / Dart 3.12.2.

After the host Chat pin:

- `flutter pub get --enforce-lockfile` — passed.
- Chat-related host test batch (Chat initialization, SSO routing, provider fallback, live service, push routing, and tap dedup) — 95 passed.
- Focused analyzer over Chat initialization, SSO, live service, push-routing and tap-dedup sources — no issues found.

After the four-package projection batch:

- `flutter pub get --enforce-lockfile` — passed.
- `flutter test test/presentation/pages/location_picker_entry_test.dart --reporter compact` in a disposable worktree of the authoritative Chat source with the upgraded projection graph — 4 passed. The disposable test worktree was removed afterward; no Chat source checkout was changed by this host batch.
- The six Chat-related host test files listed above — 95 passed.
- `flutter analyze --no-fatal-infos` — exit 0, 35 existing informational lints, no errors.
- `git diff --check` — passed.

The final clean dependency graph at host `b85bb9ca` then passed the full host suite: 5,330 visible tests plus 542 hidden tests, 0 failures, 0 skipped. Final LCOV was 93,561 / 133,302 lines, 70.187244%, above the unchanged 70% gate.

The Chat example Web build was attempted but is blocked before map-specific code by the existing `sqlcipher_flutter_libs` / `sqlite3` `dart:ffi` import reaching `dart2js`. The Chat package has no iOS example runner, so this record does not claim an iOS build result.

## File picker and sharing plugin migration

The authoritative Chat repository migration branch `codex/chat-file-picker-share-plus-13-20261002` is pinned at `60bfd34ccd303f359140a0d871dfda193bdb6ef4`. It migrates Chat file picking to `file_picker` 13 and refreshes the Chat root and example dependency locks for `share_plus` 13. The host integration commit `577e2fade95480ec15dcceb84784ef987e741d88` updates the host call sites, constraints, lockfile, and Chat pin together; `device_info_plus` is 13.3.0 and `package_info_plus` is 10.2.2. A single documented override for `package_info_plus` remains necessary because `reown_core 1.5.1` has an older upper bound; the sole Reown call uses `PackageInfo.fromPlatform().packageName`.

The Chat migration branch passed a fresh full run on 2026-10-02 with Flutter 3.44.8 / Dart 3.12.2: `flutter test --no-pub --coverage --concurrency=2 --machine`, 6,745 visible plus 522 hidden tests, 0 failures, 0 skipped. The machine stream ended with `done success=true`. Fresh Chat LCOV: 35,344 / 135,252 lines (26.131961%). Logs are retained at `/tmp/chat-file-picker-share-full-retry-20261002-machine.jsonl`, `/tmp/chat-file-picker-share-full-retry-20261002.stderr`, and `/tmp/chat-file-picker-share-full-retry-20261002-test-exit`; the coverage file is in the isolated Chat test worktree.

## macOS Release build floor

With explicit authorization, the macOS deployment floor is now 12.0 in the Runner project and Podfile, and CocoaPods post-install sets every pod target configuration to 12.0. `macos/Podfile.lock` records the resulting Podfile checksum. The macOS Release build passed on Flutter 3.44.8 / Dart 3.12.2 using `/opt/homebrew/bin/flutter build macos --release -v`; the resulting `N42 Chat.app` is universal (arm64 and x86_64), reports `LSMinimumSystemVersion=12.0`, and passes `codesign --verify --deep --strict` with an ad-hoc local signature. Xcode reported `BUILD SUCCEEDED`; no build errors occurred. Third-party SQLCipher emitted compiler warnings. The complete verbose log and exit marker are retained locally at `/tmp/host-macos-release-20261002.log` and `/tmp/host-macos-release-20261002.exit`.

## Cached network image update

The host and authoritative Chat repository now use `cached_network_image` 4.0.3, with `cached_network_image_platform_interface` 5.0.2 and `cached_network_image_web` 2.0.2. Chat commit `9cd024ee5d41976de0247c5efe4ead6cada99e6b` updates its root and example lockfiles; host commit `b5bd77efc83e5dced873ca8ad6a5801fdef17d88` updates the host constraint, lockfile, and Chat pin together. The 4.0 package changelog records the internal Material import migration and Flutter 3.44 / Dart 3.12 floor. The inspected public `CachedNetworkImage` constructor and callback signatures are unchanged from 3.4.1.

Version 4.0.4 was not selected: its `material_ui ^1.3.0` bound points at a retracted release, and the next available `material_ui` line requires Dart 3.13 / Flutter 3.47. The host and Chat constraints intentionally cap this family at 4.0.3 under the fixed toolchain. See the upstream [`cached_network_image` changelog](https://pub.dev/packages/cached_network_image/changelog) and [`material_ui` versions](https://pub.dev/packages/material_ui/versions).

On Chat, both root and example `flutter pub get --enforce-lockfile` passed. Seven image-bearing UI test files passed 37 tests with one existing skip; targeted analysis covered 21 files with zero errors and six existing informational lints. On the host, `flutter pub get --enforce-lockfile`, the `ImageNetWork` configuration/custom-builder test plus two NFT widget suites (9 tests), and targeted analysis (6 files, no issues) passed. The wrapper regression asserts the cache manager and error callback wiring but does not invoke the asynchronous disk-removal side effect; that platform-backed error path remains unverified. An incremental macOS Release build passed, the app remained universal, its declared minimum OS is 12.0, and strict code-signature verification passed. A subsequent full host suite on the later Pro Image Editor 14 graph is recorded below; it supersedes this earlier coverage checkpoint.

## Reproduction commands

```sh
/opt/homebrew/bin/flutter --version
/opt/homebrew/bin/flutter pub outdated --json
/opt/homebrew/bin/flutter pub get --enforce-lockfile
/opt/homebrew/bin/flutter test \
  test/core/app/chat_initialization_test.dart \
  test/core/routing/chat_sso_utils_test.dart \
  test/core/providers/use_new_chat_provider_test.dart \
  test/features/live/live_chat_service_test.dart \
  test/features/utils/chat_push_routing_test.dart \
  test/features/utils/chat_tap_dedup_test.dart --reporter compact
/opt/homebrew/bin/flutter analyze --no-fatal-infos
git diff --check
```

The full host coverage gate remains 70%; no threshold was lowered for this dependency work.

## Pro image editor 14 migration

The authoritative Chat source branch `codex/chat-pro-image-editor-14-20261003` is pinned at `c9e8dc3e9d7d7ac165c5d43bae3cebdadd8b6149`. It upgrades `pro_image_editor` 13.5.0 → 14.6.2, adds `material_ui` 1.2.0, migrates the editor theme arguments in `MediaEditorPage` to the package's new standalone Material types, and registers the standalone localization delegates in the Chat example. Host commit `bbdf87c300e1b78bca53388c2729d764c4942ff5` updates the editor/material_ui graph and Chat pin, and registers those delegates in both host `MaterialApp` roots. The host build hook advanced the version from `2.4.8+2026072978` to `2.4.8+2026072979`.

The package metadata for 14.6.2 requires Dart >=3.12.0 and Flutter >=3.44.0, so it resolves under the fixed Flutter 3.44.8 / Dart 3.12.2 acceptance toolchain. Chat root/example and host `flutter pub get --enforce-lockfile` passed. Chat social-image preparation and image-message behavior tests passed (19 tests); targeted analysis of the migrated Chat page and example had no issues. The host Chat initialization, live-chat service, and image-network tests passed (34 tests), and targeted analysis of the two app roots and image crop page had no issues. Host iOS simulator build (`flutter build ios --simulator --no-codesign`) and macOS Release build both exited 0. The macOS app at `build/macos/Build/Products/Release/N42 Chat.app` is universal arm64/x86_64 and passed strict deep signature verification with a local ad-hoc signature.

A dedicated `MediaEditorPage` completion/cancel widget test was not established: the ProImageEditor widget harness did not initialize its image stream or enable the done action with bounded pumps, including when using the existing fixture. No unverified harness test was retained. The migrated route is therefore not directly covered by a new behavior test in this batch; existing social-image preparation tests provide surrounding UI regression coverage. A fresh full host coverage run on the integrated Pro Image Editor 14 graph is recorded below.


## Full host verification after Pro Image Editor 14

At host integration HEAD `6210e8f59bc0a8a353752dee063b5dba8da10923`, `/opt/homebrew/bin/flutter test --coverage --concurrency=4 --machine` exited 0 under Flutter 3.44.8 / Dart 3.12.2. The machine stream ended with `done success=true`: 5,334 visible and 544 hidden tests passed, 0 failed and 0 skipped. Fresh `coverage/lcov.info` reports 93,570 covered of 133,303 executable lines (70.193469%), above the unchanged 70% gate. Machine log, stderr, and exit marker are retained locally at `/tmp/host-pro-image-editor-20261003-machine.jsonl`, `/tmp/host-pro-image-editor-20261003.stderr`, and `/tmp/host-pro-image-editor-20261003.exit`.
