# Camera Core 1.6.2 Surface JNI evidence

This archive records Task16F.4's scoped source rebuild, maintained Maven selection, and synthetic old/new `SurfaceUtil.getSurfaceInfo` runtime comparison. It is self-contained for offline receipt and byte verification. From this directory, run:

```sh
python3 verify_evidence.py
python3 -O verify_evidence.py
```

Both commands check the complete relative-path member manifest, official and maintained AAR hashes, the exact four changed JNI entries out of 28, candidate4 JNI member hashes, APK-to-AAR native member identity, the seven run2 fixture-source hashes, and the strict 16 KB runtime receipt by replaying the archived verifier. `manifest.json` deliberately excludes itself; `members.txt` lists every other regular file. No account data, signing material, SDK cache, or full app APK/AAB is included.

Source and selection commits: `272b46e93a35fee9a00e0c5a0c293a471f000ba7` (native source and recipe), `e5a58ebcec83b4b8df809404823b8e1ffb592aa8` (maintained 1.6.2 selection), `0bf7a55842b2cbecbe2e64dd612590895b8f740a` (isolated fixture and verifier). The run2 receipt records the preceding `e5a...` Git HEAD because it was captured before the fixture commit; its seven source hashes match the committed `0bf7...` bytes archived under `source/`. The source-provenance snapshot identifies AndroidX tree `987b9ac8585b31424a397206c492196dd163997b` as the pinned maintained JNI source basis, not as a claim of bitwise supplier build reproduction. See `reports/stage1-source.md` and `reports/official-162-freshness.md` for the source boundary and version evidence.

The final emulator5560 run is `raw/runtime-run2-receipt.json`, with log `logs/runtime-run2.log`. `raw/runtime-run1-*` and `logs/runtime-run1.log` preserve a successful earlier run before the output-directory guard was added. `logs/reused-output-negative.log` demonstrates that guard's rejection. `logs/native-build-fail-stl.log` and `logs/native-build-fail-version-script.log` preserve earlier wrapper failures; their companion `*-diagnostic.log` files contain the actual compiler/linker errors. Neither represents a runtime crash. The final four-ABI build, ELF audits, Maven graph, targeted app compile, APK builds, positive/negative verifier controls, detailed limits and the three independent scoped reviews are in `logs/`, `reports/` and `reviews/`.

The old official JNI still fails the static 16 KB RELRO endpoint audit although this synthetic Surface call completed. The maintained arm64 and x64 members pass that static check and the candidate's arm64 member loaded on a strict 16 KB emulator. This archive does not establish real camera HAL behavior, full app APK/AAB packaging, or a completed whole-app native audit; the last measured full app release had 30 failures including two Camera members.
