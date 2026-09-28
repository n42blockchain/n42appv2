# Bounded Wallet Core 4.8.4 acceptance

| Check | Recorded result | Evidence |
| --- | --- | --- |
| Exact source and guarded tools | Pinned tag `d40d24a63d92619167903369308bf0e2f7eb3a59`; controlled generation/link inputs; not a producer-reproducible build claim | `reports/`, `raw/build/`, `source/scripts/` |
| Four Android ABIs | JNI exports, SONAME, NEEDED and undefined symbol/version comparisons retained; stripped maintained members match the four-ABI manifest | `raw/build/candidate-stripped/`, `artifacts/maintained-wallet-core-4.8.4.aar` |
| 16 KB static alignment | Maintained 64-bit LOAD/RELRO and four-ABI audit pass; official ARM64 member fails static alignment | `raw/build/candidate-stripped/audit/summary.json`, `raw/build/maintained-aar-elf-audit.json`, `reports/task-16f-walletcore-runtime-report.md` |
| Package and Java/proto preservation | Exactly four JNI AAR members changed; all other 9 ZIP entries, Java classes, core POM and proto artifacts preserved | `raw/build/tracked-packaging-report.json`, both AARs and metadata |
| Actual app Gradle selection | Release compile/runtime select maintained `com.trustwallet:wallet-core:4.8.4`, official proto 4.8.4 and `protobuf-javalite:4.36.2` | `logs/app-selection.log`, `reports/task-16f-walletcore-packaging-report.md` |
| Dedicated ARM64 fixture | Both pinned APKs load from installed `base.apk` in distinct fresh PIDs under 16,384-byte pages and offline fatal compatibility; four tagged goldens PASS with equal outputs | `raw/runtime-receipt.json`, `raw/runtime-verification.json`, both APKs |
| App-shaped BitcoinV2 P2WSH observation | Both versions return `Error_invalid_params` and empty encoded bytes for the synthetic app route; this is not a successful transaction | `raw/runtime-verification.json`, `reports/task-16f-walletcore-runtime-report.md` |
| Offline archive replay | Normal and optimized replay PASS; five changed-member/state/source/map/golden controls reject | `verify_evidence.py`, `verify_evidence_controls.py`, `manifest.json` |

The published baseline's static ARM64 alignment failure did **not** cause a
load failure on this specific strict emulator run. The maintained candidate
passes both the static check and this run. These facts are kept distinct.

This evidence does not cover a complete Flutter APK/AAB, API-26 runtime,
every wallet/chain path, live keys/funds/broadcasts, production signing,
latest store acceptance or final license clearance. Existing IAP,
subscription and wallet business routes were not changed by this native ABI
replacement. Any BitcoinV2 P2WSH business fix needs separate analysis and
authorization.
