#!/usr/bin/env bash
# Source inside the rebuild process. Cargo global flags take precedence over target flags.
unset RUSTFLAGS CARGO_ENCODED_RUSTFLAGS
export CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS='-C link-arg=-Wl,-z,max-page-size=16384 -C link-arg=-Wl,-z,common-page-size=16384'
export CARGO_TARGET_X86_64_LINUX_ANDROID_RUSTFLAGS="$CARGO_TARGET_AARCH64_LINUX_ANDROID_RUSTFLAGS"
