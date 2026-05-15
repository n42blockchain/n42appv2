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

The app follows a layered architecture with feature-based organization. Top
level: `core/`, `features/`, `generated/`, `l10n/`, `main.dart`, `presentation/`,
`shared/`.

- **`core/`** — Framework-level infrastructure shared across all features:
  - `di/` — Composition root (`injection.dart`); registers wallet/mining service
    impls into the cross-feature Riverpod registry. No longer uses GetIt — the
    service registry is plain module-level state in `core/providers/service_providers.dart`.
  - `providers/` — Global Riverpod providers split across `core_providers.dart`
    (+ part files `_ui`, `_security`), `service_providers.dart` (cross-feature
    service registry: `walletServiceProvider`, `miningServiceProvider`,
    `deepLinkServiceProvider`), and `legacy_wallet_adapter.dart` (ChangeNotifier-to-Riverpod bridge).
  - `network/` — Dio HTTP client, retry/circuit-breaker interceptors, RPC URL
    configs (mainnet/testnet), MEV protection (Flashbots).
  - `wallet_sdk/` — Low-level blockchain operations (key management, signing,
    address derivation).
  - `passkey/` — WebAuthn Passkey support (config, credentials, platform
    adapter, service) for app auth. AA-side Passkey signing
    (`features/wallet/aa/provider/passkey_signer_provider.dart`) is **designed
    but not wired** — production AA signing currently goes through ECDSA via
    `trustdart.signMessage` in `aa_transfer_handler`.
  - `security/` — Secure storage, device security, phishing detection,
    transaction risk analysis, DApp security, signature decoder.
  - `storage/` — SQLite (`app_database.dart`), SharedPreferences (`sp_util.dart`),
    encrypted preferences.
  - `config/`, `api_hub/`, `routing/`, `market/`, `platform/` — see directory.

- **`features/`** — Feature modules. Each typically has its own
  `data/`, `domain/`, `presentation/`, `provider/`, `pages/`:
  - `wallet/` — Core wallet: create/import, send/receive, token management,
    transaction history, account abstraction (`aa/` with Passkey + social
    recovery), lending (Aave V3), perpetuals (Hyperliquid), custom EVM chains.
  - `wallet_connect/` — WalletConnect v2 (`reown_walletkit`), via a 3-layer
    mixin chain on `ChangeNotifier` (Connection + Session + Signing).
  - `mining/`, `mining_v1/`, `mining_v2/` — Mining protocol versions. The
    `features/mining/` layer is a Clean-Arch bridge wrapping
    `MiningV2Provider` (exposed through `miningRepositoryProvider`).
  - `browser/` — DApp browser with JS bridge, WebView integration.
  - `auth/` — Authentication flows. `IAuthService` / `AuthServiceImpl` are
    **designed but not wired** — production reads/writes login state through
    `AppGlobals.userInfo` and `currentUserProvider`.
  - `bridge/`, `staking/`, `earn/`, `hardware_wallet/` — DeFi & device features.
  - `home/`, `splash/`, `news/`, `profile/` — top-level screens.
  - `component/`, `widgets/`, `utils/` — shared UI / utility code.
  - `proto/` — Protocol Buffer definitions (`.proto` + generated `.pb.dart`).
  - `sqlite/` — Feature-level database ops.

- **`shared/`** — Cross-feature abstractions:
  - `domain/entities/` — Shared entities (`SharedWalletInfo`, `MessageModel`).
  - `domain/services/` — Service interfaces (`IWalletService`, `IMiningService`,
    `IAuthService`).
  - `events/` — EventBus-based `CrossFeatureEvent` subclasses + `EventManager`.
  - `utils/` — `wallet_connect_uri.dart` and other cross-feature helpers.
  - `widgets/` — Shared widgets (e.g., `tips_dialog_3`).
  - `contracts/` — `IFeatureModule` / `INavigatable` / `IRefreshable` /
    `IDisposable` / `IAuthenticatable` / `IDataProvider` / `IEventListener`
    interfaces. **Designed but not adopted** (zero implementors); kept as
    reference for a potential module-system bootstrap.

- **`presentation/themes/`** — Theme configuration and adapters.
- **`generated/`** — Auto-generated l10n code (do NOT edit manually).
- **`l10n/`** — Localization ARB files (25+ languages).

### State Management

**Riverpod is the single source of truth**:
- Global `ProviderContainer` is created in `main.dart` and exposed as
  `globalProviderContainer` for non-widget consumers.
- Cross-feature services (`IWalletService`, `IMiningService`, `DeepLinkService`)
  are held by `core/providers/service_providers.dart` module-level state and
  exposed via `Provider<T?>` wrappers.
- Feature-internal state still uses `ChangeNotifier` in many places (e.g.,
  `WalletActionProvider`, `MiningV2Provider`, `BrowserProvider`,
  `WalletConnectProvider`) and is exposed through Riverpod
  `ChangeNotifierProvider` bridges (`wapBridgeProvider`, `miningBridgeProvider`,
  `browserNotifierProvider`, `wcpBridgeProvider`, etc.). This is intentional —
  `ChangeNotifierProvider` is a supported Riverpod 3.x API, not transition scaffolding.
- `AppGlobals` (in `core/app/app_globals.dart`) is a static façade for legacy
  imperative paths (`AppGlobals.userInfo`, `AppGlobals.login()`,
  `AppGlobals.logout()`); new code should prefer the Riverpod providers.

### Cross-Feature Communication

Features communicate through:
1. **Riverpod providers** — `walletServiceProvider` / `miningServiceProvider` /
   `deepLinkServiceProvider` / `miningRepositoryProvider` / feature `*BridgeProvider`s.
2. **Shared service interfaces** — `IWalletService` / `IMiningService` in
   `shared/domain/services/`.
3. **EventBus** — `CrossFeatureEvent` subclasses in `shared/events/`.

### Local Dependencies

- `packages/n42_jmt_verify/` — JMT verification package (path dependency).
- `packages/webview_flutter_wkwebview/` — Custom WebView fork (path dependency).
- `plugins/flutter_mining/` — Native mining plugin v1 (path dependency).
- `packages/n42_chat/` — **Cache directory only**; the host actually resolves
  `n42_chat` via the git ref in `pubspec.yaml`
  (`github.com/n42blockchain/n42_chat`). Do not modify the cache.
- `chrome-extension/` — Independent Chrome MV3 extension (React/TypeScript,
  `npm run build`); not part of the Flutter build.

### Backend

- `backend/swap/` — Go-based swap monitoring service (Dockerfile, REST API);
  independent subproject.

### Strong-Typed Views

- `lib/features/wallet/models/coin_config_view.dart` — `CoinConfigView` is a
  typed overlay over the dynamic `CoinModel.coin` map (`coin['xxx']` accesses
  appear ~770 times across the codebase against 38 keys). New code can use
  `cm.config.coinType` / `.decimals` / `.pathForAddrType('legacy')` instead of
  raw map indexing; old call sites are unchanged.

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
