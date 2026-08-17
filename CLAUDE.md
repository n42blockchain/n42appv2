# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

N42 Wallet — a Flutter-based enterprise cryptocurrency wallet app (package: `n42_wallet`). Supports Android, iOS, macOS, Web, and Windows.

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

Layered architecture with feature-based organization. The directory layout is
discoverable with `ls lib/` — the notes below are only what the code does NOT
tell you on its own.

- **`core/`**:
  - `di/` — Composition root (`injection.dart`). No longer uses GetIt — the
    service registry is plain module-level state in `core/providers/service_providers.dart`.
  - `passkey/` — WebAuthn Passkey for app auth. AA-side Passkey signing
    (`features/wallet/aa/provider/passkey_signer_provider.dart`) is **designed
    but not wired** — production AA signing currently goes through ECDSA via
    `trustdart.signMessage` in `aa_transfer_handler`.

- **`features/`** — one directory per feature:
  - `wallet/` — **自定义链注意**：真正可达的加链路径是
    `add_token/wallet_chain_add.dart`（`addWalletChain` 持久化进钱包 coinInfo）；
    曾存在的死并行系统 `pages/network/`（`CustomChainService`/
    `AddCustomChainPage`，从未有导航入口）已于 2026-08-15 删除；
    如需考古见 git 历史 9713293d 与钱包竞品报告 §2.3 勘误。
    Transfer is dispatched through `api/sender/sender_factory.dart` →
    `ChainSender` implementations keyed by `blockchainType`; per-chain read
    APIs live under `api/chain_api/`, where the Cosmos-family chains share
    `CosmosChainApi` as a LCD REST base.
  - `mining/`, `mining_v1/`, `mining_v2/` — `features/mining/` is a Clean-Arch
    bridge wrapping `MiningV2Provider` (via `miningRepositoryProvider`).
    **Both v1 and v2 are live**: a user-facing switch in
    `setting_home_page.dart` (`miningUseV2Provider`) selects which page
    the home tab renders. New mining features go into v2 only; v1 is
    maintenance-only until the product decision to remove the switch
    (tracked in `docs/CLEANUP_PLAN.md` stage 5).
  - `auth/` — Login state is read/written through `AppGlobals.userInfo` and
    `currentUserProvider` (a never-wired `IAuthService`/`AuthServiceImpl` pair
    was removed in 2026-06 cleanup; recover from git history if a service
    abstraction is ever needed).

- **`shared/`** — cross-feature abstractions (entities, service interfaces,
  EventBus events, shared widgets). A zero-implementor `contracts/` interface
  set and its `FeatureInitializer` were removed in the 2026-06 cleanup — see
  `docs/CLEANUP_PLAN.md`; recover from git history if a module-system
  bootstrap is revived.

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

- `packages/n42_jmt_verify/` — JMT verification package. **Standalone; NOT
  referenced by the app** (absent from root pubspec.yaml, zero imports in
  `lib/` as of 2026-07) — has its own tests only.
- `packages/webview_flutter_wkwebview/` — Custom WebView fork (path dependency).
- `plugins/flutter_mining/` — Native mining plugin v1 (path dependency).
- `packages/n42_chat/` — **⚠️ vendored 构建源（2026-07 更正）**：
  `pubspec_overrides.yaml` 把 `n42_chat` 覆盖为此本地路径，**实际编译的就是这份
  副本**——改 chat 必须改这里才进构建；仅 bump `pubspec.yaml` 里的 git ref 无效。
  同步回 n42_chat git repo 时基于 `fix/push-notification-dedup` 分支（非 main）。
  审计 chat 现状也以此目录为准（git repo 的 commit 未必已同步进 vendored）。
- `chrome-extension/` — Independent Chrome MV3 extension (React/TypeScript,
  `npm run build`); not part of the Flutter build.

### Backend

- `backend/swap/` — 仓内唯一后端（Go/gin/PostgreSQL，Dockerfile 部署）：DEX 聚合
  报价（1inch/Jupiter/Uniswap）、限价单存取（非托管架构**无执行引擎**——后端无私钥
  不能代签）、交易确认监视、**价格预警**（2026-07 新增：CRUD + 60s CoinGecko 监控 +
  webhook/轮询触达）。Env 清单见 `backend/swap/README.md`。App 调用的 `api.n42.ai`
  外部七服务接口需求见 `docs/BACKEND_REQUIREMENTS.md`；全部外部 key/自建服务依赖
  见 `docs/EXTERNAL_DEPENDENCIES.md`。

### Strong-Typed Views

- `lib/features/wallet/models/coin_config_view.dart` — `CoinConfigView` is a
  typed overlay over the dynamic `CoinModel.coin` map (`coin['xxx']` accesses
  appear ~796 times across the codebase against 38 keys).
- **RULE: new or modified code MUST NOT add `coin['...']` string indexing** —
  use `cm.config.coinType` / `.decimals` / `.pathForAddrType('legacy')` etc.
  Legacy call sites are being migrated in batches per
  `docs/CLEANUP_PLAN.md` stage 4; when you touch a line that contains
  `coin['...']`, migrate that access as part of your change.

## Git Operations

- **提交模板**: `GIT_COMMITTER_NAME="Nyxen" GIT_COMMITTER_EMAIL="40690755+MiraWells@users.noreply.github.com" git commit --author="Nyxen <40690755+MiraWells@users.noreply.github.com>" -m "message"`
- **重要**: 所有 git 提交不要包含 "Claude" 或 "Co-Authored-By: Claude" 等字样
- Commit style: Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`)
- **English only**: commit messages (subject + body) and code comments are
  written in English. Conversations with the user stay in Chinese — this rule
  covers what lands in the repository, not how we talk. Applies to
  `packages/n42_chat` (vendored) and its upstream repo as well.
  History before 2026-08-17 was rewritten to English subjects; bodies of
  commits older than that may still be Chinese (intentionally left as the
  original engineering record).
- Pre-commit hook auto-bumps build number in `pubspec.yaml` (installed via `make setup`)
- Push 到 Gitee 时可能触发邮箱隐藏拒绝错误，Push 失败时立即重写 commit author 信息
- **跨机协作（Codex）**：`origin/codex-n42` 分支上的 `Codex-N42.md` 是任务书
  （派发/认领/验收/留言）；Codex 的真机测试报告落在 `docs/device-test-reports/`。
  push 前先 fetch——Codex 可能已推新提交，冲突时 rebase 到远端之上

## Key Conventions

- Generated files (`*.g.dart`, `*.freezed.dart`, `lib/generated/`) — never edit, regenerate with `build_runner`
- New features go under `lib/features/<feature>/` with parallel tests in `test/features/<feature>/`
- Prefer Riverpod providers over GetIt for new code
- **UI 一律走设计系统令牌**：`lib/core/design_system/`（AppColorTokens/AppTypography/
  AppSpacing/AppRadius/AppMotion/AppStylePresets），规范见 `docs/DESIGN_SYSTEM.md`；
  新/改 UI 不写硬编码色值/字号/间距/圆角；批量审查用 `/ui-review` skill

## Workflow Rules

- Prefer implementation over planning. "continue" / "继续" means execute immediately
- 生成代码后立即运行 `flutter analyze`，不等用户询问
- 用户使用中文交流，始终用中文回复，除非用户切换到英文

## Session Continuation

When continuing from a previous session, immediately summarize the prior state in 2-3 sentences and begin executing — do NOT re-explore the entire codebase. Ask the user to confirm the plan only if something is ambiguous.
