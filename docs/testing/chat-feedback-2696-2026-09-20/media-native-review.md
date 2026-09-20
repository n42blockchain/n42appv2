# Media and native integration review

## 2026-09-20 — bounded review and follow-up fix

Baseline: Chat `2166fad5` in `/Users/jieliu/Documents/n42/.tmp-worktrees/n42-chat-registration-20260917`; host working tree contains uncommitted native calendar bridges. No real transfers, account mutations, deployment, or commits were performed by this reviewer.

### Concrete finding and disposition

**Medium — gallery thumbnail failure prevents sending the selected video.** In `lib/src/presentation/pages/chat/chat_page_media_actions.dart`, `_sendRecentMediaSelection` awaited `asset.thumbnailDataWithSize` before calling `_sendVideo`. A native preview extraction exception reached the outer failed-item handler, bypassing the sender's file-based thumbnail fallback and video dispatch entirely.

The primary agent authorized a narrow fix after the read-only finding: added `loadOptionalVideoThumbnail` in `lib/src/core/utils/optional_video_thumbnail.dart`, imported it from `chat_page.dart`, and wrapped the optional gallery extraction. Missing, empty, or failed previews now become null, allowing the existing sender fallback to run. Valid preview bytes remain unchanged. Four focused tests cover asynchronous platform failure, synchronous plugin failure, null/empty output, and successful output. These edits remain uncommitted for primary-agent integration.

**Recommendation: accept the follow-up code fix after primary review.** This is automated verification of the failure handling, not proof that a particular device can generate a preview for every video codec.

### Other reviewed paths

| Path | Evidence and recommendation |
| --- | --- |
| Transfer QR | `payment_request_uri.dart` accepts the host's `n42://pay?address=...` and Chat's `n42pay://pay?to=...`. `transfer_page.dart` matches a unique requested token, rejects explicit unsupported networks and unknown URI schemes, resets address validation, and only prefills fields. No transfer is initiated by scanning. Accept this bounded behavior; Ethereum URI support is deliberately excluded rather than stripping network/asset information. |
| Native calendar | Dart dispatches event fields through `n42.chat/calendar`; Android opens an insert-event editor, iOS opens `EKEventEditViewController`. Cancellation does not claim a saved event. Build logs show both native targets compile. Accept bridge implementation; interactive save/cancel on physical devices remains a primary-agent acceptance check. |
| Bundled stickers | Sender allowlists bundled SVG/Lottie paths, uploads bytes, and sends the resulting media URI with MIME information. Reader supports both remote formats and legacy bundled paths. Focused upload tests passed. No blocker found. |
| Code messages | Plain/unknown languages render normal white text instead of passing a null language into HighlightView; known languages keep syntax highlighting. Narrow-width plaintext, fenced-code, and multiline tests passed. No blocker found. |
| Android ringing | `setCallConnected` calls `hideCallkitIncoming` before `callConnected`. Installed plugin 3.0.0's native hide handler explicitly stops its sound player and clears the incoming notification without ending the call. The method-channel ordering test passed. Accept code behavior; HarmonyOS device audio/vibration acceptance is still required. |

### Commands and results

- `flutter test --no-pub test/unit/utils/optional_video_thumbnail_test.dart`: **4 passed**. Log: `/tmp/n42-optional-thumbnail-tests.log`.
- `dart analyze lib/src/core/utils/optional_video_thumbnail.dart lib/src/presentation/pages/chat/chat_page.dart lib/src/presentation/pages/chat/chat_page_media_actions.dart test/unit/utils/optional_video_thumbnail_test.dart`: **no issues**. Log: `/tmp/n42-optional-thumbnail-analyze.log`.
- Initial focused review run also exercised payment URI, calendar action, code widget, bundled sticker sender, and call notification suites: **22 existing tests passed**. The new helper test initially failed compilation because `MissingPluginException` was incorrectly marked `const`; that test-only typo was corrected and the four helper tests rerun successfully. Initial log retained at `/tmp/n42-media-native-review-tests.log`; do not describe that initial combined run as wholly green.
- Inspected existing native build evidence: `/tmp/n42-calendar-ios-build.log` ends with `Built build/ios/iphoneos/Runner.app`; `/tmp/n42-calendar-android-build.log` ends with `BUILD SUCCESSFUL`. These logs predate the Dart-only optional-thumbnail follow-up.
- Scoped `git diff --check`: passed.

The primary agent retains ownership of `OPEN_ISSUES.md` and final accept/rework decisions. Device verification boundaries above must remain in that single unresolved-issue ledger until tested; this file records execution evidence only.

## Primary-agent disposition

Accepted and integrated in Chat `ef5fbb38`; host pin and mirror updated. Final affected host regression: 42 passed. Earlier “uncommitted/pending integration” statements above record the original handoff state. Device acceptance gaps remain open.
