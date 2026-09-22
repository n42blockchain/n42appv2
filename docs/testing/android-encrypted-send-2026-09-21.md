# Android encrypted send investigation — 2026-09-21

## Report and evidence

Downloads `2.jpg` shows a new send rejected with “Secure connection is not ready”
and historical undecryptable messages. User confirmed the connected Android
running release 2.4.8 (2026072753). Release logs do not expose the encryption
failure branch, so the screenshot-specific cause remains unconfirmed.

## Narrow correction

The guard incorrectly required the current sending device to satisfy the
recipient cross-signing policy. Matrix 6.2.0 excludes this exact device from
outbound room-key delivery. A locally valid device can fail that recipient
policy after login when account cross-signing exists but its signature is absent.

Exclude only the exact current user/device from `encryptToDevice` validation.
Continue checking its presence, block status, key validity and curve key.
Remote and other-own device policy, one-time-key readiness, and encrypted
delivery requirements remain unchanged. No plaintext fallback is introduced.

Canonical Chat commit: `6606eed4`.

## Validation

- Canonical `flutter test --no-pub test/unit/encryption/encrypted_send_guard_test.dart`: 17 passed.
- Focused analysis: no errors or warnings; 7 pre-existing informational lint findings.
- Tests cover current-device exemption, invalid current-device rejection,
  remote-device rejection, and other-own-device rejection.
- Android release build and on-device reproduction: pending.
- Historical message recovery is outside this correction; no claim of recovery.
