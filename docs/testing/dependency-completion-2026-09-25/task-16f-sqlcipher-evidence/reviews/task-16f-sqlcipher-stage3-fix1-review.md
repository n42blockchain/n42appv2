# SQLCipher Stage3 fix1 scoped review

Range: `1aec1c59425a6e817625d39de350b28b48caf32a..a62e6fa7276d007313aada0e7b1bff452aeccce3`.

## Verdict

- **Spec compliance: PASS for this scoped fix.**
- **Code quality: PASS.** No new actionable regression found.
- Original **P2 ADDRESSED**; original **P3 ADDRESSED**.

## P2: exact source provenance

`verify_sqlcipher_fixture.py:27` defines the exact seven-entry historical map; `:128` requires dictionary equality in every phase before accepting its evidence. Missing, extra or changed entries cannot satisfy the check. The explicit `require` survives optimized Python. The historical HEAD/native identity checks remain intact.

Independently parsed the pinned map from the committed verifier and compared all six tracked hashes to `git show dcedef8dc:<path>`, plus the seventh to the retained original ignored runner. All seven match. The new tracked runner is not retrospectively substituted for the historical one.

Read `fixture-controls-source-red1.log` and `red2.log`: the old verifier accepted the missing-all-maps and consistently-wrong-fixture-hash mutations, causing the control harness to fail. Both new controls alter all three receipts, which specifically defeats the former equality-only check. Retained normal and optimized GREEN logs each reject all seven controls with the intended reasons; positive logs in both modes report all three phases passed. These are behavioral RED/GREEN records, not syntax-only evidence.

## P3: runner/verifier boundary

The runner and verifier docstrings now state the frozen historical epoch, and `harness/README.md:56` explicitly says new tracked-runner output needs a separately reviewed source manifest and will be rejected by the historical verifier. Both CLI descriptions use these docstrings. The fix preserves strict source pins rather than silently accepting arbitrary current sources.

## Boundaries

This commit changes only the provenance check, its offline controls, explanatory text and normal version bump. Historical APKs, receipts, device results and fixture behavior are unchanged. The previous independent runtime findings remain valid. Durable archive review remains separately queued; this is not full application/package or other-ABI runtime acceptance.

Review used committed diff, retained logs and independent read-only source hashing. No test suite, native build or device run was repeated.
