#!/usr/bin/env bash
# Run synthetic MLS JNI calls in app_process on the dedicated offline 16 KB VM.
set -euo pipefail
fail() { printf 'MLS fixture rejected: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 2 ]] || fail 'usage: run.sh ABSOLUTE_LIB_PATH NEW_OUTPUT_DIR'
LIB="$1"
OUTPUT="$2"
[[ "$LIB" = /* && -s "$LIB" ]] || fail 'library must be an existing absolute file'
[[ "$OUTPUT" = /* && ! -e "$OUTPUT" && ! -L "$OUTPUT" ]] || fail 'output directory must be fresh and absolute'
[[ -d "$(dirname "$OUTPUT")" ]] || fail 'output parent does not exist'
SDK="${ANDROID_SDK_ROOT:-}"
[[ -x "$SDK/build-tools/37.0.0/d8" ]] || fail 'pinned Android build tools 37.0.0 required'
[[ "$(adb -s emulator-5560 shell getconf PAGE_SIZE | tr -d '\r')" = 16384 ]] || fail 'wrong page size'
[[ "$(adb -s emulator-5560 shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r')" = fatal ]] || fail 'nonfatal linker mode'
[[ "$(adb -s emulator-5560 shell getprop pm.16kb.app_compat.disabled | tr -d '\r')" = true ]] || fail 'app compatibility is enabled'
mkdir "$OUTPUT"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mkdir "$OUTPUT/classes" "$OUTPUT/dex"
javac --release 8 -d "$OUTPUT/classes" "$ROOT"/tools/android_mls_fixture/src/ai/n42/www/*.java > "$OUTPUT/javac.log" 2>&1
"$SDK/build-tools/37.0.0/d8" --min-api 26 --output "$OUTPUT/dex" "$OUTPUT"/classes/ai/n42/www/*.class > "$OUTPUT/d8.log" 2>&1
HOST_SHA="$(shasum -a 256 "$LIB" | cut -d ' ' -f 1)"
DEX_SHA="$(shasum -a 256 "$OUTPUT/dex/classes.dex" | cut -d ' ' -f 1)"
{
  printf 'library=%s\nlibrary_sha256=%s\ndex_sha256=%s\n' "$LIB" "$HOST_SHA" "$DEX_SHA"
  printf 'device=emulator-5560\npage_size=%s\nlinker_mode=%s\ncompat_disabled=%s\n' \
    "$(adb -s emulator-5560 shell getconf PAGE_SIZE | tr -d '\r')" \
    "$(adb -s emulator-5560 shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r')" \
    "$(adb -s emulator-5560 shell getprop pm.16kb.app_compat.disabled | tr -d '\r')"
} > "$OUTPUT/inputs.txt"
adb -s emulator-5560 shell mkdir -p /data/local/tmp/n42-mls-fixture > "$OUTPUT/device-setup.log" 2>&1
adb -s emulator-5560 push "$OUTPUT/dex/classes.dex" /data/local/tmp/n42-mls-fixture/classes.dex >> "$OUTPUT/device-setup.log" 2>&1
adb -s emulator-5560 push "$LIB" /data/local/tmp/n42-mls-fixture/libn42_mls-selected.so >> "$OUTPUT/device-setup.log" 2>&1
DEVICE_SHA="$(adb -s emulator-5560 shell sha256sum /data/local/tmp/n42-mls-fixture/libn42_mls-selected.so | cut -d ' ' -f 1)"
[[ "$DEVICE_SHA" = "$HOST_SHA" ]] || fail 'pushed library hash differs from input'
printf 'device_library_sha256=%s\n' "$DEVICE_SHA" >> "$OUTPUT/inputs.txt"
adb -s emulator-5560 shell 'N42_MLS_FIXTURE_LIBRARY=/data/local/tmp/n42-mls-fixture/libn42_mls-selected.so CLASSPATH=/data/local/tmp/n42-mls-fixture/classes.dex app_process /system/bin ai.n42.www.MlsFixture' > "$OUTPUT/jni.log" 2>&1
rg -qx 'MLS_FIXTURE_PASS' "$OUTPUT/jni.log" || fail 'synthetic JNI fixture did not pass'
[[ "$(adb -s emulator-5560 shell getconf PAGE_SIZE | tr -d '\r')" = 16384 ]] || fail 'page size changed'
[[ "$(adb -s emulator-5560 shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r')" = fatal ]] || fail 'linker mode changed'
[[ "$(adb -s emulator-5560 shell getprop pm.16kb.app_compat.disabled | tr -d '\r')" = true ]] || fail 'compatibility setting changed'
printf 'post_page_size=16384\npost_linker_mode=fatal\npost_compat_disabled=true\nresult=PASS\n' >> "$OUTPUT/inputs.txt"
cat "$OUTPUT/inputs.txt"
