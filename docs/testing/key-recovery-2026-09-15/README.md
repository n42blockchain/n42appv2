# Chat key recovery follow-up — 2026-09-15

The user reports a successful key-recovery notice followed by encrypted messages,
alongside “backup not set” in Security. The wallet now pins Chat
`aca3fdad317a8e86a95a664d9bc66bdebae29318`.

The repair distinguishes zero restored sessions from a positive verified count;
positive results explicitly note that messages lacking backed-up keys may remain
encrypted. Recovery imports once, server backup metadata is discovered independently
of cached local secrets, and a device-list failure no longer discards backup metadata.
Verified sessions notify existing Matrix timelines to retry decryption, including
already-known sessions. The recovery dialog disposes its input after the route's
exit animation; Security section surfaces use Material for ListTile feedback.

The canonical [repair report](https://github.com/n42blockchain/n42_chat/blob/aca3fdad317a8e86a95a664d9bc66bdebae29318/docs/KEY_RECOVERY_FEEDBACK_2026-09-15.md)
records details and limits. Seventeen targeted tests pass, including actual SDK
Timeline notification/refresh with mocked cryptographic decryption. The full Chat
suite passes 6,462 tests with one credential-dependent skip; Chat analysis reports
zero errors/warnings and 173 existing infos. This is not proof that the user's
historical keys exist in a backup or that their messages have been recovered.

The wallet's normal Chat feedback suite passes 128 tests; wallet analysis reports
zero errors/warnings and 155 existing infos. All 771 mirrored lib/assets files
match the resolved Git dependency and source manifest. Exact counts and compressed
logs are linked in [summary.json](summary.json). No new wallet-wide coverage run
was performed for this follow-up.

The user's separate friend-permissions question has an existing entry:
**Contacts → select friend → top-right “…” → Set Permissions**. Global Chat settings
cover background, quick replies, translation and automatic downloads.

The uploaded TestFlight build remains **2.4.8+2026072656** and does not contain this
follow-up. No new TestFlight upload or real-account recovery was performed here.
Registration server access at the supplied host still rejects the offered SSH
public key; the service's registration policy remains unchanged. Canonical unresolved
acceptance is tracked in Chat `OPEN_ISSUES.md`, item `QA-009`.
