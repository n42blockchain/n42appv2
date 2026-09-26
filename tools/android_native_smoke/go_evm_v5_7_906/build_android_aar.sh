#!/bin/bash
set -euo pipefail

recipe_dir=$(cd "$(dirname "$0")" && pwd)
go_bin=/Users/jieliu/.codex/toolchains/go-1.26.8/go/bin/go
if [ "$#" -ne 6 ]; then
  echo "usage: $0 PREPARED_SOURCE VERIFIED_GO_MODCACHE PINNED_TOOL_BIN ANDROID_SDK JDK21 NEW_RUN_DIRECTORY" >&2
  exit 2
fi
source_dir=$(cd "$1" && pwd)
modcache=$(cd "$2" && pwd)
tool_bin=$(cd "$3" && pwd)
android_sdk=$(cd "$4" && pwd)
jdk=$(cd "$5" && pwd)
run_dir=$6
if [ -e "$run_dir" ]; then
  echo "refusing to replace existing run directory: $run_dir" >&2
  exit 3
fi

check_hash() {
  local file=$1 expected=$2 actual
  if [ ! -f "$file" ] || ! actual=$(shasum -a 256 "$file" | awk '{print $1}') ||
     [ "$actual" != "$expected" ]; then
    echo "missing or changed input: $file" >&2
    exit 4
  fi
}
check_hash "$go_bin" 2ebc27dd4e38e9b86a9f41df0307785f4f7e2997e4be761a7b4af04b41a0de57
check_hash "$tool_bin/gomobile" fbc873fa18751c39c7bdef9eb73abffbcfe321527129fbb980f71bb77de92b43
check_hash "$tool_bin/gobind" 7f4343e4acc6767ab73d8f580d24125533b432fd8494868f5649dc01761bae30
check_hash "$source_dir/go.mod" 4639b00890c7a3a4f74760f7d94241cb093eb3e9bc06df7161b238cc99b8dd02
check_hash "$source_dir/go.sum" 0cddda5969568083ac76e023426edb81107ae6ad598587867786a52b7a56d599
check_hash "$recipe_dir/android/generated/go.mod.template" 9ad07b22d3153642defe0f1fc4b8be25854f07931832e48876d686eaf6a00cf4
check_hash "$recipe_dir/android/generated/go.sum" f3d9b4bb3a72b0e241e8f90700e72fe6368e44df1a4b6ca4b2ab92cd825311ec
if [ ! -x "$android_sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang" ] ||
   [ ! -x "$jdk/bin/javac" ]; then
  echo "Android NDK28.2 or JDK is missing" >&2
  exit 5
fi
if [ "$("$go_bin" version)" != 'go version go1.26.8 darwin/arm64' ]; then
  echo "unexpected Go toolchain" >&2
  exit 5
fi
if ! "$jdk/bin/java" -version 2>&1 | head -1 | grep -q '"21\.'; then
  echo "expected JDK21" >&2
  exit 5
fi

mkdir -p "$run_dir"
run_dir=$(cd "$run_dir" && pwd)
export JAVA_HOME=$jdk ANDROID_HOME=$android_sdk ANDROID_SDK_ROOT=$android_sdk
export GOTOOLCHAIN=local GOFLAGS=-buildvcs=false GOPROXY=off GOSUMDB=off
export GOMODCACHE=$modcache GOCACHE="$run_dir/gocache" GOPATH="$run_dir/gopath" GOBIN=$tool_bin
export CGO_CFLAGS=-D__BLST_PORTABLE__
export CGO_LDFLAGS='-Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384'
export PATH="$tool_bin:$(dirname "$go_bin"):$jdk/bin:$PATH"

echo "utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$run_dir/inputs.txt"
echo "source_dir=$source_dir" >> "$run_dir/inputs.txt"
echo "source_go_mod_sha256=4639b00890c7a3a4f74760f7d94241cb093eb3e9bc06df7161b238cc99b8dd02" >> "$run_dir/inputs.txt"
echo "source_go_sum_sha256=0cddda5969568083ac76e023426edb81107ae6ad598587867786a52b7a56d599" >> "$run_dir/inputs.txt"
echo "gomobile_sha256=fbc873fa18751c39c7bdef9eb73abffbcfe321527129fbb980f71bb77de92b43" >> "$run_dir/inputs.txt"
echo "gobind_sha256=7f4343e4acc6767ab73d8f580d24125533b432fd8494868f5649dc01761bae30" >> "$run_dir/inputs.txt"
echo "offline=GOPROXY=off GOSUMDB=off" >> "$run_dir/inputs.txt"
echo "target=android/arm,android/arm64,android/amd64 api=26 tags=nosqlite,noboltdb" >> "$run_dir/inputs.txt"

python3 - "$recipe_dir/android/generated/go.mod.template" "$recipe_dir/android/generated/go.sum" "$source_dir" "$run_dir" <<'PY'
from pathlib import Path
import sys
template, sum_path, source, run_dir = map(Path, sys.argv[1:])
graph = run_dir / 'generated-preflight'
graph.mkdir()
raw = template.read_text()
if raw.count('@SOURCE@') != 3:
    raise SystemExit('unexpected generated graph source replacement count')
(graph / 'go.mod').write_text(raw.replace('@SOURCE@', str(source)))
(graph / 'go.sum').write_bytes(sum_path.read_bytes())
PY

if ! (cd "$source_dir" && "$go_bin" list -m -json all > "$run_dir/source-modules.json" 2> "$run_dir/source-modules.err") ||
   ! (cd "$run_dir/generated-preflight" && "$go_bin" list -m -json all > "$run_dir/generated-modules.json" 2> "$run_dir/generated-modules.err") ||
   ! (cd "$source_dir" && "$go_bin" mod verify > "$run_dir/go-mod-verify.log" 2>&1); then
  echo "offline source/generated module graph preflight failed; see run logs" >&2
  exit 6
fi

echo 'gomobile bind -v -work -target=android/arm,android/arm64,android/amd64 -androidapi=26 -tags=nosqlite,noboltdb -trimpath -ldflags=-s,-w ./cmd/evmsdk/mobilebind' >> "$run_dir/inputs.txt"
if ! (cd "$source_dir" && "$tool_bin/gomobile" bind -v -work \
  -target=android/arm,android/arm64,android/amd64 -androidapi=26 \
  -tags=nosqlite,noboltdb -trimpath -ldflags='-s -w' \
  -o "$run_dir/evm.aar" ./cmd/evmsdk/mobilebind > "$run_dir/gomobile.log" 2>&1); then
  echo "gomobile build failed; see $run_dir/gomobile.log" >&2
  exit 7
fi

work_dir=$(sed -n 's/^WORK=//p' "$run_dir/gomobile.log" | tail -1)
if [ -z "$work_dir" ] || [ ! -d "$work_dir" ]; then
  echo "gomobile did not retain its generated graph" >&2
  exit 8
fi
python3 - "$work_dir" "$source_dir" "$recipe_dir/android/generated" "$run_dir" <<'PY'
from pathlib import Path
import sys
work, source, expected, run = map(Path, sys.argv[1:])
want_mod = (expected / 'go.mod.template').read_text()
want_sum = (expected / 'go.sum').read_bytes()
for abi in ('arm', 'arm64', 'amd64'):
    graph = work / ('src-android-' + abi)
    mod = (graph / 'go.mod').read_text().replace(str(source), '@SOURCE@')
    if mod != want_mod or (graph / 'go.sum').read_bytes() != want_sum:
        raise SystemExit(f'generated {abi} module graph changed')
    (run / f'generated-{abi}.go.mod.normalized').write_text(mod)
    (run / f'generated-{abi}.go.sum').write_bytes(want_sum)
print('generated_graphs=arm,arm64,amd64 exact')
PY
shasum -a 256 "$run_dir/evm.aar" >> "$run_dir/inputs.txt"
echo "gomobile_work=$work_dir" >> "$run_dir/inputs.txt"
echo "aar=$run_dir/evm.aar"
