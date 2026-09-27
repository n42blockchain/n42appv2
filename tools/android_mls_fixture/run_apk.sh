#!/usr/bin/env bash
# Build and run a signed, isolated synthetic APK containing one selected arm64 MLS library.
set -euo pipefail
fail() { printf 'MLS APK fixture rejected: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 2 ]] || fail 'usage: run_apk.sh ABSOLUTE_ARM64_LIB NEW_OUTPUT_DIR'
LIB="$1"
OUTPUT="$2"
[[ "$LIB" = /* && -s "$LIB" ]] || fail 'library must be an existing absolute file'
[[ "$OUTPUT" = /* && ! -e "$OUTPUT" && ! -L "$OUTPUT" ]] || fail 'output directory must be fresh and absolute'
[[ -d "$(dirname "$OUTPUT")" ]] || fail 'output parent does not exist'
SDK="${ANDROID_SDK_ROOT:-}"
TOOLS="$SDK/build-tools/37.0.0"
ANDROID_JAR="$SDK/platforms/android-37.0/android.jar"
for tool in aapt2 d8 zipalign apksigner; do
  [[ -x "$TOOLS/$tool" ]] || fail "missing pinned $tool from build-tools 37.0.0"
done
[[ -f "$ANDROID_JAR" ]] || fail 'Android 37.0 platform jar is missing'
page_size() { adb -s emulator-5560 shell getconf PAGE_SIZE | tr -d '\r'; }
linker_mode() { adb -s emulator-5560 shell getprop bionic.linker.16kb.app_compat.enabled | tr -d '\r'; }
compat_disabled() { adb -s emulator-5560 shell getprop pm.16kb.app_compat.disabled | tr -d '\r'; }
[[ "$(page_size)" = 16384 ]] || fail 'wrong page size'
[[ "$(linker_mode)" = fatal ]] || fail 'nonfatal linker mode'
[[ "$(compat_disabled)" = true ]] || fail 'app compatibility is enabled'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mkdir "$OUTPUT"
mkdir "$OUTPUT/classes" "$OUTPUT/dex"
printf 'selected_library_sha256=%s\npage_size=16384\nlinker_mode=fatal\ncompat_disabled=true\n' \
  "$(shasum -a 256 "$LIB" | cut -d ' ' -f 1)" > "$OUTPUT/inputs.txt"
javac --release 8 -cp "$ANDROID_JAR" -d "$OUTPUT/classes" \
  "$ROOT"/tools/android_mls_fixture/src/ai/n42/www/*.java > "$OUTPUT/javac.log" 2>&1
"$TOOLS/d8" --min-api 26 --lib "$ANDROID_JAR" --output "$OUTPUT/dex" \
  "$OUTPUT"/classes/ai/n42/www/*.class > "$OUTPUT/d8.log" 2>&1
"$TOOLS/aapt2" link -I "$ANDROID_JAR" \
  --manifest "$ROOT/tools/android_mls_fixture/AndroidManifest.xml" \
  -o "$OUTPUT/unaligned.apk" > "$OUTPUT/aapt2.log" 2>&1
python3 - "$OUTPUT/unaligned.apk" "$OUTPUT/dex/classes.dex" "$LIB" <<'PY'
import sys
import zipfile
with zipfile.ZipFile(sys.argv[1], 'a') as apk:
    apk.write(sys.argv[2], 'classes.dex', compress_type=zipfile.ZIP_STORED)
    apk.write(sys.argv[3], 'lib/arm64-v8a/libn42_mls.so', compress_type=zipfile.ZIP_STORED)
PY
"$TOOLS/zipalign" -P 16 4 "$OUTPUT/unaligned.apk" "$OUTPUT/aligned.apk" > "$OUTPUT/zipalign.log" 2>&1
"$TOOLS/zipalign" -c -P 16 4 "$OUTPUT/aligned.apk" >> "$OUTPUT/zipalign.log" 2>&1
# This disposable key signs only the synthetic fixture package. Never archive it.
keytool -genkeypair -keystore "$OUTPUT/synthetic-fixture.p12" -storetype PKCS12 \
  -alias synthetic-mls -keyalg RSA -keysize 2048 -validity 2 \
  -dname 'CN=Synthetic MLS Fixture' \
  -storepass synthetic-mls-only -keypass synthetic-mls-only > "$OUTPUT/keygen.log" 2>&1
"$TOOLS/apksigner" sign --ks "$OUTPUT/synthetic-fixture.p12" \
  --ks-pass pass:synthetic-mls-only --key-pass pass:synthetic-mls-only \
  --out "$OUTPUT/signed.apk" "$OUTPUT/aligned.apk" > "$OUTPUT/sign.log" 2>&1
"$TOOLS/apksigner" verify --verbose "$OUTPUT/signed.apk" > "$OUTPUT/apksigner-verify.log" 2>&1
"$TOOLS/zipalign" -c -P 16 4 "$OUTPUT/signed.apk" > "$OUTPUT/signed-zipalign.log" 2>&1
python3 "$ROOT/scripts/audit_android_native.py" "$OUTPUT/signed.apk" > "$OUTPUT/elf-audit.json"
"$TOOLS/aapt2" dump badging "$OUTPUT/signed.apk" > "$OUTPUT/badging.txt" 2>&1
printf 'signed_apk_sha256=%s\ndex_sha256=%s\n' \
  "$(shasum -a 256 "$OUTPUT/signed.apk" | cut -d ' ' -f 1)" \
  "$(shasum -a 256 "$OUTPUT/dex/classes.dex" | cut -d ' ' -f 1)" >> "$OUTPUT/inputs.txt"

adb -s emulator-5560 shell am force-stop ai.n42.fixture.mls > "$OUTPUT/force-stop.log" 2>&1
# Each fresh run generates a different disposable signer. Remove only this
# synthetic package so a prior fixture signature cannot block installation.
if adb -s emulator-5560 shell pm path ai.n42.fixture.mls | rg -q '^package:'; then
  adb -s emulator-5560 uninstall ai.n42.fixture.mls > "$OUTPUT/uninstall.log" 2>&1
fi
adb -s emulator-5560 install --no-incremental "$OUTPUT/signed.apk" > "$OUTPUT/install.log" 2>&1
adb -s emulator-5560 logcat -c
adb -s emulator-5560 shell am start -n ai.n42.fixture.mls/ai.n42.www.MlsFixtureActivity > "$OUTPUT/launch.log" 2>&1
pid=''
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  pid="$(adb -s emulator-5560 shell pidof ai.n42.fixture.mls 2>/dev/null | tr -d '\r' || true)"
  if [[ -n "$pid" ]]; then break; fi
  sleep 1
done
[[ -n "$pid" ]] || fail 'fixture APK process did not start'
printf 'pid=%s\n' "$pid" >> "$OUTPUT/inputs.txt"
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  adb -s emulator-5560 logcat -d --pid="$pid" > "$OUTPUT/logcat.log" 2>&1
  if rg -q 'MLS_APK_FIXTURE_PASS|MLS_APK_FIXTURE_FAIL' "$OUTPUT/logcat.log"; then break; fi
  sleep 1
done
rg -q 'MLS_APK_FIXTURE_PASS' "$OUTPUT/logcat.log" || fail 'fixture did not finish successfully'
if rg -q 'MLS_APK_FIXTURE_FAIL' "$OUTPUT/logcat.log"; then fail 'fixture reported failure'; fi
package_path="$(adb -s emulator-5560 shell pm path ai.n42.fixture.mls | tr -d '\r' | sed -n 's/^package://p')"
[[ "$package_path" = /data/app/*/base.apk ]] || fail 'installed APK path is missing'
device_sha="$(adb -s emulator-5560 shell sha256sum "$package_path" | cut -d ' ' -f 1)"
host_sha="$(shasum -a 256 "$OUTPUT/signed.apk" | cut -d ' ' -f 1)"
[[ "$device_sha" = "$host_sha" ]] || fail 'installed APK differs from signed input'
printf 'installed_path=%s\ninstalled_apk_sha256=%s\n' "$package_path" "$device_sha" >> "$OUTPUT/inputs.txt"
python3 "$ROOT/tools/android_mls_fixture/verify_apk.py" \
  "$OUTPUT/signed.apk" "$LIB" "$OUTPUT/logcat.log" > "$OUTPUT/mapping-verification.json"
[[ "$(page_size)" = 16384 ]] || fail 'page size changed'
[[ "$(linker_mode)" = fatal ]] || fail 'linker mode changed'
[[ "$(compat_disabled)" = true ]] || fail 'compatibility setting changed'
printf 'post_page_size=16384\npost_linker_mode=fatal\npost_compat_disabled=true\nresult=PASS\n' >> "$OUTPUT/inputs.txt"
cat "$OUTPUT/inputs.txt"
