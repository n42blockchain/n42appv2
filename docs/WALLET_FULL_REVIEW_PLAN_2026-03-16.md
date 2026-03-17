# Main Wallet Full Review Plan

## Goal

对 `n42appv2` 主钱包做一次分阶段、可追踪的完整 code review，覆盖启动流程、账户与安全、网络与第三方接口、钱包核心链路、交易与资产、浏览器与桥接、挖矿、周边业务模块，以及 `plugins/flutter_mining`。本计划同时承接已有 Codex 工作，避免重复审计已经修过的 proxy 对接、explorer 兼容和依赖升级区域。

配套完整文件清单见 [WALLET_FILE_INVENTORY_2026-03-16.md](./WALLET_FILE_INVENTORY_2026-03-16.md)。

## Scope

- 审计范围：
  - `lib/` 926 个 Dart 文件
  - `test/` 138 个 Dart 文件
  - `plugins/flutter_mining/` 8 个 Dart 文件，外加平台壳层与示例工程
  - 现有审计与设计文档：`audit_results/`、`docs/`
- 非审计重点：
  - `assets/` 静态资源
  - Flutter 自动生成目录，例如 `.dart_tool/`、`build/`
  - 纯生成 proto / i18n 文件仅做“引用方式与边界”检查，不做逐行风格整改

## Existing Codex Coverage

以下范围已经被 Codex 在前几轮处理过，本次不从零开始，但会在整体验证阶段复查：

1. `n42-api-proxy` 对接修复：`core/config/proxy_config.dart`、`core/network/base_http.dart`、`core/network/request_url*.dart`
2. 钱包 explorer / transaction 兼容：`features/wallet/api/transaction_api*.dart`、`features/wallet/models/transaction/*`
3. `TRX` / `SOL` / `BTC` 历史、fallback 和 proxy 主备链路：`features/wallet/api/chain_api/trx_api.dart`、`features/wallet/api/token_view_api_trx.dart`、`features/wallet/pages/send/wallet_chain_send_trx_logic.dart`
4. 主钱包、`n42_chat`、`flutter_mining`、`n42-api-proxy` 的一轮保守依赖升级

## Review Principles

1. 先找真实行为问题，再处理结构和风格问题。
2. 每个阶段都要求“发现 -> 修复 -> 回归测试 -> 更新计划日志”闭环。
3. 对高耦合路径优先补测试，再做重构。
4. 保持主路正确，同时保留必要的 fallback 和容错能力。
5. 不回滚用户已有改动，不把无关工作混进同一批修复。

## Module Inventory Summary

### Core / Shared

- `core/*`: 89 Dart 文件
- `data/*`: 2 Dart 文件
- `domain/*`: 4 Dart 文件
- `shared/*`: 8 Dart 文件
- `main.dart` / `application.dart`: 2 Dart 文件

### Feature Modules

- `features/wallet`: 445 Dart 文件
- `features/home`: 43 Dart 文件
- `features/mining_v1`: 37 Dart 文件
- `features/mining_v2`: 36 Dart 文件
- `features/proto`: 36 Dart 文件
- `features/widgets`: 34 Dart 文件
- `features/browser`: 23 Dart 文件
- `features/hardware_wallet`: 19 Dart 文件
- `features/login`: 18 Dart 文件
- `features/staking`: 15 Dart 文件
- `features/wallet_connect`: 14 Dart 文件
- `features/loyalty`: 14 Dart 文件
- `features/bridge`: 11 Dart 文件
- `features/airdrop`: 10 Dart 文件
- `features/utils`: 10 Dart 文件
- `features/mining`: 8 Dart 文件
- 其他业务模块：`earn`、`auth`、`news`、`notification`、`pay`、`profile`、`settings`、`splash`、`sqlite`

### Tests / Plugin

- `test/core/*`: 45 Dart 文件
- `test/features/*`: 81 Dart 文件
- 其他测试入口：12 Dart 文件
- `plugins/flutter_mining`: 8 Dart 文件，122 个文件总计

## Review Order

### Phase 0: Baseline And Guardrails

- 目标：冻结审计边界，确认现有 warning / dirty state / benchmark 基线
- 关键目录：
  - `main.dart`
  - `application.dart`
  - `core/di/`
  - `core/config/`
  - `docs/`
  - `audit_results/`
- 输出：
  - 当前计划文件
  - 完整文件清单
  - 初始执行日志

### Phase 1: Bootstrap, Security, Host Integration

- 优先级：P0
- 目标：审计应用启动、配置装配、深链、宿主桥接、安全存储和鉴权边界
- 关键目录：
  - `main.dart`
  - `application.dart`
  - `core/app/`
  - `core/di/`
  - `core/config/`
  - `core/platform/`
  - `core/providers/`
  - `core/routing/`
  - `core/security/`
  - `core/storage/`
  - `features/login/`
  - `features/auth/`
- 成功标准：
  - 启动链路无明显空配置崩溃点
  - 敏感信息不被错误持久化或日志泄露
  - 深链 / 社交登录 /宿主注入具备参数校验和失败兜底
  - 至少补齐一批核心单测

### Phase 2: Network Stack, Proxy, Third-Party Boundaries

- 优先级：P0
- 目标：复核 HTTP、重试、熔断、超时、代理路由、API key 注入和第三方服务边界
- 关键目录：
  - `core/network/`
  - `core/api_hub/`
  - `core/market/`
  - `features/pay/`
  - `features/browser/api/`
  - `features/bridge/api/`
  - `features/news/api/`
- 重点关注：
  - 是否存在客户端硬编码 key
  - timeout / retry 是否会造成慢失败
  - fallback 是否会把错误状态伪装成成功

### Phase 3: Wallet Core Domain And Chain Adapters

- 优先级：P0
- 目标：审计账户、地址、余额、链配置、交易构造、签名、节点 / proxy 边界
- 关键目录：
  - `features/wallet/domain/`
  - `features/wallet/data/`
  - `features/wallet/api/chain_api/`
  - `features/wallet/api/token*/`
  - `features/wallet/utils/chain/`
  - `features/wallet/utils/transaction/`
  - `core/wallet_sdk/`
  - `core/token_discovery/`
- 重点关注：
  - 主链 / 测试链切换一致性
  - decimal / 最小单位换算
  - proxy 主路与直连 fallback 的优先级和超时

### Phase 4: Wallet UX Flows, Transactions, Assets

- 优先级：P0
- 目标：审计发送、交易历史、NFT、地址簿、Portfolio、Market、Gas、ENS、AA
- 关键目录：
  - `features/wallet/pages/send/`
  - `features/wallet/pages/transactions/`
  - `features/wallet/pages/nft/`
  - `features/wallet/pages/portfolio/`
  - `features/wallet/pages/market/`
  - `features/wallet/pages/gas/`
  - `features/wallet/pages/ens/`
  - `features/wallet/pages/aa/`
  - `features/wallet/models/transaction/`
  - `features/wallet/provider/`
- 重点关注：
  - 金额、状态、分页、确认数
  - 异常路径下的表单保留和 UI 回滚
  - pending / retry / replace-by-fee / sponsored tx 等边界

### Phase 5: DApp, Browser, WalletConnect, Bridge

- 优先级：P1
- 目标：审计 DApp 注入、签名授权、链切换、请求转发和第三方桥接
- 关键目录：
  - `features/browser/`
  - `features/wallet_connect/`
  - `features/bridge/`
  - `core/security/dapp_security_service.dart`
  - `core/security/tx_simulation_service.dart`
- 重点关注：
  - 签名请求校验
  - 多链映射错误
  - 浏览器上下文与钱包状态不同步

### Phase 6: Mining Systems And Plugin Boundary

- 优先级：P1
- 目标：审计 `features/mining*` 与 `plugins/flutter_mining` 的跨层契约
- 关键目录：
  - `features/mining/`
  - `features/mining_v1/`
  - `features/mining_v2/`
  - `plugins/flutter_mining/lib/`
  - `plugins/flutter_mining/android/`
  - `plugins/flutter_mining/ios/`
- 重点关注：
  - Flutter <-> native method channel 参数契约
  - 旧版 UI 与 v2 provider 状态漂移
  - 本地密钥、节点连接、任务状态和后台行为

### Phase 7: Home, Settings, Peripheral Business Modules

- 优先级：P2
- 目标：清理主钱包非核心但用户可见的业务路径
- 关键目录：
  - `features/home/`
  - `features/profile/`
  - `features/settings/`
  - `features/notification/`
  - `features/airdrop/`
  - `features/earn/`
  - `features/loyalty/`
  - `features/news/`
  - `features/staking/`
  - `features/hardware_wallet/`

### Phase 8: Test Gaps, Performance, Documentation

- 优先级：P2
- 目标：补回归、清理测试盲区、核对 benchmark 与审计结论
- 关键目录：
  - `test/`
  - `benchmark_results/`
  - `docs/`
  - `audit_results/`
- 输出：
  - 模块审计结论
  - 剩余风险清单
  - 建议拆分提交列表

## Batch And Commit Strategy

1. `fix(wallet-bootstrap): ...`
2. `fix(wallet-network): ...`
3. `fix(wallet-core): ...`
4. `fix(wallet-ui-flows): ...`
5. `fix(wallet-browser-wc): ...`
6. `fix(wallet-mining): ...`
7. `test(wallet): add regression coverage for ...`
8. `docs(wallet): update audit plan and findings`

## Required Verification Per Phase

- Flutter:
  - `flutter analyze <target files>`
  - `flutter test <target suites>`
  - 必要时 `flutter test test/all_tests.dart -r compact`
- Plugin:
  - `flutter test -r compact` in `plugins/flutter_mining`
  - `flutter analyze` in `plugins/flutter_mining`
- 性能或启动路径改动：
  - 核对 `benchmark_results/`

## Current Coverage Snapshot (2026-03-17)

- 当前状态：
  - Phase 1 已完成两批，启动 / 安全存储 / 登录清理主链路已复核。
  - Phase 2 已完成五批，network / proxy / browser / bridge / 第三方 fallback 主路径已复核；主钱包闭环依赖的桥接与 browser 安全边界已具备审计结论。
  - Phase 3 已完成 wallet core 收口批次，`core/wallet_sdk/`、`core/token_discovery/` 与 wallet core 主线已补齐 fail-fast / payload /回归测试。
  - Phase 4 已完成 send / transaction / wallet UX 全量收口，wallet 子页面高风险状态机、表单、fallback、详情与导入导出主线均已至少完成一轮系统审查。
  - Phase 5 已完成 WalletConnect 第一批；其余 browser / dapp 残项保留在跨模块计划中，但不再阻塞“主钱包完成”判定。
  - Phase 6 已完成 `features/mining/`、`features/mining_v1/`、`features/mining_v2/` 关键 Flutter/provider/channel/plugin 契约复核，并补跑 `plugins/flutter_mining` 独立 `flutter test` / `flutter analyze`。
  - Phase 7 已完成 loyalty / airdrop / home setting 五批，外围业务仍有若干目录未完整复核。
  - Phase 8 主钱包闭环验证已完成；跨阶段定向 `flutter test` / `flutter analyze` 与计划日志已同步收口。
- 覆盖判断：
  - 主钱包范围内的高风险主线现在已达到“完成闭环”：wallet core、wallet UX、staking / mining、plugin 契约与关键回归验证均已覆盖。
  - 仍保留的 `browser / wallet_connect / bridge / home / profile / settings / notification / earn / hardware wallet` 等残项属于跨模块后续计划，不再计入本次“主钱包完成”阻塞项。

## Remaining Execution Map

### P0: Wallet Core Residual

- `lib/core/wallet_sdk/`
  - `wallet_key_manager.dart`
  - `wallet_signer.dart`
  - `wallet_address.dart`
  - `models/*.dart`
- `lib/core/token_discovery/`
- `lib/features/wallet/api/chain_api/` 中尚未单独复核的链适配器
- `lib/features/wallet/api/token*/`
- `lib/features/wallet/utils/chain/`
- `lib/features/wallet/utils/transaction/`
- 退出标准：
  - 签名、导入导出、地址生成、token 发现、链切换与精度换算至少完成一次系统审查。
  - 对原生 / token / 测试网 / fallback 关键边界补足定向回归测试。

### P0: Wallet UX Residual

- `lib/features/wallet/pages/aa/`
- `lib/features/wallet/pages/add_token/`
- `lib/features/wallet/pages/address_book/`
- `lib/features/wallet/pages/ast_swap/`
- `lib/features/wallet/pages/batch_transfer/`
- `lib/features/wallet/pages/create_wallet/`
- `lib/features/wallet/pages/dex_swap/`
- `lib/features/wallet/pages/ens/`
- `lib/features/wallet/pages/face_matching/`
- `lib/features/wallet/pages/gas/`
- `lib/features/wallet/pages/market/`
- `lib/features/wallet/pages/nft/`
- `lib/features/wallet/pages/payment_code/`
- `lib/features/wallet/pages/portfolio/`
- `lib/features/wallet/pages/staking_btc/`
- `lib/features/wallet/pages/token_discovery/`
- `lib/features/wallet/pages/wallet_backup/`
- `lib/features/wallet/pages/wallet_manage/`
- `lib/features/wallet/provider/` 中尚未随 send / transaction 复核覆盖到的 provider
- 退出标准：
  - 每个子目录至少完成一轮“状态机 / 表单 / fallback / 错误态”检查。
  - 发现真实行为问题时，必须连同页面级或 provider 级回归一起落地。

### P1: DApp / Browser / WalletConnect Residual

- `lib/features/browser/` 中未随收藏写路径复核到的 provider / page / widget
- `lib/features/wallet_connect/` 中未随 URI 校验复核到的会话恢复、事件分发、签名请求展示
- `lib/features/bridge/` 中 `_bridge_persistence.dart`、history / UI 页面
- `lib/core/security/dapp_security_service.dart`
- `lib/core/security/tx_simulation_service.dart`
- 退出标准：
  - 非法 URI、会话恢复失败、签名拒绝、链不匹配、桥接持久化错误路径均有明确结论。

### P1: Mining Completion

- `lib/features/mining/`
- `lib/features/mining_v1/` 除 `api/mining_api.dart` 外的页面、provider、model、service
- `lib/features/mining_v2/`
- `plugins/flutter_mining/lib/`
- `plugins/flutter_mining/android/`
- `plugins/flutter_mining/ios/`
- 退出标准：
  - Flutter/provider 层与 plugin/native 层的参数契约、状态同步、网络切换、后台行为至少完成一次贯通审查。
  - plugin 侧 `flutter test` / `flutter analyze` 必须单独跑通一次。

### P2: Peripheral Residual

- `lib/features/home/` 中除 setting 已覆盖路径外的剩余页面
- `lib/features/profile/`
- `lib/features/settings/`
- `lib/features/notification/`
- `lib/features/earn/`
- `lib/features/news/`
- `lib/features/staking/`
- `lib/features/hardware_wallet/`
- 退出标准：
  - 对用户可直接触达的列表页、详情页、绑定页完成错误态与首屏状态复核。

### Phase 8: Closure

- 汇总 `test/` 里的新增回归入口并去重。
- 对已修复主路径做一次跨阶段定向验证。
- 更新 `docs/`、`audit_results/` 和跨仓状态表。
- 输出“已完成 / 未完成 / 剩余风险 / 建议后续批次”。

## Remaining Batch Plan

1. 批次 A：`core/wallet_sdk/` + 对应 `test/core/` 回归。
2. 批次 B：`core/token_discovery/`、wallet chain adapter / token adapter 残余边界。
3. 批次 C：wallet 页面残余高风险目录，优先 `address_book`、`wallet_backup`、`wallet_manage`、`add_token`、`portfolio`、`market`。
4. 批次 D：wallet 页面扩展目录，覆盖 `nft`、`gas`、`ens`、`aa`、`dex_swap`、`ast_swap`、`batch_transfer`、`staking_btc`。
5. 批次 E：browser / wallet_connect / bridge 残余目录。
6. 批次 F：`features/mining_v1/`、`features/mining_v2/`、`plugins/flutter_mining/`。
7. 批次 G：home / profile / settings / notification / news / earn / hardware wallet 残余目录。
8. 批次 H：全计划收口验证、风险清单和状态文档更新。

## Main Wallet Completion Criteria

- `features/wallet/` 主线目录、`core/wallet_sdk/`、`core/token_discovery/`、`features/mining*`、`plugins/flutter_mining/` 都至少完成一轮系统审查。
- 所有本轮修复都已补充对应定向测试或明确记录“为何无法测试”。
- 各阶段执行日志、剩余风险和跨仓覆盖状态保持一致。
- 至少完成一次跨阶段定向 `flutter analyze` 与 `flutter test` 汇总验证。

## Execution Log

### 2026-03-16

- 建立主钱包整仓审计计划。
- 完成 `lib/`、`test/`、`plugins/flutter_mining/` 的初始统计与模块分类。
- 记录已有 Codex 覆盖范围，避免重复审计 proxy / explorer / transaction fallback / dependency refresh。
- 下一步直接执行 Phase 1：启动、配置、安全、宿主接线与登录链路审计。
- Phase 1 第一批修复已完成，覆盖 `main.dart`、`core/platform/deep_link_service.dart`、`core/routing/deep_link_handler.dart`、`core/security/wallet_data_migration.dart`。
- 修复 1：deep link 日志默认改为脱敏输出，`DeepLinkData.toString()` 不再泄露 `loginToken`、`symKey`、`wcUri` 等敏感参数。
- 修复 2：chat SSO 回调新增 homeserver 规范化与校验，显式非法值不再悄悄回退默认服务器。
- 修复 3：钱包敏感字段迁移兼容旧数据里的数值型 `timestamp`，避免迁移后 secure key 与钱包 ID 脱钩。
- 修复 4：钱包迁移不再因为脏数据列表或窄泛型旧数据直接崩溃；无效条目会被保留，合法钱包继续完成迁移。
- 修复 5：迁移日志改成 debug-only 且脱敏 wallet id，避免 release 环境输出敏感标识。
- 新增回归测试：
  - `test/core/platform/deep_link_service_test.dart`
  - `test/core/routing/chat_sso_utils_test.dart`
  - `test/core/security/wallet_data_migration_test.dart`
- 验证通过：
  - `flutter test test/core/security/wallet_data_migration_test.dart test/core/platform/deep_link_service_test.dart test/core/routing/deep_link_handler_test.dart test/core/routing/chat_sso_utils_test.dart`
  - `flutter analyze lib/core/platform/deep_link_service.dart lib/core/routing/deep_link_handler.dart lib/core/routing/chat_sso_utils.dart lib/core/security/wallet_data_migration.dart lib/main.dart test/core/platform/deep_link_service_test.dart test/core/routing/chat_sso_utils_test.dart test/core/security/wallet_data_migration_test.dart`
- Phase 1 继续项：复核 `application.dart`、`core/app/app_globals.dart`、`core/storage/secure_preferences.dart`、`features/auth/` 和 `features/login/` 的启动与清理边界。
- Phase 1 第二批修复已完成，覆盖 `features/auth/data/services/auth_service_impl.dart`、`core/app/app_globals.dart`、`core/providers/core_providers.dart`、`application.dart`、`features/login/pages/login_page.dart`、`core/storage/secure_preferences.dart`。
- 修复 6：`AuthServiceImpl.verifyPassword()` 之前只要本地存在 `password` 字段就会返回 `true`，现在改为必须和存储值精确匹配。
- 修复 7：`AuthServiceImpl.logout()` 之前只删 token，不清空 secure user profile；现在统一走 `clearUserData()`。
- 修复 8：`AppGlobals.login()` / `appInitProvider` 现在会同步 token、uuid、email 和 userInfo 到 `SecureStorage`，避免 `hasCredentials()` 长期失真。
- 修复 9：旧 `Application.logout()` 不再因为过期 `AppContext` 提前返回并跳过 wallet / wallet-connect 清理。
- 修复 10：`LoginPage` 的邮箱登录结束态补了 `mounted` 守卫，并消除了两个 `BuildContext across async gap` lint。
- 修复 11：`SecurePreferences` 迁移旧明文敏感键时，现在即使 secure side 已经有值，也会删除 `SharedPreferences` 里的旧 plaintext 副本。
- 新增回归测试：
  - `test/features/auth/data/services/auth_service_impl_test.dart`
  - `test/core/storage/secure_preferences_test.dart`
- 新增验证：
  - `flutter test test/features/auth/data/services/auth_service_impl_test.dart`
  - `flutter test test/core/storage/secure_preferences_test.dart test/features/auth/data/services/auth_service_impl_test.dart test/core/security/wallet_data_migration_test.dart test/core/platform/deep_link_service_test.dart test/core/routing/deep_link_handler_test.dart test/core/routing/chat_sso_utils_test.dart`
  - `flutter analyze lib/core/storage/secure_preferences.dart lib/features/auth/data/services/auth_service_impl.dart lib/core/app/app_globals.dart lib/core/providers/core_providers.dart lib/application.dart lib/features/login/pages/login_page.dart test/core/storage/secure_preferences_test.dart test/features/auth/data/services/auth_service_impl_test.dart test/core/security/wallet_data_migration_test.dart`
- Phase 2 已开始，第一批修复落在 `core/network/api_client.dart`：
  - 自动超时重试从“所有方法”收窄为仅 `GET/HEAD/OPTIONS`，避免登录、写操作、支付等请求被重复提交。
  - 新增 `test/core/network/api_client_test.dart` 回归断言。
  - 验证通过：
    - `flutter test test/core/network/api_client_test.dart`
    - `flutter analyze lib/core/network/api_client.dart test/core/network/api_client_test.dart`
- Phase 2 第二批修复已完成，覆盖 `core/config/proxy_config.dart`、`features/login/services/social_auth_service.dart`、`features/login/widgets/social_login_buttons.dart`、`core/network/external_http.dart`、`core/storage/secure_preferences.dart`。
- 修复 12：`ProxyConfig` 统一使用规范化 base URL，并清理 `trxPath()` 的前导斜杠，避免代理路径出现双斜杠。
- 修复 13：social login 成功回调若缺失 `idToken`，现在会显式报错并中止，不再在 UI 层空指针崩溃。
- 修复 14：Google social login 的预清理 `signOut()` 改为 best-effort，不再因为一次 sign-out 失败把登录流程整体打断。
- 修复 15：`SecurePreferences` 现在会迁移并清理遗留 `miningData` 明文数据；此前该敏感键未纳入迁移列表。
- 修复 16：`ExternalHttp` 的错误日志改为 debug-only 且默认脱敏 query 参数，避免 release 日志泄露地址、token、签名参数。
- 新增回归测试：
  - `test/features/login/services/social_auth_service_test.dart`
  - `test/core/network/external_http_test.dart`
  - `test/core/config/proxy_config_test.dart` 新增路径规范化断言
  - `test/core/storage/secure_preferences_test.dart` 新增 `miningData` 迁移断言
- 新增验证：
  - `flutter test test/core/storage/secure_preferences_test.dart test/core/network/external_http_test.dart test/core/config/proxy_config_test.dart test/features/login/services/social_auth_service_test.dart`
  - `flutter analyze lib/core/storage/secure_preferences.dart lib/core/network/external_http.dart lib/core/config/proxy_config.dart lib/features/login/services/social_auth_service.dart lib/features/login/widgets/social_login_buttons.dart test/core/storage/secure_preferences_test.dart test/core/network/external_http_test.dart test/core/config/proxy_config_test.dart test/features/login/services/social_auth_service_test.dart`
- Phase 2 第三批修复已完成，覆盖 `core/api_hub/aggregators/url_security_aggregator.dart`、`core/api_hub/datasources/urlhaus_datasource.dart`、`core/api_hub/datasources/defillama_datasource.dart`、`features/pay/moonpay/moonpay.dart`。
- 修复 17：`UrlSecurityAggregator` 远端 URL 检查命中安全结果后，现在会继续做 host 级兜底检查，避免“整站已知恶意但具体 path 未收录”被误判为安全。
- 修复 18：`UrlhausDatasource` 不再把所有非 `ok` 状态都永久缓存成安全结果；只有 `no_results` 这类确定性安全响应才会缓存，避免限流或异常状态污染缓存。
- 修复 19：`DefiLlamaDatasource` 在协议列表 / 收益列表上新增 stale fallback，第三方返回无效结构或临时失败时不再把已有列表清空。
- 修复 20：`Moonpay` 页面在没有传入 `coinModel` 时也会处理 `get_moonpay_signature` 请求；此前钱包首页和总览页入口会静默丢掉签名请求，导致支付页卡死。
- 修复 21：`CoinCap`、`CoinLore`、`CoinPaprika`、`CryptoCompare`、`Urlhaus`、`Moonpay` 相关错误日志统一收敛到 debug-only，避免 release 噪音和参数泄露。
- 新增回归测试：
  - `test/core/api_hub/url_security_resilience_test.dart`
  - `test/core/api_hub/defillama_datasource_test.dart`
  - `test/features/pay/moonpay_signature_test.dart`
- 新增验证：
  - `flutter test test/features/pay/moonpay_signature_test.dart test/core/api_hub/url_security_resilience_test.dart test/core/api_hub/defillama_datasource_test.dart test/core/api_hub/market_data_aggregator_test.dart test/core/market/news_resilience_test.dart`
  - `flutter analyze lib/features/pay/moonpay/moonpay.dart test/features/pay/moonpay_signature_test.dart lib/core/api_hub/aggregators/url_security_aggregator.dart lib/core/api_hub/datasources/urlhaus_datasource.dart lib/core/api_hub/datasources/defillama_datasource.dart lib/core/api_hub/datasources/coincap_datasource.dart lib/core/api_hub/datasources/coinlore_datasource.dart lib/core/api_hub/datasources/coinpaprika_datasource.dart lib/core/api_hub/datasources/cryptocompare_price_datasource.dart test/core/api_hub/url_security_resilience_test.dart test/core/api_hub/defillama_datasource_test.dart`
- Phase 2 第四批修复已完成，覆盖 `features/bridge/api/lifi_api.dart`、`features/bridge/provider/bridge_provider.dart`、`features/bridge/provider/_bridge_execution.dart`。
- 修复 22：`BridgeProvider` 现在支持注入式 `BridgeApiClient`，桥接 provider 不再被硬编码 `LiFiApi` 卡死，后续可以直接做真实 provider 行为测试。
- 修复 23：ERC-20 approval 早退路径现在都会显式进 `error`，不再把 provider 卡在 `approving`，也不会在 approval 查询失败后继续错误地发送主交易。
- 修复 24：approval 缺少 spender、approval status 获取失败、approval transaction 获取失败、用户取消 approval 签名这些路径都会 fail-fast，并带明确错误消息。
- 修复 25：approval 轮询现在会返回确认结果；超时未到账时不会再直接继续桥接主交易。
- 新增回归测试：
  - `test/features/bridge/bridge_provider_approval_test.dart`
- 新增验证：
  - `flutter test test/features/bridge/bridge_provider_approval_test.dart test/features/bridge/bridge_provider_polling_test.dart test/features/bridge/bridge_provider_test.dart`
  - `flutter analyze lib/features/bridge/api/lifi_api.dart lib/features/bridge/provider/bridge_provider.dart lib/features/bridge/provider/_bridge_execution.dart test/features/bridge/bridge_provider_approval_test.dart test/features/bridge/bridge_provider_polling_test.dart test/features/bridge/bridge_provider_test.dart`
- Phase 2 第五批修复已完成，覆盖 `features/browser/api/browser_api.dart`、`features/browser/data/repositories/browser_repository_impl.dart`、`features/browser/pages/browser_collection*.dart`。
- 修复 26：`BrowserApi` 的历史/收藏写操作现在会真正 `await` SQLite 持久化；此前上层仓库和页面会提前返回成功，数据库异常会被静默吞掉。
- 修复 27：`BrowserRepositoryImpl.addHistory()` 现在会等待底层 insert 完成，浏览记录写失败不再被误报为成功。
- 修复 28：浏览器收藏页的新增、编辑、删除现在都会在数据库操作完成后再 toast / pop，不再出现“UI 显示成功但数据没写进去”的假成功。
- 新增回归测试：
  - `test/features/browser/browser_repository_impl_test.dart`
- 新增验证：
  - `flutter test test/features/browser/browser_repository_impl_test.dart test/features/browser/browser_entity_test.dart test/features/browser/browser_models_test.dart test/core/browser/browser_models_test.dart test/core/wallet/browser_collection_model_test.dart`
  - `flutter analyze lib/features/browser/api/browser_api.dart lib/features/browser/data/repositories/browser_repository_impl.dart lib/features/browser/pages/browser_collection.dart lib/features/browser/pages/browser_collection_info.dart lib/features/browser/pages/browser_collection_list.dart test/features/browser/browser_repository_impl_test.dart`
- Phase 3 已开始，第一批修复落在 `features/wallet/data/services/wallet_service_impl.dart`。
- 修复 29：`walletServiceProvider` 不再默认新建隔离的 `ProviderContainer`；现在会优先复用已经注册到 shared service locator 的 `IWalletService`，避免不同入口读到分叉的钱包状态。
- 修复 30：只有在独立测试 / 未初始化环境下，`walletServiceProvider` 才会退回到临时本地 `WalletServiceImpl`，并在 provider dispose 时正确回收。
- 新增回归测试：
  - `test/features/wallet/wallet_service_provider_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_service_provider_test.dart test/features/wallet/wallet_service_balance_test.dart`
  - `flutter analyze lib/features/wallet/data/services/wallet_service_impl.dart test/features/wallet/wallet_service_provider_test.dart test/features/wallet/wallet_service_balance_test.dart`
- Phase 3 第二批修复已完成，覆盖 `features/wallet/domain/usecases/get_balance.dart`。
- 修复 31：`GetBalance` 不再依赖旧的根域 `WalletRepository` / `WalletAsset`；现在改为使用 wallet feature 自己的 repository/entity，避免多链资产在用例层丢失 `chainType`。
- 修复 32：当 `GetBalanceParams.chainType` 为空时，返回结果会保留每个资产原始的 `chainType`；只有显式指定链过滤时才会统一覆盖为请求链，避免跨链资产列表被错误标成 `ethereum`。
- 新增回归测试：
  - `test/features/wallet/domain/usecases/get_balance_chain_type_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_service_provider_test.dart test/features/wallet/wallet_service_balance_test.dart test/features/wallet/domain/usecases/get_balance_chain_type_test.dart`
  - `flutter analyze lib/features/wallet/data/services/wallet_service_impl.dart lib/features/wallet/domain/usecases/get_balance.dart test/features/wallet/wallet_service_provider_test.dart test/features/wallet/domain/usecases/get_balance_chain_type_test.dart`
- Phase 3 第三批修复已完成，覆盖 `features/wallet/domain/usecases/create_wallet.dart`、`features/wallet/wallet.dart`。
- 修复 33：`CreateWallet` 不再依赖旧的根域 `WalletRepository` / `Wallet` 模型；现在直接使用 wallet feature 自己的 repository/entity，避免创建钱包链路继续在两套仓库协议之间来回映射。
- 修复 34：wallet feature barrel `features/wallet/wallet.dart` 现在导出 feature 自己的 `ChainType`，不再把旧根域枚举暴露给外部，避免调用方拿到与 repository / usecase 不一致的链类型定义。
- 新增回归测试：
  - `test/features/wallet/domain/usecases/create_wallet_usecase_test.dart`
  - `test/features/wallet/wallet_barrel_export_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/domain/usecases/create_wallet_test.dart test/features/wallet/domain/usecases/create_wallet_usecase_test.dart test/features/wallet/wallet_barrel_export_test.dart`
  - `flutter analyze lib/features/wallet/domain/usecases/create_wallet.dart lib/features/wallet/wallet.dart test/features/wallet/domain/usecases/create_wallet_usecase_test.dart test/features/wallet/wallet_barrel_export_test.dart`
- Phase 3 第四批修复已完成，覆盖 `features/wallet/domain/usecases/send_transaction.dart`。
- 修复 35：`SendTransaction` 现在会在 usecase 层 fail-fast 校验 `fromAddress`；此前空发送地址会直接下沉到仓库 / 链适配层，导致错误来源滞后且难以定位。
- 修复 36：补齐 `SendTransaction` / `EstimateGas` 的真实用例测试，验证参数透传与 sender 早退校验，替代之前只校验常量值的弱测试。
- 新增回归测试：
  - `test/features/wallet/domain/usecases/send_transaction_usecase_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/domain/usecases/send_transaction_test.dart test/features/wallet/domain/usecases/send_transaction_usecase_test.dart`
  - `flutter analyze lib/features/wallet/domain/usecases/send_transaction.dart test/features/wallet/domain/usecases/send_transaction_usecase_test.dart`
- Phase 4 第一批修复已完成，覆盖 `features/wallet/pages/send/send_utils.dart` 与多条链发送页 `maxTag()` 逻辑。
- 修复 37：发送页“Max”金额计算现在统一走 `maxTransferableAmount()`，余额不足以覆盖 gas / reserve 时会回填 `0` 而不是负数，避免输入框出现非法负值。
- 修复 38：`APT` 发送页之前在 `balance <= fee` 时会保留旧金额；现在会显式回填 `0`，不再让用户在 gas 变化后继续看到过期可发送金额。
- 新增回归测试：
  - `test/features/wallet/pages/send/send_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/pages/send/send_utils_test.dart`
  - `flutter analyze lib/features/wallet/pages/send/send_utils.dart lib/features/wallet/pages/send/wallet_chain_send_logic.dart lib/features/wallet/pages/send/wallet_chain_send_sol.dart lib/features/wallet/pages/send/wallet_chain_send_sui.dart lib/features/wallet/pages/send/wallet_chain_send_fil.dart lib/features/wallet/pages/send/wallet_chain_send_dot.dart lib/features/wallet/pages/send/wallet_chain_send_apt.dart lib/features/wallet/pages/send/wallet_chain_send_algo.dart lib/features/wallet/pages/send/wallet_chain_send_ton.dart lib/features/wallet/pages/send/wallet_chain_send_memo.dart lib/features/wallet/pages/send/wallet_chain_send_zil.dart lib/features/wallet/pages/send/wallet_chain_send_trx.dart lib/features/wallet/pages/send/wallet_chain_send_xrp.dart test/features/wallet/pages/send/send_utils_test.dart`
- Phase 4 第二批修复已完成，覆盖 `features/wallet/pages/transactions/transaction_retry.dart`、`features/wallet/pages/transactions/transaction_retry_logic.dart`。
- 修复 39：`TransactionRetry.send()` 不再被 `errorMessage` 文案状态锁死；现在只要页面仍挂载、当前不在 loading、并且交易详情已加载，就允许继续做 cancel / speed-up。
- 修复 40：交易重试页的 receipt 轮询在重建 timer 前会先取消旧 timer，避免反复触发 `timerInit()` 时叠加轮询实例。
- 新增回归测试：
  - `test/features/wallet/transaction_retry_guard_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/transaction_retry_test.dart test/features/wallet/transaction_retry_guard_test.dart`
  - `flutter analyze lib/features/wallet/pages/transactions/transaction_retry.dart test/features/wallet/transaction_retry_guard_test.dart`
- Phase 4 第三批修复已完成，覆盖 `features/wallet/pages/transactions/transaction_detail_eth.dart`、`features/wallet/pages/transactions/transaction_detail_trx.dart`。
- 修复 41：`ETH` 交易详情页在 receipt 轮询遇到临时请求错误时，现在会继续轮询，而不是直接把 pending 交易卡在半失败状态。
- 修复 42：`TRX` 交易详情页在已有上一轮交易详情的情况下，遇到临时查询错误会继续轮询；成功后也会清理旧错误文案，避免页面长期显示过期错误。
- 新增回归测试：
  - `test/features/wallet/transaction_detail_polling_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/transaction_detail_polling_test.dart`
  - `flutter analyze lib/features/wallet/pages/transactions/transaction_detail_eth.dart lib/features/wallet/pages/transactions/transaction_detail_trx.dart test/features/wallet/transaction_detail_polling_test.dart`
- Phase 4 第四批修复已完成，覆盖 `features/wallet/pages/transactions/transaction_record_helpers.dart`、`features/wallet/pages/transactions/transaction_history_list*.dart`、`features/wallet/pages/transactions/transaction_detail_*.dart`、`features/wallet/pages/transactions/transaction_retry*.dart`。
- 修复 43：交易历史列表查询 token 记录时现在会按网络选择 `contract_test` / `contract`；此前测试网 token 历史会错误拿主网合约过滤，导致记录丢失。
- 修复 44：`ETH` / `TRX` 交易详情页在本地数据库没有该 hash 记录时，现在会回退到当前 `coinModel` 构建交易上下文，避免 token 详情把合约交易误当原生转账、金额显示为 `0` 或 owner 误判。
- 修复 45：`TRX` 交易详情页现在会从远端详情补齐 `to1` / `price` / TRC20 contract 信息；直接按 hash 查询的页面不再继续显示空金额或旧收款地址。
- 修复 46：交易详情页和重试页的搜索框现在每次都会同步输入框里的最新 hash、重建 explorer 链接并重置旧轮询状态；此前 `_txHash` 只会在首次为空时读取，后续手动搜索实际上不会生效。
- 修复 47：`ETH` receipt 在后续轮询成功后会清空之前的临时错误文案，不再出现“交易已成功但页面仍展示旧错误”的残留状态。
- 新增回归测试：
  - `test/features/wallet/pages/transactions/transaction_record_helpers_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/pages/transactions/transaction_record_helpers_test.dart test/features/wallet/transaction_detail_polling_test.dart test/features/wallet/transaction_retry_guard_test.dart`
  - `flutter analyze lib/features/wallet/pages/transactions/transaction_record_helpers.dart lib/features/wallet/pages/transactions/transaction_history_list.dart lib/features/wallet/pages/transactions/transaction_detail_eth.dart lib/features/wallet/pages/transactions/transaction_detail_trx.dart lib/features/wallet/pages/transactions/transaction_retry.dart test/features/wallet/pages/transactions/transaction_record_helpers_test.dart test/features/wallet/transaction_detail_polling_test.dart test/features/wallet/transaction_retry_guard_test.dart`
- Phase 5 第一批修复已完成，覆盖 `features/wallet_connect/wallet_connect_uri.dart`、`features/wallet_connect/provider/wallet_connect_connection.dart`、`features/wallet_connect/provider/wallet_connect_provider.dart`、`features/wallet_connect/pages/wallet_connect_widgets_mixin.dart`、`features/wallet_connect/pages/wc_session_list_page.dart`、`features/browser/provider/browser_provider.dart`、`features/wallet/pages/wallet_page.dart`。
- 修复 48：WalletConnect URI 校验现在统一走 `parseWalletConnectUri()` / `isWalletConnectUriString()`；扫描页、会话列表、钱包入口和浏览器拦截不再只靠字符串 `contains()` 误判任意 URL。
- 修复 49：`WalletConnectConnection.pair()` 遇到非法或非 `wc:` URI 时现在会 fail-fast 进入错误态，不再静默 no-op。
- 修复 50：`WalletConnectProvider.viewStateDeal(WalletConnectState.loading)` 不再在 `connectInit()` / `pair()` 已经切到 `error` 后把状态覆盖回 `loading`，避免初始化失败和非法二维码被错误地伪装成持续加载。
- 新增回归测试：
  - `test/features/wallet_connect/wallet_connect_uri_test.dart`
- 新增验证：
  - `flutter test test/features/wallet_connect/wallet_connect_uri_test.dart test/features/wallet_connect/wc_provider_test.dart`
  - `flutter analyze lib/features/wallet_connect/wallet_connect_uri.dart lib/features/wallet_connect/provider/wallet_connect_connection.dart lib/features/wallet_connect/provider/wallet_connect_provider.dart lib/features/wallet_connect/pages/wallet_connect_widgets_mixin.dart lib/features/wallet_connect/pages/wc_session_list_page.dart lib/features/browser/provider/browser_provider.dart lib/features/wallet/pages/wallet_page.dart test/features/wallet_connect/wallet_connect_uri_test.dart test/features/wallet_connect/wc_provider_test.dart`
- Phase 6 第一批修复已完成，覆盖 `features/mining_v1/api/mining_api.dart`。
- 修复 51：`MiningApi.setMiningNode()` 现在会按当前挖矿网络选择 `miningContract` / `miningContract_test`；此前测试网切换 RPC 节点后仍会继续绑定主网合约，导致后续链上读取/写入跑错网络。
- 新增回归测试：
  - `test/features/mining_v1/mining_api_contract_test.dart`
- 新增验证：
  - `flutter test test/features/mining_v1/mining_api_contract_test.dart`
  - `flutter analyze lib/features/mining_v1/api/mining_api.dart test/features/mining_v1/mining_api_contract_test.dart`
- Phase 7 第一批修复已完成，覆盖 `features/loyalty/api/loyalty_api.dart`、`features/loyalty/api/_loyalty_api_extras.dart`、`features/airdrop/api/airdrop_api.dart`。
- 修复 52：`LoyaltyApi` 的 rewards/referrals/rules/referralCode fallback 现在仅在 `kDebugMode` 下返回 mock 数据；release 构建里不再把“服务不可用”伪装成空成功结果或假邀请码。
- 修复 53：`LoyaltyApi.getReferralCode()` 在非 debug 且接口失败时现在会返回明确错误消息，而不是继续回退到固定测试邀请码，避免生产环境展示无效推荐码。
- 修复 54：`AirdropApi.markAsClaimed()` / `subscribeAirdropAlert()` 现在会校验接口返回 payload 是否真实成功；空响应或缺失 `data` 不再被当作写入成功。
- 新增回归测试：
  - `test/features/loyalty/loyalty_api_fallback_test.dart`
  - `test/features/airdrop/airdrop_api_response_guard_test.dart`
- 新增验证：
  - `flutter test test/features/loyalty/loyalty_api_fallback_test.dart test/features/airdrop/airdrop_api_response_guard_test.dart test/features/loyalty/loyalty_api_test.dart`
  - `flutter analyze lib/features/loyalty/api/loyalty_api.dart lib/features/loyalty/api/_loyalty_api_extras.dart lib/features/airdrop/api/airdrop_api.dart test/features/loyalty/loyalty_api_fallback_test.dart test/features/airdrop/airdrop_api_response_guard_test.dart`
- Phase 7 第二批修复已完成，覆盖 `features/airdrop/provider/airdrop_provider.dart`、`features/loyalty/api/loyalty_api.dart`、`features/loyalty/provider/loyalty_provider.dart`、`features/loyalty/pages/loyalty_home_page*.dart`。
- 修复 55：`AirdropProvider.refresh()` 现在会根据主列表加载结果决定首屏状态；首次进入时如果空投列表请求失败且没有缓存数据，会正确进入 `error`，不再把“网络失败”渲染成正常空状态。
- 修复 56：`LoyaltyProvider.refresh()` 现在会聚合各接口的真实成功结果；当 account/tasks/history/rewards/referral 全部失败时会切到 `error` 并保留错误消息，避免积分首页被伪装成正常但全空。
- 修复 57：`LoyaltyHomePage` 现在会消费 provider 的 `error` 状态并展示重试页；同时把 rewards/referral/rules 的加载入口统一收口到 `LoyaltyApi` 实例包装方法，修复 extension 方法难以替身、测试无法覆盖的问题。
- 新增回归测试：
  - `test/features/airdrop/airdrop_provider_state_test.dart`
  - `test/features/loyalty/loyalty_provider_state_test.dart`
- 新增验证：
  - `flutter test test/features/airdrop/airdrop_api_response_guard_test.dart test/features/airdrop/airdrop_provider_state_test.dart test/features/airdrop/airdrop_eligibility_test.dart test/features/loyalty/loyalty_api_fallback_test.dart test/features/loyalty/loyalty_api_test.dart test/features/loyalty/loyalty_provider_state_test.dart`
  - `flutter analyze lib/features/airdrop/api/airdrop_api.dart lib/features/airdrop/provider/airdrop_provider.dart lib/features/loyalty/api/loyalty_api.dart lib/features/loyalty/provider/loyalty_provider.dart lib/features/loyalty/pages/loyalty_home_page.dart lib/features/loyalty/pages/loyalty_home_page_widgets.dart test/features/airdrop/airdrop_api_response_guard_test.dart test/features/airdrop/airdrop_provider_state_test.dart test/features/loyalty/loyalty_api_fallback_test.dart test/features/loyalty/loyalty_api_test.dart test/features/loyalty/loyalty_provider_state_test.dart`
- Phase 7 第三批修复已完成，覆盖 `features/home/setting/setting_share.dart`。
- 修复 58：邀请分享页的四个统计请求现在分别做异常吞吐与脏值解析；单个接口网络失败、返回空对象或把数字字段写成非法字符串时，不再让整页 `Future.wait` 失败并打断统计渲染。
- 新增回归测试：
  - `test/features/home/setting/setting_share_stats_test.dart`
- 新增验证：
  - `flutter test test/features/home/setting/setting_share_stats_test.dart`
  - `flutter analyze lib/features/home/setting/setting_share.dart test/features/home/setting/setting_share_stats_test.dart`
- Phase 7 第四批修复已完成，覆盖 `features/home/setting/change_email_page_logic.dart`。
- 修复 59：修改邮箱流程在 N42 验证成功切到 Chat 同步前，现在会显式清空旧验证码倒计时；此前会 `cancel` timer 但保留非零 `countdown`，一旦 Chat 验证码首次请求失败，`resendChatCode()` 会被永久判定为“仍在倒计时中”，导致用户无法重试。
- 新增回归测试：
  - `test/features/home/change_email_countdown_test.dart`
- 新增验证：
  - `flutter test test/features/home/change_email_countdown_test.dart test/features/home/setting/setting_share_stats_test.dart`
  - `flutter analyze lib/features/home/setting/change_email_page_logic.dart lib/features/home/setting/setting_share.dart test/features/home/change_email_countdown_test.dart test/features/home/setting/setting_share_stats_test.dart`
- Phase 7 第五批修复已完成，覆盖 `features/home/setting/security/security_google_vedification_logic.dart`。
- 修复 60：Google 验证页的邮箱验证码倒计时现在收口为单个可取消的 `Timer.periodic`，页面销毁时会显式释放 timer 与 controller；此前页面没有 `dispose`，重复进入/退出后会残留输入控制器和倒计时状态。
- 修复 61：Google 验证成功后本地安全设置现在会 `await _saveSecurity()` 再退出页面，避免本地安全开关写入与页面导航竞争。
- 新增回归测试：
  - `test/features/home/security_google_countdown_test.dart`
- 新增验证：
  - `flutter test test/features/home/change_email_countdown_test.dart test/features/home/setting/setting_share_stats_test.dart test/features/home/security_google_countdown_test.dart`
  - `flutter analyze lib/features/home/setting/change_email_page_logic.dart lib/features/home/setting/setting_share.dart lib/features/home/setting/security/security_google_vedification_logic.dart test/features/home/change_email_countdown_test.dart test/features/home/setting/setting_share_stats_test.dart test/features/home/security_google_countdown_test.dart`
- Phase 3 第五批修复已完成，覆盖 `core/wallet_sdk/wallet_address.dart`、`core/wallet_sdk/wallet_key_manager.dart`、`core/wallet_sdk/wallet_signer.dart`。
- 修复 62：`WalletAddress.generateAddress()` 现在会过滤空地址变体，并在 native 只返回空字符串时显式抛错；此前 `Trustdart` 吞错回传 `{'legacy': ''}` 时会被包装成“成功但 address 为空”的假成功结果。
- 修复 63：`WalletKeyManager.importFromKeystore()` 现在会在 `legacy` 为空时回退到首个非空地址变体，避免 iOS addressMap 只有 `segwit`/其他地址有效时被误判为 keystore 导入失败；`getKeyPair()` 也不再接受缺失公钥的畸形原生返回。
- 修复 64：`WalletSigner` 现在会对空 rawTx、无效 byte-array 签名结果、空 max value 统一 fail-fast 抛出 `TransactionException`，不再把 native 吞错后的空结果继续向上伪装成正常签名响应。
- 新增回归测试：
  - `test/core/wallet_sdk/wallet_address_test.dart`
  - `test/core/wallet_sdk/wallet_key_manager_test.dart`
  - `test/core/wallet_sdk/wallet_signer_test.dart`
- 新增验证：
  - `flutter test test/core/wallet_sdk/wallet_address_test.dart test/core/wallet_sdk/wallet_key_manager_test.dart test/core/wallet_sdk/wallet_signer_test.dart`
  - `flutter analyze --no-fatal-infos lib/core/wallet_sdk/wallet_address.dart lib/core/wallet_sdk/wallet_key_manager.dart lib/core/wallet_sdk/wallet_signer.dart test/core/wallet_sdk/wallet_address_test.dart test/core/wallet_sdk/wallet_key_manager_test.dart test/core/wallet_sdk/wallet_signer_test.dart`
- Phase 3 第六批修复已完成，覆盖 `core/token_discovery/token_discovery_service.dart`、`core/storage/sp_util.dart`、`features/wallet/pages/token_discovery/token_discovery_page.dart`、`features/wallet/pages/wallet_page.dart`。
- 修复 65：token discovery 不再把所有 tracked contract 都无脑 lower-case；EVM 合约继续大小写不敏感匹配，Solana mint 改为优先按原值匹配，并兼容旧版 lower-case 存量数据，避免已添加或已忽略的 SPL token 被重复重新发现。
- 修复 66：钱包首页构建 `knownContracts` 时不再提前破坏原始合约大小写；忽略 token 时也会按链类型选择正确的存储格式，防止 Solana 忽略列表失真。
- 修复 67：`SPUtil` 的 ignored token contract 存储现在会保留原始值并清理空白脏数据，避免存储层继续扩大大小写敏感链的地址损坏。
- 新增回归测试：
  - `test/core/token_discovery/token_discovery_service_test.dart`
  - `test/core/storage/sp_util_test.dart`
- 新增验证：
  - `flutter test test/core/token_discovery/token_discovery_service_test.dart test/core/storage/sp_util_test.dart`
  - `flutter analyze --no-fatal-infos lib/core/token_discovery/token_discovery_service.dart lib/core/storage/sp_util.dart lib/features/wallet/pages/token_discovery/token_discovery_page.dart lib/features/wallet/pages/wallet_page.dart test/core/token_discovery/token_discovery_service_test.dart test/core/storage/sp_util_test.dart`
- Phase 4 第五批修复已完成，覆盖 `features/wallet/pages/wallet_manage/keystore/import_keystore.dart`、`features/wallet/pages/wallet_manage/keystore/import_privatekey.dart`、`features/wallet/pages/wallet_manage/keystore/keystore_flow_utils.dart`。
- 修复 68：私钥导入页现在会按当前选中的链类型做地址生成和校验，不再无论用户选哪条链都拿 `CoinType.N` 去验私钥；同时补上了真实 `loading` 状态，避免重复提交导入。
- 修复 69：keystore 导入现在兼容 native 返回 `address` 为字符串或地址 map 两种结构，并在地址 / 私钥为空时统一 fail-fast；此前部分平台会在 `walletInfo['address'][walletInfo['addressType']]` 处直接崩溃，或者把空导入结果继续向下走。
- 修复 70：导入链路公共 helper 统一了“选中链 coinType 解析”“导入地址提取”“私钥字符串清洗”三类边界，减少 wallet-manage 两个入口继续分叉出不同错误行为。
- 新增回归测试：
  - `test/features/wallet/wallet_manage/keystore_flow_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_manage/keystore_flow_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/wallet_manage/keystore/keystore_flow_utils.dart lib/features/wallet/pages/wallet_manage/keystore/import_keystore.dart lib/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart test/features/wallet/wallet_manage/keystore_flow_utils_test.dart`
- Phase 4 第六批修复已完成，覆盖 `features/wallet/pages/wallet_backup/export_cloud_backup.dart`、`features/wallet/pages/create_wallet/import/import_cloud_backup.dart`、`features/wallet/utils/wallet_backup_payload.dart`、`features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage*.dart`、`features/wallet/pages/wallet_manage/keystore/keystore_export_utils.dart`。
- 修复 71：cloud backup 导出/导入现在共享同一份 payload 契约，不再只导出 `walletName/mnemonic/privateKey/timestamp` 这类残缺字段；钱包密码、链配置、观察钱包标记、主钱包状态、AA 信息和用户排序元数据都会一并进入加密备份，恢复后不会再变成残缺钱包。
- 修复 72：`ImportCloudBackup` 不再把备份里的 `walletName` 当成链 key 传给 `addImportWalletInfo()`；现在会先还原完整 `WalletInfo` 再按钱包维度导入，并对重复钱包、旧版最小备份和无法恢复的残缺 payload 做显式 skip，避免“备份文件看起来导入成功但实际一个钱包都没恢复”。
- 修复 73：keystore / private key 导出现在会对空 keystore、空私钥和无效 base64 结果 fail-fast，不再打开空白导出页或把空字符串复制到剪贴板伪装成功。
- 新增回归测试：
  - `test/features/wallet/wallet_backup_payload_test.dart`
  - `test/features/wallet/wallet_manage/keystore_export_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_backup_payload_test.dart test/features/wallet/wallet_manage/keystore_export_utils_test.dart test/features/wallet/wallet_manage/keystore_flow_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/utils/wallet_backup_payload.dart lib/features/wallet/pages/wallet_manage/keystore/keystore_export_utils.dart lib/features/wallet/pages/wallet_backup/export_cloud_backup.dart lib/features/wallet/pages/create_wallet/import/import_cloud_backup.dart lib/features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage.dart lib/features/wallet/pages/wallet_manage/keystore/one_coin_wallet_manage_widgets.dart test/features/wallet/wallet_backup_payload_test.dart test/features/wallet/wallet_manage/keystore_export_utils_test.dart test/features/wallet/wallet_manage/keystore_flow_utils_test.dart`
- Phase 4 第七批修复已完成，覆盖 `features/wallet/pages/address_book/add_address_page.dart`、`features/wallet/pages/address_book/edit_address_page.dart`、`features/wallet/pages/address_book/address_book_input_utils.dart`。
- 修复 74：address book 新增页初始化默认链时现在会同时同步 `coinName / coinFullName / coinType / coinIcon / blockchainType`，不再只改部分字段，避免首次进入后显示链和真实校验链不一致。
- 修复 75：编辑地址页把 `coinName` 与真实校验用 `coinType` 正式拆开；此前切链后把显示名写回 `coinName`，后续地址校验会拿 “Ethereum” 这类展示名而不是链类型去验证，导致合法地址被误判失败。
- 修复 76：地址簿输入统一加入 URI / 二维码归一化；扫描或粘贴 `ethereum:0x...?...`、`tron:...`、`ton://transfer/...` 一类带 scheme/query 的地址时，现在会先提取纯地址再校验，不再要求用户手工清洗。
- 新增回归测试：
  - `test/features/wallet/address_book_input_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/address_book_input_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/address_book/address_book_input_utils.dart lib/features/wallet/pages/address_book/add_address_page.dart lib/features/wallet/pages/address_book/edit_address_page.dart test/features/wallet/address_book_input_utils_test.dart`
- Phase 4 第八批修复已完成，覆盖 `features/wallet/pages/wallet_backup/backup_flow_utils.dart`、`features/wallet/pages/wallet_backup/backup_one.dart`、`features/wallet/pages/wallet_backup/backup_two.dart`、`features/wallet/pages/wallet_manage/wallet_manage.dart`、`features/wallet/provider/wallet_delete_utils.dart`、`features/wallet/provider/wallet_action_provider_wallet.dart`、`features/wallet/pages/market/market_page.dart`、`features/wallet/pages/market/market_search_utils.dart`、`features/wallet/pages/wallet_sheets.dart`、`features/wallet/pages/wallet_chain_info*.dart`、`features/wallet/pages/wallet_page.dart`。
- 修复 77：助记词备份流现在会先清洗 recovery phrase 空白并校验是否真的存在；没有助记词的钱包不再进入 `BackupOne -> BackupTwo` 后在 `mnemonic!` 处崩溃，备份入口会直接阻断并提示该钱包没有可备份的 recovery phrase。
- 修复 78：`WalletManage` 现在允许删除非当前的单链导入钱包，不再把“是否包含 N 链”错误耦合到删除按钮；删除逻辑也改成仅在钱包确实具备完整 N 链配置时才执行挖矿/验证者校验，避免单链 keystore / private-key 钱包因为缺少 `CoinType.N` 配置而无法删除。
- 修复 79：钱包管理页构建 coin list 时现在会跳过坏链配置并在页面已销毁时停止 `setState`；此前只要某一条链配置损坏或用户快速返回，`WalletManage` 就可能在异步构建中抛异常或触发销毁后更新状态。
- 修复 80：market 搜索现在带请求代次判定；快速输入、删除、重新输入时，旧请求返回结果不再覆盖最新 query，避免搜索页出现“框里是 bitcoin，列表却退回 bit/eth 旧结果”的乱序状态。
- 新增回归测试：
  - `test/features/wallet/wallet_backup/backup_flow_utils_test.dart`
  - `test/features/wallet/provider/wallet_delete_utils_test.dart`
  - `test/features/wallet/market/market_search_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_backup/backup_flow_utils_test.dart test/features/wallet/provider/wallet_delete_utils_test.dart test/features/wallet/market/market_search_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/wallet_backup/backup_flow_utils.dart lib/features/wallet/pages/wallet_backup/backup_one.dart lib/features/wallet/pages/wallet_backup/backup_two.dart lib/features/wallet/pages/market/market_search_utils.dart lib/features/wallet/pages/market/market_page.dart lib/features/wallet/pages/wallet_page.dart lib/features/wallet/pages/wallet_chain_info.dart lib/features/wallet/pages/wallet_chain_info_xrp.dart lib/features/wallet/pages/wallet_sheets.dart lib/features/wallet/pages/wallet_manage/wallet_manage.dart lib/features/wallet/provider/wallet_action_provider.dart lib/features/wallet/provider/wallet_action_provider_wallet.dart lib/features/wallet/provider/wallet_delete_utils.dart test/features/wallet/wallet_backup/backup_flow_utils_test.dart test/features/wallet/provider/wallet_delete_utils_test.dart test/features/wallet/market/market_search_utils_test.dart`
- Phase 4 第九批修复已完成，覆盖 `features/wallet/pages/wallet_manage/add_watch_wallet_page.dart`、`features/wallet/pages/wallet_manage/watch_wallet_utils.dart`。
- 修复 81：观察钱包地址校验现在收口为严格十六进制 EVM 地址规则，不再只看 `0x` 前缀和长度；`0xzz...`、截断地址等脏输入会在提交前被拦下。
- 修复 82：新增观察钱包前现在会按地址做去重匹配；同一个 watch-only 地址不再被重复导入成多份钱包记录，避免余额页和钱包列表出现重复观察钱包。
- 新增回归测试：
  - `test/features/wallet/wallet_manage/watch_wallet_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_manage/watch_wallet_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/wallet_manage/add_watch_wallet_page.dart lib/features/wallet/pages/wallet_manage/watch_wallet_utils.dart test/features/wallet/wallet_manage/watch_wallet_utils_test.dart`
- Phase 4 第十批修复已完成，覆盖 `features/wallet/api/market_api_payload_utils.dart`、`features/wallet/api/market_api.dart`、`features/wallet/models/coin_model.dart`、`features/wallet/models/coin_model_build_utils.dart`、`features/wallet/provider/watch_only_wallet_utils.dart`、`features/wallet/provider/wallet_action_provider_wallet.dart`、`features/wallet/provider/wallet_action_provider_market.dart`、`features/wallet/pages/market/market_page.dart`、`features/wallet/pages/market/market_coin_info.dart`、`features/wallet/pages/wallet_manage/wallet_list_actions.dart`。
- 修复 83：market 数据解析现在统一兼容 `List`、`{data: [...]}`、单对象三种返回形态；钱包价格刷新、watchlist、price alert 轮询和 fallback trending 不再因为后端 payload 形态切换而静默丢数据或在 provider 内部抛运行时类型错误。
- 修复 84：`CoinModel.buildWallet()` 现在会把派生路径和 `addrType` 正确分开传给 `Trustdart.generateAddress()`；此前第三个参数错误地传成了派生路径字符串，导致地址派生类型与调用契约错位。
- 修复 85：watch-only 钱包现在只保留 `BlockchainType.Ethereum` 的链配置，并会在钱包初始化时自动清理旧数据里的非 EVM 链；不再把同一个 EVM 地址硬套到 BTC / SOL / TON 等非兼容链上。
- 修复 86：钱包列表页点选非当前钱包现在只切换当前钱包索引，不会再误调用 `setMainWallet()` 把“主钱包”标记一起改掉。
- 新增回归测试：
  - `test/features/wallet/api/market_api_payload_utils_test.dart`
  - `test/features/wallet/models/coin_model_build_utils_test.dart`
  - `test/features/wallet/provider/watch_only_wallet_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/api/market_api_payload_utils_test.dart test/features/wallet/models/coin_model_build_utils_test.dart test/features/wallet/provider/watch_only_wallet_utils_test.dart test/features/wallet/wallet_manage/watch_wallet_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/api/market_api.dart lib/features/wallet/api/market_api_payload_utils.dart lib/features/wallet/models/coin_model.dart lib/features/wallet/models/coin_model_build_utils.dart lib/features/wallet/pages/market/market_coin_info.dart lib/features/wallet/pages/market/market_page.dart lib/features/wallet/pages/wallet_manage/wallet_list_actions.dart lib/features/wallet/provider/wallet_action_provider.dart lib/features/wallet/provider/wallet_action_provider_market.dart lib/features/wallet/provider/wallet_action_provider_wallet.dart lib/features/wallet/provider/watch_only_wallet_utils.dart test/features/wallet/api/market_api_payload_utils_test.dart test/features/wallet/models/coin_model_build_utils_test.dart test/features/wallet/provider/watch_only_wallet_utils_test.dart test/features/wallet/wallet_manage/watch_wallet_utils_test.dart`
- Phase 4 第十一批修复已完成，覆盖 `features/wallet/pages/wallet_manage/wallet_manage_flags_utils.dart`、`features/wallet/pages/wallet_manage/wallet_manage.dart`、`features/wallet/pages/wallet_manage/wallet_list.dart`、`features/wallet/pages/wallet_manage/wallet_list_actions.dart`、`features/wallet/pages/market/market_coin_info_helpers.dart`、`features/wallet/pages/market/market_coin_info.dart`。
- 修复 87：watch-only 钱包的密码哨兵值 `'0'` 现在不会再被管理页当成真实用户密码；观察钱包进入管理页时不再被错误要求输入密码，也不会再显示“修改密码”或“备份助记词”这类不适用入口。
- 修复 88：market 详情页刷新价格时现在会保留已有 `coin_gecko_id` / `name` / `image` 等稳定字段，并按 symbol 大小写不敏感匹配；后端只回局部价格字段时，不会再把详情页状态覆盖成残缺 coin snapshot，导致提醒/交易记录入口突然消失。
- 新增回归测试：
  - `test/features/wallet/wallet_manage/wallet_manage_flags_utils_test.dart`
  - `test/features/wallet/market/market_coin_info_helpers_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_manage/wallet_manage_flags_utils_test.dart test/features/wallet/market/market_coin_info_helpers_test.dart test/features/wallet/api/market_api_payload_utils_test.dart test/features/wallet/provider/watch_only_wallet_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/wallet_manage/wallet_manage.dart lib/features/wallet/pages/wallet_manage/wallet_list.dart lib/features/wallet/pages/wallet_manage/wallet_list_actions.dart lib/features/wallet/pages/wallet_manage/wallet_manage_flags_utils.dart lib/features/wallet/pages/market/market_coin_info.dart lib/features/wallet/pages/market/market_coin_info_helpers.dart test/features/wallet/wallet_manage/wallet_manage_flags_utils_test.dart test/features/wallet/market/market_coin_info_helpers_test.dart`
- Phase 4 第十二批修复已完成，覆盖 `features/wallet/pages/face_matching/face_wallet_utils.dart`、`features/wallet/pages/face_matching/select_wallet.dart`、`features/wallet/pages/wallet_manage/wallet_list_face_section.dart`、`features/wallet/pages/portfolio/portfolio_record_utils.dart`、`features/wallet/pages/portfolio/portfolio_page.dart`。
- 修复 89：人脸绑定钱包列表与钱包管理页的人脸校验现在只接受真正支持 N 链 legacy 地址派生的钱包；watch-only、缺少 N 链配置或缺少 legacy path 的钱包不会再进入绑定/解绑流程，也不会再在生成 legacy 地址时因为空链配置直接崩溃。
- 修复 90：portfolio 现在会保留“有余额但暂无行情价格”的持仓项；资产总览 / 饼图 / movers 只统计有估值的资产，但 holdings 列表仍展示这类真实持仓，避免用户余额存在时首屏被错误渲染成空资产状态。
- 新增回归测试：
  - `test/features/wallet/face_matching/face_wallet_utils_test.dart`
  - `test/features/wallet/portfolio/portfolio_record_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/face_matching/face_wallet_utils_test.dart test/features/wallet/portfolio/portfolio_record_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/face_matching/face_wallet_utils.dart lib/features/wallet/pages/face_matching/select_wallet.dart lib/features/wallet/pages/wallet_manage/wallet_list.dart lib/features/wallet/pages/wallet_manage/wallet_list_face_section.dart lib/features/wallet/pages/portfolio/portfolio_page.dart lib/features/wallet/pages/portfolio/portfolio_record_utils.dart test/features/wallet/face_matching/face_wallet_utils_test.dart test/features/wallet/portfolio/portfolio_record_utils_test.dart`
- Phase 4 第十三批修复已完成，覆盖 `core/storage/sp_util.dart`、`features/wallet/pages/market/market_page.dart`。
- 修复 91：market 自选列表现在在读写两端都会统一做 `trim + lowercase + 去重 + 去空串`；旧版本残留的 `ETH` / ` eth ` / 空串 / 重复 symbol 不会再把星标状态、自选列表刷新和价格请求参数打乱。
- 新增回归测试：
  - `test/core/storage/sp_util_test.dart`
- 新增验证：
  - `flutter test test/core/storage/sp_util_test.dart`
  - `flutter analyze --no-fatal-infos lib/core/storage/sp_util.dart lib/features/wallet/pages/market/market_page.dart test/core/storage/sp_util_test.dart`
- Phase 4 第十四批修复已完成，覆盖 `features/wallet/pages/wallet_manage/edit_wallet.dart`、`features/wallet/pages/wallet_manage/edit_wallet_utils.dart`。
- 修复 92：编辑钱包名称时不再允许把名字保存成空串；用户清空输入后会优先保留当前有效名称，若历史数据本身也为空则回退到 `Account{index}`，避免钱包列表和管理页再次退化成 `-` / 空名状态。
- 新增回归测试：
  - `test/features/wallet/wallet_manage/edit_wallet_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/wallet_manage/edit_wallet_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/wallet_manage/edit_wallet.dart lib/features/wallet/pages/wallet_manage/edit_wallet_utils.dart test/features/wallet/wallet_manage/edit_wallet_utils_test.dart`
- Phase 4 第十五批修复已完成，覆盖 `features/wallet/pages/market/market_price_format_utils.dart`、`features/wallet/pages/market/market_coin_info_helpers.dart`、`features/wallet/pages/market/price_alert_sheet.dart`、`features/wallet/pages/market/market_page.dart`。
- 修复 93：market 行情页、币种详情和价格提醒弹窗现在统一使用非科学计数法的小数价格 formatter；超小价格不再显示成 `1.234e-8` 这类工程计数，而会按用户可读的小数形式展示，提醒输入框也会按 8 位小数上限安全预填。
- 新增回归测试：
  - `test/features/wallet/market/market_price_format_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/market/market_price_format_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/market/market_price_format_utils.dart lib/features/wallet/pages/market/market_coin_info_helpers.dart lib/features/wallet/pages/market/price_alert_sheet.dart lib/features/wallet/pages/market/market_page.dart test/features/wallet/market/market_price_format_utils_test.dart`
- Phase 4 第十六批修复已完成，覆盖 `features/wallet/pages/market/trade_entry_sheet.dart`、`features/wallet/pages/market/trade_entry_sheet_utils.dart`、`features/wallet/pages/wallet_manage/edit_wallet_password.dart`、`features/wallet/pages/wallet_manage/edit_wallet_password_utils.dart`。
- 修复 94：portfolio trade 录入弹窗现在在保存期间禁止关闭，且 tiny price 预填会保留到 8 位小数，不再把 `0.00000001234` 这类价格直接预填成 `0.000000` 导致用户保存失败或误录入。
- 修复 95：钱包密码修改页在提交期间禁止返回，并移除了提交成功 `pop()` 后继续 `setState` 的风险路径，避免提交刚完成就触发 `setState() called after dispose()`。
- 新增回归测试：
  - `test/features/wallet/market/trade_entry_sheet_utils_test.dart`
  - `test/features/wallet/wallet_manage/edit_wallet_password_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/market/trade_entry_sheet_utils_test.dart test/features/wallet/wallet_manage/edit_wallet_password_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/market/trade_entry_sheet.dart lib/features/wallet/pages/market/trade_entry_sheet_utils.dart lib/features/wallet/pages/wallet_manage/edit_wallet_password.dart lib/features/wallet/pages/wallet_manage/edit_wallet_password_utils.dart test/features/wallet/market/trade_entry_sheet_utils_test.dart test/features/wallet/wallet_manage/edit_wallet_password_utils_test.dart`
- Phase 4 第十七批修复已完成，覆盖 `features/wallet/pages/market/price_alert_sheet.dart`、`features/wallet/pages/market/price_alert_sheet_utils.dart`。
- 修复 96：价格提醒弹窗在保存或删除期间现在同样禁止被外部关闭；如果本地持久化失败，会把 `_saving` 正常回退并保留弹窗可操作，不再出现后台已写入但 UI 结果返回 `null` 或按钮永久 loading 的状态。
- 新增回归测试：
  - `test/features/wallet/market/price_alert_sheet_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/market/price_alert_sheet_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/market/price_alert_sheet.dart lib/features/wallet/pages/market/price_alert_sheet_utils.dart test/features/wallet/market/price_alert_sheet_utils_test.dart`
- Phase 4 第十八批修复已完成，覆盖 `features/wallet/pages/market/market_coin_info.dart`、`features/wallet/pages/market/market_coin_info_helpers.dart`。
- 修复 97：market 币种详情页“官网”入口现在优先读取 CoinGecko 的 `homepage`，不再把 `official_forum_url` 误当成官网展示；无效链接也会在提取阶段被过滤，避免详情页把论坛或脏 URL 贴到官网入口。
- 新增回归测试：
  - `test/features/wallet/market/market_coin_info_helpers_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/market/market_coin_info_helpers_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/market/market_coin_info_helpers.dart lib/features/wallet/pages/market/market_coin_info.dart test/features/wallet/market/market_coin_info_helpers_test.dart`
- Phase 4 第十九批修复已完成，覆盖 `features/wallet/pages/payment_code/payment_page.dart`、`features/wallet/pages/payment_code/payment_amount_utils.dart`、`features/wallet/pages/payment_code/payment_request_utils.dart`。
- 修复 98：payment code 金额换算现在统一按 `fiat / tokenPriceUsd` 计算，不再把 USDT 脱锚或溢价场景错误地算成乘法 / 补差值，避免付款页把 100 USD 误折成错误 USDT 数量。
- 修复 99：`PaymentPage` 现在独立清洗 `amount / address / coinType / uuid` 请求参数；即使二维码未带固定金额，也会保留收款地址和链信息，不再因为 `amount == null` 把整个支付请求降成空白页。
- 修复 100：付款页切换不同 USDT 钱包时现在会重新评估所选 token 余额和原生 gas 余额，并通过代次判定丢弃旧请求结果；此前首个钱包余额不足时，切到另一个余额充足的钱包仍会残留旧错误态。
- 新增回归测试：
  - `test/features/wallet/payment_code/payment_amount_utils_test.dart`
  - `test/features/wallet/payment_code/payment_request_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/payment_code/payment_amount_utils_test.dart test/features/wallet/payment_code/payment_request_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/payment_code/payment_page.dart lib/features/wallet/pages/payment_code/payment_amount_utils.dart lib/features/wallet/pages/payment_code/payment_request_utils.dart test/features/wallet/payment_code/payment_amount_utils_test.dart test/features/wallet/payment_code/payment_request_utils_test.dart`
- Phase 4 第二十批修复已完成，覆盖 `features/wallet/pages/gas/gas_tracker_page.dart`、`features/wallet/pages/gas/gas_tracker_widgets.dart`、`features/wallet/pages/gas/gas_alert_sheet_utils.dart`、`features/wallet/pages/ens/ens_subdomain_sheet.dart`、`features/wallet/pages/ens/ens_subdomain_sheet_utils.dart`、`features/wallet/pages/ast_swap/swap_ast_home.dart`、`features/wallet/pages/ast_swap/swap_ast_price_utils.dart`。
- 修复 101：gas 提醒弹窗在保存 / 删除期间现在会阻止外部关闭，并在失败时回退 `_saving` 与展示错误；此前用户可以在保存中直接 dismiss，导致结果回调丢失或按钮永久 loading。
- 修复 102：ENS 子域名创建弹窗在提交失败时不再先 `pop()` 再报错；现在会保留弹窗和输入内容，并在提交期间禁止关闭，避免失败后用户被强制踢回上一页重新输入。
- 修复 103：AST swap 价格查询现在兼容 market payload 的多形态返回，并在缺少 `N` 或 pay coin 行情时显式失败；此前直接读取 `list['data']['data']` 和 `indexWhere == -1` 会在接口变形或缺币时抛运行时错误。
- 修复 104：AST swap 双向数量换算补了零价格 guard，不再在行情为空或 price=0 时把输入换算成 `Infinity` / `NaN`。
- 新增回归测试：
  - `test/features/wallet/gas/gas_alert_sheet_utils_test.dart`
  - `test/features/wallet/ens/ens_subdomain_sheet_utils_test.dart`
  - `test/features/wallet/ast_swap/swap_ast_price_utils_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/gas/gas_alert_sheet_utils_test.dart test/features/wallet/ens/ens_subdomain_sheet_utils_test.dart test/features/wallet/ast_swap/swap_ast_price_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/gas/gas_tracker_page.dart lib/features/wallet/pages/gas/gas_alert_sheet_utils.dart lib/features/wallet/pages/ens/ens_subdomain_sheet.dart lib/features/wallet/pages/ens/ens_subdomain_sheet_utils.dart lib/features/wallet/pages/ast_swap/swap_ast_home.dart lib/features/wallet/pages/ast_swap/swap_ast_price_utils.dart test/features/wallet/gas/gas_alert_sheet_utils_test.dart test/features/wallet/ens/ens_subdomain_sheet_utils_test.dart test/features/wallet/ast_swap/swap_ast_price_utils_test.dart`
- Phase 4 第二十一批修复已完成，覆盖 `features/wallet/pages/staking_btc/redeem.dart`、`features/wallet/pages/staking_btc/self_custody1.dart`、`features/wallet/pages/staking_btc/staking_btc_utils.dart`、`features/wallet/pages/add_token/wallet_coin_token_add2.dart`。
- 修复 105：BTC staking `Redeem` 现在会使用第一页 10 条 UTXO 查询，而不是错误的 `pageSize=1/pageNum=10` 组合；此前第一页多 UTXO 场景会直接漏拿或拿错页，导致赎回前置签名链路空转。
- 修复 106：`Redeem` 在重新拉 UTXO 和计算 gas 前会重置旧状态，并在无 UTXO 时 fail-fast，不再把空 `inputUTXO` 继续写入 `witnessValue` 触发越界。
- 修复 107：staking WebView 回传的 `lockupTime / amount` 现在都会先做容错解析；JS payload 脏值不再让 `SelfCustody1` 崩在 `double.parse(...)` 或 `lockAmount!`。
- 修复 108：自定义 token 列表页 `WalletCoinTokenAdd2` 在接口失败时会通过 `finally` 把 `load` 回退到 `finish`；此前失败后页面会永久停在 loading。
- 新增回归测试：
  - `test/features/wallet/staking_btc/staking_btc_utils_test.dart`
  - `test/features/wallet/add_token/wallet_coin_token_add2_state_test.dart`
- 新增验证：
  - `flutter test test/features/wallet/staking_btc/staking_btc_utils_test.dart test/features/wallet/add_token/wallet_coin_token_add2_state_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/staking_btc/redeem.dart lib/features/wallet/pages/staking_btc/self_custody1.dart lib/features/wallet/pages/staking_btc/staking_btc_utils.dart lib/features/wallet/pages/add_token/wallet_coin_token_add2.dart test/features/wallet/staking_btc/staking_btc_utils_test.dart test/features/wallet/add_token/wallet_coin_token_add2_state_test.dart`
- Phase 6 第二批修复已完成，覆盖 `features/mining_v1/pages/today_mining_page.dart`、`features/mining_v1/pages/today_mining_page_logic.dart`、`features/mining_v1/pages/mining_task_list.dart`、`features/mining_v1/pages/task_detail_page.dart`、`features/mining_v1/pages/today_mining_price_utils.dart`、`features/mining_v1/pages/mining_task_list_utils.dart`。
- 修复 109：today mining 页读取 AST 行情时现在统一走 market payload 兼容提取，不再直接依赖 `list['data']['data']`；后端返回形态切换后页面不再静默丢价格。
- 修复 110：mining task list 的翻页游标和任务号展示现在都支持十六进制 `blockNumber`；此前接口返回 `0x235` 时，翻页 cursor 会在 `int.parse()` 处抛错，列表标题也会显示成 `null`。
- 修复 111：task detail 页现在正确解析 RPC 返回的十六进制 `gasLimit / gasUsed / number / timestamp`，不再把这些字段渲染成空值或错误时间。
- 新增回归测试：
  - `test/features/mining_v1/today_mining_price_utils_test.dart`
  - `test/features/mining_v1/mining_task_list_utils_test.dart`
- 新增验证：
  - `flutter test test/features/mining_v1/mining_task_list_utils_test.dart test/features/mining_v1/today_mining_price_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/mining_v1/pages/today_mining_page.dart lib/features/mining_v1/pages/today_mining_page_logic.dart lib/features/mining_v1/pages/mining_task_list.dart lib/features/mining_v1/pages/task_detail_page.dart lib/features/mining_v1/pages/mining_task_list_utils.dart lib/features/mining_v1/pages/today_mining_price_utils.dart test/features/mining_v1/mining_task_list_utils_test.dart test/features/mining_v1/today_mining_price_utils_test.dart`
- Phase 8 主钱包闭环验证已完成。
- 收口结论：
  - `wallet core`、`wallet UX`、`staking_btc`、`mining_v1`、`mining_v2`、`features/mining/services` 与 `plugins/flutter_mining` 已完成一轮系统审查。
  - 对 `aa / batch_transfer / dex_swap / nft / mining_v2 provider / mining channel / flutter_mining` 的残余静态复核本轮未再发现需要立即落地的高置信行为问题。
  - `browser / wallet_connect / bridge / home / profile / settings / notification / earn / hardware wallet` 等残项保留在跨模块后续计划，不再阻塞“主钱包完成”。
- 汇总验证：
  - `flutter test test/features/wallet/market/market_coin_info_helpers_test.dart test/features/wallet/payment_code/payment_amount_utils_test.dart test/features/wallet/payment_code/payment_request_utils_test.dart test/features/wallet/gas/gas_alert_sheet_utils_test.dart test/features/wallet/ens/ens_subdomain_sheet_utils_test.dart test/features/wallet/ast_swap/swap_ast_price_utils_test.dart test/features/wallet/staking_btc/staking_btc_utils_test.dart test/features/wallet/add_token/wallet_coin_token_add2_state_test.dart test/features/mining_v1/mining_task_list_utils_test.dart test/features/mining_v1/today_mining_price_utils_test.dart`
  - `flutter analyze --no-fatal-infos lib/features/wallet/pages/market/market_coin_info.dart lib/features/wallet/pages/market/market_coin_info_helpers.dart lib/features/wallet/pages/payment_code/payment_page.dart lib/features/wallet/pages/payment_code/payment_amount_utils.dart lib/features/wallet/pages/payment_code/payment_request_utils.dart lib/features/wallet/pages/gas/gas_tracker_page.dart lib/features/wallet/pages/gas/gas_alert_sheet_utils.dart lib/features/wallet/pages/ens/ens_subdomain_sheet.dart lib/features/wallet/pages/ens/ens_subdomain_sheet_utils.dart lib/features/wallet/pages/ast_swap/swap_ast_home.dart lib/features/wallet/pages/ast_swap/swap_ast_price_utils.dart lib/features/wallet/pages/staking_btc/redeem.dart lib/features/wallet/pages/staking_btc/self_custody1.dart lib/features/wallet/pages/staking_btc/staking_btc_utils.dart lib/features/wallet/pages/add_token/wallet_coin_token_add2.dart lib/features/mining/services/mining_channel.dart lib/features/mining_v1/pages/today_mining_page.dart lib/features/mining_v1/pages/today_mining_page_logic.dart lib/features/mining_v1/pages/mining_task_list.dart lib/features/mining_v1/pages/task_detail_page.dart lib/features/mining_v1/pages/mining_task_list_utils.dart lib/features/mining_v1/pages/today_mining_price_utils.dart lib/features/mining_v2/api/mining_api.dart lib/features/mining_v2/provider/mining_v2_provider_actions.dart lib/features/mining_v2/provider/mining_v2_provider_websocket.dart lib/features/mining_v2/provider/mining_web_socket_bridge.dart ...`
  - `flutter test` in `plugins/flutter_mining`
  - `flutter analyze` in `plugins/flutter_mining`
