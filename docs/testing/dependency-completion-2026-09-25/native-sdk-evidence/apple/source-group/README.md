# Task 16E source and host fixture evidence

This archive records the first bounded Apple SDK source/Swift/Dart group. The
source is the N42 `mobile-sdk-v0.2.2` commit
`2099ec735a658ba1db97c49b77a6c58c1fc82920`, Reth `v1.4.3` commit
`fe3653ffe602d4e85ad213e8bd9f06e7b710c0c5`, the five reviewed Android
portable patches, lock SHA-256 `7e255879661c166546a70e21c0fa7d2e8cb76705a0d4a5fd214d48630db630ca`,
and Apple patch SHA-256 `28fcd58ec016d5fa5ff0145d7bbc2146d18fcf099606406437c6fabd664f4465`.
`source-manifest.txt` is the independent network replay output; the tested
`Cargo.toml` and `c_ffi.rs` hashes match that replay.

| Test | Raw transcript and exit | Result |
| --- | --- | --- |
| Rust C FFI first three tests before fix | `cffi-red.*` | exit 101: invalid fee, stale error and interior-NUL tests failed |
| Rust first fix | `cffi-green-1.*` | exit 0: three tests passed |
| Injected runtime-constructor mutation | `runtime-mutation-red.*` | exit 101: expected failure test caught wrong result |
| Rust library after restoring source | `cffi-full-lib-green.*` | exit 0: 14 library tests passed |
| Swift pointer shim before fix | `swift-red.*` | exit 1: both-result-and-error returned success |
| Swift pointer shim after fix | `swift-green.*` | exit 0: 13 pointer cases passed |
| Dart null exit before fix | `dart-exit-red.*` | exit 1: transaction send was attempted |
| Dart null exit after fix | `dart-exit-green.*` | exit 0: 1 focused test passed |
| macOS host static library | `host-staticlib-build.*` | exit 0 |
| Host C ABI fixture | `host-c-abi-final.*`, `runtime.log`, `inputs.sha256` | exit 0: 7 transaction cases, BLS relationship, error contract |

The C test links a macOS archive. Its transaction decoder compares the exact
synthetic output with the maintained Android v0.2.2 source fixture, **not** the
old iOS device archive. It does not invoke a valid `run_client_c` or a live
validator. No valid offline block-verification golden is available. The host
link log retains warnings from objects targeting macOS 27 while the test host
links against macOS 26; the executable ran on macOS 26.6.2. The iOS device
archive, host iOS app link and physical-device runtime remain separate gates.

`artifact-inputs.sha256` records the unchanged old device and simulator inputs
and the byte-identical generated/current header. `cbindgen-install.*` and
`rust-target-install.*` record the isolated tool setup. Generated archives,
Cargo caches and synthetic random private keys are not stored here.
