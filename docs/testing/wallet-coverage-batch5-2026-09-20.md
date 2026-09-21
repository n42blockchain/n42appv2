# Wallet coverage batch 5: add-network form — 2026-09-20

## Scope

New test file: `test/features/wallet/add_token/wallet_chain_add_interaction_test.dart`.

Ten widget tests mount the production `WalletChainAdd` page through a real Navigator at 390×844. This batch covers a network-add form rather than revisiting keystore flows. No production, dependencies, generated code, existing tests or coverage configuration changed.

## Behavior

- Empty name and three invalid chain IDs are rejected with the draft retained.
- Decimal precision above 18 is rejected.
- Plain HTTP RPC and explorer URLs are rejected before RPC probing.
- A new symbol cannot bypass the existing Ethereum chain ID guard; a repeated submit remains rejected.
- Selecting CELO replaces all six draft fields and clears the prior chain ID error; navigating back cancels the unsubmitted form.
- An existing-symbol confirmation can be cancelled twice without leaving the form or losing its draft, then the route can be exited.

Input tests fill chain ID before RPC, preventing focus-loss autodiscovery. Submit paths deliberately stop at validation, chain-conflict detection or cancelled confirmation; they do not exercise RPC success, signing, secure storage or persisted wallet creation. No credentials or usable keys are involved. Built-in registry data and presets are left unchanged.

## Verification

- `dart analyze test/features/wallet/add_token/wallet_chain_add_interaction_test.dart`: no issues.
- `flutter test --no-pub test/features/wallet/add_token/wallet_chain_add_interaction_test.dart`: **10 passed, 0 failed** (exit 0), run after the shared-build window was granted. Log: `/tmp/n42-wallet-batch5.log`.
- Scoped formatting and `git diff --check`: passed.

No full suite or coverage measurement was run for this batch. The previously reported **46.8233% (61,391 / 131,112)** remains the earlier full-suite measurement and does not include this batch. The 70% goal remains open.
