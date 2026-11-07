# iOS simulator integration build — 2026-11-07

Source: wallet `18ea161df`, Chat dependency `ad7ce8c41d2ad747db966ba1d8ff015f7d9230ef`. Flutter 3.47.8, Xcode 27.1 RC.

`flutter build ios --simulator --debug --no-pub` completed with exit 0. Pod install: 5.7 seconds. Xcode build: 199.3 seconds. Artifact: `build/ios/iphonesimulator/Runner.app`. Built Info.plist confirms `ai.n42.www`, `2.5.3+73404`, platform `iphonesimulator`.

No plugins were removed for this build. Artifact includes WalletCore, WalletCoreSwiftProtobuf and flutter_vodozemac frameworks. `nm -g Runner.debug.dylib` confirms linked `_n42_pq_keypair`, `_n42_pq_sign` and `_n42_pq_verify` symbols. Linkage is not runtime signing acceptance.

Pod installation synchronizes only the WalletCoreSwiftProtobuf specification checksum in Podfile.lock from 54df2ff1c711c0c10eb7f1bbc04995ee003964d1 to 63ff9e6b8c6b88468681254335a285d80f7d42fa. The repository local podspec remains unchanged at version 4.8.7, official release URL and archive SHA-256 b39fa0f3968fcdab0ab5a44c26d3e16d6f1277f5df6f7db008cdf65890204f67. No pod version or binary source changed in this task.

Nonfatal warnings identify plugins that need future Swift Package Manager adoption and Facebook's Windows default-plugin declaration. This successful simulator build does not prove physical-device signing, App Store upload, TestFlight access, real Google/Apple/Facebook login, camera/QR, calls, E2EE or push runtime acceptance.

Local log: `/tmp/n42-ios-simulator-20261107.log`.
Log SHA-256: `337a7a559090d61f32d5c09e6cc69ff2f4192ce6cce1788edbf96b08aaa7d998`.
