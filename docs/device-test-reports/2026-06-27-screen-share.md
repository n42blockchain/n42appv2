# 2026-06-27 Android Screen Share Device Test

## Scope

Task T8: group call screen sharing on Android 14+ / Android 16.

## Changes Verified By Build

- Added `flutter_background` dependency for the Android media projection foreground service path.
- Added Android `FOREGROUND_SERVICE_MEDIA_PROJECTION` permission.
- Added `de.julianassmann.flutter_background.IsolateHolderService` with `android:foregroundServiceType="mediaProjection"`.
- Updated `LiveKitService.startScreenShare()` on Android to request `Helper.requestCapturePermission()` before starting the foreground service and publishing the LiveKit screen share track.
- Updated `stopScreenShare()` and meeting cleanup to stop the Android foreground service.
- Fixed host compile blocker from the updated `IWalletBridge.requestNftTransfer` interface.

## Static And Build Verification

| Check | Result | Notes |
|---|---:|---|
| `flutter pub get` | PASS | Dependencies resolved. |
| merged Android manifest | PASS | `FOREGROUND_SERVICE_MEDIA_PROJECTION` and `IsolateHolderService mediaProjection` present in debug merged manifest. |
| `flutter analyze --no-fatal-infos` | PASS | No issues found. |
| `flutter build apk --debug --no-pub` | PASS | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| Android 16 install | PASS | Installed with `adb install -r -g -d -t build/app/outputs/flutter-apk/app-debug.apk`. |

## Android Device

- Device: `25098RA98C`
- ADB id: `38f4f08a`
- OS: Android 16, API 36
- Installed T8 app: `ai.n42.www` version `2.4.3`, versionCode `2026062603`, lastUpdateTime `2026-06-27 05:19:32`
- Runtime permission check: `android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION: granted=true`

## Device Install Status

Passed after retry.

Six initial ADB install attempts were rejected by the device:

- `adb install -r`
- `adb install -r -g`
- `adb install --no-streaming -r -g`
- `adb push ... /data/local/tmp/n42-t8-debug.apk && adb shell pm install -r -g /data/local/tmp/n42-t8-debug.apk`
- `adb install -r -g` retry after re-checking the connected device
- `adb install -r -g` retry before the successful `-d -t` install

All returned:

```text
INSTALL_FAILED_USER_RESTRICTED: Install canceled by user
```

The successful install command was:

```text
adb -s 38f4f08a install -r -g -d -t build/app/outputs/flutter-apk/app-debug.apk
```

After install, `dumpsys package ai.n42.www` confirmed `versionCode=2026062603` and `FOREGROUND_SERVICE_MEDIA_PROJECTION: granted=true`.

## Pending A/B Validation

| # | Scenario | Expected |
|---|---|---|
| 1 | Android starts screen share in a group call | Android system capture permission dialog appears; after approval, screen track publishes successfully. |
| 2 | Android screen share while iPhone is in the same group call | iPhone sees the Android shared screen tile/overlay; no sender-side silent failure. |
| 3 | Android stops screen share | LiveKit screen track stops and Android foreground notification disappears. |
| 4 | Android denies capture permission | No crash; screen share stays off and user-facing error path is triggered. |
| 5 | Re-enter Android settings / notification surfaces | No repeated unrelated battery optimization prompt from this code path. |

## 2026-06-27 Follow-up Attempt

- Located a real group conversation: `bdns`, shown as `5 members`.
- Group call entry is not in the top app bar. It is under the chat input attachment/more panel: `paperclip` -> `Video Call`.
- Tapped `Video Call` in `bdns`.
- Result: group call did not open because LiveKit JWT token fetch failed before `GroupCallScreen` navigation.

Observed device log:

```text
CallManager: LiveKit token POST returned 301 without token
CallManager: LiveKit token GET returned 404 without token
```

External endpoint check:

```text
https://m.si46.world/livekit/jwt  -> 301 Location: /livekit/jwt/
https://m.si46.world/livekit/jwt/ -> 404 page not found
https://m.si46.world/livekit/sfu  -> 200 OK
```

The LiveKit SFU health endpoint is reachable, but the JWT signing endpoint advertised by `.well-known` is not currently serving tokens. Screen sharing cannot be validated until group call join succeeds.

## Status

Code/build/install: PASS.

Real A/B device validation: BLOCKED by LiveKit JWT endpoint returning no token.
