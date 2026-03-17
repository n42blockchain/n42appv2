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
