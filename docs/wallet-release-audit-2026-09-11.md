# Wallet audit release — 2026-09-11

Release target: `master`, as corrected by the user. The existing remote default is
also `master`; no `main` branch is created or made the default.

## Changes included

This release consolidates the previously uncommitted wallet audit batches:
transaction history filtering/export, DEX and bridge execution guards, Solana
transaction handling, security setup and signing warnings, WalletConnect session
management, compact home asset rows, five-minute automatic price refresh, partial
quote/stale states, aggregate stablecoin details, and startup deep-link delivery.
Per-batch implementation, UI screenshots and physical-device evidence remain in
`docs/wallet-*-2026-09-10.md`, `docs/*followup-2026-09-11.md`, and
`docs/device-test-reports/`.

Final review additionally fixed:

- Startup registers the deep-link handler before awaiting the platform initial
  link, so a later unknown link cannot overwrite a pending valid navigation.
  A consumed manual intent still takes precedence over an older platform initial
  link. Initialization errors log only the exception type.
- Aggregated ERC-20 balances reject values wider than uint256 while preserving
  exact integer handling through the maximum valid balance.
- The IPA helper accepts `--dart-define-from-file PATH`, preserving paths with
  spaces and rejecting unreadable files before changing the version. Release
  credentials remain local and are not committed or printed.

The localization review also fills missing wallet resources and connects 147 new
message keys to wallet, backup, CSV, perps, email and hardware flows. It fixes
narrow-screen overflow in limit-order selection and CSV validation. The Chat
pin advances to `fa08010e34e5e558b7fd592e5f7c1fce84cd21d7`, fixing missing SSO
translations and malformed placeholders that affected red-packet details.
See [localization findings and remaining source literals](localization-audit-2026-09-11.md).
The reported home/Chat bottom-navigation issue was withdrawn by the user; no home
bottom-navigation fix is included.

## Validation

- Focused Flutter regressions: 66 passed, including four new boundary cases.
- `flutter analyze --no-fatal-infos`: exit 0, 0 errors, 0 warnings, 145 infos.
- Swap backend: `go test ./...` and `go vet ./...` passed.
- Python script regressions: 15 passed; feature wiring inventory check passed.
- IPA helper: shell syntax, private argument forwarding, missing-file failure and
  `--no-bump` version preservation passed an isolated stub check.
- Added-file credential scan found only the public RFC TOTP test vector; no local
  credentials, provisioning files or keystores are included.
- Complete Flutter suite: **4,111 passed in 3m33s**. LCOV: **58,930/130,685 lines (45.09%)**, across 914 files. See [full coverage report](testing/coverage-release-2026-09-11.md).

The full-suite gain includes execution of generated localization resources; it
should not be read as equivalent growth in transaction/signing coverage. The
module report keeps those business-code scopes separate. Localized screenshot
font setup was refined afterward and all 8 screenshot tests passed again without
changing production code.

The first complete-suite attempt hit the shell's 256-file-descriptor limit and
was interrupted. It is not counted as a successful run. The final run raises the
process limit to 4096 and uses `--concurrency=4` with unchanged app sources.

## Release and remaining scope

The commit hook increments the canonical build number once. Build with
`bash scripts/build_ipa.sh --no-bump --dart-define-from-file <local-private-file>`.
The archive and uploaded bundle must retain that version; the upload export uses
`manageAppVersionAndBuildNumber=false`. Local acceptance checks cover bundle and
extension versions, App Store signature, production push entitlement, disabled
debug entitlement and SQLCipher linkage. Upload receipt is saved separately under
ignored `build/ios/testflight-validation/`; this document is not evidence that
Apple has accepted or finished processing the upload.

Full-project coverage remains below the unchanged 70% CI threshold. Passing tests
and static analysis do not mean that the coverage gate is green. Hardware signer
integration, a complete on-chain approval/revocation center, group-mining/full-node
navigation, on-chain prediction and in-app Sui payment acceptance still have gaps
recorded in earlier audits. Previous device evidence applies to its recorded
source hashes; this final review does not relabel it as a new device run. No
mainnet transaction is broadcast as part of this release.
