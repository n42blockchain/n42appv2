#!/bin/bash
set -euo pipefail

recipe_dir=$(cd "$(dirname "$0")" && pwd)
go_bin=/Users/jieliu/.codex/toolchains/go-1.26.8/go/bin/go
if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
  echo "usage: $0 PREPARED_SOURCE TASK_GO_MODCACHE NEW_PREFETCH_DIRECTORY [--check-environment]" >&2
  exit 2
fi
check_mode=${4:-}
if [ -n "$check_mode" ] && [ "$check_mode" != --check-environment ]; then
  echo "unsupported prefetch mode: $check_mode" >&2
  exit 2
fi
source_dir=$(cd "$1" && pwd)
modcache=$2
prefetch_dir=$3
if [ -e "$prefetch_dir" ]; then
  echo "refusing to replace existing prefetch directory: $prefetch_dir" >&2
  exit 3
fi
if [ "$(shasum -a 256 "$go_bin" | awk '{print $1}')" != 2ebc27dd4e38e9b86a9f41df0307785f4f7e2997e4be761a7b4af04b41a0de57 ] ||
   [ "$(shasum -a 256 "$source_dir/go.mod" | awk '{print $1}')" != 1a98bf2ee961c11b4e77cc8a6ff3026bfdcdf950ab14270af402d6889ebfec1b ] ||
   [ "$(shasum -a 256 "$source_dir/go.sum" | awk '{print $1}')" != 6dedcc331228891ee79297521297697020263b3710f59f9b0c775ab3cec3b7b0 ]; then
  echo "unreviewed Go/source input" >&2
  exit 4
fi
if [ "$(shasum -a 256 "$recipe_dir/android/generated/go.mod.template" | awk '{print $1}')" != 73f3d67e6bb00113eb59353d376ac90d7194b9c930453ddba1a1d4459068a57e ] ||
   [ "$(shasum -a 256 "$recipe_dir/android/generated/go.sum" | awk '{print $1}')" != 2ae35fbba78a593eda6ef02a49b02e4eb1b39841a9150a81d8a0de07b33ac424 ]; then
  echo "unreviewed generated graph template" >&2
  exit 4
fi
if [ "${N42_ALLOW_PUBLIC_MODULE_FETCH:-}" != yes ]; then
  echo "set N42_ALLOW_PUBLIC_MODULE_FETCH=yes for public proxy/sumdb fetch" >&2
  exit 5
fi
mkdir -p "$prefetch_dir" "$modcache"
prefetch_dir=$(cd "$prefetch_dir" && pwd)
modcache=$(cd "$modcache" && pwd)
python3 - "$recipe_dir/android/generated/go.mod.template" "$recipe_dir/android/generated/go.sum" "$source_dir" "$prefetch_dir" <<'PY'
from pathlib import Path
import sys
template, sum_path, source, target = map(Path, sys.argv[1:])
graph = target / 'generated-graph'
graph.mkdir()
raw = template.read_text()
if raw.count('@SOURCE@') != 3:
    raise SystemExit('unexpected generated source replacement count')
(graph / 'go.mod').write_text(raw.replace('@SOURCE@', str(source)))
(graph / 'go.sum').write_bytes(sum_path.read_bytes())
PY
export GOENV=off GOTOOLCHAIN=local GOFLAGS=-buildvcs=false GOWORK=off
export GOPRIVATE= GONOPROXY= GONOSUMDB= GOINSECURE= GOVCS='*:off'
export GOPROXY=https://proxy.golang.org GOSUMDB=sum.golang.org GOMODCACHE=$modcache
export GOCACHE="$prefetch_dir/gocache" GOPATH="$prefetch_dir/gopath"
"$go_bin" env -json GOENV GOWORK GOPROXY GOSUMDB GOPRIVATE GONOPROXY GONOSUMDB GOINSECURE GOVCS > "$prefetch_dir/go-env.json"
echo "goenv_export=$GOENV" > "$prefetch_dir/inputs.txt"
if [ "$check_mode" = --check-environment ]; then
  echo "environment_only=PASS prefetch_dir=$prefetch_dir"
  exit 0
fi
if ! (cd "$source_dir" && "$go_bin" mod download all > "$prefetch_dir/source-download.log" 2>&1) ||
   ! (cd "$prefetch_dir/generated-graph" && "$go_bin" mod download all > "$prefetch_dir/generated-download.log" 2>&1); then
  echo "public module fetch failed; see separate graph logs" >&2
  exit 6
fi
if [ "$(shasum -a 256 "$source_dir/go.sum" | awk '{print $1}')" != 6dedcc331228891ee79297521297697020263b3710f59f9b0c775ab3cec3b7b0 ]; then
  echo "source module sum changed during fetch" >&2
  exit 7
fi
if ! python3 - "$recipe_dir/android/generated/go.sum" "$prefetch_dir/generated-graph/go.sum" <<'PY'
from pathlib import Path
import sys
expected, fetched = (Path(value) for value in sys.argv[1:])
want = set(expected.read_text().splitlines())
have = set(fetched.read_text().splitlines())
if not want <= have:
    raise SystemExit('generated graph checksum changed or disappeared')
PY
then
  exit 7
fi
shasum -a 256 "$prefetch_dir/generated-graph/go.sum" > "$prefetch_dir/expanded-generated-sum.sha256"
export GOPROXY=off GOSUMDB=off
if ! (cd "$source_dir" && "$go_bin" list -m -json all > "$prefetch_dir/source-modules.json" 2> "$prefetch_dir/source-modules.err") ||
   ! (cd "$prefetch_dir/generated-graph" && "$go_bin" list -m -json all > "$prefetch_dir/generated-modules.json" 2> "$prefetch_dir/generated-modules.err"); then
  echo "offline graph preflight failed; see separate graph logs" >&2
  exit 8
fi
echo "source_and_generated_graphs=available_offline"
