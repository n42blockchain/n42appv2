# Worktree cleanup and merge review — 2026-11-01

Scope: linked worktrees owned by `n42appv2`. Other repositories were not cleaned.

## Completed

- Worktree registrations: 96 before, 13 after.
- Pruned 70 records whose directories no longer exist. Before pruning, retained
  five otherwise unreferenced, unmerged commit tips under
  `refs/archive/worktrees/20261101/`.
- Removed 13 old worktree directories: 11 duplicate/completed trees listed
  below, plus `n42appv2-t30` and `n42appv2-t30-handoff` after integration.
  The new temporary integration tree was also removed after validation.
- Kept local branches and remote branches. No force removal, force push or
  removal of unique local source changes was used.
- Three apparently dirty trees contained only changes already identical to
  master. Their tracked/untracked state was first saved as stash-shaped
  archive references, then the clean trees were removed.
- Preserved ignored coverage/configuration files for retired trees. Preserved
  T30's four historical APK paths as two deduplicated APK artifacts, with
  SHA-256 and original-path manifests. Historical APKs are provenance records,
  not the new merged build.

Local archive: `../.worktree-archives/20261101-n42appv2/`. It contains before/after
inventories, removed-tree manifests, configurations, APKs and verification logs.
It is outside this repository and was not pushed.

## Removed duplicate trees

- `n42-staking-provider-coverage-20261002`: all local changes match master.
- `n42appv2-algo-send-preflight-coverage-20261002`: patch-equivalent commits in master.
- `n42appv2-btc-send-coverage-20261002`: patch-equivalent commits in master.
- `n42appv2-ens-confirm-dialog-coverage-20261002`: patch-equivalent commits in master.
- `n42appv2-ens-management-coverage-20261002`: all local changes match master.
- `n42appv2-hw-accounts-coverage-20261002`: test content already in master.
- `n42appv2-market-shared-widgets-coverage-20261002`: patch-equivalent commits in master.
- `n42appv2-mining-v2-provider-actions-20261002`: patch-equivalent commits in master.
- `n42appv2-prediction-card-coverage-20261002`: test content already in master.
- `n42appv2-wallet-base-send-coverage-20261002`: all local changes match master.
- `n42appv2-wallet-security-sections-20261002`: patch-equivalent commits in master.

## Integrated

`feat/mining-v3-ui@d350588f5` descends directly from the prior
`master@b4712fb30`. It was integrated with
`origin/feat/mining-v3-mobileverify@24df062c2`, rather than keeping the older
SDK binary from the UI branch. Both AAR copies match that upstream build:

```
SHA-256 9f73082d2107e5390658d6f56600a1e119bc5f7f0d4af68f0601c11c8af0821a
```

Merge `22a8ef318` combines the UI and SDK. Merge `6d6437324` retains the latest
`origin/codex-n42@689f4968d` task/handoff record, including the T30 SDK response.
The only merge conflicts were version lines in `pubspec.yaml`; newer build
numbers and the current dependency graph were preserved. The existing Chat
pin, Falcon support and October 31 QA fixes are retained.

Fresh validation in the isolated integration tree:

- 123 app/widget tests passed: mining version migration/settings, V3
  activity/engine/dashboard, shared design widgets, address book, backup,
  mnemonic layout and security verification.
- 10 Flutter mining plugin tests passed.
- Changed-area analysis: no errors or warnings; four pre-existing
  initializing-formal style infos.
- Android JDK 21 Gradle tasks `:flutter_mining:compileDebugKotlin` and
  `:flutter_mining:processDebugManifest`: BUILD SUCCESSFUL.

Android V3 remains an explicit selection; the existing V1/V2 choice is
preserved and the default remains V2. iOS does not acquire a V3 bridge from
this merge. The prior device reports describe their original APKs. No device
was installed, no miner was started, and no production package was published
by this review. The new SDK's native private-input logging recheck on a device,
long background endurance and reward-payment acceptance remain separate.

## Retained for review

| Tree / branch | Finding | Decision |
|---|---|---|
| `n42appv2-main-flow-audit-20261006` | Three signing/account-binding commits; conflict in `chain_sender.dart`, `wallet_chain_send_logic.dart`, wallet storage and dependency files. | Keep. Split and revalidate against current signing and wallet behavior; no wholesale merge. |
| `n42appv2_test_audit_20261004` | Production phishing fix already matches master; four test files conflict with newer tests. | Keep for selective test reconciliation. |
| `n42appv2-dependency-completion` | 114 unique commits, roughly 1,942 changed files, native/dependency/archive work. | Keep as a separate migration; not a cleanup merge. |
| `n42appv2-coverage-70` | 58 unique commits, 83 changed files; includes CI/backend edits and changes inside `packages/n42_chat`. | Keep. Separate useful tests and port Chat changes through the formal Chat repository before integration. |
| `n42appv2-ui-token-baseline` | Detached historical UI baseline with many patch-equivalent and unique commits. | Keep as a reference snapshot; do not overwrite current source with it. |

Seven other old worktrees retain unique uncommitted source, tests or coverage
records. Their heads and working/index status were checked unchanged:

- `n42appv2-chain-send-logic-coverage-20261002`
- `n42appv2-chat-init-coverage-20261002`
- `n42appv2-coverage-20261002`
- `n42appv2-coverage-snapshot-20261002`
- `n42appv2-max-xrp-coverage`
- `n42appv2-qr-protocol-remediation-20260924`
- `n42appv2-wallet-coverage-20260924`

The primary checkout's pre-existing untracked plans and `packages/n42_chat`
mirror were retained unchanged.

## Recovery example

The three saved local-state references are listed in `removed-worktrees.json`.
For example, restore the former staking tree into a new location with:

```sh
git worktree add /tmp/n42-staking-restore test/staking-provider-coverage-20261002
git -C /tmp/n42-staking-restore stash apply --index refs/archive/worktrees/20261101/n42-staking-provider-coverage-20261002-local
```
