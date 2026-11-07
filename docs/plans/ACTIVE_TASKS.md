# 当前任务与验收台账

> Batch 242 interruption check: Sui message-key binding recovered; 1,049 WalletConnect tests pass. Remaining signer/worktree reconciliation, archive ownership, native login, current-source regression and fresh release are explicitly open. See [current reconciliation](reconciliation-2026-11-06.md). Historical batch notices below are not a cumulative current TODO list.

> Batch 241: TRON/Solana message signing now verifies the derived address with identical captured key material and path. 12 pre-fix failures; 1,032 directory tests and 313 final-source scoped tests pass; analysis clean. Other non-EVM account models, native parity/device validation and broader release/lifecycle work remain open.


> Batch 240: empty native WalletConnect message signatures fail without a success response; explicit retry remains available. 16 pre-fix failures and 1,004 passing directory tests. Non-EVM key/address binding, native protocol parity and broader lifecycle/release requirements remain open.


> Batch 239: obsolete native message signatures no longer reach WalletConnect after captured session/request/account changes. 24 pre-fix failures, 988 directory tests and 269 final-source scoped tests pass. Empty native signature handling and non-EVM derived-key binding remain next, alongside broader release/lifecycle acceptance.


> Batch 238: WalletConnect coin lists now use completed wallet-build provenance; stale account/list contexts reject signing and refresh only from a ready source. 1,226 provider/WalletConnect tests pass, seven new origin/recovery cases. Non-EVM derived-key review, native/device acceptance, archive lifecycle and release remain open.


> Batch 237: exact WalletConnect chain selection replaces namespace-only routing. Eight pre-fix failures reproduced; 960 directory tests pass, scoped analysis clean. Wallet-switch coin-list ownership requires upstream rebuild-origin tracking; old-worktree signer reconciliation and release remain open.


> Batch 236: recovered omitted WalletConnect EVM key/address binding and selected derivation-path capture. Three pre-fix failures reproduced; 948 WalletConnect tests pass. Old-worktree non-EVM/coin-list and ordinary-sender comparisons remain open; no release or live acceptance.


> Batch 235: omitted group member-count refresh restored with stale/session guards. Chat 86891d07 passes 105 related tests; 51 wallet host checks pass. Remaining old-worktree signer reconciliation, native login, archive lifecycle and new release stay open. Batch 234 full results apply to the preceding source.


> Batch 234: fixed-source full regressions accepted: wallet 07ab42be0, 7,505 pass / zero failures or skips, 73.768618% coverage; Chat 4b8ab5b2, 8,314 pass / zero failures / four external skips, 71.493947%. Source and coverage preservation verified. Old-worktree comparison found missing group-member-count refresh; restore next without discarding other work. Native login, archive ownership and release remain open.



> Batch 233: archive/backup restore stop later work after captured session/service identity changes. 60 Chat tests and 51 host checks pass; pin 4b8ab5b2. Archive account partition/backup ownership and continuous redactions remain open, as do native login/full regression/release.


> Batch 232: archive v2 persists event-ID deletion markers and atomically removes plaintext/FTS; stale inserts are rejected after reopen. 53 Chat tests and 51 host checks pass; pin 27c4d1a3. Remote delivery, whole-database restore, account lifecycle and release/full regression remain open.


> Batch 231: archive scans remove SDK-confirmed redactions from storage/FTS; live search excludes them. 48 Chat tests and 51 host checks pass. Pin f261cc62. Continuous remote redaction synchronization and durable tombstones remain open; no release/full-suite claim.


> Batch 230: visible search results now clear on wired authentication and selected-owner durable history-clear events; pending work is invalidated and listeners released. 42 Chat tests and 51 host checks pass. Pin dbda9b3e. Server redactions/remaining history semantics, full regression, native login and release are still open.


> Batch 229: datasource search completions/history iteration are session-guarded and owned timelines released. 99 Chat tests, scoped analysis and 51 host checks pass. Pin e7031dc5. Proactive rendered-result invalidation and other lifecycle/release requirements remain open.


> Batch 228: global/category search now rejects changed account origins across awaits; 128 related Chat tests and 51 host checks pass. Pin 3c02667b. Proactive UI invalidation and datasource lifecycle remain open, alongside native login/full regression/release.


> Batch 227: clear-during-search history races reproduced and repaired; 59 Chat tests and 51 host checks pass. Chat pin 2f136ef3. Next: guard global search across account changes; full regression/native login/release remain open.


> Batch 226: Chat search history is scoped to homeserver/user and serialized across same-isolate instances; stale session work and failed writes are guarded. 55 Chat tests and 51 wallet host checks pass. Current pin is 7eef1654; full regression, native login, newer release and remaining MSG-001 work remain open.

> Batch 225: Chat pin 07e7c2ae guards history completions/errors and clears visible results immediately. 46 Chat tests, clean analysis and 51 host checks pass. Repository write concurrency/proactive invalidation and remaining MSG-001 work stay open; no new release.

> Batch 224: wallet now pins Chat a8a87226; stale search completions after clear/scope changes and duplicate pagination are guarded. 40 Chat search tests and 51 host tests pass. Proactive clear/account invalidation and remaining MSG-001 items stay open; old full-suite coverage is historical.

> Batch 223: memo dispatch/release now match stored recipient, exact amount, contract and asset identity. Eight pre-fix SQLite failures reproduced; 124 related tests pass after repair. Broader maturity and release requirements remain open.

> Batch 222: memo confirmation/quotes now track mutable signing configuration; persistence callbacks reject form/key changes before RPC. 65 widget cases pass. Native/live acceptance and broader remaining work are unchanged.

> Batch 221: actual Android NEAR MethodChannel/WalletCore JNI passes two integration cases, including independent signature/reference matching and 12 malformed inputs. Temporary emulator stopped; physical devices untouched. Native component gap closed; full app/live/device, precise fees and new release remain open.

> Batch 220: NEAR confirmation/Max now use storage reserve and network-priced fee reserve; sender rejects reserve changes before signing. This retains the conservative 300 TGas policy, not exact fee estimation or optimal Max. Protocol-derived quoting, native/live/device checks and new release remain open.

> Batch 219: NEAR history now queries FINAL receipts bound to hash/sender/receiver/exact amount. 147 related tests pass, including SQLite reopen and terminal resolution. Batches 217–219 close the local persistence/recovery wiring gap; fees, native/live/device acceptance and updated release remain open.

> Batch 218: NEAR memo-page preparation/dispatch and canonical Base58 database reservation are wired; 113 SQLite/widget cases pass. Final receipt/history resolution is the next required gap; pending reservations must not be released on timeout/not-found. No new release.

> Batch 217: NEAR sender preserves local hash on unknown outcomes and awaits preparation/dispatch hooks with account rechecks; 65 related tests pass. Next integrate NEAR into memo-page/database reservation and receipt recovery; hooks alone are not durable app recovery. No release upload.

> 本次中断核对：batch 216 已提交；35 项交易哈希/回执测试复跑通过。钱包及 Chat 先前全量运行均已有终态，不再列作运行中。73325 是未上传的旧候选包，不含 batches 212–216；仍需新包、原生登录验收和上传权限确认。13 个辅助工作树保留（7 个有本地改动，4 个干净但非祖先，2 个干净祖先）。详见[当前核对](reconciliation-2026-11-06.md)。

> Batch 216: NEAR submission success now requires the RPC hash to match the locally hashed signed transaction; 185 related tests and native independent digest fixture pass. Durable pre-submit identity/history recovery and finality remain open. 73325 predates this work.

> Batch 215: NEAR submission rejects malformed/pending receipts instead of claiming success; 169 related cases pass. Local payload/hash binding, durable unknown-outcome recovery and finalized settlement remain open. No real transaction or new release upload.

> Batch 214: NEAR transfer/Max now retains storage stake using same-final-block account/config data. Display balance contract is unchanged; 71 related tests and public read-only RPC schema verification pass. Precise fee/reserve preview, JNI/live/device and uncertain-outcome recovery remain open.

> Batch 213: NEAR iOS/Android native parameter validation added before casts/key access; Swift/Kotlin each pass 96 boundary cases. Actual Swift signing and invalid-input rejection pass. Android JNI and full app/live acceptance remain open; 73325 predates these changes.

> Batch 212: NEAR ordinary sender identity, access-key failure handling and native wire encoding repaired; 44 related tests and real Swift/WalletCore component signing pass. Fee/reserve, Android JNI, unknown outcomes and live acceptance remain open. The already built 73325 IPA does not include this later runtime fix.

> Batch 211 supersedes the pending full-run/release notes below: wallet `4b1f38aec` passed 7,335 tests, zero failures/skips, coverage 73.6573%; Chat `8c5202ab` passed 8,230 tests with four external skips, coverage 71.3931%. Release `cbbe308d6` / 2.5.3+73325 is signed and passes packaged-provider checks. Release fixes are merged and pushed to master. Upload remains pending N42-authorized Transporter access; no TestFlight processing/tester claim. See [release evidence](../releases/testflight-20261106-73325.md).

> Batch 210: Signed IPA 73324 is rejected for missing native provider configuration despite valid signatures. The ignored native config is now copied privately; additional provider artifact checks are prepared. Fixed Python 3.9 capability hashing, with 52 script tests passing on both interpreters. Rebuild/provider inspection and N42 upload-account verification remain pending.

> Batch 208: Chat pinned 8c5202ab full suite is accepted: 8,230 pass / four external skips, 71.3931% coverage. Wallet batch 205 remains active on 4b1f38aec. Isolated signed build failed for missing ignored Google plist; correct N42 config is now copied privately, and the license-only generated pod checksum is reconciled here. New IPA and TestFlight acceptance remain open.

> Batch 204: Both sender fixes are integrated into master; their temporary worktree is removed. Wallet full batch 200 finished with 7,292 pass / one Falcon export-wait failure / zero skips, coverage 73.5978%, and is not accepted. The unchanged failure passes alone; its real-KDF ownership test now has a bounded contention-tolerant wait and both page cases pass. A new full run is required. Chat batch 199 still awaits its terminal result.

> Batch 203: Algorand sender balance/API shape, selected-network routing, ASA native dispatch and signer isolation are repaired on the isolated branch (63 related tests). Native validity-window/full-width integer and live acceptance remain open. Main full regressions still apply only to their captured source commits.

> Batch 202: Solana signer/address binding and account-switch guards are verified in an isolated branch (125 related tests). Integration is pending the fixed-head wallet/Chat full runs. Batch 196 reduced old auxiliary worktrees to 12; batch 202 adds one temporary active worktree. Older worktree counts and full-suite records below remain historical.

> Batch 199: Chat batch 195 finished with 8,222 passing tests, eight mock-fixture failures and four external skips; coverage 71.3688%, but full verification failed. Fixture repaired at wallet-pinned `8c5202ab`; 25 draft cases and three host checks pass. A fresh Chat full run is active. Earlier running/pin statements below are historical.

> Batch 195: Chat `930690d1` is now integrated into the usual branch and wallet. The stalled batch 192 run was explicitly terminated and is not accepted. A fresh full run of `930690d1` with concurrency 2 is active; require its terminal result and gates before claiming success.

> Batch 194 supersedes the pin below: current wallet dependency is Chat `930690d1`. Thread initialization visibility and first-load retry are repaired with focused regression evidence in the reconciliation. The terminated batch 192 run was scoped to `90271407`; it did not cover these newer fixes.

> Current source check (2026-11-06): wallet `66fc50b8a` pins Chat `90271407613989ccc27e159903382857c3848338`. Both match their fetched upstreams. Chat batch 192 was later terminated; it did not produce accepted full-suite evidence. Batch 173 (Chat `ca0a2049`, 8,103 passed / four external skips, 71.1056% coverage) is a historical full-suite baseline, not the current dependency. See the current reconciliation for remaining work and evidence boundaries.

> Latest verification (batch 172): wallet source `5cb2b8a7b` passes 7,271 tests with zero failures/skips; coverage 73.5942% passes the existing 70% gate. Older dated coverage/release statements below are historical, not the current baseline. Open feature and external acceptance items remain active. See [current reconciliation](reconciliation-2026-11-06.md).

更新：2026-11-06。最近几天的当前状态、遗漏和续做顺序见[任务核对](reconciliation-2026-11-06.md)。以下 10 月及更早表格和执行记录为历史快照，不代表当前依赖、覆盖率或发布状态。

## 待办

| ID | 任务 | 当前状态 | 验收标准 / 证据 |
| --- | --- | --- | --- |
| IAP-01 | 完成 iOS App Store 内购交付链路 | 商店商品查询和购买界面已接入；未发现服务端收据校验、订单幂等或商品发放。当前只证明商店返回购买状态，不能证明用户收到商品。 | 需要定义 `ai.n42.www.n.*` 的交付内容，再接收据校验、账号绑定、幂等发货和退款/恢复流程。现有购买提示不应作为履约完成证据；见 [IAP 页面](../../lib/features/wallet/pages/iap/iap_page.dart)。 |
| DEP-01 | 完成主程序、Chat 插件和本地包依赖升级 | Flutter 3.47.5 下继续升级：主程序全量 5,432 项通过，覆盖率 71.1451%；Chat 最新全量结果对应 `0cee5c69`：7,310 项通过、3 项跳过，行覆盖率 70.1020%；`sqflite_common` 升至 2.5.13+1 后，相关 SQLite 测试 18 项通过。`connectivity_plus`、Chat `wakelock_plus` 和 dbus/Linux 网络依赖已升级；Chat 示例 Linux ARM64 Debug 构建通过。全部最新版本仍未完成，剩余约束见依赖记录。 | 在兼容边界解除后继续升级，不强制覆盖造成编译或钱包数据风险的依赖。当前清单和验证见[依赖升级记录](../testing/dependency-upgrade-2026-10-02/README.md)。 |
| PAY-01 | 欧美及海外法币转账、红包、USDT/USDC 渠道与架构设计 | 设计完成，基础代码及本地模拟已分项提交，未接入生产 | [设计方案](payments-red-packets-overseas-2026-09-20.md)。确认运营主体、供应商消费者场景准入后进入实施；当前不进行真实资金交易。 |
| UX-01 | 依据欧美常用产品参考，对聊天、联系人和账号切换继续细调 | 本轮微调已验收并集成 | 在已完成 UI 方案基础上修补具体缺口，保留现有功能；窄屏、交互及无障碍针对性验证，由主代理审阅后集成。[执行记录](../testing/ui-polish-2026-09-20.md) |
| COV-01 | 主程序 CI 口径测试覆盖率达到 70%，并单独推进 Chat 插件 | 主程序本轮全量 5,432 项通过，行覆盖率 71.1451%。Chat 最新全量覆盖率在 `0cee5c69`：7,310 项通过、3 项跳过，行覆盖率 70.1020%。两个仓库分别统计。 | 不降低门槛。两套结果及此前各轮历史证据见[覆盖率报告](../testing/coverage-expansion-2026-10-02/README.md)。Chat 的剩余改进按行为风险排序；不将模块覆盖率或旧 LCOV 当作最新全量结果。 |
| QA-01 | 2696 遗留问题与最新反馈真机验收 | 部分等待反馈设备 / 外部渠道 | [修复与边界](../testing/chat-feedback-2696-2026-09-20/README.md)。Chat `OPEN_ISSUES.md` 为未解决缺陷的唯一台账，本表不替代它。 |

## 执行规则

- 新代理只接收任务目标、必要文件、独占范围、验收标准和证据位置，不传完整历史。
- 同一任务复用已有代理；文件或任务阶段变化后由主代理重新划分边界。
- UI 代理修改真实 Chat 仓库的呈现层及相关测试；覆盖率代理修改主程序测试，避开 Chat 镜像、依赖版本与 UI 文件。主代理更新 pin、镜像并提交。
- 子代理结果写入各自文档，回复仅含结论、测试计数、失败摘要和路径；大日志保留在本机。
- 先跑针对性验证；扩大测试由变更、失败或验收需求决定。覆盖率目标最终必须有全量新报告，不能用模块覆盖率或旧 LCOV 代替。
- 不降低门槛、不通过排除文件改变口径，不添加没有业务断言的测试凑比例。若发现生产缺陷，先报告，主代理决定是否纳入修复。
- 未得到证据不标记完成；已通过自动测试不能替代真机、支付渠道生产准入或真实资金验收。

## 主代理决策记录

- 用户确认支付首批为欧美和其他海外市场；数字货币优先 USDT/USDC。PAY-01 已形成设计，尚不等于生产功能。
- 用户批准 UI 微调和 70% 覆盖率并行，由最小必要上下文的代理实施。两任务已启动。
- 已完成 UI 方案不推倒重做；当前优先修补可证实的交互/无障碍问题。
- 旧 `coverage/lcov.info` 为 9 月 15 日文件，不能当作本轮基线；等待新全量测量后安排覆盖率批次。

- UX-01 本轮接受：群成员选择项向读屏暴露名称、选中/禁用状态与点击动作，移除重复头像读音；3 项针对性检查通过，分析无问题。仅改实际缺口，不重做已完成布局。

- UX-01 已推送 Chat `21748699` 并同步主程序 Git 依赖及镜像；新增主程序回归入口。
- COV-01 首次全量因本机文件句柄上限 256 失败，作废该结果；按 CI 的 4096 上限重跑。新增 29 项安全存储、网络与防钓鱼测试已通过。

- 用户要求每段工作按功能、模块、单项修复及时独立提交，禁止混合多个功能；所有提交标题为英文。
- 新全量覆盖率 60,962 / 130,827 = 46.60%；5442 项通过、1 项旧注册 fixture 失败。修正该 fixture 后单独复测；本轮不宣称全量全绿或 70% 达标。

- 注册 fixture 修复后 `test/quality/chat_device_fixture_contract_test.dart` 18 项通过；未重新全量运行。
- 已独立提交：UI `e07045d10`、网络测试 `1d87470d0`、防钓鱼 `24405a5df`、安全存储 `08d92581a`、注册 fixture `68707bb2b`、支付设计 `06cfd630e`。版本号由现有提交钩子逐次递增，不表示已发布安装包。

- 支付实施已拆成独立任务：[实施清单](payment-implementation-tasks.md)。P01–P08 和 P10a 已提交，剩余界面、签名、公共测试网及供应商沙盒按依赖推进。人工负责外部账号/签约；本地模拟不等于外部沙盒。

## 第二批实施（2026-09-20）

- UI：成员选择弹窗增加可清除搜索/无结果反馈，修复320宽、200%文字及键盘遮挡时52px溢出。Chat `d2e3167c`，主程序 `92085d013`，4项widget测试通过，未作真机验收。
- 钱包：测试发现并修复代币超额发送（`cc4ef4a61`）、刷新手续费后余额不足（`707bf93b6`）、非有限金额绕过校验（`31d6f486a`）；均独立提交并有失败前/通过后证据。
- 支付：P09a–P09c本地HTTP、账号隔离客户端与跨语言协议验证已完成。尚未接APP入口、公共测试网或外部支付供应商。
- 覆盖率：稳定提交 `707bf93b6` 全量 5567 通过、0失败、0跳过；61,391 / 131,112 = 46.8233%，921个文件。后续支付协议校验和测试界面未纳入该测量，采用针对性验证。完整证据见 [第二批报告](../testing/wallet-coverage-batch2-2026-09-20.md)。

## 覆盖率与服务端配置续跑（2026-09-23）

- 主程序全量在发现 Chat 附件面板排序回归后，先将 `Apps` 调整到首屏，再复跑：5,756 个可见测试通过，另有 458 个隐藏加载/设置事件通过，共 6,214 个成功 machine 事件。当前原始覆盖率 48.1233%，70% 质量门槛未通过，COV-01 继续开放。修复提交 `be7d520ec`。
- Chat 正式审计仓全量 6,585 项通过、1 项凭据条件跳过；原始覆盖率 25.0024%，非生成代码诊断视图 39.5986%。Chat 独立审计分支提交 `8d735268e`，未更改主程序 Git pin。
- 配置与服务端模块测试/覆盖结果、LCOV 归档及口径说明见[覆盖率扩展报告](../testing/coverage-expansion-2026-09-23/README.md)。
- Chat 后续归档完整性续跑：真实 SQLite 导出/导入测试发现并修复 Unicode 字节编码损坏；服务覆盖 120/121 行（99.1736%），全量 6,592 通过、1 条凭据条件跳过。提交 `38af33fc`；主程序 pin 未变。[补充报告与 LCOV](../testing/coverage-expansion-chat-archive-2026-09-23/README.md)。

## 覆盖率续跑（2026-09-24）

- Chat 正式审计仓全量 6,593 项通过、1 项实时媒体凭据条件跳过；原始覆盖率 33,395 / 133,072 = 25.0954%，非生成 `lib/src` 诊断口径 39.7518%，Chat 核心路径诊断口径 28.19%。新增消息 Markdown 链接协议安全测试 1 项，提交 `942a4ed1`；主程序 Chat pin 未变。
- 主程序配置按生产默认、development、代理末尾斜线和 host-only origin 四种构建配置测试；4 个配置文件按 LCOV 行并集合计 97 / 106 = 91.51%。Dart analyze 和 diff 检查通过。
- Go `social-auth` 与 `swap` 全模块测试通过，分别验证必填配置缺失时的子进程退出码及诊断信息；覆盖率统计限制和各模块结果见本批[报告](../testing/coverage-expansion-2026-09-24/README.md)。
- 主程序未重新执行全量测试；最新完整结果仍为 48.1233%，COV-01 的 70% 门槛继续开放。root 配置测试提交 `f9d61c3fc`，`social-auth` 测试提交 `8ceb2ceb0`，`swap` 测试提交 `d96a5c11c`；本轮未更改 Chat 依赖 pin。
- 后续钱包发送覆盖率续跑：新加 5 项 Max 金额回归测试，先复现并修复 XRP 余额未扣 10 XRP 预留的问题。全量有 5,766 个可见测试通过、0 失败、0 跳过；另有 458 个隐藏加载/设置事件，共 6,224 个成功 machine 事件。覆盖率 63,710 / 132,404 = 48.1179%，`wallet_chain_send_logic.dart` 为 125 / 327 行（38.2263%）。70% 目标仍开放；完整报告与 LCOV 见[9 月 24 日覆盖率报告](../testing/coverage-expansion-2026-09-24/README.md)。
- 后续钱包备份确认补测新增 6 项测试（5 项交互测试和 1 项旧保存入口兼容测试）；安全存储失败原先被扩展方法吞掉、页面仍显示成功并退出，已新增严格保存入口并验证失败可留页重试、重复点击仅写入一次。定向测试 6/6、Dart analyze 无问题；完整套件有 5,772 个可见测试通过、0 失败、0 跳过，另有 459 个隐藏加载/设置事件；全量覆盖率升至 63,837 / 132,408 = 48.2123%，`backup_three.dart` 为 101 / 111 行（90.9910%）。COV-01 的 70% 目标继续开放，报告及 LCOV 见[覆盖率扩展报告](../testing/coverage-expansion-2026-09-24/README.md)。
- 钱包覆盖率继续分三轮完成并分别提交：真实钱包 Provider 账户隔离 1 项；Ethereum/Solana 合成 USDC 搜索、网络筛选和 API 错误页面测试 2 项；助记词手动/剪贴板规范化、无效及重复拒绝、成功路由和离页竞态测试 5 项。旧空格切分无法处理 tab/换行，现已统一折叠连续空白。全量新增 8 项可见测试后，5,780 项通过、462 个隐藏 machine 事件通过；LCOV 提升至 64,779 / 132,409 = 48.9234%，较上一轮增加 0.7111 个百分点。`ImportOne` 为 133 / 144 行；COV-01 的 70% 目标仍开放，详见[覆盖率报告](../testing/coverage-expansion-2026-09-24/README.md)。提交：`12219ce30`、`69527a526`、`e80a463ce`。

## 第三批与下一步

- Keystore 导出新增8项交互测试，修复倒计时文字窄屏溢出，提交 `354eedad1`；风险确认/取消/复制/定时和离页清理均验证。
- 支付实验页已接About中的显式debug入口（默认关闭，release禁用）；7项页面测试、开关两种配置通过。本机服务可用启动器初始化两个测试账号，不涉及真实资金。
- UI后续优先真实设备大字体/键盘回归；支付优先红包表单、待处理订单恢复、显式资产桥接；覆盖率继续钱包资产/导入导出实际交互批次。
- 最近完整测量仍为707bf93b6的46.8233%；后续协议、实验页、keystore修复已窄测，未再次全量测量。不宣称70%已达成或这些后续修改已纳入全量报告。

## 第四批（本地红包与结果恢复）

- 钱包导入页新增11项真实交互测试，提交 `5775ab98d`；不读取真实剪贴板或密钥，不宣称覆盖成功存储路径。
- 本地红包实验页增加创建/领取/退回，以及结果未知时的原参数锁定和只读查询；独立debug入口不共用转账页会话。
- 本地转账实验页增加按原幂等键查询；页内换号保留各账号未确认请求，返回完成收据时不再次POST。
- 修复dot-only幂等键被URI规范化导致查询错误的问题，客户端改用查询参数，保留旧服务端接口兼容。
- 集成验证：Flutter相关148项通过，Python本地支付35项通过；本轮未再次全量测覆盖率，最新全量仍46.8233%，70%目标开放。
- 后续优先：pending离页/重启恢复、专属收款人红包资格、显式资产钱包桥接；UI真机与公共测试网仍未验收，外部签约/沙盒账号由人工处理。

## 第五批与发布后继续

- `v2.4.8+2026072753` 已推送；TestFlight上传成功、Apple处理状态待确认；APK已核验并放入下载目录。见 [发布记录](../testing/testflight-release-2026-09-20-2753.md)。
- 专属红包后端、pending存储基础、钱包网络设置10项交互测试已分模块提交。支付仍仅本地模拟，存储尚待页面接线。
- 下一批并行：转账离页重建恢复、专属红包客户端、钱包地址簿交互测试；Flutter测试串行使用共享构建目录。
- UI既定聊天/联系人/换号布局已实现；继续以具体缺口和真机验收为准，不重复重做。支付恢复页属于本轮交互完善。
- 70%尚未达到。2753发布前156项Flutter相关测试、47项Python测试通过；没有重新全量测覆盖率，不将这些计数换算成覆盖率提高。

## Token 节省执行规则（用户补充）

目标是减少实际累计输入/输出 tokens，不以便宜模型或缓存命中冒充节省数量。

- 默认一个执行代理；小修改直接完成。确需独立并行时才增加代理，不为复述同一结果再派代理。
- 新模块用 `fork_turns=none`，派单约300–500 tokens，包含目标、独占路径、约束、验收；结果约200 tokens，只给结论、失败摘要、证据路径。
- Sol low用于边界清楚的实现；Terra/Luna用于轻量检索和文档；主代理审查安全边界。模型降价与token减少分别统计，不承诺同模型/跨模型共享零token。
- 先定位再局部读取，限制工具输出；主代理审关键diff，不复制代理的整段探索过程。日志存本机，正常仅取汇总，失败才取附近片段。
- 窄测试通过即停止重复；全量测试在集成里程碑执行。不要用增加并行和频繁轮询换取无效上下文。
- 阶段结束维护短交接记录；压缩历史只减少后续上下文，不能追回已消耗量。共享工作区文件仍需被模型读取，缓存输入仍是输入tokens。

参考：[OpenAI子代理说明](https://learn.chatgpt.com/docs/agent-configuration/subagents)、[Prompt caching](https://developers.openai.com/api/docs/guides/prompt-caching)。

## 第六批结果

- 地址簿真实交互8测试：`721ff30ed`；未新增远程写入成功路径覆盖。
- 专属红包客户端与本地协议21测试：`7ee3520d2`；指定人界面尚未接线。
- 存储串行队列生命周期修复11测试：`8aebb3071`；转账离页恢复22测试、host启用3测试：`2db7df734`。
- Sol低推理、无历史继承实现资产解析，主代理审查补充严格链ID拒绝；12测试、定点分析无问题：`84105d834`。没有声称精确发送/签名已接通。
- 本轮未重新全量测量覆盖率，未重打安装包；已上传TestFlight仍2753。下一步单执行代理优先红包pending/专属人表单，再进入P10c精确发送参数；覆盖率持续按高价值业务补测。

## 第七批（2026-09-21）

- 一个Sol low执行代理，复用同模块上下文；主代理集中审关键diff及身份/重复请求边界。
- 红包create/claim/refund持久恢复：`859c16337`，29项测试通过；损坏/保存失败阻断，清理失败明确提示已确认且禁止重发，转账记录保持。
- 专属收款人表单与旧存储兼容：`a7a86f6ae`。初次组合40通过，审查修订后红包页28通过；收款账号ID不与bearer token混用，sender/member授权由服务端验证，界面份数与实际请求一致。
- 支付仍是本地模拟。未执行本轮全量覆盖率、真机验收或新安装包发布，最新已上传TestFlight仍2753。
- 下一小模块P10c：先修手续费估算绕过精确最小单位的问题，再接发送参数；不得直接宣称测试网或签名通过。

## 第八批（2026-09-21）

- EVM精确金额估算修复 `16a7237b4`：22相关回归通过、定向分析无问题；本机RPC和记录型签名替身验证，无真实私钥或真实广播。
- 一个Sol执行代理实施，主代理审查补充成功回显不能沿用NaN/旧浮点金额。保持按功能独立提交。
- 下一步P10c-2显式资产到SendParams映射及确认界面；70%覆盖率、公共测试网、真机验收仍开放。本轮未重新测全量覆盖率或发布安装包。

## 第九批（2026-09-21）

- P10c-2纯参数适配 `547a02e85`：10测试通过、定向分析无问题。显式资产/地址绑定、精确金额、不可变安全配置与派生路径边界已验证。
- 单执行代理实施，主代理审查补充RPC缺失拒绝、配置allowlist、chain ID范围与索引0路径处理。
- 下一步旧symbol接口歧义保护与确认/授权复核。未接真实签名广播、未做设备验收或新包发布；70%全量覆盖率仍未达标。

- 本批RPC追加边界发现URI规范化会移除空userinfo，已在解析前校验原始authority并重新验证10项全过。后续代理必须先明确冻结文件并交付对应测试结果，主代理才提交，避免交接后追加修改污染已验收版本。

## 第十批（2026-09-21）

- 旧转账入口歧义保护 `9c32edc55`：24项相关测试通过，定向分析无问题；多网络同名资产在发送器前拒绝，单匹配行为保持。
- 未改变余额查询/代币列表；旧入口显式网络选择仍待确认页接线。下一步P10e/P11账户和授权复核。
- 未跑全量覆盖率、未操作真实资产或发布新包，70%覆盖率目标仍开放。
