# N42 Wallet Release Checklist

## Quick Status

| Item | Status |
|------|--------|
| Code Analysis | ✅ 0 errors, 0 warnings |
| iOS PrivacyInfo.xcprivacy | ✅ Created & added to Xcode |
| iOS Info.plist | ✅ Privacy descriptions updated |
| Android Manifest | ✅ All permissions configured |
| ProGuard Rules | ✅ Configured |
| Build Scripts | ✅ Created |

---

## Before Release - REQUIRED Actions

### 1. Android Signing (P0)

Edit `android/key.properties`:
```properties
storeFile=../keystores/release.keystore
storePassword=YOUR_ACTUAL_PASSWORD
keyAlias=n42wallet
keyPassword=YOUR_ACTUAL_PASSWORD
```

Create keystore if needed:
```bash
cd android/keystores
keytool -genkey -v -keystore release.keystore -alias n42wallet \
  -keyalg RSA -keysize 2048 -validity 10000
```

### 2. TrustWallet Credentials (P0)

Edit `android/local.properties`:
```properties
wallet_core.user=YOUR_GITHUB_USERNAME
wallet_core.key=YOUR_GITHUB_PERSONAL_ACCESS_TOKEN
```

Get token from: https://github.com/settings/tokens (scope: `read:packages`)

### 3. iOS Signing (P0)

In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Set Team ID
4. Configure signing certificates

---

## Build Commands

### iOS Release
```bash
./scripts/prepare_ios_release.sh
# Then: Xcode → Product → Archive → Distribute
```

### Android Release
```bash
./scripts/prepare_android_release.sh
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Version Management

Current: `1.0.0+1`

Update in `pubspec.yaml`:
```yaml
version: X.Y.Z+BUILD_NUMBER
```

---

## Store Submission Notes

### App Store (iOS)
- [x] PrivacyInfo.xcprivacy included
- [x] Privacy descriptions professional
- [x] ITSAppUsesNonExemptEncryption = false
- [ ] Screenshots prepared
- [ ] Privacy policy URL

### Play Store (Android)
- [x] ProGuard enabled
- [x] Debug symbols included
- [x] Target SDK compliant
- [ ] Screenshots prepared
- [ ] Privacy policy URL

---

## File Reference

| File | Purpose |
|------|---------|
| `android/key.properties` | Signing config (edit before release) |
| `android/local.properties` | Build config + TrustWallet creds |
| `android/keystores/` | Store keystore files here |
| `ios/Runner/PrivacyInfo.xcprivacy` | Apple privacy manifest |
| `ios/ExportOptions-AppStore.plist` | Archive export settings |
| `scripts/prepare_*.sh` | Build automation |
