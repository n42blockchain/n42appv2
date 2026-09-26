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
