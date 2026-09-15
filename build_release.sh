#!/usr/bin/env bash
# Build release artifacts at the committed version; never upload or source .env.
# Usage: ./build_release.sh [apk|aab|android|ipa|all] [--dart-define-from-file PATH]
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-all}"
if [ "$#" -gt 0 ]; then shift; fi
case "$TARGET" in
  apk|aab|android|ipa|all) ;;
  *) echo "Unknown release target: $TARGET" >&2; exit 64 ;;
esac
CONFIG_FILE=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dart-define-from-file)
      if [ "$#" -lt 2 ] || [ ! -f "$2" ] || [ ! -r "$2" ]; then
        echo "Release configuration file is missing or unreadable" >&2; exit 64
      fi
      CONFIG_FILE="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
      shift 2 ;;
    *) echo "Unknown release option" >&2; exit 64 ;;
  esac
done
cd "$PROJECT_ROOT"
python3 scripts/quality_gate.py version pubspec.yaml
if [ -z "$CONFIG_FILE" ] && [ -f .env ]; then CONFIG_FILE="$PROJECT_ROOT/.env"; fi
BUILD_ARGS=()
if [ -n "$CONFIG_FILE" ]; then
  BUILD_ARGS+=("--dart-define-from-file=$CONFIG_FILE")
fi
if [ "$TARGET" != ipa ] && [ ! -f android/key.properties ]; then
  echo "Android release signing requires android/key.properties" >&2; exit 1
fi
flutter pub get --enforce-lockfile
build_apk() { flutter build apk --release ${BUILD_ARGS[@]+"${BUILD_ARGS[@]}"}; }
build_aab() { flutter build appbundle --release ${BUILD_ARGS[@]+"${BUILD_ARGS[@]}"}; }
build_ipa() {
  IPA_ARGS=(--no-bump)
  if [ -n "$CONFIG_FILE" ]; then IPA_ARGS+=(--dart-define-from-file "$CONFIG_FILE"); fi
  bash scripts/build_ipa.sh "${IPA_ARGS[@]}"
}
case "$TARGET" in
  apk) build_apk ;;
  aab) build_aab ;;
  android) build_aab; build_apk ;;
  ipa) build_ipa ;;
  all) build_aab; build_apk; build_ipa ;;
esac
