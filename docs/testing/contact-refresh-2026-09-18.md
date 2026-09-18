# Contact refresh failure — 2026-09-18

The user reports a contact-refresh failure when switching to the Contacts tab.
The affected build, account, and whether cached contacts remain visible have
not yet been confirmed. No matching diagnostic was found in the currently
connected Android device's recent filtered logs; that device is not established
as the feedback device.

## Reproduced path and repair

A historical direct-room mapping can remain after the peer's member state no
longer exists. `resolveDirectPeer` queried that state and propagated
`M_NOT_FOUND`. With no other accepted friends, contact hydration then threw
`ContactMembershipUnavailable`, showing an error for an otherwise empty list.

Chat commit `9e9460c6d0c87d645776bcc27273576965838a36` treats this specific
response as a non-joined peer. The cache gets non-joined membership; no server
membership event, account-data rewrite, room deletion or history deletion occurs.
The send guard still rejects the peer. Forbidden requests, expired sessions,
rate limits, timeouts and other errors are not converted into successful refresh.

## Evidence and limitations

- Two new regression cases failed before the repair, covering missing members
  in both initial lookup and authoritative state lookup; both pass afterward.
- A real Matrix SDK Room with a stale direct mapping verifies an empty contact
  list, no outgoing request fabricated, blocked sending and preserved mapping.
- Explicit `M_FORBIDDEN`, `M_UNKNOWN_TOKEN` and `M_LIMIT_EXCEEDED` cases verify
  that real failures remain errors. Existing unavailable-membership coverage
  still passes.
- Chat contact datasource/repository/bloc suite: 134 passed before adding the
  extra real-Room case; the final datasource suite passes all 30 cases.
- The changed production file and its tests pass targeted analysis.
- App-resolved Matrix SDK 6.2.0: 554 contact/Chat feedback regression tests
  passed; wallet analysis has zero errors/warnings and 196 informational
  diagnostics. All 779 mirrored lib/assets files match the resolved Git package.

The app's Git dependency and cache mirror are updated together. This addresses
a reproduced code defect; it does not establish that the user's device emitted
`M_NOT_FOUND`. Keep QA-009 open until the affected version/account and error are
correlated, and tab switching is verified on the replacement installation. Do
not suppress every refresh error or clear user data as a workaround.

## User follow-up

The user identified account **okle**, said the failure was on build
2026072679, and confirmed contacts now display normally. This closes the
reported contact-tab symptom; other QA-009 acceptance items remain open.
