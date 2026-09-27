# Task16F.3 Vodo crypto/fixture review

Range: `4a26a4a1e691e69696f1b593e6d9f72927e40a9a..c9b7d676755588903edff227b7d6ba3b0172cd1d`.

**Spec: CHANGES REQUIRED. Quality: CHANGES REQUIRED for the fixture evidence gates.** Two P2 findings remain. The actual crypto assertions and release FRB selection path are sound; these findings do not show a crypto regression or an incorrectly selected library in the observed run.

## Findings

### P2 — Strict runtime state is not bound to the release run

Locations: `tools/android_native_smoke/harness/integration_test/vodo_android_16k_test.dart:13`; `tools/android_native_smoke/verify_vodo_release_fixture.py:81`–`:94`.

The fixture executes crypto without checking or recording page/linker/compatibility settings. The verifier accepts only AAR, local APK and runtime log; it has no strict-state input or rejection rule. The report acknowledges pre-run observations exist only in tool transcript. The retained postcheck includes page size 16384, linker `fatal`, airplane mode and routes, but **does not include `pm.16kb.app_compat.disabled` at all**. Thus a successful run performed with compatibility enabled or different pre-run settings could satisfy this verifier. Current retained 1/1 is crypto execution evidence, not a complete strict-mode run attestation.

**Required:** add a focused runner/receipt around the actual release-member test which explicitly rejects incorrect/missing pre-run page size, linker mode and compatibility-disabled state; retain the same post-run observations, exact invocation/exit, artifact and source hashes, and the stated offline checks. Do not retroactively relabel the prior run. One focused corrected run is needed to produce the missing contemporaneous evidence, without a whole-app/native rebuild solely for this bookkeeping. If settings are changed, restore them on failure as well. Add normal/optimized offline controls where property values are semantically invalid (4096, compatibility enabled or missing), with consistent hashes so rejection is not merely a stale log digest.

### P2 — Local APK is not cryptographically bound to the installed mapped APK

Location: `tools/android_native_smoke/verify_vodo_release_fixture.py:59`–`:85`, especially the map parser at `:69`.

The verifier proves local APK member bytes equal the pinned release AAR and checks that a logged executable range lies inside that local member's ZIP range. It computes the local APK hash but never compares it with an installed-package digest. Its regular expression discards the exact installed APK pathname. The runtime log identifies `/data/app/.../base.apk`; Flutter's build/install messages identify a file path, not the installed bytes. Consequently a log from a different APK with the same relevant ZIP layout can be paired with the current local APK and pass. The present receipt cannot establish the full local-artifact → installed-artifact → mapped-process chain required for exact runtime selection evidence.

**Required:** in the same focused runner, obtain the installed synthetic package's base.apk path and SHA256, require equality with the exact produced APK, and bind the observed map path/PID to that installation. Include this receipt in verifier inputs with explicit errors, plus wrong-installed-hash/path controls. This is a missing proof edge, not evidence that the observed installation was actually wrong.

## Accepted code and bounded evidence

- The release branch initializes `vodozemac.init(stem: 'vodozemac_release_probe')` before any Vodo operation. Read actual resolved vodozemac 0.8.0 API: this passes the selected external library into generated `RustLib.init`; the account/session wrappers use that singleton. The separate symbol lookup is therefore corroborating map evidence, not a substitute for selecting the library used by crypto calls. The debug branch remains separately initialized and separately reported.
- The fixture calls real account identity getters, signature verification and deterministic signing, encrypted historical account/session unpickling, historical ciphertext decryption, continuation encrypt/decrypt and fresh-session encrypted pickle restoration. Wrong-key cases must throw after successful valid-input operations. The final success marker is reached only after these assertions.
- The copied historical vector independently hashes to `fb333c76054d891503537433db553aa25c1210581a6c96540b617e0c536d74da` and is byte equal to the official Chat synthetic fixture. Its public test key/identity are not real account data.
- The fixture-only JNI source set and renamed release probe do not alter production library selection. Report distinguishes debug ELF `9109b83…` from release member `3807e8f…`, and debug host APK from a main-app release build.
- Retained release log has PID13790, release variant, resolved account-key executable map, crypto success and `+1: All tests passed!`. The local mapping receipt retains AAR `7878472e…`, APK `389c70ee…`, release member byte equality and file range within that member. This supports the observed execution subject to the two missing bindings above.
- Parser uses explicit failures and bounded ZIP reads; no Python assertions are used as acceptance gates. Retained controls are 10 expected outcomes across normal/optimized mode. The wrong-APK mutation actually rejects on ZIP CRC, so it is corruption rejection evidence; the wrong-map and false-crypto controls exercise their intended semantic checks.
- Whole fixture audit is **13 checked / 5 non-Vodo failures**, not a whole-package pass. The report preserves this, the separate release-AAR 2/2 static result, lack of other-ABI runtime and pending main-app release acceptance.

## Queued durable evidence

Final archive is explicitly a separate group and its absence is not an additional finding in this slice. Preserve raw debug/release logs separately, all source/vector/receipt hashes, failed attempts and optimized control source/results. The current verifier requires the exact 204 MB APK; an archive containing only the AAR and receipt cannot replay that ZIP/map check after ignored cleanup. The later package must either retain the exact APK in an appropriate artifact/archive location or provide a separately reviewed sufficient durable proof/reconstruction strategy, with this limitation stated until then. Historical evidence must remain immutable.

Reviewed committed source and retained outputs only. No build, test, device execution or production-network operation was repeated; uncommitted worker changes were excluded.
