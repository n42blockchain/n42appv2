# Isolated Apple native acceptance

This fixture uses its own bundle ID and only synthetic temporary databases/Keychain accounts. It never installs or launches the wallet application. The two fixture assets come unchanged from reviewed Chat `e71e59ea3ab33fa0c0681baebe4ab38ece019014`; archive SHA-256 is `cf488c02d1c00c519f5d20e57ae68b4122165b2e0d57b797bd5029242e9a5821`. The public raw archive key is64 `a` characters. The legacy Vodozemac0.5 fixture contains fictional keys and history.

Use Flutter3.47.5/Dart3.13.4 and Xcode27. The local Podfiles select the same maintained SQLCipher4.19 source/settings as the host; iOS calls the host's existing Vodozemac static-to-dynamic wrapper script. The default Vodozemac loader exercises this packaged output, not a pub-cache dylib. Firebase12.19.0 uses synthetic options with Analytics/Crashlytics collection and Messaging auto-init disabled before initialization. No real project or notification token is used.

```sh
cd tools/apple_native_smoke/harness
flutter pub get
flutter test integration_test/native_smoke_test.dart integration_test/firebase_test.dart -d <isolated-ios-simulator-id>
flutter test integration_test/native_smoke_test.dart integration_test/firebase_test.dart -d macos
N42_APPLE_FRAMEWORKS='/absolute/path/N42 Chat.app/Contents/Frameworks' flutter test test/host_release_abi_test.dart
python3 ../verify_host_sqlcipher.py '/absolute/path/N42 Chat.app'
```

For a changed local SQLCipher podspec, run `pod update SQLCipher --no-repo-update` in both native directories before the tests; CocoaPods can otherwise retain the same-version cached spec. Database tests cover both real FFI/FMDB routes, new writes, restart reads, wrong/missing keys, old4.10 ciphertext, plaintext export, Matrix plaintext schema, SQLite session APIs, Vodozemac FRB handshake, old0.5 account/history pickles and continuing encryption. The host-release tests separately load the exact final app binaries.

macOS data-protection Keychain requires development/distribution provisioning; the unsigned/ad-hoc fixture explicitly skips that test. iOS simulator Keychain tests cannot establish macOS signed-app accessibility, device lock/unlock behavior, or existing production account migration. The fixture writes three isolated account names and deletes only its own unique keys. Final signed-device acceptance remains a release task.

The Firebase probe proves local initialization and collection-disabled method calls only. It does not prove delivery, APNs receipt, or coverage of the known Firebase12.19.2 Analytics crash fix. The default Firebase app cannot be deleted by FlutterFire; dispose of this fixture's simulator/container after use. Do not remove another application's data.
