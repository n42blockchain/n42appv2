# WalletCore API bounded launch — controller review

PASS exact `07aa285a..92174acfe9da1a730f9671cf615b841788e4a2e9`. Read runner/verifier/test delta and run4 report. No reviewer device action.

Launch removes -W and uses subprocess.run timeout20; timeout records exit124/timed_out plus retained partial stdout/stderr. Python subprocess.run terminates its own timed-out child, not the adb server/emulator. The runner rejects failed/timed-out launch; zero launch alone never proves fixture success. Existing raw nonce/PID/order/golden/native/APK/map/page/offline gates remain. Replay checks exact non-W command and timeout20/timed_out=false. Focused negative controls reject old -W/timed-out receipt and exercise TimeoutExpired byte output capture. Scope is launch timeout only, not a claim every subprocess now has a global timeout.

Reviewer ran `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest tools/android_native_smoke/test_walletcore_api_runtime_gate.py -q`: 7 tests OK, exit0. Writer reports optimized7/source gate. Same reviewed APK epoch. Run4 is preserved partial actualAPI26 JNI evidence with failed start transport, not an overall pass. Separate run5 may now proceed.
