# Physical-device acceptance

Use the explicit device wrapper for tests on phones that contain user data:

```bash
scripts/test_device.sh DEVICE_ID integration_test/app_test.dart
```

It passes `--no-uninstall`. Flutter 3.44 defaults to uninstalling integration-test
apps during cleanup, including after deployment failure. Do not invoke a bare
`flutter test integration_test/... -d DEVICE_ID` on a user's installed wallet.
The flag prevents automatic uninstall; it does not make destructive test cases
safe. Review the selected test, use disposable test accounts, and do not reset
storage or import fixtures over an existing wallet.

`app_test.dart` checks real app startup, declared routes, and lifecycle recovery.
`device_full_flow_test.dart` requires a configured account and Chat test credentials
for its authenticated phase. A missing prerequisite is not a passed flow.
Do not label a locally mocked test as a physical-device or on-chain pass.

Record app version, device/OS, tested screens, errors, and screenshots. For an
on-chain pass, retain the network, public addresses, transaction digest, receipt,
and balance changes. Keep private keys and mnemonics out of source and logs.
Mainnet transactions are excluded from the current acceptance authorization.

See [the September 10 report](../docs/device-test-reports/2026-09-10-device-testnet-acceptance.md)
for the installation/signing blockers, app restoration incident, and public
Sui Devnet verification evidence.

The [device retry report](../docs/device-test-reports/2026-09-10-device-retry-acceptance.md)
records subsequent successful deployment and native signing checks on both
phones. On this Mac, iOS signing succeeds from a GUI Terminal session even when
the same identity fails in the background execution context. Run the same safe
wrapper from Terminal in that case; no keychain password belongs in a command.

## Native Solana acceptance

`native_solana_signing_test.dart` runs the real Wallet Core method channel on a
phone, generates a temporary account in memory, independently verifies its
Ed25519 signature, and queries Solana Testnet for the message fee. It never
persists the mnemonic or calls a transaction broadcast method. This is a native
signing check, not a funded transfer or a UI payment pass.

For page navigation without authenticated Chat, run:

```bash
flutter test --no-pub --no-uninstall --reporter expanded \
  --dart-define=N42_E2E_INCLUDE_CHAT=false \
  -d DEVICE_ID integration_test/device_full_flow_test.dart
```

The test name and output explicitly exclude Chat in that mode. The default
continues to include the authenticated Chat flow.

## Local proxy configuration

`ProxyConfig` reads `PROXY_BASE_URL` and `PROXY_AUTH_TOKEN` from Dart compile
defines; a local `.env` file alone does not populate those constants. Supply a
private JSON define file containing only the needed settings. Keep it outside
version control, readable only by its owner, and do not put the token directly
in a shell command or log. The physical-device wrapper accepts its path:

```bash
N42_DEVICE_DEFINES_FILE=/path/to/private-proxy-defines.json \
  scripts/test_device.sh DEVICE_ID integration_test/app_test.dart
```

For navigation plus a read-only authenticated market check:

```bash
flutter test --no-pub --no-uninstall --reporter expanded \
  --dart-define-from-file=/path/to/private-proxy-defines.json \
  --dart-define=N42_E2E_INCLUDE_CHAT=false \
  --dart-define=N42_E2E_CHECK_PROXY=true \
  -d DEVICE_ID integration_test/device_full_flow_test.dart
```

The additional check requires nonempty trending data from the real proxy. It
prints only the record count, never the credential. Pass the same private
define file when rebuilding the normal `lib/main.dart` entrypoint afterward.

Do not run UIAutomator/accessibility hierarchy dumps concurrently with a Flutter
integration test. They can change native accessibility state after the test has
started and trigger the framework's outstanding SemanticsHandle check. The
Android startup case passed when repeated without the concurrent UI inspection.

The wallet navigation flow also opens the first token row and returns from its
asset details page. With `N42_E2E_CHECK_PROXY=true`, it presses the home refresh
control and checks that complete quotes advance the successful timestamp inside
the cache window. Incomplete or failed quotes must preserve the timestamp and
show the partial/cached/unavailable status that matches the received data. Both paths must finish loading and retain
the compact text status without a balance-sync banner. These checks make
read-only requests and do not submit transactions.

The flow requires a visible preset USDT/USDC asset and opens its network balances,
either directly from an aggregate row or through the ordinary asset detail page.
It verifies the real receive QR route has a token descriptor without a private
key, opens the corresponding mainnet asset page, and returns to the wallet.
`DEVICE_AGGREGATE detail=true receive=true network=true readOnly=true` records
completion. This does not assert that every public balance RPC is available.

For external device screenshots, add
`--dart-define=N42_E2E_CAPTURE_AGGREGATE=true`. The test emits
`DEVICE_AGGREGATE screenshotReady=true` and holds the loaded detail page for
12 seconds before continuing. The default run has no screenshot delay. Archive
only fixed `DEVICE_*` markers and test outcomes, keeping raw device logs private.

Add `--dart-define=N42_E2E_CHECK_DEEP_LINKS=true` to inject a fixed, non-real ID
Hub request before the first app frame. The test verifies startup intent
delivery through the real host router, suppresses a duplicate while that page
is open, returns home, and rejects an untrusted origin before navigation.
It never taps the signing confirmation. This exercises the app's pending-link
handoff; it is not an operating-system universal-link association or completed
SSO/account-binding acceptance. `DEVICE_DEEP_LINK` records the outcome.
