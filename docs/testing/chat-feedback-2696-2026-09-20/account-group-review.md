# Account and group review — 2026-09-20

## Scope and decision

Reviewed Chat commit `2166fad5cf98a37ca570d07dcb32b172b0be1034` in `/Users/jieliu/Documents/n42/.tmp-worktrees/n42-chat-registration-20260917`. Host `pubspec.yaml` points to that commit. Review covered session restore/logout/switch, contact relationship fallback, friend-only group autojoin, member invitation filtering, nickname persistence, and group detail routes.

**Recommendation: accept after integrating the contact race fix below.** No further blocking account/group defect was established in this bounded review. Native-device acceptance is still outstanding; unit tests are not evidence that the original two-phone encryption scenario is resolved.

## Finding and fix

- **P2 — stale relationship lookup overwrites newer contact state.** In `lib/src/presentation/pages/contact/contact_detail_page.dart`, `_loadStandaloneRelationship()` could begin with an empty ContactBloc, wait for the repository, then replace a newly synchronized friend with an older non-friend response. This can reintroduce the incorrect Add to Contacts button on a shared card. The reverse ordering could also overwrite current annotations.
- Parent authorized the bounded fix. Completion now re-reads the current Bloc contact and prefers it over the older repository response. Explicit deletion still takes priority. Pending requests are cleared when the resolved contact is a friend.
- Added two completer-based ordering tests in `test/presentation/pages/contact_detail_page_test.dart`: a newer friend update survives an older non-friend result; a newer explicit deletion survives an older friend result.
- Only these two source/test files were edited by this reviewer. They remain uncommitted for parent integration; the host mirror and pin need the integration update.

## Evidence

Before the race fix, this focused review suite passed **72 tests**:

```sh
flutter test --no-pub test/unit/repositories/group_repository_impl_test.dart test/unit/datasources/matrix_group_datasource_test.dart test/unit/repositories/auth_session_behavior_test.dart test/presentation/pages/contact_detail_page_test.dart
```

Log: `/tmp/n42-agent-account-group-review.log`.

After the fix, the narrow contact suite passed **14 tests**:

```sh
flutter test --no-pub test/presentation/pages/contact_detail_page_test.dart
```

Log: `/tmp/n42-agent-contact-race.log`. Formatting was applied to the two edited files. No full-suite rerun was performed after this narrow change.

Static checks confirmed:

- Autojoin checks the actual invite-event sender against confirmed friendship and blocking state; strangers, blocked contacts, lookup failures, and admission failures remain pending. It uses RoomJoinService, retaining token-gate and account-identity checks.
- Matrix SDK 6.2.0 `requestParticipants()` defaults include joined and invited members, so backend duplicate-invite filtering covers both.
- Group settings and member routes now own a GroupBloc; own nickname writes a membership state event while preserving existing membership content.
- Explicit logout removes only the logged-out saved account; missing local encryption sessions request authentication rather than silently rebuilding the old device identity. Restore exceptions no longer universally imply token expiry.

## Acceptance gaps

- Retest saved-account switching and incoming-message readability on the affected native devices; the review did not manipulate user accounts or devices.
- Exercise the actual group-detail routes, nickname refresh, and friend/stranger invitation policy in a release build. Existing unit coverage verifies policy and state operations, not every rendered route.
- Integration owner must copy the two-file fix into the host mirror and advance the Chat pin after committing. The current pin does not include this review fix.

## Primary-agent disposition

Accepted and integrated in Chat `ef5fbb38`; host pin and mirror updated. Final affected host regression: 42 passed. Earlier “uncommitted/pending integration” statements above record the original handoff state. Device acceptance gaps remain open.
