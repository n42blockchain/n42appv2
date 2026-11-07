# Matrix backend upgrade assessment — 2026-11-06

## Verified baseline

Public read-only probes of `https://m.si46.world` identify **Tuwunel 1.9.3**, through both client versions and federation version. Protocol versions through v1.19 are advertised. Login discovery returns application_service, token and password; it does not advertise m.login.sso. Raw public responses are in `matrix-upgrade-2026-11-06.json`. Historical Synapse/1.8.2 deployment notes are not current version evidence.

The pinned Chat package declares Matrix Dart SDK ^15.0.0; its lock resolves 15.0.0. Server software, protocol and Dart SDK version numbers are independent. Existing Web identity Hub success does not establish native homeserver OIDC acceptance.

## Candidate and compatibility

Official latest stable: [Tuwunel 1.9.4](https://github.com/matrix-construct/tuwunel/releases/tag/v1.9.4), released October 10. It fixes federated key-response ownership and knocked-room history exposure; startup also reconciles thread state and repairs database records. Password limits can return M_LIMIT_EXCEEDED. Locked accounts can return M_USER_LOCKED with soft logout; native OIDC remains opt-in. These changes warrant upgrade rehearsal, not an untested live binary replacement.

Code review: Chat maps M_LIMIT_EXCEEDED to rateLimited, and now explicitly maps M_USER_LOCKED and M_USER_DEACTIVATED in password/token login and stored-session restore. AuthBloc exposes these errors without requesting logout; local credentials remain intact. Six regression cases failed before the fix and 97 repository/bloc tests pass (Chat a3e2ea87). SDK 15.0.0's inspected sync recovery handles soft logout inside its M_UNKNOWN_TOKEN branch. Locked-account behavior therefore needs a controlled end-to-end test and possible adapter fix; do not infer compatibility from generic error handling. Inspect UIAA retries with retained request bodies, cross-signing/device recovery, thread redactions, login retry timing, and invited/knocked rooms. Inspected group/space/Moments creation overrides do not explicitly place the creator in the users map, but room-v12 creation/permissions still need live coverage.

No evidence requires a wholesale frontend rewrite or a newer SDK solely to match the server version. Compatibility acceptance must cover password/token/Hub login, lock/recovery without deleting keys, E2EE send/receive and backup restore, reconnect/sync, room creation and roles, media authentication, push and calls. Existing automated tests do not prove acceptance against 1.9.4.

## Deployment sequence and current boundary

1. Inspect the running image digest, actual mounted configuration, database/media paths, disk space and backup jobs. A historical record names `source/deployment/11x/matrix/tuwunel.toml`; its current server location and deployment revision have not been revalidated.
2. Preserve a recoverable database, media and configuration snapshot; prove restoration on an isolated copy. [Official backup guidance](https://github.com/matrix-construct/tuwunel/blob/v1.9.4/docs/backups.md) distinguishes database backups from separately backed-up media. Do not open a live database with a second process.
3. Rehearse the pinned stable release on an isolated database copy with external federation/push prevented. Inspect startup repairs, errors, completion and startup duration. Keep the original snapshot and binary for rollback; do not assume an older binary can open migrated data.
4. Run the frontend/API matrix above. Preserve the existing identity architecture and do not enable native OIDC as an incidental version change.
5. Deploy in a controlled window only after backup/rehearsal and frontend checks, then record version, health, user-visible acceptance and rollback evidence separately.

This turn checked public endpoints and source only. No server restart, upgrade, live account mutation, media migration or physical-device test was performed. Upgrade delivery remains open alongside the existing wallet/Chat maturity work.
