# Task 16F Reown source fix 1 independent review

**Result: PASS for the two requested recipe guard fixes** in `53144fe52732f76a846cf04038401684f5f822c8..4d953741bfdb6e9622d49ca8f7a76300e92d78e2`. No new blocking issue in this bounded diff. This does not claim a fresh native relink, AAR selection, app integration, or 16 KB runtime result.

## Findings resolved

1. `scripts/build_reown_wcpay_android.py:24–27,142–147,211–223` pins and checks the SHA256 of both official baseline Kotlin binding files before `out.mkdir` or Cargo. The values match the independently checked archived release inputs from the original review. The files returned by this check are the same paths compared with generated Kotlin at `:260–277`; the hashes are included in both preflight output and build manifest. `test/scripts/test_reown_wcpay_build.py:39–59` rejects mutation of either file. The retained actual preflight receipt `task-16f-reown-build/fix1-evidence-run2/receipt.json` shows official input exit 0, each mutated input exit 1 with `byte mismatch`, and no output directory created in any case.
2. `scripts/build_reown_wcpay_android.py:100–129,183–192` clears all inherited `OPENSSL_*` variables and `PERL`, sets `PERL=/usr/bin/perl` for the child, and SHA-checks that binary in preflight. I independently rehashed `/usr/bin/perl` and got the recorded `53bce3db7e095b596fa42626b55edc63e3388d7afecf45a0b1ecc5211721c812`. The environment test at `test/scripts/test_reown_wcpay_build.py:71–94` injects the known OpenSSL controls and a hostile Perl path and asserts their removal/replacement. The `fix1-evidence-run2/official.stdout` records the Perl hash and unchanged API 21, four-target recipe profile/features, and GC/max/common 16384 flags.

## Scope and evidence

I inspected the full `task-16f-reown-source-fix1-review.diff`, current source at `4d953741bfdb6e9622d49ca8f7a76300e92d78e2`, unit tests, actual preflight receipt/stdout, and the prior finding locations. Exact-range `git diff --check` is clean; tracked worktree is clean. The supplied report records six passing Python tests, `py_compile` and staged diff check; I did not repeat those successful runs or a native build. The first incomplete ad hoc harness run used a wrong filename alias and is accurately distinguished from the corrected completed receipt.

The earlier four candidate `.so` files and corrected bindgen byte comparisons predate these new guards. Their static evidence remains as reviewed; only a later end-to-end guarded rebuild can demonstrate the final script's full native output, and subsequent AAR/Gradle/runtime checks are separately pending.
