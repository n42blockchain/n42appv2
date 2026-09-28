# WalletCore API explicit main log buffer — independent controller review

PASS bounded source delta `8242168c..dff250b50561c6b8f95a997092b7a217a0041639`. Reviewed exact runner/verifier/test diff and preserved run2 JSON. No reviewer device commands or APK rebuild.

Run2 API26 really passed install/pull then has logcat clear exit1 `failed to clear the main log` (quoted main in original stderr), no start field. Strict5560 has successful start and recorded results; no API26 JNI claim. Fix changes only clear/read to explicit `-b main`, with exact argv validation and regression rejecting old clear argv. Main buffer contains fixture Log.i records; token/PID/maps/artifact/offline/page/owner checks are unchanged. Normal pubspec bump only other file.

Reviewer ran `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest tools/android_native_smoke/test_walletcore_api_runtime_gate.py -q`: six tests, OK, exit0. Writer also reports six optimized tests and postcommit source gate. Exact APK/build epoch unchanged. Run3 may proceed as a separate record; keep run1/run2 failures unchanged.
