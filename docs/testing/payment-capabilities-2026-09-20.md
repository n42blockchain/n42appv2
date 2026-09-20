# PAY-P0-02 — payment capability policy

Date: 2026-09-20. Scope: pure Dart domain policy only; no payment execution or external API integration.

## Implemented

- `lib/features/payments/domain/payment_capability.dart` defines distinct production, sandbox and local-simulation environments and six independent features: fiat transfer, fiat red packet, crypto transfer, crypto red packet, on-ramp and off-ramp.
- Production is disabled by default, even with a complete capability configuration. Enabling the production gate still requires exact environment/feature matching, operation approval, an enabled capability and reviewed region/network allowlists.
- Missing configuration, missing/unsupported region, unknown/pending/rejected KYC, unapproved operation and absent/unsupported blockchain network produce structured reason enums. Fiat operations do not require a blockchain network; crypto and ramp operations do.
- `requiresKyc` defaults to true. A reviewed self-custody crypto configuration may explicitly opt out. Fiat and ramp operations retain the KYC gate even if configured with `requiresKyc: false`. `operationApproved` describes approval of the provider operation or chain flow; it does not imply every crypto operation uses a provider.
- Decisions retain their environment. `isAvailable` is scoped to that environment; `isProductionAvailable` is always false for sandbox/simulation. Configuration cannot be reused across environments or features. Allowlists and decision reasons are immutable copies.

Region and network identifiers are matched exactly. Callers provide reviewed canonical region codes and namespaced network IDs; token symbols cannot substitute for network IDs. Configuration is trusted application policy, not unverified client/provider flags. No provider API fields or credentials were introduced.

## Validation

- `flutter test --no-pub test/features/payments/domain/payment_capability_test.dart`: **51 passed**.
- Coverage includes default production closure, missing configuration, each feature/environment combination, every cross-environment and cross-feature mismatch, region rejection, KYC states/exemption boundaries, network absence/mismatch, independent approval/enablement gates and immutable policy snapshots.
- `dart analyze lib/features/payments/domain/payment_capability.dart test/features/payments/domain/payment_capability_test.dart`: **no issues**.
- Logs: `/tmp/n42-payment-capabilities-tests-20260920.log`, `/tmp/n42-payment-capabilities-analyze-20260920.log`.

## Integration boundaries

This model is not wired to a production caller and does not authorize a transfer. Provider onboarding, authoritative account/region eligibility, exact asset and amount validation, backend authorization and audited chain execution remain later integration work. No external accounts were opened, APIs called, dependencies changed, credentials read or funds moved. Test approval values are synthetic and do not assert real market/provider availability.
