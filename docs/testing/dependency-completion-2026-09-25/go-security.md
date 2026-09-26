# Go standard-library security patch — 2026-09-26

## Change and scope

Execution base: `1dbbe89c055681dce30eca5d5da17ee34b036f08`. The four backend services now require **Go 1.26.8** in `go.mod`; all four Docker builder stages use `golang:1.26.8-alpine`. CI continues to select the exact patch through `go-version-file` and now sets `GOTOOLCHAIN=local`, preventing a hidden toolchain switch. No redundant `toolchain` directive was added. Social-auth's former Go 1.22 minimum is raised deliberately: retaining it would let that standard-library-only service build with an affected compiler/runtime.

This is a toolchain/configuration fix. Service source and dependency versions are unchanged, all three existing `go.sum` files are byte-identical to the execution base, and social-auth still has no external modules or `go.sum`. No opaque Android AAR, global toolchain, coverage threshold, or deployment changed.

## Verified tools and official sources

- [Official Go release metadata](https://go.dev/dl/?mode=json&include=all), retrieved 2026-09-26, confirms **1.26.8** is the latest stable patch in the 1.26 series. The observed standard-library advisories require at least 1.26.6; 1.26.8 incorporates the subsequent patch releases.
- [Official macOS ARM64 archive](https://go.dev/dl/go1.26.8.darwin-arm64.tar.gz) SHA256 was verified before extraction: `a012b25b571bd0138a03dcd25375ceba866fe5ca822f426d2c66a4de56fd3f4b`.
- Isolated executable: `/Users/jieliu/.codex/toolchains/go-1.26.8/go/bin/go`. `/usr/local/go/bin/go` still reports 1.26.5. Commands prepend only the isolated bin directory and use `GOTOOLCHAIN=local`.
- [Docker Official Image tag metadata](https://hub.docker.com/v2/repositories/library/golang/tags/1.26.8-alpine) confirms the tag exists, including Linux amd64 and arm64 images. The observed manifest digest is `sha256:8ac98ca534ac3f51e1f420a1dd2c15e74c75cfa0f23f3ad27eb5d7236c349a0c`. Dockerfiles pin the patch tag, not this digest; rebuilding may therefore receive later base-image updates under the same Go patch tag.
- `govulncheck v1.1.4` was rebuilt with Go 1.26.8 into the ignored task directory, preserving the global scanner. Executable SHA256: `1ee8c00d1b46754fa1331f8bc4c3269172295bc0c2159e8e2e509feb14bc2027`. All final scan records report `go1.26.8`, source/symbol scanning and advisory database timestamp **2026-09-24T20:07:49Z**.

## Before and after

Before this fix, all four services on Go 1.26.5 had reachable standard-library findings: `GO-2026-5026`, `GO-2026-5972`, `GO-2026-6089`, `GO-2026-6090`, and `GO-2026-6218`. These cover HTTP/IDNA processing, ASN.1 recursion, HTTP timeouts, TLS processing and URL path resolution. Original scan output and earlier scanner/toolchain-mismatch failures are preserved in the evidence archive.

After the patch, **all 12 source scans contain zero standard-library findings, zero reachable findings and zero imported affected-package findings**. Scans cover each service on macOS arm64, Linux amd64 and Linux arm64. Linux scans and builds use `CGO_ENABLED=0`, matching the production Dockerfiles. The JSON scanner exits 0 even when it emits findings; results were parsed and classified, not accepted based on exit code alone.

| Service | Host tests / vet / tidy diff / module verification | Host / Linux amd64 / Linux arm64 scans | Linux amd64 / arm64 cross-builds |
| --- | --- | --- | --- |
| livekit-jwt | All pass | No reachable or imported affected-package findings; two module-only advisories | Both pass |
| loyalty | All pass | No reachable or imported affected-package findings; one module-only advisory | Both pass |
| social-auth | All pass | No findings at any level | Both pass |
| swap | All pass | No reachable or imported affected-package findings; one module-only advisory | Both pass |

All **51 recorded commands** exited 0. Tests use `go test -count=1 ./...`; other checks are `go vet ./...`, `go mod tidy -diff` and `go mod verify`. Cross-builds use `go build -trimpath` and write only ignored artifacts. This does not establish container-image execution or deployment behavior: no Docker image was built or run, and Linux binaries were cross-compiled rather than executed. Test execution was on macOS arm64.

## Remaining findings and limits

- [GO-2026-5932](https://vuln.go.dev/ID/GO-2026-5932.json): `golang.org/x/crypto` contains the unmaintained OpenPGP packages. LiveKit, loyalty and swap retain this **module-only** finding. The affected OpenPGP import paths are absent from both host production/test dependency graphs and Linux production dependency graphs on both architectures. No fixed version is reported; do not hide the advisory or claim the entire module is advisory-free.
- [GO-2026-6443](https://vuln.go.dev/ID/GO-2026-6443.json): LiveKit's `google.golang.org/grpc v1.84.0` retains a **module-only** server-panic advisory. Affected `internal/transport` and `internal/xds/server` packages are absent from the checked graphs. The [official Go proxy](https://proxy.golang.org/google.golang.org/grpc/@latest) still identifies 1.84.0 as latest stable. The advisory gives fixes in older 1.82.2/1.83.2 branches and a 1.85 development version; no unreviewed downgrade or prerelease was introduced.
- Module-only classifications reflect the checked build targets and source. New imports, build tags or target architectures require another scan; they are not universal non-exploitability claims.
- Earlier Rust audit of unchanged `rust/n42_mls/Cargo.lock` found zero vulnerability entries but **RUSTSEC-2026-0173**, unmaintained `proc-macro-error2 2.0.1`, through OpenMLS/libcrux/hax macros. That prior audit is retained as a separate ecosystem limitation, not rerun or resolved by this Go patch.
- The user-deferred Flutter coverage gate remains unchanged at 70%; this Go work does not alter or pass that gate. Final-source dependency, release and payment acceptance remains separate.

## Reproduction and evidence

[Compressed exact evidence](go-security-logs.tar.gz), SHA256 `e403302a2c7c18a2313c0be953108e09acb81a9a3e4a1ebd347196b21b36451d`, includes each command's arguments, working directory, environment overrides, timestamp, duration, exit status, stdout and stderr; official metadata snapshots; scanner build details; source hashes; parsed findings; and original failing scans. Executables, cross-built binaries and the downloaded Go archive are excluded.

From the repository root, select the isolated Go toolchain and rebuild the scanner into a task-specific directory. This preserves the global scanner and prevents an incompatible global executable from being selected:

```sh
export PATH="/Users/jieliu/.codex/toolchains/go-1.26.8/go/bin:$PATH"
export GOTOOLCHAIN=local
GO_SECURITY_TOOLS="$PWD/.superpowers/sdd/dependency-completion-20260925/go-security/tools"
mkdir -p "$GO_SECURITY_TOOLS"
GOBIN="$GO_SECURITY_TOOLS" go install golang.org/x/vuln/cmd/govulncheck@v1.1.4
```

Then, in each directory `backend/{livekit-jwt,loyalty,social-auth,swap}`, using that same shell, run:

```sh
go test -count=1 ./...
go vet ./...
go mod tidy -diff
go mod verify
"$GO_SECURITY_TOOLS/govulncheck" -json ./...
go list -deps -test ./...
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 "$GO_SECURITY_TOOLS/govulncheck" -json ./...
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 "$GO_SECURITY_TOOLS/govulncheck" -json ./...
```

The archive's `run_checks.py` also records Linux import inventories and cross-builds. Its paths describe this worktree; adapt the root and isolated tool paths when reproducing elsewhere. `classify_results.py` verifies all scan outputs and intersects advisory package paths with the actual import inventories.
