# TestFlight release — 2026-09-11

- App: `ai.n42.www`, version **2.4.8+2026072639**.
- Source: `158c14b0cd345b3f56a7c618c0a58f60edb55578` on `master`.
- Release tag: `v2.4.8-wallet-audit-20260911-r2`; the original tag remains intact.
- Archive and IPA export succeeded. App and extension versions match.
- Strict/deep code-signature verification passed. App Store provisioning,
  production APNs, disabled debug entitlement and SQLCipher symbols verified.
- IPA SHA-256: `b16b1c6ffd97b7337327f6794e323dfeb5b88baa6e10a8f0c796fd4b5ad4867b`.
- Xcode reported **Upload succeeded**, **Uploaded Runner**, and **EXPORT SUCCEEDED**
  at 2026-09-11 09:27:11 UTC; exit code 0. Apple reported the package processing.
  This does not establish completion of processing or tester availability.
- Non-blocking symbol-upload warnings: WebRTC.framework and
  flutter_vodozemac.framework lack matching dSYMs.
- No mainnet transaction was broadcast.

The first archive was intentionally cancelled to include the Gas-cap correction.
The accepted build is the second archive, with a distinct build number.
Local signing assets and private release configuration remain untracked.

After uploading, signing regression tests and coverage evidence are committed
separately. The commit hook may advance the development build number; this does
not change the already-uploaded version recorded above.
