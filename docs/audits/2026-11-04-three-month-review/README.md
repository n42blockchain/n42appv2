# Three-month code audit — batch 1

Scope: N42 wallet, 2026-08-04 through 2026-11-04. Baseline `6a9bc5a11`.
Git inventory: 658 commits, 751 distinct source paths across lib/plugins/ios/android/scripts. This inventory is not a claim that every file has received semantic review.

## Confirmed and fixed

- FalconVault.sign retained a caller-owned mutable digest across secure-storage awaits. A caller could change the digest after requesting a signature. A regression failed before the fix and passed after it. Snapshot the digest before the first await. This is an API trust-boundary issue; no UI exploit or asset loss was demonstrated.
- BatchTransferProvider.items exposed its mutable recipient list. External list edits could bypass cached totals and quote invalidation. Return an unmodifiable list; immutable recipient/amount fields remain intact. A regression checks attempted external edits and retained totals. No observed asset loss.

## Evidence

- Real native Falcon/network, transfer serialization, RPC endpoint suites: 56 passed, N42_PQ_LIBRARY explicitly supplied.
- Batch transfer, address-book account isolation, wallet account isolation, WalletConnect signing: 35 passed.
- Whole-repository Flutter analyze --no-pub --no-fatal-infos: no errors/warnings; 57 info diagnostics.
- Logs: /tmp/n42-audit-falcon-before.log, /tmp/n42-audit-falcon-after.log, /tmp/n42-audit-wallet-tests.log, /tmp/n42-audit-analyze.log.
- Existing untracked plans and packages/n42_chat were preserved. The git n42_chat dependency, not that untracked directory, is the application dependency.

## Remaining review

This is an incomplete audit. Continue with transaction signing/broadcast state across account/network switches, amount/decimals/calldata agreement, AA/hardware wallet permissions, browser/deep-link authorization, chat host/session isolation, native mining lifecycle, dependency/native build boundaries and release artifact identity. No new device or production acceptance and no new release upload were performed by this audit batch.
