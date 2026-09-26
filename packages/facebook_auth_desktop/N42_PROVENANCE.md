# Maintained facebook_auth_desktop 2.1.3

Upstream archive: https://pub.dev/api/archives/facebook_auth_desktop-2.1.3.tar.gz

SHA256: `9fcde1146914e9f46497d2b6053ea5865828b576a258be4e0193635f52176712`.
`UPSTREAM_SHA256.json` records original archive source hashes.

All published Dart runtime, macOS Swift runtime, podspec and MIT LICENSE are
retained. The published package contains no PrivacyInfo.xcprivacy file; this patch
does not invent privacy declarations. The Apple release audit is a separate gate.

Changes: raise the flutter_secure_storage constraint from ^10.3.1 to ^11.2.0 only
after tests against the real maintained 11.2.0 Dart implementation pass; add focused
login/read/logout/cancellation compatibility tests. Flutter 3.47 adds analyzer
exclusions for platform/build directories. OAuth/native source is unchanged.

Tests exercise the published login flow with a simulated platform redirect and
HTTP profile response. They use flutter_secure_storage's upstream test backend,
so these establish Dart API and CRUD/logout compatibility, not a real Facebook
OAuth session or macOS Keychain runtime proof. No network account or real token is
used. Native Apple builds remain Task14, store/privacy auditing remains Task16.

For standalone tests, create an ignored pubspec_overrides.yaml selecting
../flutter_secure_storage, then run flutter pub get, flutter test and flutter analyze
--no-fatal-infos. Production consumers must use the reviewed immutable Git source
with package subpaths; they must not use the test path override.
