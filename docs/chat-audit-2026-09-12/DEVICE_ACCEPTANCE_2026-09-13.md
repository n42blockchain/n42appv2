# Chat device acceptance — 2026-09-13

Source baseline: host `f03f41e1`, Chat Git pin `58ed5f9b07277a211f84da505f6718c2716a8f86`. This pass validates the prior coverage fixes on physical ARM64 devices. Test-entrypoint changes are separate from normal application behavior.

The host now pins `657a66bb1a5a5963f6460e5cc60b305fcc272de3`. This includes the reusable SQLite test registrar and the Android media database loader fix discovered during acceptance. All 767 runtime lib/assets files match the resolved Git package. Tested application version: `2.4.8+2026072647`.

## Devices and scope

- USB Xiaomi 25098RA98C, Android 16/API 36.
- USB iPhone 13 Pro Max (iPhone14,3), iOS 26.6.2. The earlier shorthand “iPhone 13” was not an exact model label.
- Fourteen in-memory SQLite contracts cover archive/FTS and media cleanup on the device native libraries. A fifteenth contract exercises the production media database initializer with a temporary documents directory, writes metadata, closes/reopens the background connection and verifies cleanup. It never opens the normal account database.
- Three new UI scenarios cover English/Arabic poll validation and quiz scheduling, protected images/payment detail callbacks, and registration validation/error-draft/anonymous fields.
- Existing expression/GIF-unconfigured/sticker/menu/AI-unconfigured fixture remains included.
- The auth boundary is a controlled failing repository; no account is created. Text injection uses a registered test-input connection and asserts resulting controller values; this is not a native IME compatibility certification. No real message or payment is sent.

## Test-driver fixes

The prior `--keep-app-running` flag prevented post-test uninstall, but did not protect installation. The local Flutter 3.44.8 Android installer retries a failed overwrite by uninstalling and reinstalling (`android_device.dart:406`). The Chat runner now requires an existing VM-service URI. The reuseApplication path does not start/build/install the app; `--keep-app-running` remains explicit.

First iPhone execution passed the SQLite, image and original expression/menu cases, but failed the two input forms: profile mode rejected the test helper's debug-only `-1` text-input client ID, leaving fields empty. The fixture now registers a valid test connection and verifies every injected value. AuthBloc cleanup moved to test teardown so the host fake-async preflight does not wait inside a widget frame.

The reusable SQL contracts accept a registrar so device execution uses `testWidgets` and `runAsync` for real file/isolate work. This puts all fifteen SQL results in the integration binding's result map, ensuring failures reach the external driver. The final report includes nineteen named cases; framework setup/teardown is not counted as acceptance coverage.

## Android findings and fixes

After the owner enabled USB installation, the first Android run exposed a missing SQLite loader in the fixture and screenshot conversion state retained after Flutter automatically reverted the surface at each test teardown. The fixture now selects the bundled SQLCipher library on Android and resets its conversion flag at every test teardown.

Inspection also found the production media metadata connection created a background isolate without configuring its SQLCipher loader. Overrides in the archive/main isolate are not inherited. The production initializer now prepares the Android native library and supplies an isolate initializer that selects `libsqlcipher.so`. The added persistence/reopen contract exercises this exact production path. This change does not migrate or encrypt existing media metadata.

## Safe execution

Build without installation, and install only through `adb install -r -t` or `xcrun devicectl device install app`. If installation is rejected, surface that failure and wait for the device owner; never retry by uninstalling or clearing app data.

Launch the already installed fixture app and forward its VM-service port over USB, then:

```sh
FLUTTER_BIN=/path/to/flutter ./scripts/run_chat_device_acceptance.sh DEVICE_ID VM_SERVICE_URI --profile
```

The runner rejects missing connection URIs, conflicting existing-app arguments and app-stop flags before launching Flutter. Its argument behavior is covered with a fake Flutter executable. The CLI change is intentional: a device ID alone can no longer initiate installation.

Finish with a profile build of `lib/main.dart` and an explicit overwrite install. Preserve local signing and runtime proxy configuration outside Git. The iPhone container is checked using a newly created non-secret marker; no wallet keys or credentials are copied. Marker persistence verifies this container boundary only, not the completeness of historical wallet/Chat data.

## Results

- iPhone and Xiaomi: **19/19 passed on each**, comprising fifteen SQLite contracts, three added UI cases and the existing expressions/menus/RTL case. Both final drivers exited successfully and kept the apps installed for explicit restoration.
- Evidence: [iPhone results](device-2026-09-13/results.json), [Android results](device-2026-09-13/android-results.json), and twenty-four fixture screenshots with SHA-256 hashes. Only controlled fixture screens are committed; normal-account screenshots remain local.
- Normal iPhone app: explicitly overwrite-restored from the signed `lib/main.dart` build and launched successfully. Its Wallet homepage and all four bottom navigation entries are visible. A non-secret cache marker matches byte-for-byte across installation. Native accessibility inspection timed out, so post-restoration Chat login and historical data continuity are **not certified** by this pass; QA-007 remains open.
- Local checks: **36/36** host quality cases, **15/15** canonical SQL cases and **49/49** related cleanup service/storage bloc cases passed. The host sticker resource compatibility tests also passed **4/4**. No new full-suite coverage percentage is claimed for this device pass.
- Xiaomi: USB installation was enabled by the owner after four rejected attempts. Explicit overwrite installation succeeded, and the expanded suite passed after the fixes above. No Android uninstall or data clearing was performed.

- Normal Android app: the rebuilt `lib/main.dart` application was overwrite-restored and launched. The Wallet → Chat entry opens the existing logged-in conversation list. Version code is `2026072647`; `firstInstallTime` remains `2026-09-12 06:37:13`. Existing encrypted-history placeholders were already visible before this run; this check does not certify old history decryption or full data completeness.
- Final host static analysis: **0 errors, 0 warnings, 155 informational findings**. Scoped analysis of the changed canonical production/test files reports no issues.
- Host sticker compatibility: bundled OpenMoji/Lottie assets are available at the root paths used by Chat rendering/upload code. The four compatibility tests verify asset equality with the Git package, rendering and selection. Online sticker transmission was not performed.

Both normal applications are restored. The release tag is `v2.4.8-chat-device-audit-20260913`. The pre-commit hook increments the build metadata to `2026072648`; device evidence above records the actually tested and installed build `2026072647` with the same runtime source. The release certifies the scoped device regressions above, not full online messaging, remote AI/GIF configuration, chain transactions or historical account data recovery. Existing QA-006 translation and QA-007 historical data verification items remain open.
