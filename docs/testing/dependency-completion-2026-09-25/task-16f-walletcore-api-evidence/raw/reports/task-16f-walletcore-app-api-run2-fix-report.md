# Wallet Core API runtime attempt 2 and API 26 log buffer fix

Attempt 2 at reviewed source HEAD `8242168c47d89326db681bfbb71f951df0efa3ff` exited **1** and remains unchanged in `task-16f-walletcore-api-fixture/runtime-run2/`. It is not a two-device PASS. The exact build3 APK/native/source input epoch was not rebuilt.

Both host/AVD ownership checks passed before action. `emulator-5560` again ran the strict 16 KB synthetic JNI case set in PID **22115**, recording tagged P2PKH and unsupported app-shaped P2WSH as `PASS`. On `emulator-5562`, the corrected direct `/proc/1/smaps` probe proved SDK 26, ARM64, **4 KB Kernel and MMU pages** and offline state. APK install and app-data clear succeeded; `pm path` and pulled APK SHA-256 matched pinned build3 `f3f627565b70b42787f15bce7cf1c8024a6c4696b916a289e196a96d6526b855`.

API 26 then stopped **before app launch/JNI** because unqualified `adb -s emulator-5562 logcat -c` exited 1 with `failed to clear the 'main' log`. A bounded diagnostic using the same serial showed `adb ... logcat -c -b main` exited 0, and direct `logcat -d -b main -v threadtime -s N42_WC_API_FIXTURE:I` exited 0. The separate `adb shell id` read reported root, but no root-mode change was made.

The minimal source fix specifies the `main` log buffer for both clear and read in the runner and pins that exact argv in replay. The synthetic fixture's `Log.i` records reside in the main buffer. A negative control rejects the old unqualified clear command. Normal and optimized no-device gate tests each passed **6/6**; the earlier source, page/ownership, installed APK and native gates remain in place. A separately recorded third run waits for review of this source fix. Attempt 1's API 26 preinstall failure remains preserved.
