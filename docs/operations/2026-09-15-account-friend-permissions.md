# Account friendship permissions — clarified 2026-09-15

Status: requirements confirmed; implementation and production acceptance pending.
This is not included in TestFlight 2.4.8 (2026072659).

## Required account-level settings

Entry: Settings → Chat. These controls apply to the signed-in account and do not
require selecting a contact. Preserve the existing background, quick replies,
translation and download options.

| Section / control | Required behavior |
| --- | --- |
| 加好友权限 / 需要验证 | Default. A request remains pending until the recipient accepts. Only then do both accounts become friends and gain access to friend-only messaging. |
| 加好友权限 / 开放 | The account owner explicitly permits new requests to become friendships without manual approval. Both accounts must observe the accepted relationship, including when the recipient app is offline. |
| 加好友权限 / 关闭 | Reject new incoming friend requests before creating a pending request or friendship. Existing friends are retained. |
| 可发现性 / 允许被搜索 | Control whether others can find the account through the supported nickname, email and phone search paths. A disabled option must affect server search results, not just the owner's local view. |
| 隐私 / 黑名单 | Show blocked users and allow removal from the blocklist; blocking takes precedence over the open friendship mode. |

The supplied descriptions are: “对方发送申请后，需你同意才能成为好友。”;
“任何人无需验证即可加你为好友。”; “任何人都无法向你发送好友申请。”;
“允许他人通过昵称、邮箱或手机号找到你”; “管理已拉黑的用户”.
These descriptions are acceptance requirements, not a claim about current behavior.
Email/phone discovery must only use supported, verified bindings; the current
registration email field is not proof of an established searchable binding.

## Verified implementation gap

The local Mintus reference (`minto/mobile-consumer/src/screens/ChatSettingsScreen.tsx`)
uses an authenticated backend: `GET`/`PUT /chat/settings` reads and writes
`friendPermission` (`REQUIRE_APPROVAL`, `OPEN`, `CLOSED`) and `chatSearchable`.
Its `backend/src/controllers/chat-settings.controller.ts` persists account values,
and `backend/src/services/friend.service.ts` checks recipient permissions when
handling requests. Those endpoints and identities are not currently integrated
with wallet Chat; they cannot simply be called with a Matrix access token.

Wallet Chat currently has:

- `lib/src/presentation/pages/settings/chat_settings_page.dart`: background,
  quick replies, translation and downloads; no own-account friendship controls.
- `lib/src/data/datasources/matrix/matrix_contact_datasource.dart`: searches the
  Matrix directory and uses direct-room invitations for friendship requests.
- `lib/src/domain/repositories/contact_repository.dart`: ignored-user list and
  block/unblock methods, but no global request-policy contract.
- `lib/src/data/datasources/matrix/matrix_client_manager.dart`: privacy network
  preferences concern proxy routing, not incoming friendship authorization.

Private account data or local preferences alone cannot prevent another client
from sending invitations or remove an account from server directory results.
Automatically leaving an invitation after sync does not satisfy “cannot send a
request”; accepting only when the recipient app runs does not satisfy offline
open-mode behavior. Keep the existing mutual-membership send guard until the
accepted relationship is established; do not reintroduce asymmetric friendships.

## Implementation handoff

1. Inspect the deployed Matrix version and service configuration, and identify an
   enforceable integration point for invitations, account policy and directory
   search. Deployment access is currently unavailable: the authorized read-only
   SSH attempt to `root@5.78.152.227` still returns public-key authentication
   failure. The actual SSH login user/key installation remains to be confirmed.
2. Select the backend contract against that deployment. Authenticate changes as
   the policy owner; keep account state isolated across users and persistent
   across logout, device changes and reinstalls. Do not assume Mintus's backend
   is already connected or invent a deployed Matrix endpoint.
3. Enforce closed/verification/open modes for all friend-request paths, including
   QR, search, profile and retry. Cover older clients and direct Matrix invites,
   or explicitly constrain supported clients before claiming the permission.
   Preserve blocked-user checks, accepted friendship consistency and E2EE.
4. Apply discoverability at the directory source and supported identity lookup
   paths. Hiding directory results does not revoke an already shared Matrix ID;
   friendship permission independently controls requests to known IDs.
5. Add the three mutually exclusive options, discovery switch and blocklist
   entry to the global Chat page; translate them for all supported locales.
   Load authoritative state, serialize saves, display failures and never report
   an unsaved setting as active. Do not display fabricated defaults on a failed
   load. Reuse the existing Matrix ignored-user repository for the blocklist.

## Required acceptance

Use dedicated accounts A/B/C on iOS and Android. Do not reuse passwords or
recovery keys from user screenshots.

- Default verification: request pending on both sides; no premature contact or
  messaging access; accepting establishes both sides, rejecting does not.
- Open: establish both sides without manual approval, including with B offline;
  verify encrypted messaging and logout/login history remain correct.
- Closed: no new pending requests through QR, search, known ID or direct invite;
  do not remove existing friends. Explicitly test treatment of earlier pending
  requests and ensure changing modes never silently accepts old requests.
- Search off/on: confirm result suppression/restoration from another account for
  each supported lookup type; unsupported/unverified email/phone paths must not
  be described as working. Existing contacts and known-ID behavior stay distinct.
- Blocked user: cannot bypass blocking using open mode or another request path;
  removing a block does not itself create or accept a friendship.
- Persistence: same account on another device, logout/login, switching between
  different accounts and restarting the application; no cross-account leakage.
- Save/load failure, rapid toggles, concurrent requests and policy updates:
  authoritative state remains consistent; no false success or stale UI rollback.

Canonical unresolved tracking: Chat repository `OPEN_ISSUES.md`, `QA-009`.
