# SQLCipher Android 4.19 and strict 16 KB fixture evidence

This archive records Task16F.5's scoped native source repair, maintained Maven
selection, and three synthetic SQLCipher migration runs. It contains no
production accounts, signing material, user database, full app package, SDK
cache, or build object tree. It can be replayed offline with Python 3 and
`zstd` on the `PATH` with enough memory for its 512 MiB decode window:

```sh
python3 verify_evidence.py
python3 -O verify_evidence.py
python3 verify_evidence_controls.py
python3 -O verify_evidence_controls.py
```

The verifier checks the complete relative-path SHA-256 manifest, seven exact
historical fixture/runner source hashes, official and maintained AAR identities,
17 AAR entries with only four native changes, the four candidate native member
hashes, and the exact three installed APKs. It expands the deterministic
`artifacts/three-installed-apks.tar.zst` (96,382,614 bytes, SHA-256
`846916ccc66eeefc2178117e0371508e7db904b7fab4890355850ea03dbd70bc`)
to a temporary directory, then runs the archived final historical verifier
against the retained receipt and raw Flutter log for each phase. The temporary
APKs are removed afterward. `members.txt` lists all regular files except
`manifest.json`; the manifest also hashes this README and verifier.
The two archive controls reject a changed manifest hash and a consistently
forged source hash across all three phase receipts, even when the manifest is
updated to match the altered receipt bytes.

Reviewed source/recipe commits are `cf39240f9f6429e8bba90198146f429f0e11ad15`
and `2bf7a0ca7ddea695704567367e86d905506bf438`. Maintained AAR selection
is `0224b3ae14ed286d475efdfbdeec58a278f76d22`. The fixture source is
`dcedef8dc2f60bfdc2aacd389d7d6f3e81b3b055`; the three device runs
record that source epoch and the ignored original W runner, copied under
`source/historical/`. The tracked runner/verifier commits are
`1aec1c59425a6e817625d39de350b28b48caf32a` and
`a62e6fa7276d007313aada0e7b1bff452aeccce3`. The archived verifier
accepts only the reviewed historical epoch; new tracked-runner output needs a
new independently reviewed source manifest before acceptance.

`reports/` gives exact commands, failure history, source/build boundary and
results. `reviews/` preserves independent scoped findings and fix approval.
`source-proof/candidate4-manifest.json`, the source patch, actual candidate4
native logs, tool guard check, ELF/program comparisons and Maven selection
logs bind the maintained AAR to its reviewed candidate. Source revisions are
the pinned Android wrapper `9a5d685404489cbff14d4c46da81555de1a38787`,
SQLCipher core `c4b275a47932888216bade83aff2bbc73df0ff85`, and LibTomCrypt
`476a9579ae94f32b9ea9e2747bfb04b302370259`; this is a maintained build
candidate, not a bitwise supplier AAR reproduction. The original generated
source trees, native build objects and tool caches are omitted; the exact
source snapshot can be reconstructed from the pinned revisions and patch.

The old 4.10 seed, official 4.19, and maintained 4.19 arm64 members all loaded
and completed the focused encrypted Java/FFI migration checks on dedicated
offline emulator5560 in strict 16 KB mode. Only the maintained member has a
16 KB aligned GNU_RELRO end; the two official members' synthetic runtime
success does not remove their measured static alignment failure. This archive
does not establish whole-app APK/AAB alignment, other-ABI runtime behavior,
real user database migration, or a production deployment.
