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
