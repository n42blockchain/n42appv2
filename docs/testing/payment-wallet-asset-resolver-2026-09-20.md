# P10b wallet payment asset resolver evidence

## Scope

`WalletPaymentAssetResolver` performs a synchronous, local lookup from a
`PaymentAssetId` to exactly one trusted wallet `CoinModel`. It does not read a
display symbol, call RPC services, sign, broadcast, or connect an existing
payment entry point.

The current safe mapping is EIP-155 only. Explicit non-EVM and aggregated rows
in a mixed wallet are ignored. EVM inventory validation fails closed for a
missing active-network chain ID, an invalid or contradictory contract field,
or a duplicate canonical `(network, contract)` identity. Testnet records use
only `chainId_test` and `contract_test`; they never fall back to mainnet.
Chain IDs accept only positive integers or complete decimal-digit strings;
fractional, non-finite, signed, or whitespace-padded values are rejected.

## Safety boundary

The returned `CoinModel` is a resolution result, not payment authorization.
`CoinModel` is mutable. A later signing flow must resolve the requested
`PaymentAssetId` again and revalidate the active wallet, asset configuration,
balance, fee quote, expiry, and device authorization immediately before
signing.

## Verification

- Target test: `flutter test test/features/payments/data/wallet_payment_asset_resolver_test.dart`
- Formatting: `dart format lib/features/payments/data/wallet_payment_asset_resolver.dart test/features/payments/data/wallet_payment_asset_resolver_test.dart`

The target test covers native and ERC20 identities, contract case
canonicalization, same-symbol assets across networks and contracts, strict
testnet selection, mixed wallets, unsupported and absent assets, missing chain
IDs, invalid/contradictory contracts, and duplicate identities.

## Result

- `flutter test test/features/payments/data/wallet_payment_asset_resolver_test.dart`: 12 tests passed.
- `flutter analyze --no-fatal-infos lib/features/payments/data/wallet_payment_asset_resolver.dart test/features/payments/data/wallet_payment_asset_resolver_test.dart`: no issues found.
