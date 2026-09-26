#!/bin/bash
set -euo pipefail

source_commit=5083c29735acfc7023ab1fbbd6d6527b7b97cbae
expected_go_mod=cc02fd1da3063d1ebdee16e04e7ddd2e835f27c4e26164b2872719c01464a0c2
expected_go_sum=899d023d3da8b64689e51fd7a7d5e932d93878dbcf780b35e2fe85e4ddc270ca
expected_patch=8ce074b989d01fa83ecb3c5878d08140cd6d6b109ea0bb8f0ddc05618aaa617b
expected_contract_test=1fddc806bee30c1d2697cb8a13cda893ad4c193f341307a99d186c6c48816b38
expected_mobile_emit=8212470e064305bb18a01a8cbd90412ab074a4ff395991982f6e6f349e1603d4
expected_mobile_test=cc83ebc5da0e61ce4b43c5750be2f7c868f8702600aec9acaf68314dafab39eb
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
if ! contract_test_hash=$(shasum -a 256 "$recipe_dir/protocol/emit_contract_test.go" | awk '{print $1}') ||
   ! mobile_emit_hash=$(shasum -a 256 "$recipe_dir/protocol/mobilebind/emit.go" | awk '{print $1}') ||
   ! mobile_test_hash=$(shasum -a 256 "$recipe_dir/protocol/mobilebind/emit_test.go" | awk '{print $1}'); then
  echo "could not hash mobile protocol source" >&2
  exit 11
fi
if [ "$contract_test_hash" != "$expected_contract_test" ] ||
   [ "$mobile_emit_hash" != "$expected_mobile_emit" ] ||
   [ "$mobile_test_hash" != "$expected_mobile_test" ]; then
  echo "reviewed mobile protocol source hash differs" >&2
  exit 11
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
if [ -e "$output_dir/cmd/evmsdk/emit_contract_test.go" ] ||
   [ -e "$output_dir/cmd/evmsdk/mobilebind" ]; then
  echo "canonical source unexpectedly contains mobile protocol overlay" >&2
  exit 12
fi
if ! mkdir "$output_dir/cmd/evmsdk/mobilebind" ||
   ! cp "$recipe_dir/protocol/emit_contract_test.go" "$output_dir/cmd/evmsdk/emit_contract_test.go" ||
   ! cp "$recipe_dir/protocol/mobilebind/emit.go" "$output_dir/cmd/evmsdk/mobilebind/emit.go" ||
   ! cp "$recipe_dir/protocol/mobilebind/emit_test.go" "$output_dir/cmd/evmsdk/mobilebind/emit_test.go"; then
  echo "could not install mobile protocol source" >&2
  exit 13
fi
echo "source_commit=$source_commit"
echo "go_mod_sha256=$mod_hash"
echo "go_sum_sha256=$sum_hash"
echo "patch_sha256=$patch_hash"
echo "contract_test_sha256=$contract_test_hash"
echo "mobile_emit_sha256=$mobile_emit_hash"
echo "mobile_test_sha256=$mobile_test_hash"
