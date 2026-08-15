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

# ── 1.5. 读取 .env（如存在）────────────────────────────────────────────
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# ── 2. 公共 --dart-define 参数 ──────────────────────────────────────────
DART_DEFINES=""
for key in \
  INFURA_API_KEY \
  INFURA_SEPOLIA_KEY \
  ETHERSCAN_API_KEY \
  BSCSCAN_API_KEY \
  BASESCAN_API_KEY \
  SONICSCAN_API_KEY \
  SOLSCAN_API_TOKEN \
  TRON_PRO_API_KEY \
  TOKENVIEW_API_KEY \
  TON_API_KEY_MAINNET \
  TON_API_KEY_TESTNET \
  DOT_API_KEY \
  COINGECKO_API_KEY \
  SIMPLE_HASH_API_KEY \
  MOONPAY_SECRET_KEY \
  MOONPAY_SECRET_KEY_TEST \
  AI_API_KEY \
  AI_BASE_URL \
  AI_MODEL \
  GOOGLE_TRANSLATE_API_KEY \
  GOOGLE_SPEECH_API_KEY \
  AZURE_SPEECH_API_KEY \
  AZURE_SPEECH_REGION \
  GIPHY_API_KEY \
  TENOR_API_KEY \
  FIATRAMP_API_KEY \
  LOCAL_LLM_MODEL_URL \
  LOCAL_LLM_HF_TOKEN \
  DEBANK_API_KEY \
  ALCHEMY_API_KEY \
  N42_CHAT_GOOGLE_CLIENT_ID \
  N42_CHAT_GOOGLE_SERVER_CLIENT_ID \
  N42_CHAT_TWITTER_API_KEY \
  N42_CHAT_TWITTER_API_SECRET \
  N42_CHAT_TWITTER_REDIRECT_URI \
  N42_CHAT_WECHAT_APP_ID \
  N42_CHAT_WECHAT_UNIVERSAL_LINK \
  PROXY_BASE_URL \
  PROXY_AUTH_TOKEN \
  MINING_WS_URL \
  MINING_RPC_URL \
  MINING_EXPLORER_URL \
  N42_TESTNET_RPC \
  ETH_RPC_URL \
  BTC_TESTNET_RPC \
  BTC_MAINNET_RPC \
  IPFS_USERNAME \
  IPFS_PASSWORD; do
  value="${!key:-}"
  [[ -n "$value" ]] && DART_DEFINES+=" --dart-define=${key}=${value}"
done

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
