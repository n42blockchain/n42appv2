# Scanner gallery entry and friend-request follow-up

## Scope

- Chat source: `59e2a5fd6a5a984725b524590347b4da377f4075`.
- Adds a localized Album action to the scanner app bar in 26 locales.
- Opens the system image picker and analyzes QR images through the existing native scanner plugin; decoded data uses the existing friend/payment/mini-app routing.
- Serializes camera stop/resume with gallery work, prevents duplicate actions, and safely handles cancellation, unreadable images and late results after navigation.
- Incoming friend requests no longer wait for unrelated room membership or global profile queries. Available invitation state is published before contact hydration completes; outgoing membership is still refreshed through contact loading.

## Verification

- Chat focused scanner/contact/request/navigation suite: 116 passed.
- Wallet `flutter test --no-pub test/features/chat/chat_testflight_feedback_regression_test.dart --reporter expanded`: 397 passed.
- Stalled-query tests verify incoming requests remain available while contact hydration and profile queries cannot complete.
- Scanner widget coverage includes denied camera permission, image cancellation, duplicate taps, lifecycle resume while the picker is open, payment confirmation, picker/decoder failures and page disposal.
- Wallet static analysis: zero errors and warnings; 196 existing informational findings.
- All 779 mirrored lib/assets files match the resolved Git dependency.

## Acceptance still outstanding

- The user reports that adding friends still has the original failure. Both feedback devices' installed versions and the direction/current state of the request have been requested and remain unconfirmed.
- This client query-blocking fix does not establish the cause or resolution on dxx/dxx01. Verify request delivery, explicit acceptance, bilateral contacts and message exchange on those updated clients. Chat `OPEN_ISSUES.md` QA-009 remains open.
- Native gallery selection/decoding on the feedback Android and iPhone has not been tested in this change. Do not overwrite a user's app with an integration-test harness.
- Existing TestFlight/APK build 2026072674 predates these changes; no replacement binary is produced by this code-only update.
- The previously confirmed TURN gateway HTTP 400 blocker remains unresolved.
