# Falcon-512 wallet integration

The Wallet Management screen opens an independent Falcon-512 account for an
eligible local wallet. Existing EVM recovery phrases do not restore this account.
Watch-only wallets cannot create or sign with it.

The implementation uses PQClean padded Falcon-512: 897-byte public keys,
1281-byte secret keys and 666-byte signatures. Native libraries are included for
iOS device/simulator and four Android ABIs. Build them from the locked source:

```sh
bash scripts/build_falcon_native.sh all
cargo build --locked --release --manifest-path rust/n42_pq/Cargo.toml
N42_PQ_LIBRARY="$PWD/rust/n42_pq/target/release/libn42_pq.dylib" \
  /Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin/flutter test --no-pub \
  test/features/wallet/falcon
```

Each sensitive operation requires OS device authentication. Secret keys live in
FlutterSecureStorage. Backups use PBKDF2-HMAC-SHA256 (310,000 iterations), a random
salt and AES-256-GCM. The wallet verifies a saved backup before allowing sends.
An account is never overwritten by creation or restore. The UI supports native
value transfers, exact integer wei and an explicit transaction/RPC preview.

Sending requires an exact `n42_getPQCapabilities` handshake, chain ID, pending
nonce and sufficient balance. The wallet checks its owner after asynchronous
steps, verifies the native signature locally, and persists an account-level
pending record before one broadcast. Timeouts, RPC errors and mismatched hashes
retain this record. Query the original transaction; do not re-send a payment on
an unknown result. Canonical receipts need 12 confirmations before the pending
record is cleared. A failed receipt is reported as failed.

Offline exports include the signed raw transaction and its reviewed fields.
They contain public signatures, not secret keys. Backup exports contain the
password-encrypted secret and must be kept separate from their password.

The N42-rs and N42-gov5 feature branches provide matching 0x05 codecs and actual
signature verification. Existing endpoints remain disabled until an operator
activates compatible chain configuration. See each client's
`docs/spec/N42_TX_0x05.md` for activation and seven-node acceptance steps.

## Acceptance boundaries

- Local automated tests and native builds do not prove production deployment.
- No real-device acceptance, mainnet send, App Store release or seven-node
  activation is included. Real-device QA was deferred at the user's request.
- New Falcon accounts need test funding after backup verification. The existing
  seven-node operator must confirm its endpoint and activation plan.
- This is Falcon-512 support, not a final FN-DSA/FIPS 206 certification or an
  independent cryptographic audit.

## Local evidence, 2026-10-30

- Falcon native/transaction/network suite: 15 passed with the real native library.
- Wallet management, signing policy, amount properties, serialization and EVM
  exact-amount regression suite: 46 passed (includes the earlier Falcon suite).
- Changed Dart source and tests: analyzer reported no issues.
- iOS x86_64 simulator Runner build: succeeded. All three `n42_pq_*` FFI entry
  points are present in the linked Runner.debug.dylib.
- iOS device/simulator native archives and all four Android native libraries
  rebuilt from the locked Rust crate. Full Android app/device QA is separate.
- Go client verifies the Dart public fixture. Rust verifies both independently
  generated wallet and Go fixtures, with storage/pool/JSON roundtrips.
- Wallet management route/owner/watch-only widget checks: 4 passed.
- Android `:app:mergeDebugNativeLibs` with JDK 21: succeeded. Packaged Falcon
  libraries match source SHA-256 hashes for arm64-v8a, armeabi-v7a, x86 and
  x86_64. This verifies packaging, not Android device runtime acceptance.
