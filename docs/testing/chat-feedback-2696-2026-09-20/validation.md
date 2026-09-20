# Feedback 2696 validation evidence

## 2026-09-20 — integration checks

Host dependency pin inspected in `pubspec.yaml`: `n42_chat` revision `2166fad5cf98a37ca570d07dcb32b172b0be1034`. Results below are evidence for primary-agent review, not a blanket acceptance of the reported phone scenarios. Logs are local temporary artifacts; credentials and private recordings are not copied here.

| Check | Observed result | Evidence / boundary |
| --- | --- | --- |
| Chat regression suite | **473 passed** | `/tmp/n42-feedback-full-tests-final.log`, terminal `+473: All tests passed!`. Automated suite; not feedback-device acceptance. |
| Chat analyzer | **0 errors, 0 warnings, 280 infos** | `/tmp/n42-feedback-analyze-final.log`. Informational diagnostics remain. |
| Host chat regression suite | **1,019 passed** | `/tmp/n42-feedback-host-tests.log`, terminal `+1019: All tests passed!`. Does not represent every app test. |
| Host analyzer | **0 errors, 0 warnings, 264 infos** | `/tmp/n42-feedback-host-analyze.log`. Informational diagnostics remain. |
| iOS device Debug compilation | **Build succeeded, signing disabled** | `/tmp/n42-calendar-ios-build.log`: `Built build/ios/iphoneos/Runner.app`. Verifies native compilation; no TestFlight upload, installation or calendar save/cancel verification. |
| Android native compilation | **Build succeeded** | `/tmp/n42-calendar-android-build.log`: `BUILD SUCCESSFUL`. The assigned check is `:app:compileDebugKotlin` with JDK 17; compilation is not a signed release APK or HarmonyOS call test. |
| Latest live encryption harness invocation | **Failed before loading test** | `/tmp/n42-live-feedback-2696-result-final.log`: SDK exit 1. `/tmp/n42-live-feedback-2696.log` points to a nonexistent host `test/live/account_switch_encryption_test.dart`; the test belongs in the Chat worktree. This invocation provides no encryption verdict. Both temporary accounts were deactivated (2 created / 2 cleaned). |
| Live AI authentication | **Invalid identity rejected, HTTP 401** | `/tmp/n42-live-ai-vision-result.log`. Authentication rejection verified. |
| Live AI vision | **HTTP 429; completion not verified** | Same log; expected HTTP 200 assertion failed. Upstream free-service rate limiting remains an external limitation. Temporary account deactivated (1 created / 1 cleaned). No paid fallback or quota reset is part of this result. |

The prior integration handoff reports an earlier live SDK encryption pass. That report must be distinguished from the failed harness invocation above; a rerun from the correct Chat worktree is in progress. The primary agent owns reconciliation. SDK tests use temporary accounts and cannot establish native secure-storage persistence, account switching on the feedback phones, or HarmonyOS ringtone behavior.

## Remaining acceptance boundaries

- Native calendar editor save/cancel/permission behavior, real media rendering and phone account-session persistence need device checks.
- AI vision and image translation need a successful live upstream response before claiming end-to-end availability.
- Demo red packets remain demo records. Actual money movement and automatic discovery of a friend's verified wallet address are not established by these checks.
- Preserve the user's admission rule: existing unblocked friends autojoin; strangers remain pending. Automated coverage does not replace arrival/badge verification on devices.
- Primary agent reviews and records final acceptance after resolving test invocation errors and inspecting the integrated diff.

## 2026-09-20 — backend rerun

Command: `python3 -m unittest discover -s backend/ai-proxy -p 'test_server.py'`. Result: **7 tests passed**, exit 0. Evidence: `/tmp/n42-feedback-backend-tests-doc.log`. This covers the local gateway unit suite and does not override the live upstream HTTP 429 result.

The live encryption runner starts Flutter with a relative test path and inherits its working directory. It has been restarted from `/Users/jieliu/Documents/n42/.tmp-worktrees/n42-chat-registration-20260917`, without changing account-handling code. Result destination: `/tmp/n42-live-feedback-2696-result-rerun.log`. Only disposable QA accounts are used.

## 2026-09-20 — live encryption rerun completed

**Passed:** `/tmp/n42-live-feedback-2696-result-rerun.log` reports `SDK live test exit: 0`; the detailed runner log ends `+1: All tests passed!`. All temporary QA accounts were deactivated: 2 created, 2 cleaned.

Running the unchanged harness from the correct Chat worktree resolved the earlier test-file loading failure. The earlier exit 1 was a harness invocation error, not a product encryption failure. The runner rewrites `/tmp/n42-live-feedback-2696.log`; it now contains this successful execution, while the original failure summary remains in `/tmp/n42-live-feedback-2696-result-final.log` and the recorded table above. This is a live Matrix SDK/repository result, not native device verification or proof that every reported encryption scenario is resolved.

The pin above identifies the integration baseline inspected for this entry. Any later fixes and final pin change require the primary agent to append their own validation scope.

## Primary integration acceptance

Final Chat pin: `ef5fbb38c42da0a09db8f4e5ba3a3b3004d52069`. The two delegated follow-ups were reviewed and accepted. Host command `flutter test --no-pub packages/n42_chat/test/presentation/pages/contact_detail_page_test.dart test/features/chat/chat_feedback_2696_regression_test.dart` passed **42 tests** (`/tmp/n42-feedback-final-integration-tests.log`). This targeted run follows the earlier 1,019-test baseline; those counts are separate scopes, not an additive total. All **792** resolved library/asset files match the host mirror. No further native changes followed the successful native builds.

The final acceptance covers code integration and the automated checks stated here. Feedback-phone and free-provider limitations remain in `OPEN_ISSUES.md`; no TestFlight upload or release APK is claimed.
