# Task 16C Go V1 Android SDK evidence

The app's two `evm.aar` copies are the reviewed 41,052,430-byte AAR with SHA-256 `a7f1e0122ca76fe6a4b5c3a29816a07bb95cacb3cc6c21d73573d90a168d258c`. It was rebuilt from public N42-gov5 v5.7.906 commit `5083c29735acfc7023ab1fbbd6d6527b7b97cbae`, the tracked source overlays, Go 1.26.8, pinned gomobile and Android NDK 28.2. The tracked [recipe](../../../../../tools/android_native_smoke/go_evm_v5_7_906/README.md) states the exact preparation, prefetch and offline build commands. The old AAR had unknown exact source and serves only as an offline protocol baseline.

`task-16c-evidence.tar.gz` contains text records under `logs/`, `security/`, `reports/` and `build-v4/`, plus the controlled size comparison scripts. `manifest.json` records the archive SHA-256, every regular member's size and SHA-256, and both app AAR hashes. From the app root, verify without extracting or running any SDK:

```sh
python3 docs/testing/dependency-completion-2026-09-25/native-sdk-evidence/go-v1/verify_evidence.py
```

The verifier passed on this 261-member archive. Independent test copies with a changed archive byte and a changed member hash both failed as expected. A separate run of the archived packing script reproduced the same archive and manifest byte for byte, SHA-256 `456ec05de2b7dccdaf15c862d32fcdf6513b4d44cb03420ec8bb1d9f95741682`. The ignored task workspace retains the verification and replay transcripts.

The archive retains failed attempts and review corrections alongside passing results. It omits SDK caches, binary build outputs, APKs, AABs, temporary Gradle signing configuration copies, signing material and account credentials. The app's committed AARs remain the binary reference; retained release APK/AAB hashes bind the text records to actual package bytes. The manifest records the historical Task 16B baseline, fixture, comparator correction and AAR integration commits. To inspect a historical tracked fixture or runner, use `git show <recorded-commit>:<path>`; a later HEAD may legitimately change shared harness code. The archive's raw run logs retain the source hashes observed at run time. The verifier checks the archived bytes and current AARs, not historical working-tree source against a future HEAD.

## Verification boundaries

- The final AAR includes armv7, arm64 and x86_64 `libgojni.so`, preserving `evmsdk.Evmsdk.emit(String):String`. The NDK stripped member in the strict 16 KB offline arm64 fixture equals the release APK member byte for byte. Synthetic valid Emit responses match the old AAR; one invalid key response deliberately differs because the new SDK rejects it. An independent Rust blst oracle checks BLS vectors and the app's deposit ABI without signing or sending a transaction.
- The final AAR's two 64-bit ELF members pass LOAD and GNU_RELRO checks. The complete release APK and AAB still fail the whole native audit for 35 of 55 libraries; Task 16F owns those other binaries. A release package build and static member check do not prove full-app runtime or store acceptance.
- The exact final AAR's three stripped members were scanned with `govulncheck v1.1.4`. Cilium's earlier advisory is gone after v0.22.0. The remaining OpenPGP unmaintained advisory is a module-version fallback, not a demonstrated linked package or reachable call: final offline package graphs for all three ABIs select zero OpenPGP packages. The scanner JSON exits zero even when findings exist. The source/license inventory is review input, not a combined-app license conclusion.
- The old SDK ran only in isolated offline compatibility mode; it is not 16 KB proof. The final SDK ran with compatibility disabled and a 16 KB page emulator. Neither SDK was started against a validator. No production signing, Play upload or account action was performed.
- A controlled same-commit AAR swap produced old/new release APKs of 739,729,224/800,218,952 bytes. The added stored Go JNI bytes explain 60,506,988 bytes of the difference; the new AAB grew only 3,865,652 bytes because its compressed Go members and nondelivered bundle metadata changed in opposite directions. Bundletool's 4,662 static delivery rows for the new AAB range from 111,643,477 to 163,594,956 compressed bytes. The actual store upload and signing verdict remain external.

See `reports/task-16c-go-sdk-report.md` in the archive for exact commit, build and package identities, commands, review outcomes and remaining external gates. The local release packages use temporary debug signing and are not final store submissions.
