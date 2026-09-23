# Release Coverage and Server Operations Plan

> **For agentic workers:** Follow this plan task by task. Each code task starts with a failing behavior test, then implements the smallest safe change and reruns the relevant suite.

**Goal:** Establish trustworthy, passing release test gates for the Flutter app, Chat plugin, and backend services, then document repeatable server operations and deployment readiness without weakening existing security controls.

**Architecture:** Keep coverage reports separate by component and language: app and Chat use LCOV line coverage, Go services use Go statement coverage, and Python services use Python coverage. Preserve the app's 70% CI gate and add equivalent per-component targets only after each component has a reproducible baseline. Review authentication and deployment contracts before changing externally visible behavior.

**Tech Stack:** Flutter/Dart, `flutter_test`, LCOV, Go `testing`/`go tool cover`, Python `unittest`/coverage.py, GitHub Actions, Docker, systemd, Nginx, SSH.

**Scope inputs:** User request on 2026-09-22: inspect release coverage requirements, include Chat plugin and server code/configuration, parallelize the work, review available server login, repair server code/deployment gaps, and produce detailed documentation. Repo guidance requires the main Flutter CI suite to retain its 70% threshold.

## Global Constraints

- Keep `.github/workflows/ci.yml`'s main-app line coverage threshold at 70%.
- Do not exclude generated Dart code, add artificial imports, skip tests, or lower a threshold to pass.
- Do not count placeholder integration tests as coverage or release evidence.
- Do not claim Chat or backend coverage from the main app LCOV file; their production sources are not represented there.
- Treat a public key and an SSL/TLS certificate as different credentials. Never request, log, or commit a private key or production secret.
- Trace every client and service contract before changing authentication, authorization, or network behavior.
- Do not deploy to a production host until the host, environment, operator credentials, rollback path, and change window are known.
- Report uncovered files and executable-line/statement denominators with every percentage.

## Baseline Evidence (2026-09-22)

| Component | Existing requirement | Fresh/current evidence | Result |
|---|---|---|---|
| Main Flutter app | 70% LCOV line coverage in `.github/workflows/ci.yml` | Initial baseline: 63,620 / 132,301 = 48.0873%; 927 of 1,055 `lib/**/*.dart` files represented (128 absent). Latest full run: 68,374 / 132,313 = 51.6760%; 5,767 passed, 0 failed, 0 skipped. | Gate correctly fails at 70%; tests are green |
| Chat plugin | No separate CI coverage gate; tests are indirectly included by some root wrappers | 711 Dart library files and 163 test files. After fixes and storage-cleanup boundary tests: 2,127 passed, 2 skipped; LCOV 24,641 / 135,037 = 18.2476%. | Suite green; `.github/workflows/chat-package.yml` tests local source and publishes a separate coverage artifact; proposed 70% gate not yet enabled |
| Go services | CI runs tests/vet for four services; no coverage threshold | Current: `swap` 31.8%, `social-auth` 35.2%, `loyalty` 28.6%, `livekit-jwt` 72.8% statement coverage | All four `go test`/`go vet` pass; separate CI coverage artifacts added; only LiveKit currently exceeds proposed 70% |
| Python services | No CI test or coverage gate | With pinned `coverage==7.6.1`: `ai-proxy` improved from 7 tests / 61% to 13 tests / 78% line coverage (153 executable statements); `payment-sandbox` 47 tests, 510 executable statements / 92% line coverage. Branch data collected separately; test files excluded from both denominators. | Separate CI job reports coverage; no 70% failure gate yet |
| Deployment access/config | No backend deploy workflow or unified deployment bundle | No SSH config and no loaded SSH-agent identities on this Mac. Four Go services have Dockerfiles; AI proxy has systemd/Nginx instructions. There is no backend compose/Kubernetes deploy, and `livekit-jwt` is documented as legacy. | Cannot authenticate to a server from this workstation or verify live state |

The initial main app run's one failure was `首屏优先展示通用分享动作` in `packages/n42_chat/test/unit/widgets/chat_more_panel_pagination_test.dart:135`, included through `test/features/chat/chat_ux_regression_test.dart`. Root cause: optional Quick Reply occupied a slot even when its callback was null. The implementation now omits that unavailable action; the full app suite and isolated regression both pass. The Chat package dependency compile failure was fixed by mapping otherwise-unrecognized Firebase authorization states conservatively to denied; this compiles against both the host lock and standalone package lock.

## Service Authentication and Login Inventory

| Service | Current authentication path found in source/docs | Follow-up |
|---|---|---|
| `social-auth` | Discord/GitHub OAuth or Telegram validation, then Matrix Synapse shared-secret registration/login; returns Matrix credentials | Verify OAuth state/nonce, Telegram replay protection, Synapse errors, token handling, and rate limits |
| `livekit-jwt` | Matrix Bearer token, Matrix `whoami`, room membership/room-name checks, then LiveKit JWT | README marks the standalone service legacy; confirm current production route before changing/deploying |
| `loyalty` | `AUTH_VERIFY_URL` checks UUID plus token and wallet association | Cover rejection, timeout, mismatched wallet, and upstream outage |
| `ai-proxy` | Matrix Bearer token validation | Cover missing/expired/malformed token and upstream failure |
| `swap` | README describes UUID ownership checks but no token authentication | P0: trace all clients and auth contract, then design compatible authentication and unauthorized-request tests before implementation |
| `payment-sandbox` | Synthetic, loopback-oriented fixture service | Keep isolated from production credentials and production deployment |

The available SSH public key alone does not let this workstation connect: SSH requires the matching private key locally plus the public key authorized by the server. TLS/SSL certificates secure HTTPS ingress and do not provide SSH login. No private key will be requested in chat; the operator can configure a local SSH alias or agent identity outside the repository.

## Parallel Work Tracks

### Track A — Main Flutter coverage

- Completed: corrected the single red test by omitting unavailable Quick Reply when its callback is absent; the assertion that Apps appears on the first page remains intact.
- Use the fresh 48.0873% trace to identify high-value untested behavior; first targets from the trace include wallet management, NFT listing, token import, gas tracking, push utilities, and Sui sends. Wallet keystore gating, NFT empty/search/info card, ENS retry, market fallback, wallet search ranking/history, add-token fail-closed, Gas Tracker card/alert/configuration, and Sui/XRP/ALGO/TRX/TON/SOL send safety behavior now have widget tests; latest full app run is 51.6760% (68,374/132,313) with 5,767 passing tests.
- Add user-observable tests for validation, error/retry, authorization, and lifecycle behavior. Add module test batches without editing generated files.
- Re-run the full suite on a stable tree after each coherent batch; add the 70% gate only as measured by the existing CI script.

### Track B — Chat plugin coverage and dependency stability

- Completed: pinned CI to the repository's Flutter/Dart release toolchain; dependencies currently resolve through the package constraints and the full suite passes.
- Completed: fixed the authorization-status mismatch with a conservative fallback and verified against host and standalone dependency locks.
- Completed: ran standalone coverage (18.23%) and added a CI job that directly tests the tracked local package source and publishes LCOV. Next: prioritize message send/receive, E2EE/key errors, media permission/upload failure, account switching, and VoIP/screenshare flows.
- Establish a package-specific 70% line target after meaningful coverage gains and a stable clean baseline.

### Track C — Go service coverage and security

- Preserve separate coverage artifacts for `backend/swap`, `backend/social-auth`, `backend/loyalty`, and `backend/livekit-jwt`.
- Prioritize authorization and trust boundaries first: swap auth contract, social login callback/replay handling, loyalty upstream verification, and LiveKit room-role validation.
- For every service, cover valid request, unauthenticated/unauthorized request, malformed input, dependency timeout/error, and safe response behavior.
- Raise each active service toward a proposed 70% statement-coverage target. Confirm whether `livekit-jwt` is still deployed before investing in production-facing changes.
- Add Go coverage tests and `go vet` to CI with separate service summaries; do not pool unrelated service lines into one percentage.

### Track D — Python service tests and coverage

- Add a pinned development-only coverage tool and CI commands for `backend/ai-proxy` and `backend/payment-sandbox`.
- Preserve the existing 7 and 47 passing unittest cases as baselines; measure line/branch coverage and add tests for auth, invalid payloads, upstream timeouts, fixture isolation, and cleanup.
- Keep `payment-sandbox` local/synthetic; never point tests or deploy configuration at production funds or endpoints.
- Establish separate 70% line-coverage targets after the first valid measurements.

### Track E — Deployment configuration and documentation

- Audit every backend environment variable, listener, health/readiness endpoint, database migration/backup assumption, outbound dependency, rate limit, TLS boundary, and secret source.
- Document the current trust boundary accurately: Go services are generally HTTP behind a TLS ingress/reverse proxy; AI proxy has manual systemd/Nginx instructions; no universal deploy pipeline exists.
- Produce service-specific runbooks with prerequisites, build/tag commands, secret names (never values), health checks, migration order, rollback, log locations, and failure recovery.
- Provide reproducible deployment artifacts only after production topology is known. Do not assume Docker Compose/Kubernetes/systemd where the operator has not selected it.
- Record that deployment from this workstation is blocked until an SSH/private-key identity or another approved server login method is configured and a target environment is named.

## Execution Order and Verification

1. **Freeze fresh baselines — complete:** app, Chat, Go, and Python component denominators and outcomes are recorded above.
2. **Remove test blockers — complete:** Chat first-page ordering and standalone Firebase API compatibility issues are fixed with targeted tests.
3. **Parallel test batches:** app, Chat, Go, and Python work may proceed independently on their own test files and coverage artifacts; keep shared auth/config changes on the security track until the caller contract is understood.
4. **Server security review:** build endpoint-to-caller maps and add unauthorized/timeout tests before changing authentication or deploying.
5. **CI/config gates:** add independent component jobs, pinned dependencies, and per-component thresholds only after clean baselines and green tests.
6. **Documentation:** update coverage evidence and create the backend operations/deployment manual from verified source/config facts; mark unknown production facts explicitly.
7. **Final validation:** run the main suite and 70% gate, Chat suite and gate, each Go suite/vet/coverage gate, each Python suite/coverage gate, plus configuration/secret scanners available in CI. Report any remaining device or external-service checks separately.
8. **Deployment:** prepare and validate a staging deployment artifact first. Production deployment requires a concrete target and working operator credential; none is currently available on this workstation.

## Work Completed During Initial Parallel Pass

- Chat first-page ordering regression repaired without weakening the assertion; full plugin tests pass and its 18.23% baseline is now reproducible.
- Added host-app wallet numeric parsing, EVM transaction receipt, and Gas Tracker tests for integer/double/string/null/invalid inputs, receipt status envelopes, pending/reverted states, testnet RPC selection, EIP-1559 fee history, legacy fallback, unavailable base fee, offline card fallback, alert threshold save/restore, and gas-settings result validation. Added keystore backup password-gating, NFT empty/search/info card, ENS retry, market fallback, wallet search history/ranking, add-token fail-closed, and Sui/XRP/ALGO/TRX/TON/SOL send safety widget behaviors. Latest full suite passes (5,767 tests), coverage is 51.6760%, and the 70% gate remains red. Gas Tracker API source is at 79.63%, card source gained 89/253 lines, alert widgets 224/282 focused lines, settings page 195/223, NFT info card 195/210, ENS widgets 226/246, market screen 70/248, wallet search 149/218, Sui send logic 118/263, XRP send logic 61/245, ALGO logic 81/243, TRX logic 54/241, TON logic 61/231, transaction-state resolver 39.45%, and add-token logic 61/304 focused lines.
- Go CI now records separate statement-coverage artifacts and summaries for each service. Added config boundary tests raise `livekit-jwt` to 72.8%; the other three services remain below the proposed target.
- Python CI with pinned coverage tooling and independent service reports yields `ai-proxy` 61%, `payment-sandbox` 92%. No threshold failure is enabled yet.
- Added `.github/workflows/chat-package.yml` so CI executes the checked-in Chat package rather than relying only on the host app's pinned Git dependency.
- Added boundary tests for transaction receipt state mapping and an injectable EVM receipt reader; added six fail-closed/upstream/HTTP-boundary tests to `ai-proxy`, taking it to 78%; Go coverage is now `loyalty` 28.6%, `social-auth` 35.2%, and `swap` 31.8% after award/auth-verifier/handler, Telegram HMAC/auth-date/login-handler, OAuth/provider loopback, and quote/commit/alert-handler boundary tests. No server behavior/authentication contracts were changed.
- The independent `packages/n42_jmt_verify` package has 13 passing tests. Its dependencies must be fetched in that package directory; the main CI analyze/test jobs now do so, avoiding false analyzer errors from a missing package config.
- No current SSH identity or server target has been established. No remote login, server mutation, or deployment was performed.

## Completion Criteria

- Main Flutter app: full suite green and the existing 70% LCOV CI gate passes without exclusions.
- Chat plugin: standalone source suite green; its own LCOV denominator is documented and its proposed 70% line target passes.
- Backend Go and Python services: all relevant suites green; each active service has a separate, reproducible coverage report and the proposed 70% target passes.
- Authentication findings are resolved or explicitly documented with tested mitigations and a caller-compatible contract.
- Deployment docs match tracked configuration, identify every required secret by name only, document health checks and rollback, and clearly distinguish confirmed access from missing access.
- Staging deployment is verified only if an authorized target and login identity become available; production is never inferred from a successful local build.
