# Account switching and encrypted message regression — 2026-09-18

## Report and diagnosis

The supplied `2.mov` records 2.4.8 (2026072690), with dxx and dxx01 alternating through **Log Out**, then signing in again. Outgoing messages remain readable while incoming messages can lack their encryption keys.

A disposable-account reproduction against the production Matrix service confirmed this sequence: the recipient logs out, the sender sends and then logs out, and the recipient returns as a new device. The recipient cannot decrypt; the sender can read its locally retained copy. Local key snapshots cannot contain keys that were never received.

The user approved using **Switch Account** with independent retained sessions. Explicit Log Out continues to revoke the session.

## Change

Chat dependency: `e1598c798db499b79309fe806a2c0e750c9272ad`.

- Keep a separate Matrix database and cryptographic device identity for each server/user/device combination.
- Restore the saved database without replacing its Olm identity with token-only initialization.
- Bootstrap an external token only if the server confirms its device has not already published keys.
- Restore the previous session if a new login fails; isolate homeserver probes from the active authenticated client.
- Add a localized **Switch Account** entry in Settings and the logout confirmation.
- Keep logout revocation and account isolation; do not share keys across accounts or disable encryption.

## User workflow

1. Open Settings → Switch Account.
2. Add and sign in to the other account once, then use the account list for subsequent switches.
3. If an older saved entry was already invalidated by logout, use Add Account to sign in again. The change cannot reconstruct a deleted device identity.
4. Use Log Out when intending to revoke that account's session. Offline messages addressed to a deleted device still cannot be guaranteed recoverable without another key source or recovery setup.

## Validation

- Chat focused regression: 84 passed; opt-in live test skipped in the normal run.
- Main application Chat regression: 935 passed.
- Main application analyzer: zero errors/warnings; 232 informational findings.
- Chat analyzer: zero errors/warnings; 250 informational findings.
- All 783 resolved Chat library/asset files match the application mirror.
- Real MatrixClientManager live test passed with the main app's Matrix SDK 6.2.0, and earlier with Chat's SDK 6.1: A→B and B→A offline delivery decrypts; device identity remains stable; manager restart preserves both sessions; failed login restores the previous session; explicit logout affects its own session only.
- All temporary live-test accounts were deactivated (2/2 for the final app run).
- Initial concurrent app test invocations collided while preparing a native asset; the standalone live rerun passed.

The live test uses real server requests, native cryptography and SQLite, with mocked secure storage/preferences. It does not replace iOS/Android hardware regression or a full OS process-restart test. No user credentials or raw logs are included here.

## Release status and limits

This source fix is not present in build 2026072690. No new TestFlight upload or APK was produced for this task. Verify both platforms after the next release, including account switching, full application restart, offline incoming messages and account isolation. Previously missing message keys remain outside this fix.
