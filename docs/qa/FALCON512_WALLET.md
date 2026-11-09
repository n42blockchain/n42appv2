# Falcon-512 wallet integration

The Wallet Management screen opens an independent Falcon-512 account for an
eligible local wallet. Existing EVM recovery phrases do not restore this account.
Watch-only wallets cannot create or sign with it.

The implementation uses PQClean padded Falcon-512: 897-byte public keys,
1281-byte secret keys and 666-byte signatures. Native libraries are included for
iOS device/simulator and four Android ABIs. Build them from the locked source:

```sh
bash scripts/build_falcon_native.sh all
# Host-only verification; does not rebuild or replace the mobile packages.
bash scripts/test_falcon_native.sh
```

The host runner requires Rust/C build tools and the project's Flutter SDK on
PATH (currently Flutter 3.47.8). Set `FLUTTER_BIN` to an explicit Flutter executable
when the default SDK differs. Run `flutter pub get` before it. The runner builds
for the Rust host target into `rust/n42_pq/target/host-tests`, runs the Rust test
and both native Dart suites, and sets `N42_PQ_LIBRARY` for later GitHub Actions
steps. A missing toolchain, failed build or failed test fails the command.

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

## Host verification refresh, 2026-11-06

- Rebuilt from Cargo.lock using rustc 1.97.1 for aarch64-apple-darwin.
- Rust: 1 passed. Real native Dart suites: 16 passed, no skips, exit 0.
- Verified the CI environment-file export with a second successful run.
- Logs: /tmp/n42-falcon-native-b68.log and /tmp/n42-falcon-ci-env-b68.log.
- Local dylib SHA-256: a2befdb8ed3e94333c87ded191fcad1279956c79c4e8dd139803c438587f3349.
- The network suite uses synthetic RPC responses and secure-storage mocks with
  actual native signatures. It does not submit to a node or validate device
  keychain/keystore behavior. Linux CI execution remains to be observed remotely.

## RPC compatibility refresh, 2026-11-09

The public RPC still returns method-not-found for the Falcon capability handshake.
The wallet now reports that this network has not enabled Falcon transactions and
keeps offline signing available. A mismatched response ID, other RPC method or
other error does not receive that compatibility classification. Real loopback
HTTP regression and native crypto/vault/page suites pass all 25 tests. Three Rust
wallet/Go codec tests pass. This is not public-network send or seven-node activation
acceptance. The private-chain mining test also passes: invalid signatures are
rejected, a valid transfer is mined with a successful 0x05 receipt, and recipient
balance, sender nonce and exact value plus gas charge match. This test calls the
actual node RPC handler in one process; it is not a deployed HTTP/wallet send.
