# 模块化与解耦工程：基线、规则与分批路线

> 背景：`CLEANUP_PLAN.md` 五阶段（赘肉清除→测试健康→主路径审计→coin 迁移→
> mining 收敛）已于 2026-06 全部收尾。本计划是下一轮工程：**每个模块过一遍，
> 加强模块化与解耦，同时提高测试覆盖率**。方法论同前——量化基线、分批执行、
> 每批独立可验收（analyze 零新增 + 相关测试绿 + 行为不变）。

## 依赖方向规则（本工程的验收红线）

```
core/  shared/          ← 不得 import features/*（composition root 除外，见下）
features/widgets|component|utils   ← 共享 UI/工具层，不得 import 业务 feature
features/<A>            ← 不得与 features/<B> 形成循环；单向依赖需走
                          shared 接口 / EventBus / Riverpod provider
lib/features/proto      ← protobuf 生成代码，豁免一切规则与测试目标
```

**composition root 豁免**：`core/di/injection.dart`、`core/app/`（app_globals、
chat_initialization、main 启动链）是接线点，允许 import features 实现——
这是把「谁认识谁」集中到一处的设计，不是违规。

## 侦察基线（2026-08-05）

### 共享层反向依赖（倒挂，批次 1–4 目标）

| 违规点 | 站点 | 处置 |
|---|---|---|
| `widgets/candlestick_chart` → wallet `ohlc_point` | 1 | 模型下移 shared |
| `widgets/device_login_dialog` → auth `device_login_info` | 1 | 模型下移 shared |
| `core/{sp_util,core_providers}` → auth `user_info` | 2 | 模型下移 shared |
| `sqlite/app_database` → browser×3 + wallet×2 模型 | 5 | 表 schema 注册制 |
| `utils/app_push_utils` → browser/home/auth/wallet 页面 | 6 | push 路由注册制 |
| `core/token_discovery` → wallet chain API | 3 | 接口抽象或服务归位 |
| `core/security/tx_simulation` → wallet `eth_api` | 1 | 同上 |
| `core/config/rpc_config` → wallet `chain_registry` | 1 | 同上 |

### 特性间循环/横向依赖（批次 5 目标）

| 依赖对 | 强度（import 数） | 处置（2026-08-05 批次 5 决议） |
|---|---|---|
| wallet ↔ browser | 9 ↔ 4 | ✅ 已断：wallet→browser 9 处全是「打开站内浏览器」，改走 shared `InAppBrowser`（composition root `navigation_wiring` 注册页面构造器）；browser→wallet（DApp 请求处理）保留为单向 |
| wallet ↔ wallet_connect | 5 ↔ 12 | 📌 接受：WC 是钱包卫星模块（同发版、深度共生）。方向规则：wallet_connect→wallet 任意；wallet→wallet_connect 仅限 wallet_page 入口/providers |
| mining ↔ mining_v2 | 3 ↔ 9 | 📌 接受（分层枢纽）：mining/domain+services ← mining_v2 ← mining/data（桥实现）。子层无环；mining/presentation↔mining_v2 的残余环等 v1/v2 收敛决策（CLEANUP 阶段5）一并处理 |
| loyalty → home | 1 | ✅ 已断：SettingShare+share_list 移入 component（通用「分享 App」页） |
| profile ↔ home | 4 ↔ 1 | ✅ 已消解：profile（2 文件、唯一入口 home 抽屉）并回 `home/profile/`——它不是独立特性 |
| news → browser | 1 | ✅ 已断：改走 `InAppBrowser` |
| utils → home | 3 | ✅ 批次 4 已断 |
| home → X / earn → X | 聚合 | 📌 接受：home/earn 是 App 外壳与聚合页，单向向下依赖是其职责；红线是 X→home/X→earn 反向边（已清零） |

### 测试覆盖基线（dart 文件数 / 测试文件数）

| 模块 | lib | test | 密度 | 优先级 |
|---|---|---|---|---|
| component | 4 | 0 | 0% | 高（被全仓引用） |
| profile | 2 | 0 | 0% | 高 |
| proto | 36 | 0 | — | 豁免（生成代码） |
| mining_v2 | 36 | 2 | 6% | 高（活跃开发线） |
| widgets | 35 | 2 | 6% | 高（被全仓引用） |
| mining_v1 | 38 | 3 | 8% | 低（维护态） |
| live | 34 | 4 | 12% | 中 |
| home | 28 | 3 | 11% | 高 |
| hardware_wallet | 19 | 2 | 11% | 中 |
| browser | 22 | 3 | 14% | 中 |
| staking | 15 | 2 | 13% | 中 |
| wallet | 515 | 79 | 15% | 持续（按子目录推进） |
| 其余小模块 | ≤14 | 1–7 | — | 顺带补齐 |

## 分批路线

| 批次 | 内容 | 状态 |
|---|---|---|
| 1 | 共享层纯度：`ohlc_point`/`device_login_info`/`user_info` 下移 `shared/domain/entities` + 三模型序列化测试 | ✅ 2026-08-05 |
| 2 | sqlite DAO 按 feature 下放为 extension（browser_dao/transaction_record_dao），`app_database` 只留连接/schema/通用查询；顺手删除零引用的 core/storage 加密版 AppDatabase 死代码 | ✅ 2026-08-05 |
| 3 | core 服务解耦：token_discovery/tx_simulation/legacy_wallet_adapter 归位 wallet；rpc_config 覆盖同步移至 wallet 侧；core→features 清零（composition root 豁免） | ✅ 2026-08-05 |
| 4 | 推送导航注册制：shared `PushRouteRegistry` + composition root `push_route_wiring`；utils→feature 页面清零 | ✅ 2026-08-05 |
| 5 | 循环依赖逐对治理（决议见上表）：`InAppBrowser` 抽象 + profile 并回 home + SettingShare 下移 component | ✅ 2026-08-05 |
| 6 | 测试洼地补覆盖：硬件钱包签名链路 108 测（UrCodec/Keystone/Ledger APDU，原为**零覆盖**且旧 ledger_utils_test 是假覆盖）+ DApp 安全 54 测（方法路由/地址冒名/审批闸门/URL 拦截）+ staking 交易构建 18 测 + mining_v2 状态派生与生命周期 24 测 + LineChart 标度 8 测，共 212 个新测试；另有架构守护测试 7 条 | ✅ 2026-08-05 |

## 批次 6 缺陷登记（**2026-08-05 全部修复**，skip 测试全部转绿）

**P0 硬件钱包 ✅**
1-3. `ur_codec.dart` 按 BC-UR 规范重写：词表替换为 BCR-2020-012 官方 256 词
   （以规范附录 62 字符黄金向量逐字节验证）；UR 正文改 minimal bytewords
   （2 字母/字节），旧全词格式保留解码兼容；多帧 UR（total>1）显式报错，
   单帧序号 `1-1/`、`1-of-1/` 可解。**注意：仍无 fountain 多帧解码器，
   大 payload 动画 QR 需后续实现；真机 Keystone 联调仍待验证。**
4. `keystone_service.dart` `codeUnits`→`utf8.encode`，非 ASCII 签名数据不再损坏。
5. `toDevice()` xpub 越界修复；`validateScannedUr` 改精确类型段匹配。

**P1 ✅**
- line_chart：min/max 以首元素起始（全负数正确）；paint 期 difference=0/单元素/空列表除零保护。
- atom_staking_api：APY 计算抽 `buildInflationApyResult`（ratio≤0 走兜底防 Infinity）；catch 兜底 error=true（3 处调用方均以 `!error` 采信，行为安全）。
- mining_v2 beacon：`rmm.data?[...] ?? 0` 空安全；新增 MiningApi 替身注入测试。
- resetData：一并清空 privateKey/miningKeypart/miningData（唯一调用方为换钱包路径，随后立即重新派生）。
- ledger buildEthSignTxApdu：payload>255 抛 ArgumentError（生产唯一调用方已 150 分块，无现网影响）。
- dapp_request_handler：hex 前缀大小写不敏感；裸字符串 throw 改 `{'code': -32602}` 错误对象（上层按 Map 形状序列化回 DApp）。

## 依赖方向的自动守护

`test/quality/dependency_rules_test.dart` 扫描 lib/ 全部 import 强制执行上述
方向规则（core/shared 纯度、共享 UI 层纯度、sqlite 零 feature 依赖、
X→home 禁止、wallet→browser 禁止、wallet→wallet_connect 白名单）。
新增违规 = 测试红。放宽规则须同步改测试 allowlist 并更新本文档。

## 贯穿护栏

- 每批只做结构移动/接线，不混入行为改动；资金路径（send/transfer/签名）
  涉及处必须有回归测试兜底。
- `AppGlobals` 仍不做清理运动（同 CLEANUP_PLAN 决议）。
- 移动文件一律**改真实 import**，不留旧路径 re-export 桩。
- 每批结束更新本文件状态表。
