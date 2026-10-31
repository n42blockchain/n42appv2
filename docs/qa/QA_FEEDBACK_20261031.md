# Wallet and Chat QA fixes — 2026-10-31

This change addresses the reported backup, new-wallet mnemonic layout, address
book account isolation and QR friend-request flow. It is targeted regression
work. It does not certify a new full device regression of Wallet, Market,
Chat, groups or Moments, and it does not publish an app release.

## Behavior

- Viewing a stored recovery phrase still requires security verification. The
  verification route now identifies the backup operation and authenticates the
  selected wallet, rather than another active wallet. Canceling or changing
  the account cannot reveal the phrase. A null password is treated as unset.
- A wallet without an old password can set its first password. Existing
  passwords still require verification. Storage failure keeps the form open
  and restores the previous in-memory password instead of reporting success.
- The new-wallet and backup reveal areas use a minimum height rather than a
  fixed height. In the new-wallet screen, the previous layout produced bottom
  overflow at 320px with 1.0, 1.5 and 2.0 text scales. The same cases now pass
  with visible labels and recovery words inside their cells.
- SQLite schema v8 adds an indexed `userUuid` to AddressBook. All lists,
  coin filters, searches, updates and deletes require that owner. Add/edit
  screens retain their original account binding across asynchronous work.
  Rows from old versions have no trustworthy owner: they remain in the
  database with a null owner, hidden from accounts. They are not deleted or
  automatically assigned to the first account that signs in.
- Scanning a friend QR opens the existing identity preview. Adding an unknown
  contact now shows a localized request confirmation. Canceling sends no
  request; explicit Send creates one. Existing incoming/outgoing request and
  known-friend behavior remains in place.

## Source and acceptance

The host pins Chat `7ce89fd3188f83baae41b93fdf5c0fe12a34c95b`, based on its
previous `827a02eb` dependency. The wallet's existing Mini App security/NFC
extensions are retained. Formal Chat source was edited in its Git worktree;
no pub-cache or untracked package mirror was edited.

Chat targeted widget, contact repository and Matrix datasource regression:
71 passed. Changed Chat files analyze without issues. Physical two-account
QR scanning, invitation delivery and accept/reject checks remain in Chat's
existing QA-009 ledger. Physical-device acceptance remains deferred as requested.

Host regression with the corrected Chat pin: 55 passed, covering SQLite creation
and migration, account-isolated CRUD/search and delayed operations, address
forms, backup verification, first-password persistence/failure, mnemonic reveal,
and the three small-screen text scales. Changed wallet source and new tests
analyze without issues. These automated results do not replace the deferred
physical-device checks.
