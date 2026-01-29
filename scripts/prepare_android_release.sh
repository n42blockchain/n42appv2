#!/bin/bash
# Android Release Preparation Script
# This script prepares the Android project for Google Play release

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANDROID_DIR="$PROJECT_ROOT/android"

echo "=== N42 Wallet Android Release Preparation ==="
echo ""

# 1. Check for key.properties
KEY_PROPS="$ANDROID_DIR/key.properties"
if [ ! -f "$KEY_PROPS" ]; then
    echo "ERROR: key.properties not found!"
    echo ""
    echo "Please create $KEY_PROPS with:"
    echo "  storeFile=../keystores/release.keystore"
    echo "  storePassword=your_password"
    echo "  keyAlias=your_alias"
    echo "  keyPassword=your_key_password"
    echo ""
    echo "See key.properties.template for details."
    exit 1
fi
echo "  - key.properties found"

# 2. Check for TrustWallet credentials
LOCAL_PROPS="$ANDROID_DIR/local.properties"
if [ -f "$LOCAL_PROPS" ]; then
    if ! grep -q "wallet_core.user" "$LOCAL_PROPS"; then
        echo "WARNING: wallet_core.user not found in local.properties"
        echo "  TrustWallet Core may fail to download."
    else
        echo "  - TrustWallet credentials found"
    fi
fi

# 3. Clean Flutter build
echo ""
echo "Cleaning Flutter build..."
cd "$PROJECT_ROOT"
flutter clean

# 4. Get dependencies
echo ""
echo "Getting Flutter dependencies..."
flutter pub get

# 5. Build Android App Bundle (recommended for Play Store)
echo ""
echo "Building Android App Bundle..."
flutter build appbundle --release

# 6. Also build APK for testing
echo ""
echo "Building APK for testing..."
flutter build apk --release

echo ""
echo "=== Android Release Preparation Complete ==="
echo ""
echo "Output files:"
echo "  - App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "  - APK: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Next steps:"
echo "1. Test the APK on a real device"
echo "2. Upload the AAB to Google Play Console"
