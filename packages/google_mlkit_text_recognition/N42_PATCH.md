# N42 OCR integration patch

Based on pub.dev google_mlkit_text_recognition 1.0.1 (MIT license retained). Dart API, Android implementation and Swift implementation are unchanged. The Swift package links all five script products so existing non-Latin recognition does not silently fall back to Latin. Model bundles must be added by the host; the original package bundles are excluded here because upstream requires main-app resource placement. Do not edit the global pub cache.
