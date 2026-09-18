# Chat feedback repairs — 2026-09-18

Chat source: `aed4d9539f6e12c64e347c543ec930119b025d54` (implementation `8b471847`).

## Changes

- Explicit logout/logoutAll preserves inbound history sessions in device secure storage, isolated by homeserver and user. Authenticated login restores missing sessions before opening Chat. Failed snapshot writes/readback abort logout and keep the session usable. Snapshots exclude access tokens, passwords, Olm identity and outbound ratchets; account deactivation deletes its snapshot. Native Megolm regression encrypts before logout, clears the database through the production auth datasource, logs in and decrypts the original ciphertext after restoration. The platform secure store is mocked.
- Caller alone publishes a call summary, with a stable transaction ID and per-call deduplication. Freeze duration before cleanup; hide local pending signaling bubbles. Remote termination cancels pending media setup. Both peers must upgrade to stop older receiver clients publishing records.
- Chat-only friend rows open the friend's profile and reload the permission-filtered list on return.
- File-picker paths/streams in encrypted rooms previously threw UnsupportedError. Read bounded bytes and use the SDK encrypted attachment path; encrypted failures never fall back to plaintext upload. The existing 50 MB application file limit bounds memory reads, including streams with inaccurate declared sizes. Larger encrypted files still need streaming encryption support.
- Resolve GPS and manually selected map-center addresses. Preserve the address in outgoing message text instead of discarding it in favor of “My location”; allow two lines on the card. Offline/geocoder failure retains coordinates rather than inventing a place.
- User clarified the okle contact-refresh failure was on 2026072679 and now displays normally.

## Verification

- Chat targeted suite: **188 passed**, including history preservation/storage failure, call races and caller-only records, profile navigation, file path/stream encryption routing, failed encrypted upload, address lookup and offline fallback.
- Chat analysis: **0 errors, 0 warnings**, 219 informational diagnostics.
- App-resolved Matrix SDK **6.2.0**: **545 passed** across feedback, local-history and contacts/groups wrappers. Native crypto suites run in separate test processes to avoid duplicate flutter_rust_bridge initialization.
- App analysis: **0 errors, 0 warnings**, 201 informational diagnostics.
- All **780** mirrored Chat lib/assets files match the pinned Git dependency byte-for-byte.
- Test map tile requests are blocked by Flutter's test HTTP client; location assertions use controlled native geocoder results and do not assert live map availability.

## Acceptance limits

The user's Downloads/1.mov shows readable messages before logout and encrypted placeholders after re-login; no recovery key was configured. This fix preserves keys held by the upgraded app for later explicit logout on the same device. It cannot recreate already lost keys. Reinstall/device replacement, storage erasure and forced SDK session invalidation are not covered by this hook; retain a recovery backup for those cases.

No user credentials were requested and no production account/contact/history data was modified. This pass does not establish physical iOS Keychain/Android secure-storage persistence, live file upload/download/decryption, native address lookup or bilateral call acceptance. Keep Chat OPEN_ISSUES.md QA-009 and MEDIA-002 open for those gaps. Release upload is not proof of native acceptance.
