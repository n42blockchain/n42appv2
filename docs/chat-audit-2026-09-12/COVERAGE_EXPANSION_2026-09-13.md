# Chat behavior coverage expansion — 2026-09-13

**6,007 tests passed; one credential-dependent live smoke skipped.** This batch adds 140 behavior cases across eight new suites and the existing platform-write suite. Baseline: the complete settings run at `16fe83a` (5,867 passed). No CI threshold, instrumented file selection or generated-code exclusion changed.

Command: `ulimit -n 4096; flutter test --no-pub --coverage --concurrency=6 --reporter expanded`.

| Scope | Baseline | Current |
|---|---:|---:|
| Raw lcov (including generated code) | 25,212/131,079 (19.23%) | 27,822/131,172 (21.21%) |
| Non-generated reference view | 24,584/79,238 (31.03%) | 26,688/79,257 (33.67%) |
| Auth repository | 59/567 (10.41%) | 272/569 (47.80%) |
| Message actions repository | 0/269 (0.00%) | 272/275 (98.91%) |
| Story repository | 8/156 (5.13%) | 152/156 (97.44%) |
| Archive database | 24/319 (7.52%) | 182/321 (56.70%) |
| Media metadata database | 0/165 (0.00%) | 126/165 (76.36%) |
| Registration page | 1/390 (0.26%) | 332/391 (84.91%) |
| Password reset page | 0/257 (0.00%) | 234/257 (91.05%) |
| Poll composer | 1/200 (0.50%) | 206/207 (99.52%) |
| Image messages | 0/222 (0.00%) | 134/223 (60.09%) |
| Payment cards | 0/232 (0.00%) | 225/232 (96.98%) |

The raw result remains below the 70% CI target. The non-generated row is a separately labeled reference view, not the CI result. Source fixes/formatting slightly change instrumented line totals. Module measurements come from complete runs, not merged selective runs.

## Behavior and defects verified

- Authentication: token restoration inside its existing lock, official Matrix error-code mapping independent of human wording, concurrency exclusion, credential preservation/removal, account switching, delayed sync failure and signed-out guards. Fixed restoration rejecting itself and wrong Matrix error categorization.
- Real SQLite: in-memory Drift/SQLite databases execute inserts, duplicate imports, room/time paging, FTS search/index rebuild/deletion, checkpoint upserts, archive statistics, media pinning, thumbnail protection, age/size filters and cleanup accounting. Blank FTS input previously caused SQLite syntax errors; it now returns no matches/count zero. Generated SQL mapping coverage is reported in the raw figure.
- Favorites and forwarding: persistence across repository recreation, rich message serialization, copy-on-write cache updates, concurrent first saves, rejected/false writes, corrupt/read-unavailable storage, retry recovery, reactions/replies/edits/redaction and mixed-success forwarding. Fixed optimistic success after storage failure, lost concurrent first saves and null forwarding results being counted as successful. Cross-key deletion is not atomic (STORAGE-001).
- Stories: unread grouping and ordering, ownership filtering, viewed state and its 500-ID cap, media/music payloads, failed uploads, absent posted events, ID resolution for deletion and viewer mapping. Matrix I/O is mocked; this is not server-side publication verification.
- Auth UI: terms gate, invalid inputs, normal/anonymous dispatch, loading prevention, failure draft retention, successful navigation, password-reset stages and resend cooldown. Fixed anonymous toggle Material background and homeserver validation disagreeing with trimmed submission.
- Poll UI: real taps through validation/send/schedule/cancel, anonymous and multi-select controls, blank-option filtering, correct-answer remapping after deletion, quiz single-select enforcement, English/Arabic 320-pixel layout. Fixed quiz switching back to multi-select and narrow header/settings overflow.
- Images: manual download, pending policy, disposed widgets, aspect bounds, view-once access denial after consumption and preview callback. Fixed stale policy completion overriding a replacement image, policy failure bypassing manual-download preferences, and the view-once placeholder overflowing with unknown dimensions.
- Payment/red-packet cards: sender/receiver statuses, currency amounts, accessibility labels, detail callbacks and Arabic dark layout. No payment or chain transaction was sent.

Static analysis: zero errors/warnings, 173 existing infos. A separate local screenshot fixture is used for visual review; its execution is not included in the 6,007 count. No device install, account mutation, private-key access or real message send was performed.

## Remaining boundaries

The ledger records three directly observed gaps: favorite deletion spans separate keys (STORAGE-001); persisted favorite tags/remarks have no UI read/edit path (UI-001); email confirmation accepts but does not use its code/address arguments (AUTH-001). Tests do not certify these as complete. Existing AI service/group-bot, sticker distribution, localization and multi-device acceptance gaps remain in `OPEN_ISSUES.md`.
