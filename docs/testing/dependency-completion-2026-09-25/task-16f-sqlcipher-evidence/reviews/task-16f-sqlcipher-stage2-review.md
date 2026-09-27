# Task16F.5 SQLCipher Stage2 independent integration review

## Verdict

- **Specification: PASS for maintained AAR packaging, selection and targeted compilation.**
- **Code quality: PASS.** No actionable finding in this increment.
- Reviewed `2bf7a0ca7ddea695704567367e86d905506bf438..0224b3ae14ed286d475efdfbdeec58a278f76d22` against the implementation brief and Stage2 report. No build, test, native tool or device action was rerun. Stage1 source and candidate4 guard timeline remain separately accepted.

## Exact artifact preservation

Independently read the five Maven artifacts from the final commit and checked working-tree equality. Maintained AAR is4,075,995 bytes, SHA256 `4c3a1ab35258f98c13f34775621c730fbe1e2d39c0207be110f98bf07d99c25c`; module is4,116 bytes, SHA256 `7c13b8d82148f207287e9f7fbed1e6b598b5e2f65d6276304959d7ce925ffbde`.

Compared with the pinned official4.19 AAR: identical ordered17-member inventory, exactly four JNI replacements, all13 non-native members byte-identical. Each replacement matches the accepted candidate4 ABI manifest. There is no Java/resource/manifest/notice modification hidden in repackaging.

Independently recomputed size/SHA512/SHA256/SHA1/MD5 in both API/runtime AAR file records. Those are the only semantic `.module` changes. Original attributes, Kotlin/AndroidX dependencies and auxiliary variants remain unchanged. Official POM, source JAR and javadoc JAR match bytewise, with hashes6026401a…, ff22ea95…, and63551a3b… respectively.

`scripts/build_sqlcipher_android_maven.py:16–30,98–136` pins all official inputs, the exact candidate4 manifest and the four native hashes/sizes. It rejects absent/symlink inputs, unexpected ABI sets, changed input bytes and an existing destination before packaging. The ZIP routine checks duplicate/member inventory and each replacement/non-target entry; metadata code requires exactly one API and one runtime AAR variant and preserves the remainder via deep copy. All acceptance checks use explicit exceptions, so Python optimization does not remove them. The candidate-manifest pin intentionally freezes the already-reviewed artifact epoch; no retroactive guarded rebuild claim is made.

## Actual host/plugin selection

`android/build.gradle.kts:20–30` adds an exclusive local repository for exactly `net.zetetic:sqlcipher-android:4.19.0`. `packages/sqflite_sqlcipher/android/build.gradle:44` changes the plugin request from4.10 to4.19; host already requests4.19 at `android/app/build.gradle.kts:203`. No plugin Java/Dart/Apple code is changed. Existing host AndroidX SQLite2.7.1 dependency remains explicit; the packaging preserves provider metadata without pretending this commit changes the existing @aar declaration semantics.

Read the actual inspection init script: it queries each project's real releaseRuntimeClasspath with a module-filtered AAR artifact view and requires exactly one result per project; it does not perform substitutions. `selected-artifacts-stage2-fixed.log` shows both :app and :sqflite_sqlcipher selecting the same tracked local AAR path and exact4c3a1ab… hash. `dependency-insight-stage2.log` shows one4.19 runtime component reached by both direct host and plugin paths. The reported earlier included-build inspection error is correctly separated from production dependency resolution.

## Retained verification and acceptance limits

- Focused packaging tests:3/3 normal and3/3 optimized pass. They cover exact replacement, unchanged non-target content and metadata dependencies, checksum updates, missing inputs/variants and wrong candidate hash. The manifest-named test actually rejects on the candidate-binary hash before the later exact-manifest check; source inspection confirms that later check is present. No independent claim of a dedicated changed-manifest mutation test is inferred.
- Additional retained controls reject altered official POM and existing output. Initial syntax-error RED and later missing-recipe RED are disclosed accurately; neither is presented as native failure.
- Targeted Gradle command succeeds in30s,691 tasks with7 executed. Plugin release Java compilation executed; app Java and AAR metadata were up-to-date. This matches the bounded report and is not fresh full-app compilation or an APK/AAB/runtime claim.

The plugin's historical encrypted4.10 database compatibility, published4.19 vs maintained4.19 Java/JNI and direct SQLite FFI behavior, correct/wrong/null keys, exports/reopen and unrelated plaintext database behavior remain the already-agreed Stage3 runtime gates. APK/native map binding, strict-device receipts, durable source/binary evidence and final package audit remain later scope. This review approves the integration increment without claiming database migration, crypto correctness or whole-app16KB completion.
