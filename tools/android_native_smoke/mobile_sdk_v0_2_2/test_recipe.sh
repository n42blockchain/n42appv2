#!/usr/bin/env bash
set -euo pipefail

N42_RECIPE_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ $# -ne 2 ]]; then
  echo "usage: $0 ALIGNED_AAR UNALIGNED_AAR" >&2
  exit 2
fi

# Both Cargo global spellings must be absent from the actual sourced build environment.
RUSTFLAGS='-C link-arg=-Wl,-z,common-page-size=4096' \
CARGO_ENCODED_RUSTFLAGS='-C\x1flink-arg=-Wl,-z,max-page-size=4096' \
N42_RECIPE_DIR="$N42_RECIPE_DIR" bash -c '
  set -euo pipefail
  source "$N42_RECIPE_DIR/build_flags.sh"
  if [[ ${RUSTFLAGS+x} || ${CARGO_ENCODED_RUSTFLAGS+x} ]]; then exit 1; fi
  if [[ "$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS" != *"max-page-size=16384"* ]]; then exit 1; fi
  if [[ "$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS" != *"common-page-size=16384"* ]]; then exit 1; fi
  if [[ "$CARGO_TARGET_X86_64_LINUX_ANDROID_RUSTFLAGS" != "$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS" ]]; then exit 1; fi
'

# Input provenance must reject the maintained AAR before making a work directory.
N42_PROBE_ROOT="$(mktemp -d)"
N42_PROBE_WORKDIR="$N42_PROBE_ROOT/not-created"
if "$N42_RECIPE_DIR/rebuild.sh" > /dev/null 2> "$N42_PROBE_ROOT/rejection.log"; then
  echo "missing arguments unexpectedly accepted" >&2
  exit 1
fi
rg -q '^usage:' "$N42_PROBE_ROOT/rejection.log"
if "$N42_RECIPE_DIR/rebuild.sh" "$N42_PROBE_WORKDIR" "$1" "$N42_RECIPE_DIR" "$N42_RECIPE_DIR" > /dev/null 2> "$N42_PROBE_ROOT/rejection.log"; then
  echo "incorrect official AAR unexpectedly accepted" >&2
  exit 1
fi
rg -q 'Official AAR SHA-256 mismatch' "$N42_PROBE_ROOT/rejection.log"
if [[ -e "$N42_PROBE_WORKDIR" ]]; then
  echo "source work directory was created before input validation" >&2
  exit 1
fi

mkdir "$N42_PROBE_ROOT/existing"
if "$N42_RECIPE_DIR/rebuild.sh" "$N42_PROBE_ROOT/existing" "$2" "$N42_RECIPE_DIR" "$N42_RECIPE_DIR" > /dev/null 2> "$N42_PROBE_ROOT/rejection.log"; then
  echo "existing work directory unexpectedly accepted" >&2
  exit 1
fi
rg -q 'Work directory must not exist' "$N42_PROBE_ROOT/rejection.log"

mkdir "$N42_PROBE_ROOT/tool-stubs"
printf '#!/usr/bin/env bash\necho "rustc 0.0.0"\n' > "$N42_PROBE_ROOT/tool-stubs/rustc"
chmod +x "$N42_PROBE_ROOT/tool-stubs/rustc"
if PATH="$N42_PROBE_ROOT/tool-stubs:$PATH" "$N42_RECIPE_DIR/rebuild.sh" "$N42_PROBE_WORKDIR" "$2" "$N42_RECIPE_DIR" "$N42_RECIPE_DIR" > /dev/null 2> "$N42_PROBE_ROOT/rejection.log"; then
  echo "wrong Rust compiler unexpectedly accepted" >&2
  exit 1
fi
rg -q 'Rust compiler mismatch' "$N42_PROBE_ROOT/rejection.log"

rm -f "$N42_PROBE_ROOT/tool-stubs/rustc"
printf '#!/usr/bin/env bash\necho "cargo-ndk 0.0.0"\n' > "$N42_PROBE_ROOT/tool-stubs/cargo"
chmod +x "$N42_PROBE_ROOT/tool-stubs/cargo"
if PATH="$N42_PROBE_ROOT/tool-stubs:$PATH" "$N42_RECIPE_DIR/rebuild.sh" "$N42_PROBE_WORKDIR" "$2" "$N42_RECIPE_DIR" "$N42_RECIPE_DIR" > /dev/null 2> "$N42_PROBE_ROOT/rejection.log"; then
  echo "wrong cargo-ndk unexpectedly accepted" >&2
  exit 1
fi
rg -q 'cargo-ndk mismatch' "$N42_PROBE_ROOT/rejection.log"

rm -f "$N42_PROBE_ROOT/tool-stubs/cargo"
mkdir "$N42_PROBE_ROOT/ndk"
printf 'Pkg.Revision = 0.0\n' > "$N42_PROBE_ROOT/ndk/source.properties"
if "$N42_RECIPE_DIR/rebuild.sh" "$N42_PROBE_WORKDIR" "$2" "$N42_PROBE_ROOT/ndk" "$N42_RECIPE_DIR" > /dev/null 2> "$N42_PROBE_ROOT/rejection.log"; then
  echo "wrong NDK revision unexpectedly accepted" >&2
  exit 1
fi
rg -q 'NDK revision mismatch' "$N42_PROBE_ROOT/rejection.log"

rm -f "$N42_PROBE_ROOT/rejection.log"
rm -f "$N42_PROBE_ROOT/ndk/source.properties"
rmdir "$N42_PROBE_ROOT/ndk" "$N42_PROBE_ROOT/tool-stubs" "$N42_PROBE_ROOT/existing"
rmdir "$N42_PROBE_ROOT"

N42_AUDITOR="$N42_RECIPE_DIR/../../../scripts/audit_android_native.py"
python3 "$N42_AUDITOR" "$1" > /dev/null
if python3 "$N42_AUDITOR" "$2" > /dev/null; then
  echo "unaligned control unexpectedly passed" >&2
  exit 1
fi
echo 'build flags isolated; missing args, existing path, wrong AAR/tool/NDK versions rejected; ELF audit rejects unaligned control'
