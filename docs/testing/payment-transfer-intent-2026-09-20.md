# P10a: ERC-20 transfer construction parameters — 2026-09-20

## Implementation

Files:

- `lib/features/payments/domain/payment_transfer_intent.dart`
- `test/features/payments/domain/payment_transfer_intent_test.dart`

`PaymentTransferIntent.prepare` is an immutable, dependency-free domain constructor built on `PaymentAssetId` and `PaymentAmount`. The caller must explicitly supply the expected EIP-155 network and token contract; they must match the selected amount's asset identity. Native assets and other namespaces are rejected.

The constructor rejects the zero token contract even when expected and selected identities match, and validates a nonzero 20-byte EVM recipient, positive amount no larger than uint256, non-negative token/native balances and fee, sufficient token balance, sufficient native fee balance, and a fee quote whose `expiresAt` is strictly after the injected `now`. Equality with expiry is expired. EVM case and decimal chain reference normalization use the established asset ID rules.

Output contains namespace, network, exact `BigInt` chain ID, token contract destination (`to`), normalized recipient, amount, exact calldata (`a9059cbb` plus 32-byte padded address and uint256 words), zero native call value, quoted fee, UTC expiry and UTC preparation time. No floating-point conversion occurs.

## Validation

```sh
flutter test --no-pub test/features/payments/domain/payment_transfer_intent_test.dart --reporter expanded
dart analyze lib/features/payments/domain/payment_transfer_intent.dart test/features/payments/domain/payment_transfer_intent_test.dart
```

**12 tests passed; targeted analysis found no issues.** Coverage includes known complete ABI bytes, same-symbol wrong-chain rejection, wrong contract, matching zero contract rejection, native/non-EVM rejection, equivalent case/chain spelling, malformed and zero recipient, six/eighteen decimal smallest units, very large integers and uint256 maximum/overflow, exact/insufficient balances and fees, negative snapshots, and expiry boundary/timezone equivalence.

Logs: `/tmp/n42-payment-transfer-intent-tests.log`, `/tmp/n42-payment-transfer-intent-analyze.log`.

## Boundaries

This object contains **construction parameters, not signing authorization**. It does not fetch or attest balances, verify the account owning them, authenticate a quote, establish token authenticity/ERC-20 behavior, check address checksums, simulate execution, estimate gas, select a nonce, sign, or broadcast. The expected asset and precision must come from a reviewed registry and the snapshots/quote from a trusted account-scoped caller. Fee sufficiency is against the supplied quote only; it is not a promise of the eventual network fee.

Construction-time freshness does not remain valid indefinitely: before signing, the integration must revalidate quote expiry, balances, network/account identity, simulation and final gas parameters, and obtain explicit user authorization. Existing wallet bridges and production payment flows remain untouched. No RPC, provider credentials, network account or real/testnet funds were used.

Proposed independent commit: `feat: prepare validated ERC-20 transfer intents`, containing the source, its test, and this evidence report. The coordinating agent reviews and commits; the worker creates no commit.
