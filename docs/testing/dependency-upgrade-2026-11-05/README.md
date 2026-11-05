# Dependency upgrade acceptance — 2026-11-05

Base: `c389ea0b4d53af71d14cad9d9961b7282b6b8a2e`. This report covers the wallet
repository and its immutable Chat Git dependency. Existing untracked plans and
`packages/n42_chat` were preserved.

## Upgrades

| Area | Before | After |
| --- | --- | --- |
| Flutter / Dart | 3.47.5 / 3.13.4 | 3.47.8 / 3.13.7; CI aligned |
| WalletCore Android / iOS | 4.8.4 | 4.8.7 |
| Android toolchain | AGP 8.13.2 / Gradle 8.14.4 / Kotlin 2.4.20 | 9.5.1 / 9.6.0 / 2.4.21 |
| Matrix / Vodozemac | 13 / 0.8 | 15 / 0.9 |
| Firebase Dart | Core 4 / Messaging 16 / Analytics 12 / Crashlytics 5 | 5 / 17 / 13 / 6 |
| Secure storage | hosted 10.3.4 | reviewed migration-compatible Git 11.2.0 |
| WebKit plugin | 3.26.1 | 3.27.2; local changes preserved |
| Equatable / Image / Archive | 2.1 / 4.10.1 / 4.3 | 3.0 / 4.12 / 4.6 |
| Go backends | mixed 1.22 / 1.26 | 1.26.10; Docker builders aligned |

110 Dart package versions changed; see `dart-version-changes.json`. Rust locks,
mobile native binaries, Go modules, and extension dependencies were also updated.
macOS minimum deployment target is now 12.0, as required and migrated by Flutter.
Android's existing legacy Kotlin/DSL compatibility flags remain necessary for
third-party plugins; builds use the current AGP without dropping those plugins.

## Compatibility fixes

- WalletCore 4.8.7 is not on CocoaPods trunk. Local podspecs keep existing pod
  identities, download official release XCFramework assets, and enforce SHA-256
  checksums from the release's generated `Package.swift`. Both installed slices
  and both packaged iOS framework binaries match those official release assets.
  Framework Info.plist reports 1.0, so provenance uses release hashes, not that field.
- Secure storage keeps the verified project fork at immutable commit
  `9733aa21eb7e4fa98c2aa8a287ef9588960023c2`. Wallet/preferences use separate
  versioned import namespaces and prefixes, disable reset-on-error, and retain
  existing iOS Keychain accounts/accessibility. Published upstream v11 without
  these import adapters is not substituted. New tests inspect actual options.
- Analytics 13.0.1 pins a native Analytics 12.19.3 version absent from official
  CocoaPods Specs. A small local patch uses official Analytics 12.19.x while
  retaining Core 12.19.3. Runtime sources match the verified official archive.
- Latest video_thumbnail still calls jcenter(), removed in Gradle 9. A local
  build patch selects Maven Central/current AGP; runtime logic is unchanged
  (published trailing whitespace is normalized).
  Its obsolete test binding/channel was corrected and both APIs are tested.
- Solana native test tooling now loads installed 4.8.7 binaries, never cached
  4.8.4 build products. Unknown future raw-message variants fail closed.
- The Solana sender fake accepts the actual production encoding argument.
- Chat migration tests open a real SQLite schema-11 fixture through Matrix 15,
  preserve direct trust/key lists, last Olm message, account/session/history
  data, and verify reopen idempotence. Existing native Vodozemac tests also
  decrypt older encrypted pickles and continue Megolm sessions.
- A gallery test's fixed 100 ms wait timed out under the full concurrent run.
  It now waits for actual deletion/persistence; its complete 11-case file passes.

## Validation

Wallet full suite: **6,248 passed, 0 skipped**. Chat full suite: **7,753 passed, 4 skipped**.
Coverage: **72.40%**, above the 70% gate. Both full runners exit 0.
Final counts and artifact checks are recorded in `test-results.json`.
Android APK builds successfully; all 50 checked 64-bit ELF libraries and the
16 KiB ZIP alignment check pass. WalletCore AAR retains all four prior ABIs. This does not prove execution on a 16 KiB device.

- iOS full debug device build without code signing: passed on Xcode 27.1 / Swift 6.4. This compiles all
  native wallet handlers against 4.8.7 and packages the official binaries.
- macOS full debug build: passed after dependency resolution and the required
  deployment-target migration. Initial direct Xcode invocation lacked Flutter's
  generated input lists; the standard Flutter build generates them and succeeds.
- Android Kotlin compile and Mining JVM unit test: passed (657 tasks, 1 JVM test).
- WalletCore simulator: original Solana legacy/v0/co-signatures, 595 truncated
  prefixes, malformed/non-signer inputs, ordinary SOL/SPL, BIP-39 ETH/BTC vectors,
  keystore round trip/wrong password and rejection of invalid scrypt dklen pass.
- WebKit: 164 tests and analyzer pass. Firebase Analytics vendor: 12 tests pass.
  Video thumbnail vendor: 2 tests pass. Mining Flutter plugin: 11 tests pass.
- Rust: PQ 1 and MLS 6 tests pass; rebuilt iOS device/simulator and all four Android
  ABIs. All rebuilt 64-bit Rust ELF libraries have 16 KiB load alignment.
  MLS strict Clippy passes. PQ Clippy passes with 10 existing style/safety-doc
  warnings; a strict `-D warnings` invocation exposes those warnings.
- All four Go modules: tests, vet, Linux static builds and vulnerability scans.
  OpenPGP module advisory GO-2026-5932 was cleared with its published fix commit.
- Extension: lint, type check, 5 tests, production build, npm audit 0 vulnerabilities.
- Wallet and resolved Chat localization audit passes; no baseline was weakened.

## Explicit holds and unresolved boundaries

- Web3Auth 8 is SPM-only on iOS. A real full build fails on missing Web3Auth and
  FetchNodeDetails modules under this app's validated CocoaPods setup. Keep
  7.0.1 and its existing MFA behavior until a separately validated SPM migration.
- Flutter pins test_api 0.7.12, constraining test/analyzer and generators.
  Do not force the incompatible analyzer/build_runner/freezed/source_gen stack.
- Cupertino Icons 2 is blocked by current Chewie constraints; cross_file 0.4,
  qr 4, sdp_transform 0.4, built_collection 6 and package_config 3 remain blocked
  by their maintained consumers. material_color_utilities is Flutter-pinned.
- objective_c 9.6.3 requires unpublished code_assets 2.2.0-wip; the solver rejects
  it. Keep 9.6.2. TypeScript 7 conflicts with typescript-eslint's peer range;
  extension keeps the latest compatible TypeScript 6 without forcing peers.
- Rust audit is **not clean**: existing crypto-bigint timing advisory plus two
  optional libcrux-kem advisories remain constrained by the stable MLS provider.
  libcrux-kem is absent from the selected target dependency tree. The current
  MLS engine uses X25519/ChaCha20/Ed25519, but this is not grounds to erase the
  compiled provider's bigint advisory. Patched-version solver probes fail.
  Falcon/PQClean and one macro dependency also have maintenance warnings.
  See `security-audit-summary.json`; no consensus/signature format was replaced.
- Windows plugin metadata still warns about Facebook desktop registration;
  Windows and Linux desktop application builds are not accepted by this run.
- Physical-device installed-wallet migration, live social/MPC login, push,
  real relay/homeserver traffic and on-chain transactions are not accepted here.
  The user previously deferred real-device acceptance. Builds and local tests
  do not prove those external flows. No store upload or production deployment
  is part of this dependency-upgrade acceptance.

Primary references: [WalletCore release](https://github.com/trustwallet/wallet-core/releases/tag/4.8.7),
[AGP compatibility](https://developer.android.com/build/releases/agp-9-5-0-release-notes),
[Flutter Kotlin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin).

Final Chat Git pin: `4ec1cd8cf45002835627586d4d7eca954bc86296` on
`chore/dependency-upgrade-20261105`. Its runtime and manifest Git trees match
the full-suite revision; only regression tests and acceptance records changed.
The host resolves this exact immutable commit and passes enforced lock resolution.
