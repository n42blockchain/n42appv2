# Apple MobileSdk v0.2.2 source and host fixtures

`prepare_source.sh NEW_DIRECTORY` fetches the immutable N42 `mobile-sdk-v0.2.2`
tag and Reth `v1.4.3` tag, verifies their commits, pins the three external
crate archives by SHA-256, applies the reviewed Android portable patches and
lock, then applies the Apple C ABI patch. It rejects an existing work directory.
The source remains in its own Git repository so build metadata cannot inherit
the app revision. Build from this prepared source with Rust 1.97.1 and Cargo
`--locked --offline`; do not run the supplier's mutable `build_xcframework.sh`.

The host C fixture uses a **macOS** static library built from this source. It
checks synthetic deposit, exit and fee transactions, BLS secret/public-key
relationship, pointer ownership and malformed-input errors. It invokes
`run_client_c` only with a NULL required argument, which returns before runtime
creation or network work. The transaction oracle is the maintained Android
v0.2.2 source fixture; this does not establish parity with the old packaged
iOS device binary.

```sh
tools/apple_native_smoke/mobile_sdk_v0_2_2/prepare_source.sh NEW_DIRECTORY
cargo +1.97.1 build --locked --offline -p mobile-sdk
cargo +1.97.1 rustc --locked --offline -p mobile-sdk --lib -- --print native-static-libs
tools/apple_native_smoke/mobile_sdk_v0_2_2/run_host_c_abi.sh HOST_STATICLIB GENERATED_HEADER_DIRECTORY BLST_HEADER_DIRECTORY NATIVE_LIBS_LOG NEW_OUTPUT_DIRECTORY
tools/apple_native_smoke/mobile_sdk_v0_2_2/test_swift_bridge.sh NEW_OUTPUT_DIRECTORY
```

Run Cargo commands from `NEW_DIRECTORY/source`; supply its `target/debug/libmobile_sdk.a`
and generated header to the host fixture. Generate the header with pinned
`cbindgen 0.29.2` from `crates/n42/mobile-sdk/ios/cbindgen.toml`. The checked
header is byte-identical to `ios/include/mobile_sdk.h` in this app. The Swift
fixture links a C shim, not the Rust library, and tests both-pointer precedence
and freeing without a validator.

The exact tested input hashes, RED/GREEN transcripts and host run are in
`docs/testing/dependency-completion-2026-09-25/native-sdk-evidence/apple/source-group`.
The host fixture is a source-level ABI check; iOS device execution requires
separate device runtime evidence. Do not use simulator stubs as device evidence.
