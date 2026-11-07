# N42 MLKit common bridge patch

Based on MIT-licensed google_mlkit_commons 0.13.0 from pub.dev. License retained. Dart API and Android implementation are unchanged. iOS model completion observers use the MLKit userInfo remoteModel key instead of filtering Notification.object, while retaining per-model success/failure filtering, duplicate suppression and observer cleanup. The real synthetic model-download integration test passes with a fresh app container. No global pub-cache modification.

Match equivalent notification models by model name and class, not object pointer identity. Both pubspec.yaml and pubspec_overrides.yaml must select this package.
