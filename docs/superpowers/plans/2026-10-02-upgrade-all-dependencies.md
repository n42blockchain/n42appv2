# Repository Dependency Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to execute this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade every tracked third-party dependency in the repository to the newest stable version supported by its ecosystem and project platform constraints.

**Architecture:** Treat Dart/Flutter, Go, Rust, npm, and Apple native dependencies as separate batches with independent lockfiles and test commands. Preserve local package overrides, generated-code inputs, macOS/iOS deployment targets, and the configured quality gates; migrate application code only where an upgraded API requires it.

**Tech Stack:** Flutter/Dart, CocoaPods/Swift package manifests, Go modules, Cargo, npm.

**Spec:** User request: “升级全部依赖库” (2026-10-02).

## Global Constraints

- Upgrade direct and transitive dependencies, including development dependencies and tracked lockfiles.
- Prefer newest stable releases; keep declared SDK, iOS/macOS deployment, and toolchain minimums unless a dependency cannot be upgraded otherwise.
- Keep local path packages and intentional dependency overrides functional.
- Do not weaken test, analyzer, release, or coverage gates to accommodate upgrades.
- Commit each ecosystem batch separately with an English subject and the repository build-number hook applied.

## Review Focus

- Major-version API changes compile and retain existing runtime behavior.
- Lockfiles resolve reproducibly from a clean checkout.
- Plugin and override versions remain aligned across root app and local packages.
- Apple native dependency updates retain supported deployment targets and build settings.
- Upgrades do not silently remove security, signing, wallet, or platform-specific behavior.

## File Structure

- Root and local Dart manifests/locks: `pubspec.yaml`, `pubspec.lock`, `packages/**/pubspec.yaml`, `packages/**/pubspec.lock`, `plugins/**/pubspec.yaml`, and example lockfiles.
- Go manifests/locks: `backend/*/go.mod` and `backend/*/go.sum`.
- Rust manifests/lock: `rust/n42_mls/Cargo.toml` and `rust/n42_mls/Cargo.lock`.
- Chrome extension manifest/lock: `chrome-extension/package.json` and `chrome-extension/package-lock.json`.
- Apple native manifests/locks: tracked `ios/Podfile*`, `macos/Podfile*`, and plugin/example native package resolution files.
- Per-ecosystem tests and build checks remain within each ecosystem task; this plan and its execution ledger are in `docs/superpowers/plans/`.

## Tasks

### Task 1: Dart and Flutter packages

- [ ] Inventory outdated direct and transitive dependencies for the root app and every tracked local package/example.
- [ ] Upgrade constraints and locks to newest compatible stable versions, preserving local overrides and compatible SDK floors.
- [ ] Regenerate code only when the upgraded generator requires it; review generated diffs.
- [ ] Run `flutter pub get --offline`, Dart analysis, relevant package tests, and the host test suite; report the unchanged 70% gate separately.
- [ ] Commit this ecosystem as one focused change.

### Task 2: Go modules

- [ ] Upgrade dependencies in each tracked `backend/*/go.mod` module and tidy its `go.sum`.
- [ ] Run `go test ./...` and `go vet ./...` per module; resolve API migrations without changing behavior.
- [ ] Commit Go module changes separately from other ecosystems.

### Task 3: Rust module

- [ ] Upgrade `rust/n42_mls` dependencies and lockfile to newest stable versions allowed by its declared Rust/toolchain constraints.
- [ ] Run formatting, tests, and clippy for the module; preserve FFI/protocol compatibility.
- [ ] Commit Rust changes independently.

### Task 4: Chrome extension npm packages

- [ ] Compare manifest and lockfile with current stable releases; upgrade outdated entries and preserve lockfile reproducibility.
- [ ] Run clean install, available tests, lint/build, and npm audit; fix migration issues.
- [ ] If already current, record the evidence without creating a no-op commit.

### Task 5: Apple native dependencies

- [ ] Update tracked CocoaPods locks for iOS and macOS, including applicable local plugin/example projects; retain deployment targets and signing/build settings.
- [ ] Update tracked Swift package resolution files if present.
- [ ] Run `pod install --deployment` after resolution and available iOS/macOS simulator builds or project checks.
- [ ] Commit Apple native lock changes independently.

### Task 6: Whole-repository dependency and release verification

- [ ] Re-run ecosystem outdated checks and confirm no tracked dependency remains behind the newest compatible stable release.
- [ ] Run required package tests/build checks and the host coverage gate without changing thresholds.
- [ ] Record unresolved external/toolchain blockers with exact evidence; do not label them upgraded or passing.

