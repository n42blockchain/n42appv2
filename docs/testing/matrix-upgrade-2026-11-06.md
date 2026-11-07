# Matrix backend upgrade assessment — 2026-11-06

## Verified baseline

Public read-only probes of `https://m.si46.world` identify **Tuwunel 1.9.3**, through both client versions and federation version. Protocol versions through v1.19 are advertised. Login discovery returns application_service, token and password; it does not advertise m.login.sso. Raw public responses are in `matrix-upgrade-2026-11-06.json`. Historical Synapse/1.8.2 deployment notes are not current version evidence.

The pinned Chat package declares Matrix Dart SDK ^15.0.0; its lock resolves 15.0.0. Server software, protocol and Dart SDK version numbers are independent. Existing Web identity Hub success does not establish native homeserver OIDC acceptance.

## Candidate and compatibility

Official latest stable: [Tuwunel 1.9.4](https://github.com/matrix-construct/tuwunel/releases/tag/v1.9.4), released October 10. It fixes federated key-response ownership and knocked-room history exposure; startup also reconciles thread state and repairs database records. Password limits can return M_LIMIT_EXCEEDED. Locked accounts can return M_USER_LOCKED with soft logout; native OIDC remains opt-in. These changes warrant upgrade rehearsal, not an untested live binary replacement.

Code review: Chat maps M_LIMIT_EXCEEDED to rateLimited, and now explicitly maps M_USER_LOCKED and M_USER_DEACTIVATED in password/token login and stored-session restore. AuthBloc exposes these errors without requesting logout; local credentials remain intact. Six regression cases failed before the fix and 97 repository/bloc tests pass (Chat a3e2ea87). SDK 15.0.0's inspected sync recovery handles soft logout inside its M_UNKNOWN_TOKEN branch. Batch 250 now exercises the real SDK sync loop with a temporary SQLite database and simulated HTTP responses: locked/deactivated errors preserve the token, identity, stored client row and account-data marker without logout/session-clear; a successful sync after unlocking advances the cursor. Combined SDK/repository/bloc tests: 99 pass; new test analysis clean. This is not real cryptographic key recovery or live server acceptance. Do not convert locked-account errors into destructive logout. Batch 251 adds localized generic load-failure, retry and close controls to the initial-sync overlay. Close works even while the initial request is pending and does not logout or stop sync. Retry is single-flight and checks the captured client/user/device/token/homeserver. Four pre-fix widget failures reproduced; 110 related tests pass, followed by 11 final-source widget tests and clean scoped analysis. Lock-specific explanations and real-device recovery UX still need acceptance. Inspect UIAA retries with retained request bodies, cross-signing/device recovery, thread redactions, login retry timing, and invited/knocked rooms. Inspected group/space/Moments creation overrides do not explicitly place the creator in the users map, but room-v12 creation/permissions still need live coverage.

No evidence requires a wholesale frontend rewrite or a newer SDK solely to match the server version. Compatibility acceptance must cover password/token/Hub login, lock/recovery without deleting keys, E2EE send/receive and backup restore, reconnect/sync, room creation and roles, media authentication, push and calls. Existing automated tests do not prove acceptance against 1.9.4.

## Deployment sequence and current boundary

1. Inspect the running image digest, actual mounted configuration, database/media paths, disk space and backup jobs. A historical record names `source/deployment/11x/matrix/tuwunel.toml`; its current server location and deployment revision have not been revalidated.
2. Preserve a recoverable database, media and configuration snapshot; prove restoration on an isolated copy. [Official backup guidance](https://github.com/matrix-construct/tuwunel/blob/v1.9.4/docs/backups.md) distinguishes database backups from separately backed-up media. Do not open a live database with a second process.
3. Rehearse the pinned stable release on an isolated database copy with external federation/push prevented. Inspect startup repairs, errors, completion and startup duration. Keep the original snapshot and binary for rollback; do not assume an older binary can open migrated data.
4. Run the frontend/API matrix above. Preserve the existing identity architecture and do not enable native OIDC as an incidental version change.
5. Deploy in a controlled window only after backup/rehearsal and frontend checks, then record version, health, user-visible acceptance and rollback evidence separately.

This turn checked public endpoints and source only. No server restart, upgrade, live account mutation, media migration or physical-device test was performed. Upgrade delivery remains open alongside the existing wallet/Chat maturity work.

## Deployment discovery — 2026-11-07

Read-only SSH through the domain gateway now reaches `matrix01` at `10.0.0.3`. Running homeserver: `matrix-homeserver-1`, healthy, image `jevolk/tuwunel:v1.9.3`, local image ID `sha256:19b42dc95e279f97eb1509be7fe4a254b41f9f2860a9354b2c5ecb096675ab76`.

Compose working directory: `/home/ubuntu/source/deployment/11x/matrix`; config file `docker-compose.yml`. Docker volume `matrix_db` mounts at `/var/lib/tuwunel`; `tuwunel.toml` is a read-only bind at `/etc/tuwunel.toml`. Root disk has 118 GiB available; host memory is 15 GiB. Configuration secrets were not printed. No upgrade/restart has occurred. Next: inspect backup facilities, volume size and media paths, obtain a recoverable snapshot and rehearse isolated restoration before deployment.

## Consistent recovery point — 2026-11-07

The homeserver was stopped, its entire `matrix_db` volume (including media) archived, and the original container restarted. Public federation version again reports 1.9.3 and Docker health is healthy. Recovery set: `/home/ubuntu/backup/matrix-upgrade-20261107`, directory 0700, configuration copies and data archive 0600. Archive `data.tar` is approximately 2.7 GiB; SHA-256 `bbd489517b9fc4229506d6176c3b21b1580b186f39de00633e96cc52127182e9`. Old repository digest: `jevolk/tuwunel@sha256:678b7f5350e06a41614444497c587da9dddf66767e4068a27480402f3c1367d0`.

This is a consistent on-host recovery point, not yet an independently stored backup or a proven restore. Next: extract into an isolated directory, rehearse startup with network disabled, verify the stable candidate image, then perform controlled upgrade. No version change occurred during snapshot creation.

## Isolated recovery and candidate rehearsal — 2026-11-07

Archive checksum verified. Two separate extractions were opened in maintenance containers with `--network none` and `--execute "server shutdown"`: v1.9.3 and v1.9.4 both exited 0. Rehearsal directories and private logs remain under the protected recovery directory. Candidate binary reports `tuwunel 1.9.4`; pinned repository digest `jevolk/tuwunel@sha256:0e86c6164d6c9f5b60291938eb61ad8395021c37fe58d47a963ea7edddbedaec`.

Production remains healthy on v1.9.3. These runs establish database startup/shutdown on restored copies, not authenticated client/E2EE compatibility. Next: inspect rehearsal diagnostics without exposing user data, retain an independent backup copy, prepare immutable Compose override and controlled production switch.

## Candidate preparation and independent-copy transfer — 2026-11-07

Both rehearsal logs were inspected in place: v1.9.3 has 53 lines, v1.9.4 has 55; neither contains ERROR or panic and both record shutdown. A protected `candidate.json` under the server recovery directory overrides only homeserver to the pinned v1.9.4 digest; Compose config validation exits 0.

An independent data archive transfer is running to `~/.config/n42/backups/matrix-upgrade-20261107/data.tar.partial`, mode 0600, outside repositories. Exec session 47530 is the live transfer handle; the observed file grew from 99 MiB to 137 MiB. Do not restart this transfer solely because a polling window expires. Completion requires terminal exit, matching the recorded SHA-256, then renaming the partial file. Production remains healthy on v1.9.3; no candidate deployment yet.

## Pre-switch checks while transfer remains live — 2026-11-07

Original transfer handle 47530 remains live. Independent archive reached 724,434,944 / 2,872,463,360 bytes (25.2%). Production health is healthy, restart count 0, image v1.9.3. Candidate Compose validation again exits 0. No `docker-compose.override.yml` exists in the deployment working directory, so a durable pinned override (or reviewed base image change) must be installed at cutover to avoid later default Compose operations reverting the image. No version switch yet.

Rehearsal warning comparison: four warnings in each version. The changed pattern is updated wording for existing open registration; remaining warnings concern the pre-existing unknown allow_check_for_updates option, maintenance listening=false and deliberate shutdown. No new startup failure found. Independent transfer handle 47530 remains live and is above 42 percent; production healthy on 1.9.3.

Pre-cutover public API baseline captured in `matrix-precutover-2026-11-07.json`: federation version 1.9.3 and login flows application_service/token/password, all probes HTTP 200. Independent archive transfer remains live, latest observed 64.6 percent. No production image switch performed.

## Production cutover completed — 2026-11-07

Independent archive completed at 2,872,463,360 bytes with SHA-256 matching the recovery point above. It is finalized as `~/.config/n42/backups/matrix-upgrade-20261107/data.tar` (0600); the separate protected config bundle contains the original Compose/config, image ID, candidate and checksum.

Immediately before deployment, the homeserver was stopped and a fresh complete volume snapshot saved as `data-cutover.tar` in the server recovery directory. Its SHA-256 check passes. The pinned candidate was installed as `docker-compose.override.yml` (0600), validated, then deployed with `docker compose up -d --no-deps homeserver`. Adjacent services were not redeployed.

Verified production: Tuwunel **1.9.4**, pinned digest above; container running, healthy, restart count 0. Initial startup log has 30 lines and no ERROR/panic lines. Public federation, client versions and login discovery all return HTTP 200; login flows remain application_service/token/password. Public evidence is saved in `matrix-postcutover-2026-11-07.json`. Native OIDC was not enabled.

Rollback boundary: stop the upgraded homeserver and preserve its current volume before any recovery; restore the fresh pre-cutover snapshot with the original configuration and old image. Do not run the old binary against migrated data. Restoring that snapshot would exclude writes after cutover; reconcile those writes before a rollback that could lose messages. The earlier independent recovery point also predates cutover and must not silently replace newer data.

The server version upgrade is complete. Authenticated login, real E2EE messaging, media, push, calls and device recovery against this production version remain unverified. Existing automated frontend checks and isolated database rehearsals do not establish those outcomes.
