# Local designated-recipient packet eligibility

Date: 2026-09-20. Backend local simulation only; no Flutter changes or real funds.

## Behavior

`create_packet(..., recipient=None)` and `POST /packets` accept an optional
recipient. Omission preserves the existing equal-share group behavior. A named
recipient requires one slot, must be a creation-time room member and must differ
from the authenticated sender. Eligibility stores only that recipient, and claim
also checks the persisted recipient explicitly plus current room membership.
Other members, the sender and outsiders cannot first claim. Expiry and owner
refund logic remain unchanged.

Claims retain their existing idempotent historical-receipt behavior: a claim
already recorded before departure can be read again after departure/expiry but
never credits twice. An unclaimed recipient who leaves is rejected.

`packets.recipient` is nullable. Startup migrates an existing database under a
fresh SQLite write lock, preserving legacy rows as group packets. Explicit-column
INSERTs work with migrated and fresh schemas. Ordinary packet requests retain
legacy five-element idempotency arrays; designated requests append the recipient.
HTTP request-key lookup builds the corresponding expected array, preserving old
bindings while rejecting direct-core collisions with a different recipient.
Strict JSON accepts only the optional recipient field; null, invalid types and
sender/account overrides are rejected.

## Files

- `backend/payment-sandbox/sandbox.py`
- `backend/payment-sandbox/packet_reservations.py`
- `backend/payment-sandbox/packet_claims.py`
- `backend/payment-sandbox/server.py`
- `backend/payment-sandbox/test_designated_recipient.py` (new)
- `backend/payment-sandbox/README.md`

## Verification

- New targeted Python suite: **12 passed**.
- Complete local payment-sandbox Python suite: **47 passed**.
- Covers other-member/sender rejection, departure before claim, concurrent
  duplicate creation/claim, claim-versus-refund race and conservation, exact
  recipient replay, changed recipient/group conversion rejection, strict HTTP
  fields, restart persistence, concurrent legacy-schema migration, preserved old
  group claims/receipts/request lookup, and mismatched direct-core lookup.
- Logs: `/tmp/n42-designated-recipient-tests-20260920.log` and
  `/tmp/n42-designated-recipient-regression-20260920.log`.

Tests use temporary SQLite fixtures and numeric-loopback HTTP only. No Flutter
command, real account, external provider, wallet, blockchain or testnet was used.
Recipient selection/client UI wiring remains the host integrator's separate task.
