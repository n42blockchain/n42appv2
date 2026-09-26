# Task 7 — Go module upgrades

Base: `b452b89cf`. Worktree: `codex/dependency-upgrade-20260925`. Runtime used for all commands: `go1.26.5 darwin/arm64`, with `GOTOOLCHAIN=local` and no downloaded toolchain. Numbered command logs and module inventories are in `docs/testing/dependency-upgrade-final-2026-09-25/go/` as gzip files.

## Decisions and scope

- Ruling: The brief says to preserve the `go` directives, but the controller clarified that a directive may rise within the installed 1.26 toolchain where required by updated dependencies. `loyalty` and `swap` rise from `go 1.22` to `go 1.26.0`; `livekit-jwt` is normalized from `go 1.26` to `go 1.26.0` by `go mod tidy` because its graph contains dependencies declaring 1.26.0. No `toolchain` directive was added. Cost if wrong: build environments pinned below 1.26 must be upgraded; their Docker builder images were updated here.
- `social-auth` has no external Go modules. Its `go 1.22` directive and source remain unchanged.
- `loyalty` and `swap` Docker builders move from `golang:1.22-alpine` to `golang:1.26-alpine`; otherwise their checked-in container builds could not satisfy the new minimum. LiveKit already uses a 1.26 builder. CI uses `go-version-file: ${{ matrix.module }}/go.mod` in `.github/workflows/ci.yml`, so it follows each declared minimum.
- No source API edits were required. All packages compiled and passed their existing tests against the new direct releases. No major module-path change was needed for an imported direct package.

## Version inventory

| Module | Before → after direct modules | `go` directive | Production/test modules with an available update |
| --- | --- | --- | ---: |
| `livekit-jwt` | `github.com/livekit/protocol` 1.46.4 → 1.52.1 | 1.26 → 1.26.0 | 0 / 0 (64 modules used) |
| `loyalty` | `go-ethereum` 1.13.14 → 1.17.6; `gin` 1.9.1 → 1.12.0; `lib/pq` 1.10.9 → 1.12.3 | 1.22 → 1.26.0 | 0 / 0 (42 modules used) |
| `social-auth` | none | 1.22 unchanged | 0 / 0 (1 local module) |
| `swap` | Same Ethereum, Gin, and pq upgrades; `sqlx` 1.3.5 → 1.4.0; `uuid` 1.6.0 unchanged/latest | 1.22 → 1.26.0 | 0 / 0 (43 modules used) |

Each updated `go.mod` also advances its indirect requirements used by the main packages. In both Ethereum modules, `golang.org/x/exp` still lagged after `go get -u ./...`; an explicit `go get golang.org/x/exp@latest` advanced it to `v0.0.0-20260908205506-85c1c2202aba`, then tidy and verification passed. The direct requirements are stable tagged releases. The Go graph contains upstream pseudo versions where those projects do not publish semver tags; no new prerelease tag was selected.

## Update queries and actual dependency use

`go list -m -u all` completed for all four modules. Its final broad module graph still reports 34 available updates for LiveKit, 84 for loyalty, and 87 for swap. These entries are dependencies listed by upstream modules that the local production or test package builds do not actually import. I compared each update's module path with the `Module` objects returned by both `go list -deps -json ./...` and `go list -deps -test -json ./...`. Each intersection is empty. The exact full update lists are in `27-livekit-updates2.log.gz`, `48-loyalty-final-updates.log.gz`, and `49-swap-final-updates.log.gz`; the module/version sets are in `used-modules-*.log.gz` and `test-modules-*.log.gz`, and the comparison result is in `50-used-module-audit.log.gz` and `51-test-module-audit.log.gz`. I did not add unused upstream modules to this app's `go.mod` solely to raise their selected versions.

An earlier parallel update query for swap failed because concurrent metadata fetches changed a shared shallow Git cache file (`29-swap-updates2.log.gz`). After the other queries finished, the serial swap retry and final serial query succeeded (`30-swap-updates-retry.log.gz`, `49-swap-final-updates.log.gz`). This was a local cache race, not a remaining module lookup failure. The old `go-bip39` update lookup failure seen in baseline did not recur in the final queries.

The resolved graph's highest declared Go version is **1.26.0** for each updated module, verified by `go list -m -json all` (`47-toolchain-caps.log.gz`). None of the 161 LiveKit, 214 loyalty, or 218 swap selected graph modules requests a Go version above installed 1.26.5. No `toolchain` directive appears in any module.

## Verification

| Module | `go test ./...` | Test functions | `go vet ./...` | `go mod tidy -diff` | Final update query |
| --- | --- | ---: | --- | --- | --- |
| `livekit-jwt` | pass (`38-livekit-final-test.log.gz`) | 27 | pass (`39-livekit-final-vet.log.gz`) | clean (`43-livekit-tidy-diff.log.gz`) | pass |
| `loyalty` | pass (`36-loyalty-final-test.log.gz`) | 9 | pass (`40-loyalty-final-vet.log.gz`) | clean (`44-loyalty-tidy-diff.log.gz`) | pass |
| `social-auth` | pass (`23-social-test.log.gz`) | 10 | pass (`42-social-final-vet.log.gz`) | clean (`46-social-tidy-diff.log.gz`) | pass (`11-social-updates.log.gz`) |
| `swap` | pass, all six packages (`37-swap-final-test.log.gz`) | 45 | pass (`41-swap-final-vet.log.gz`) | clean (`45-swap-tidy-diff.log.gz`) | pass |

Test-function counts are `func Test...` declarations and do not count subtests. The final test output says `(cached)` for some packages; the preceding uncached-by-change runs are in `18-livekit-test.log.gz`, `19-loyalty-test.log.gz`, and `21-swap-test.log.gz`. These are local Go test and vet results. A container build was not run, so the Docker image change has static review and matching toolchain evidence, not a container runtime result.

## Commit and review

Commit: `6f9505574 chore: upgrade Go service dependencies`. The English subject was checked for Chinese characters before commit. The repository's pre-commit hook bumped `pubspec.yaml` from `2.4.8+2026072834` to `2.4.8+2026072835` and included it in the commit, as anticipated by the repository guidelines. `git diff --cached --check` passed before commit; the worktree is clean afterward.
