# Chat full-suite coverage run

- Date: 2026-10-04
- Repository: `n42_chat`
- Tested commit: `b976317565e46bf2f6f65e96ac05bc8d28322047`
- Host dependency pin: `a24058de8849ab2322d743458e88c60d2f042790` (merged PR #2)
- Toolchain: Flutter 3.44.8, Dart 3.12.2
- Command: `ulimit -n 4096; flutter test --coverage --reporter compact`
- Result: exit 0; 6,742 successful test events; 3 skipped; no failures.
- LCOV: 35,451 covered / 135,533 executable lines = 26.156729%.
- LCOV SHA-256: `82e9e725b3d52edef8032ef762cd47f6ebe2a98aab90ad6bf1c06edb43ca2d7b`

The suite passes, but this whole-package LCOV result is below the requested 70% target. The host app and Chat plugin use separate coverage denominators. This result does not establish current host coverage.
