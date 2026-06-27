#!/bin/sh
set -e

if [ -z "${FRAMEWORKS_FOLDER_PATH:-}" ]; then
  echo "Skipping flutter_vodozemac embed: FRAMEWORKS_FOLDER_PATH is not set"
  exit 0
fi

SOURCE_FRAMEWORK="${BUILT_PRODUCTS_DIR}/flutter_vodozemac/flutter_vodozemac.framework"
STATIC_LIBRARY="${BUILT_PRODUCTS_DIR}/flutter_vodozemac/libvodozemac_bindings_dart.a"
DESTINATION_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
DESTINATION_FRAMEWORK="${DESTINATION_DIR}/flutter_vodozemac.framework"
DESTINATION_BINARY="${DESTINATION_FRAMEWORK}/flutter_vodozemac"

if [ ! -d "${SOURCE_FRAMEWORK}" ]; then
  echo "error: flutter_vodozemac.framework was not built at ${SOURCE_FRAMEWORK}" >&2
  exit 1
fi

if [ ! -f "${STATIC_LIBRARY}" ]; then
  echo "error: libvodozemac_bindings_dart.a was not built at ${STATIC_LIBRARY}" >&2
  exit 1
fi

mkdir -p "${DESTINATION_DIR}"
rm -rf "${DESTINATION_FRAMEWORK}"
mkdir -p "${DESTINATION_FRAMEWORK}"

if [ -f "${SOURCE_FRAMEWORK}/Info.plist" ]; then
  cp "${SOURCE_FRAMEWORK}/Info.plist" "${DESTINATION_FRAMEWORK}/Info.plist"
else
  cat > "${DESTINATION_FRAMEWORK}/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>flutter_vodozemac</string>
  <key>CFBundleIdentifier</key>
  <string>org.cocoapods.flutter-vodozemac</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>flutter_vodozemac</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>0.0.1</string>
  <key>CFBundleVersion</key>
  <string>1</string>
</dict>
</plist>
PLIST
fi

ARCH_FLAGS=""
for build_arch in ${ARCHS:-}; do
  ARCH_FLAGS="${ARCH_FLAGS} -arch ${build_arch}"
done
if [ -z "${ARCH_FLAGS}" ]; then
  ARCH_FLAGS="-arch arm64"
fi

SDK_LOOKUP_NAME="${PLATFORM_NAME:-iphoneos}"
case "${SDK_LOOKUP_NAME}" in
  iphoneos*) SDK_LOOKUP_NAME="iphoneos" ;;
  iphonesimulator*) SDK_LOOKUP_NAME="iphonesimulator" ;;
esac
SDK_PATH="$(xcrun --sdk "${SDK_LOOKUP_NAME}" --show-sdk-path 2>/dev/null || xcrun --sdk iphoneos --show-sdk-path)"
MIN_IOS_VERSION="${IPHONEOS_DEPLOYMENT_TARGET:-16.0}"
if [ "${PLATFORM_NAME:-iphoneos}" = "iphonesimulator" ]; then
  MIN_VERSION_FLAG="-mios-simulator-version-min=${MIN_IOS_VERSION}"
else
  MIN_VERSION_FLAG="-miphoneos-version-min=${MIN_IOS_VERSION}"
fi

xcrun clang -dynamiclib ${ARCH_FLAGS} \
  -isysroot "${SDK_PATH}" \
  "${MIN_VERSION_FLAG}" \
  -Wl,-force_load,"${STATIC_LIBRARY}" \
  -Wl,-install_name,@rpath/flutter_vodozemac.framework/flutter_vodozemac \
  -o "${DESTINATION_BINARY}"

if [ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] \
  && [ "${CODE_SIGNING_ALLOWED:-YES}" != "NO" ] \
  && [ "${CODE_SIGNING_REQUIRED:-YES}" != "NO" ]; then
  /usr/bin/codesign --force \
    --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
    ${OTHER_CODE_SIGN_FLAGS:-} \
    --preserve-metadata=identifier,entitlements \
    "${DESTINATION_FRAMEWORK}"
fi
