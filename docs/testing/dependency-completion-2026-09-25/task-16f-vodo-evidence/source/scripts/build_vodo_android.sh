#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

fail() {
  printf 'Vodo Android build: %s\n' "$1" >&2
  exit 1
}

[[ $# -eq 1 && ( "$1" == --preflight || "$1" == --build ) ]] ||
  fail 'usage: scripts/build_vodo_android.sh --preflight|--build'
[[ -n "${CARGO_HOME:-}" && -d "$CARGO_HOME" ]] ||
  fail 'set CARGO_HOME to the provisioned isolated Cargo directory'
[[ -n "${PUB_CACHE:-}" && -d "$PUB_CACHE" ]] ||
  fail 'set PUB_CACHE to the provisioned isolated Dart package directory'

check_sha() {
  local file=$1 expected=$2 actual
  [[ -f "$file" ]] || fail "missing input: $file"
  actual=$(shasum -a 256 "$file" | cut -d ' ' -f 1)
  [[ "$actual" == "$expected" ]] || fail "input hash mismatch: $file ($actual)"
  printf '%s %s\n' "$actual" "$file"
}

check_sha packages/flutter_vodozemac/rust/Cargo.toml \
  7f71f83cfd7df4c783ce061382fde11dbe5a9c013e44c50ca5555dbfb6e817c0
check_sha packages/flutter_vodozemac/rust/Cargo.lock \
  6ebe0a5c46e39aa243ba06754bfbaef22c56ba110e7868c44b3abfde2f875d61
check_sha packages/flutter_vodozemac/cargokit/build_tool/pubspec.lock \
  225c8196b05bd033af023077f75f842e282fedaa01e323f0c6dfa7e4d0d7ec97
check_sha packages/flutter_vodozemac/cargokit/build_tool/lib/src/android_environment.dart \
  68b65520057588eb17893bc5016b72fafb73222c5c38ec31252dfbe063c62ee0
check_sha packages/flutter_vodozemac/cargokit/build_tool/lib/src/builder.dart \
  c951ddf2066e60eec87f2c5201c7869d2e26d1457c5195877b2a9bf451b4af4a
check_sha packages/flutter_vodozemac/cargokit/run_build_tool.sh \
  53cb317d773a67dcedff1f971f88621799ed96ad883a465bbfc2a26555aae503
check_sha android/cargokit_options.yaml \
  2873f42d6b40604ebf0d2a666bea1834ef0421bffb12cbf9b17cfe02a09712a6

# Reject changes to every retained Rust crate file, including new build scripts
# or wrapper modules. The generated bridge alone does not bind its callees.
python3 - <<'PY' || fail 'Rust source tree mismatch'
from hashlib import sha256
from pathlib import Path
import sys

root = Path('packages/flutter_vodozemac/rust')
expected = {
    'Cargo.toml': '7f71f83cfd7df4c783ce061382fde11dbe5a9c013e44c50ca5555dbfb6e817c0',
    'Cargo.lock': '6ebe0a5c46e39aa243ba06754bfbaef22c56ba110e7868c44b3abfde2f875d61',
    'LICENSE': '499b339f40cfa26e7bb430bab2674c596422bbbef211a9c455fefaa130dcfdc5',
    'src/bindings.rs': '4024a5cb07ac7bc56a0926687e306d2fcf9cc3e7da691b728d2a0012e8c3ef34',
    'src/frb_generated.rs': '1b32ccf2af2b0cf800f0ff5d6efb261c7219764edf85091a0d451b5e8e9e118d',
    'src/ios_ffi_bindings.rs': '9f35f0139da6a83eab1c1f63df02874006258f405356c614f2ec5bc548a4f1ff',
    'src/lib.rs': '8b7d22e4e7efafe8248aa2cc917d7847665adcf1160d3efb1d3dd4edadf13258',
}
actual = {str(path.relative_to(root)) for path in root.rglob('*') if path.is_file() or path.is_symlink()}
if actual != expected.keys():
    print(f'Rust source file set mismatch: missing={sorted(expected.keys() - actual)} extra={sorted(actual - expected.keys())}', file=sys.stderr)
    raise SystemExit(1)
for relative, digest in expected.items():
    path = root / relative
    if path.is_symlink() or sha256(path.read_bytes()).hexdigest() != digest:
        print(f'Rust source hash mismatch: {relative}', file=sys.stderr)
        raise SystemExit(1)
print(f'Pinned Vodo Rust source tree verified: {len(expected)} files.')
PY

sdk_path=$(sed -n 's/^sdk.dir=//p' android/local.properties)
[[ -n "$sdk_path" && -d "$sdk_path" ]] || fail 'android/local.properties must select an installed SDK'
sdk_path=$(realpath "$sdk_path")
ndk="$sdk_path/ndk/28.2.13676358"
[[ -f "$ndk/source.properties" ]] || fail "missing pinned NDK: $ndk"
grep -Eq '^Pkg.Revision = 28\.2\.13676358$' "$ndk/source.properties" ||
  fail 'NDK revision mismatch'
clang="$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang"
check_sha "$clang" df85444b66234bf4cae267e22bde45ea8fef596d30ca2991b2091a27e6ea7718

rustc_version=$(rustup run stable rustc --version)
[[ "$rustc_version" == 'rustc 1.97.1 (8bab26f4f 2026-07-14)' ]] ||
  fail "stable Rust compiler mismatch: $rustc_version"
printf '%s\n' "$rustc_version"
rustup run stable cargo --version
for target in aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android; do
  rustup target list --toolchain stable --installed | grep -Fxq "$target" ||
    fail "missing stable Rust target: $target"
done

# Cargokit supplies these target-specific settings itself. Do not let an
# inherited Rust/NDK override change the accepted source build.
for name in $(compgen -e); do
  case "$name" in
    RUSTFLAGS|RUSTDOCFLAGS|RUSTC|RUSTC_WRAPPER|RUSTC_WORKSPACE_WRAPPER|\
    CARGO_ENCODED_RUSTFLAGS|CARGO_BUILD_RUSTFLAGS|CARGO_BUILD_TARGET|\
    CARGO_BUILD_RUSTC|CARGO_BUILD_RUSTC_WRAPPER|CARGO_BUILD_RUSTC_WORKSPACE_WRAPPER|\
    CARGO_TARGET_*|CC|CXX|AR|CC_*|CXX_*|AR_*) unset "$name" ;;
  esac
done
export CARGO_NET_OFFLINE=true
export CARGOKIT_PUB_OFFLINE=1

rustup run stable cargo metadata \
  --manifest-path packages/flutter_vodozemac/rust/Cargo.toml \
  --locked --offline --format-version 1 >/dev/null
printf 'Pinned Vodo Cargo graph resolved offline.\n'

if [[ "$1" == --preflight ]]; then
  exit 0
fi

cd android
./gradlew :flutter_vodozemac:assembleRelease \
  -Ptarget-platform=android-arm,android-arm64,android-x64 \
  --offline --no-daemon --rerun-tasks
