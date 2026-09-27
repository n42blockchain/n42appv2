# SQLCipher Stage3 runtime verifier fix 1

Base: `1aec1c59425a6e817625d39de350b28b48caf32a` (local Stage3 runner/verifier commit, not yet published at this point). Review: `task-16f-sqlcipher-stage3-runtime-review.md` found one P2 source-map gate and one P3 runner/verifier epoch documentation issue. This fix does not change the three retained device runs or their APKs.

## Change

- The offline verifier now requires the exact seven-entry source hash map in each historical receipt: six tracked source files at `dcedef8dc2f60bfdc2aacd389d7d6f3e81b3b055`, plus the original ignored W runner (`7983dbf36d2253437875f7775b387fc2b8f8b52b3b9a8b254880047eba7a7123`). Missing, extra, or changed entries fail before other checks.
- Two semantic controls delete all three maps or change the same fixture hash in all three maps. The README and CLI descriptions say the verifier replays only the reviewed historical epoch. Current tracked-runner output needs a separately reviewed source epoch/manifest before acceptance.

## RED and GREEN

All paths below are relative to this worktree. `W` in the path descriptions means `.superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build`.

RED with the original verifier, before the production fix:

- `python3 tools/android_native_smoke/sqlcipher_fixture_controls.py --seed-run .superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build/run-seed-strict1 --official-run .superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build/run-official-strict1 --candidate-run .superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build/run-candidate-strict1` exited 1 after the five older controls rejected correctly; `missing_all_source_maps` was wrongly accepted. Raw output: `W/fixture-controls-source-red1.log`.
- A one-off Python invocation of `check_rejected('same_wrong_source_hash', same_wrong_source_hash, 'source input identity mismatch', runs)` exited 1 because the consistently changed fixture hash was wrongly accepted. Raw output: `W/fixture-controls-source-red2.log`. This was the same control function later added to the regular suite.

GREEN with the fixed verifier; each command exited 0:

```sh
W=.superpowers/sdd/dependency-completion-20260925/task-16f-sqlcipher-build
python3 tools/android_native_smoke/verify_sqlcipher_fixture.py --seed-run "$W/run-seed-strict1" --official-run "$W/run-official-strict1" --candidate-run "$W/run-candidate-strict1"
python3 -O tools/android_native_smoke/verify_sqlcipher_fixture.py --seed-run "$W/run-seed-strict1" --official-run "$W/run-official-strict1" --candidate-run "$W/run-candidate-strict1"
python3 tools/android_native_smoke/sqlcipher_fixture_controls.py --seed-run "$W/run-seed-strict1" --official-run "$W/run-official-strict1" --candidate-run "$W/run-candidate-strict1"
python3 -O tools/android_native_smoke/sqlcipher_fixture_controls.py --seed-run "$W/run-seed-strict1" --official-run "$W/run-official-strict1" --candidate-run "$W/run-candidate-strict1"
```

The first two logs are `W/fixture-sourcefix-positive-{normal,optimized}.log`. The latter two are `W/fixture-controls-source-green-{normal,optimized}.log`; both report `7/7 semantic negative controls rejected`, including the two new source-map controls. `python3 -m py_compile` on the three touched Python files and `git diff --check` also exited 0.

No device, Flutter, native build, or full application run was repeated. The historical strict 16 KB runtime evidence remains the exact three `run-{seed,official,candidate}-strict1` directories; the package-wide and other ABI gates remain outside this bounded fixture.
