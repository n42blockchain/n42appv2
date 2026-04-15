# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

N42 Wallet — a Flutter-based enterprise cryptocurrency wallet app (package: `n42_wallet`). Supports Android, iOS, macOS, Web, and Windows. The app includes wallet management, token swaps, DApp browser, mining (v1/v2), staking, chat (via `n42_chat` package), WalletConnect, and social auth.

## Related Repositories

- **主项目 (当前 repo)**: Flutter 钱包 App
- **n42_chat**: 聊天功能模块 (独立 Flutter package, pulled via git dependency)
- **n42-26**: N42 区块链 Rust 全节点
- **minto**: 链上储值卡 (TypeScript 全栈)
- **开始工作前确认当前目录属于哪个子项目，git remote 确认是对的 repo**

## Build & Development Commands

```bash
# First-time setup (installs git hooks for auto build-number bump)
make setup

# Install dependencies
flutter pub get

# Run in debug mode (auto-bumps build number)
make run                    # default device
make run-android            # target Android
make run-ios                # target iOS

# Static analysis (run after any code changes)
flutter analyze --no-fatal-infos

# Format code
dart format lib test

# Run tests
make test                   # unit tests (with build-number bump)
flutter test --coverage     # with coverage report
flutter test integration_test/  # integration tests

# Code generation (after modifying models, DI, freezed, or l10n)
flutter pub run build_runner build --delete-conflicting-outputs   # DI/models/freezed
flutter pub run intl_utils:generate                                # localization

# Release builds
make build-android          # APK
make build-ipa              # iOS IPA via scripts/build_ipa.sh
./scripts/prepare_android_release.sh
./scripts/prepare_ios_release.sh
```

## Architecture

### Layer Structure (`lib/`)

The app follows a layered architecture with feature-based organization:

- **`core/`** — Framework-level infrastructure shared across all features:
  - `di/` — GetIt + Riverpod dependency injection (`injection.dart` is the central DI config)
  - `providers/` — Global Riverpod providers (user auth, theme, UI state); split into `core_providers.dart` + part files (`_ui`, `_security`, `_profile`)
  - `network/` — Dio HTTP client, API base classes, retry/circuit-breaker interceptors, RPC URL configs (mainnet/testnet), MEV protection (Flashbots)
  - `wallet_sdk/` — Low-level blockchain operations (key management, signing, address derivation)
  - `passkey/` — WebAuthn Passkey support (config, credentials, platform adapter, service) for app auth and AA signing
  - `security/` — Secure storage, device security, phishing detection, transaction risk analysis, DApp security, signature decoder (human-readable)
  - `storage/` — SQLite (`app_database.dart`), SharedPreferences (`sp_util.dart`), encrypted preferences
  - `config/` — App config, API keys, RPC config, proxy config
  - `api_hub/` — Aggregated API layer with datasources and models
  - `routing/` — Deep link handling, chat SSO utils
  - `market/` — Crypto news, fear & greed index services
  - `platform/` — Platform-specific services (deep links, social auth)

- **`features/`** — Feature modules, each typically with `data/`, `domain/`, `presentation/`, `provider/`, `pages/`:
  - `wallet/` — Core wallet: create/import, send/receive, token management, transaction history, account abstraction (`aa/` with Passkey signing + social recovery), lending (Aave V3), perpetuals (Hyperliquid), custom EVM chains
  - `browser/` — DApp browser with JS bridge, WebView integration
  - `mining/`, `mining_v1/`, `mining_v2/` — Mining functionality across protocol versions
  - `wallet_connect/` — WalletConnect v2 (via `reown_walletkit`)
  - `auth/` — Authentication flows
  - `login/` — Login/signup pages
  - `staking/`, `earn/`, `airdrop/`, `loyalty/` — DeFi features
  - `bridge/` — Cross-chain bridge
  - `pay/` — Payment feature (MoonPay buy/sell, Transak off-ramp)
  - `home/` — Main tab container and settings
  - `proto/` — Protocol Buffer definitions (`.proto` files + generated `.pb.dart`)
  - `sqlite/` — Feature-level database operations
  - `notification/` — Push notifications (Firebase)

- **`shared/`** — Cross-feature abstractions:
  - `contracts/` — Feature module interfaces (`IFeatureModule`, `INavigatable`, `IRefreshable`, etc.)
  - `events/` — EventBus-based cross-feature events (`CrossFeatureEvent` subclasses)
  - `di/` — Shared service locator for inter-feature communication
  - `domain/entities/` — Shared domain entities (e.g., `WalletInfo`)

- **`data/models/`** — Legacy shared data models (e.g., `UserInfo`)
- **`presentation/themes/`** — Theme configuration and adapters
- **`generated/`** — Auto-generated l10n code (do NOT edit manually)
- **`l10n/`** — Localization ARB files (25+ languages)

### State Management

**Dual system (migration in progress)**:
- **Riverpod** (primary, preferred) — Global `ProviderContainer` in `main.dart`; providers in `core/providers/` and per-feature `providers/` directories
- **GetIt** (secondary) — Service locator for singleton services, configured in `core/di/injection.dart`
- Legacy `Application` class (`application.dart`) bridges both systems — marked `@Deprecated`

### Cross-Feature Communication

Features communicate through:
1. **EventBus** — `CrossFeatureEvent` subclasses in `shared/events/`
2. **Shared service interfaces** — `IWalletService`, `IMiningService` in `shared/domain/services/`
3. **Riverpod providers** — Shared state via global `ProviderContainer`

### Local Dependencies

- `packages/n42_jmt_verify/` — JMT verification package
- `packages/n42_chat/` — Chat package (also available via git)
- `plugins/flutter_mining/` — Native mining plugin (v1)
- `packages/webview_flutter_wkwebview/` — Custom WebView fork
- `chrome-extension/` — Chrome browser extension (Manifest V3, React/TypeScript, independent build with `npm run build`)

### Backend

- `backend/swap/` — Go-based swap monitoring service (Dockerfile, REST API)

## Git Operations

- **提交模板**: `GIT_COMMITTER_NAME="Nyxen" GIT_COMMITTER_EMAIL="40690755+MiraWells@users.noreply.github.com" git commit --author="Nyxen <40690755+MiraWells@users.noreply.github.com>" -m "message"`
- **重要**: 所有 git 提交不要包含 "Claude" 或 "Co-Authored-By: Claude" 等字样
- Commit style: Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`)
- Pre-commit hook auto-bumps build number in `pubspec.yaml` (installed via `make setup`)
- Push 到 Gitee 时可能触发邮箱隐藏拒绝错误，Push 失败时立即重写 commit author 信息

## Key Conventions

- Generated files (`*.g.dart`, `*.freezed.dart`, `lib/generated/`) — never edit, regenerate with `build_runner`
- Analyzer excludes generated files; `constant_identifier_names` disabled (crypto symbols like BTC/ETH)
- Lint config: `package:flutter_lints/flutter.yaml` base
- New features go under `lib/features/<feature>/` with parallel tests in `test/features/<feature>/`
- Prefer Riverpod providers over GetIt for new code

## Workflow Rules

- Prefer implementation over planning. "continue" / "继续" means execute immediately
- 生成代码后立即运行 `flutter analyze`，不等用户询问
- 用户使用中文交流，始终用中文回复，除非用户切换到英文

## Session Continuation

When continuing from a previous session, immediately summarize the prior state in 2-3 sentences and begin executing — do NOT re-explore the entire codebase. Ask the user to confirm the plan only if something is ambiguous.
