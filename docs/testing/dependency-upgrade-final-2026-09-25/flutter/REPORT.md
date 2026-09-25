# Task 4 implementation report

## Status

**DONE_WITH_CONCERNS.** The app and active local packages resolve and pass their required tests and analyses on Flutter 3.44.8 / Dart 3.12.2. The pinned Chat package's own complete suite has one reproducible upstream test failure. No push/publish was performed. Commit identity is recorded in the implementation handoff.

Machine-readable handoff: `final-status.json`. Every instrumented command has its working directory, arguments, exit and elapsed time in `commands.jsonl`; the corresponding `<label>.log` and `<label>.exit` preserve full output and status.

## Changes

- Upgraded root direct/dev constraints and regenerated the root lock through Pub. The final root lock has 426 dependency entries, with 132 added/version-changed entries relative to Task 3, no removed packages, and no prerelease selections. Full changes: `lock-changes.json`; final dependency and outdated graphs: `deps-final.json`, `outdated-final.json`.
- Migrated Web3Auth 6.3 to 7.0: `Network` → `Web3AuthNetwork`, `Provider` → `AuthConnection`, `login` → `connectTo`, session initialization + `getPrivateKey`, string redirect URLs, and renamed response/user fields. Ten focused tests cover every supported login method, restored sessions, known secp256k1 key/address identity, empty-key rejection, and logout/signing access. The adapter's signing and address derivation algorithms are unchanged. Native OAuth/device acceptance belongs to the later native tasks; no credentials were fabricated.
- Upgraded Fluttertoast to 10, Reown, Firebase modules, Riverpod, media/storage packages, generators and compatible transitive dependencies. Remaining caps have package/API-specific evidence in the complete inventory below.
- Upgraded Mining and its example independently; raised plugin_platform_interface to 2.1.8, example cupertino_icons to 1.0.9 and flutter_lints to 6.0.0. Kept native Kotlin 2.2.20, AGP 8.11.1, Java 21, compileSdk 36, minSdk 24 and existing `mobile-sdk-module` / `evm-module` AAR integration unchanged.
- Upgraded JMT's test dependency to 1.32.0; kept `blake3_dart` exactly 1.0.0. JMT's 13 tests include BLAKE3 vectors and proof verification.
- Upgraded the Audio path override to upstream 6.5.0. Its released Swift source is identical to 6.4.0, so the local iOS >=27 registration guard remains intact. Removed the upstream monorepo-only `resolution: workspace` declaration so the vendored package resolves independently; its lint dependency now matches its existing flutter_lints configuration.
- Upgraded the actual WebView path package to 3.26.1. The latest release's generated Swift still lacked the local NSNull authentication-challenge guard. The package's existing `CONTRIBUTING.md` documents the Pigeon generator; Pigeon 29.0.4 generates `WebKitLibraryPigeonInternal.isNullish`, which checks NSNull before casting the response. Regenerated Dart/Swift using `dart run pigeon --input pigeons/web_kit.dart`, formatted generated Dart with `dart format`, and regenerated mocks with `flutter pub run build_runner build --delete-conflicting-outputs`. No generated source was hand-edited. Validated first in a disposable copy, then in the package. Added the exact reproducible generator workflow to CONTRIBUTING. Its native example project/toolchain files were retained from this repository.
- Captured generated lockfiles for all standalone active packages and both examples, including previously ignored library locks, so clean package-level resolution is reproducible.
- Deleted all 13 root test aggregators that imported `packages/n42_chat/test/`. The actual Chat source remains the declared Git SHA. The existing CI test job now checks resolved local override paths, runs Mining/example/WebView tests, exports the exact locked Chat revision from its Git checkout, and independently runs Chat analysis/tests. These steps still run when app tests fail. No CI job was added; the 70% coverage gate is unchanged.

## Firebase compatibility fix and correction of earlier evidence

The earlier statement that `firebase_messaging_platform_interface 4.9.2` defines `AuthorizationStatus.deniedPermanently` was **incorrect**. This task downloaded official 4.9.2, 4.9.3 and 4.10.0 release archives, checked each archive's SHA256 against pub.dev metadata, and inspected `lib/src/types.dart`:

| Interface version | `deniedPermanently` | Cached source matches official archive |
|---|---|---|
| 4.9.2 | Absent | Yes |
| 4.9.3 | Absent | Yes |
| 4.10.0 | Present | Yes |

Exact URLs, expected/downloaded digests and comparisons: `messaging-archive-audit.json`. Official package manifests and enum snapshots are stored alongside it.

Chat SHA `3cc19c12a7c9bbf2031270acca8e3922730b55a5` still omits the new case in `lib/src/core/notifications/firebase_push_service.dart:getPermissionStatus`. Messaging 16.6+ requires interface ^4.10.0; Messaging 16.5.0 requires ^4.9.3 and is the latest compatible stable release. The root now declares Messaging `>=16.5.0 <16.6.0` and a direct platform-interface bound `>=4.9.3 <4.10.0`. The second upper bound is necessary because a ^4.9.3 transitive requirement would otherwise resolve to 4.10.0 again.

The earlier upgraded graph reproduced the compiler failure with **4.10.0**, not 4.9.2. After the compatible constraints, the complete app suite passes 4,803 tests. This resolves the notification compile blocker without editing Chat, its cache/mirror, or its SHA. A future move past the cap needs an upstream Chat permission mapping for the new enum member.

## Final verification

| Check | Result | Evidence label |
|---|---|---|
| `flutter test test/ --concurrency=4 --reporter expanded` | Exit 0; **4,803 passed**, zero failed | `root-app-tests-compatible` |
| `flutter analyze --no-fatal-infos` | Exit 0; **0 errors, 0 warnings, 35 infos** | `firebase-compatible-analyze` |
| `flutter test plugins/flutter_mining/test/` | Exit 0; 3 passed | `mining-test` |
| Mining example `flutter test test/` from its package directory | Exit 0; 1 passed | `mining-example-test` |
| JMT `dart pub get`, `dart test` | Exit 0; 13 passed | `jmt-get`, `jmt-test` |
| `flutter test packages/webview_flutter_wkwebview/test/` | Exit 0; 154 passed | `final-webview-formatted-test` |
| Web3Auth migration tests | Exit 0; 10 passed | `web3auth-last-test` |
| Mining, JMT, Audio, WebView package analyses | All exit 0; no issues | `mining-analyze`, `jmt-analyze`, `audio-analyze`, `webview-analyze` |
| Seven clean manifest/lock exports, `pub get --enforce-lockfile` | All exit 0 | `clean-root-compatible`, `clean-mining`, `clean-mining-example`, `clean-audio`, `clean-webview`, `clean-webview-example`, `clean-jmt` |
| Actual CI override-resolution Python script | Exit 0; Audio/WebView/Mining resolve to intended local paths | `ci-overrides-final` |
| Actual CI exact-Chat export Python script | Exit 0; Git SHA matches declared/locked SHA | `ci-export-check` |
| CI YAML parsing, `git diff --check`, staged-path review | Passed | Self-review / final command output |

The baseline root suite counted 5,831 tests while importing 13 mirror-backed Chat aggregators. The final app-owned suite counts 4,803 after those aggregators were removed and the Web3Auth migration tests were added; the exact Git Chat package is tested separately. This scope/count change is not a coverage improvement or a claim that the 70% gate passes.

The literal root command `flutter test plugins/flutter_mining/example/test/` fails because the root package does not resolve `package:flutter_mining_example/main.dart`. Running the example suite from `plugins/flutter_mining/example` is the correct package context and passes; CI uses that context. This is recorded as a failed diagnostic command (`mining-example-root-command`), not hidden.

The first broad app test attempt was interrupted while WebView files were changing; the process happened to return exit 0 after SIGINT, which is **not a pass**. The next attempt was explicitly stopped when the user paused at 1,815 passed / 39 failed; it has no final result. Neither is acceptance evidence. The resumed, completed `root-app-tests-compatible` run is the final result.

## Exact Chat source verification and actual remaining issues

The Chat analysis and full suite ran from a disposable `git archive` export of the exact resolved SHA, without editing package/cache/mirror source. Its own committed dependency lock resolves Firebase Messaging 16.1.2 / platform interface 4.7.7 and Matrix 6.1.1:

- `flutter pub get`: exit 0 (`chat-get`).
- `flutter analyze --no-fatal-infos`: exit 0, 279 infos, no errors/warnings (`chat-analyze`).
- `flutter test test/ --concurrency=4 --reporter expanded`: exit 1, **6,736 passed, 3 skipped, 1 failed** (`chat-test`).

The failing upstream test is `test/unit/datasources/matrix_contact_datasource_test.dart`, **expired timed status clears status message without forcing online presence**. Its `_MockClient.accountData` returns unstubbed `Null`, but `ContactPrivacyService.all` requires `Map<String, BasicEvent>`; the stack proceeds through `forUser`, `hides`, `getUserStatusMessage` and `getCurrentUserStatusMessage`. This is an actual failure in the untouched selected Git source, not a passing check or a presumed baseline exemption. CI reports it as a failure. Fixing it requires an upstream test/source revision, which this task is not authorized to edit or replace.

The previously documented missing exact-asset QR transfer interfaces at that SHA also remain: no `IWalletBridge.requestTransferExact` or expanded `TokenInfo` chain/network/asset identity contract. Task 3 preserves host helpers, but the exact Chat UI/API limitation remains external to Task 4.

Native Android/Apple device/build acceptance remains for Tasks 5/6; Dart/package tests do not establish native release acceptance. The existing 70% coverage gate remains unchanged; the captured 49.13% baseline/coverage expansion was deferred by the user and was not rerun or expanded here.

## Override and source audit

All four existing overrides remain: Audio path, WebView path, secure storage ^10.3.4 and Facebook exact 7.2.0. Chat is Git in both lock and dependency graph at the unchanged declared/resolved SHA. No additional override was removed or added. The Firebase compatibility constraint is a direct dependency bound, not an override. No `packages/n42_chat`, external Chat repository, cache source, host native toolchain, signing credential or generated localization file was edited.

All lockfiles were generated by Pub; final locks contain stable releases only. Secure storage remains v10 because v11 removes legacy storage migration and `AndroidOptions.sharedPreferencesName` used by `lib/core/storage/secure_preferences.dart`, and raises compileSdk from the fixed 36 to 37.

## Per-dependency inventory and retained caps

The complete direct/dev inventory follows. Supporting metadata and solver failures are in `registry.json`, `resolved-manifests.json`, `cap-*.log`, `cap-callers.txt`, and `registry-wakelock.json`.

# Task 4 direct and dev dependency inventory

Registry metadata was fetched from https://pub.dev/api/packages/<name> on 2026-09-25. Full responses: registry.json; final solver view: outdated-final.json. Versions below are stable. Every manifest scalar dependency was checked; SDK/Git/path entries follow the table.

| Package | Previous constraint | Final constraint | Resolved | Latest stable | Retention evidence |
|---|---|---|---|---|---|
| `mobile_scanner` (dependencies) | `^7.2.0` | `^7.4.2` | 7.4.2 | 7.4.2 | Latest stable resolved. |
| `cupertino_icons` (dependencies) | `^1.0.8` | `^1.0.9` | 1.0.9 | 1.0.9 | Latest stable resolved. |
| `flutter_screenutil` (dependencies) | `^5.9.3` | `^5.9.3` | 5.9.3 | 5.9.3 | Latest stable resolved. |
| `easy_refresh` (dependencies) | `^3.4.0` | `^3.5.1` | 3.5.1 | 3.5.1 | Latest stable resolved. |
| `flutter_slidable` (dependencies) | `^4.0.3` | `^4.0.3` | 4.0.3 | 4.0.3 | Latest stable resolved. |
| `qr_flutter` (dependencies) | `^4.1.0` | `^4.1.0` | 4.1.0 | 4.1.0 | Latest stable resolved. |
| `fl_chart` (dependencies) | `^1.1.1` | `^1.2.0` | 1.2.0 | 1.2.0 | Latest stable resolved. |
| `extended_image` (dependencies) | `^10.0.1` | `^10.1.0` | 10.1.0 | 10.1.0 | Latest stable resolved. |
| `custom_pop_up_menu` (dependencies) | `^1.2.4` | `^1.2.4` | 1.2.4 | 1.2.4 | Latest stable resolved. |
| `gesture_password_widget` (dependencies) | `^2.0.1` | `^2.0.1` | 2.0.1 | 2.0.1 | Latest stable resolved. |
| `roundcheckbox` (dependencies) | `^2.0.5` | `^2.0.5` | 2.0.5 | 2.0.5 | Latest stable resolved. |
| `simple_html_css` (dependencies) | `^5.0.0` | `^5.0.0` | 5.0.0 | 5.0.0 | Latest stable resolved. |
| `chewie` (dependencies) | `^1.13.1` | `^1.13.1` | 1.13.1 | 1.17.2 | Chewie >=1.14 requires wakelock_plus >=1.6, which needs win32 6 and package_info_plus 10. Chat file_picker 11/share_plus 12 require win32 5; reown_core 1.5.1 requires package_info_plus <10. cap-chewie.log + registry-wakelock.json. |
| `intl` (dependencies) | `^0.20.2` | `^0.20.2` | 0.20.2 | 0.20.3 | Flutter flutter_localizations pins intl exactly 0.20.2; root and Chat use generated S delegates and date/number formatting. |
| `flutter_riverpod` (dependencies) | `^3.2.1` | `^3.4.3` | 3.4.3 | 3.4.3 | Latest stable resolved. |
| `riverpod_annotation` (dependencies) | `^4.0.2` | `^4.0.7` | 4.0.7 | 4.0.7 | Latest stable resolved. |
| `sqflite` (dependencies) | `^2.4.3` | `^2.4.4` | 2.4.4 | 2.4.4 | Latest stable resolved. |
| `sqflite_sqlcipher` (dependencies) | `^3.1.0+1` | `^3.4.1` | 3.4.1 | 3.4.1 | Latest stable resolved. |
| `path` (dependencies) | `^1.9.0` | `^1.9.1` | 1.9.1 | 1.9.1 | Latest stable resolved. |
| `path_provider` (dependencies) | `^2.1.5` | `^2.1.6` | 2.1.6 | 2.1.6 | Latest stable resolved. |
| `shared_preferences` (dependencies) | `^2.5.4` | `^2.5.5` | 2.5.5 | 2.5.5 | Latest stable resolved. |
| `flutter_secure_storage` (dependencies) | `^10.0.0` | `^10.3.4` | 10.3.4 | 11.2.0 | 11.2.0 removes AndroidOptions.sharedPreferencesName (lib/core/storage/secure_preferences.dart uses n42_secure_prefs), encryptedSharedPreferences and legacy RSA/AES migration paths; also compileSdk 37 versus unchanged host compileSdk 36. Keep newest v10 (10.3.4) so existing stored wallet material can migrate. |
| `dio` (dependencies) | `^5.9.2` | `^5.11.1` | 5.11.1 | 5.11.1 | Latest stable resolved. |
| `xml` (dependencies) | `^6.6.0` | `^6.6.1` | 6.6.1 | 7.0.1 | simple_html_css 5.0.0 (latest stable) requires xml ^6.5.0; root HTML rendering and NewsApi RSS parsing share this parser. cap-xml.log. |
| `connectivity_plus` (dependencies) | `^7.0.0` | `^7.3.1` | 7.3.1 | 7.3.1 | Latest stable resolved. |
| `cached_network_image` (dependencies) | `^3.4.1` | `^3.4.1` | 3.4.1 | 4.0.2 | Pinned Chat pubspec ^3.4.1; image rendering still uses CachedNetworkImage/ImageProvider throughout Chat widgets. |
| `webview_flutter` (dependencies) | `^4.13.1` | `^4.14.1` | 4.14.1 | 4.14.1 | Latest stable resolved. |
| `webview_flutter_android` (dependencies) | `^4.13.0` | `^4.14.1` | 4.14.1 | 4.14.1 | Latest stable resolved. |
| `webview_flutter_wkwebview` (dependencies) | `^3.24.0` | `^3.26.1` | 3.26.1 | 3.26.1 | Latest stable resolved. |
| `web_socket_channel` (dependencies) | `^3.0.2` | `^3.0.3` | 3.0.3 | 3.0.3 | Latest stable resolved. |
| `http` (dependencies) | `^1.3.0` | `^1.6.0` | 1.6.0 | 1.6.0 | Latest stable resolved. |
| `url_launcher` (dependencies) | `^6.3.2` | `^6.3.2` | 6.3.2 | 6.3.2 | Latest stable resolved. |
| `flutter_cache_manager` (dependencies) | `^3.4.1` | `^3.4.5` | 3.4.5 | 3.4.5 | Latest stable resolved. |
| `eip712` (dependencies) | `^1.0.1` | `^1.0.1` | 1.0.1 | 1.0.1 | Latest stable resolved. |
| `web3dart` (dependencies) | `^3.0.1` | `^3.0.3` | 3.0.3 | 3.0.3 | Latest stable resolved. |
| `web3auth_flutter` (dependencies) | `^6.3.0` | `^7.0.0` | 7.0.0 | 7.0.0 | Latest stable resolved. |
| `fast_base58` (dependencies) | `^0.2.1` | `^0.2.2` | 0.2.2 | 0.2.2 | Latest stable resolved. |
| `bech32` (dependencies) | `^0.2.2` | `^0.2.2` | 0.2.2 | 0.2.2 | Latest stable resolved. |
| `crypto` (dependencies) | `^3.0.7` | `^3.0.7` | 3.0.7 | 3.0.7 | Latest stable resolved. |
| `decimal` (dependencies) | `^3.2.4` | `^3.2.6` | 3.2.6 | 3.2.6 | Latest stable resolved. |
| `pointycastle` (dependencies) | `^4.0.0` | `^4.0.0` | 4.0.0 | 4.0.0 | Latest stable resolved. |
| `blockchain_utils` (dependencies) | `^7.1.0` | `^7.1.0` | 7.1.0 | 7.1.0 | Latest stable resolved. |
| `reown_walletkit` (dependencies) | `^1.4.0` | `^1.5.1` | 1.5.1 | 1.5.1 | Latest stable resolved. |
| `reown_sign` (dependencies) | `^1.3.9` | `^1.4.1` | 1.4.1 | 1.4.1 | Latest stable resolved. |
| `reown_core` (dependencies) | `^1.3.8` | `^1.5.1` | 1.5.1 | 1.5.1 | Latest stable resolved. |
| `protobuf` (dependencies) | `^6.0.0` | `^6.1.0` | 6.1.0 | 6.1.0 | Latest stable resolved. |
| `fixnum` (dependencies) | `^1.1.0` | `^1.1.1` | 1.1.1 | 1.1.1 | Latest stable resolved. |
| `validators` (dependencies) | `^3.0.0` | `^3.0.0` | 3.0.0 | 3.0.0 | Latest stable resolved. |
| `event_bus` (dependencies) | `^2.0.1` | `^2.0.1` | 2.0.1 | 2.0.1 | Latest stable resolved. |
| `fluttertoast` (dependencies) | `^9.0.0` | `^10.0.0` | 10.0.0 | 10.0.0 | Latest stable resolved. |
| `flustars_flutter3` (dependencies) | `^3.0.0` | `^3.0.0` | 3.0.0 | 3.0.0 | Latest stable resolved. |
| `date_format` (dependencies) | `^2.0.9` | `^2.0.9` | 2.0.9 | 2.0.9 | Latest stable resolved. |
| `convert` (dependencies) | `^3.1.2` | `^3.1.2` | 3.1.2 | 3.1.2 | Latest stable resolved. |
| `cryptography` (dependencies) | `^2.7.0` | `^2.9.0` | 2.9.0 | 2.9.0 | Latest stable resolved. |
| `image_picker` (dependencies) | `^1.2.1` | `^1.2.3` | 1.2.3 | 1.2.3 | Latest stable resolved. |
| `photo_manager` (dependencies) | `^3.12.0` | `^3.12.0` | 3.12.0 | 3.12.0 | Latest stable resolved. |
| `file_picker` (dependencies) | `^11.0.2` | `^11.0.3` | 11.0.3 | 13.1.0 | Pinned Chat pubspec ^11.0.2; media/file picker paths call FilePicker.pickFiles. v13 cannot intersect its constraint. |
| `video_compress` (dependencies) | `^3.1.4` | `^3.1.4` | 3.1.4 | 3.1.4 | Latest stable resolved. |
| `video_player` (dependencies) | `^2.13.0` | `^2.14.0` | 2.14.0 | 2.14.0 | Latest stable resolved. |
| `pro_image_editor` (dependencies) | `^13.2.3` | `^13.5.0` | 13.5.0 | 14.4.1 | Pinned Chat ^13.2.3; media editor opens ProImageEditor with v13 configs/callbacks. v14 cannot intersect the source constraint. |
| `open_filex` (dependencies) | `^4.6.0` | `^4.7.0` | 4.7.0 | 4.7.0 | Latest stable resolved. |
| `share_plus` (dependencies) | `^12.0.1` | `^12.0.2` | 12.0.2 | 13.3.0 | Pinned Chat ^12.0.1; chat share/export paths use SharePlus/ShareParams. v13 cannot intersect that constraint. |
| `local_auth` (dependencies) | `^3.0.1` | `^3.0.2` | 3.0.2 | 3.0.2 | Latest stable resolved. |
| `local_auth_android` (dependencies) | `^2.0.9` | `^2.2.0` | 2.2.0 | 2.2.0 | Latest stable resolved. |
| `local_auth_darwin` (dependencies) | `^2.0.3` | `^2.0.4` | 2.0.4 | 2.0.4 | Latest stable resolved. |
| `permission_handler` (dependencies) | `^12.0.1` | `^12.0.3` | 12.0.3 | 13.0.2 | Pinned Chat ^12.0.1; Chat permission/push/media services use Permission.*. v13 cannot intersect that constraint. |
| `aes_crypt_null_safe` (dependencies) | `^3.0.0` | `^3.1.1` | 3.1.1 | 3.1.1 | Latest stable resolved. |
| `google_sign_in` (dependencies) | `^7.2.0` | `^7.2.0` | 7.2.0 | 7.2.0 | Latest stable resolved. |
| `sign_in_with_apple` (dependencies) | `^8.1.0` | `^8.2.0` | 8.2.0 | 8.2.0 | Latest stable resolved. |
| `pinput` (dependencies) | `^6.0.2` | `^6.0.2` | 6.0.2 | 6.0.2 | Latest stable resolved. |
| `device_info_plus` (dependencies) | `^12.3.0` | `^12.4.0` | 12.4.0 | 13.2.0 | v13 requires win32 ^6.0.x; Chat file_picker 11/share_plus 12 and secure-storage Windows 4.1 require win32 5. Joint package_info/device upgrades cannot bypass those pinned Chat/native callers. cap-device_info_plus.log. |
| `package_info_plus` (dependencies) | `^9.0.0` | `^9.0.1` | 9.0.1 | 10.2.1 | reown_core 1.5.1 / walletconnect_pay 1.1.0 constrain package_info_plus >=8.1.2 <10; Chat geolocator_linux 0.2.4 and wakelock_plus 1.5.2 need ^9; v10 win32 ^6 also conflicts with Chat file_picker 11/share_plus 12. cap-package_info_plus.log. |
| `flutter_local_notifications` (dependencies) | `^22.2.0` | `^22.3.1` | 22.3.1 | 22.3.1 | Latest stable resolved. |
| `flutter_new_badger` (dependencies) | `^2.0.0` | `^2.0.0` | 2.0.0 | 2.0.0 | Latest stable resolved. |
| `app_links` (dependencies) | `^7.2.1` | `^7.2.1` | 7.2.1 | 7.2.1 | Latest stable resolved. |
| `rate_us_on_store` (dependencies) | `^0.0.4` | `^0.0.4` | 0.0.4 | 0.0.4 | Latest stable resolved. |
| `in_app_purchase` (dependencies) | `^3.2.0` | `^3.3.1` | 3.3.1 | 3.3.1 | Latest stable resolved. |
| `firebase_core` (dependencies) | `^4.5.0` | `^4.15.0` | 4.15.0 | 4.15.0 | Latest stable resolved. |
| `firebase_messaging` (dependencies) | `^16.1.2` | `>=16.5.0 <16.6.0` | 16.5.0 | 16.7.0 | 16.5.0 is the latest stable compatible with the fixed Chat getPermissionStatus switch: 16.6+ requires platform_interface ^4.10.0. Official registry manifests and SHA-verified enum archives are in messaging-archive-audit.json. |
| `firebase_messaging_platform_interface` (dependencies) | `transitive` | `>=4.9.3 <4.10.0` | 4.9.3 | 4.10.0 | Direct compatibility bound >=4.9.3 <4.10.0 prevents caret ranges in Firebase packages from adding AuthorizationStatus.deniedPermanently, missing from Chat firebase_push_service.dart:getPermissionStatus at the fixed Git SHA. 4.9.3 is the latest compatible stable. Prior attribution of that enum to 4.9.2 was incorrect; official/cache source proves it first appears in 4.10.0. |
| `firebase_crashlytics` (dependencies) | `^5.0.8` | `^5.4.0` | 5.4.0 | 5.4.0 | Latest stable resolved. |
| `firebase_analytics` (dependencies) | `^12.1.3` | `^12.6.0` | 12.6.0 | 12.6.0 | Latest stable resolved. |
| `go_router` (dependencies) | `^17.0.0` | `^17.5.0` | 17.5.0 | 18.0.1 | Pinned Chat pubspec ^17.0.0; Chat navigation consumes GoRouter/GoRoute. v18 has no intersecting source constraint. |
| `dartz` (dependencies) | `^0.10.1` | `^0.10.1` | 0.10.1 | 0.10.1 | Latest stable resolved. |
| `equatable` (dependencies) | `^2.0.7` | `^2.1.0` | 2.1.0 | 3.0.0 | Pinned Chat pubspec ^2.0.7; Chat entities and BLoC state classes extend Equatable. |
| `freezed_annotation` (dependencies) | `^3.1.0` | `^3.1.0` | 3.1.0 | 3.1.0 | Latest stable resolved. |
| `livekit_client` (dependencies) | `^2.13.0` | `^2.13.0` | 2.13.0 | 2.13.0 | Latest stable resolved. |
| `get_it` (dependencies) | `^9.2.1` | `^9.3.0` | 9.3.0 | 9.3.0 | Latest stable resolved. |
| `flutter_callkit_incoming` (dependencies) | `3.0.0` | `3.0.0` | 3.0.0 | 3.1.6 | Pinned Chat explicitly requires >=3.0.0 <3.1.0. call_notification_service.dart constructs CallKitParams(textAccept:, textDecline:) and uses old Event names; 3.1 moved fields into AndroidParams. Keep exact 3.0.0 until upstream migrates. |
| `flutter_vodozemac` (dependencies) | `^0.6.0` | `^0.6.0` | 0.6.0 | 0.8.1 | Pinned Chat ^0.6.0; matrix 6.2 encryption binds vodozemac 0.5 / flutter_rust_bridge exact 2.11.1 native ABI. 0.8 is outside that upstream contract. |
| `google_mlkit_face_detection` (dependencies) | `^0.14.0` | `^0.14.0` | 0.14.0 | 0.15.1 | Pinned Chat ^0.14.0; core/utils/face_blur_util.dart uses FaceDetector.processImage. 0.15 changes the graph outside the pinned source contract. |
| `google_mlkit_text_recognition` (dependencies) | `^0.16.0` | `^0.16.0` | 0.16.0 | 0.17.1 | Pinned Chat ^0.16.0; core/services/mlkit_image_text_recognition_service.dart consumes TextRecognizer.processImage. 0.17 cannot intersect the constraint. |
| `google_mlkit_translation` (dependencies) | `^0.14.0` | `^0.14.0` | 0.14.0 | 0.15.1 | Pinned Chat ^0.14.0; core/services/on_device_translation_service.dart consumes OnDeviceTranslator/TranslateLanguage. 0.15 cannot intersect the constraint. |
| `flutter_background` (dependencies) | `^1.3.1` | `^1.3.1` | 1.3.1 | 1.3.1 | Latest stable resolved. |
| `image_picker_platform_interface` (dev_dependencies) | `^2.11.1` | `^2.11.1` | 2.11.1 | 2.11.1 | Latest stable resolved. |
| `path_provider_platform_interface` (dev_dependencies) | `^2.1.2` | `^2.1.3` | 2.1.3 | 2.1.3 | Latest stable resolved. |
| `sqlcipher_flutter_libs` (dev_dependencies) | `^0.6.4` | `^0.6.8` | 0.6.8 | 0.7.0+eol | Pinned Chat ^0.6.4 and sqlite3 ^2.4.0; archive_database.dart uses NativeDatabase/sqlcipher_export for encrypted-history migration. 0.7.0+eol is outside its constraint and belongs to sqlite3 v3 migration. |
| `sqlite3` (dev_dependencies) | `^2.4.0` | `^2.9.4` | 2.9.4 | 3.6.0 | Pinned Chat ^2.4.0, matrix 6.2 ^2.1.0 and drift 2.31 ^2.6.0; encrypted archive NativeDatabase/sqlcipher_export and MatrixSdkDatabase require the existing graph. |
| `flutter_lints` (dev_dependencies) | `^6.0.0` | `^6.0.0` | 6.0.0 | 6.0.0 | Latest stable resolved. |
| `build_runner` (dev_dependencies) | `^2.11.1` | `^2.15.1` | 2.15.1 | 2.16.1 | Flutter 3.44.8 pins meta 1.18.0; build_runner >=2.15.2 requires analyzer >=13.3, whose meta ^1.18.3 is incompatible. cap-build_runner.log. |
| `json_serializable` (dev_dependencies) | `^6.9.5` | `^6.14.1` | 6.14.1 | 6.14.1 | Latest stable resolved. |
| `freezed` (dev_dependencies) | `>=3.2.0 <3.2.6` | `>=3.2.0 <3.2.6` | 3.2.5 | 4.0.2 | Stable 3.2.5 is the newest release supporting Dart 3.12.2. All stable 4.x need Dart >=3.13. 3.2.6-dev.1 was rejected as prerelease. Stable 3.2.5 requires analyzer >=9 <11. cap-freezed.log. |
| `intl_utils` (dev_dependencies) | `^2.8.13` | `^2.8.14` | 2.8.14 | 2.8.16 | Stable Freezed 3.2.5 needs analyzer <11; intl_utils 2.8.15 requires >=11 and 2.8.16 ^13. Keep 2.8.14 for intl_utils:generate. cap-intl_utils.log. |
| `mockito` (dev_dependencies) | `^5.6.3` | `^5.6.4` | 5.6.4 | 5.8.1 | 5.7.0 requires analyzer ^13, incompatible with stable Freezed analyzer <11; 5.8 requires analyzer >=13.3 and meta ^1.18.3 beyond Flutter pin. Root keeps 5.6.4; standalone WebView uses compatible 5.7.0 without Freezed. |
| `mocktail` (dev_dependencies) | `^1.0.3` | `^1.0.5` | 1.0.5 | 1.0.5 | Latest stable resolved. |
| `vodozemac` (dev_dependencies) | `^0.5.0` | `^0.5.0` | 0.5.0 | 0.8.0 | flutter_vodozemac 0.6.0 requires vodozemac ^0.5.0 and its FRB native ABI exact 2.11.1; test native library setup must match production encryption. |
| `bloc_test` (dev_dependencies) | `^10.0.0` | `^10.0.0` | 10.0.0 | 10.0.0 | Latest stable resolved. |
| `sqflite_common_ffi` (dev_dependencies) | `^2.3.4` | `^2.3.7+1` | 2.3.7+1 | 2.4.3 | 2.4.3 requires sqlite3 >=3.1.2; pinned Chat, matrix 6, and drift 2.31 require sqlite3 2.x. Tests use databaseFactoryFfi with the production-compatible SQLite ABI. cap-sqflite_common_ffi.log. |
| `webview_flutter_platform_interface` (dev_dependencies) | `^2.15.1` | `^2.15.1` | 2.15.1 | 2.15.1 | Latest stable resolved. |

## SDK/Git/path contracts

- Flutter SDK packages remain Flutter 3.44.8 / Dart 3.12.2, including flutter_test/integration_test pin sets. No prerelease appears in the final root lock.
- n42_chat remains Git ref and resolved-ref 3cc19c12a7c9bbf2031270acca8e3922730b55a5. No code in the cache, mirror, or external repository was changed.
- flutter_mining remains plugins/flutter_mining, local version 0.0.1; plugin_platform_interface raised to ^2.1.8; its example uses cupertino_icons ^1.0.9 and flutter_lints ^6.0.0. Native Kotlin 2.2.20, AGP 8.11.1, Java 21, compileSdk 36, minSdk 24 and mobile-sdk-module/evm-module AAR references are unchanged.
- n42_jmt_verify keeps blake3_dart exactly 1.0.0 (latest stable: 1.0.0); test raised to ^1.32.0. BLAKE3 pin is the explicit security requirement, not a solver workaround.
- audioplayers_darwin path override updates to upstream 6.5.0; upstream actual Swift is unchanged from 6.4.0. Local iOS >=27 registration guard is preserved byte-for-byte. Its platform interface is ^7.2.0; flutter_lints ^6.0.0 matches its existing analysis_options instead of unused flame_lint. Removed upstream monorepo resolution: workspace so this vendored package resolves standalone.
- webview_flutter_wkwebview path override updates to upstream 3.26.1, latest stable. Pigeon exact 29.0.4 keeps generated Swift/Dart reproducible and preserves the NSNull crash fix through generated isNullish. Standalone build_runner 2.15.1 / mockito 5.7.0 are capped by Flutter meta 1.18.0 (analyzer 13.0.0 works; >=13.1 requires newer meta). Other production dependencies use latest SDK-compatible meta 1.18.0, path 1.9.1, platform interface 2.15.1. Example path_provider is 2.1.6 and leak_tracker is 11.0.2.
- All four overrides remain present: audio path, WebView path, flutter_secure_storage ^10.3.4, flutter_facebook_auth exact 7.2.0 (latest stable). No additional override was removed. Facebook exact pin remains an audited override as directed.
