# Task 16E iOS device archive and host link

The app selects a maintained Apple MobileSdk build from the N42
`mobile-sdk-v0.2.2` release commit `2099ec735a658ba1db97c49b77a6c58c1fc82920`.
Its base, five portable patches and repaired lock are fixed by the tracked
Android recipe; `tools/apple_native_smoke/mobile_sdk_v0_2_2/apple-source.patch`
adds the Apple C ABI repairs and `staticlib`. `prepare_source.sh` in that same
directory replays the complete source from immutable upstream tags and pinned
crate archives. See the adjacent `source-group` for its source hash manifest,
header, host C ABI transaction comparison and RED/GREEN tests.

## Selected output and toolchain

The selected device archive is
`ios/MobileSdk.xcframework/ios-arm64/libmobile_sdk.a`, SHA-256
`7c6a01c9ab98651115c4b00c14bbc9fdf4ded656e91106b4b6d24b73318c82c6`,
100,607,320 bytes (95.95 MiB). It was built with Rust 1.97.1, Xcode 27.0
(27A266a), iPhoneOS SDK 27.0, deployment target 16.0, `--release --locked
--offline --target aarch64-apple-ios`, and `CARGO_PROFILE_RELEASE_LTO=false`.
All other release profile settings came from the frozen Cargo manifest:
optimization 3, panic unwind, 16 codegen units, `strip = "symbols"`. The
compiler, libclang, lock and source hashes are in `device-build-inputs.txt`;
the pinned follow-up recipe is `build_device.sh` in the tracked tool directory.
No Apple post-build stripping was applied to the selected archive.

`selected-archive-audit.json` inspected all 4,502 Mach-O objects: all are iOS
arm64, 390 carry minimum OS 10.0 from prebuilt Rust objects and 4,112 carry
16.0; none requires more than the app's iOS 16 floor. The independently linked
iOS probe resolved all seven C exports without executing them, and its linked
binary reports iOS 16.0 / SDK 27.0. The generated device and retained simulator
headers both have SHA-256 `af3e0ed0...`, identical to `ios/include/mobile_sdk.h`.
The simulator stub remains byte-identical at SHA-256 `50b29a083a1f1a4e348892e2d12e61692a6da20f71394381124392540d61819f`;
it is still a mock and is not device runtime evidence.

The formal `flutter build ios --release --no-codesign --no-pub` completed with
exit 0 (`flutter-ios-release-first.*`). A second no-signing Xcode Release build
with `LD_GENERATE_MAP_FILE=YES` completed with exit 0
(`xcodebuild-link-map-final.*`). Its Runner link map is retained as
`Runner-LinkMap-normal-arm64.txt.gz` (raw SHA-256 in
`link-map-hashes.sha256`). `link-map-selected-excerpt.txt` shows all seven C
exports and the selected archive. The exact selected build intermediate
`build/ios/Release-iphoneos/libmobile_sdk.a` hashes identically to the tracked
archive; the map contains no reference to the obsolete Downloads path in the
Xcode project's file-reference group. The final `Runner` executable is arm64,
iOS 16.0 / SDK 27.0, SHA-256 `91a7592a8d89a82d96ff66ba0fc661ae546918d534ad8adf0da2e78e5050de28`.
The built app is unsigned as requested; `runner-final-codesign.log` records the
expected absence of a signature. `privacy-manifest-inventory.txt` lists 66
bundled privacy manifests. `final-artifacts.txt` records sizes and hashes.

## Rebuild check and failed attempts

The pinned `build_device.sh` was independently run to completion with the same
prepared source and lock (`replay-*`, `build-replay-driver.*`): generated header,
4,502-object platform audit and all-seven-export device link passed. Its
archive is 100,607,280 bytes, SHA-256 `b743de9846c72218427a395de2d2e07c5ace3df92d8bc2cdb94dc37fa180a28e`.
This is a successful source/ABI rebuild but **not a byte-identical reproduction**
of the selected artifact. `replay-member-comparison.txt` finds differences in
four `reth_node_core` objects, one `mdbx.o` and the archive symbol table; the
other 4,497 ar members are byte-identical. The recipe explicitly sets CXX,
linker and `DEVELOPER_DIR` and uses a new target directory; no cause for the
40-byte size difference is asserted. The app link map binds the selected
`7c6a...` artifact, not the replay artifact.

The original release-LTO build succeeded but emitted a 261 MiB archive with
embedded LLVM bitcode (`device-build-first.*`, `device-raw-archive-audit.*`).
`strip -S -x` and `strip -S` reduced that archive but actual iOS links failed
with 406 duplicate Rust symbols (`ios-link-stripped` and `ios-link-no-debug`
logs). `strip -S` also failed an actual link on the no-LTO archive
(`ios-link-no-lto-stripS` logs). These are rejected tool transformations, not
source compiler failures. `bitcode_strip -r` failed as a tool invocation and
was not selected. The first raw all-seven probe linked but its verifier
misread a binary-encoded link map as UTF-8; the fixed probe passed. The first
app map command assigned one output path to Runner and N42Extension, causing
Xcode's duplicate-output error; the per-target default map build passed.
All failed transcripts remain in this directory.

## Dependency and evidence boundaries

The final iOS arm64 normal graph has 600 package/version pairs; normal plus
actual build dependencies has 630 (30 build-only). The offline whole-lock
audit reported 9 vulnerabilities and 4 unsound warnings; the selected
normal+build graph intersects neither set. It still selects seven unmaintained
package warnings and yanked `core2` 0.4.0. See `ios-arm64-advisory-scope.json`,
the raw tree/audit files and `ios-arm64-license-inventory.json`; the latter has
630 selected package declarations and one absent declaration in local
`merkle_db_rs` (the supplier source root has the MIT license retained here).
These are source and build-graph findings, not a scan of the old binary or a
license conclusion for the combined app.

No physical iOS device was used. Neither this link nor the macOS host fixture
establishes old/new iOS device runtime parity, valid block verification,
production TLS transport, validator scheduling or reward attribution. The
valid `run_client_c` path was never invoked. `files.sha256` binds every retained
file in this directory; gzip members can be checked with `gzip -t` and the raw
map SHA after decompression.
