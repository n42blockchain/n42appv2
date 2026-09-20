# Message-key retention regression — September 19, 2026

## User acceptance

The user tested TestFlight 2.4.8 (2026072692) and confirmed ten other items passed. Encrypted-message readability remains failing. The current switch-versus-explicit-logout workflow and whether newly received messages fail have not yet been confirmed. This report does not close feedback-phone acceptance.

## Reproduced cause

The previous live test sent one message in each direction and reopened the accounts. Extending it to reuse A's outbound session after another account switch reproduces history loss:

1. A sends to B; B reads it.
2. B sends to A; A reads it.
3. A sends a second message using the same outbound session.
4. Switch to B, read the new message, restart/switch accounts and reread A's first message.

The first message becomes `m.bad.encrypted`: first known key index 1, message index 0. This failed repeatedly with real SQLite, vodozemac and the production Matrix server. Matrix 6.x compares incoming Megolm keys with the memory cache only. After reopening an account, a later-index key can overwrite the earlier key on disk before it has been loaded into memory.

## Changes

- A small Client subclass loads existing inbound sessions before its first sync for each encryption identity, including the sync initiated inside SDK initialization. A storage failure blocks sync and permits retry.
- Local history snapshot restoration loads missing sessions without clearing existing ratchets from memory.
- Message-list and single-message streams subscribe before their initial emission. A separate deterministic test showed a key-arrival notification was previously lost while the consumer paused at that initial emission.
- Observer cancellation remains nonblocking, including consumers requesting only the first emission.
- The live acceptance test now retains the application message repository across account changes and checks repeat-session messages and historical readability.

No device trust policy, encryption algorithm, recipient permissions or account isolation was relaxed. This does not guarantee recovery of earlier keys already overwritten without another retained copy.

## Verification

- 66 focused encryption and message-repository tests passed.
- 461 integrated application regressions passed with the pinned Chat dependency (account switching, local history and TestFlight feedback suites).
- The paused-consumer test failed before the stream change and passes after it.
- Extended live acceptance passed after the key-preservation change: bidirectional offline delivery, repeat-session delivery, historical readability after restart/switch, unchanged device identities, failed-login rollback and explicit-logout isolation.
- Main application analysis completed with zero errors/warnings and 236 informational notices.
- Both temporary live-test accounts were deactivated after each run. Credentials and raw crypto logs are excluded from this repository.
- The live test uses real Matrix 6.2.0/SQLite/crypto but mocked platform secure storage/preferences. It does not replace iPhone/Android acceptance.

## Remaining acceptance

TestFlight 2692 lacks these changes. Verify new bidirectional messages, several account switches, app termination/relaunch and old-message readability on the feedback devices. Explicit logout still revokes the device; switching accounts retains it. Initial sync loads all persisted inbound sessions once per encryption identity; startup performance with large histories remains unmeasured.
