# 2026-06-27 iOS Local AI

## Summary

Status: iOS device build PASS; simulator build blocked by an upstream
TensorFlowLite pod slice gap; on-device model generation not run because no
small `.task` model URL/token was configured for this session.

## Verification

- PASS: `flutter test packages/n42_chat/test/unit/services/local_llm_service_test.dart --no-pub`
- PASS: `flutter build ios --debug --no-codesign --no-pub`
  - Confirms `flutter_gemma` / MediaPipe / TensorFlowLite pods link for iOS
    device builds.
- PASS: `flutter analyze --no-fatal-infos`
- BLOCKED: `flutter build ios --debug --simulator --no-pub`
  - Fails at link with `Framework 'TensorFlowLiteSelectTfOps' not found`.
  - Local inspection shows
    `ios/Pods/TensorFlowLiteSelectTfOps/Frameworks/TensorFlowLiteSelectTfOps.xcframework`
    contains only an `ios-arm64` device slice and no simulator slice.

## Findings

- No Dart inference logic change was needed.
- `ios/Podfile` already uses `use_frameworks! :linkage => :static`, which is
  required by the current iOS static framework dependency graph.
- The current `flutter_gemma 0.12.6` pod set is usable for iOS device builds,
  but not simulator builds because `TensorFlowLiteSelectTfOps` is device-only in
  the resolved pod version.
- `LocalLlmBridge.isDeviceCapable()` still correctly returns false until a model
  source is configured. To get a runtime `true`, provide a valid small `.task`
  model URL and any required HuggingFace token via `LocalLlmConfig`.

## Pending Device Runtime Test

Run on a physical iPhone:

1. Configure a small MediaPipe `.task` model URL/token.
2. Open the local LLM settings flow.
3. Verify capability becomes available after configuration.
4. Download the model.
5. Generate a short response.

Expected:

- No crash during model install/load.
- `LocalLlmService` transitions to `ready`.
- `generate()` returns a non-empty response.
