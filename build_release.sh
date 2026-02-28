#!/usr/bin/env bash
# build_release.sh — 自动递增版本号并构建 APK / IPA
#
# 用法:
#   ./build_release.sh          # 构建 apk + ipa（默认）
#   ./build_release.sh apk      # 仅构建 debug APK
#   ./build_release.sh ipa      # 仅构建 TestFlight IPA
#   ./build_release.sh all      # 构建 apk + ipa

set -euo pipefail

PUBSPEC="pubspec.yaml"
BIN_DIR="bin"
TARGET="${1:-all}"

# ── 1. 读取并递增版本号 ───────────────────────────────────────────────
CURRENT=$(grep '^version:' "$PUBSPEC" | awk '{print $2}')
# 格式: 2.1.X  → 拆分
MAJOR=$(echo "$CURRENT" | cut -d. -f1)
MINOR=$(echo "$CURRENT" | cut -d. -f2)
PATCH=$(echo "$CURRENT" | cut -d. -f3 | cut -d+ -f1)  # 兼容旧 +N 格式

NEW_PATCH=$((PATCH + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"

echo "▶ 版本递增: ${CURRENT} → ${NEW_VERSION}"

# 写回 pubspec.yaml（仅替换 version 行，保留其余内容不变）
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
else
  sed -i "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
fi

DATE=$(date +%Y%m%d)
mkdir -p "$BIN_DIR"

# ── 2. 公共 --dart-define 参数 ──────────────────────────────────────────
DART_DEFINES=""
[[ -n "${COINGECKO_API_KEY:-}" ]] && DART_DEFINES+=" --dart-define=COINGECKO_API_KEY=$COINGECKO_API_KEY"
[[ -n "${AI_API_KEY:-}" ]]        && DART_DEFINES+=" --dart-define=AI_API_KEY=$AI_API_KEY"

# ── 3. 构建 APK ────────────────────────────────────────────────────────
build_apk() {
  echo ""
  echo "▶ 构建 Debug APK ..."
  # shellcheck disable=SC2086
  flutter build apk --debug $DART_DEFINES
  APK_NAME="n42_v${NEW_VERSION}_debug_${DATE}.apk"
  cp build/app/outputs/flutter-apk/app-debug.apk "${BIN_DIR}/${APK_NAME}"
  echo "✓ APK → ${BIN_DIR}/${APK_NAME}  ($(du -sh "${BIN_DIR}/${APK_NAME}" | cut -f1))"
}

# ── 4. 构建 IPA ────────────────────────────────────────────────────────
build_ipa() {
  echo ""
  echo "▶ 构建 TestFlight IPA ..."
  # shellcheck disable=SC2086
  flutter build ipa $DART_DEFINES
  IPA_SRC=$(ls build/ios/ipa/*.ipa 2>/dev/null | head -1)
  if [[ -z "$IPA_SRC" ]]; then
    echo "✗ IPA 文件未找到，构建可能失败"
    exit 1
  fi
  IPA_NAME="n42_v${NEW_VERSION}_testflight_${DATE}.ipa"
  cp "$IPA_SRC" "${BIN_DIR}/${IPA_NAME}"
  echo "✓ IPA → ${BIN_DIR}/${IPA_NAME}  ($(du -sh "${BIN_DIR}/${IPA_NAME}" | cut -f1))"
}

# ── 5. 执行目标 ────────────────────────────────────────────────────────
case "$TARGET" in
  apk)
    build_apk
    ;;
  ipa)
    build_ipa
    ;;
  all|*)
    build_apk
    build_ipa
    ;;
esac

echo ""
echo "✅ 完成  版本: ${NEW_VERSION}  日期: ${DATE}"
