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
- The operator completed first-run Terms of Use locally. The agent did not accept or bypass it. Home, market and settings navigation were subsequently exercised; authenticated Chat remains unverified.
- Search text `btc` survived the observed fold/rotation sequence with the keyboard visible; widget tests additionally cover draft continuity. Camera, QR, calls, capture protection, transactions and physical Duo behavior are unverified.
- This is partial simulator acceptance, not complete iPhone Duo support.

Raw logs, screenshots and temporary QA project remain outside Git under `/tmp/n42-duo-acceptance-20261016`.

## Follow-up after operator confirmation

- Opened wallet home, BTC asset preview and full chart. Selected 1M, then changed from closed to open and partially open; the route and selected period survived and the chart fit one usable pane. Back navigation returned to the asset and home pages.
- Opened Markets, Settings and Theme. Inspected Apple/default and optional custom styles, and light/dark presentation.
- Maximum accessibility text exposed fixed narrow theme preset cards. Cards now use one column at large sizes, with complete descriptions. Twelve theme behavior tests passed and the corrected dark-theme screen was visually verified.
- Half-open portrait with a keyboard exposed the backup overlay and balance cards hiding token search. Search mode now removes the floating overlays and collapses the balance/feature cards. The simulator screenshot confirms the search field and results remain in the top pane above the keyboard. Closing search restores the normal content and reminder.
- Eight wallet interaction tests passed, including short-screen search geometry and restoring the backup reminder on exit. Eighteen compact wallet tests passed. Targeted analysis found no issues.
- Remaining observed failures: maximum accessibility text still makes side-navigation labels wrap excessively and makes the floating backup reminder occupy too much home-list space outside search mode. These are not accepted.
- The UI QA copy is still based on the recorded baseline plus the specific fixes above; later remote navigation/dependency changes are not independently accepted by these screenshots. All raw captures remain local.
- Result: bounded UI checks completed, with outstanding failures. This is not full-app or physical Duo acceptance. No new TestFlight upload was made.
