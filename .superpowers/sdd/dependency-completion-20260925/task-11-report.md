# Task 11 report

Status: complete; ready for independent review.

Installed and hash verified official stable Flutter 3.47.5 / Dart 3.13.4, Node 24.21.0 LTS, Android stable SDK packages in versioned `~/.codex/toolchains` paths. No global SDK/default changes. Invocation paths and official selection/hash evidence: `docs/testing/dependency-completion-2026-09-25/toolchains.md`.

Updated root SDK floors, four existing Flutter workflow pins, existing HIG Node pin, and seven SDK-pinned package versions. All seven are increases from e54045fe9. Included approved continuation plan amendment and corrected Task12 CallKit path as requested by controller.

Unmodified manifest pub get passed, contrary to expected failure; no override added. Initial full analysis failed: 23 standalone JMT missing-resolution errors, 12 new host lint warnings, 35 infos. Raw logs retained. These remain next-task baseline work, not accepted final blockers. No product changes. Existing coverage gap remains deferred with threshold unchanged.

Checks: official archive hashes match, executable versions verified, Android install exit0, initial git diff --check excluded then-untracked evidence; controller review found raw analyzer log trailing spaces. The log is now losslessly gzip-compressed as `toolchain-baseline-analyze.log.gz` and byte-for-byte decompression was verified. No full tests rerun for declaration-only task. Root pub get after floor edits is recorded separately. Normal commit hook may increment build number.

Follow-up verification: `git diff --check --cached e54045fe9` passed with the full staged continuation diff, including evidence files. No product changes or tests were added.
