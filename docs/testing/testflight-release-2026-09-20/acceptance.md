# Build 2026072696 — eight-item acceptance checklist

Use the same build on both feedback phones. Automated and server-side results are
recorded separately in ../chat-ux-feedback-2026-09-20/README.md. An unchecked row
means feedback-device acceptance is still pending, not that no code was changed.

| Item | Device acceptance procedure | Passed |
|---|---|---|
| 1. Last message preview | Exchange text both directions, leave/reopen the conversation; compare the last visible message and list preview, including a message received while the page is closed. | [ ] |
| 2. Encrypted messages and sending | First test one account per phone. Then add two accounts to the same phone and use Switch Account; exchange new messages and restart. Finally test explicit logout/relogin followed by newly sent peer messages. Existing missing-key history is separate. A peer logged out of every device should receive a specific unavailable-device explanation. | [ ] |
| 3. AI summary | Open a group with at least two eligible plaintext messages; tap summary and confirm Chinese output. Quota/provider unavailability should show a readable failure rather than Forbidden internals. | [ ] |
| 4. Tags | Open a populated tag, inspect matching contacts, tap a member to open the correct friend profile; change tags and return. | [ ] |
| 5. Starred contacts | Star a friend, confirm one entry in the star section, jump using the star index, unstar and check return to its alphabetic group. | [ ] |
| 6. Group invitations/counts | Invite two accounts; verify joined and pending counts before acceptance and after each acceptance. Normal group invitations still require confirmation. | [ ] |
| 7. Internal invitations | Open Groups with the accounts previously seeing My Moments/My Status. Internal invitations should be absent while ordinary group invitations remain. An ordinary group with a similar name must remain visible. | [ ] |
| 8. Contacts badge | Receive a friend request and ordinary group invitation while viewing Messages. Bottom Contacts count must match actionable entries inside; accept/reject them and confirm count clears. Sent requests/internal social rooms must not count. | [ ] |

Also check both light/dark appearance, enlarged font, failed-search retry,
short-screen menus, and the account selector's active identity. Do not uninstall
or clear app data for regression; preserve each account's independent session.
