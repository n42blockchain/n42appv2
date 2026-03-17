# Repository Guidelines

## Project Structure & Module Organization
`lib/` contains the Flutter app entrypoints (`main.dart`, `application.dart`) plus shared layers: `core/`, `data/`, `domain/`, `features/`, `presentation/`, and `shared/`. Keep new feature work under `lib/features/<feature>/` and mirror the same area in `test/features/<feature>/`. Local dependencies live in `packages/n42_jmt_verify/` and `plugins/flutter_mining/`; native platform code is under `android/`, `ios/`, `macos/`, `web/`, and `windows/`. Static assets and localized resources are in `assets/`, `lib/l10n/`, and generated output in `lib/generated/`.

## Build, Test, and Development Commands
Run `flutter pub get` after dependency changes. Use `flutter run` for local development and `flutter analyze --no-fatal-infos` before opening a PR. Format with `dart format lib test`.

Common generation commands:
- `flutter pub run intl_utils:generate` regenerates localization files.
- `flutter pub run build_runner build --delete-conflicting-outputs` refreshes generated DI/model code.

Testing and release helpers:
- `flutter test --coverage` runs the main test suite and updates `coverage/lcov.info`.
- `flutter test integration_test/` runs integration tests.
- `./scripts/prepare_android_release.sh` and `./scripts/prepare_ios_release.sh` prepare signed release builds.

## Coding Style & Naming Conventions
Follow Dart defaults: 2-space indentation, trailing commas where formatter expects them, and `snake_case.dart` filenames. Prefer small feature-scoped widgets/services over large mixed files. Use descriptive Riverpod/provider/use case names such as `wallet_balance_provider.dart` or `send_transaction.dart`. Do not edit generated files in `lib/generated/`, `*.g.dart`, or `*.freezed.dart`; regenerate them instead.

## Testing Guidelines
Name tests with the `_test.dart` suffix and keep paths parallel to production code. Use `flutter_test` for unit/widget coverage, `integration_test/` for device flows, and place reusable helpers in `test/helpers/`. CI enforces coverage on the main suite, with a 70% threshold in `.github/workflows/ci.yml`; add or update tests for behavior changes, especially in `core/`, `wallet`, security, and platform integration code.

## Commit & Pull Request Guidelines
Recent history follows Conventional Commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`. Keep subjects short and imperative, for example `fix: expand market fallback list`. PRs should include a clear summary, test evidence (`flutter analyze`, relevant `flutter test` command), linked issue/task, and screenshots or recordings for UI changes. If your local hooks use `.githooks/pre-commit`, commits will auto-bump `pubspec.yaml`; include that change when relevant.

## Security & Configuration Tips
Never commit secrets or local signing files. Use the templates in `android/key.properties.template` and `android/local.properties.template`, keep real credentials out of version control, and treat keystores, API keys, and release provisioning assets as local-only.
