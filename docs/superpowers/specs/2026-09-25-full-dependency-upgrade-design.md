# Full Repository Dependency Upgrade

## Goal

Upgrade production dependency graphs across the N42 app repository to current stable releases, including major versions where the resulting migration can be implemented and verified. Keep the existing language and framework toolchain versions fixed so dependency changes remain attributable.

## Confirmed scope and policy

- Flutter application dependencies and active path packages: root app, `plugins/flutter_mining`, `packages/n42_jmt_verify`, `packages/audioplayers_darwin`, and `packages/webview_flutter_wkwebview`.
- Native Android dependencies and build plugins: Gradle wrapper, Android Gradle Plugin, Kotlin/Google plugins, direct Maven artifacts, and resolved Flutter plugin dependencies.
- Native Apple dependencies: iOS and macOS CocoaPods lockfiles, Swift Package Manager resolved files, and platform-specific build integration.
- All four Go modules under `backend/`.
- Rust MLS crate at `rust/n42_mls`.
- Chrome extension production and development npm dependency graphs.
- Update direct constraints/manifests and lockfiles as required; refresh transitive lockfile versions to the latest stable versions that resolve. Use no prereleases.
- Major migrations may change application call sites and generated outputs when needed. Preserve behavior and focus on compatibility, security, wallet cryptography, encrypted storage, authentication, Chat, and native plugin paths.
- Keep Flutter/Dart, Go, Rust, Node, and Java versions pinned to their existing CI/project versions. Update build plugins and platform library versions, not these language/runtime toolchains.
- Remove the `n42_chat` path override from the checked-in `pubspec_overrides.yaml`; `n42_chat` must resolve from the Git SHA declared in `pubspec.yaml`, and `pubspec.lock` must record that Git source.
- Audit the production `n42_chat` Git pin for an available compatible upstream revision. Do not edit or push the separate Chat repository. Leave `packages/n42_chat` as a cache mirror and do not use it to validate the production Chat dependency.
- Keep the checked-in `audioplayers_darwin` and `webview_flutter_wkwebview` path overrides in scope; inspect and test the path packages that fresh CI checkouts actually resolve.

## Execution phases

1. Record the clean baseline, actual resolved sources, registry resolution, tests, and known environment limitations before dependency edits. Confirm `n42_chat` resolves from the Git pin after removing its path override.
2. Upgrade the Flutter root graph and active path packages. Migrate API changes and regenerate code only through the repository's generators.
3. Upgrade Android and Apple platform dependencies/build plugins, resolving and building each platform before proceeding.
4. Upgrade each Go module independently, then run its test and vet suites.
5. Upgrade the Rust crate graph and verify formatting, tests, checks, and linting.
6. Upgrade the Chrome extension graph and verify lint, types, build, and production dependency audit.
7. Run the complete repository acceptance suite and review lockfile diffs for unintended package removals, prereleases, or version downgrades.

Keep each ecosystem's changes and verification results separately reviewable. If a package has no safe stable replacement or requires changes outside this repository, leave it pinned and record its exact blocker and follow-up owner rather than making an unverified substitution.

## Acceptance criteria

- Every in-scope manifest and lockfile resolves reproducibly from a fresh dependency install using the pinned toolchains.
- Every upgraded direct dependency is on a stable release and its major-version migration is represented in source/configuration where required.
- Flutter: `flutter analyze --no-fatal-infos`; full `flutter test --coverage`; coverage remains at or above the repository's 70% gate; debug Android APK build; iOS and macOS no-code-sign builds when required local configuration is available.
- Android and Apple native dependency resolution completes from the checked-in manifests/lockfiles. Platform build failures caused by absent signing/Firebase configuration are reported as blocked, not passed.
- Each Go module: `go test ./...` and `go vet ./...`.
- Rust: `cargo fmt --check`, `cargo test --all-targets`, `cargo check --all-targets`, and `cargo clippy --all-targets -- -D warnings`.
- Chrome extension: clean install from lockfile, `npm run lint`, `npm run type-check`, `npm run build`, and production dependency audit.
- No new analyzer, test, build, or security-audit failures relative to the captured baseline. Existing failures must be identified by exact command and kept distinct from upgrade regressions.
- Fix the 24 Flutter analyzer errors reported as the current baseline before closing the upgrade: capture the exact error list first, correct each root cause, and finish with zero analyzer errors across the repository. If the fresh baseline count differs, fix the current complete error set rather than relying on the old count.
- Final report lists upgraded package groups, migration notes, commands/results, skipped or blocked packages, and any remaining environment limitations.

## Initial inventory

- With the current tracked Chat path override, root Flutter resolution contains 217 packages; registry metadata reported newer releases for 56 direct or development dependencies. These counts must be recaptured after `n42_chat` resolves from Git. Some current caps are documented compatibility decisions and require revalidation before removal.
- `pubspec_overrides.yaml` is tracked and currently overrides `n42_chat`, `audioplayers_darwin`, and `webview_flutter_wkwebview` to local paths. A recent change added the Chat path override, so the checked-in resolution does not match the project instruction that Chat is Git-pinned and its local directory is only a mirror.
- The Chrome extension registry reported current latest releases across React and Noble/Scure packages with major-version gaps; viem and Zustand were already current at inspection time.
- Android currently pins Gradle 8.14, AGP 8.11.1, and Kotlin 2.2.20, plus explicit native artifacts in the app and mining plugin.
- Initial CocoaPods update inspection was blocked by a CDN HTTP/2 framing error; macOS CocoaPods metadata was not installed locally. Recheck in the isolated worktree before changing those locks.
- CI already defines Flutter analysis/coverage, Android/iOS builds, and tests/vet for the four Go modules. Rust and Chrome checks will be run explicitly; adding new CI jobs is outside this upgrade unless required to make the repository's existing acceptance path work.

## Out of scope

- Changing product behavior unrelated to dependency migrations.
- Updating language/framework toolchains or release signing credentials.
- Editing or publishing changes to external repositories.
- Fabricating local Firebase/signing configuration to make a build appear successful.
