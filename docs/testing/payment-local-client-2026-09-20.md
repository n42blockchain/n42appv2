# Local payment client and protocol validation

Date: 2026-09-20. Scope: P09 transport/account context; no production or APP payment entrypoint enabled.

## Client

`LocalPaymentClient` requires explicit enablement, a literal HTTP `127.0.0.1` endpoint, and a synthetic test account token. Release mode rejects use. Transport is injected and owned by the caller; no credentials are persisted or logged. Requests use bearer authentication, exact decimal minor-unit strings and explicit idempotency keys. Redirect following is disabled; request/response sizes are bounded at 64 KiB, with a whole-operation timeout.

Account activation/logout advances a generation counter. Old-account success/error responses cannot enter the new account's state. This does not undo a transaction already accepted by the server. The client never automatically retries a timed-out mutation; a deliberate retry must reuse its original account, body and key.

Success responses must identify localSimulation, use exact integer strings, and match transfer/create inputs. Unknown server messages and transport exceptions are reduced to fixed error codes, without exposing payload text.

## Evidence

- 11 client tests passed: disabled/no-account gates, loopback restriction, synthetic tokens, exact large integers, stable request keys, account switching, logout, malformed/foreign receipts, timeout without retry, packet encoding, redirect and size rejection.
- 1 real loopback protocol test passed. Flutter test starts the actual Python adapter on an ephemeral port and temporary SQLite database; two synthetic accounts exercise balances, transfer/retry, reserve, claim/retry, server-clock expiry and refund/retry. Starting issuance 100 ends as sender 70 + recipient 30, with no duplicate debit or credit.
- Existing server suite: 7 real HTTP tests passed (separate evidence).
- Logs: `/tmp/n42-payment-client-tests.log`, `/tmp/n42-payment-protocol-tests.log`, `/tmp/n42-payment-client-analyze.log`.

The protocol test requires Python 3 (already required by the CI quality gate) and loopback socket access. Test funds and tokens are synthetic. Public testnets, payment-provider sandboxes, device UI, persistent client order recovery and production authorization are not validated by these tests. P09 remains partial until a deliberate test UI entry is wired.
