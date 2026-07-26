# 2026-06-28 Scan-To-Pay

## Scope

Task T12: complete EIP-681 scan-to-pay by switching to the requested chain/token
and prefilling amount using BigInt-safe smallest-unit conversion.

## Implementation

- Added `ScanToPayResolver` in
  `lib/features/wallet/pages/send/scan_to_pay_utils.dart`.
- Resolved ERC-20 requests by `chainId + contractAddress`.
- Resolved native EVM requests by `chainId`.
- Converted `value` / `uint256` from smallest units to decimal strings without
  using `double`.
- Updated `WalletChainSend.scanQR()`:
  - plain addresses keep the old behavior;
  - EIP-681 for the current asset fills recipient + amount;
  - EIP-681 for another wallet asset replaces the send page with that asset
    and carries recipient + amount forward;
  - missing token/chain does not guess and does not prefill.
- Updated the address picker sheet's default scan path to resolve EIP-681
  recipient instead of placing the full URI into the address field.

## Verification

| Check | Result | Notes |
|---|---:|---|
| `flutter analyze --no-fatal-infos` | PASS | No issues found. |
| `flutter test test/features/wallet/eip681_test.dart test/features/wallet/scan_to_pay_utils_test.dart --no-pub` | PASS | Covers EIP-681 parse, recipient resolution, ERC-20/native matching, missing-token no-guess, and BigInt decimal formatting. |
| `flutter build apk --debug --target-platform android-arm64 --no-pub` | PASS | Android compile verified. |
| `flutter build ios --debug --no-codesign --no-pub` | PASS | iOS device compile verified. |

## Device Runtime

Cross-device scan/sign/send was NOT RUN.

Reason: this flow requires two installed devices, an unlocked wallet, a known
test recipient, and testnet/native or ERC-20 funds. The connected Android device
blocked debug install with `INSTALL_FAILED_USER_RESTRICTED: Install canceled by
user`, and no transfer target/test asset confirmation was provided in this
session.

## Pending Runtime Matrix

| Scenario | Expected |
|---|---|
| A device shows ERC-20 receive QR with amount | QR is `ethereum:<token>@<chainId>/transfer?address=...&uint256=...`. |
| B device scans QR from a different current token | Send page switches to requested chain + token. |
| B device scans QR | Recipient, token, chain, and decimal amount are all prefilled. |
| B signs/sends on testnet | Transaction submits successfully. |
| Requested token not in wallet | User sees an error and no unsafe amount guess occurs. |

## 2026-07-01 Android Retest

See `2026-07-01-missed-install-runtime.md` for the full retest log.

| Scenario | Runtime Result | Notes |
|---|---:|---|
| Scanner entry | PASS | QR scanner page opened and camera preview was reached. |
| Receive QR source | BLOCKED | Receive flow was blocked by the seed phrase backup modal. |
| Cross-device EIP-681 handoff | BLOCKED | Still requires a second installed/logged-in device, backed-up wallet, recipient, and test funds. |
