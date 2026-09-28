# Wallet Core 4.8.4 maintained Android JNI evidence

This bounded archive retains the exact Wallet Core 4.8.4 published and
maintained AARs, metadata and proto inputs, the two synthetic release-variant
fixture APKs, four-ABI build and package proofs, actual app Gradle selection,
source and license notices, and the dedicated `emulator-5560` run 1 receipt.
It excludes the synthetic signing key, production keys, complete upstream
checkout, toolchain/cache objects, and intermediate APK attempts.

Replay offline with Python 3 from this directory:

```sh
python3 verify_evidence.py
python3 -O verify_evidence.py
python3 verify_evidence_controls.py
python3 -O verify_evidence_controls.py
```

`members.txt` enumerates every regular archive member except `manifest.json`;
the manifest pins each member's byte count and SHA-256, including the verifier
and control script. Replay compares all 13 AAR ZIP members and proves that only
the four JNI members changed; checks source/strip/ABI/ELF/package hashes,
raw compressed symbol/header transcripts, versioned undefined imports,
unchanged Java/proto descriptors and POM, proto/Javalite inputs and app Gradle selection;
then calls the exact reviewed fixture verifier's APK ZIP, ELF, logcat framing,
installed byte, fresh PID/token, direct executable map, tagged golden and
old/new parity checks. Archive glue replaces the original Git-object and
locally installed device-tool lookups with archived source bytes and pinned
hashes. It cannot itself prove Git server authenticity or rerun Android;
`reports/` and `reviews/` preserve the original stage and independent review
records, while `raw/runtime-receipt.json` preserves original command outputs.
The replay entry points disable local Python bytecode writes before importing
archived modules, so a default Python `__pycache__` location cannot add a
member after the first run; extra-member rejection remains strict.

The actual 16,384-byte emulator run had fatal linker compatibility, package
compatibility disabled, airplane mode, Wi-Fi off and an empty route. The
published baseline and maintained candidate both loaded in distinct processes
(PIDs 19272 and 19382), passed four tagged HDWallet/Ethereum/Bitcoin JNI
goldens, and produced equal results on all five recorded cases. The published
native fails static 16 KB ELF alignment even though it ran on this emulator;
the maintained native passes both static and this runtime fixture. The fifth,
app-shaped BitcoinV2 P2WSH case returned `Error_invalid_params` and empty
encoded bytes on **both** versions. This parity is not a successful Bitcoin
transaction or a claim that the app's signing route is correct.

The fixture APKs have no INTERNET permission and are signed only with a
task-owned synthetic key. The evidence covers ARM64 runtime and four-ABI
static/package checks. It does not establish API-26 runtime, the complete
Flutter APK/AAB, all wallet operations, real account or fund use, network or
broadcast behavior, latest store acceptance, or final license clearance.
The user's IAP, subscription and existing business routes were preserved.
