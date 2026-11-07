# Isolated MLKit host migration — incomplete

Branch: fix/mlkit-host-20261107. Do not merge or release yet. Main wallet branch remains unchanged.

Staged: pin Chat e10e6daf19e5cef1c67e96a970db75a84097ee2e; enable Flutter SwiftPM; remove legacy arm64 simulator exclusion and old CocoaPods OCR script entries. Local MIT-licensed OCR 1.0.1 override changes only its SwiftPM dependencies to retain all five scripts; upstream 1.0.1 otherwise silently falls back to Latin for non-Latin requests. Dart and Android sources are unchanged.

Model preparation: `python3 scripts/prepare_mlkit_resources.py` passed for ten required bundles. SHA-256 values are pinned in ios/NativeDependencies/mlkit-resources.json from the upstream 9.0.2 release asset digests. Downloaded binaries under ios/MLKitResources are ignored. The main-app resource build phase is not wired yet. Python compilation and git diff --check pass.

Host regression: 125 tests pass, exit 0, covering Chat initialization, social configuration, mini-app configuration, SSO and push routing/dedup. Log: /tmp/n42-wallet-mlkit-host-tests-20261107.log. This is not native SwiftPM resolution or model runtime acceptance.

Native build attempt exits 1 at SwiftPM resolution: Firebase SDK 13.1.1 requires gtm-session-fetcher 4.0.0..<6.0.0; google-mlkit-swiftpm 9.0.2 requires 3.5.0..<4.0.0. Log: /tmp/n42-wallet-mlkit-build-20261107.log. No dependency constraints were forcibly widened, Firebase downgraded or features removed. Flutter rolled back its automatic SwiftPM project integration after resolution failure.

Remaining before merge: resolve native dependency compatibility with validated versions or reviewed package integration; complete Flutter-generated project integration; wire all model bundles and verify required linker flags; build arm64 simulator and device; install and cold launch; verify all OCR scripts, face blur, segmentation and translation. Repeat host regressions and relevant Android validation. Preserve the known-good main branch and its previous release configuration.
