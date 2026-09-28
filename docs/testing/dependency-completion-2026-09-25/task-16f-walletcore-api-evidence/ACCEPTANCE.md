# Bounded acceptance

- Exact APK SHA-256: `f3f627565b70b42787f15bce7cf1c8024a6c4696b916a289e196a96d6526b855`.
- Packaged ARM64 JNI SHA-256: `f2ad3625ae3e691369baaf3bede441f9b56500e5a2655b33baa0ca2866fa3a3d`.
- Fixture build epoch SHA-256: `ccc3aaf38b5e82c762fd861c5e3f8781ea2ed5b72571a4843a43e6582dcd1a39`.
- Run 5 receipt SHA-256: `a030a4847149be3b197bafbe0b45e32d5b2305b23da8d23deb777f150ed6e2a2`.
- API 37 strict 16 KB: PID 26939; API 26 4 KB: PID 8357. Both pulled
  installed APKs match the exact fixture APK, with package JNI, classloader,
  native maps, offline state, process identity, and golden/error records checked.
- Tag positive encoded SHA-256:
  `56fcd3c80cb10c4ff7026bfa583a38475700a211e21d034e747589f2259007bf`;
  transaction ID:
  `c19f410bf1d70864220e93bca20f836aaaf8cdde84a46692616e9f4480d54885`.
- App-shaped P2WSH returns `Error_not_supported`. No P2WSH algorithm, spend,
  full app release, or live payment was validated.

The independent runtime review is in `raw/reviews/runtime-review.md`. The
historical attempts and their fixes remain in `raw/`; their failure is not
relabelled as native failure or full runtime acceptance.

Historical focused logs include the RED compile, final six Java tests, six Dart
tests, exact Kotlin snippet compile and both Gradle dry-run outcomes. Four
builder and runtime gate test logs were rerun later, without a device, under
normal and optimized Python and are explicitly marked as a new source epoch.
