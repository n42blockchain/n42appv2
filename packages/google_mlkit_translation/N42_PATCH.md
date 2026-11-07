# N42 translation bridge lifetime patch

Based on MIT-licensed google_mlkit_translation 0.15.1 from pub.dev; license retained. One GenericModelManager now lives for the plugin instance instead of being replaced by each check/download/delete request. This keeps concurrent downloads alive and lets the common manager route completion per model. Dart, Android and translation inference code are unchanged. Real concurrency acceptance is recorded in the host testing report.
