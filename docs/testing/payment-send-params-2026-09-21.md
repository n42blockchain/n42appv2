# Payment send-parameter adapter — 2026-09-21

## Scope

`WalletPaymentSendParamsAdapter` is a pure boundary adapter for EVM payments.
It re-resolves `PaymentAmount.asset.id` against the current wallet inventory and
returns inert `SendParams`. It does not perform RPC calls, read keys, authorize,
sign, broadcast, or connect to UI state.

The returned parameters must be dispatched directly to `EvmSender`. They must
not be passed through a coin-type-based `SenderFactory`, because a cached sender
may carry configuration for a different network.

`SendParams.amount` is retained only as an approximate legacy display value.
Transaction semantics come from exactly one `BigInt` field:

- native asset: `valueWeiOverride`
- ERC-20 asset: `tokenValueWeiOverride`

No symbol lookup or decimal conversion is used.

## Fail-closed checks

- Unique EIP-155 network/contract identity is resolved from current coins.
- Wallet precision is an exact integer from `decimals`/`decimal`; conflicting
  aliases, mismatch with `PaymentAsset.decimals`, and values outside 0–255 fail.
- Units must be positive uint256.
- Sender, expected sender, recipient, and token contract are non-zero 20-byte
  EVM addresses. Expected and selected sender must match case-insensitively.
- Imported-key coins are rejected; `privateKey` is always null in the result.
- Derivation paths are full-match BIP-32-style paths. Each component and the
  selected index must fit 31 bits; index zero still replaces the final segment.
- Mainnet/testnet chain ID, RPC, and contract use only the selected side. There
  is no mainnet fallback for testnet.
- RPC must be an explicit HTTP(S) URL without credentials or a fragment.
- `chainConfig` is an immutable allowlist snapshot. Unknown metadata, nested
  objects, and key material are not propagated. Its chain ID and RPC are
  checked through `EvmSender`'s own resolvers before return.

## Verification

```text
flutter test test/features/payments/data/wallet_payment_send_params_test.dart
flutter analyze --no-fatal-infos \
  lib/features/payments/data/wallet_payment_send_params.dart \
  test/features/payments/data/wallet_payment_send_params_test.dart
```

The focused suite covers native and ERC-20 exact overrides, selected testnet
configuration, immutable snapshots, source-map mutation, secret exclusion,
precision conflicts, uint256 bounds, address binding, imported-key rejection,
derivation bounds, chain-ID bounds, and RPC validation.

Result: **10 tests passed**; targeted analysis found no issues and diff check passed. No RPC, key retrieval, signing, broadcasting, full-suite coverage measurement, or device acceptance was performed.

## Final RPC boundary follow-up

The worker added empty-user-info and invalid-port cases after its first passing report. The final combined source exposed one failure: Dart normalizes `https://@host` to an authority without `@`. The parent reproduced it, added a check against the original authority before URI parsing, and reran the complete 10-test adapter file successfully. Final targeted analysis reported no issues. Evidence: `/tmp/n42-send-params-final.log` (failure), `/tmp/n42-send-params-final-fixed.log` (10 passed), `/tmp/n42-send-params-final-analyze.log`.
