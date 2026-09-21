# Local designated-recipient packet client

Date: 2026-09-20. Extends only the local simulation client and its tests.

## Changes

- `LocalPaymentClient.createPacket` accepts `String? recipient`. Null omits the
  field entirely, preserving the ordinary group-packet request body. A designation
  requires one slot. Empty identifiers, identifiers longer than 256 Unicode code
  points and C0/DEL control characters are rejected before network dispatch.
  Identities are never trimmed, case-folded or otherwise rewritten.
- A designated create receipt must contain exactly the requested recipient;
  missing, null, different, wrong-type or whitespace-normalized identities are
  rejected. Ordinary group requests reject unexpectedly designated receipts.
- Added read-only `Uri get endpoint`, returning the exact internally validated
  local endpoint, so callers can bind recovery scope to the actual transport
  endpoint instead of an unrelated host-supplied value.
- Existing local-only enablement, numeric-loopback restriction, release guard,
  synthetic-token format and generation isolation are unchanged. Recipient
  membership, sender exclusion and account authority remain enforced by the
  backend; client validation is not authorization.

## Verification scope

Seven added mock-client tests cover actual endpoint identity, recipient preservation
(including Unicode code-point boundaries), local validation/no dispatch, exact
receipt matching, ordinary group compatibility and optional-recipient validation
in GET operation/original-request recovery receipts. The existing Dart/Python local
protocol lifecycle now also exercises a designated packet, original-key lookup,
changed-recipient conflict, rejection of sender/other member claims, allowed
recipient claim and idempotent replay with exact final balances.

The protocol uses a temporary SQLite fixture and numeric-loopback HTTP. It does
not call an external provider, connect to a chain/testnet or move real funds.
No UI, pending store, host entry, dependencies or version files were changed.


## Results

- `flutter test --no-pub test/features/payments/data/local_payment_client_test.dart test/features/payments/data/local_payment_protocol_test.dart`: **21 passed**, including the real local Dart/Python protocol lifecycle.
- Focused `dart analyze` on those files and the client: no errors or warnings;
  one pre-existing `prefer_initializing_formals` informational diagnostic remains
  on the transport constructor initializer.
- GET packet receipts in both `operation` and `recoverRequest` reject invalid
  recipient types/identifiers and designated multi-slot receipts, while accepting
  legacy receipts without the optional field. These reads validate receipt shape;
  callers still match recovered terms to their saved intent.
- Logs: `/tmp/n42-designated-client-tests-20260920.log` and
  `/tmp/n42-designated-client-analyze-20260920.log`.
- Flutter testing is complete and its shared window has been released.
