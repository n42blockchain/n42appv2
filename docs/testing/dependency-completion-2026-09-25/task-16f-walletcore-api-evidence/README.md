# Wallet Core Bitcoin V2 adapter evidence

This archive preserves the exact release-style synthetic APK and records for the
production `BitcoinV2SigningAdapter` JNI check. It is self-contained for offline
verification; it does not contact a device, repository, package manager, or task
workspace. Run `python3 verify_evidence.py` and
`python3 verify_evidence_controls.py` from this directory. Repeat with
`python3 -O` for an optimized-Python replay.

`manifest.json` hashes every archive member. Ten logical APK inputs (the build
artifact and installed pulls in runs 1–5) had the same SHA-256 and are represented
by one compressed artifact, `artifacts/build3-apk.gz`. The verifier expands that
artifact into temporary files and replays the reviewed runtime verifier against
the recorded run 5 device receipts. `source/` holds the precise adapter, fixture,
runner, verifier, and build epoch bytes used for this APK and runtime; `raw/`
holds the recorded build, owner, runtime, and review evidence. The original task
path embedded in receipts is historical data, not an archive dependency.

The exact APK is a **synthetic fixture**, signed with its fixture debug key. No
signing key is archived. The older Wallet Core evidence archive contains the
four-ABI native build, official comparison, Maven metadata, and license records.
This archive is the separate application API correction proof, not a full app
build or release artifact.

Runs 1–4 are retained as partial failures in transport or runner probes. Run 4
contains real API 26 JNI output but did not complete the receipt. Run 5 completed
on the owned strict 16 KB API 37 emulator and the owned API 26, 4 KB emulator.
Both devices returned the tag golden vector and explicit `Error_not_supported`
for the app-shaped P2WSH input. That error does not establish P2WSH spending
support; no funds, account, network, or broadcast operation was involved.
