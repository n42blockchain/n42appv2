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
| `equatable` | 2.1.0 | 3.0.0 | Host is blocked by `fl_chart` 1.2.0's `equatable ^2.0.7` bound; see the evaluation below. |
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
| `webview_flutter_wkwebview` | 3.26.2 | 3.27.0 | Host path fork is refreshed to the latest SDK-compatible 3.26.2; 3.27.0 requires Dart 3.13 / Flutter 3.47. |
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

At host integration HEAD `6210e8f59bc0a8a353752dee063b5dba8da10923`, `/opt/homebrew/bin/flutter test --coverage --concurrency=4 --machine` exited 0 under Flutter 3.44.8 / Dart 3.12.2. The machine stream ended with `done success=true`: 5,334 visible and 544 hidden tests passed, 0 failed and 0 skipped. Fresh `coverage/lcov.info` reports 93,570 covered of 133,303 executable lines (70.193469%), above the unchanged 70% gate. The machine log and LCOV are archived as [machine JSONL](../coverage-expansion-2026-10-02/artifacts/host-pro-image-editor-14-20261003-machine.jsonl.gz) and [LCOV](../coverage-expansion-2026-10-02/artifacts/host-pro-image-editor-14-20261003-lcov.info.gz); the [exit marker](../coverage-expansion-2026-10-02/artifacts/host-pro-image-editor-14-20261003.exit) is `0`. Uncompressed SHA-256: machine `bee7d5fbc09c9faba55f8ee7b6fe8db4b9843714fbc4f74e7f0e59d266282544`, LCOV `ad76c3d8a441c75f69df18f3c7d8f1af904db3cbf60ced0c09e794d167adde9c`; archived SHA-256: machine `782afaf289e92b3532647e99761ea1e7ffcdb224ecf0aafeff0dc1d90aed94b2`, LCOV `94ad571962bff9e1b507d46cbc6f695630f7c5910914d2f44d4600c83a0986ec`. The raw stderr file is empty.

## Chewie video controls update

The authoritative Chat branch `codex/chat-pro-image-editor-14-20261003` now resolves at `755096fc31345568dc9a2e89b27009fb370da201`. It raises `chewie` 1.13.1 → 1.17.2 in the package manifest, updates root/example locks, and resolves Chewie's new lower bound to `video_player` 2.14.1 (from 2.13.0) and `cupertino_icons` 1.0.9 (from 1.0.8). Host commit `dfd802c31293b2e88c4522fcf774bb304a41fda7` raises its Chewie constraint and pins that Chat SHA; Host already used `video_player` 2.14.1. The existing `VideoPlayerPage`, `VideoPlaySafe`, and NFT detail call sites use the same `Chewie` / `ChewieController` constructor surface.

Pub's current resolver reports Chewie 1.17.2 as the latest and resolvable version. Its package metadata requires Dart >=3.12.0 and Flutter >=3.44.0. The official [Chewie changelog](https://pub.dev/packages/chewie/changelog) records the Flutter 3.44 minimum beginning with 1.16.0 and lists 1.17.2 as an additive release, so the fixed Flutter 3.44.8 / Dart 3.12.2 toolchain is supported.

On Chat, root and example `flutter pub get --enforce-lockfile` passed; the six existing story/video-feed/authenticated-video/sticker/video-note/thumbnail focused test files passed 23 tests, and targeted analysis of `VideoPlayerPage` plus those tests reported no issues. Host `flutter pub get --enforce-lockfile` passed; the video-player disposal regression and two NFT list interaction files passed 7 tests; analysis of `VideoPlaySafe`, NFT detail, and the disposal regression reported no issues. iOS simulator build exited 0. macOS Release build exited 0; the 215.5 MB app is universal arm64/x86_64, targets macOS 12.0, and passed strict deep signature verification with a local ad-hoc signature. Existing tests do not instantiate Chewie's actual playback controls in `VideoPlayerPage`, `VideoPlaySafe`, or NFT detail; compilation and surrounding video/NFT regressions were verified, while control-level playback interaction remains untested. A fresh full host coverage run on the Chewie graph is recorded below.

## Remaining upgrade work

The dated outdated table above is the baseline inventory, not the current lock graph. The map projection family, file-picker/share plugin family, cached image, Pro Image Editor, Chewie, go_router, flutter_contacts, geolocator, ML Kit, and Firebase Messaging batches are now recorded as integrated upgrades. Remaining direct candidates still need separate compatibility work: `connectivity_plus` 7.3.2 is blocked by Chat's `dbus ^0.7` constraint; `intl` 0.20.3 is blocked by Flutter's pin; `easy_refresh` 4 requires Flutter 3.47 / Dart 3.13; `cached_network_image` 4.0.4 requires a newer `material_ui` line which is also blocked by that SDK floor; `xml` 7.x needs namespace/RSS behavior tests; and `permission_handler` 13 requires Android compile SDK 37. `material_ui` 1.5.0 inherits the Flutter 3.47 / Dart 3.13 minimum first declared by 1.4.0. `cupertino_icons` 2.0 remains outside Chewie's current semver bound. CallKit, secure storage, and Vodozemac remain protected source/API boundaries; Equatable 3 is currently blocked by Host's `fl_chart` constraint as detailed below. `webview_flutter_wkwebview` remains a local host implementation override. Dev dependency upgrades (`freezed`, `sqlite3`, and generator/database tools) remain open. These are ongoing tasks; this record does not claim all dependencies upgraded.

## Equatable 3 evaluation and resolver blocker

The Chat-only Equatable 3 trial was based on Chat SHA `e2135d767e74021992729e5f877a08f763a92f23`, which is the SHA pinned by Host before this trial. Chat `pubspec.yaml` was temporarily raised to `equatable ^3.0.0`; root and example `pub get --enforce-lockfile` passed with Equatable 3.0.0. Five focused Chat test files passed 229 tests and targeted analysis of the migrated page and regression tests reported no issues. The trial covered top-level runtime-type distinction, nested list/map int-double equality and matching hashes, weakly typed `ProtocolEvent.data`, `ScheduledMessageDraft.payload`, and `VoteEntity.choice`, and custom `AuthState.toString`. The temporary migration/test commits `fa48fc8d` and `7826c870` were reverted on branch `codex/chat-equatable-3-20261003` because Host could not resolve the combined graph; the branch now ends at revert commits `df6bf46e` and `0cf32d0a`, whose working tree is identical to `e2135d76`.

Host resolution was tested after temporarily setting its direct Equatable constraint to `^3.0.0` and pinning Chat to `7826c870b49a874a89c664391ed1041584d28ff9`. Flutter 3.44.8 / Dart 3.12.2 `flutter pub get` failed with: `fl_chart 1.2.0 depends on equatable ^2.0.7`; the Host's direct Equatable 3 constraint therefore has no compatible solution. Pub's current package listing reports `fl_chart` 1.2.0 as latest, and its package metadata still declares `equatable: ^2.0.7` ([package metadata](https://pub.dev/packages/fl_chart), [changelog](https://pub.dev/packages/fl_chart/changelog)). Host uses fl_chart in four Dart files: `chart_histogram.dart`, `wallet_coin_market_preview.dart`, `gas_tracker_page.dart`, and `portfolio_page.dart`. No dependency override or fl_chart fork was introduced. The temporary Host manifest edit was discarded; Host lockfile is unchanged. No Host Equatable tests, analyzer, iOS/macOS builds, or dependency commit were made for this trial.

The trial also found a user-visible numeric representation edge in `ProposalDetailPage`: `_resolveChoiceName` maps integer `1` to its choice label but displays `1.0` literally. The temporary tested normalization mapped only finite integral numeric values within the valid option-index range and left fractional values and weighted maps unchanged. That code and test were reverted with the Equatable trial; the finding is documented for a separately approved fix and is not shipped.


## Full host verification after Chewie update

At host integration HEAD `4ae6fe166d29c5dac7e205906156d7b87ca1078a` (dependency code commit `dfd802c31293b2e88c4522fcf774bb304a41fda7`), `/opt/homebrew/bin/flutter test --coverage --concurrency=4 --machine` exited 0 under Flutter 3.44.8 / Dart 3.12.2. The machine stream ended with `done success=true`: 5,334 visible and 544 hidden tests passed, 0 failed and 0 skipped. Fresh LCOV reports 93,570 covered of 133,303 executable lines (70.193469%), above the unchanged 70% gate. Evidence is archived as [machine JSONL](../coverage-expansion-2026-10-02/artifacts/host-chewie-20261003-machine.jsonl.gz), [LCOV](../coverage-expansion-2026-10-02/artifacts/host-chewie-20261003-lcov.info.gz), and [exit marker](../coverage-expansion-2026-10-02/artifacts/host-chewie-20261003.exit) (`0`). Uncompressed SHA-256: machine `8ea8353e79ebc103eada319963a9d8cfa6e32ea660dc0699e22fba535be45b26`, LCOV `3da208ace4966a153ad3ce88874e77681f461e0fc0a8fdb0b8fccd3364bfd973`; archived SHA-256: machine `2ddb05f3859a730ac33f7d4621119e04a556d63f21b99938af3f1f5e7f0125d0`, LCOV `a2a17e1114aa053baf50e617c89f3e0fdc2c70e6c2a9418620e67abee7debbc8`.

## Unused Pinput dependency removal

A complete Dart/Kotlin/Swift/platform source scan found no Host or authoritative Chat imports or API references to the `pinput` package. Chat's lock page uses an in-house PIN form (`_showPinInput`), not `Pinput`; Pub's graph showed Pinput was only a direct Host/Chat dependency and introduced no transitive requirements. Chat commit `4bed0759cbce363aa3aaa2965c6b596642987c20` removes the Chat root manifest entry and refreshes root/example locks. Host commit `b909f617819e2bd7f55e246a575b0c701ce5c9da` removes its manifest/lock entry and pins that Chat commit. Chat `--enforce-lockfile`, the four Chat lock-service tests, and targeted analysis passed; Host `--enforce-lockfile`, 82 authentication/security focused tests, targeted analysis, and diff check passed. Pinput removal followed the Chewie-graph full coverage run; coverage was not rerun after this package-only removal.


## go_router 18.0.2 routing update

The authoritative Chat branch `codex/chat-pro-image-editor-14-20261003` now pins `go_router` 18.0.2 in commit `7f014c3d3c6e10e3372d8cf2df6f4cd711a625da`; its root and example locks resolve 18.0.2. Host commit `670684382cca3020b1a71f5d4414ef1709f2c322` raises the host constraint to `^18.0.2`, pins that Chat SHA, and refreshes the lock graph. The v18 release migrates internal Material/Cupertino imports to `material_ui` and `cupertino_ui`; the public router exports used by these applications remain available, so neither repository needed a source API migration. Flutter 3.44.8 / Dart 3.12.2 satisfies go_router 18.0.2's declared minimums. Existing Chat localization delegates already include `material_ui` delegates.

Before and after the Chat update, the same focused `app_router_test.dart`, `voice_room_list_page_test.dart`, and `auth_flow_test.dart` files passed (26 tests); targeted analysis of router, auth, voice route sources and tests reported no issues. These tests cover router instance/diagnostics, voice-room success/failure navigation, and login/register UI. They do not directly invoke the auth redirect function. Host added a live navigation regression: clicking the Live home start action opens `GoLivePage`, and closing it returns to `LiveHomePage`; it passed on the 17.5.0 baseline and after 18.0.2. The host Live route and page focused tests passed (5 tests), targeted analysis reported no issues, and `flutter pub get --enforce-lockfile` plus `git diff --check` passed.

Host iOS simulator build exited 0. macOS Release build exited 0 at `build/macos/Build/Products/Release/N42 Chat.app` (215.5 MB); the universal x86_64/arm64 app declares macOS 12.0 and passed `codesign --verify --deep --strict` with a local ad-hoc signature. This dependency batch did not rerun the full host test/coverage suite; the latest archived full run remains the Chewie-graph result above and predates the subsequent Pinput/go_router manifest-only updates.

The refreshed host `flutter pub outdated --json` snapshot after the geolocator pin is preserved in [`pub-outdated-2026-10-03.json`](pub-outdated-2026-10-03.json). It reports 20 direct, 8 dev, and 58 transitive packages; 18 direct, all 8 dev, and all 58 transitive entries have a newer `latest` release than the current lock. Two direct dependencies and one transitive dependency are resolvable beyond their current locks: Firebase Messaging 16.5.0 → 16.7.0, its platform interface 4.9.3 → 4.10.0, and web implementation 4.2.4 → 4.2.5. Firebase remains a protected API/native migration and was not changed. `flutter_contacts` and `geolocator` no longer appear as outdated packages. The command exited 0 under Flutter 3.44.8 / Dart 3.12.2.

## Flutter contacts 2.6.0 update

The authoritative Chat branch `codex/chat-pro-image-editor-14-20261003` was upgraded from `flutter_contacts` 2.1.0 to 2.6.0 in commit `c5e77bf51a1aa11cd451026b366ce2d62633ec03`. The Chat root constraint is now `^2.6.0`; root and example locks resolve 2.6.0. Host commit `acdb2e5ec985411835b5b5e1c487364214757606` pins this Chat commit and updates the host lock from 2.5.0 to 2.6.0. Host build metadata advanced from `2.4.8+2026072990` to `2.4.8+2026072991`.

The package changelog for 2.6.0 notes fixes to Android bulk photo writes, returning `null` for a missing single-contact lookup, and custom-label readback changes on Apple platforms. Chat's integration uses only permission requests and `getAll`; it does not call single-contact `get()` or depend on custom-label representations. Version 2.2 moved the Android plugin to built-in Kotlin; the package declares Android minSdk 24. The fixed Flutter 3.44.8 / Dart 3.12.2 toolchain satisfies its Flutter minimum. See the upstream [`flutter_contacts` changelog](https://pub.dev/packages/flutter_contacts/changelog) and [package metadata](https://pub.dev/packages/flutter_contacts).

On Chat, root and example `flutter pub get --enforce-lockfile` passed; all 17 contact-focused test files passed 306 tests, and targeted analysis of `ContactSyncService` plus its tests reported no issues. Chat's example has no Android runner, so an example APK build is not applicable. On Host, `flutter pub get --enforce-lockfile`, Chat initialization and live Chat service tests (32 tests), `flutter analyze --no-fatal-infos` (exit 0; 35 existing infos), and `git diff --check` passed. The iOS simulator build exited 0 and produced `build/ios/iphonesimulator/Runner.app`. macOS Release exited 0 and produced a universal arm64/x86_64 app; strict deep code-signature verification passed. Android debug compilation could not proceed because the local checkout lacks `android/app/google-services.json`; Gradle stopped in `processDebugGoogleServices` before app compilation. No native Pod lockfiles changed. This batch did not rerun the full host suite or coverage; the last archived full run is the Chewie-graph result above, so the 70% gate still needs a fresh run on a later integrated dependency graph.

## Geolocator 14.1.1 update

The authoritative Chat branch `codex/chat-pro-image-editor-14-20261003` raises its direct `geolocator` constraint from `^14.0.0` to `^14.1.1` in commit `a57209a1735dc8eeac6bff6b68306c93f69da1ea`. Root and example locks now resolve geolocator 14.1.1, `geolocator_android` 5.1.1+1, `geolocator_apple` 2.3.14, `geolocator_platform_interface` 4.4.0, `geolocator_web` 4.1.4, and `geolocator_linux` 0.2.6. Host has no direct Geolocator import or calls; its dependency comes through Chat. Host commit `9f80eaf4a6c1d526aacb87fdab882fab8b8c7a91` pins the Chat SHA and updates only `pubspec.yaml` / `pubspec.lock`; build metadata advanced from `2.4.8+2026072992` to `2.4.8+2026072993`.

The upstream [geolocator changelog](https://pub.dev/packages/geolocator/changelog) records no public API break in 14.1.0/14.1.1; 14.1.0 raises its Android/platform-interface dependency family, while 14.1.1 only adjusts the example Gradle pins. The resolved Android plugin declares Flutter-provided compile/min SDK values, and its 5.1.1+1 release rolls back automatic `FOREGROUND_SERVICE_LOCATION` manifest insertion. Apple plugin podspec floors are iOS 11 and macOS 10.11, below the host's configured floors. Chat call sites use `Geolocator` service/permission checks, `getCurrentPosition(LocationSettings(...))`, and the location-picker GPS flow. Four existing live-location and map-picker behavior suites passed before and after the update (62 tests each), covering live-location state/timer behavior, GPS coordinates, stale-search invalidation, and selection; the picker platform fake returns an enabled service and `whileInUse` permission, so denied/denied-forever UX was not exercised by this focused set. Chat full analyze exited 0 with 279 existing infos; the five targeted location files had one existing informational lint. Root and example enforce-lockfile both passed.

On Host, `flutter pub get --enforce-lockfile`, Chat initialization/live service tests (32 tests), and full analyze (exit 0; 35 existing infos) passed. iOS simulator build exited 0. macOS Release exited 0; the 215.6 MB universal arm64/x86_64 app reports minimum OS 12.0 and passed strict deep signature verification. Android debug build remains blocked before app compilation by the missing local `android/app/google-services.json` Firebase config. No CocoaPods lockfiles changed. Full host coverage was not rerun after this lock/pin update; the 70% gate remains to be reconfirmed on a later integrated dependency graph.


## Google ML Kit plugin family update

The authoritative Chat dependency branch was advanced to `126ca0f94aea66c0e95ddfc8e805223730dc8dcd` (`deps: upgrade Chat ML Kit plugins`). It updates the coordinated Google ML Kit family: `google_mlkit_face_detection` 0.14.0 → 0.15.1, `google_mlkit_text_recognition` 0.16.0 → 0.17.1, `google_mlkit_translation` 0.14.0 → 0.15.1, and `google_mlkit_selfie_segmentation` 0.11.0 → 0.12.1; shared `google_mlkit_commons` resolves to 0.13.0. Chat API call sites did not require source changes. Host commit `2d74b6597` (`deps: upgrade Chat ML Kit packages`) pins that Chat SHA and updates the three Host direct ML Kit constraints, `pubspec.lock`, and `ios/Podfile.lock`. The host build metadata hook advanced with the commit.

Under Flutter 3.44.8 / Dart 3.12.2, Chat root and example `flutter pub get --enforce-lockfile` passed; four existing translation/image-text/virtual-background focused suites passed 20 tests both before and after the package update, and full Chat analysis exited 0 with 279 existing infos. Host `flutter pub get --enforce-lockfile`, Chat initialization/live-service focused tests (32 tests), and `flutter analyze --no-fatal-infos` (exit 0; 35 existing infos) passed. Host iOS simulator build exited 0. Host macOS Release build exited 0; its build log is `/private/tmp/host-mlkit-macos-build-20261003.log` and the exit marker is `/private/tmp/host-mlkit-macos-build-20261003.exit` (`0`). The 215.6 MB app is universal arm64/x86_64, declares `LSMinimumSystemVersion=12.0`, and passed `codesign --verify --deep --strict`. The macOS log contains non-fatal plugin/PrivacyInfo processing warnings; Flutter completed with the app build success line. Android build was not repeated in this batch; the known local `google-services.json` prerequisite remains. Full host coverage was not rerun after this dependency update, so the 70% gate requires a fresh full run on the current integrated graph.

The refreshed Host `flutter pub outdated --json` snapshot on the ML Kit graph is preserved in [`pub-outdated-2026-10-03-post-mlkit.json`](pub-outdated-2026-10-03-post-mlkit.json); the command exited 0 with Flutter 3.44.8 / Dart 3.12.2. It reports 81 packages: 17 direct (15 have a newer `latest`), 8 dev (all 8 have a newer `latest`), and 56 transitive (all 56 have a newer `latest`). At that point Firebase Messaging 16.5.0 → 16.7.0 and its platform interface 4.9.3 → 4.10.0 remained a coordinated Chat API/native migration; both have since been upgraded and are absent from the next audit. Other direct candidates remain blocked by fixed SDK/shared constraints or need explicit migrations: `connectivity_plus` by Chat's `dbus ^0.7`, `intl` by Flutter's pin, `easy_refresh` by toolchain minimum, `cached_network_image` 4.0.4 by `material_ui` compatibility, `cupertino_icons` 2.0 by Chewie's semver upper bound, `permission_handler` 13 by Android SDK 37, `material_ui` 1.5.0 by its Flutter 3.47 / Dart 3.13 minimum (introduced at 1.4.0), and `xml` 7 by XML namespace/RSS behavior migration. Major migrations include `equatable` 3, CallKit, secure storage, and Vodozemac. A next candidate must be selected only after checking the fixed-SDK graph and source/API impact; this audit does not mark the remaining packages complete.

## Firebase Messaging 16.7.0 integration

The authoritative Chat branch `codex/chat-pro-image-editor-14-20261003` now includes commit `e2135d767e74021992729e5f877a08f763a92f23`, upgrading `firebase_messaging` 16.1.2 → 16.7.0 and `firebase_messaging_platform_interface` 4.7.7 → 4.10.0. Chat's permission-status switch maps the newly added `AuthorizationStatus.deniedPermanently` to the existing denied status. A focused fake-platform test first failed to compile on the missing enum case, then passed after the mapping. Chat root and example locks resolve `firebase_core` 4.15.0, Firebase Messaging 16.7.0, platform interface 4.10.0, and web implementation 4.2.5. Root and example `flutter pub get --enforce-lockfile` passed, as did the four FCM/CallKit/dedup focused suites (65 tests) and targeted analysis with no issues. The Chat example has no iOS application target; `flutter build ios --simulator --no-codesign` reports `Application not configured for iOS`.

Host commit `eb6190523705a55f5e66fda35e81b2defd280c21` pins the Chat SHA and constrains Messaging to 16.7.x and its platform interface to 4.10.x. It adds regression coverage that an iOS `deniedPermanently` status does not trigger another permission request (the prior logic failed by issuing one extra request), while ordinary denied permission still follows the existing retry path. A separate terminated-app tap test supplies only `getInitialMessage()` with no `onMessageOpenedApp` event and verifies that the host route registry receives the payload once. This test passes without changing the existing cold-start route implementation, which already handles `getInitialMessage()`.

On Host, `flutter pub get --enforce-lockfile`, the app-push/cold-start/dedup suites (25 tests), targeted analysis, and `git diff --check` passed under Flutter 3.44.8 / Dart 3.12.2. The iOS simulator build exited 0 and produced `build/ios/iphonesimulator/Runner.app`. The macOS Release build exited 0 and produced a 215.6 MB `N42 Chat.app`; strict deep code-signature verification passed and its `LSMinimumSystemVersion` is 12.0. Both `ios/Podfile.lock` and `macos/Podfile.lock` only changed the Firebase Messaging version/checksum; Firebase Apple SDK remains 12.19.0. The macOS compiler emitted non-fatal dependency warnings, including Firebase Messaging's deprecated Firebase token API calls. Android build was not run because the local `android/app/google-services.json` prerequisite is absent. The Host build metadata hook advanced the version to `2.4.8+2026072997`. Full Host coverage was not rerun for this batch; the unchanged 70% gate still requires a fresh full run on a selected integrated graph.

The refreshed Host `flutter pub outdated --json` result is preserved in [`pub-outdated-2026-10-03-post-fcm.json`](pub-outdated-2026-10-03-post-fcm.json), SHA-256 `a994f2a522bd87fef299ee4183fc70cf1763521af412d7dcdc721479a806d8a1`. It reports 78 packages: 15 direct (13 have a newer `latest`), 8 dev (all 8 have a newer `latest`), and 55 transitive (all 55 have a newer `latest`). No package is marked resolver-upgradable under the current constraints. Firebase Messaging and its platform interface no longer appear as pending upgrades. The next candidate remains the direct `connectivity_plus` 7.3.2 patch, which Pub cannot currently resolve because the pinned Chat source still requires `dbus ^0.7`; a `flutter_local_notifications` update also cannot relax this because its Linux implementation still requires `dbus ^0.7.8`. Other open direct work includes `xml` 7 API/namespace behavior, which is also bounded by `simple_html_css` 5.0.0, `intl`'s Flutter pin, `permission_handler` Android SDK 37, and larger `equatable`/CallKit/storage migrations.

## WebKit Pigeon transport patch

Host commit `23ad18d9fef7ed9e9b95ac66ff6bbd1937b16c14` advances the direct `webview_flutter_wkwebview` constraint and the existing host-local path fork from 3.26.1 to 3.26.2. The authoritative Chat source uses the public `webview_flutter` API and does not import the platform implementation; its standalone lock remains independent, so no Chat pin/source change was required. The fork's local iOS/macOS project configuration and source customizations were retained. The upstream 3.26.2 Pigeon-generated Dart/Swift channels fix nullish error responses and malformed error descriptions; no public Dart API or host call-site migration was needed. The official 3.27.0 release requires Dart ^3.13.0 and Flutter >=3.47.0, so 3.26.2 is the latest compatible candidate under the fixed Dart 3.12.2 / Flutter 3.44.8 toolchain.

Root, fork root, and fork example `flutter pub get --enforce-lockfile` passed. The fork's 154 tests, Host's three browser behavior suites (71 tests), fork analyzer, and Host analyzer limited to `lib/features/browser` and `test/features/browser` passed. Full Host `flutter analyze` exited 1 with 35 informational findings and no errors; the focused browser analysis was clean. iOS simulator build exited 0 and produced `build/ios/iphonesimulator/Runner.app`. macOS Release exited 0 and produced `build/macos/Build/Products/Release/N42 Chat.app`; strict deep codesign verification passed and `LSMinimumSystemVersion` is 12.0. Xcode logged non-fatal Swift deprecation warnings for `SecTrustGetCertificateAtIndex`, plus “SwiftCompile ... exit code 0 but produced no further output” diagnostics, but Flutter reported successful packaging and the signed app was verified. `git diff --check` passed. These focused tests/builds do not replace the full Host coverage gate.

The refreshed Host `flutter pub outdated --json` snapshot after this batch is [`pub-outdated-2026-10-03-post-webkit.json`](pub-outdated-2026-10-03-post-webkit.json), SHA-256 `a81e4964d895991d36681be3128d2f019ae42c258f198d77b818731fe41b8e8b`. It reports 81 packages: 15 direct (13 with a newer latest), 8 dev (8 with a newer latest), and 58 transitive (58 with a newer latest). `webview_flutter_wkwebview` is now 3.26.2; its 3.27.0 latest remains incompatible with the accepted SDK.
