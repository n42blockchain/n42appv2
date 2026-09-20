# P14 — local synthetic packet lab UI

Date: 2026-09-20. Local HTTP protocol simulation only; no blockchain or testnet.

## Scope and behavior

- Added `lib/features/payments/presentation/local_packet_lab_page.dart`, with
  `LocalPacketLabPage({required LocalPaymentClient client})`. No existing transfer
  page, host route, client implementation or dependency was modified.
- Clearly labeled **Local simulation / synthetic funds**. Account token is manually
  entered and obscured. No real wallet, Matrix session or real balance is accessed.
- Creation takes synthetic room/asset, positive integer base-unit total, equal-share
  count and expiry minutes (1–10080). Shares must divide the total exactly. A
  confirmed create receipt displays the local packet ID and fills the action field.
- Pasted `packet_` plus 64 lowercase hex IDs can be submitted for a simulated claim
  or an expired-packet refund request. The local service determines authorization,
  membership and expiry; the page does not mark refunds successful merely because
  a timer elapsed.
- Money actions serialize through busy state. An operation snapshot fixes its
  parameters, absolute expiry and idempotency key before dispatch. Without a
  confirmed receipt, inputs/new money actions remain locked and **Retry same
  operation** resends that exact snapshot. Even definitive server rejections are
  conservatively retained; this page has no abandon/edit-unconfirmed-operation flow.
- During the page lifetime, unconfirmed snapshots are retained per synthetic
  account. Switching clears displayed balance, packet ID, error and receipt, while
  generation checks discard old responses. Switching back restores the unresolved
  request rather than assigning it a new key. No account balance/receipt cache exists.
- Success displays a **Simulated create/claim/refund receipt — synthetic funds only**
  and refreshes the receipt's synthetic asset balance. Balance-refresh failure
  preserves the receipt and directs users to a GET-only balance refresh.
- Client and transport remain caller-owned. The page requires a dedicated client
  while mounted, clears its active session on entry/replacement/disposal, and does
  not call `close()`.

## Validation

`test/features/payments/presentation/local_packet_lab_page_test.dart` uses injected
`http.MockClient` exclusively; no network connection or external service is used.

- **8 widget tests passed**: synchronous repeated creation callback dispatches once;
  stored body/absolute-expiry/key survives create retry; claim and refund each keep
  their keys; switching drops a late prior-account receipt and restores its request
  on return; confirmed operation plus failed balance refresh only repeats GET;
  320×568 with 200% text remains scrollable and rejects invalid amounts/IDs before
  dispatch; disabled client sends nothing and disposal leaves the client reusable.
- Focused Dart analysis of the new page and test: **no issues**.
- Logs: `/tmp/n42-payment-packet-lab-ui-tests-20260920.log` and
  `/tmp/n42-payment-packet-lab-ui-analyze-20260920.log`.

## Remaining boundaries

Snapshots are memory-only. Leaving the page or restarting does not reconcile or
recover an accepted-but-unacknowledged operation. No durable order query/storage,
unknown-outcome recovery across restarts, real-fund safety, native device acceptance
or testnet acceptance is claimed. Session clearing cannot undo an accepted
simulated operation. Release/default entry gating remains owned by the existing
client and host; this change adds no route or deployment capability.

## Follow-up — read-only original-result lookup

Added **Check original result** for the active account's saved unconfirmed
operation. It calls `LocalPaymentClient.recoverRequest(originalKey)` through
`GET /requests?key=<encoded>`; mocks assert the query key. It does not POST or create another request key. Both lookup and retry obey the existing busy
state. Only a confirmed receipt matching the saved operation clears pending state:

- Create: packet receipt type, asset, total, slots, absolute expiry, and room when
  supplied by the receipt must match the original snapshot.
- Claim: the returned packet must match the original packet, with no ID indicating
  another operation type.
- Refund: the receipt must be a refund type; any supplied packet association must
  match. The current refund protocol can omit packet ID, so association then
  depends on the authenticated account's authoritative original-key lookup, not
  on inferring packet identity from the refund ID. A pasted packet has no known
  asset before the authoritative response; the form's unrelated asset is not used
  to claim an independent asset binding.

Unresolved results, HTTP 404, lookup errors and mismatched receipts leave the saved
request/key intact. They do not mark the operation failed. Switching accounts
invalidates late lookup responses without removing the original account's pending
snapshot. After successful recovery, balance refresh errors preserve the receipt
and direct the user to GET-only refresh, never a repeat money action.

Validation: **18 widget tests passed** (the prior 8 plus 10 lookup cases), with
**no issues** in focused Dart analysis. Added tests cover create/claim/refund lookup
without a second POST, unresolved/404 followed by same-key retry, stale lookup after
account switching, all saved create terms, claim/refund packet mismatches and a
recovered receipt followed by failed balance refresh. Logs:
`/tmp/n42-packet-lab-recovery-tests-20260920.log` and
`/tmp/n42-packet-lab-recovery-analyze-20260920.log`.

This adds lookup for page-memory snapshots only. It does not add persistence or
recovery after page disposal/restart. Verification still uses HTTP mocks, not a
network service, blockchain or testnet.
