# Recent interrupted-work reconciliation — 2026-11-06

Scope: November 3–6 wallet work, its resolved Chat branch and ID Hub; adjacent Mintus release records checked separately. This is a source/record reconciliation, not fresh device, server or store acceptance. Repeat inspection found an interrupted, uncommitted Aptos native-signing integration on top of `336ef29ad` (matching remote master). Batch 31 below closes that implementation after verification. A subsequent inspection found interrupted scheduled-message account-isolation edits; batch 36 now closes and pushes that implementation (see below); the older untracked plans and unused Chat mirror are preserved.

## Latest interruption check

- Wallet `b8ee625ad` matches freshly fetched `origin/master` (0 ahead / 0 behind). Tracked wallet sources are clean; four previously recorded untracked paths remain preserved.
- Chat task worktree `.tmp-worktrees/n42-chat-native-hub-20261106` is now clean at pushed `3ce77c7a`. The interrupted account-isolation patch is completed; the wallet pin is updated to the same source.
- The earlier run (171 passed / 2 failed) is superseded by `/tmp/n42-owner-broad-final.log`: 3,398 passed, plus four client/token-switch transport checks in `/tmp/n42-owner-session-tests.log`. Analyzer reports no errors/warnings and ten informational diagnostics. Batch 36 records scope and limitations.
- Legacy unattributed drafts remain preserved and unsent. A user-confirmed recovery flow, queued UI intent and standalone-page same-user re-login generation binding (batch 37 now guards in-flight BLoC work), cross-device/process coordination and live-server acceptance remain open in MSG-001.
- Thirteen auxiliary wallet worktrees were inspected again: seven dirty ancestor heads, five clean non-ancestor heads, one clean ancestor head. None was removed or merged by this inspection.

## Still open, in execution order

| Priority | Work | Current evidence and next step |
| --- | --- | --- |
| P0 | Native Google/Apple/Facebook acceptance | Provider clients, Hub routes, app adapters and layout are implemented. Three real Web providers passed twice with revocation. Native Google exchange is still disabled; first/repeat/cancel/account-switch native authorization, Android browser handoff and same-DID Matrix login need end-to-end acceptance. Keep distinct from Web success. |
| P0 | Meta public availability | Developer/test-account authorization passed. Data-deletion instructions/process and review/publication remain open. Do not call this public Facebook availability. |
| P1 | Three-month security audit continuation | Batch 26 now fixes Solana request-chain-to-RPC selection with 926 passing regressions. Batch 28 also binds Aptos/NEAR submission networks to approved requests (903 module tests). Remaining: other chains' routing/RPC identity validation, Android JNI serialized-signing acceptance (batch 27 implements and compiles the missing branch; 4 validation tests pass), native WC_APT acceptance (batch 31 integrates BCS validation and single-sender Ed25519 signing on both platforms; iOS component signing passes independent vectors, Android JNI/device acceptance remains open), embedded signer/message semantics, unknown-outcome recovery (Chat batch 33 fixes cancellation acknowledgement and same-BLoC queue races; batch 34 also serializes scheduled storage across same-isolate data-source instances; batch 35 adds stable retry transaction IDs and preserves unconfirmed drafts; batch 36 scopes drafts and dispatch to the active account; legacy/live/cross-device recovery remains open), AA/hardware permissions and other module review. Batches 20–23 already addressed non-EVM permission/await guards; do not repeat them as missing. All changed files have not received full semantic review. |
| P1 | Release delivery | iOS unsigned Release compile and signed Android APK passed at 2.5.3 (73133). Source advances independently through the audit commits (batch 31 follows 73141); the verified artifacts remain 73133. No new N42 TestFlight upload/processing/tester availability is proven. Rebuild from the chosen release commit before upload. Physical-device acceptance was explicitly deferred by the user. |
| P1 | UI localization completion | November 4 catalogs/placeholder/format checks passed. Chat QA-006 still records direct UI literal candidates. Notification mode controls are now localized in all 26 catalogs at Chat `6995818b`, with narrow/large-text UI regression coverage; other modules still require review, not blind translation of brands/examples. Native-speaker, RTL and expanded-text device acceptance remain separate. |
| P1 | Dependency holds | Upgrade report retains Web3Auth 7 pending validated SPM migration, Flutter/consumer-constrained packages and MLS crypto-bigint advisory/maintenance warnings. No claim that every dependency is newest or security audit clean. |
| P2 | Worktree reconciliation | 13 auxiliary wallet worktrees remain. Seven contain local changes even though HEAD is an ancestor; five clean heads are not ancestors. Only mining-v3-ios is both clean and ancestor in this snapshot. Preserve all until per-tree preservation/patch comparison completes. |

## Worktree evidence

Non-ancestor clean branches checked with `git cherry HEAD <branch>`: dependency-completion has 114 patch-unique commits; main-flow-audit 3; test-audit 1; coverage-70 58. Detached ui-token-baseline is also non-ancestor. These counts do not prove missing functionality: rewritten history, later rewrites and superseding fixes require file/behavior comparison before any merge or deletion. No worktree was removed.

Root has only the three old untracked plan files and the unused `packages/n42_chat` directory. Actual Chat dependency is immutable Git pin `d141cbc3`; its task worktree contains the unfinished nine-file account-isolation change described above. ID Hub is clean at `7c0dd68`. The later interrupted Aptos integration is recorded in batch 31; it must not be confused with a completed release. N42-rs has a modified fleet-test result file, preserved without alteration.

## Completed work that must not be reopened as missing

- November 4 localization: wallet 1,488 and Chat 1,359 missing values supplied; resource checks and formatting passed. Full wallet regression then passed 5,803 tests, coverage 72.30%.
- November 5 dependency upgrade: WalletCore 4.8.7 and toolchain/native dependencies integrated. Report records 6,248 wallet tests, 7,753 Chat tests (4 skipped), coverage 72.40%; acceptance applies to that source revision.
- November 6 login layout: compact Google/Facebook controls and real native Apple standard control implemented. Android dynamic provider-resource shrinking issue fixed. This review reran five wallet auth/config suites: 90 passed, log `/tmp/n42-social-final-regression.log`.
- Three-provider standalone Web identity login deployed and live-tested; it is not a complete browser wallet transaction application.

## Stale handoffs found

`ACTIVE_TASKS.md` still led with October 5 state. `SOCIAL_LOGIN_PLAN.md` still led with July legacy Amaze configuration and API. Both now point here and to current evidence. Their historical body is retained, not used as current deployment instructions. Chat AUTH-SOCIAL-001 also contains earlier deployment-pending text superseded by the wallet/Hub live Web records; native acceptance remains open.

## Adjacent Mintus handoff (separate product)

Repeat inspection found newer records that supersede the earlier deployment gap:

- `../minto/docs/qa/2026-11-06-web-backend-deployment.md` records staging/production deployment at `7d45167a`, Nginx follow-up `a861d2a7`, three completed migrations in both databases, healthy services and public association-file verification. The original welcome-gift deployment is therefore recorded as completed, not still missing. This inspection reads the committed evidence; it does not independently re-probe the servers.
- Superseding record `../minto/docs/qa/2026-11-06-release-3210.md` confirms staging/production Web, backend and workers deployed from `1a91f05c`, including those audit fixes and the notification-summary endpoint. The older requirements-audit release paragraph is stale. Later App-only `2b415eb0` is explicitly not included in build 3210. This check read release evidence and did not re-probe the servers.
- The per-holder lifetime interest ceiling is explicitly incomplete. Annual-rate UI is not that feature. Contract/factory/issuance/metadata/settlement/UI changes need a decision on new Tokens only versus existing-Token migration.
- Published older Android APK still needs replacement for welcome-gift acceptance. Installation does not provide automatic deferred deep linking; the documented flow requires returning to the landing page to reopen/copy the link.
- TestFlight 3210 has recorded upload acceptance, exit 0 and ASC Processing. Tester/device availability was not refreshed in this review. App-only `2b415eb0` still needs a subsequent release.
- Native-provider authorization, device links/recovery, settlement, iPad and language editorial acceptance remain separate. Explicitly deferred product requirements are not silently reactivated by this audit.

## Evidence

- [Audit batches and remaining review](../audits/2026-11-04-three-month-review/README.md)
- [Localization closeout](../audits/2026-11-04-three-month-review/localization-closeout.md)
- [Dependency upgrade and explicit holds](../testing/dependency-upgrade-2026-11-05/README.md)
- [Current social login evidence](../testing/social-login-2026-11-05/README.md)

Older IAP delivery and payment-provider plans remain historical open work; they are not newly discovered November interruptions. This reconciliation does not silently expand the current login task into those implementations.
