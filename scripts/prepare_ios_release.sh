#!/bin/bash
# iOS Release Preparation Script
# This script prepares the iOS project for App Store release

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IOS_DIR="$PROJECT_ROOT/ios"

echo "=== N42 Wallet iOS Release Preparation ==="
echo ""

# 1. Update entitlements for production push notifications
ENTITLEMENTS_FILE="$IOS_DIR/Runner/Runner.entitlements"
if [ -f "$ENTITLEMENTS_FILE" ]; then
    echo "Updating entitlements for production..."
    # Backup original
    cp "$ENTITLEMENTS_FILE" "$ENTITLEMENTS_FILE.backup"

    # Replace development with production
    sed -i '' 's/<string>development<\/string>/<string>production<\/string>/g' "$ENTITLEMENTS_FILE"
    echo "  - aps-environment set to 'production'"
else
    echo "Warning: Entitlements file not found at $ENTITLEMENTS_FILE"
fi

# 2. Clean Flutter build
echo ""
echo "Cleaning Flutter build..."
cd "$PROJECT_ROOT"
flutter clean

# 3. Get dependencies
echo ""
echo "Getting Flutter dependencies..."
flutter pub get

# 4. Run iOS pod install
echo ""
echo "Installing CocoaPods dependencies..."
cd "$IOS_DIR"
pod install --repo-update

# 5. Build iOS release
echo ""
echo "Building iOS release..."
cd "$PROJECT_ROOT"
flutter build ios --release

echo ""
echo "=== iOS Release Preparation Complete ==="
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select 'Any iOS Device' as build target"
echo "3. Product -> Archive"
echo "4. Distribute App -> App Store Connect"
echo ""
echo "Note: After release, run 'scripts/restore_ios_dev.sh' to restore development settings"
