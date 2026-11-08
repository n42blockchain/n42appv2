#!/bin/bash
# Build IPA for TestFlight with automatic fix for objective_c simulator platform bug
#
# Usage: ./scripts/build_ipa.sh [OPTIONS]
#   --no-bump       Skip build number auto-increment (rebuild same version)
#   --set-version X Set App Store version (CFBundleShortVersionString), e.g. --set-version 1.0.17
#   --dart-define-from-file PATH  Load private release configuration without logging it
#
# Version strategy:
#   - pubspec.yaml is the single source of truth for both version fields.
#   - App Store Version (CFBundleShortVersionString): manual, change with --set-version.
#   - App Store Build   (CFBundleVersion): auto-increment each build unless --no-bump.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

MIN_IOS_VERSION="16.0"
PUBSPEC="pubspec.yaml"

# === Parse arguments ===
NO_BUMP=false
NEW_APP_VERSION=""
BUILD_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --no-bump)
      NO_BUMP=true
      shift
      ;;
    --set-version)
      [ $# -ge 2 ] && [[ "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "--set-version requires X.Y.Z"; exit 1; }
      NEW_APP_VERSION="$2"
      shift 2
      ;;
    --dart-define-from-file)
      [ $# -ge 2 ] && [ -r "$2" ] || { echo "Release configuration file is missing or unreadable"; exit 1; }
      BUILD_ARGS+=("--dart-define-from-file=$2")
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

python3 scripts/quality_gate.py version "$PUBSPEC"
IOS_SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version)"
IOS_SDK_MAJOR="${IOS_SDK_VERSION%%.*}"
IOS_SDK_MINOR="${IOS_SDK_VERSION#*.}"
IOS_SDK_MINOR="${IOS_SDK_MINOR%%.*}"
if [ "$IOS_SDK_MAJOR" -lt 27 ] || { [ "$IOS_SDK_MAJOR" -eq 27 ] && [ "$IOS_SDK_MINOR" -lt 1 ]; }; then
  echo "iPhone Duo releases require iOS SDK 27.1 or later (Xcode 27.1+)" >&2
  exit 1
fi

# Fetch verified model bundles before changing versions or invoking CocoaPods.
python3 scripts/prepare_mlkit_resources.py

# === Read the canonical version from pubspec.yaml ===
CURRENT_PUBSPEC=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
CURRENT_BUILD_NAME=$(echo "$CURRENT_PUBSPEC" | cut -d'+' -f1)
CURRENT_BUILD_NUMBER=$(echo "$CURRENT_PUBSPEC" | cut -d'+' -f2)

echo "=== Current App Store version: $CURRENT_BUILD_NAME ($CURRENT_BUILD_NUMBER) ==="

# === Update App Store Version if requested ===
if [ -n "$NEW_APP_VERSION" ]; then
  echo "=== Updating App Store version: $CURRENT_BUILD_NAME -> $NEW_APP_VERSION ==="
  CURRENT_BUILD_NAME="$NEW_APP_VERSION"
fi

# === Auto-increment Build Number ===
if [ "$NO_BUMP" = false ]; then
  NEW_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
  echo "=== Build number: $CURRENT_BUILD_NUMBER -> $NEW_BUILD_NUMBER ==="
  CURRENT_BUILD_NUMBER="$NEW_BUILD_NUMBER"
else
  echo "=== No bump (using existing build number: $CURRENT_BUILD_NUMBER) ==="
fi

RESOLVED_VERSION="$CURRENT_BUILD_NAME+$CURRENT_BUILD_NUMBER"
if [ "$RESOLVED_VERSION" != "$CURRENT_PUBSPEC" ]; then
  sed -i '' "s/^version: .*/version: $RESOLVED_VERSION/" "$PUBSPEC"
  echo "=== Flutter version: $CURRENT_PUBSPEC -> $RESOLVED_VERSION ==="
fi

# Runner and NotificationExtension inherit Flutter's generated version settings.
# The build flags below update that shared source without rewriting the project.

echo ""
echo "=== Building IPA: $CURRENT_BUILD_NAME ($CURRENT_BUILD_NUMBER) ==="
echo ""

echo "=== Building iOS archive ==="
mkdir -p build/release-evidence
python3 scripts/release/wallet_capability_manifest.py --output build/release-evidence/wallet-ipa-source.json
flutter build ipa \
  --release \
  --export-options-plist=ios/ExportOptions-AppStore.plist \
  --build-name="$CURRENT_BUILD_NAME" \
  --build-number="$CURRENT_BUILD_NUMBER" \
  ${BUILD_ARGS[@]+"${BUILD_ARGS[@]}"}

python3 scripts/release/login_build_evidence.py --settings ios/Flutter/Generated.xcconfig --output build/release-evidence/wallet-ipa-login-build.json

echo "=== Fixing objective_c.framework in archive ==="
ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
ARCHIVE_APP="$ARCHIVE_PATH/Products/Applications/Runner.app"
bash scripts/check_ios_version.sh "$ARCHIVE_PATH/Products/Applications/Runner.app"
ARCHIVE_OBJ_C="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
ARCHIVE_OBJ_C_PLIST="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/Info.plist"

if [ -f "$ARCHIVE_OBJ_C" ]; then
  NEEDS_FIX=false

  # Check platform tag
  PLATFORM=$(vtool -show "$ARCHIVE_OBJ_C" 2>/dev/null | grep "platform " | head -1 | xargs)
  if echo "$PLATFORM" | grep -qi "simulator"; then
    echo "  Fixing platform: IOSSIMULATOR -> IOS"
    vtool -set-build-version ios "$MIN_IOS_VERSION" "$IOS_SDK_VERSION" -replace \
      -output "$ARCHIVE_OBJ_C" "$ARCHIVE_OBJ_C"
    NEEDS_FIX=true
  fi

  # Check minos version
  MINOS=$(vtool -show "$ARCHIVE_OBJ_C" 2>/dev/null | grep "minos " | head -1 | awk '{print $2}')
  if [ -n "$MINOS" ] && [ "$(printf '%s\n' "$MIN_IOS_VERSION" "$MINOS" | sort -V | head -1)" != "$MIN_IOS_VERSION" ]; then
    echo "  Fixing minos: $MINOS -> $MIN_IOS_VERSION"
    vtool -set-build-version ios "$MIN_IOS_VERSION" "$IOS_SDK_VERSION" -replace \
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
    # Use the archive's signer, not the first unrelated identity in the keychain.
    IDENTITY=$(codesign --display --verbose=4 "$ARCHIVE_APP" 2>&1 | \
      sed -n 's/^Authority=//p' | head -1)
    if [ -z "$IDENTITY" ]; then
      echo "Cannot identify the archive signing authority." >&2
      exit 1
    fi
    codesign --force --sign "$IDENTITY" --preserve-metadata=identifier,entitlements \
      "$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework"
    # Nested code changes invalidate the containing app's resource seal.
    codesign --force --sign "$IDENTITY" \
      --preserve-metadata=identifier,entitlements,requirements,flags "$ARCHIVE_APP"
    echo "  Done!"
  else
    echo "  No fixes needed."
  fi
else
  echo "  objective_c.framework not found in archive, skipping."
fi

# Fail before export if the repaired archive or any nested signature is invalid.
codesign --verify --deep --strict "$ARCHIVE_APP"

echo "=== Exporting IPA ==="
mkdir -p build/ios/ipa
# Flutter's generated ExportOptions.plist enables automatic build-number
# management. This second export must preserve the archive's build number.
EXPORT_OPTIONS="build/ios/ipa/N42WalletExportOptions.plist"
cat > "$EXPORT_OPTIONS" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>manageAppVersionAndBuildNumber</key>
  <false/>
  <key>teamID</key>
  <string>CFRXH38L48</string>
  <key>uploadSymbols</key>
  <true/>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
PLIST

rm -f build/ios/ipa/*.ipa
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath build/ios/ipa \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -quiet

echo ""
python3 scripts/release/wallet_capability_manifest.py --artifact build/ios/ipa/N42Wallet.ipa --require-source build/release-evidence/wallet-ipa-source.json --output build/release-evidence/wallet-ipa.json
python3 scripts/release/verify_ios_chat_crypto.py --ipa build/ios/ipa/N42Wallet.ipa --output build/release-evidence/wallet-ipa-chat-crypto.json
python3 scripts/release/verify_ios_social_auth.py \
  --ipa build/ios/ipa/N42Wallet.ipa \
  --google-plist ios/Runner/GoogleService-Info.plist \
  --native-config ios/Flutter/ChatSocialAuth.xcconfig \
  --output build/release-evidence/wallet-ipa-social-auth.json
echo "=== Done ==="
echo "App Store Version: $CURRENT_BUILD_NAME  Build: $CURRENT_BUILD_NUMBER"
ls -lh build/ios/ipa/*.ipa
echo ""
echo "Upload to TestFlight:"
echo "  1. Open Transporter and drag the .ipa file"
echo "  2. Or: xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER"
