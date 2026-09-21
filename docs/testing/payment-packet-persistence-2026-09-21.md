# Packet lab pending persistence — 2026-09-21

`LocalPacketLabPage` now uses `LocalPaymentPendingStore` before every create,
claim, or refund POST. The journal scope is derived only from the validated
client endpoint and the active synthetic account token hash. Restarting the
page restores the original request key and parameters, including the absolute
create expiry, but never sends a POST automatically.

Activation blocks money actions when the journal is corrupt, unavailable, or
contains more than one packet operation. Transfer entries remain owned by the
transfer page. Account, client, and store changes invalidate late async results.

A confirmed, matching receipt is rendered before journal cleanup. If cleanup
fails, the receipt stays visible, resend remains disabled, and a read-only
original-result GET can retry cleanup. Only a matching receipt clears the
record. A normal group-packet create recovery rejects a receipt containing a
designated recipient.

Focused widget coverage verifies existing create/claim/refund behavior,
GET-only recovery, mismatch retention, account-switch isolation, exact
create-request restoration across page rebuild, and host dependency injection.
The local lab remains disabled in release builds and still uses synthetic funds
only.

Validation:

```text
flutter test test/features/payments/presentation/local_packet_lab_page_test.dart test/features/payments/presentation/local_payment_lab_host_test.dart
```

Result: **29 passed**, targeted analyzer reported no issues; diff check passed. Added failure-path checks cover zero POST after save failure, cleanup failure preserving confirmation and disabling resend until GET reconciliation, corrupt/multiple-entry blocking, create/claim/refund page recreation retaining original body/key, and unrelated transfer-entry preservation.

This is local simulation only. SharedPreferences does not guarantee persistence after abrupt OS failure, and recovery requires the original server ledger; restarting the disposable sandbox launcher discards that ledger. No physical-device or production payment acceptance was performed.
