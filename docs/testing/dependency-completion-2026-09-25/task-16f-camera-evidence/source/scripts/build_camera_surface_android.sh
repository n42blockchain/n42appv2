#!/usr/bin/env bash
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
project="$repo/android/native/camera_core_surface"
default_source="$project/upstream"
source_dir="$default_source"
out_dir="$repo/.superpowers/sdd/dependency-completion-20260925/task-16f-camera-build/candidate"

fail() {
  printf 'Camera surface build: %s\n' "$1" >&2
  exit 1
}

[[ $# -ge 1 && ( "$1" == --preflight || "$1" == --build ) ]] ||
  fail 'usage: build_camera_surface_android.sh --preflight|--build [--source-dir DIR] [--out-dir DIR]'
mode=$1
shift
while (( $# )); do
  case "$1" in
    --source-dir) [[ $# -ge 2 ]] || fail 'missing --source-dir value'; source_dir=$2; shift 2 ;;
    --out-dir) [[ $# -ge 2 ]] || fail 'missing --out-dir value'; out_dir=$2; shift 2 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

# Recheck the complete small source input set before touching CMake or output.
python3 - "$source_dir" <<'PY' || fail 'pinned source verification failed'
from hashlib import sha256
from pathlib import Path
import sys

root = Path(sys.argv[1])
expected = {
    'CMakeLists.txt': '6506d3c4353821f4596648008801a81312e2214725297286e067351f8667b286',
    'LICENSE.txt': '809fa1ed21450f59827d1e9aec720bbc4b687434fa22283c6cb5dd82a47ab9c0',
    'jni.lds': 'b578ca06967ba7ff8d732eeb99a8e91917335d00f19fe2d44e7cb805946ee45c',
    'surface_util_jni.cc': 'dd3f02712e359fa0b987bfef17661686fa130666674fca2d91405b50ab309779',
}
actual = {str(path.relative_to(root)) for path in root.rglob('*') if path.is_file() or path.is_symlink()}
if actual != expected.keys():
    print(f'source file set mismatch: missing={sorted(expected.keys()-actual)} extra={sorted(actual-expected.keys())}', file=sys.stderr)
    raise SystemExit(1)
for name, digest in expected.items():
    path = root / name
    if path.is_symlink() or sha256(path.read_bytes()).hexdigest() != digest:
        print(f'source hash mismatch: {name}', file=sys.stderr)
        raise SystemExit(1)
print('Pinned AndroidX camera-core 1.6.1 source files verified: 4')
PY

check_sha() {
  local path=$1 expected=$2 actual
  [[ -f "$path" ]] || fail "missing pinned input: $path"
  actual=$(shasum -a 256 "$path" | cut -d ' ' -f 1)
  [[ "$actual" == "$expected" ]] || fail "hash mismatch: $path ($actual)"
  printf '%s %s\n' "$actual" "$path"
}

check_sha "$project/CMakeLists.txt" 2536d47221effa300e9b3f522228be355e358c23a82043529a6daff46a08afd3

sdk=${CAMERA_ANDROID_SDK_ROOT:-$(sed -n 's/^sdk.dir=//p' "$repo/android/local.properties")}
[[ -n "$sdk" && -d "$sdk" ]] || fail 'SDK path missing or not a directory'
sdk=$(realpath "$sdk")
ndk="$sdk/ndk/28.2.13676358"
[[ -f "$ndk/source.properties" ]] || fail "SDK missing pinned NDK: $ndk"
grep -Eq '^Pkg.Revision = 28\.2\.13676358$' "$ndk/source.properties" || fail 'NDK version mismatch'
check_sha "$ndk/build/cmake/android.toolchain.cmake" dbad92d9dcfea0d32b7c5e5f82f5072d878ded5d46a5d3f1f581ea108ca7fe89
check_sha "$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang++" df85444b66234bf4cae267e22bde45ea8fef596d30ca2991b2091a27e6ea7718
check_sha "$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/ld.lld" 295bc36e1b10be0137f09904b7cc928a11ab3d44a8ec8250e4087ebd71f091c2
strip="$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip"
check_sha "$strip" 438848c3cb13a8fa7607507779465f3e3426637eb2e9c605cde44e49c8539f1f
cmake="$sdk/cmake/3.22.1/bin/cmake"
ninja="$sdk/cmake/3.22.1/bin/ninja"
check_sha "$cmake" e46c7ffb232c25a43e130509368dd6b88f492f110ab6b44c69c639ac1ed8c8f6
check_sha "$ninja" 5b861a9e1e062ad8e01a1370f5909b36c086774899b4ac2029192744352404d0
printf 'Android API=23 STL=c++_static SDK=%s NDK=28.2.13676358\n' "$sdk"
printf 'Pinned Camera surface source and tools verified.\n'
[[ "$mode" == --preflight ]] && exit 0

[[ "$(realpath "$source_dir")" == "$(realpath "$default_source")" ]] ||
  fail '--build uses only the tracked pinned source directory'
[[ ! -e "$out_dir" ]] || fail "output already exists: $out_dir"

# NDK CMake selects its compiler for each ABI. Ignore inherited compiler and
# link selectors that could change the standalone final link.
unset CC CXX CFLAGS CXXFLAGS CPPFLAGS LDFLAGS CMAKE_TOOLCHAIN_FILE CMAKE_GENERATOR
unset CPATH CPLUS_INCLUDE_PATH C_INCLUDE_PATH LIBRARY_PATH
unset ANDROID_NDK_HOME ANDROID_NDK_ROOT
mkdir -p "$out_dir/jni"
for abi in armeabi-v7a arm64-v8a x86 x86_64; do
  build_dir="$out_dir/build-$abi"
  "$cmake" -S "$project" -B "$build_dir" -G Ninja \
    "-DCMAKE_MAKE_PROGRAM=$ninja" \
    "-DCMAKE_TOOLCHAIN_FILE=$ndk/build/cmake/android.toolchain.cmake" \
    "-DANDROID_ABI=$abi" \
    -DANDROID_PLATFORM=android-23 \
    -DANDROID_STL=c++_static \
    -DCMAKE_BUILD_TYPE=Release \
    > "$out_dir/configure-$abi.log" 2>&1
  "$cmake" --build "$build_dir" --target surface_util_jni --verbose \
    > "$out_dir/build-$abi.log" 2>&1
  so="$build_dir/libsurface_util_jni.so"
  [[ -f "$so" ]] || fail "missing $abi output"
  mkdir -p "$out_dir/jni/$abi"
  cp "$so" "$out_dir/jni/$abi/libsurface_util_jni.so"
  "$strip" --strip-unneeded "$out_dir/jni/$abi/libsurface_util_jni.so"
  shasum -a 256 "$out_dir/jni/$abi/libsurface_util_jni.so"
done
