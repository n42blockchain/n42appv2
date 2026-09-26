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

## Android compatibility layer

`prepare_android_source.sh` adds only the reviewed Android source and module
changes to a fresh output of `prepare_source.sh`. It pins Go 1.26's mobile tool
directive and its related `x/*` versions, `cilium/ebpf` 0.22.0, and exact
`go.mod`/`go.sum` hashes. It patches only artificial unsafe array bounds for
32-bit ARM, the Android x86_64 BLST `sigaction` initializer, and anet's private
Go zone-cache linknames. The exact upstream anet 0.0.5 and BLST 0.3.17 module
ZIP hashes are checked before extraction; the reviewed anet copy contains only
the root Go source and legal/module files, excluding its unrelated bundled AAR.
BLST's `blst.tgo` template and generated `blst.go` have the same one-line fix.
The three small serialization/mmap tests freeze unpatched wire bytes and test
small-file behavior. The anet fixture proves that a known interface index can
be carried as a numeric IPv6 zone through public Go APIs.

The anet change is limited to this mobile `Emit` build. Generic named link-local
zones are **not** equivalent when Android prevents Go's interface lookup:
`%wlan0` can resolve to scope zero while `%7` retains index 7. The current
mobile libp2p configuration uses TCP and QUIC; its imported WebRTC/ICE package
is not shown to be instantiated by this SDK path. The inspected geth STUN
path uses direct `net.Dial`. If a future reachable consumer needs named scoped
addresses, it needs a bounded public-interface-index conversion at that socket
boundary. The fixture does not prove actual scoped network traffic or broad
anet compatibility.

For a prepared Android source, prefetch the **source** and **generated gobind**
module graphs separately from the public Go proxy and checksum database, then
build with Go module-fetch routes disabled. These scripts do not create an OS
network sandbox. Both scripts refuse an existing output
directory; use task-owned paths and the pinned Go 1.26.8, gomobile/gobind, NDK
28.2 and JDK 21 inputs. The prefetch requires an explicit public-fetch flag.

```sh
/bin/bash tools/android_native_smoke/go_evm_v5_7_906/prepare_android_source.sh \
  /path/to/N42-gov5 /path/to/verified-go-modcache /path/to/new-android-source
N42_ALLOW_PUBLIC_MODULE_FETCH=yes /bin/bash \
  tools/android_native_smoke/go_evm_v5_7_906/prefetch_android_modules.sh \
  /path/to/new-android-source /path/to/verified-go-modcache /path/to/new-prefetch
/bin/bash tools/android_native_smoke/go_evm_v5_7_906/build_android_aar.sh \
  /path/to/new-android-source /path/to/verified-go-modcache \
  /path/to/pinned-gomobile-and-gobind /path/to/android-sdk-37 \
  /path/to/jdk-21 /path/to/new-build-run
```

`build_android_aar.sh` checks both offline module graphs before binding all
three shipping ABIs. It compares the retained generated Go module graph and
checksums for **each** ABI against the normalized, reviewed graph in
`android/generated/`. The only normalization is the prepared source directory
in the three local `replace` paths; selected versions and checksums must match.
It pins `ANDROID_NDK_HOME` to the checked 28.2 installation and verifies its
revision, metadata and clang hashes. Both scripts disable persistent Go
settings and clear inherited private-module routes. Their `go-env.json` files
record effective module routing; `--check-environment` and `--preflight-only`
allow bounded inspection without a public fetch or native bind.
The candidate AAR still needs its own Java descriptor, ELF alignment, binary
security scan, offline device protocol, app integration, and release packaging
checks. A prior AAR's passing device run does not carry over to a rebuilt hash.
