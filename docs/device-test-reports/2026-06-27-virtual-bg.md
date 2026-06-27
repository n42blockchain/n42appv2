# 2026-06-27 Virtual Background Frame Injection

## Scope

- Task: T7, virtual background / background blur injection into the published WebRTC video track.
- Baseline: `master` `5e8123eb`.
- Host: macOS 26.5.1 (25F80), Flutter 3.41.4 stable, Dart 3.11.1.
- Android device seen by Flutter: Redmi `25098RA98C`, Android 16 (API 36).

## Implementation

- Used the existing `flutter_webrtc 1.4.0` Android hook instead of forking:
  `LocalVideoTrack` already implements `VideoProcessor` and exposes `addProcessor` / `removeProcessor`.
- Added `VirtualBackgroundHandler` for MethodChannel `n42.chat/virtual_background`.
  It resolves the local camera `LocalVideoTrack` by `trackId` via `FlutterWebRTCPlugin.sharedSingleton.getLocalTrack(trackId)` and attaches the processor.
- Added `N42VirtualBackgroundProcessor`, implementing `LocalVideoTrack.ExternalVideoFrameProcessing`.
  It converts WebRTC I420 frames to Bitmap, runs ML Kit Selfie Segmentation asynchronously, composites with the latest mask, then converts the result back to I420.
- Supported modes:
  - `none`: detach processor / pass through.
  - `blur`: downscale/upscale background blur approximation.
  - `solidColor`: replace non-person pixels with configured color.
  - `virtualBackground`: use provided background image bytes; fallback to blur if absent.
- Extended Dart native config payload with `backgroundImageBytes` so native can actually render configured virtual background images.
- Added explicit Android app dependencies:
  - `io.github.webrtc-sdk:android:144.7559.01`
  - `com.google.mlkit:segmentation-selfie:16.0.0-beta6`

## Verification

| Check | Result | Notes |
|---|---|---|
| `flutter build apk --debug --no-pub` | PASS | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| Repeat `flutter build apk --debug --no-pub` after cleanup | PASS | Confirms Kotlin/WebRTC/ML Kit references compile. |
| `flutter install -d 38f4f08a --debug` | PASS | Retry installed `app-debug.apk` to Redmi `25098RA98C`. |
| Cold launch `ai.n42.www/.MainActivity` | PASS | `pidof ai.n42.www` returned `2455`; `MainActivity` was resumed/focused; no `ai.n42.www` FATAL/AndroidRuntime crash found in the captured logcat window. |
| A/B video call, A enables blur/background and B sees processed video | NOT VERIFIED | Requires successful device install plus a second call endpoint. |
| Switch mode back to `none` restores original video | NOT VERIFIED | Requires full runtime call verification. |

## Notes

The original task expected a `flutter_webrtc` fork because the design assumed no processor registration point was available. On the current resolved dependency (`flutter_webrtc 1.4.0`), Android already has a processor chain on `LocalVideoTrack`, so the implementation avoids a fork and attaches through that existing native API.

iOS frame injection remains a second phase. This change only wires Android publisher-frame injection.
