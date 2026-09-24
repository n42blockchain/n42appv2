# QR Protocol Remediation Plan

## Goal

Save the QR protocol inventory and deliver P0 wallet payment QR correctness, P1 Chat/social QR interoperability, then P2 wallet camera scanner unification. The user-facing acceptance criteria are in `docs/qr-protocol-inventory-remediation-2026-09-24.md` and the P0 direct-payment behavior is defined by the existing merchant QR spec.

## Architecture

- Keep protocol codecs as pure string/model logic so malformed payload behavior is unit-testable.
- Normalize supported wallet payment requests to chain/network/asset/recipient/optional-amount data before resolving against wallet-owned assets.
- Continue routing WalletConnect and hardware-wallet UR payloads through their dedicated handlers.
- Treat Matrix permalinks and WhatsApp Click to Chat as allowlisted social payloads, with explicit confirmation before joining or external navigation.
- Use the app root dependency graph for all `n42_chat` tests; the package-local lock resolution can select incompatible plugin versions.

## Tech Stack

Flutter, Dart, Riverpod, `flutter_test`, `mobile_scanner`, `qr_flutter`, the local `packages/n42_chat` development override, Matrix SDK.

## Spec

- `docs/qr-protocol-inventory-remediation-2026-09-24.md`
- `docs/superpowers/specs/2026-09-24-merchant-qr-direct-payment-design.md`

## Global Constraints

- Fail closed on malformed/ambiguous payment requests; never infer a token from symbol or recipient address shape.
- A missing amount remains editable. Plain addresses keep the coin picker. WalletConnect and UR behavior remain separate.
- Confirm before joining a Matrix room or leaving the app for an external social link.
- Preserve backward compatibility for existing N42 Chat user IDs/payment request forms, but identify when they lack enough asset context.
- All commits use short English Conventional Commit subjects.
- `packages/n42_chat` is a local mirror of a Git dependency; note the required forward-port in release notes.

## Review Focus

Wrong-chain or wrong-token routing, malformed URI acceptance, backward compatibility, URL allowlisting and confirmation boundaries, camera permission/lifecycle regressions, dependency/lockfile consistency.

## Task 1 — Save the inventory and execution criteria (P0/P1/P2)

### Interfaces

Produces the report and this executable plan consumed by Tasks 2–5.

### Steps

1. Review the report against current code entry points, public protocol links, and the previously committed direct-payment design.
2. Run `git diff --check`.
   - Expected: no whitespace errors.
3. Record the documentation task in the SDD ledger. Create one final commit after all phases so the repository's pre-commit build-number hook runs once.

### Acceptance

- The report lists every QR producer/consumer family discovered, standards comparison, social interop limits, ordered priorities, and testable criteria.
- P0, P1, P2 remain in the requested order and each has observable acceptance checks.

## Task 2 — P0 payment request model, strict parsing, and resolution

### Interfaces

Consumes `CoinModel.config.mKey`, network (`isTest`), chain ID, token contract/mint, and the existing `Eip681Request`. Produces a normalized payment request consumed by Task 3 wallet routing and receive QR generation.

### Steps

1. Add failing tests for versioned `n42pay://v1/pay` round-trips, required/forbidden fields, URI encoding, positive decimal amounts, duplicate parameters, malformed values, and unsupported versions.
   - Expected: the tests fail because the v1 model/parser is not present.
2. Run `flutter test test/features/wallet/chain_payment_uri_test.dart` from the repository root.
   - Expected: only assertions about the new API fail; no compile/test harness errors.
3. Implement the versioned request codec and strict EIP-681 accepted-shape validation needed for wallet send requests. Preserve supported existing native payment URI parsing where the chain can be mapped unambiguously; requests that cannot resolve an asset return null/unsupported.
4. Add failing resolver tests for exact chain, network, token contract/mint, absent amount, ambiguous matches and unsupported assets.
   - Expected: resolver tests fail before the resolver changes.
5. Implement normalization and resolution against wallet coin candidates. Token matching uses network-specific contracts, never symbols. EVM requests match explicit chain ID; N42 requests match mKey and network.
6. Run `flutter test test/features/wallet/chain_payment_uri_test.dart test/features/wallet/eip681_test.dart test/features/wallet/scan_to_pay_utils_test.dart`.
   - Expected: all named tests pass.
7. Record Task 2 test evidence in the SDD ledger; defer the commit until all phases are complete.

### Acceptance

- Required chain/network/type/recipient fields are validated; native cannot include a contract; token requires one.
- Invalid or duplicate critical query fields, unsupported URI versions, unsupported EIP-681 functions, invalid decimals and missing identity fail closed.
- Amounts remain display-unit decimals for N42 and are converted from EIP-681 minimum units using the resolved asset decimals.
- Resolver returns one exact asset or null; no symbol/address-shape guessing.

## Task 3 — P0 asset-aware receive QR generation and wallet routing

### Interfaces

Consumes Task 2 request model and resolver. Integrates `wallet_receive_qr.dart` with `wallet_page.dart`; preserves WalletConnect and plain-address routes.

### Steps

1. Add failing producer tests for amount-free/amount-bearing native and token QR payloads on EVM and non-EVM chains, including Solana SPL mint and N42 fallback network identity.
   - Expected: the current address-only/no-amount behavior and missing mint/network assertions fail.
2. Run `flutter test test/features/wallet/pages/wallet_receive_qr_test.dart`.
   - Expected: new behavior assertions fail, existing EIP-681 cases pass.
3. Implement exact identity-bearing generation. Use EIP-681 for EVM, Solana Pay where the public network/asset can be represented, standard Bitcoin form where unambiguous, and N42 v1 fallback where a public format cannot identify the configured network or token.
4. Add failing wallet scan dispatch tests or focused resolver/route seam tests proving exact-asset requests go direct, unsupported requests do not reach the selector, plain address keeps the selector, and WalletConnect is unchanged.
   - Expected: each assertion fails against existing dispatch.
5. Integrate normalized parsing/resolution in `_scanToPay` before plain-address fallback.
6. Run `flutter test test/features/wallet/pages/wallet_receive_qr_test.dart test/features/wallet/chain_payment_uri_test.dart test/features/wallet/eip681_test.dart test/features/wallet/scan_to_pay_utils_test.dart`.
   - Expected: all named tests pass.
7. Record Task 3 test evidence in the SDD ledger; defer the commit until all phases are complete.

### Acceptance

- All wallet-produced receive QRs contain native/token identity even with no amount.
- EVM native and ERC-20 requests carry explicit chain ID and contract; Solana token requests carry SPL mint; unresolved network/asset uses N42 v1.
- No amount opens the exact send form with amount editable; a valid amount pre-fills existing send behavior.
- Unsupported recognized requests show unsupported feedback and do not fall through to the coin picker.
- Plain address picker and WalletConnect pairing routes remain intact.

## Task 4 — P1 Chat/social QR interoperability and payment compatibility

### Interfaces

Consumes Chat payment URI and Matrix permalink utilities. Produces normalized social scan payloads used by `ScanQRPage`; preserves local N42 mini-app and user QR compatibility.

### Steps

1. Add failing parser tests for Matrix user, room/space link, legacy N42 user code, valid `wa.me` HTTPS links, and rejection of untrusted hosts/schemes/credentials/ports/invalid international numbers.
   - Expected: Matrix rooms and WhatsApp payloads are not recognized today.
2. Run `flutter test packages/n42_chat/test/unit/utils/social_scan_payload_parser_test.dart packages/n42_chat/test/unit/utils/payment_request_uri_test.dart` from the app root.
   - Expected: new format tests fail; no dependency compilation errors.
3. Implement parser normalization and update newly generated personal QR to Matrix permalink. Keep generated room links parseable. Retain legacy parser support.
4. Add failing tests for versioned Chat payment requests requiring network and contract/mint identity, plus explicit legacy parsing for `n42pay://pay` and `n42://pay`.
   - Expected: the new strict v1 validation and identity metadata tests fail.
5. Implement Chat v1 encoding/parsing and merchant QR generation using chain/network/asset identity where available; legacy requests remain recognizable but must be marked ambiguous and never silently auto-select a token.
6. Add tests that room join and WhatsApp launch require confirmation; cancellation produces no repository call/launch. Implement safe confirmation and allowlisted navigation/room-join behavior.
   - Expected: scanner-flow tests fail before confirmation behavior is added.
7. Run `flutter test packages/n42_chat/test/unit/utils/social_scan_payload_parser_test.dart packages/n42_chat/test/unit/utils/payment_request_uri_test.dart packages/n42_chat/test/presentation/pages/my_qrcode_page_test.dart packages/n42_chat/test/presentation/pages/scan_qr_permission_test.dart` from the app root.
   - Expected: all named tests pass.
8. Record Task 4 test evidence in the SDD ledger; defer the commit until all phases are complete.

### Acceptance

- New personal Chat QR uses Matrix permalink; legacy N42 user QR still resolves.
- Matrix room/space QR scans to a room preview and joins only after user confirmation.
- WhatsApp accepts only `https://wa.me/<international-number>`; displays the destination and launches only after confirmation.
- Unsafe URL variants never reach a launcher.
- Versioned payment QR carries chain, network and token contract/mint; symbols are display-only. Legacy formats remain readable but ambiguous assets require explicit choice and confirmation.

## Task 5 — P2 migrate wallet camera scanner to `mobile_scanner`

### Interfaces

Replaces `qr_code_scanner_plus` inside `ScanPage`, preserving `Future` navigation result (`String?`) consumed by Task 3. Chat and Keystone scanners remain on their already-established `mobile_scanner` integrations.

### Steps

1. Add failing pure/widget tests for one-result delivery, camera permission states, flash toggling and controller disposal/lifecycle seams.
   - Expected: current `ScanPage` lacks testable lifecycle/result behavior and the migration seam tests fail.
2. Run the focused wallet scanner test.
   - Expected: new assertions fail because the shared scanner controller/result guard is absent.
3. Replace QRView with a single `MobileScannerController`/`MobileScanner` flow; request/check camera permission consistently, serialize start/stop lifecycle, expose flash state, stop and dispose safely, and prevent duplicate pop.
4. Remove `qr_code_scanner_plus` from `pubspec.yaml`, resolve dependencies from the app root, and confirm the lockfile drops its direct/transitive package when unused.
5. Run focused scanner tests, all QR acceptance tests, and `flutter analyze --no-fatal-infos`.
   - Expected: all tests and analysis pass; platform camera testing is separately recorded if the environment has no device.
6. Record Task 5 test evidence in the SDD ledger; defer the commit until all phases are complete.

### Acceptance

- Camera permission denied/restricted/granted states show the correct screen and camera behavior.
- Lifecycle pause/resume and dispose do not leave duplicate active controllers or invoke a disposed controller.
- Flash toggles once per user action; first successful barcode returns exactly one raw string and stops scanning.
- The old dependency is removed, app routing API is unchanged, and related Flutter analysis/tests pass.

## Final Verification

After Tasks 2–5, run all QR-focused wallet and Chat tests, `flutter analyze --no-fatal-infos`, `git diff --check`, inspect the entire branch diff against the starting commit, and record any platform camera tests that cannot run in the current environment. Commit the complete result with an English Conventional Commit subject; the repository hook will include its single build-number bump. Do not push or publish from this worktree.
