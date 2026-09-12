# Device retry and recovery — 2026-09-12

## Verified results

- Android overwrite installation returned `Success`; the normal application launched. The user logged into Chat afterwards. Read-only inspection reached the real Profile AI Assistant and Sticker Store pages, then returned to Messages. No messages were sent or credentials entered by the agent.
- Both development certificates remained valid but signing from the agent's Background session returned `errSecInternalComponent`; security logs identified `CSSMERR_CSP_NO_USER_INTERACTION`.
- In GUI Terminal, the same signing identity successfully signed a temporary executable, and keychain settings returned `no-timeout`. This confirms the execution-context problem; the earlier assumption that the user needed to unlock the keychain was incorrect. [Apple DTS guidance](https://developer.apple.com/forums/thread/712005) explicitly distinguishes GUI and background security contexts.
- iPhone Xcode compilation and signing succeeded. The first driver connection reset before tests completed. A retry from GUI Terminal using `--disable-dds` passed the single UI acceptance scenario plus framework teardown (`+2`, `All tests passed`, exit 0), producing eight screenshots. This is local fixture acceptance, not real message delivery or configured AI/GIF service validation.

## App removal incident and mitigation

The successful invocation omitted `--keep-app-running`. Flutter 3.44.8 calls `driverService.stop()` in this case; its implementation stops **and uninstalls** the app. The verbose log explicitly records `devicectl device uninstall app` and `App uninstalled` on iPhone. This was an unintended consequence of the test command, and it was disclosed to the user.

The normal app was reinstalled. Local app-container data cannot be assumed to survive that removal. Inspection of the replacement preferences showed that `flutter.n42_keychain_initialized` was absent. Since `lib/main.dart` clears the `n42wallet_prefs` keychain namespace on first initialization, further launches were paused. The existing replacement preferences were retained locally, only the initialization flag was set to true, and the on-device plist was read back to confirm it. This prevents the normal first-install cleanup path when that flag is observed; it does not recover removed app-container files or prove that earlier keychain data is intact. No wallet private keys or mnemonics were read or exported.

The user subsequently confirmed successful Chat login on iPhone. Current Chat login is restored on both phones; this does not establish preservation of earlier chat history or wallet data. Wallet and historical Chat data continuity on iPhone remains unverified. The user's newly established Android Chat session remains separate and was preserved during this retry.

## Prevention

- `scripts/run_chat_device_acceptance.sh` explicitly uses `--keep-app-running` and rejects `--no-keep-app-running` / `--keep-app-running=false` before invoking Flutter.
- The existing `PUBLISH_PORT=1` drive branch in `scripts/run_automated_tests.sh` now also retains the application.
- New shell-command regressions execute these scripts against a fake Flutter binary, checking argument preservation, invalid requests, and both drive paths. Together with the existing quality gate: 10 passed.
- Test fixtures still replace the app entrypoint, so finish by overwriting with the normal app. Prefer a standalone AOT build for a phone that should remain usable after the debugger disconnects.
- The existing `flutter test` integration path has a separate `uninstallApp` option; no unconditional uninstall call was inferred from the `flutter drive` behavior.

## Normal app restoration

The normal `lib/main.dart` Profile build (build 2026072643) compiled and installed successfully; `flutter run --profile --no-resident --disable-dds` returned exit 0. After tool exit, devicectl confirmed the main Runner process was still running. The initialized preference was read back as true after launch, and the temporary preference copies were removed. This confirms normal-app restoration and the flag, not the survival of previous wallet or Chat data; the user has confirmed current Chat login, while wallet and historical-data confirmation remains pending.
