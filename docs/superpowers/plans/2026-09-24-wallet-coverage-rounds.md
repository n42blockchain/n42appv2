# Wallet Coverage Rounds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Add behavior-level coverage for account-scoped wallet persistence, cross-chain asset discovery, and mnemonic import validation, then refresh the CI-style aggregate coverage evidence.

**Architecture:** Keep tests on production paths. Exercise wallet persistence through the real `WalletActionProvider` and in-memory secure storage; give `WalletCoinAddAll` an optional `TokenViewApi` injection point so its real search and network-selection UI can use synthetic responses; drive `ImportOne` with test-only platform-channel responses and a fake wallet lookup. Run one focused suite per round and one full coverage run after all three.

**Tech Stack:** Flutter, Dart, `flutter_test`, Riverpod, `flutter_secure_storage` test platform, and the existing `TokenViewApi` / `Trustdart` interfaces.

**Spec:** `docs/plans/ACTIVE_TASKS.md` — COV-01 and the next planned wallet asset/import/export interaction work.

## Global Constraints

- Preserve the CI line-coverage command and 70% threshold; do not exclude sources or mix diagnostic views into the reported percentage.
- Keep all wallet phrases, addresses, balances, and API responses synthetic and in memory; do not use real credentials, clipboard data, networks, or funds.
- Do not edit generated files, dependency declarations, the Chat mirror, or signing/release configuration.
- Keep the three functional rounds in separate English Conventional Commit subjects; include the repository's automatic `pubspec.yaml` build-number bump when each commit hook creates it.
- Do not claim full-suite coverage until the final full run has `done.success=true` and its LCOV archive is hash-verified.

## Review Focus

- If the active authenticated account has no stored wallet entry, no anonymous or prior account wallet may be loaded or moved into that account.
- Saving a wallet for the active account must preserve every other account's existing record.
- Asset search must filter by both token text and the selected chain; API error results must leave loading state.
- Mnemonic input must normalize whitespace/case before validation, reject invalid and duplicate phrases, and keep test clipboard access isolated.
- A delayed mnemonic-validation result must not update a disposed import page.

## Tasks

### Task 1: Account-scoped wallet persistence

**Files:**
- Create: `test/features/wallet/provider/wallet_action_provider_account_isolation_test.dart`
- Read/Exercise: `lib/features/wallet/provider/wallet_action_provider_wallet.dart`

**Interfaces:**
- Consumes: `WalletActionProvider.getWalletInfo`, `saveWalletInfoOrThrow`, `AppGlobals.userInfo`, and secure-storage platform interface.
- Produces: A real-provider regression test proving a new authenticated account does not inherit the stored `AstranetWallet` entry and that creating its first wallet preserves the older record.

- [x] **Step 1: Write the regression test first.** Seed in-memory secure storage with a test-only `AstranetWallet` record named `Wallet from previous account`; set `AppGlobals.userInfo` to `UserInfo(uuid: 'synthetic-new-account')`; mock `trustdart.generateMnemonic` to return `synthetic alpha beta gamma delta epsilon`; hold `buildwallet = true` so `addWalletInfo` cannot start wallet/network initialization. Call `getWalletInfo()` and assert the current wallet is named `Account1`, its UUID is `synthetic-new-account`, the old record remains under `AstranetWallet`, and the new record is stored under `synthetic-new-account`.

```dart
test('new account creates its own wallet without migrating the anonymous wallet', () async {
  await store.getWalletInfo();
  expect(store.walletInfoLsit.single.walletName, 'Account1');
  expect(store.walletInfoLsit.single.walletUuid, 'new-account');
  expect(decoded['AstranetWallet']['wallet'].single['walletName'], 'previous-account-wallet');
  expect(decoded['new-account']['wallet'].single['walletName'], 'Account1');
});
```

- [x] **Step 2: Prove the test catches the old behavior.** Temporarily restored the previous fallback that copies `walletAll['AstranetWallet']` into the authenticated account; the focused test failed because the loaded wallet was `Wallet from previous account`. Restored the current production implementation.

Run: `flutter test --no-pub test/features/wallet/provider/wallet_action_provider_account_isolation_test.dart`
Expected: RED under the temporary legacy fallback; GREEN after restoring current behavior.

- [x] **Step 3: Run formatting, focused analysis, and the focused suite.** `dart format --output=none --set-exit-if-changed`, `dart analyze`, and the focused suite all pass. Production behavior stayed unchanged; the test calls the real secure-storage and wallet-provider path.

Run: `dart format --output=none --set-exit-if-changed test/features/wallet/provider/wallet_action_provider_account_isolation_test.dart && dart analyze test/features/wallet/provider/wallet_action_provider_account_isolation_test.dart && flutter test --no-pub test/features/wallet/provider/wallet_action_provider_account_isolation_test.dart`
Expected: formatter unchanged, analyzer clean, and every account-isolation assertion passes.

- [ ] **Step 4: Commit.** Commit the test and this plan with subject `test: cover account-scoped wallet persistence`.

### Task 2: Cross-chain asset discovery interactions

**Files:**
- Modify: `lib/features/wallet/pages/add_token/wallet_coin_add_all.dart`
- Modify: `lib/features/wallet/pages/add_token/wallet_coin_add_all_data.dart`
- Create: `test/features/wallet/pages/add_token/wallet_coin_add_all_interaction_test.dart`

**Interfaces:**
- Consumes: `WalletCoinAddAll`, `TokenViewApi.getChainListAll`, `WalletActionProvider.walletMap`, and the localized network picker/search UI.
- Produces: An optional `TokenViewApi` constructor injection used by tests; the default remains `TokenViewApi()` in production. Tests exercise real response parsing, token search, and selected-chain filtering.

- [ ] **Step 1: Write widget tests against the intended injected API.** Return synthetic Ethereum and Solana chain rows, each with a `USDC` contract token. Assert the page shows both `USDC` results on the all-networks view, selecting Solana leaves only the Solana result, and an API error leaves the page out of loading state and displays the returned error. Assert no add/remove provider mutation occurs in these search-only scenarios.

```dart
await tester.pumpWidget(wrapForTest(
  WalletCoinAddAll('USDC', tokenViewApi: fakeApi),
  overrides: [wapBridgeProvider.overrideWith((ref) => fakeWalletStore)],
));
await tester.pumpAndSettle();
expect(find.text('USDC'), findsNWidgets(2));
// Choose the Solana row in the network sheet, then verify only one result remains.
expect(fakeApi.calls, 1);
```

- [ ] **Step 2: Run the new focused suite before implementation.** Confirm the test cannot compile because `WalletCoinAddAll` does not yet accept a `TokenViewApi` injection; this identifies the missing test seam.

Run: `flutter test --no-pub test/features/wallet/pages/add_token/wallet_coin_add_all_interaction_test.dart`
Expected: RED with the missing named constructor parameter, before any production edit.

- [ ] **Step 3: Add the smallest injection seam.** Add optional `TokenViewApi? tokenViewApi` to `WalletCoinAddAll`; keep the existing call sites source-compatible; have state use `widget.tokenViewApi ?? TokenViewApi()` for `getChainList`. Do not change filtering, parsing, mutation, or error behavior to satisfy tests.

- [ ] **Step 4: Run formatting, analysis, and the focused widget suite.**

Run: `dart format --output=none --set-exit-if-changed lib/features/wallet/pages/add_token/wallet_coin_add_all.dart test/features/wallet/pages/add_token/wallet_coin_add_all_interaction_test.dart && dart analyze lib/features/wallet/pages/add_token/wallet_coin_add_all.dart test/features/wallet/pages/add_token/wallet_coin_add_all_interaction_test.dart && flutter test --no-pub test/features/wallet/pages/add_token/wallet_coin_add_all_interaction_test.dart`
Expected: formatter unchanged, analyzer clean, and search/network/error assertions pass without external HTTP.

- [ ] **Step 5: Commit.** `git add lib/features/wallet/pages/add_token/wallet_coin_add_all.dart test/features/wallet/pages/add_token/wallet_coin_add_all_interaction_test.dart && git commit -m "test: cover cross-chain asset discovery"`.

### Task 3: Mnemonic import validation

**Files:**
- Modify: `lib/features/wallet/pages/create_wallet/import/import_one.dart`
- Create: `test/features/wallet/pages/create_wallet/import/import_one_interaction_test.dart`
- Read/Exercise: `lib/features/wallet/pages/create_wallet/import/import_one.dart`

**Interfaces:**
- Consumes: `ImportOne`, the `trustdart` `checkMnemonic` method channel, clipboard platform channel, `WalletActionProvider.findWallet`, and `wrapForTest`.
- Produces: Widget tests for normalized manual input, synthetic clipboard import, invalid-phrase refusal, duplicate-wallet refusal, and late validation after route disposal.

- [ ] **Step 1: Write tests first using only synthetic phrase text.** Mock clipboard get/set and `trustdart.checkMnemonic`; capture every validation request; use a fake wallet lookup that can return a synthetic existing wallet. Include tabs and newlines in manual and clipboard text. Assert all whitespace is collapsed and text is lowercased before validation, invalid phrases remain on the page, duplicate phrases are refused without opening `CreatePassword`, clipboard text is normalized before display, and a delayed result after pop causes no framework exception.

```dart
const rawPhrase = 'Synthetic\tTEST\nphrase';
await tester.enterText(find.byType(TextField), rawPhrase);
await tester.tap(find.text(S.current.g_key_11));
await tester.pumpAndSettle();
expect(validationRequests.single, 'synthetic test phrase');
expect(find.byType(ImportOne), findsOneWidget);
```

- [ ] **Step 2: Run the focused suite.**

Run: `flutter test --no-pub test/features/wallet/pages/create_wallet/import/import_one_interaction_test.dart`
Expected: The initial newline/tab normalization assertion fails because the current implementation splits on literal spaces only; after replacing that split with `RegExp(r'\s+')`, all input, refusal, clipboard, and disposal assertions pass with platform calls mocked in memory.

- [ ] **Step 3: Normalize every whitespace run before mnemonic validation.** Replace `value.trim().split(" ")` in `checkInput` with `value.trim().split(RegExp(r'\s+'))`, discard empty tokens, then join with one ASCII space and lowercase. This keeps manual entry and clipboard entry on the same canonicalization path.

```dart
final words = value.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
setState(() => inputMW = words.join(' ').toLowerCase());
```

- [ ] **Step 4: Run formatting and focused analysis.**

Run: `dart format --output=none --set-exit-if-changed lib/features/wallet/pages/create_wallet/import/import_one.dart test/features/wallet/pages/create_wallet/import/import_one_interaction_test.dart && dart analyze lib/features/wallet/pages/create_wallet/import/import_one.dart test/features/wallet/pages/create_wallet/import/import_one_interaction_test.dart && flutter test --no-pub test/features/wallet/pages/create_wallet/import/import_one_interaction_test.dart`
Expected: formatter unchanged, analyzer clean, and the import suite passes.

- [ ] **Step 5: Commit.** `git add lib/features/wallet/pages/create_wallet/import/import_one.dart test/features/wallet/pages/create_wallet/import/import_one_interaction_test.dart && git commit -m "test: cover mnemonic import validation"`.

### Final coverage measurement

- [ ] Run `ulimit -n 4096; flutter test --no-pub --coverage --concurrency=4 --machine` after all three commits; require `done.success=true`, zero visible failures/skips, and record hidden events separately from visible tests.
- [ ] Measure raw LCOV totals and per-file deltas for all touched wallet sources; gzip the exact `coverage/lcov.info`; verify decompression equality and raw/archive SHA-256 values.
- [ ] Update `docs/testing/coverage-expansion-2026-09-24/README.md`, `summary.json`, and the COV-01 row plus a new entry in `docs/plans/ACTIVE_TASKS.md`. Keep the 70% task open unless the measured original CI denominator reaches the threshold.
- [ ] Commit only the report, archive, and plan updates with an English subject after a fresh whole-branch review.
