# Apple SDK device recipe preflight fix

This group fixes the two recipe findings in `task-16e-device-review.md` after
the selected device archive was already built. It does **not** rebuild or
relabel that archive (`7c6a01c9ab98651115c4b00c14bbc9fdf4ded656e91106b4b6d24b73318c82c6`).

`build_device.sh` now pins the prepared workspace `Cargo.toml` SHA-256
`9c2ce43e9a4e230e83fcdaa78d063ef1e51eeb9c8621c73c20f712ede92f4bbd`.
That manifest defines the frozen release profile. The script rejects inherited
native compiler selectors, C/C++/archiver flags, include/search paths, target
linker overrides, CMake selectors and bindgen extra clang flags before it
creates an output directory. It then exports the reviewed Xcode clang, clang++,
ar, libclang, deployment floor and Rust target linker/flags. Future full runs
write these effective inputs and the root manifest hash to `inputs.txt`.

`--preflight` runs the same source/tool/environment gates and prints the
effective compiler inputs without Cargo, C compilation or output creation.
The focused regression command was:

```sh
/bin/bash tools/apple_native_smoke/mobile_sdk_v0_2_2/test_device_preflight.sh \
  .superpowers/sdd/dependency-completion-20260925/apple-sdk-rebuild/recipe-proof-2/source \
  .superpowers/sdd/dependency-completion-20260925/apple-sdk-rebuild/tools/bin/cbindgen \
  .superpowers/sdd/dependency-completion-20260925/apple-sdk-rebuild/preflight-green-3
```

It exited 0: one clean preflight and **22** rejected inputs before build.
The source mutation changes actual root `[profile.release] opt-level` from 3
to 0 while leaving the lock, member manifest and C FFI file unchanged; its
exact diff is `root-profile-mutation.patch`. Each `logs/*.log` records the
specific rejection. No `*-build` directory was created; only the test's
task-owned log directory and copied source fixture were made. The checked
source was an independent task-owned supplier checkout, not a sibling repo.

`red-missing-preflight.log` is the initial expected failure because the old
script did not accept `--preflight`; it is **not** a behavioral race or root
hash regression. `intermediate-harness-failure.log` records a test assertion
mistake: it expected the whole root mismatch line to equal only its prefix.
`intermediate-root-profile.log` confirms the recipe did reject the mutated
manifest; the corrected harness produced `summary.log` and the final logs.

The locked `cc` 1.2.15 checks a hyphenated target selector before its
underscored form and accumulates flags from global, build-kind and target
variables. `bindgen` 0.70.1 also reads target-specific
`BINDGEN_EXTRA_CLANG_ARGS`. `prior-replay-zstd-sys-output.txt` is a retained
build-script transcript from the earlier full recipe replay: for that one
native dependency, it reports hyphenated CC/AR and CFLAGS variants absent and
the underscored Xcode clang/ar selected. It does not establish every effective
input in the selected manual build, and the new guard was not present then.

The selected and replay archives still differ by 40 bytes. The retained
Reth/MDBX objects show embedded build timestamps, but the available evidence
does not prove that timestamps explain every changed byte. No new archive,
device app, simulator runtime, physical iOS run or signing result is claimed
by this guard fix.

Run `shasum -a 256 -c files.sha256` from this directory to verify the archived
logs and inputs.
