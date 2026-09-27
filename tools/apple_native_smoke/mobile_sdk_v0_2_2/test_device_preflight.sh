#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 PREPARED_SOURCE CBINDGEN_0_29_2 NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
N42_TEST_DIR="$3"
if [[ -e "$N42_TEST_DIR" ]]; then
  echo "Test output already exists: $N42_TEST_DIR" >&2
  exit 2
fi
mkdir -p "$N42_TEST_DIR"
N42_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
N42_RECIPE="$N42_SCRIPT_DIR/build_device.sh"

run_rejected() {
  local case_name="$1"
  shift
  local expected_error="$1"
  shift
  if "$@" > "$N42_TEST_DIR/$case_name.log" 2>&1; then
    echo "Unexpected success: $case_name" >&2
    exit 1
  fi
  if [[ -e "$N42_TEST_DIR/$case_name-build" ]]; then
    echo "Build output created during rejected preflight: $case_name" >&2
    exit 1
  fi
  if [[ "$case_name" != root-profile ]]; then
    expected_error="Unexpected inherited native build input: $expected_error"
  fi
  if ! rg -Fq "$expected_error" "$N42_TEST_DIR/$case_name.log"; then
    echo "Wrong rejection reason: $case_name" >&2
    exit 1
  fi
  echo "PASS $case_name rejected before build"
}

if ! "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/clean-build" \
  > "$N42_TEST_DIR/clean.log" 2>&1; then
  echo "Clean preflight failed" >&2
  exit 1
fi
if [[ -e "$N42_TEST_DIR/clean-build" ]]; then
  echo "Clean preflight created build output" >&2
  exit 1
fi
echo 'PASS clean preflight without build'

run_rejected hyphen-cc 'CC_aarch64-apple-ios' env 'CC_aarch64-apple-ios=/bin/false' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/hyphen-cc-build"
run_rejected underscore-cc 'CC_aarch64_apple_ios' env 'CC_aarch64_apple_ios=/bin/false' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/underscore-cc-build"
run_rejected global-cc 'CC' env CC=/bin/false \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/global-cc-build"
run_rejected host-cc 'HOST_CC' env HOST_CC=/bin/false \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/host-cc-build"
run_rejected target-cc 'TARGET_CC' env TARGET_CC=/bin/false \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/target-cc-build"
run_rejected hyphen-cxx 'CXX_aarch64-apple-ios' env 'CXX_aarch64-apple-ios=/bin/false' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/hyphen-cxx-build"
run_rejected hyphen-ar 'AR_aarch64-apple-ios' env 'AR_aarch64-apple-ios=/bin/false' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/hyphen-ar-build"
run_rejected global-ar 'AR' env AR=/bin/false \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/global-ar-build"
run_rejected global-cflags 'CFLAGS' env CFLAGS=-O0 \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/global-cflags-build"
run_rejected target-cflags 'TARGET_CFLAGS' env TARGET_CFLAGS=-O0 \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/target-cflags-build"
run_rejected host-cflags 'HOST_CFLAGS' env HOST_CFLAGS=-O0 \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/host-cflags-build"
run_rejected hyphen-cflags 'CFLAGS_aarch64-apple-ios' env 'CFLAGS_aarch64-apple-ios=-O0' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/hyphen-cflags-build"
run_rejected global-cxxflags 'CXXFLAGS' env CXXFLAGS=-O0 \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/global-cxxflags-build"
run_rejected target-cxxflags 'CXXFLAGS_aarch64_apple_ios' env 'CXXFLAGS_aarch64_apple_ios=-O0' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/target-cxxflags-build"
run_rejected arflags 'ARFLAGS' env ARFLAGS=r \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/arflags-build"
run_rejected bindgen-global 'BINDGEN_EXTRA_CLANG_ARGS' env BINDGEN_EXTRA_CLANG_ARGS=--sysroot=/tmp \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/bindgen-global-build"
run_rejected bindgen-flags 'BINDGEN_EXTRA_CLANG_ARGS_aarch64-apple-ios' \
  env 'BINDGEN_EXTRA_CLANG_ARGS_aarch64-apple-ios=--sysroot=/tmp' \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/bindgen-flags-build"
run_rejected cargo-target-linker 'CARGO_TARGET_AARCH64_APPLE_IOS_LINKER' \
  env CARGO_TARGET_AARCH64_APPLE_IOS_LINKER=/bin/false \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/cargo-target-linker-build"
run_rejected cmake-compiler 'CMAKE_C_COMPILER' env CMAKE_C_COMPILER=/bin/false \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/cmake-compiler-build"
run_rejected native-include-path 'CPATH' env CPATH=/tmp \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/native-include-path-build"
run_rejected host-deployment-target 'MACOSX_DEPLOYMENT_TARGET' env MACOSX_DEPLOYMENT_TARGET=10.0 \
  "$N42_RECIPE" --preflight "$1" "$2" "$N42_TEST_DIR/host-deployment-target-build"

cp -R "$1" "$N42_TEST_DIR/mutated-source"
python3 - "$N42_TEST_DIR/mutated-source/Cargo.toml" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
content = path.read_text()
old = "[profile.release]\nopt-level = 3\n"
assert content.count(old) == 1
path.write_text(content.replace(old, "[profile.release]\nopt-level = 0\n", 1))
PY
run_rejected root-profile 'Workspace manifest mismatch' "$N42_RECIPE" --preflight \
  "$N42_TEST_DIR/mutated-source" "$2" "$N42_TEST_DIR/root-profile-build"
