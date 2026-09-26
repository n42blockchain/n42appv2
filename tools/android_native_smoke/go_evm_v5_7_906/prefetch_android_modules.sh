#!/bin/bash
set -euo pipefail

recipe_dir=$(cd "$(dirname "$0")" && pwd)
go_bin=/Users/jieliu/.codex/toolchains/go-1.26.8/go/bin/go
if [ "$#" -ne 3 ]; then
  echo "usage: $0 PREPARED_SOURCE TASK_GO_MODCACHE NEW_PREFETCH_DIRECTORY" >&2
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
   [ "$(shasum -a 256 "$source_dir/go.mod" | awk '{print $1}')" != 4639b00890c7a3a4f74760f7d94241cb093eb3e9bc06df7161b238cc99b8dd02 ] ||
   [ "$(shasum -a 256 "$source_dir/go.sum" | awk '{print $1}')" != 0cddda5969568083ac76e023426edb81107ae6ad598587867786a52b7a56d599 ]; then
  echo "unreviewed Go/source input" >&2
  exit 4
fi
if [ "$(shasum -a 256 "$recipe_dir/android/generated/go.mod.template" | awk '{print $1}')" != 9ad07b22d3153642defe0f1fc4b8be25854f07931832e48876d686eaf6a00cf4 ] ||
   [ "$(shasum -a 256 "$recipe_dir/android/generated/go.sum" | awk '{print $1}')" != f3d9b4bb3a72b0e241e8f90700e72fe6368e44df1a4b6ca4b2ab92cd825311ec ]; then
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
export GOTOOLCHAIN=local GOFLAGS=-buildvcs=false
export GOPROXY=https://proxy.golang.org GOSUMDB=sum.golang.org GOMODCACHE=$modcache
export GOCACHE="$prefetch_dir/gocache" GOPATH="$prefetch_dir/gopath"
if ! (cd "$source_dir" && "$go_bin" mod download all > "$prefetch_dir/source-download.log" 2>&1) ||
   ! (cd "$prefetch_dir/generated-graph" && "$go_bin" mod download all > "$prefetch_dir/generated-download.log" 2>&1); then
  echo "public module fetch failed; see separate graph logs" >&2
  exit 6
fi
if [ "$(shasum -a 256 "$source_dir/go.sum" | awk '{print $1}')" != 0cddda5969568083ac76e023426edb81107ae6ad598587867786a52b7a56d599 ]; then
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
