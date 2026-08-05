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

| 依赖对 | 强度（import 数） | 备注 |
|---|---|---|
| wallet ↔ browser | 9 ↔ 4 | 大对，需接口化 |
| wallet ↔ wallet_connect | 5 ↔ 12 | 大对 |
| mining ↔ mining_v2 | 3 ↔ 9 | mining 是 v2 的 Clean-Arch 桥，方向需理顺 |
| loyalty ↔ home | 1 ↔ 2 | 小对 |
| profile → home | 4 | home → profile 1，循环 |
| news → browser | 1 | 单向，评估必要性 |
| utils → home | 3 | 归入批次 4 |
| earn → staking/loyalty/mining_v2/bridge/airdrop/hardware_wallet | 聚合页 | earn 是聚合入口，单向可接受，记录即可 |

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
| 1 | 共享层纯度：`ohlc_point`/`device_login_info`/`user_info` 下移 `shared/domain/entities` + 三模型序列化测试 | 进行中 |
| 2 | sqlite 表 schema 注册制，`app_database` 不再认识 feature 模型 + 单测 | 待办 |
| 3 | core 服务解耦：token_discovery / tx_simulation / rpc_config 的 wallet 依赖接口化或归位 | 待办 |
| 4 | app_push_utils push 路由注册制（utils 不再 import feature 页面）+ 分发单测 | 待办 |
| 5 | 循环依赖逐对治理（上表），每对配回归测试 | 待办 |
| 6 | 测试洼地补覆盖（component/profile/home/mining_v2/widgets 优先，纯逻辑先行） | 待办 |

## 贯穿护栏

- 每批只做结构移动/接线，不混入行为改动；资金路径（send/transfer/签名）
  涉及处必须有回归测试兜底。
- `AppGlobals` 仍不做清理运动（同 CLEANUP_PLAN 决议）。
- 移动文件一律**改真实 import**，不留旧路径 re-export 桩。
- 每批结束更新本文件状态表。
