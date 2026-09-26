# Go V1 mobile SDK candidate source

This recipe starts from the **public** N42-gov5 `v5.7.906` commit
`5083c29735acfc7023ab1fbbd6d6527b7b97cbae`. The same-name local tag in
the older sibling checkout is not the identity. The source repository is read
only; `prepare_source.sh` archives that exact commit into a new task-owned
directory outside the app tree, checks the original `go.mod`, `go.sum` and
reviewed patch hashes, and applies `source.patch`. It refuses an existing
output directory. The resulting archive has no Git metadata, so future Go
commands must use `-buildvcs=false` and identify the source by the commit and
patch hashes recorded here.

The first patch removes raw `Emit` request-value logging. Initial `setting`
and BLS requests can carry a `priv_key`, and the upstream log runs before the
first `log_level` is applied. The patch retains the operation name and response
JSON. Tests capture the real `Emit` stdout path for initial setting and BLS
public-key requests, using synthetic 32-byte material. No validator `start`
or production service is called.

The hash-checked `protocol/` overlay characterizes the app's offline JSON
`setting`, `state`, `stop`, `blspubk`, and `blssign` operations, including
malformed input. It also adds `cmd/evmsdk/mobilebind`: a Go package named
`evmsdk` that exports only `Emit` and delegates to the original engine. The
current app's two Java/Kotlin call sites both use
`evmsdk.Evmsdk.emit(String)`. Binding the whole upstream `cmd/evmsdk` package
fails because its Go-only `GenerateMobileBLSKey` and `DecodeWireHeader`
functions return tuples that gobind cannot represent. The narrow binding
does not rename or remove those upstream functions. A compiled AAR descriptor
check remains required before integration.

Recreate from a Git repository that contains the exact public commit:

```sh
/bin/bash tools/android_native_smoke/go_evm_v5_7_906/prepare_source.sh \
  /path/to/N42-gov5 /private/tmp/n42-task16c-go/source
GOTOOLCHAIN=local GOFLAGS=-buildvcs=false \
  /Users/jieliu/.codex/toolchains/go-1.26.8/go/bin/go \
  test ./cmd/evmsdk ./cmd/evmsdk/mobilebind \
  -run 'TestEmitDoesNotLog|TestAppEmit|TestEmitDelegatesToEngine' -count=1
```

Run the Go command from the prepared source directory. This is **candidate
source only**. No AAR replacement, mobile ABI build, license conclusion or
release acceptance follows from this patch.
