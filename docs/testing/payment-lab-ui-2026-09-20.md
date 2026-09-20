# P09/P14 — local payment lab UI

Date: 2026-09-20. Scope: synthetic balance and transfer form only.

## Delivered

- `lib/features/payments/presentation/local_payment_lab_page.dart` accepts
  `required LocalPaymentClient client`. It creates no transport, production
  route, wallet connection or Matrix session.
- Heading explicitly reads **Local simulation / synthetic funds**. Account token
  starts empty, requires manual synthetic-token input and is obscured. Asset and
  recipient fields explicitly describe synthetic identifiers. Amount is entered
  in **whole base units**, validated as a positive integer within the client's
  local bounds; decimals and scientific notation are rejected.
- Activation/switching clears prior balance, receipt, error and attempt state.
  Client and page generation checks discard responses belonging to an earlier
  activation. The newly activated account loads its own balance when an asset
  has been entered; old-account balances are never used as a cache.
- Balance refresh and transfer serialize through a busy state. Transfer controls
  and fields disable while working; repeated taps cannot send concurrent requests.
  Account switching remains available to invalidate the displayed session.
- Errors appear inline. A failed transfer retried with unchanged inputs in the
  current session reuses its idempotency key. A successful receipt is explicitly
  labeled **Simulated transfer receipt — synthetic funds only**, and balance is
  refreshed afterward.
- If that follow-up balance refresh fails, the confirmed simulated receipt stays
  visible and the message directs users to **Refresh synthetic balance**. It does
  not suggest retrying the transfer; the test verifies that refresh sends only GET.
- The caller owns the client and transport. The page clears the client session on
  entry, replacement and disposal, and never calls `close()` on either. Therefore
  the client should be dedicated to this page while mounted. The host controls
  explicit debug-only entry and final resource disposal.

## Verification

`test/features/payments/presentation/local_payment_lab_page_test.dart` injects
`http.MockClient`; no socket or service is contacted. Fixtures use `test-usdc`,
recipient `b`, token `synthetic-test-accounta` / `synthetic-test-accountb`, and
integer base units.

- Focused widget suite: **7 passed**. Covers duplicate taps/busy state, inline
  failure and same-key recovery, switching during pending balance requests,
  clearing a prior receipt and disabling after an invalid replacement token,
  receipt preservation after balance-refresh failure, 320×568 at 200% text with
  scrollable controls and exact amount rejection, disabled client/no dispatch,
  and caller-owned client reuse after disposal.
- Focused Dart analysis of the page and test: **no issues**.
- Logs: `/tmp/n42-payment-lab-ui-tests-20260920.log` and
  `/tmp/n42-payment-lab-ui-analyze-20260920.log`.

## Deliberate limits

This is a local simulation screen, not production payment functionality. No red
packet form is included. No true wallet, credentials, live balance, real payment
or device acceptance was used or claimed.

Idempotency keys and receipts are page-session state, not durable order storage.
Leaving/reopening the page, switching accounts or editing an uncertain transfer's
inputs does not reconcile an accepted-but-unacknowledged operation. This page
does not claim unknown-outcome or restart recovery; those require a separate
order-query/persistence design before real payment use. Client clearing discards
late UI results and cannot undo an already accepted simulated operation.
