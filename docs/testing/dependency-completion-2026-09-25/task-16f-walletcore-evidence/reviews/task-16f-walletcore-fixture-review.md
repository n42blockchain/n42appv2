# Wallet Core synthetic fixture source review

Reviewed app range `89e214c2..0af4663d` on 2026-09-28 by root, independently of implementer. Scope: build recipe, Gradle/manifest/Java fixture, pinned build epoch, runner, verifier and focused test sources; report and runtime brief.

## Spec and quality

The bounded synthetic source/build stage matches the brief: exact published versus maintained AAR, identical Java/proto and app-selected Javalite, tagged HD/ETH/Bitcoin golden assertions, separate app-shaped P2WSH characterization, no production signing/accounts or INTERNET permission. Runner is restricted to emulator-5560 and binds APK/member/source/tool identities, strict/offline state, fresh process tokens, raw logcat and executable maps. No runtime pass is claimed by this review.

**Important, fix before device execution:** `member_and_executable_offsets` returns a list of tuples. `run_phase` saves that value in `member_executable_loads`; in-memory verification compares equal, but JSON serialization converts tuples to lists. A persisted receipt read by the standalone verifier will therefore fail equality with the recomputed tuples. Existing full-replay tests pass in-memory dictionaries and miss the serialization boundary. Normalize the representation and add a JSON dump/load full receipt regression, keeping wrong offsets rejected. APK source/build epoch need not change.

Gate: hold source-stage completion and device run until this finding is fixed and independently re-reviewed. No other blocking issue found in this bounded diff. Full app/API-26 behavior, source-license acceptance and real business flows remain outside this fixture gate. The valid BitcoinV2 P2PKH oracle is an acceptable tagged compiler vector alongside the separate app-shaped route; it does not claim app P2WSH correctness.
