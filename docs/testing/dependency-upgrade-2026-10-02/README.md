# Dependency upgrade record — started 2026-10-02; status refreshed 2026-10-05

This record covers the host application's pinned Chat map update and the first host dependency batch. The audit is a checkpoint, not a claim that every package is upgraded. The host `pubspec.yaml` and lockfile are the source of truth; `packages/n42_chat/` is a cache mirror and was not edited.

## Resolver snapshot from 2026-10-04

At this snapshot, the host pinned Chat to merged PR #2 (`a24058de8849ab232d743458e88c60d2f042790`), which included the channel-discovery and red-packet-history entry points. The Chat source was tested at `b976317565e46bf2f6f65e96ac05bc8d28322047`. The 2026-10-05 state is listed below; the earlier sections record older dependency checkpoints.

A fresh Pub resolver audit found newer package versions in both graphs. Host: 23 direct, 8 dev, and 60 transitive dependencies; Chat: 65 direct, 10 dev, and 157 transitive dependencies. The exact upgradable, resolvable, and latest counts are in [`artifacts/pub-outdated-20261004-summary.md`](artifacts/pub-outdated-20261004-summary.md), with compressed machine snapshots beside it. Not every latest version fits current constraints or has completed compatibility work. The full dependency-upgrade request remains open.

## Previous completed batch (2026-10-05)

The host repository is at `10a429c7f` and pins Chat to `dadb12a1`. The latest host dependency batch aligned the Chat source API with the host constraints, removed unused or obsolete direct package entries, and updated six compatible packages. The root full suite passed 5,432 tests; coverage was 71.1432%. Analysis exited 0 with no warnings or errors. The independent Chat full suite passed 7,308 tests, skipped 3, and measured 70.0962% coverage; Chat analysis exited 0 with no warnings or errors. See the current task ledger for these acceptance results.

The request to upgrade every dependency is still open. The latest `pub outdated` snapshot lists newer releases that remain outside current constraints or need source/native migration. Keep them open until each graph has a compatible update and its tests and platform builds pass. Do not infer completion from the successful compatible batch.

## Additional verified batch (2026-10-05)

This later batch advances the package graph and the Chat example host after the checkpoint above. The host now requires Dart 3.13 / Flutter 3.47 and CI pins Flutter 3.47.5. It pins Chat to `c1388a54452a233aa840a79b4e7980e844228cb2`, which includes the checked-in mobile example hosts, the final dependency migration, and refreshed dependency locks.

Host changes include `easy_refresh` 3.5.1 → 4.0.0, `cached_network_image` 4.0.3 → 4.0.4, `intl` 0.20.2 → 0.20.3, `pro_image_editor` 14.6.2 → 14.8.0, `sqflite` 2.4.4 → 2.4.4+1, `sqlite3` 3.5.2 → 3.7.0, and `xml` 6.6.1 → 7.1.0. `freezed` moved to the latest resolvable 4.0.1; `build_runner`, `intl_utils`, and `mockito` moved to 2.16.1, 2.8.16, and 5.8.1. A normal `flutter pub upgrade` advanced six more allowed transitive packages, including `background_downloader`, cached-image interfaces, `native_toolchain_c`, and `stack_trace`. The XML override is needed because `simple_html_css` 5.0.0 still declares an XML 6-only range; RSS tests and the full suite pass with XML 7.1.0.

Chat replaced `flutter_gemma` with `flutter_edge_ai` 2.0.0 plus `flutter_edge_ai_mediapipe` 1.0.9, and replaced discontinued `flutter_markdown` with `flutter_markdown_plus` 1.0.12. It also upgrades `fluwx` to 6.0.4, `pro_image_editor` to 14.8.0, `material_ui` to 1.5.0, `drift` / `drift_dev` to 2.35.1, `sqlite3` to 3.7.0, and the other compatible packages in its lockfile. Unused `badges` was removed. Chat declares Dart 3.13 / Flutter 3.47 as its floor. The example iOS host supports iOS 16; Android uses API 24+, Java/Kotlin 17, and desugaring 2.1.4.

Validation with Flutter 3.47.5 / Dart 3.13.4:

- Host `flutter test --coverage --concurrency=4 --reporter compact` — 5,432 passed; 94,867 / 133,343 lines, 71.1451% coverage.
- Chat full suite on the final lockfiles — 7,308 passed, 3 skipped; final 2.x Equatable graph measured 70.0948% coverage (97,035 / 138,434 lines).
- `flutter analyze --no-fatal-infos` — exit 0; informational lints only.
- Host Android debug APK and iOS simulator app — both built. The Chat example Android APK and x86_64 iOS simulator app also built.
- Host and Chat `flutter pub get --enforce-lockfile` — passed.
- The resolver snapshot after the host's normal `pub upgrade` is preserved in [`artifacts/host-pub-outdated-final-flutter347-20261005.json`](artifacts/host-pub-outdated-final-flutter347-20261005.json). It reports 24 packages with newer releases outside current constraints.

The full-upgrade task remains open. Remaining direct version gaps have concrete compatibility boundaries:

- `equatable` stays at 2.1.0 because `fl_chart` 1.2.0 uses `EquatableMixin`, removed in Equatable 3. Forcing Equatable 3 caused the chart-based host tests to fail compilation, so both Chat and the host use 2.1.0.
- `connectivity_plus` stays at 7.3.1 and Chat `wakelock_plus` at 1.8.0. Their next releases require `dbus` 0.8, which conflicts with the Linux notification plugin's `dbus` 0.7 range.
- `cupertino_icons` stays at 1.0.9 because the current `chewie` graph also requires the 1.x icon package.
- `flutter_secure_storage` remains overridden to 10.3.4 to keep the wallet's legacy encrypted-value migration. Version 11 removes that migration path and raises the Android compile SDK requirement; do not remove this pin until an explicit data migration is in place.
- `freezed` 4.0.2 requires Analyzer 14, while the latest `intl_utils` requires Analyzer 13. The latest compatible pair is Freezed 4.0.1 with `intl_utils` 2.8.16.
- `webview_flutter_wkwebview` remains on the local host override; its newer hosted release does not include the host-specific patch. `package_info_plus` and `unorm_dart` overrides already resolve to their latest versions.

The Chat plugin upgrade and refreshed lockfiles are merged to Chat `main` at `c1388a54452a233aa840a79b4e7980e844228cb2`. Host changes are being committed in small batches. Keep this task open for the listed migrations; do not describe the dependency graph as fully latest.

## Toolchain and historical baseline

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
