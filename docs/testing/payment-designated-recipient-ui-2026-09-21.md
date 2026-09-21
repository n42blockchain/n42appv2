# Designated-recipient packet lab UI — 2026-09-21

The local packet lab can optionally designate one synthetic test account when
creating a packet. The field is visibly labeled as a test account. A designated
packet fixes the visible slot field to one and displays the recipient in pending
summaries and confirmed receipts. Leaving the field empty
keeps the existing equal-share group-packet request.

The recipient identity is preserved exactly, without trimming, in the POST and
pending journal. Recovery requires the receipt recipient to match exactly; a
changed or missing value keeps the operation pending. Server-side room
membership, sender, and eligibility checks remain authoritative. The bearer
token is not an account ID, so the UI does not guess an identity mapping or
compare token prefixes to recipient IDs. A server rejection remains pending for
same-key recovery.

`LocalPaymentPendingEntry` continues to read the legacy five-field create
snapshot. Its optional sixth `recipient` field is accepted only for create with
one slot and a non-empty, control-free value of at most 256 Unicode code points.
Claim, refund, and transfer schemas remain exact.

Focused tests cover legacy group requests, designated request serialization,
cross-page exact restoration without automatic POST, mismatched recovery,
server rejection retention, legacy journal compatibility, Unicode length limits, and
the one-slot invariant.

Validation command:

```text
flutter test test/features/payments/data/local_payment_pending_store_test.dart test/features/payments/presentation/local_packet_lab_page_test.dart
```

Results: the initial store/page combined run passed 40 tests. After the final UI review changes, all 28 packet-page tests passed again; store code was unchanged after its passing run. Targeted page analysis found no issues; the earlier combined analysis had no errors/warnings and eight existing style infos. No full-suite coverage measurement or physical-device acceptance was performed.
