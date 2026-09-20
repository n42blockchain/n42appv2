# Local payment simulation

Python standard-library fixtures for **synthetic funds only**. This is not a Nium API emulator, provider adapter, public server, production payment service, or blockchain testnet. No HTTP listener, credentials, networking, payment signing, or real currency is used. Production mode is rejected; no fallback into simulation exists.

## Run

```sh
python3 -m unittest discover -s backend/payment-sandbox -p 'test_*.py' -v
```

From this directory, a local fixture can be created explicitly:

```python
from sandbox import Sandbox

asset = 'test-fiat:USD:minor-2'
sandbox = Sandbox('/tmp/n42-local-payment-test.sqlite',
                  mode='localSimulation', assets=[asset])
sandbox.seed_test_funds('test-alice', asset, 1000, key='fixture-1')
alice = sandbox.account('test-alice')
alice.transfer('test-bob', asset, 100, key='example-transfer')
```

Every receipt and balance identifies `mode=localSimulation`. Assets are opaque allowlisted identifiers supplied by the fixture owner; `USD`, `USDC`, and other display symbols do not resolve automatically. All amounts are integer minor units, rejecting floats, strings, booleans, negatives, zero, and values above 9,000,000,000,000,000. Total synthetic issuance per asset is capped at that same limit, below signed SQLite 64-bit maximum.

## Boundaries and semantics

- `Sandbox` is the privileged **local fixture owner**, able to seed test funds and set test membership. `account(id)` establishes a trusted test principal, not authentication. Account-facing operations do not accept sender overrides or arbitrary account balance queries. Never expose these Python objects directly to untrusted clients. A later API must derive principals and membership from verified server-side identity.
- `seed_test_funds` is the only issuance path, explicit and idempotent. Transfers use an actor-scoped idempotency key; same parameters replay the original receipt, changed parameters reject. Different actors cannot debit each other's funds.
- Packet creation atomically reserves funds from the owner's available balance. Equal shares must divide exactly, and slots cannot exceed the member snapshot. This version includes the sender in the snapshot; the sender may claim one share while still a member.
- Claims require both creation-time snapshot inclusion and current membership. A claimant receives at most one share. Repeated successful claims return the original receipt even after expiry or departure, without moving funds again.
- At `now >= expires_at`, new claims are denied. Only the owner can explicitly invoke the local refund fixture; it credits the exact unclaimed remainder once in the original asset. There is no scheduler or automatic wall-clock refund worker yet.
- `now` is an explicit trusted test timestamp for deterministic scenarios, not a client-controlled timestamp contract. A future service must use its own clock.
- SQLite `BEGIN IMMEDIATE` serializes each money operation, including balance changes, idempotency record and paired ledger entries. Process restart retains committed data; errors roll back. Concurrent fixtures sharing a local file do not overspend or overclaim. No guarantees are made for network-mounted SQLite or distributed multi-region deployments.
- `audit_test_asset` is a privileged fixture check of available + reserved = seeded supply, with zero-sum paired ledger postings including the synthetic issuance bucket. It is not external-provider reconciliation.

## Module / commit order

Each stage can be separately committed and tested. `Account` wrappers import action modules only when called, so the ledger stage can run independently before later action files land.

1. **P04** `common.py`, `sandbox.py`, `account.py`, `test_support.py`, `test_ledger.py`, `.gitignore`, README: account-scoped balances, configured assets, seed issuance, paired ledger and transaction foundation. Run `python3 -m unittest discover -s backend/payment-sandbox -p test_ledger.py -v`.
2. **P05** `transfers.py`, `test_transfers.py`: idempotent atomic transfers and concurrency tests.
3. **P06** `packet_reservations.py`, `test_packet_reservations.py`: exact equal-share reservation and snapshot.
4. **P07** `packet_claims.py`, `test_packet_claims.py`: current + snapshot membership and once-only concurrent claims.
5. **P08** `packet_refunds.py`, `test_packet_refunds.py`: expiry boundary, unclaimed refund and replay.

For P05–P08, run unittest discovery with that stage's test filename; later stages depend on previous stages. Append the consolidated evidence document after all stages. No app integration or real-provider capability is implied by these modules.

## P09a: opt-in loopback HTTP fixture

`server.py` adds an explicit local-only adapter. It binds **only the literal `127.0.0.1`**, rejects other hosts and production mode, does not perform reverse DNS, and accepts only configured synthetic test tokens. There is no public deployment configuration, CORS, external provider call, credential discovery or automatic production fallback.

Start it from a trusted local test harness after setting up the SQLite fixture:

```python
from server import LocalPaymentServer
from common import MODE

# Existing `sandbox` was explicitly created and seeded by the fixture owner.
server = LocalPaymentServer(
    sandbox, mode=MODE, port=8765,
    tokens={'synthetic-test-alice000': 'test-alice'},
)
try:
    server.serve_forever()
finally:
    server.server_close()
```

The token mapping is required at startup; tokens must match `synthetic-test-[A-Za-z0-9_-]{8,128}`. These are disposable local fixture identifiers, not production secrets. Do not provide real provider credentials. Seed and member configuration remain trusted Python fixture actions; no HTTP seed/member/admin endpoint exists. Requests must use `Host: 127.0.0.1:<port>` and must not carry an `Origin` header.

### Protocol

Every request requires `Authorization: Bearer <configured synthetic token>`. Every POST additionally requires `Content-Type: application/json` and `Idempotency-Key` (1–128 non-space printable ASCII characters). Maximum JSON body: **64 KiB**. Duplicate JSON keys, unknown fields, transfer encoding, multiple identity/length headers, and malformed bodies are rejected. HTTP responses are non-cacheable.

| Method/path | Request | Success object fields, in addition to `mode` |
| --- | --- | --- |
| GET `/balances?asset=<percent-encoded assetId>` | No body | `asset`, `available` |
| POST `/transfers` | `recipient`, `asset`, `amount` | `id`, `recipient`, `asset`, `amount` |
| POST `/packets` | `room`, `asset`, `total`, `slots`, `expiresAt` | `id`, `asset`, `total`, `slots`, `expiresAt` |
| POST `/packets/{packet_id}/claims` | `{}` | `packet`, `asset`, `amount` |
| POST `/packets/{packet_id}/refunds` | `{}` | `id`, `asset`, `amount` |

Successful responses are direct JSON objects, not wrapped in `data`, always with `mode: "localSimulation"`. **All integer fields are canonical decimal strings**, including balances, amount, total, slots, and absolute Unix-seconds expiresAt. JSON numbers, floating-point/exponent notation, booleans and leading zeroes are rejected. Example transfer body: `{"recipient":"test-bob","asset":"test-fiat:USD:minor-2","amount":"100"}`. Amounts remain integer minor units; there is no decimal or symbol conversion. Values above the core's 9e15 ceiling are rejected.

The server derives the actor from its token mapping. Body fields such as `sender`, `account` or `now` are rejected; time comes from the server clock (injectable only by the local harness). Idempotency keys are **globally scoped per actor across these HTTP actions** and persist in the same SQLite file. A key bound to a different route or body rejects with 409. Validation failures before binding do not consume the key; a core/business failure after binding retains it, allowing a same-request retry when conditions change.

HTTP binding and the core financial operation use separate committed transactions. If interrupted between them, the key remains bound and the same request retries the core operation. The core's own durable transfer/create idempotency and unique claim/refund semantics prevent a second financial effect, including after adapter restart. The adapter does not cache receipts only in memory. Do not share one SQLite test ledger across independently configured incompatible fixtures.

Errors are generic JSON without account state, tokens, tracebacks, SQL or internal exception details:

```json
{"mode":"localSimulation","error":{"code":"conflict","message":"conflict"}}
```

Codes/statuses: `unauthorized` 401, `invalid_request` 400, `not_found` 404, `conflict` 409, `payload_too_large` 413, `internal_error` 500. Core business errors intentionally share `conflict`; this small test protocol is not a production customer-error taxonomy.

### HTTP verification

```sh
python3 -m unittest discover -s backend/payment-sandbox -p test_server.py -v
```

Tests use a real ephemeral loopback socket, synthetic tokens and temporary SQLite files, with an injected server clock. This is not app integration or external-provider validation. There is no TLS because the listener is local-only; do not port-forward or proxy it publicly.

## Disposable debug-UI launcher

From the repository root:

```sh
python3 backend/payment-sandbox/run_local.py
```

This starts the local fixture at `http://127.0.0.1:8765`. Use `--port 8766` for another local port, or `--port 0` to choose an ephemeral port printed at startup. The only configurable argument is the port; no production mode, host override, credential file, real provider or persistent database configuration exists.

The launcher explicitly creates two public test accounts:

| Account | Synthetic token | Starting balance |
| --- | --- | --- |
| `a` | `synthetic-test-accounta` | `100000000` minimum units of `test-usdc` |
| `b` | `synthetic-test-accountb` | `100000000` minimum units of `test-usdc` |

Room `test-room` initially contains `a` and `b`. These displayed tokens are disposable fixture identifiers, not secrets. The temporary SQLite database is owned by this process. **Ctrl+C** stops the server and deletes the temporary directory; restarting creates a fresh fixture and resets balances. A normal SIGTERM also cleans up. SIGKILL or process/OS crashes cannot guarantee context-manager cleanup; this launcher is not persistent storage.

The launcher supports the explicitly enabled debug client on the same machine. A physical phone's `127.0.0.1` points to the phone, not the development computer; this launcher deliberately does not open a LAN listener or production UI entry. Runtime integration must preserve the local-only boundary.

Launcher checks:

```sh
python3 -m unittest discover -s backend/payment-sandbox -p test_run_local.py -v
```

Four tests cover seeded account balances, normal and exceptional temporary-file cleanup, unsupported CLI arguments, and a real subprocess with ephemeral loopback HTTP balance lookup followed by SIGINT and directory removal.
