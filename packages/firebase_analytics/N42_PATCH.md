# Firebase Analytics 13.0.1 compatibility patch

Source: official pub.dev firebase_analytics 13.0.1 archive.
Archive SHA-256: `4184afc17c5749a1dc008289e582cdc07ea213d03f681f00454aed834db34357`.

Only native podspec dependency bounds and workspace metadata change. Dart/native
runtime and generated sources are copied unchanged. Example apps are omitted.

Upstream pins FirebaseAnalytics to the Firebase Core version (12.19.3), but the
CocoaPods Specs repository publishes Analytics 12.19.0 and no 12.19.3. Use the
compatible official 12.19.x Analytics release without rolling back Core 12.19.3.
Remove this override once upstream supports independently released native versions.

Official specs:
https://github.com/CocoaPods/Specs/tree/master/Specs/e/2/1/FirebaseAnalytics
