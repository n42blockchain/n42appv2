#!/bin/bash
set -euo pipefail

source_commit=5083c29735acfc7023ab1fbbd6d6527b7b97cbae
expected_go_mod=cc02fd1da3063d1ebdee16e04e7ddd2e835f27c4e26164b2872719c01464a0c2
expected_go_sum=899d023d3da8b64689e51fd7a7d5e932d93878dbcf780b35e2fe85e4ddc270ca
expected_patch=8ce074b989d01fa83ecb3c5878d08140cd6d6b109ea0bb8f0ddc05618aaa617b
recipe_dir=$(cd "$(dirname "$0")" && pwd)

if [ "$#" -ne 2 ]; then
  echo "usage: $0 SOURCE_GIT_REPO NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
source_repo=$1
output_dir=$2
if [ ! -d "$source_repo/.git" ] && [ ! -f "$source_repo/.git" ]; then
  echo "source is not a Git worktree: $source_repo" >&2
  exit 3
fi
if [ -e "$output_dir" ]; then
  echo "refusing to replace existing output: $output_dir" >&2
  exit 4
fi
if ! git -C "$source_repo" cat-file -e "$source_commit^{commit}"; then
  echo "canonical source commit is missing" >&2
  exit 5
fi
patch_hash=$(shasum -a 256 "$recipe_dir/source.patch" | awk '{print $1}')
if [ "$patch_hash" != "$expected_patch" ]; then
  echo "reviewed source patch hash differs" >&2
  exit 6
fi

mkdir -p "$output_dir"
if ! git -C "$source_repo" archive --format=tar "$source_commit" | tar -xf - -C "$output_dir"; then
  echo "canonical source extraction failed" >&2
  exit 7
fi
mod_hash=$(shasum -a 256 "$output_dir/go.mod" | awk '{print $1}')
sum_hash=$(shasum -a 256 "$output_dir/go.sum" | awk '{print $1}')
if [ "$mod_hash" != "$expected_go_mod" ] || [ "$sum_hash" != "$expected_go_sum" ]; then
  echo "canonical module inputs differ" >&2
  exit 8
fi
if ! (cd "$output_dir" && patch --dry-run -p1 < "$recipe_dir/source.patch"); then
  echo "reviewed source patch cannot apply" >&2
  exit 9
fi
if ! (cd "$output_dir" && patch -p1 < "$recipe_dir/source.patch"); then
  echo "reviewed source patch failed" >&2
  exit 10
fi
echo "source_commit=$source_commit"
echo "go_mod_sha256=$mod_hash"
echo "go_sum_sha256=$sum_hash"
echo "patch_sha256=$patch_hash"
