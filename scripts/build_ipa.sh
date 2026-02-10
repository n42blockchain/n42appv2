#!/bin/bash
# Build IPA for TestFlight with automatic fix for objective_c simulator platform bug
#
# Usage: ./scripts/build_ipa.sh [OPTIONS]
#   --no-bump       Skip build number auto-increment (rebuild same version)
#   --set-version X Set App Store version (CFBundleShortVersionString), e.g. --set-version 1.0.17
#
# Version strategy:
#   - App Store Version (CFBundleShortVersionString): manual, change with --set-version
#   - App Store Build   (CFBundleVersion):            auto-increment each build
#   - Flutter version in pubspec.yaml:                auto-increment (internal tracking)

set -e

MIN_IOS_VERSION="16.0"
PUBSPEC="pubspec.yaml"
PBXPROJ="ios/Runner.xcodeproj/project.pbxproj"

# === Parse arguments ===
NO_BUMP=false
NEW_APP_VERSION=""

while [ $# -gt 0 ]; do
  case "$1" in
    --no-bump)
      NO_BUMP=true
      shift
      ;;
    --set-version)
      NEW_APP_VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# === Read current App Store version from pbxproj ===
CURRENT_BUILD_NAME=$(grep 'FLUTTER_BUILD_NAME' "$PBXPROJ" | head -1 | sed 's/.*= *//;s/ *;.*//')
CURRENT_BUILD_NUMBER=$(grep 'FLUTTER_BUILD_NUMBER' "$PBXPROJ" | head -1 | sed 's/.*= *//;s/ *;.*//')

echo "=== Current App Store version: $CURRENT_BUILD_NAME ($CURRENT_BUILD_NUMBER) ==="

# === Update App Store Version if requested ===
if [ -n "$NEW_APP_VERSION" ]; then
  echo "=== Updating App Store version: $CURRENT_BUILD_NAME -> $NEW_APP_VERSION ==="
  sed -i '' "s/FLUTTER_BUILD_NAME = $CURRENT_BUILD_NAME/FLUTTER_BUILD_NAME = $NEW_APP_VERSION/g" "$PBXPROJ"
  CURRENT_BUILD_NAME="$NEW_APP_VERSION"
fi

# === Auto-increment Build Number ===
if [ "$NO_BUMP" = false ]; then
  NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
  echo "=== Build number: $CURRENT_BUILD_NUMBER -> $NEW_BUILD_NUMBER ==="
  sed -i '' "s/FLUTTER_BUILD_NUMBER = $CURRENT_BUILD_NUMBER/FLUTTER_BUILD_NUMBER = $NEW_BUILD_NUMBER/g" "$PBXPROJ"
  CURRENT_BUILD_NUMBER="$NEW_BUILD_NUMBER"

  # Also increment pubspec.yaml for internal tracking
  CURRENT_PUBSPEC=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
  PUB_VERSION_NAME=$(echo "$CURRENT_PUBSPEC" | cut -d'+' -f1)
  PUB_BUILD_NUM=$(echo "$CURRENT_PUBSPEC" | cut -d'+' -f2)
  PUB_MAJOR=$(echo "$PUB_VERSION_NAME" | cut -d'.' -f1)
  PUB_MINOR=$(echo "$PUB_VERSION_NAME" | cut -d'.' -f2)
  PUB_PATCH=$(echo "$PUB_VERSION_NAME" | cut -d'.' -f3)
  NEW_PUB_PATCH=$((PUB_PATCH + 1))
  NEW_PUB_BUILD=$((PUB_BUILD_NUM + 1))
  NEW_PUB_VERSION="$PUB_MAJOR.$PUB_MINOR.$NEW_PUB_PATCH+$NEW_PUB_BUILD"
  sed -i '' "s/^version: .*/version: $NEW_PUB_VERSION/" "$PUBSPEC"
  echo "=== Flutter version: $CURRENT_PUBSPEC -> $NEW_PUB_VERSION ==="
else
  echo "=== No bump (using existing build number: $CURRENT_BUILD_NUMBER) ==="
fi

echo ""
echo "=== Building IPA: $CURRENT_BUILD_NAME ($CURRENT_BUILD_NUMBER) ==="
echo ""

echo "=== Building iOS archive ==="
flutter build ipa \
  --build-name="$CURRENT_BUILD_NAME" \
  --build-number="$CURRENT_BUILD_NUMBER" \
  2>&1 || true

echo "=== Fixing objective_c.framework in archive ==="
ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
ARCHIVE_OBJ_C="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
ARCHIVE_OBJ_C_PLIST="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/Info.plist"

if [ -f "$ARCHIVE_OBJ_C" ]; then
  NEEDS_FIX=false

  # Check platform tag
  PLATFORM=$(vtool -show "$ARCHIVE_OBJ_C" 2>/dev/null | grep "platform " | head -1 | xargs)
  if echo "$PLATFORM" | grep -qi "simulator"; then
    echo "  Fixing platform: IOSSIMULATOR -> IOS"
    vtool -set-build-version ios "$MIN_IOS_VERSION" 26.2 -replace \
      -output "$ARCHIVE_OBJ_C" "$ARCHIVE_OBJ_C"
    NEEDS_FIX=true
  fi

  # Check minos version
  MINOS=$(vtool -show "$ARCHIVE_OBJ_C" 2>/dev/null | grep "minos " | head -1 | awk '{print $2}')
  if [ -n "$MINOS" ] && [ "$(printf '%s\n' "$MIN_IOS_VERSION" "$MINOS" | sort -V | head -1)" != "$MIN_IOS_VERSION" ]; then
    echo "  Fixing minos: $MINOS -> $MIN_IOS_VERSION"
    vtool -set-build-version ios "$MIN_IOS_VERSION" 26.2 -replace \
      -output "$ARCHIVE_OBJ_C" "$ARCHIVE_OBJ_C"
    NEEDS_FIX=true
  fi

  # Check Info.plist MinimumOSVersion
  if [ -f "$ARCHIVE_OBJ_C_PLIST" ]; then
    PLIST_MIN=$(plutil -extract MinimumOSVersion raw "$ARCHIVE_OBJ_C_PLIST" 2>/dev/null || echo "")
    if [ -n "$PLIST_MIN" ] && [ "$PLIST_MIN" != "$MIN_IOS_VERSION" ]; then
      echo "  Fixing Info.plist MinimumOSVersion: $PLIST_MIN -> $MIN_IOS_VERSION"
      plutil -replace MinimumOSVersion -string "$MIN_IOS_VERSION" "$ARCHIVE_OBJ_C_PLIST"
      NEEDS_FIX=true
    fi
  fi

  if [ "$NEEDS_FIX" = true ]; then
    echo "  Re-signing framework..."
    IDENTITY=$(security find-identity -v -p codesigning | head -1 | sed 's/.*"\(.*\)"/\1/')
    codesign --force --sign "$IDENTITY" --preserve-metadata=identifier,entitlements \
      "$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework"
    echo "  Done!"
  else
    echo "  No fixes needed."
  fi
else
  echo "  objective_c.framework not found in archive, skipping."
fi

echo "=== Exporting IPA ==="
EXPORT_OPTIONS="build/ios/ipa/ExportOptions.plist"
if [ ! -f "$EXPORT_OPTIONS" ]; then
  mkdir -p build/ios/ipa
  cat > "$EXPORT_OPTIONS" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>2P2W332P22</string>
  <key>uploadSymbols</key>
  <true/>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
PLIST
fi

rm -f build/ios/ipa/*.ipa
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath build/ios/ipa \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -quiet

echo ""
echo "=== Done ==="
echo "App Store Version: $CURRENT_BUILD_NAME  Build: $CURRENT_BUILD_NUMBER"
ls -lh build/ios/ipa/*.ipa
echo ""
echo "Upload to TestFlight:"
echo "  1. Open Transporter and drag the .ipa file"
echo "  2. Or: xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER"
