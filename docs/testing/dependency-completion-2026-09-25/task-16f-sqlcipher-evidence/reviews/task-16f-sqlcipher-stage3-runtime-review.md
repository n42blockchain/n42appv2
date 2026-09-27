# SQLCipher Stage3 runtime/runner review

Range: `dcedef8dc2f60bfdc2aacd389d7d6f3e81b3b055..1aec1c59425a6e817625d39de350b28b48caf32a`.

## Verdict

- **Spec compliance: CHANGES REQUESTED**, one P2 in the offline source-provenance gate and one P3 documentation clarification.
- **Code quality: CHANGES REQUESTED**, the same P2 plus P3 below. No further actionable defect found in the scoped increment.
- The actual retained three strict runtime results are supported by independent read-only checks below. This finding does not establish that the recorded runs used incorrect source.

## P2 — Bind the source hash map to the accepted source, not only to the other receipts

Location: `tools/android_native_smoke/verify_sqlcipher_fixture.py:170` and `:186`.

`verify_phase` returns `receipt.get('source_sha256')` without validating its type, required entries or values. `verify` then only requires the three values to equal each other. Removing this field from all three receipts yields `None == None == None`; changing the fixture hash identically in all three also satisfies the check. All other assertions are independent of that field. Consequently the verifier reports success without proving its claimed fixture/source binding. The separate `git_head` string does not validate the recorded files and cannot detect a dirty source tree.

Minimal repair: bind each receipt to the exact accepted seven-entry historical source map (six tracked inputs at dcedef8dc plus the original ignored runner), or an equivalently authenticated manifest. Reject missing, extra and changed entries explicitly. Add offline normal/optimized controls that remove all three maps and alter the same fixture hash in all three maps, requiring the intended source-provenance rejection. Preserve the historical runner identity rather than substituting the newly tracked runner. No device or native rebuild is required.

## Independently checked retained evidence

Read and hashed the three retained `installed.apk` files; each equals its in-process, pulled and device-reported identity. Parsed their SQLCipher member and ELF executable headers directly:

| Phase | APK SHA256 prefix | Native SHA256 prefix | Executable APK offset / mapped span | PID | RELRO end modulo16384 |
|---|---|---|---|---:|---:|
| seed4.10 | 2ffba104caf77a4a | bc85746647ce4ea5 | 0x5a3c000 / 4816896 | 16198 | 4096 |
| official4.19 | df5414d77be467a3 | da51355b6c455150 | 0xd4000 / 2064384 | 16392 | 4096 |
| maintained4.19 | 2a82be87b80235c9 | 9d1bb9723058f51d | 0xd4000 / 2146304 | 16621 | 0 |

The executable offsets and page-rounded spans match each phase's in-process mapping of its installed APK. Paths also agree with package-manager output. All three initial/pre/post/final snapshots report page16384, arm64/API37, fatal linker mode, compatibility disabled, airplane mode1 and empty IP route, with successful commands. Raw Flutter logs contain the single runtime receipt and 1/1 success; process IDs/nonces are distinct. Separate seed branch files are recorded and each verification phase records its corresponding updated branch.

Independently compared all six tracked source hashes in each receipt against `git show dcedef8dc:<path>` and the seventh against the retained historical runner bytes: all match. Thus the specific historical evidence has valid source binding even though the reusable verifier does not enforce it yet.

Retained normal/optimized positive outputs and five semantic-negative logs support the current implemented checks. The PID and map controls consistently mutate receipt and raw log, so their failures exercise the intended semantic gates rather than a raw-log mismatch. No tests, builds or device actions were rerun for review.

## Runner and scope

The runner rejects an existing output directory before device changes, uses the dedicated emulator and synthetic harness, clears inherited SQLCipher phase selectors, preserves application data with `--no-uninstall`, records command exits, and restores strict/offline settings in `finally`. Each invocation is a complete phase; after an interrupted database update a fresh seed may be needed rather than treating the half-finished phase as resumable. Runtime acceptance additionally requires the independent verifier; a runner receipt alone is not final evidence.

The original ignored runner and newly tracked runner differ exactly in root relocation and the added pre-load IP-route rejection. The report accurately discloses that timeline; retained historical snapshots independently show empty routes. No retrospective attribution of the new guard is accepted. The verifier is bound to the historical source epoch, so new future runs need an explicit new source identity rather than silently inheriting historical acceptance.

Both official libraries actually passed this strict synthetic runtime despite their static RELRO-end failure. This does not remove that static defect or imply a baseline crash. The published fixture plugin's 4.10 compilation versus app runtime4.19 distinction remains explicit; no production full-app, store, other ABI runtime or complete package-audit pass is claimed. Durable archiving is the next separately queued slice.

## P3 — Document the historical verifier versus current runner interface

Locations: `tools/android_native_smoke/run_sqlcipher_fixture.py:2` and `:124`; `tools/android_native_smoke/verify_sqlcipher_fixture.py:2`, `:16` and `:104`.

The runner records current repository HEAD and its own tracked source path. The verifier requires historical HEAD dcedef8dc; the P2 repair should additionally require the historical ignored runner hash/path. Therefore an otherwise successful invocation of the newly tracked runner at current HEAD cannot feed this historical verifier successfully. The generic CLI descriptions currently do not make that distinction clear.

This may legitimately remain a historical replay verifier. Make that boundary explicit in CLI/help or nearby usage documentation: the retained three runs are the accepted historical input; future runner output requires a new independently reviewed source epoch/manifest before offline acceptance. Do not relax source pins to accept arbitrary current HEAD or retrospectively relabel the old receipts. This is a documentation/interface correction and needs no new device run.
