# Android host integration build — 2026-11-07

Source: wallet `ffaa82233`, Chat immutable dependency `ad7ce8c41d2ad747db966ba1d8ff015f7d9230ef`. Flutter 3.47.8.

`flutter build apk --debug --no-pub` completed with exit 0; Gradle assembleDebug took 97.3 seconds. Artifact: `build/app/outputs/flutter-apk/app-debug.apk`, 791,874,607 bytes. SHA-256: `6549f3c52bc8a11ba84962197a2586df0ad8cf256da19d2a1f703549a37293ff`. This is a universal debug artifact; its size is not a release download-size measurement.

Android aapt inspection confirms package `ai.n42.www`, version `2.5.3` / `73403`, minimum SDK 26, target SDK 36, compile SDK 37. APK contains both `libn42_pq.so` and `libvodozemac_bindings_dart.so` for arm64-v8a, armeabi-v7a and x86_64. Manifest includes the n42app/n42.world and n42id callbacks plus Facebook fbconnect/cct.ai.n42.www callback. Manifest presence does not establish provider console correctness or successful login.

Observed nonfatal messages: future Flutter compatibility warning for Kotlin Gradle Plugin usage in the app and several dependencies; Facebook Windows default-plugin declaration warning. Neither prevented this Android build. Follow-up requires a coordinated built-in Kotlin migration before adopting a Flutter release that removes compatibility; do not remove native integrations to silence the warning.

No device install, provider authentication, E2EE runtime, signing on Android, release signing, Play upload or TestFlight acceptance was performed. Existing source and unrelated work were preserved.

Local build log: `/tmp/n42-android-debug-20261107.log`.
Log SHA-256: `3a4b79c42059229b06508811516e49f432cbdc376ca79a92138fc46b8150e4fa`.
