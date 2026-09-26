# Task14C — Apple native dependency acceptance

## Result and source identity

Apple production migration is in `5f3c62e4677c0780a0a300e7e10698f07afda38a`,
reviewed from `4eb66cc38deb4da0b84b7ee8308c2a53ec6da36c`. URI portability follow-up
`47422bdd3` preserves identical generated linker flags. Isolated fixtures and
artifact readers are in `6f1780568e47b18232490354fca4e17f088e8bb7`.
Controller scope documentation is a separate commit `aaf24dc80`.

Selected unsigned iOS and macOS builds passed. Native storage/crypto fixtures
passed with an explicit macOS Keychain skip. This is not signed-release or
physical-device acceptance. No production account, payment functionality,
physical device, TestFlight upload or global toolchain was changed.

Evidence is in [apple-native-evidence.tar.gz](apple-native-evidence.tar.gz),
with member hashes in [apple-native-evidence-sha256.json](apple-native-evidence-sha256.json).
The archive retains failed attempts and abandoned candidates; use the final
log mapping below rather than interpreting every archived attempt as accepted.

## Selected graph and source changes

| Area | Selected result |
| --- | --- |
| Toolchain | Isolated Flutter3.47.5 / Dart3.13.4; Xcode27.0 build27A266a; iPhoneOS, simulator and macOS27.0 SDKs; CocoaPods1.17.0 |
| Platforms | iOS16 app/pod floor, existing higher iOS17 target settings preserved; macOS12 in Podfile, project configurations and pod settings, preserving any higher dependency floor |
| Package manager | Existing CocoaPods graph retained; app-local SPM flag false |
| SQLCipher | Immutable official4.19.0 source commit `c4b275a47932888216bade83aff2bbc73df0ff85`, local podspec; Dart hook also4.19 |
| sqflite_sqlcipher | Maintained official3.4.1 source; only iOS/macOS podspec exact dependency4.10→4.19; runtime and Android unchanged |
| Firebase | Core/Analytics/Crashlytics/Messaging12.19.0; FlutterFire4.15.0/12.6.0/5.4.0/16.7.0 respectively; tested cap below |
| Other native constraints | GoogleMLKit9.0, FMDB2.7.12, FBSDK18.0.2, TrustWalletCore4.8.4; MediaPipeTasksGenAI0.10.24 and TensorFlow Lite nightly20250619 inherited from flutter_gemma; MLKit segmentation beta14/Xeno beta16 inherited upstream |
| Preserved behavior | Existing audio iOS27 and WebView safeguards, Vodozemac wrapper, storage account names/accessibility and target-specific settings |

[Official SQLCipher4.19 release](https://github.com/sqlcipher/sqlcipher/releases/tag/v4.19.0)
and the retained package provenance/license/hash files identify the source.
The custom podspec derives from the prior official4.10 metadata, retains its
CommonCrypto/Security provider, extensions, temp-store and EXTRA_INIT/SHUTDOWN
requirements, and enables SESSION/PREUPDATE_HOOK for sqlite3v3 APIs. It runs
upstream configure/make; generated amalgamation files are not vendored.

The Ruby helper derives all93 required SQLite symbols from the resolved
sqlite3 package, protects them from stripping, and exports them from the iOS
executable. Existing `sqlite3_key` anchor and post_integrate system-SQLite
cleanup remain. Repeated `-framework` tokens must be preserved: set-union on
an entire linker argument list was an observed failed attempt, now covered by
an idempotence regression test. Obsolete FilePicker11 framework names were
removed from the host's manual link list.

On macOS the Dart native asset and FMDB pod are separate implementations.
The CocoaPods module is named **N42SQLCipher**, avoiding a real case-insensitive
filesystem collision between `SQLCipher.framework` and `sqlcipher.framework`.
Both final files are enumerated and tested independently; an `nm` listing alone
was never considered encryption acceptance.

### Retained compatibility settings and final audit carryover

Inspection confirms the existing iOS Podfile still adds `-ld_classic` and sets
`EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64` for Runner, with a comment
about the MLKit MLImage simulator slice; pod targets retain the separate i386
exclusion. It also preserves simulator-specific MobileSdk link exclusions. These settings
were retained, not independently proven obsolete or necessary for every current
SDK. The selected unsigned device build passed with them. The isolated simulator
fixture does not include the full host MLKit/MobileSdk graph, so full-host
simulator architecture/linker acceptance remains a final integration follow-up.
Do not infer that the simulator fixture proves those host exclusions work.

Carry the inherited MediaPipe0.10.24, TensorFlow Lite nightly20250619 and MLKit
beta14/beta16 pins into the final dependency audit as upstream native constraints.
They are not described as latest stable native dependencies or independently
completed ML/runtime upgrades. Their production device behavior remains part of
final integration acceptance.

## Firebase12.19.2 migration assessment and cap

[Official Firebase Apple notes](https://firebase.google.com/support/release-notes/ios)
identify12.19.2 as SPM-only, with an Analytics unrecognized-selector crash fix;
12.19.1 has no SDK code changes.12.19.0 is the final scheduled CocoaPods release.
The notes do not label12.19.2 a security fix. The app includes Analytics, so the
fix is relevant; collection-disabled initialization does not establish that
all production Analytics paths avoid the known issue.

Published FlutterFire manifests exact-pin12.19.0, but that pin was not treated
as proof of incompatibility. A minimal maintained-source **manifest-only**
12.19.2 patch was tested. A small core/analytics plus MLKit unsigned probe built.
The full host graph, including Messaging/Crashlytics, failed with **635 duplicate
symbols**, with Flutter diagnosing GoogleDataTransport from both MLKit CocoaPods
and Firebase SPM (`logs/ios-spm-candidate-attempt2.log`). The preceding candidate
attempt first exposed stale manual framework references; its log is also retained.

Candidate pubspecs, locks, Package.swift files, source hashes/provenance and
patches are archived under `spm-candidate/`. Production candidate packages,
SPM project/scheme references and overrides were removed. No broad transport
surgery or blind native pod override was retained. The macOS SPM candidate was
stopped after the full iOS graph failure; it is not acceptance evidence.

**Removal condition:** a supported combined MLKit/Firebase integration that
resolves GoogleDataTransport once, followed by full-host unsigned builds and
native initialization/runtime regressions. Revisit with maintained upstream
SPM support or a specifically scoped native-manager migration. The present
cap retains working Firebase behavior and carries the known Analytics fix gap.

## Final artifacts (actual embedded version, before hook increments)

Both artifacts embed **2.4.8+2026072861**. Production and later test/docs commits
advance the source build number through the existing hook. No rebuild was run
solely for those increments. FinalTask15/16 must build the final selected Chat
pin, product cleanup and intended release version.

| Artifact | SHA-256 of main executable | Floor / SDK |
| --- | --- | --- |
| `build/ios/iphoneos/Runner.app/Runner` | `333f6d87a5d1b1754fc7bd6aab6d6257aa0a823384b2cb9a9c9c7ac0a5a1f881` | iOS16 / iphoneos27.0 |
| `build/macos/Build/Products/Release/N42 Chat.app/Contents/MacOS/N42 Chat` | `dae100c737b7f569736b52e0595edd8eb031ddcd3dd7726b76b5bf26a59f797e` | macOS12 / macosx27.0 |

Native identities from the actual final macOS app:

| Binary | SHA-256 |
| --- | --- |
| `N42SQLCipher.framework/N42SQLCipher` | `49784121079c95ce4988b3673257af17896644fd35e6d0821de49369498ff920` |
| `sqlcipher.framework/sqlcipher` | `6bbef6f0e3ca6a9d17133f709a5a04bb9a7de9788877694d93152bf9b2c34e6f` |
| `flutter_vodozemac.framework/flutter_vodozemac` | `c3fca0f0f0beb2016c6f8f701c94a620c74f3ae24ce495d96b3fa82c81e5ea33` |

The final iOS Vodozemac binary hash is
`9cdbf27e735c90bb584e6361cd57e4dbb5dea0f13048f88cbff52c4a1b0f332b`.
Its unchanged host build phase wraps the maintained0.8.1 plugin's source-built
Rust archive into the loadable framework. The first small fixture had omitted
that phase and failed; this was a fixture error, not a host loader defect.
The accepted fixture invokes the same host wrapper and default loader.

Full artifact architecture/dependency/signature metadata and privacy declarations
are in `logs/final-artifact-inventory.json`. The source-equivalent URI follow-up
has byte-identical linker flag output (`link-flags-before/after-uri-fix.txt`).

## Verification commands and outcomes

Commands use the isolated Flutter binary under
`~/.codex/toolchains/flutter-3.47.5/flutter/bin`, with
`XDG_CONFIG_HOME=/tmp/n42-task14c-config` and SPM disabled in that isolated config.
No signing identity was selected for the host builds.

```sh
flutter build ios --release --no-codesign --no-pub
flutter build macos --release --config-only
xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner \
  -configuration Release -sdk macosx27.0 -destination 'generic/platform=macOS' \
  -derivedDataPath build/macos CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
ruby test/scripts/apple_native_settings_test.rb
flutter analyze --no-fatal-infos
```

| Accepted check | Evidence member / result |
| --- | --- |
| iOS unsigned host | `logs/ios-selected-unsigned-final.log`, exit0; fresh staging rerun `ios-selected-clean-staging.log`, exit0 (76s) |
| macOS unsigned host | `logs/macos-selected-unsigned-retry.log`, BUILD SUCCEEDED/exit0 |
| Ruby helper | `logs/settings-uri-green.log`,4tests19assertions; relative/absolute encoded-space URI cases, repeated framework tokens and higher floors; corresponding red log retained |
| Host analysis | `logs/host-analyze-resolved-tools.log`, exit0,69infos, no errors/warnings |
| Fixture analysis | `logs/harness-analyze-final.log`, no issues |
| iOS native fixture | `logs/harness-ios-selected-final.log`, native2pass before separate failed Firebase attempt; standalone preceding accepted wrapper log `harness-ios-wrapper-attempt2.log` |
| macOS native fixture | `logs/harness-macos-selected-final.log`, native1pass/Keychain1skip before separate failed Firebase attempt; standalone `harness-macos-distinct-final.log` |
| Final Firebase local probe | `logs/harness-ios-firebase-final.log` and `harness-macos-firebase-final.log`,1pass each |
| Actual host macOS SQLCipher images | `logs/host-final-sqlcipher-runtime.log`, both providers pass |
| Actual host macOS Vodozemac | `logs/host-final-vodo-runtime.log`, legacy0.5 compatibility pass |
| Final iOS link inventory | `logs/ios-final-sqlite-symbols.json`,93/93 required symbols; runtime proof remains the simulator fixture |

The69 analyzer infos comprise19 maintained Vodozemac tool-source,10fl_chart,
3video_thumbnail and37host/tests/scripts infos. The earlier host analysis failed
because the nested Cargokit build-tool dependencies were unresolved. Running
`dart pub get` in that tool package resolved them without tracked source changes;
the failed log is retained. This count supersedes earlier47-info reports.

Fixture commands and limitations are documented in
[the fixture README](../../../tools/apple_native_smoke/harness/README.md).
Fixtures cover real FFI and FMDB cipher_version4.19, new encrypted CRUD/reopen,
wrong/missing key rejection, historical4.10 ciphertext, plaintext export,
cross-provider reads, SQLite session APIs, Matrix plaintext database behavior,
FRB initialization, old0.5 account/history pickles and continuing Megolm.
The host runtime readers load the exact final macOS framework paths, not a
pub-cache dylib. Only synthetic temporary data and isolated fixture accounts
were used.

The Firebase test uses deliberately synthetic valid-format options, disables
Analytics/Crashlytics collection and Messaging auto-init before initialization,
and exercises local methods. It proves neither production Firebase delivery,
APNs/token receipt nor the12.19.2 Analytics crash path. Initial invalid-format
options aborted inside FIRInstallations; subsequent cleanup tried unsupported
default-app deletion. Both fixture mistakes were corrected; all final probes
pass. The default app lives only in the disposable fixture container.

## Build-manager experiment cleanup and retained failures

The initial macOS selected rerun imported a leftover top-level SPM
`in_app_purchase_storekit.swiftmodule`, which referenced an absent Objective-C
module, instead of the CocoaPods framework. Generated top-level `*.swiftmodule`
directories under `build/macos/Build/Products/Release` were moved to ignored
`apple/spm-candidate/stale-macos-products`; the same command then succeeded.
No IAP source or dependency was changed. Those generated binaries are omitted
from the evidence archive; the failing diagnostic and cleanup record are retained.

The first iOS inventory still contained125 privacy files/13 frameworks because
Xcode's staging app retained candidate resources even after the destination app
was removed. After recording that inventory, only these task-generated app
outputs were removed before rerunning the selected build:

```text
build/ios/Release-iphoneos/Runner.app
build/ios/iphoneos/Runner.app
```

Final inventory has66 privacy files/9 frameworks, with the same main executable
hash. `artifact-inventory-before-ios-staging-cleanup.json` preserves the stale
state. This was an artifact-contamination rebuild, not a hook-version rebuild.
Other archived attempt logs document the missing session exports, linker-token
regression and abandoned SPM probes; none are represented as final acceptance.

## Keychain, network and privacy handoff

macOS Debug/Profile and Release entitlements now include outbound network access
and the plugin-required Keychain access-groups entry. The plugin's default
data-protection Keychain mode is preserved. Existing `n42wallet`,
`n42wallet_prefs`, default Chat/Reown account scope and
`first_unlock_this_device` values are unchanged.

The simulator fixture passes isolated three-account CRUD. macOS Keychain testing
is **explicitly skipped** because the ad-hoc fixture does not have development
provisioning for the data-protection Keychain. It does not prove signed macOS
production accessibility, old user record migration, or device lock/unlock
behavior. Do not switch to the legacy keychain to make this fixture pass.

Final inventories enumerate66 iOS and45 macOS privacy files,9 and61 loadable
frameworks, plus18 vendored XCFramework inputs in
`logs/vendor-xcframework-signature-inventory.json`. Static SDKs such as
MediaPipe/TensorFlow/TrustWalletCore are additionally represented by the resolved
pod locks and bundled resources, not necessarily standalone final frameworks.
Unsigned/ad-hoc or preserved vendor signature metadata is not distribution
signature compliance. Final release signing and SDK provenance validation remain
Task16 work under [Apple SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/).

Concrete privacy review items:

- The iOS app manifest declares tracking false, while bundled FBSDKCoreKit and
  FBSDKLoginKit manifests declare tracking true. Reconcile actual FB SDK settings,
  ATT/collection behavior and App Store answers; do not mechanically copy a SDK's
  declaration into product answers.
- App reasons include UserDefaults CA92.1, timestamps C617.1/0A2A.1, boot time35F9.1,
  disk spaceE174.1 and active keyboards3EC4.1. Presence alone does not validate
  allowed purposes against actual source behavior.
- The app declares device/crash/performance data unlinked, sensitive face,
  location and email linked, contacts/photos/audio unlinked. Reconcile authenticated
  uploads/chat and backend retention with product owners. No organizational answer
  was invented in this task.
- There is no top-level macOS app privacy manifest in this artifact inventory.
  Plugin/transitive manifests exist; review actual macOS application APIs and
  required declarations before release.
- Local flutter_mining's privacy resource-bundle declaration is commented out;
  review its MobileSdk provenance/data behavior. Missing wrapper-source manifests
  do not automatically imply missing bundled transitive SDK manifests. Vendor
  MobileSdk, WeChat, WebRTC, FBSDK, Google/MLKit, TrustWalletCore and native crypto
  need the final distribution inventory and vendor evidence reconciled.

External acceptance remaining: signed macOS Keychain and physical-device prior
account access/lock behavior; real notification/Firebase service receipt; camera,
ML/face, media, audio/WebView device flows; vendor privacy/signature and App Store
answers; finalTask15/16 integrated artifacts. Free verify points remain product
scope; no SKU/payment materials are required by this Apple task.
