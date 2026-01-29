# N42 Wallet Release Checklist

This document outlines the requirements and steps for releasing the N42 Wallet app to Android (Google Play) and iOS (App Store).

---

## Pre-Release Code Quality

- [x] All `dart analyze` warnings resolved (0 errors, 1 info)
- [x] Code properly type-annotated
- [x] No security vulnerabilities in code

---

## Android Release Requirements

### 1. Signing Configuration

**Status: ACTION REQUIRED**

The `android/key.properties` file is missing. Create it from the template:

```bash
cp android/key.properties.template android/key.properties
# Edit key.properties with your actual keystore credentials
```

Required values:
- `storeFile`: Path to your release keystore file
- `storePassword`: Keystore password
- `keyAlias`: Key alias in the keystore
- `keyPassword`: Key password

### 2. TrustWallet Core Credentials

**Status: ACTION REQUIRED**

Add TrustWallet Maven credentials to `android/local.properties`:

```properties
flutter.sdk=/path/to/flutter
wallet_core.user=YOUR_GITHUB_USERNAME
wallet_core.key=YOUR_GITHUB_PERSONAL_ACCESS_TOKEN
```

### 3. Build Configuration

- [x] `minifyEnabled = true` (ProGuard enabled)
- [x] `shrinkResources = true`
- [x] ProGuard rules configured
- [x] NDK debug symbols enabled

### 4. Google Play Console Requirements

- [ ] App signing by Google Play configured
- [ ] Privacy policy URL set
- [ ] Content rating questionnaire completed
- [ ] Target API level meets current requirements (API 34+)

### Build Command

```bash
flutter build appbundle --release
# or for APK
flutter build apk --release
```

---

## iOS Release Requirements

### 1. Privacy Manifest (PrivacyInfo.xcprivacy)

**Status: CREATED**

The `ios/Runner/PrivacyInfo.xcprivacy` file has been created with:
- NSPrivacyCollectedDataTypes declared
- NSPrivacyAccessedAPITypes with required reasons
- NSPrivacyTracking set to false

**Note:** Add this file to Xcode project:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on "Runner" folder → "Add Files to Runner"
3. Select `PrivacyInfo.xcprivacy`
4. Ensure "Copy items if needed" is unchecked
5. Target membership: Runner

### 2. App Transport Security (ATS)

**Status: REVIEW RECOMMENDED**

Current `Info.plist` has `NSAllowsArbitraryLoads = true`. Consider:
- Adding specific exception domains instead of allowing all
- Documenting justification for App Store review

### 3. Push Notification Entitlements

**Status: ACTION REQUIRED FOR PRODUCTION**

The `Runner.entitlements` has:
```xml
<key>aps-environment</key>
<string>development</string>
```

For App Store release, create a production entitlements file or update to:
```xml
<key>aps-environment</key>
<string>production</string>
```

### 4. Code Signing

- [ ] Distribution certificate installed
- [ ] App Store provisioning profile created
- [ ] Team ID configured in Xcode

### 5. App Store Connect Requirements

- [ ] Privacy policy URL
- [ ] App category selected (Finance)
- [ ] Screenshots for all required device sizes
- [ ] App description and keywords
- [ ] Support URL
- [ ] Export compliance (encryption declaration)

### 6. Export Options

**Status: TEMPLATE CREATED**

The `ios/ExportOptions-AppStore.plist` has been created. Update with:
- Your actual Team ID
- Correct provisioning profile names

### Build Command

```bash
flutter build ios --release
# Then archive and upload via Xcode or xcrun
```

---

## Version Management

Current version: `1.0.0+1` (pubspec.yaml)

Before each release:
1. Update `version` in `pubspec.yaml`
2. Update version in iOS Info.plist (automatic with Flutter)
3. Update versionCode/versionName in Android (automatic with Flutter)

---

## Testing Before Release

### Android
- [ ] Release APK installs on real device
- [ ] ProGuard doesn't break functionality
- [ ] All deep links work
- [ ] Push notifications work in release mode

### iOS
- [ ] TestFlight build works
- [ ] App Review guidelines compliance
- [ ] All permissions show correct descriptions
- [ ] Universal links work

---

## Security Reminders

1. **Never commit sensitive files:**
   - `android/key.properties`
   - `android/keystores/`
   - `ios/*.p12`
   - `ios/*.mobileprovision`
   - API keys in code

2. **Review before release:**
   - Remove debug logging
   - Disable developer tools
   - Verify API endpoints (production vs staging)

---

## Quick Reference

| Platform | Build Command | Output Location |
|----------|---------------|-----------------|
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/` |
| Android Bundle | `flutter build appbundle --release` | `build/app/outputs/bundle/release/` |
| iOS | `flutter build ios --release` | `build/ios/iphoneos/Runner.app` |

---

*Last updated: 2026-01-28*
