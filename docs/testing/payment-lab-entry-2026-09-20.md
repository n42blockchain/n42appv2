# Explicit local payment lab entry

Scope: an opt-in developer UI, not a production wallet route. Open Settings → About → Local payment lab only in a non-release build compiled with `N42_LOCAL_PAYMENT_LAB=true`. Without the flag the entry is absent; release builds always disable it. No production wallet or Matrix credential is used.

## Local setup

```sh
python3 backend/payment-sandbox/run_local.py
flutter run --dart-define=N42_LOCAL_PAYMENT_LAB=true
```

Use the public fixture token `synthetic-test-accounta` or `synthetic-test-accountb`, asset `test-usdc`, recipient `a` or `b` (other than the sender), and a positive integer **minor-unit** amount. Each account starts with 100000000 synthetic minor units. The launcher deletes the temporary ledger on exit. These are synthetic identifiers, not provider sandbox credentials or real USDC.

The host defaults to `http://127.0.0.1:8765`. An alternative loopback port can be supplied with `--dart-define=N42_LOCAL_PAYMENT_ENDPOINT=http://127.0.0.1:PORT` and the launcher's `--port PORT`. Remote hosts and HTTPS endpoints are intentionally rejected by this local client.

For an Android USB development connection, an explicit device reverse mapping can be configured with `adb -s SERIAL reverse tcp:8765 tcp:8765`; remove it with `adb -s SERIAL reverse --remove tcp:8765` afterward. A debug-only network-security resource adds literal `127.0.0.1` to the existing local exceptions. The main resource remains unchanged and HTTPS remains the default. XML structure was checked; Android resource packaging and physical-device connectivity have not been validated in this batch.

The host owns and disposes both transport and client. Invalid endpoint configuration shows a disabled page rather than opening a remote service. The page's detailed interaction evidence is recorded separately in `payment-lab-ui-2026-09-20.md`.

## Validation

- Host widget test with default flags: the payment page is absent.
- The same test with `--dart-define=N42_LOCAL_PAYMENT_LAB=true`: the injected local page is present; disposal produces no widget exception.
- Launcher validation: 4 tests, including actual subprocess startup, HTTP balance request and SIGINT cleanup.

Logs: `/tmp/n42-payment-lab-host-disabled.log`, `/tmp/n42-payment-lab-host-enabled.log`.

This is the balance/transfer lab slice. Red-packet form, persistent pending-order recovery, mainnet execution, public testnet execution, provider contracts and real-device acceptance remain separate tasks. The latest full-app coverage report predates this UI entry; do not count these tests as a new full-suite measurement.
