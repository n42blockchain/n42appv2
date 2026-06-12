# 全仓清理计划：骨架之外的赘肉与暗坑

> 背景：通知系统全局审查（见 `PUSH_NOTIFICATIONS.md`）证明了一个模式——
> 架构骨架是好的，问题集中在「赘肉」（死代码、未接线的设计、假实现）和
> 「暗坑」（被结构掩盖的 bug、编译不过的测试、依赖隐式顺序的正确性）。
> 本计划把同样的方法论推广到全仓，分五个阶段，每阶段独立可验收。

## 侦察基线（2026-06-12）

| 项 | 规模 | 定性 |
|---|---|---|
| `shared/contracts/` 接口 | 7 个接口，**零实现** | 赘肉 |
| `IAuthService`/`AuthServiceImpl` | 仅 2 处自引用 | 赘肉 |
| `passkey_signer_provider` | 零使用（AA Passkey 设计未接线） | 有意保留，需标注 |
| `coin['xxx']` 动态 map 访问 | **796 处**（92% 在 wallet） | 类型安全暗坑 |
| mining / mining_v1 / mining_v2 | 共 1.4 万行；v1 仍被 30 个外部文件引用 | 活的旧版本，非死代码 |
| TODO/FIXME | 29 处（`chain_prediction_repository` 独占 12） | 占位待决策 |
| n4_chat 存量失败测试 | 4 个（chat_lock ×2、translation ×2） | 暗坑：一直没在跑 |
| host analyzer 存量 | 59 个 info/warning | 已派 Codex（T3） |
| `AppGlobals.` 引用 | 103 处 | legacy façade，只立护栏不清理 |

---

## 阶段 1：零风险赘肉清除（~半天，立即可做）

只删「零引用且 git 可找回」的东西，每删一项同步更新 CLAUDE.md。

1. **删 `shared/contracts/` 7 个零实现接口**。CLAUDE.md 已记录其设计意图
   （"kept as reference"），git 历史即存档，不需要活代码占位。
2. **删 `IAuthService`/`AuthServiceImpl`**（features/auth）：生产路径走
   `AppGlobals.userInfo` + `currentUserProvider`，接口零接线。
3. **`passkey_signer_provider` 不删、加标注**：文件头注明「设计未接线，
   生产 AA 签名走 `trustdart.signMessage`（aa_transfer_handler）」+ 接线
   前置条件，防止误以为生效。
4. **处置 `benchmark_results/` 三个长期未提交的修改**（提交或还原，二选一）。

验收：`flutter analyze` 零新增问题、`flutter test` 全绿、CLAUDE.md 与
现实一致。

## 阶段 2：测试套件健康（~1 天）

暗坑最高发区是「以为在跑、其实没跑」的测试。

1. **修 n42_chat 4 个存量失败测试**（chat_lock salted-pin ×2、
   translation 语言数 ×2）——与通知域的 2 个「编译都过不了」的测试同类，
   规则：测试要么修好要么删除，不许长期红着。
2. **核查 `test/all_tests.dart` 覆盖完整性**（侦察提示可能有遗漏的测试
   文件未被聚合）。
3. **加守门**：`Makefile` 增加 `make check` = analyze（零 error）+ test，
   作为提交前手动闸门（pre-commit hook 已有 build-number bump，不再加重）。
4. **跟踪 Codex T3**（analyzer 59 项清理，已在 `codex-n42` 任务书派发）。

验收：两仓库 analyzer 零 error、全部测试可运行且绿。

## 阶段 3：主路径暗坑审计（~2-3 天，价值最高）

复制通知审计的方法论（找：初始化截断、双监听竞态、标记/检查顺序错误、
吞异常）。每条路径产出：发现清单 → 修复 → 回归测试 → 不变量文档。

按风险排序：
1. **main.dart 启动链**：`_initData`/`_initDeferredServices` 的顺序依赖与
   异常吞噬；deep link 初始化与 push 初始化的竞态（通知审计已抓到一个
   init 截断 bug，启动链是同类暗坑的温床）。
2. **转账主路径**：`sender_factory` 20+ 链分发 + `aa_transfer_handler`
   ECDSA 签名——资金路径，错误处理与重试语义必须逐行过。
3. **WalletConnect 三层 mixin 链**（Connection+Session+Signing on
   ChangeNotifier）：会话恢复、重连、并发签名请求。
4. **DApp browser JS bridge**：消息路由与来源校验（结合 core/security
   的 DApp 安全模块看是否真的在主路径上）。
5. **`chain_prediction_repository` 12 条 TODO**：对照
   `feat/live-prediction-market` 分支确认功能状态，TODO 要么排期实现
   要么降级为 issue，不留在代码里发霉。

验收：每条路径一份审计记录（可并入对应 docs/），修复带回归测试。

## 阶段 4：类型安全硬化——coin['xxx'] 迁移（分批，2-4 周）

796 处字符串下标是最大的暗坑面（typo 不报错、类型靠运气）。
`CoinConfigView` 已就位，策略是**先锁增量、再清存量**：

1. **锁增量**：CLAUDE.md 写入「新代码禁止 `coin['...']`，必须走
   `cm.config.*`」；code review 以此为准。
2. **分批清存量**：按目录批次（每批 50–100 处），优先 send/transfer
   等资金路径文件；每批验收 = analyze + 相关测试 + 行为不变。
3. **机械批次适合派 Codex**（通过 `codex-n42` 任务书追加），资金路径
   批次由 Claude 做并配测试。

验收：`grep "coin\['" lib` 计数逐批下降至 0，迁移期间不混入逻辑改动。

## 阶段 5：mining v1/v2 版本收敛（决策先行，不抢跑）

v1 被 30 个外部文件引用、`plugins/flutter_mining` 仅服务 v1——这是
**活的旧版本**，不是赘肉，删它是产品决策不是代码清理：

1. 先做路由可达性分析：v1 入口在生产 UI 是否仍可达、是否有存量用户依赖。
2. 可下线 → 迁移路由、删 v1 + plugin（一次性 PR，预计 -7k 行）；
   不可下线 → 在 CLAUDE.md 写清两版边界与「新功能只进 v2」的规则。

## 贯穿护栏

- `AppGlobals`（103 处）**不做清理运动**——它是有意保留的 legacy façade；
  护栏是 CLAUDE.md 已有的「新代码用 Riverpod」，阶段 3 审计时顺手记录
  哪些路径还在双写。
- 每阶段结束更新本文件的状态表。

## 状态

| 阶段 | 状态 | 完成时间 |
|---|---|---|
| 1 零风险赘肉 | 未开始 | |
| 2 测试健康 | 部分（通知域已完成；Codex T3 已派发） | |
| 3 主路径审计 | 部分（通知路径已完成，见 PUSH_NOTIFICATIONS.md） | |
| 4 coin 迁移 | 未开始（CoinConfigView 已就位） | |
| 5 mining 收敛 | 未开始（待决策） | |
