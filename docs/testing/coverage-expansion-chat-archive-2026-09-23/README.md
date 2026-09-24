# Chat archive integrity coverage — 2026-09-23

Added real SQLite and temporary-file coverage for the Chat archive integrity service. The tests cover a Unicode quarterly export/import round trip, empty-quarter export rejection, checksum matching and mismatch, missing files, invalid gzip data, malformed JSONL records, and sorted archive listing that filters unrelated files.

The round-trip test exposed corrupted non-ASCII content: export truncated UTF-16 code units into bytes and import decoded UTF-8 bytes as individual characters. Both boundaries now use UTF-8 encoding/decoding. The regression test failed before the fix and passed afterward.

## Results

- Targeted suite: 7/7 passed.
- Full Chat suite: 6,592 passed, 1 credential-dependent skip, 0 failed.
- `archive_integrity_service.dart`: 120/121 lines, 99.1736%.
- Chat raw LCOV: 33,391/133,072 lines, 648 files, 25.0924%. The prior full Chat result was 33,271/133,071 (25.0024%); generated output and localization remain in the raw CI-style figure.
- Dart analyze: 0 errors and 0 warnings; one pre-existing `prefer_initializing_formals` info remains at the service constructor.
- Commit: `38af33fc` (`fix: preserve UTF-8 in chat archives`). This is on the Chat audit branch; the main app's Chat dependency pin was not changed.

## Artifacts

- [Full Chat LCOV](chat-full.lcov.gz)
- [Machine-readable summary and SHA-256](summary.json)

The Chat worktree's generated `coverage/lcov.info` was restored after archiving. Its two pre-existing local changes (`.flutter-plugins-dependencies` and `example/pubspec.lock`) were left untouched.
