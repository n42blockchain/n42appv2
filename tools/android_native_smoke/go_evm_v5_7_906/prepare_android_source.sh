#!/bin/bash
set -euo pipefail

recipe_dir=$(cd "$(dirname "$0")" && pwd)
android_dir="$recipe_dir/android"
if [ "$#" -ne 3 ]; then
  echo "usage: $0 SOURCE_GIT_REPO VERIFIED_GO_MODCACHE NEW_OUTPUT_DIRECTORY" >&2
  exit 2
fi
source_repo=$1
modcache=$2
output_dir=$3
if [ -e "$output_dir" ]; then
  echo "refusing to replace existing output: $output_dir" >&2
  exit 3
fi

check_hash() {
  local file=$1 expected=$2 actual
  if [ ! -f "$file" ]; then
    echo "missing input: $file" >&2
    exit 4
  fi
  if ! actual=$(shasum -a 256 "$file" | awk '{print $1}'); then
    echo "cannot hash input: $file" >&2
    exit 4
  fi
  if [ "$actual" != "$expected" ]; then
    echo "input hash differs: $file" >&2
    exit 4
  fi
}

check_hash "$android_dir/source.patch" 453bba81aa9e5c68f40371889c818e1e33a367c0b33d51b672eefa927629d648
check_hash "$android_dir/anet.patch" 6b407c16b7331eed340da232061ba646bae9d9670c50eb8f031bd5a21e4a82c0
check_hash "$android_dir/blst.patch" 4fa2f6dd25dd8f30135a6d732acdd49fb9ee021d1dcfcc1981249a27d4c912c0
check_hash "$android_dir/tests/lib/commitment/keys_nibbles_keccak_portable_test.go" e18aa22e96f363944e55b14cbfbe217a2aaf092868c95c69ccc0d2c587641e96
check_hash "$android_dir/tests/lib/mmap/mmap_portable_test.go" b2cc21b513e8e0722e31195621486c793cd425d290460c9e702d63d9c9f96ffb
check_hash "$android_dir/tests/lib/recsplit/eliasfano16/serialization_portable_test.go" 6bbda7cf0173e1e5ad5813af1ae57a904c28d5d90caf284a287f941046cbcec3
check_hash "$android_dir/tests/lib/recsplit/golomb_portable_test.go" 45de50b794364a9be10b906aa543dd6b425cfa8291ec63f103297cc922af2b63
check_hash "$android_dir/tests/third_party/anet/zone_portable_test.go" 1fdb11332ba065e33e8d2bf561c2dee10239a79cac6e2fa4eac6d00f04e08aaf

anet_zip="$modcache/cache/download/github.com/wlynxg/anet/@v/v0.0.5.zip"
blst_zip="$modcache/cache/download/github.com/supranational/blst/@v/v0.3.17.zip"
check_hash "$anet_zip" 5d6e471ccaa553e0cac56e17f8e44499f99ca1a1e37d80d5fdb3c64d4d50d02a
check_hash "$blst_zip" 898d1f5c9ba35fd1b045bfd28bf61f55a978ad6089091109df5f43d2e47eed2b

if ! /bin/bash "$recipe_dir/prepare_source.sh" "$source_repo" "$output_dir"; then
  echo "canonical source preparation failed" >&2
  exit 5
fi
if ! (cd "$output_dir" && patch --dry-run -p1 < "$android_dir/source.patch") ||
   ! (cd "$output_dir" && patch -p1 < "$android_dir/source.patch"); then
  echo "Android source patch failed" >&2
  exit 6
fi

mkdir -p "$output_dir/third_party/anet" "$output_dir/third_party/blst"
anet_prefix=github.com/wlynxg/anet@v0.0.5
for member in LICENSE go.mod go.sum android_api_level.go android_api_level_cgo.go interface.go interface_android.go netlink_android.go; do
  if ! unzip -p "$anet_zip" "$anet_prefix/$member" > "$output_dir/third_party/anet/$member"; then
    echo "anet archive member missing: $member" >&2
    exit 7
  fi
done
blst_prefix=github.com/supranational/blst@v0.3.17
if ! unzip -q "$blst_zip" -d "$output_dir/third_party/blst" ||
   ! mv "$output_dir/third_party/blst/$blst_prefix" "$output_dir/third_party/blst/module"; then
  echo "could not extract reviewed blst module" >&2
  exit 8
fi
mv "$output_dir/third_party/blst/module" "$output_dir/third_party/blst-patched"
rmdir "$output_dir/third_party/blst/github.com/supranational" "$output_dir/third_party/blst/github.com" "$output_dir/third_party/blst"
mv "$output_dir/third_party/blst-patched" "$output_dir/third_party/blst"
if ! (cd "$output_dir/third_party/anet" && patch --dry-run -p1 < "$android_dir/anet.patch") ||
   ! (cd "$output_dir/third_party/anet" && patch -p1 < "$android_dir/anet.patch") ||
   ! (cd "$output_dir/third_party/blst" && patch --dry-run -p1 < "$android_dir/blst.patch") ||
   ! (cd "$output_dir/third_party/blst" && patch -p1 < "$android_dir/blst.patch"); then
  echo "reviewed module patch failed" >&2
  exit 9
fi

for member in lib/commitment/keys_nibbles_keccak_portable_test.go lib/mmap/mmap_portable_test.go lib/recsplit/eliasfano16/serialization_portable_test.go lib/recsplit/golomb_portable_test.go; do
  if [ -e "$output_dir/$member" ] ||
     ! cp "$android_dir/tests/$member" "$output_dir/$member"; then
    echo "could not install Android source test: $member" >&2
    exit 10
  fi
done
if [ -e "$output_dir/third_party/anet/zone_portable_test.go" ] ||
   ! cp "$android_dir/tests/third_party/anet/zone_portable_test.go" "$output_dir/third_party/anet/zone_portable_test.go"; then
  echo "could not install numeric IPv6 zone test" >&2
  exit 10
fi
check_hash "$output_dir/go.mod" 1a98bf2ee961c11b4e77cc8a6ff3026bfdcdf950ab14270af402d6889ebfec1b
check_hash "$output_dir/go.sum" 6dedcc331228891ee79297521297697020263b3710f59f9b0c775ab3cec3b7b0
echo "android_source=prepared"
echo "go_mod_sha256=1a98bf2ee961c11b4e77cc8a6ff3026bfdcdf950ab14270af402d6889ebfec1b"
echo "go_sum_sha256=6dedcc331228891ee79297521297697020263b3710f59f9b0c775ab3cec3b7b0"
echo "anet_module_zip_sha256=5d6e471ccaa553e0cac56e17f8e44499f99ca1a1e37d80d5fdb3c64d4d50d02a"
echo "blst_module_zip_sha256=898d1f5c9ba35fd1b045bfd28bf61f55a978ad6089091109df5f43d2e47eed2b"
