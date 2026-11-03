# iOS V3 bridge acceptance

These tests use the real native SDK and the configured testnet. Each run
registers a new ephemeral verifier. They never export the private key.

Build the opt-in app from the example directory:

```sh
flutter pub get
flutter build ios --release --no-pub \
  --target integration_test/mobileverify_ios_smoke_app.dart \
  --dart-define=MINING_V3_IOS_SMOKE=true \
  --dart-define=MINING_V3_IOS_SOAK_SECONDS=300 \
  --build-name=1.0.0 --build-number=3
xcrun devicectl device install app --device "$DEVICE_UDID" build/ios/iphoneos/Runner.app
xcrun devicectl device process launch --device "$DEVICE_UDID" \
  --terminate-existing mining.ai.n42.www.flutterMiningExample
```

The build needs valid local development signing. `MINING_V3_URL` and
`MINING_V3_CHAIN` can override the LAN test defaults. Without the smoke opt-in,
the app does not start the test. Without the soak parameter, it skips the soak.

The SDK chain must match the node's execution rules, including its fork
schedule. A local `mainnet_qmdb_staggered` genesis with Shanghai/Cancun moved
to block 1 does not match that SDK preset. Empty blocks can hide this
mismatch; include transaction traffic. For an isolated Rust fleet using the
SDK's `mainnet_qmdb` rules, set `MINING_V3_CHAIN=mainnet_qmdb` explicitly.
Do not use that preset for a node with a different fork schedule.

Grant the expected local-network permission on the phone. The test gives the
first connection 30 seconds for that flow. It then checks registration, block
verification, certificate queries, and native mining. The optional soak checks
that the session remains active, counters do not decrease, and verification
and certificate counts both advance. Any block verification failure fails the
healthy soak and lifecycle checks. Public results include the node, chain,
start time and native error log so earlier successful empty blocks cannot
hide a failed transaction block.

Read only the public result file:

```sh
xcrun devicectl device copy from --device "$DEVICE_UDID" \
  --source tmp/n42-mobileverify-ios-smoke/results.json \
  --domain-type appDataContainer \
  --domain-identifier mining.ai.n42.www.flutterMiningExample \
  --destination /tmp/n42-ios-device-results.json
```

When `stage` is `ready-for-background`, put the app in the background or lock
the phone for at least 12 seconds. Unlock and return to the same app without
terminating it. Then send its continuation flag:

```sh
touch /tmp/resume.request
xcrun devicectl device copy to --device "$DEVICE_UDID" \
  --source /tmp/resume.request \
  --destination tmp/n42-mobileverify-ios-smoke/resume.request \
  --domain-type appDataContainer \
  --domain-identifier mining.ai.n42.www.flutterMiningExample
```

When `stage` is `ready-after-stop`, repeat the background-and-return step for
at least six seconds and copy a `stopped-resume.request` flag to the same test
directory. Both continuation stages have a three-minute deadline. A successful
run ends at `passed`, with the native miner stopped. Every new run removes its
own stale continuation flags.

For simulators, use the existing `drive_mobileverify_ios_smoke.py` driver with
an explicit simulator UUID. Do not apply this driver to physical devices.

Save the public JSON and a final screenshot with the test report. Record the
actual device, OS, app version, node, and build mode. A short soak does not
establish multi-hour stability, battery drain, or physical temperature limits.
