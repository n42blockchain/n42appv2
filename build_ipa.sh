#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE_PATH="$SCRIPT_DIR/build/ios/archive/Runner.xcarchive"
EXPORT_DIR="$SCRIPT_DIR/build/ios/ipa"
EXPORT_OPTIONS="$SCRIPT_DIR/ios/ExportOptions-AppStore.plist"
HOOKS_DIR="$SCRIPT_DIR/.dart_tool/hooks_runner/shared/objective_c/build"

echo "=== 清理 native assets 缓存 ==="
rm -rf "$SCRIPT_DIR/build/native_assets/ios"

echo "=== 清理 hooks_runner 中的 x86_64/Simulator 缓存 ==="
if [ -d "$HOOKS_DIR" ]; then
    find "$HOOKS_DIR" -name "objective_c.dylib" | while read -r dylib; do
        platform=$(otool -l "$dylib" 2>/dev/null | awk '/LC_BUILD_VERSION/{found=1} found && /platform/{print $2; exit}')
        arch=$(lipo -info "$dylib" 2>/dev/null | grep -o 'x86_64' || true)
        # platform 7 = iOS Simulator; also remove any x86_64 slice
        if [ "$platform" = "7" ] || [ -n "$arch" ]; then
            dir=$(dirname "$dylib")
            echo "删除 Simulator/x86_64 缓存: $dir"
            rm -rf "$dir"
        fi
    done
fi

echo "=== 构建 Archive ==="
cd "$SCRIPT_DIR"
flutter build ipa --release

echo "=== 验证 native_assets 架构 ==="
OBJ_C_NATIVE="$SCRIPT_DIR/build/native_assets/ios/objective_c.framework/objective_c"
if [ -f "$OBJ_C_NATIVE" ]; then
    echo "native_assets 架构: $(lipo -info "$OBJ_C_NATIVE")"
fi

echo "=== 验证 xcarchive 架构 ==="
OBJ_C_ARCHIVE="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
if [ -f "$OBJ_C_ARCHIVE" ]; then
    INFO=$(lipo -info "$OBJ_C_ARCHIVE")
    echo "xcarchive 架构: $INFO"
    if echo "$INFO" | grep -q 'x86_64'; then
        echo "WARNING: 仍含 x86_64，强制剥离..."
        lipo "$OBJ_C_ARCHIVE" -remove x86_64 -output "$OBJ_C_ARCHIVE"
        echo "修复后: $(lipo -info "$OBJ_C_ARCHIVE")"
    fi
fi

echo "=== 从 Archive 导出并上传 IPA ==="
rm -rf "$EXPORT_DIR"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -allowProvisioningUpdates

echo "=== 完成 ==="
