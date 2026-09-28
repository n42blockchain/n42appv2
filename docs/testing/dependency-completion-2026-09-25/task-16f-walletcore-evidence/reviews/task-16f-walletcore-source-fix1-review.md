# Wallet Core preflight receipt fix 1 independent review

**Verdict: PASS for the bounded stale-receipt fix.** No new defect found in app `11c3e9bb165ec435f7661f1997018011c069bb74..9b8bf717cb751fcd8333950c51c2e40a2d91086c`.

The supplied exact diff matches Git (SHA-256 `19bf4fd7b865a0365697e1bef1b5c21a8699eaf8e3cf83d8b8d31624053a72b1`), and `git diff --check` is clean. Changes are limited to the receipt lifecycle guard, its focused tests, and the normal hook's `pubspec.yaml` build version.

`invalidate_receipt` runs before checking source/tool/Boost/official bytes. For an existing receipt from this pinned source/tool epoch, it unlinks the prior success before validation; a later manifest failure therefore leaves no `passed: true` file at the same output path. The command-level test and preserved replay show success, a one-byte copied-manifest mutation, second command exit 1, and `receipt_exists=False`. Both normal Python and `python3 -O` record **6/6 focused tests**, and both full actual preflight modes pass against the unchanged pinned inputs.

The guard refuses a symlink receipt, an output equal to an input manifest, or an output within the source, Boost-header or official-artifact input trees. It also refuses to unlink an existing file unless its JSON has the expected prior-success marker, source commit and tool-input SHA. The new tests confirm direct input-file, source-tree and symlink paths are not deleted. This is appropriate for the task-owned receipt path and closes the original same-epoch stale-PASS case.

Later build recipes must still check the preflight command's exit status and current pinned hashes; a receipt file alone is not proof of a new run, especially after a future pin/epoch change. This review does not extend to native generation, compilation, AAR selection or runtime. No build, device action, or broad test suite was rerun by this reviewer.
