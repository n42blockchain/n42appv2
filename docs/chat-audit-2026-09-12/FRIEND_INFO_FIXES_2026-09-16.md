# Friend information fixes — 2026-09-16

## Report and behavior

Reviewed the supplied 45-second screen recording from Downloads. The recording is not included in the repository.

- Edit Remark now contains only the remark field.
- Phone opens an editor, saves its value and prepopulates it on reopening.
- Tags returns the confirmed selection, persists it and supports removing selections.
- Notes saves and displays the text and restores it in the editor.
- Photos opens the system gallery. Selected images are copied into application support storage and displayed as thumbnails beneath the friend-info fields. Tap to preview; delete removes the annotation and its local image.

Phone, tags, notes and photos are private device-local annotations isolated by homeserver, signed-in account and friend. They are not published to Moments or synchronized across devices. Saving after an account change is rejected. This change does not update membership counts in the existing global tag catalogue.

## Dependency and verification

Chat source: `10a1f7db4e1ec712ccad19c05e179a223ced865c` on `fix/chat-entry-audit-20260912`. The app pins this Git commit; 772 resolved source/resource files match the cache mirror and its updated SHA-256 manifest.

- Full application `flutter analyze --no-pub --no-fatal-infos`: exit 0, no errors or warnings; 155 informational notices elsewhere in the repository.
- Chat focused static analysis: no issues.
- Chat friend-info/contact tests: 14 passed.
- Application `flutter test --no-pub test/features/chat/chat_testflight_feedback_regression_test.dart`: 186 passed against the resolved Git dependency.
- Tests cover field persistence and reopening, cancellation, tag removal, gallery selection/preview/deletion, account isolation and rejection of stale-session writes.

Native iOS/Android gallery permission and picker acceptance remain unverified on hardware. The existing TestFlight build `2.4.8 (2026072666)` predates these fixes; no new TestFlight upload was performed for this change. The Chat open-issues ledger QA-009 records the remaining device verification.
