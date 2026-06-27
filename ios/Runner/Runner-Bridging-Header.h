#import "GeneratedPluginRegistrant.h"

// MobileSdk is only available on real devices (arm64)
// On simulator, we use mock implementations in Swift
#if !TARGET_OS_SIMULATOR
#import "mobile_sdk.h"
#endif

#import "n42_mls.h"
