# Go dependency upgrade evidence

All commands used local Go 1.26.5 with `GOTOOLCHAIN=local`. The numbered `.log.gz` files contain the command output, including the transient parallel Git cache failure and successful serial retry. Full decisions and results are in `.superpowers/sdd/2026-09-25-full-dependency-upgrade/task-7-report.md` in the worktree ledger.

| Module | Direct dependencies after upgrade | Declared Go | Tests | Vet | Tidy diff |
| --- | --- | --- | --- | --- | --- |
| livekit-jwt | LiveKit protocol 1.52.1 | 1.26.0 | pass, 27 test functions | pass | clean |
| loyalty | go-ethereum 1.17.6, Gin 1.12.0, pq 1.12.3 | 1.26.0 | pass, 9 test functions | pass | clean |
| social-auth | none | 1.22 | pass, 10 test functions | pass | clean |
| swap | go-ethereum 1.17.6, Gin 1.12.0, pq 1.12.3, sqlx 1.4.0, uuid 1.6.0 | 1.26.0 | pass, 45 test functions | pass | clean |

Final `go list -m -u all` outputs are `27-livekit-updates2.log.gz`, `48-loyalty-final-updates.log.gz`, `49-swap-final-updates.log.gz`, and `11-social-updates.log.gz`. The broad upstream graphs report 34, 84, 87, and 0 available updates, respectively. `go list -deps -json ./...` and `go list -deps -test -json ./...` show zero available updates among production or test modules actually imported by these services; see `50-used-module-audit.log.gz`, `51-test-module-audit.log.gz`, and the `used-modules-*.log.gz` and `test-modules-*.log.gz` path/version inventories. `47-toolchain-caps.log.gz` records that no resolved module requires a Go version above 1.26.0.

Loyalty and swap Docker builders were raised to Go 1.26 to match their module minimums. Local tests and vet ran; container images were not built.
