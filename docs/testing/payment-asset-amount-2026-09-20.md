# Payment asset and amount foundations — 2026-09-20

## PAY-P0-01: asset identity

Files:

- `lib/features/payments/domain/payment_asset.dart`
- `test/features/payments/domain/payment_asset_test.dart`

`PaymentAssetId` is an immutable value object identified by namespace, network, and contract. Display symbols do not participate in identity. Namespace is normalized to lowercase. EIP-155 network references normalize decimal leading zeroes; EVM contract addresses normalize case after 20-byte hexadecimal syntax validation. Non-EVM network and contract references preserve case. A null contract explicitly identifies the native asset and cannot collide with a contract named `native`.

`PaymentAsset` carries the ID plus display symbol and validated precision (0–255). The stable `canonicalId` is a local key, **not a CAIP identifier**. Validation checks representation, not asset authenticity, checksum validity, ownership, or payment availability. Non-EVM references have generic safe-character validation, not chain-specific address validation.

Seven tests cover same-symbol assets on different networks/contracts, EVM normalization and hash equality, case-sensitive non-EVM references, native asset separation, invalid inputs and delimiter rejection, and metadata precision boundaries.

Proposed independent commit: `feat: add immutable payment asset identity` (source and corresponding test above).

## PAY-P0-02: exact amounts

Files:

- `lib/features/payments/domain/payment_amount.dart`
- `test/features/payments/domain/payment_amount_test.dart`

`PaymentAmount` stores non-negative `BigInt` smallest units and immutable asset metadata. Parsing and formatting never use floating point. Negative values, signed values, scientific notation, whitespace, separators, malformed decimals, and excess fractional precision are rejected. Extra fractional zeroes beyond the asset precision are also rejected. Leading integer zeroes are accepted and normalized.

`format()` emits exact plain decimal text, removing insignificant fractional zeroes by default; `format(trimTrailingZeros: false)` retains the full asset scale. Zero is valid at this domain layer. Amount equality includes asset identity, precision and integer units, while ignoring display symbol changes.

Ten tests cover six-decimal values, values beyond double/JavaScript-safe integer limits, zero and zero-decimal assets, smallest units at precision 255, strict parse failures, exact formatting, identity-bound equality, and integer round-trips at precision 0/2/6/8/18/255.

Proposed independent commit after PAY-P0-01: `feat: add exact payment amount parsing` (source and corresponding test above).

## Validation

Commands:

```sh
flutter test test/features/payments/domain/payment_asset_test.dart test/features/payments/domain/payment_amount_test.dart --reporter expanded
dart analyze lib/features/payments/domain/payment_asset.dart lib/features/payments/domain/payment_amount.dart test/features/payments/domain/payment_asset_test.dart test/features/payments/domain/payment_amount_test.dart
git diff --check
```

Results: **17 tests passed**, targeted analysis found **no issues**, and diff whitespace check passed. Logs: `/tmp/n42-payment-asset-amount-tests.log` and `/tmp/n42-payment-asset-amount-analyze.log`.

Only the four domain/test files and this report are owned by this task. No third-party package imports were added to the domain implementation. No wallet bridge, UI, dependency declarations, production registry, account, signing, or financial transaction flow was changed. The worker did not create commits; the coordinating agent reviews and commits each feature separately.

## Integration limitations

- Callers must obtain decimals and accepted asset IDs from a reviewed registry. These constructors do not make arbitrary client-supplied metadata trustworthy.
- A transfer policy must separately require a positive amount and enforce chain/API limits (such as uint256), balance, fees and recipient compatibility. The mathematical amount type intentionally does not impose a universal maximum.
- Checksummed EVM display addresses and non-EVM chain validation remain separate responsibilities; case normalization here is for identity comparisons.
- The existing float/symbol-based payment paths are not migrated by these foundations. No testnet or production transfer capability is claimed.
