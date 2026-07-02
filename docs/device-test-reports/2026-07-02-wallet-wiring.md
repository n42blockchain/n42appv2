# 2026-07-02 Wallet Wiring T15 Device Regression

## Scope

Task T15: wallet wiring large-batch end-to-end regression on
`fix/competitor-report-audit`.

Baseline:

- Branch: `fix/competitor-report-audit`
- Commit: `5b8e47b0 feat(wallet/chat): 自定义EVM链接入真实链系统 + 启用链上通知`
- Version in `pubspec.yaml`: `2.4.3+2026062617`

The task matrix covers custom EVM chains, DApp browser provider injection,
AA/UserOp, EIP-7702, staking/lending, on-chain notifications, price alerts,
perps read-only entry, Aave execution, and built-in chain regression.

## Devices

| Device | Status | Notes |
|---|---:|---|
| Android `38f4f08a` / `25098RA98C` | INSTALLED / LAUNCH SMOKE PASS | Android 16 API 36. `persist.security.adbinstall=1`, `persist.security.adbinput=0`. Installed `ai.n42.www` `2.4.3+2026062618` on retry. |
| iPhone wireless `00008150-000E2469149A401C` | BUILD/INSTALL ATTEMPTED / RUNTIME BLOCKED | iOS 27.0 `24A5370h`. Xcode build completed and entered install/launch, then Flutter could not connect to the Dart VM because macOS Local Network permission is blocked. |

## Code And Build Verification

| Check | Result | Notes |
|---|---:|---|
| `flutter pub get` | PASS | Dependencies resolved. |
| `flutter analyze --no-fatal-infos` | PASS | No issues found. |
| Targeted T15 unit tests | PASS | 309 tests passed. Covered custom chain registry, sender factory, balance RPC override, chain config, browser txHash, price/trade alert sheet utils, EIP-7702, UserOperation, gas estimator, UserOperation receipt, and staking models. |
| `flutter build apk --debug --target-platform android-arm64 --no-pub` | PASS | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| Android `adb install --no-streaming -r -t -d ...` | PASS ON RETRY | Initial T15 attempt failed with `INSTALL_FAILED_USER_RESTRICTED`; retry at `2026-07-02 02:23 EDT` succeeded. |
| Android `flutter install -d 38f4f08a --debug` | BLOCKED | Failed with the same `INSTALL_FAILED_USER_RESTRICTED` device policy. |
| `flutter build ios --debug --no-codesign --no-pub` | PASS | Built `build/ios/iphoneos/Runner.app`. |
| `flutter run -d 00008150-000E2469149A401C --debug --no-pub` | BLOCKED AFTER BUILD | Xcode build completed and install/launch started. Flutter then failed to access local network / Dart VM: `SocketException: Send failed (OS Error: No route to host, errno = 65), address = 0.0.0.0, port = 5353`. |

Targeted test command:

```text
flutter test test/features/wallet/custom_chain_registry_test.dart test/features/wallet/api/sender/sender_factory_test.dart test/features/wallet/n_testnet_balance_rpc_test.dart test/features/wallet/chain_config_test.dart test/features/wallet/browser_txhash_test.dart test/features/wallet/market/price_alert_sheet_utils_test.dart test/features/wallet/market/trade_entry_sheet_utils_test.dart test/features/aa/eip7702_handler_test.dart test/features/aa/user_operation_test.dart test/features/aa/gas_estimator_test.dart test/core/wallet/user_operation_receipt_test.dart test/features/staking/staking_model_test.dart --no-pub
```

## Runtime Matrix

Device runtime could not be completed because Android automated input is still
disabled and the iPhone debug session cannot attach after launch. Android
install/launch smoke is now PASS, but the rows below are still not full runtime
PASS.

| # | Scenario | Runtime Result | Evidence / Notes |
|---|---|---:|---|
| 1 | Custom EVM chain add + native balance | BLOCKED | Android app is not installed. Needs device install plus wallet session. |
| 2 | Custom EVM native transfer | BLOCKED | Requires installed app, wallet, funded address, custom chain RPC, and signing. |
| 3 | Custom EVM ERC-20 transfer | BLOCKED | Requires installed app, funded token, gas, and recipient. |
| 4 | Restart persistence for custom chain | BLOCKED | Requires installed app and custom chain created on device. |
| 5 | Built-in DApp browser wallet connect on Android/iOS | BLOCKED | Android install blocked. iPhone build/install started but Flutter runtime attach is blocked by macOS Local Network permission, so the DApp connect flow was not driven. |
| 6 | DApp `personal_sign` / `eth_signTypedData` | BLOCKED | Requires DApp connect runtime. |
| 7 | DApp `eth_sendTransaction` | BLOCKED | Requires DApp connect runtime and funded wallet. |
| 8 | Phishing DApp sensitive method interception | BLOCKED | Requires installed app and test phishing domain flow. |
| 9 | AA single ETH send via real UserOp | BLOCKED | Requires installed app, AA account, bundler access, wallet funds. Code-level AA/UserOp tests passed. |
| 10 | AA Paymaster unavailable guard | BLOCKED | Requires AA send page runtime. |
| 11 | EIP-7702 account creation | BLOCKED | Requires installed app and AA create page runtime. EIP-7702 unit tests passed. |
| 12 | ETH/Lido staking submit | BLOCKED | Requires installed app, funded wallet, and signing. Staking model tests passed. |
| 13 | Chat list on-chain notification bell | BLOCKED | Requires installed app and chat/wallet runtime. |
| 14 | Market price alert local notification | BLOCKED | Requires installed app, foreground wait, and price trigger. Price alert utility test passed. |
| 15 | Earn tool perps read-only entry | BLOCKED | Requires installed app runtime. |
| 16 | Aave supply flow | BLOCKED | Requires installed app, funded wallet, Aave-supported asset, approve/supply signing. |
| 17 | Built-in chain send/receive regression | PARTIAL/BLOCKED | Android wallet home opened to `Account1` and showed `Balance $0.00` with wallet actions. Send/receive transfer regression still requires manual interaction, backed-up wallet, and funded ETH/BSC/Polygon test assets. |

## 2026-07-02 Android Retry

After the initial report, Android installation was retried successfully:

- Rebuilt current branch version `2.4.3+2026062618`.
- `adb -s 38f4f08a install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk` returned `Success`.
- Installed package:
  - `versionName=2.4.3`
  - `versionCode=2026062618`
  - `firstInstallTime=2026-07-02 02:23:42`
  - `lastUpdateTime=2026-07-02 02:23:42`
- Launch via `adb shell monkey -p ai.n42.www -c android.intent.category.LAUNCHER 1` succeeded.
- `pidof ai.n42.www` returned `19707`.
- Foreground focus: `ai.n42.www/.MainActivity`.
- UI tree showed wallet home content including `Account1`, `Balance`, `$0.00`, and wallet action entries.
- Recent logcat scan found no `FATAL EXCEPTION` / app `AndroidRuntime` crash. Startup did log expected network/data warnings such as `TrxApi ... unauthorized` and balance fetch fallback messages.

Initial Android runtime blocker was `persist.security.adbinput=0`, which meant
ADB could not drive deterministic taps through the T15 UI matrix. The app is
installed and ready for manual on-device testing. A direct tap attempt confirmed
the blocker:
`adb shell input tap 100 100` fails with
`SecurityException: Injecting input events requires ... INJECT_EVENTS permission`.

Re-run after opening Developer options showed both `USB安装` and
`USB调试（安全设置）` as checked, and `persist.security.adbinput=1`; however,
after `adb reconnect` and ADB server restart, both `adb shell input keyevent
KEYCODE_BACK` and `adb shell input tap 100 100` still failed with the same
`INJECT_EVENTS` security exception. `dumpsys package com.android.shell` also
shows `android.permission.INJECT_EVENTS: granted=true`, so the remaining
blocker appears to be an OS/InputManager-layer restriction rather than the
visible Developer options switch state. `monkey` launch still works, and the
app returns to `ai.n42.www/.MainActivity`.

## 2026-07-02 Android ADB Retest

Retested after reconnecting Android device `38f4f08a` (`25098RA98C`,
Android 16 / API 36):

- Rebuilt current branch with
  `flutter build apk --debug --target-platform android-arm64 --no-pub`.
- Installed successfully with
  `adb -s 38f4f08a install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk`.
- Installed package after retest:
  - `versionName=2.4.3`
  - `versionCode=2026062618`
  - `firstInstallTime=2026-07-02 02:23:42`
  - `lastUpdateTime=2026-07-02 04:51:17`
- ADB input is now available on this connection:
  `adb shell input tap 1 1` and `adb shell input keyevent KEYCODE_WAKEUP`
  both returned success.
- Cold launch via `monkey` succeeded; foreground activity remained
  `ai.n42.www/.MainActivity`.
- Wallet home rendered `Account1`, `Balance`, `Just updated`, `Send`,
  `Receive`, `Buy`, and token rows for `N`, `BTC`, `ETH`, and `USDT`.
- Smart Wallet entry opened successfully and showed `Smart Account`,
  `Smart Accounts`, `Send`, `Batch`, `Advanced Features`, and
  `Create Smart Account`.
- Receive entry did not open the receive address because the device wallet is
  not backed up; it correctly showed the guard dialog
  `Please backup your wallet seed phrase first!`.
- Startup log initially exposed a Flutter runtime issue:
  `NoSuchMethodError: Class 'CoinModel' has no instance getter 'config'` in
  `WalletActionProviderMarket.getCoinInfo`. Root cause was `coinList` being a
  `List<dynamic>`, which made extension getter `CoinModel.config` dispatch
  dynamically inside `coinList.map(...)`.
- Fixed by typing `coinList` as `List<CoinModel>` and cleaning the now
  redundant sort casts/type checks. Also removed three redundant `?? 0.0`
  expressions in Earn that became analyzer warnings after the type tightening.
- Verification after the fix:
  - `flutter analyze --no-fatal-infos`: PASS.
  - T15 targeted wallet/AA/staking tests: PASS, 309 tests.
  - Android debug build: PASS.
  - Android reinstall and cold launch: PASS.
  - Logcat no longer shows the `CoinModel.config` NoSuchMethodError or an app
    `FATAL EXCEPTION`.

Remaining non-fatal runtime warnings observed on this device:

- Token discovery RPC/proxy calls return 401 for ETH/BASE.
- MATIC token discovery logs a response-shape cast warning:
  `type 'String' is not a subtype of type 'Map<String, dynamic>?'`.
- Some remote token images fail Android image decoding with
  `ImageDecoder$DecodeException: ... unimplemented`.

## Blockers

1. Full transfer/signing rows still require a backed-up wallet and funded test
   assets. The current device blocks receive/send entry with the seed backup
   guard, which is expected.
2. macOS Terminal/IDE does not currently have Local Network access for Flutter's
   iPhone Dart VM discovery. `flutter run` reaches install/launch, then fails on
   mDNS/port 5353 with `No route to host`.
3. Runtime asset prerequisites remain needed for full T15: backed-up/unlocked
   wallet, funded custom EVM chain address, recipient address, optional ERC-20
   on the custom chain, AA/bundler test account, DApp test pages, staking/Aave
   test funds, and price alert trigger conditions.

## Next Steps

1. On Android, continue the T15 matrix with ADB-driven navigation where possible,
   but keep transfer/signature submission manual until funded test wallets and
   recipients are confirmed.
2. On macOS, grant the terminal or IDE Local Network permission in System
   Settings -> Privacy & Security -> Local Network, then rerun:
   `flutter run -d 00008150-000E2469149A401C --debug --no-pub`.
3. After either device is controllable, run the T15 priority rows first:
   #1, #2, #5, #9, and #17.
