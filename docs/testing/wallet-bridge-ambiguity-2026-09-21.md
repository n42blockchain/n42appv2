# Wallet bridge ambiguity verification — 2026-09-21

## Scope

The legacy `N42WalletBridge.requestTransfer` symbol lookup now enumerates all
matching `CoinModel` records before sender resolution. Zero matches retain the
existing not-found error, one match retains dispatch behavior, and multiple
records fail with instructions to select a network and asset explicitly.

## Regression coverage

`test/features/wallet/n42_wallet_bridge_rejection_test.dart` covers:

- case-insensitive same-symbol matches on multiple networks;
- stable rejection after reversing wallet record order;
- no preference for a funded record over a zero-balance record;
- rejection before derivation-path lookup, sender resolution, RPC, or signing;
- one record matching both `coinType` and `miniName` counts once and continues
  into the existing single-match path;
- existing disconnected, invalid-amount, zero-match, and single-match rejection behavior.

## Command

```sh
flutter test --no-pub test/features/wallet/n42_wallet_bridge_rejection_test.dart test/features/wallet/n42_wallet_bridge_test.dart --reporter expanded
```

Result: **24 tests passed**.

Focused analysis also passed:

```sh
flutter analyze --no-pub lib/features/wallet/n42_wallet_bridge.dart test/features/wallet/n42_wallet_bridge_rejection_test.dart
```

## Upstream integration

Rebased the unpushed fix onto colleague commit `d7b89fb0e` (wallet-list/add-wallet sheet UI). The final fix commit is `9c32edc55`. No overlap with transfer selection or dependency changes; preserved upstream UI edits. The 24 passing focused tests cover transfer behavior, not native acceptance of the upstream wallet sheets.
