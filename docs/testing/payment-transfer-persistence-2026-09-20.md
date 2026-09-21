# Transfer lab pending persistence — 2026-09-20

Status: implementation and narrow verification complete; awaiting parent review/commit.

## Behavior

- The transfer lab receives a `Future<LocalPaymentPendingStore>` from its explicitly enabled host. Scope uses the client's read-only, already validated loopback endpoint plus synthetic account token hash; there is no independent endpoint argument to mismatch.
- Account activation loads the durable journal before enabling payment. Corrupt/unavailable journals and multiple transfer entries block new transfers. Packet entries are left untouched.
- An original transfer snapshot is persisted before POST; failed save prevents dispatch. Generation checks after storage/network awaits reject stale account/page results.
- Reopening the page and activating the same test account restores the original key, amount, asset and recipient with inputs locked. The original request can be queried or retried unchanged.
- A validated successful receipt is shown before removing the pending record. If removal fails, the UI preserves both confirmation and the pending record, disables POST, and directs the user to read-only recovery and cleanup retry. A known cleanup failure also stays blocked when switching away and back during the page lifetime.
- Client or store injection replacement invalidates the page session; storage is reloaded on activation. The host initializes its store independently of whether its initial view is transfer or packets, allowing same-State view changes without null assertions.
- Store initialization failures are handled before user activation and reported as storage failures; no unhandled future exception is used as a fallback. Release/default-disabled host behavior remains unchanged.

## Limits

The journal is SharedPreferences local-test storage, not a production financial database. It does not store bearer tokens or private keys. The same endpoint and original server SQLite ledger must be retained: restarting the disposable server launcher creates a new ledger. A pending record alone does not prove payment success; recovery still checks the authoritative local server receipt.

## Tests

Commands (serialized Flutter ownership):

```sh
flutter test --no-pub test/features/payments/presentation/local_payment_lab_page_test.dart test/features/payments/presentation/local_payment_lab_host_test.dart
flutter test --no-pub --dart-define=N42_LOCAL_PAYMENT_LAB=true test/features/payments/presentation/local_payment_lab_host_test.dart
```

Final results: **22/22 passed** for transfer page (19) plus default-disabled host (3); **3/3 passed** for the explicitly enabled host. Logs: `/tmp/n42-transfer-persistence-tests.log` and `/tmp/n42-transfer-persistence-host-enabled-tests.log`.

New coverage includes page recreation and exact-key recovery, write failure blocking POST, corrupt/unavailable/multiple-entry journals, removal failure preserving confirmation, and same-State host mode changes. Existing account switching and stale-response tests remain passing. Narrow analysis reported no errors or warnings (style infos only).

## Separate store lifecycle fix

Initial widget-suite execution revealed that retaining a completed static queue Future could retain a previous FakeAsync Zone and stall subsequent widget lifecycles. This does not establish that all production payments were broken. Parent authorized a separate minimal store fix: retain only the active queue tail, releasing it when its newest marker completes. Two independent widget-Zone regression tests were added to the existing nine store tests. Store fix files should be committed independently from this UI integration.


## Suggested independent commits

1. Store lifecycle fix: only `local_payment_pending_store.dart`, its test, and `payment-pending-zone-lifecycle-2026-09-20.md`; suggested title `fix: release completed pending journal queue futures`.
2. Transfer integration: transfer page + host, their two test files, and this document; suggested title `feat: persist local transfer recovery attempts`.

No version edits, full-suite execution or commits were performed by this subtask. The read-only `client.endpoint` getter is supplied independently by the client subtask.
