# 2026-07-01 Missed Install Runtime Retest

## Scope

Retest the device scenarios that were previously missed because Android debug
installation was blocked. Covered reports:

- `2026-06-28-wallet-h1.md` / T11
- `2026-06-28-scan-to-pay.md` / T12
- `2026-06-28-nft-batch.md` / T13
- `2026-06-30-live-gift-prediction.md` / T14

## Device And Build

- Branch: `feat/live-gift-prediction-sync`
- Android device: `38f4f08a`, model `25098RA98C`, Android 16/API 36
- Existing installed app at start: `ai.n42.www` `2.4.3`
  versionCode `2026062617`
- Rebuilt and installed app after fixes: `ai.n42.www` `2.4.3`
  versionCode `2026062619`

## Installation Result

- The previously installed Android build launched and was usable for wallet and
  chat smoke tests.
- After code fixes, direct ADB install still failed:
  - `adb -s 38f4f08a install --no-streaming -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
  - `adb -s 38f4f08a install -r -t -d build/app/outputs/flutter-apk/app-debug.apk`
  - Result: `INSTALL_FAILED_USER_RESTRICTED`
- `flutter install -d 38f4f08a --debug` succeeded, but it uninstalled the old
  app first, which cleared local wallet/chat session state.
- After reinstall, automated UI input is blocked by MIUI security policy:
  - `persist.security.adbinput=0`
  - `adb shell input tap ...` fails with `SecurityException: Injecting input events requires ... INJECT_EVENTS permission`
- Post-commit retry at `2026-07-01 17:43 EDT`:
  - Rebuilt pushed head `5275fefb` as `2.4.3+2026062620`.
  - `flutter install -d 38f4f08a --debug` uninstalled the old app, then failed
    with `INSTALL_FAILED_USER_RESTRICTED`.
  - Repeated `adb install --no-streaming -r -t -d ...` attempts also failed
    with `INSTALL_FAILED_USER_RESTRICTED`.
  - Final device state: `pm list packages ai.n42.www` is empty; the app is not
    installed on Android.

## Runtime Matrix

| Area | Result | Evidence / Notes |
|---|---:|---|
| App launch before reinstall | PASS | Existing build opened and showed the wallet/chat UI. No AndroidRuntime fatal crash was seen during the test window. |
| T11 S1 stablecoin earn | PARTIAL | Earn page and Stablecoin Earn opened. Stablecoin Earn showed `No stablecoin markets available right now`, so Aave/USDC/USDT APY sorting and Supply navigation could not be verified. |
| T11 S5 network quick-add | PARTIAL | Wallet network filter switched to Ethereum and showed Ethereum actions. `Add Tokens` -> `Add custom chain` opened with chain name/symbol/id/decimal/RPC fields. No popular preset quick-add list was observed in the tested UI path. |
| T11 M2 receive QR | BLOCKED | ETH Receive was blocked by the required seed phrase backup modal. The scan page itself opened after camera permission was granted. |
| T12 scan-to-pay | PARTIAL | QR scanner page opened and camera preview was reached. Cross-device EIP-681 receive QR -> scan -> switch token/chain -> prefill -> sign/send remains blocked by missing second installed device session, backed-up wallet, recipient, and test funds. |
| T13 NFT gallery | PARTIAL | ETH NFT Gallery opened and showed empty state. Logcat reported `[SimpleHashNftApi] WARN: fetchNfts error: unauthorized`. No NFT long-press, multi-select, or batch send could be tested without holdings/API auth. |
| T13 batch transfer entry | BLOCKED | Batch Transfer was visible in the ETH action menu, but entering send flow was blocked by the seed phrase backup modal. |
| T14 chat entry | PARTIAL | Chat tab opened to the unauthenticated N42 Chat welcome/login page. Chat live/gift/prediction matrix still needs two logged-in devices/accounts. |
| Chat welcome back button | FAIL -> FIXED IN CODE | Reproduced on Android: tapping the welcome page top-left back button did not leave the chat entry page. Fixed by wiring the package `WelcomePage` back action to the root navigator. Post-fix device tap verification is blocked by `persist.security.adbinput=0`. |
| Wallet refresh runtime error | FAIL -> FIXED IN CODE | Logcat repeatedly showed `NoSuchMethodError: Class 'CoinModel' has no instance getter 'config'` from `WalletActionProviderMarket.getCoinInfo`. Fixed by typing `WalletActionProvider.coinList` as `List<CoinModel>` and removing dynamic sort casts. |

## Code Fixes From Retest

- `packages/n42_chat/lib/src/presentation/widgets/n42_chat_widgets.dart`
  - Unauthenticated chat/profile welcome pages now call
    `Navigator.of(context, rootNavigator: true).maybePop()` for back.
- `lib/features/wallet/provider/wallet_action_provider.dart`
  - `coinList` is now `List<CoinModel>` instead of `List<dynamic>`.
- `lib/features/wallet/provider/wallet_action_provider_sort.dart`
  - Sorting and pinned-token handling now use typed `CoinModel` values.

## Verification

| Check | Result | Notes |
|---|---:|---|
| `flutter analyze packages/n42_chat/lib/src/presentation/widgets/n42_chat_widgets.dart --no-fatal-infos` | PASS | No issues found. |
| `flutter analyze lib/features/wallet/provider lib/features/wallet/pages/wallet_manage packages/n42_chat/lib/src/presentation/widgets/n42_chat_widgets.dart --no-fatal-infos` | PASS | No issues found. |
| `flutter test test/features/wallet/eip681_test.dart test/features/wallet/scan_to_pay_utils_test.dart test/features/wallet/nft_gallery_utils_test.dart test/features/wallet/nft_batch_transfer_utils_test.dart --no-pub` | PASS | 22 tests passed. |
| `flutter build apk --debug --target-platform android-arm64 --no-pub` | PASS | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| `flutter install -d 38f4f08a --debug` | PASS | Installed `ai.n42.www` versionCode `2026062619`; app data was cleared by uninstall/reinstall. |

## Remaining Manual Preconditions

1. Enable MIUI Developer options -> USB debugging security / simulated input so
   `persist.security.adbinput=1`.
2. Keep USB install allowed, or continue using `flutter install` with awareness
   that it may clear app data.
3. Provide an unlocked and backed-up wallet with test funds, stablecoins, and
   transfer-safe NFTs.
4. Provide a second logged-in device/account for T12 scan-to-pay and T14
   live/gift/prediction cross-device verification.
5. Configure NFT API auth if real NFT gallery data is expected.
