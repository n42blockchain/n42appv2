# iPhone Duo simulator partial acceptance

Source baseline: `19da594a87c08aa9a49650530b01ebaf80ed2782` (2.5.2+73029).
Device: iPhone Duo / iOS 27.1 (24A94232).
Toolchain: Flutter 3.47.5 / Dart 3.13.4 / Xcode 27.1 RC.

## Results

- Five adaptive viewport widget tests passed: dynamic size changes, route/draft retention, fold avoidance, keyboard safe regions and navigation layout switching.
- 54 wallet compact layout, signing-sheet and Apple UI widget tests passed.
- One added terms-page regression passed at 390x350 and 3x text: the label remains inside the button and scroll controls stay above it.
- Targeted static analysis: no issues.
- Simulator screenshots confirmed terms content reflows between closed and open states. In partially open mode, content occupies one pane; after rotation it occupies the lower pane.
- Maximum accessibility text exposed a clipped Agree label. Removed its fixed height and confined scroll controls to the document region. Rebuilt, installed and visually verified the label is complete and controls no longer overlap.

## Important limits

- The unmodified native build produced an x86_64 simulator executable because MLKit lacks an arm64 simulator slice. The installed Duo runtime supports arm64 only and rejected installation.
- UI screenshots therefore use an isolated temporary app copy with five MLKit iOS plugin registrations and explicit MLKit pods omitted. Dart application screens otherwise use the source under review. This QA package is not a production build and must not be uploaded.
- No production dependency or native build configuration was changed by this workaround. OCR, face detection, segmentation and translation are excluded.
- First-run Terms of Use remains visible. The operator was asked to review and accept it locally; the agent did not accept or bypass it. Actual home, market, settings and authenticated Chat navigation remain pending.
- Keyboard/draft continuity has widget-test proof only. Camera, QR, calls, capture protection, transactions and physical Duo behavior are unverified.
- This is partial simulator acceptance, not complete iPhone Duo support.

Raw logs, screenshots and temporary QA project remain outside Git under `/tmp/n42-duo-acceptance-20261016`.
