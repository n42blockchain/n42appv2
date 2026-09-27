#!/usr/bin/env bash
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
cd "$repo"
evidence="$repo/.superpowers/sdd/dependency-completion-20260925/task-16f-owned-build2"
mkdir -p "$evidence"
gradle_file="$repo/android/app/build.gradle.kts"
backup="$evidence/build.gradle.kts.original"
cp "$gradle_file" "$backup"
original_hash=$(shasum -a 256 "$backup" | cut -d ' ' -f 1)
restore() {
  cp "$backup" "$gradle_file"
  restored_hash=$(shasum -a 256 "$gradle_file" | cut -d ' ' -f 1)
  if [[ "$restored_hash" != "$original_hash" ]]; then
    printf 'Signing source restore hash mismatch\n' >&2
    exit 1
  fi
  printf 'Signing source restored: %s\n' "$restored_hash"
}
trap restore EXIT

export PATH="/Users/jieliu/.codex/toolchains/flutter-3.47.5/flutter/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/28.2.13676358"
export CARGO_HOME="$repo/.superpowers/sdd/dependency-completion-20260925/task-16f-vodo-cargo-home"
export PUB_CACHE=/Users/jieliu/.pub-cache
export CARGO_NET_OFFLINE=true
export CARGOKIT_PUB_OFFLINE=1
export GRADLE_OPTS=-Dorg.gradle.offline=true

{
  printf 'git_head='; git rev-parse HEAD
  printf 'pubspec_version='; sed -n 's/^version: //p' pubspec.yaml
  printf 'flutter='; flutter --version --machine | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["frameworkVersion"], d["dartSdkVersion"])'
  java -version 2>&1
  rustup run stable rustc --version
  rustup run stable cargo --version
  printf 'sdk=%s\nndk=%s\n' "$ANDROID_HOME" "$ANDROID_NDK_HOME"
  shasum -a 256 "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang" android/app/libs/evm.aar android/app/libs/mobile-sdk-android.aar build/flutter_vodozemac/outputs/aar/flutter_vodozemac-release.aar
  printf 'original_gradle_sha256=%s\n' "$original_hash"
  printf 'signing=temporary local Android debug signing, not distribution signed\n'
  printf 'gradle_offline=unverified cargo_offline=true cargokit_pub_offline=true\n'
} > "$evidence/inputs.txt"

python3 - "$gradle_file" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
needle = 'signingConfig = signingConfigs.getByName("release")'
if source.count(needle) != 1:
    raise SystemExit('Expected exactly one release signing selection')
path.write_text(source.replace(needle, 'signingConfig = signingConfigs.getByName("debug")', 1))
PY

printf 'APK build start: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
printf '%s\n' 'flutter build apk --release --target-platform android-arm,android-arm64,android-x64' > "$evidence/apk-command.txt"
set +e
flutter build apk --release --target-platform android-arm,android-arm64,android-x64 > "$evidence/apk-build.log" 2>&1
apk_rc=$?
set -e
printf 'apk_exit=%d\n' "$apk_rc" | tee -a "$evidence/inputs.txt"
(( apk_rc == 0 )) || exit "$apk_rc"
cp build/app/outputs/flutter-apk/app-release.apk "$evidence/app-release.apk"
shasum -a 256 "$evidence/app-release.apk" > "$evidence/apk.sha256"
stat -f '%z' "$evidence/app-release.apk" > "$evidence/apk.bytes"

printf 'AAB build start: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
printf '%s\n' 'flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64' > "$evidence/aab-command.txt"
set +e
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64 > "$evidence/aab-build.log" 2>&1
aab_rc=$?
set -e
printf 'aab_exit=%d\n' "$aab_rc" | tee -a "$evidence/inputs.txt"
(( aab_rc == 0 )) || exit "$aab_rc"
cp build/app/outputs/bundle/release/app-release.aab "$evidence/app-release.aab"
shasum -a 256 "$evidence/app-release.aab" > "$evidence/aab.sha256"
stat -f '%z' "$evidence/app-release.aab" > "$evidence/aab.bytes"
printf 'Builds finished: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
