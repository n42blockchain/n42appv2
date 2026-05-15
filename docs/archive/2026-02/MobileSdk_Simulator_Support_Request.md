# MobileSdk iOS Simulator Support Request

## Current Status

The `MobileSdk.xcframework` currently only supports **iOS arm64 (physical devices)**. To enable development and testing on iOS Simulator, we need a version that includes simulator architectures.

## Required Architectures

Please build the xcframework with the following architectures:

| Platform | Architecture | Purpose |
|----------|-------------|---------|
| `ios-arm64` | arm64 | Physical iOS devices (iPhone/iPad) |
| `ios-arm64-simulator` | arm64 | Apple Silicon Mac simulators (M1/M2/M3) |
| `ios-arm64_x86_64-simulator` | arm64 + x86_64 | Universal simulator (Intel + Apple Silicon) |

**Recommended**: Build with `ios-arm64_x86_64-simulator` to support both Intel and Apple Silicon Macs.

## Technical Specifications

### Current C API (from `mobile_sdk.h`)

```c
#ifndef MOBILE_SDK_H
#define MOBILE_SDK_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

// Memory management
void rust_free_string(char *s);

// Client operations
int32_t run_client_c(const char *ws_url, const char *validator_private_key, char **out_error);

// Block verification
char *gen_block_verify_result_c(const char *block,
                                const char *validator_private_key,
                                char **out_error);

// BLS key generation
char *generate_bls12_381_keypair_c(char **out_error);

// Deposit transaction
char *create_deposit_unsigned_tx_c(const char *deposit_contract_address,
                                   const char *validator_private_key,
                                   const char *withdrawal_address,
                                   const char *deposit_value_in_wei,
                                   char **out_error);

// Exit fee query
char *create_get_exit_fee_unsigned_tx_c(char **out_error);

// Exit transaction
char *create_exit_unsigned_tx_c(const char *validator_public_key,
                                const char *fee_in_wei_or_empty,
                                char **out_error);

#endif  /* MOBILE_SDK_H */
```

### Build Instructions for Rust Library

If the SDK is built from Rust, here are the typical build commands:

```bash
# 1. Add required targets
rustup target add aarch64-apple-ios              # iOS arm64 (device)
rustup target add aarch64-apple-ios-sim          # iOS arm64 simulator
rustup target add x86_64-apple-ios               # iOS x86_64 simulator

# 2. Build for each target
cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target x86_64-apple-ios

# 3. Create fat library for simulator (combining arm64 and x86_64)
lipo -create \
  target/aarch64-apple-ios-sim/release/libmobile_sdk.a \
  target/x86_64-apple-ios/release/libmobile_sdk.a \
  -output target/ios-simulator/libmobile_sdk.a

# 4. Create xcframework
xcodebuild -create-xcframework \
  -library target/aarch64-apple-ios/release/libmobile_sdk.a \
  -headers include/ \
  -library target/ios-simulator/libmobile_sdk.a \
  -headers include/ \
  -output MobileSdk.xcframework
```

### Expected xcframework Structure

```
MobileSdk.xcframework/
├── Info.plist
├── ios-arm64/
│   ├── Headers/
│   │   └── mobile_sdk.h
│   └── libmobile_sdk.a
└── ios-arm64_x86_64-simulator/
    ├── Headers/
    │   └── mobile_sdk.h
    └── libmobile_sdk.a
```

### Expected Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <!-- iOS Device -->
        <dict>
            <key>BinaryPath</key>
            <string>libmobile_sdk.a</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>LibraryIdentifier</key>
            <string>ios-arm64</string>
            <key>LibraryPath</key>
            <string>libmobile_sdk.a</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
        <!-- iOS Simulator (Universal) -->
        <dict>
            <key>BinaryPath</key>
            <string>libmobile_sdk.a</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>LibraryIdentifier</key>
            <string>ios-arm64_x86_64-simulator</string>
            <key>LibraryPath</key>
            <string>libmobile_sdk.a</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
                <string>x86_64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
```

## Alternative: Cargo Configuration

If using `cargo-lipo` or similar tools, ensure `.cargo/config.toml` includes:

```toml
[target.aarch64-apple-ios]
linker = "rust-lld"

[target.aarch64-apple-ios-sim]
linker = "rust-lld"

[target.x86_64-apple-ios]
linker = "rust-lld"
```

## Testing the xcframework

After building, verify the architectures:

```bash
# Check device library
lipo -info MobileSdk.xcframework/ios-arm64/libmobile_sdk.a
# Expected: Architectures in the fat file: arm64

# Check simulator library
lipo -info MobileSdk.xcframework/ios-arm64_x86_64-simulator/libmobile_sdk.a
# Expected: Architectures in the fat file: arm64 x86_64
```

## Integration Notes

- The xcframework should be dropped into `ios/` directory
- No changes needed to the Swift wrapper (`MobileSdk.swift`)
- No changes needed to the bridging header
- Flutter build commands will automatically select the correct architecture

## Contact

For questions about integration, please contact the n42appv2 development team.
