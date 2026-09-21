# Local payment pending journal — 2026-09-20

Status: storage foundation implemented; UI/client integration remains a separate task. No commit created by this subtask.

## API

- `LocalPaymentPendingScope.fromAccount(endpoint: ..., syntheticToken: ...)`: only HTTP literal loopback, no credentials/path/query/fragment, synthetic token format only. Canonical endpoint includes port. Account namespace is SHA256 of the synthetic token; the token itself is not retained or persisted.
- `LocalPaymentPendingEntry(key: ..., operation: ..., parameters: ...)`: operations `transfer`, `create`, `claim`, `refund`; immutable exact-string parameters. Transfer fields: recipient/asset/amount. Create: room/asset/total/slots/expiresAt (original Unix seconds). Claim/refund: packet. No key or expiry is regenerated while loading.
- `LocalPaymentPendingStore(preferences: ..., mode: 'localSimulation')`: explicit injected SharedPreferences; rejected in release mode or other modes.
- `load(scope)` returns `LocalPaymentPendingLoad`, with status `empty`, `ready`, `corrupt`, or `unavailable` and immutable entries. **Only empty/ready permit normal continuation.** Corrupt/unavailable never silently become empty.
- `save(scope, entry)` must be awaited successfully before dispatching POST. Same-key same-parameters saves are idempotent; same-key different-operation/parameters rejects with `key_conflict`. Up to 32 entries and 64 KiB per scope; never evicts an older recovery key.
- `remove(scope, key)` explicitly removes the matching entry; caller must invoke only after reconciling success. Missing keys are harmless; corrupt/unavailable journals cannot be overwritten by remove or save. Failed writes throw `LocalPaymentPendingStoreException('write_failed')`.

## Storage and boundaries

Versioned canonical JSON contains mode, canonical endpoint, account hash and entries under a hashed scope preference key. Strict decoding validates exact fields/types, integer strings (including the 9e15 limit), ID/key/identifier bounds, version/mode/scope, duplicate entry keys, and canonical representation. Corrupt or edited duplicate-key JSON is rejected rather than loosely interpreted. Past expiry is intentionally retained for querying/retrying the original operation.

All instances serialize reload/read/write work within one Dart isolate; loading reloads the injected preferences instead of trusting an old cached journal. This is **not** a cross-isolate/process transactional database. SharedPreferences does not guarantee disk durability after abrupt OS/process failure. No bearer token/private key is stored; token hashing is a namespace mechanism, not encryption or anonymization (synthetic tokens are predictable). No production account or real payment integration exists.

## Evidence

```sh
flutter test --no-pub test/features/payments/data/local_payment_pending_store_test.dart
```

**9/9 tests passed**. Log: `/tmp/n42-payment-pending-store-tests.log`.

Coverage: explicit mode/scope validation; restart reads original key, amount and expired timestamp; no token in stored JSON; immutable loaded objects; endpoint/account isolation; exact removal; idempotent/conflicting saves; concurrent separate-store writes without dropped entries; all four operations; malformed types, amounts, IDs, duplicate JSON/entry keys, foreign account/endpoint/mode/version; unreadable preferences distinct from corrupt; false/throwing writes prevent a simulated caller's POST; capacity rejection preserves old entries.

```sh
dart analyze lib/features/payments/data/local_payment_pending_store.dart test/features/payments/data/local_payment_pending_store_test.dart
```

No errors or warnings; 9 style infos. Only the new storage file, its test file and this evidence document were edited.
