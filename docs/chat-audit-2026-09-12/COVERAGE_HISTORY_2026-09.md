# Chat 覆盖率历史记录

前四轮报告合并于 2026-09-14，第五轮在同一文件追加。各轮正文、统计口径、限制和证据链接保留；后续状态以 [交付索引](README.md) 与正式插件问题台账为准。不同轮次的独立用例数、宿主复验数不能重复相加。

- [第 1 轮](#round-1)
- [第 2 轮](#round-2)
- [第 3 轮](#round-3)
- [第 4 轮](#round-4)
- [第 5 轮](#round-5)

---

<a id="round-1"></a>

## Chat behavior coverage expansion — 2026-09-13

原路径：`COVERAGE_EXPANSION_2026-09-13.md`。

**6,007 tests passed; one credential-dependent live smoke skipped.** This batch adds 140 behavior cases across eight new suites and the existing platform-write suite. Baseline: the complete settings run at `16fe83a` (5,867 passed). No CI threshold, instrumented file selection or generated-code exclusion changed.

Command: `ulimit -n 4096; flutter test --no-pub --coverage --concurrency=6 --reporter expanded`.

| Scope | Baseline | Current |
|---|---:|---:|
| Raw lcov (including generated code) | 25,212/131,079 (19.23%) | 27,822/131,172 (21.21%) |
| Non-generated reference view | 24,584/79,238 (31.03%) | 26,688/79,257 (33.67%) |
| Auth repository | 59/567 (10.41%) | 272/569 (47.80%) |
| Message actions repository | 0/269 (0.00%) | 272/275 (98.91%) |
| Story repository | 8/156 (5.13%) | 152/156 (97.44%) |
| Archive database | 24/319 (7.52%) | 182/321 (56.70%) |
| Media metadata database | 0/165 (0.00%) | 126/165 (76.36%) |
| Registration page | 1/390 (0.26%) | 332/391 (84.91%) |
| Password reset page | 0/257 (0.00%) | 234/257 (91.05%) |
| Poll composer | 1/200 (0.50%) | 206/207 (99.52%) |
| Image messages | 0/222 (0.00%) | 134/223 (60.09%) |
| Payment cards | 0/232 (0.00%) | 225/232 (96.98%) |

The raw result remains below the 70% CI target. The non-generated row is a separately labeled reference view, not the CI result. Source fixes/formatting slightly change instrumented line totals. Module measurements come from complete runs, not merged selective runs.

### Behavior and defects verified

- Authentication: token restoration inside its existing lock, official Matrix error-code mapping independent of human wording, concurrency exclusion, credential preservation/removal, account switching, delayed sync failure and signed-out guards. Fixed restoration rejecting itself and wrong Matrix error categorization.
- Real SQLite: in-memory Drift/SQLite databases execute inserts, duplicate imports, room/time paging, FTS search/index rebuild/deletion, checkpoint upserts, archive statistics, media pinning, thumbnail protection, age/size filters and cleanup accounting. Blank FTS input previously caused SQLite syntax errors; it now returns no matches/count zero. Generated SQL mapping coverage is reported in the raw figure.
- Favorites and forwarding: persistence across repository recreation, rich message serialization, copy-on-write cache updates, concurrent first saves, rejected/false writes, corrupt/read-unavailable storage, retry recovery, reactions/replies/edits/redaction and mixed-success forwarding. Fixed optimistic success after storage failure, lost concurrent first saves and null forwarding results being counted as successful. Cross-key deletion is not atomic (STORAGE-001).
- Stories: unread grouping and ordering, ownership filtering, viewed state and its 500-ID cap, media/music payloads, failed uploads, absent posted events, ID resolution for deletion and viewer mapping. Matrix I/O is mocked; this is not server-side publication verification.
- Auth UI: terms gate, invalid inputs, normal/anonymous dispatch, loading prevention, failure draft retention, successful navigation, password-reset stages and resend cooldown. Fixed anonymous toggle Material background and homeserver validation disagreeing with trimmed submission.
- Poll UI: real taps through validation/send/schedule/cancel, anonymous and multi-select controls, blank-option filtering, correct-answer remapping after deletion, quiz single-select enforcement, English/Arabic 320-pixel layout. Fixed quiz switching back to multi-select and narrow header/settings overflow.
- Images: manual download, pending policy, disposed widgets, aspect bounds, view-once access denial after consumption and preview callback. Fixed stale policy completion overriding a replacement image, policy failure bypassing manual-download preferences, and the view-once placeholder overflowing with unknown dimensions.
- Payment/red-packet cards: sender/receiver statuses, currency amounts, accessibility labels, detail callbacks and Arabic dark layout. No payment or chain transaction was sent.

Static analysis: zero errors/warnings, 173 existing infos. A separate local screenshot fixture is used for visual review; its execution is not included in the 6,007 count. No device install, account mutation, private-key access or real message send was performed.

### Host integration recorded with round 1

正式插件提交 `58ed5f9b07277a211f84da505f6718c2716a8f86`。实际 Git 依赖下 136 项回归通过，宿主相关 109 项检查通过；宿主静态检查 0 错误、0 警告、155 条 info。767 个 lib/assets 文件与 Git 缓存哈希一致。此轮未重跑宿主完整覆盖率，宿主整体数据仍使用明确标注的历史基线。机器统计见 [COVERAGE_EXPANSION_2026-09-13.json](COVERAGE_EXPANSION_2026-09-13.json)。

### Remaining boundaries

The ledger records three directly observed gaps: favorite deletion spans separate keys (STORAGE-001); persisted favorite tags/remarks have no UI read/edit path (UI-001); email confirmation accepts but does not use its code/address arguments (AUTH-001). Tests do not certify these as complete. Existing AI service/group-bot, sticker distribution, localization and multi-device acceptance gaps remain in `OPEN_ISSUES.md`.

---

<a id="round-2"></a>

## Chat 分模块覆盖率扩展：第二轮

原路径：`COVERAGE_ROUND2_2026-09-13.md`。

正式插件基线：`1985645`；本轮提交：`e38d6fb43bd61227352ec9cdb54dbb18e8e7c069`。基线和最终结果均重新运行完整 `flutter test --no-pub --coverage --concurrency=4`，不使用工作区残留的旧 lcov 作为基线。

新增 **84 项**行为测试：贴纸仓库 38 项、备份文件与恢复 34 项、聊天导出与分享 12 项。全量从 **6,008 → 6,092 项通过**，均有 1 项需要在线凭据的测试跳过。宿主新增入口复用这 84 项测试，对实际 Git 依赖执行回归；这是同一批用例的集成复验，不计为另增 84 项独立用例。

| 模块 | 基线覆盖行 | 最终覆盖行 | 覆盖率变化 |
|---|---:|---:|---:|
| 贴纸仓库 | 48 / 145 | 135 / 145 | 33.10% → 93.10% |
| 备份服务 | 254 / 585 | 393 / 589 | 43.42% → 66.72% |
| 导出服务 | 71 / 166 | 140 / 167 | 42.77% → 83.83% |
| 原始 lcov，包含生成代码 | 27,829 / 131,164 | 28,117 / 131,169 | 21.22% → 21.44% |
| 排除生成代码的参考视图 | 26,696 / 79,249 | 26,984 / 79,254 | 33.69% → 34.05% |

参考视图排除 `*.g.dart`、`*.freezed.dart` 和 `lib/l10n/`；原始口径完整保留。没有降低 CI 门槛或删除未覆盖生产文件。插件整体覆盖仍偏低，本轮提升主要集中在表列三个模块，不能据此宣称全部功能覆盖完成。

### 测试发现并修复的问题

1. 完整备份和增量备份的文件名仅精确到分钟，连续创建会覆盖上一份文件。现加入唯一备份 ID；回归验证路径不同且上一份文件字节不变。
2. v3 AES-GCM 加密曾将按块向上取整的整个缓冲区写入文件，部分长度下认证标签位置错误，正确密码也无法恢复。现只写入实际加密输出。读取兼容历史末尾补零布局，仅在 GCM 认证成功时接受，最多尝试 15 字节补零，不跳过认证。
3. 同名聊天在同一秒导出时，HTML/JSON/TXT 文件会覆盖先前结果。现每次使用独立临时目录，保留分享接口正在引用的文件。

密码与完整性回归覆盖多种载荷长度、错误密码、缺失密码、截断文件、salt/nonce/tag/密文篡改和旧格式恢复。独立 Python `cryptography` 生成的公开合成样本验证标准及历史格式的互操作；固定测试盐、nonce、密码仅存在于测试样本，生产仍使用安全随机数及原 PBKDF2 参数。

导出测试通过真实临时文件验证排序、日期范围、文件名路径处理及阅后即焚内容过滤，拦截平台分享通道检查已生成的文件；没有调用真实分享界面。贴纸测试覆盖缓存刷新、订阅通知、上传类型、失败后保留原数据、增删改和检索。

### 证据与验证范围

- [机器可读结果与哈希](coverage-round2-2026-09-13/summary.json)
- [完整基线 lcov（gzip）](coverage-round2-2026-09-13/baseline.lcov.gz)
- [完整最终 lcov（gzip）](coverage-round2-2026-09-13/final.lcov.gz)
- 正式插件静态检查：0 错误、0 警告，173 条既有 info。
- 宿主实际 Git 依赖下 124 项检查通过；静态检查 0 错误、0 警告、155 条 info。运行时 767 个 lib/assets 文件与固定 Git 依赖逐一核对哈希。

本轮未改动手机安装，也未进行真实账户备份、消息发送、在线贴纸上传或新的真机验收。上轮真机 tag 保持原指向。本轮发现的问题及修复证据已写入正式插件 `OPEN_ISSUES.md` 的 BACKUP-001 / BACKUP-002。

---

<a id="round-3"></a>

## Chat 分模块覆盖率扩展：第三轮

原路径：`COVERAGE_ROUND3_2026-09-14.md`。

本轮于 2026-09-13 开始、2026-09-14 完成。基线为正式插件 `e38d6fb43bd61227352ec9cdb54dbb18e8e7c069`。复用第二轮在该提交上完成的完整测试 trace，并校验原始 SHA-256；开始工作时正式插件无未提交改动。最终结果重新运行完整 `flutter test --no-pub --coverage --concurrency=4` 得到，没有使用仓库残留的旧覆盖率文件。

正式插件提交：`dba781335dfe4238b5de1a5efbac709d62c28751`。

新增 **74 项独立测试**：搜索仓库 43 项，真实 SQLite 下的归档搜索仓库与服务 31 项。插件全量 **6,092 → 6,166 项通过**，1 项需要在线凭据的测试跳过。宿主通过新增测试入口对固定 Git 依赖复用这 74 项用例，不重复计入独立用例数。

| 模块 | 基线覆盖行 | 最终覆盖行 | 覆盖率变化 |
|---|---:|---:|---:|
| 搜索仓库 | 25 / 198 | 205 / 208 | 12.63% → 98.56% |
| 归档搜索服务 | 0 / 30 | 31 / 31 | 0.00% → 100.00% |
| 归档数据库 | 182 / 321 | 206 / 345 | 56.70% → 59.71% |
| 原始 lcov，包含生成代码 | 28,117 / 131,169 | 28,418 / 131,204 | 21.44% → 21.66% |
| 排除生成代码的参考视图 | 26,984 / 79,254 | 27,284 / 79,289 | 34.05% → 34.41% |

参考视图排除 `*.g.dart`、`*.freezed.dart` 和 `lib/l10n/`。原始口径完整保留，未降低 CI 门槛或移除未覆盖生产文件。模块提升不代表插件整体已达到覆盖目标。

### 修复及界面对接

1. 全局搜索的归档结果忽略了发送人、消息类型、时间、“仅自己发送”和“仅媒体”条件。22 项初始 SQLite 用例中 21 项在旧实现上失败。现将界面已有的 MessageSearchFilter 经 SearchBloc、搜索仓库和归档服务传入参数化 SQL，在 LIMIT/OFFSET 之前筛选，避免错误结果挤掉后续匹配消息；隐藏/锁定会话的排除条件继续生效。缺少登录身份时，“仅自己发送”返回空结果。
2. 聊天内加载更多时，新消息插入或原消息删除会使当前索引指向另一条消息或越界。3 项定位回归在旧实现上全部失败。现在优先保持原选中消息 ID；消息已删除时回退到有效索引，无结果时设为 -1。

现有全局搜索和聊天内搜索页均有筛选面板与 Bloc 对接，本轮修复直接作用于已有入口。SQL 类型判定保留现有归档映射器的事件类型优先级、未知类型按文本处理的行为，以及 m.audio 对应 voice 的表示；界面的 Audio 条件可检索这些音频归档。没有增加新的归档消息类型支持。

其他回归覆盖用户名/ENS 解析与失败回退、联系人头像、群聊和私聊结果、隐私状态读取失败、实时/归档去重与排序、归档故障降级、组合筛选、日期边界、分页偏移、SQL 参数绑定、摘要和计数。

### 验证证据

- [机器可读覆盖率与哈希](coverage-round3-2026-09-14/summary.json)
- [基线 trace](coverage-round3-2026-09-14/baseline.lcov.gz) / [最终 trace](coverage-round3-2026-09-14/final.lcov.gz)
- [全量测试日志](coverage-round3-2026-09-14/full-tests.log.gz) / [插件静态检查](coverage-round3-2026-09-14/analyze.log.gz)
- 旧实现失败证据：[归档筛选](coverage-round3-2026-09-14/archive-before-fix.log.gz) / [分页定位](coverage-round3-2026-09-14/pagination-before-fix.log.gz)
- 正式插件静态检查：0 错误、0 警告、173 条既有 info。
- 宿主固定 Git 依赖下 **198 项检查通过**，静态检查 0 错误、0 警告、155 条既有 info：[测试日志](coverage-round3-2026-09-14/host-tests.log.gz) / [静态检查](coverage-round3-2026-09-14/host-analyze.log.gz)。
- 767 个 lib/assets 运行时文件与实际 Git 依赖逐一核对 SHA-256；没有以缓存镜像替代正式依赖。
- 本轮未重跑宿主全量覆盖率，上表整体数字均指正式 Chat 插件。

本轮使用合成数据、本地数据库和模拟 Matrix 接口；未安装或卸载手机应用，未发送真实消息，未进行新的真机或线上 homeserver 验收。已有真机 tag 保持原指向。正式插件问题台账已记录 SEARCH-001 / SEARCH-002 的修复与验证范围。

---

<a id="round-4"></a>

## Chat 分模块覆盖率扩展：第四轮（2026-09-14）

原路径：`COVERAGE_ROUND4_2026-09-14.md`。

基线正式插件：`dba781335dfe4238b5de1a5efbac709d62c28751`。开始时正式插件与宿主均无未提交改动；复用第三轮完整 trace 并校验 SHA-256，最终重新运行完整 `flutter test --no-pub --coverage --concurrency=4`。没有使用仓库残留的旧覆盖率文件。

正式插件提交：`ce0483338d859e4c483506fe3a7f1c29e1a581ec`。

新增 **105 项独立测试**：联系人 32、会话 24、群组持币校验 49。插件全量 **6,166 → 6,271 项通过**，1 项在线凭据测试跳过。宿主入口复用这 105 项测试，对实际 Git 依赖执行回归，不重复计数。

| 模块 | 基线覆盖行 | 最终覆盖行 | 覆盖率变化 |
|---|---:|---:|---:|
| 联系人仓库 | 47 / 139 | 127 / 141 | 33.81% → 90.07% |
| 会话仓库 | 90 / 167 | 133 / 167 | 53.89% → 79.64% |
| 群组仓库 | 93 / 226 | 171 / 260 | 41.15% → 65.77% |
| Matrix 群组数据源 | 11 / 372 | 29 / 374 | 2.96% → 7.75% |
| 原始 lcov，包含生成代码 | 28,418 / 131,204 | 28,636 / 131,242 | 21.66% → 21.82% |
| 排除生成代码的参考视图 | 27,284 / 79,289 | 27,502 / 79,327 | 34.41% → 34.67% |

参考视图排除 `*.g.dart`、`*.freezed.dart` 和 `lib/l10n/`。原始口径保留；没有降低 CI 门槛、移除未覆盖代码，或把不可达的群成员懒加载分支删除来提高百分比。宿主整体覆盖率本轮未重新测量。

### 测试确认并修复

- 联系人搜索漏掉界面显示的备注，名称两侧空格导致无结果；首次打开黑名单时未加载备注。3 项旧实现失败用例验证修复。会话搜索也统一处理外部空格和空白查询，另有 2 项旧实现失败证据。
- 持币校验读取失败、房间不可用或部分配置损坏时，旧实现可能按“无门槛”放行。现在准入检查使用严格读取，启用配置必须含有效规则；错误通过实际 AcceptGroupInvite Bloc 路径阻止加入。保存无效配置同样进入设置页已有错误状态，不发出状态写入。
- 原生币余额经过 double 会丢失最小单位；比门槛少 1 wei 时可能误通过。现从十进制字符串直接计算 BigInt，保留 18 位精度；错误、负数、超精度余额不能以零余额替代。当前 UI 支持的 Ethereum、Optimism、BSC、Polygon、Arbitrum 分别查询对应钱包资产；未知原生币链不再回退到 ETH。

42 项最初的持币用例中 21 项在旧实现上失败。最终扩展到 49 项，覆盖 ERC-20/721/1155、AND/OR、RPC 错误、合约与 token ID 校验、余额边界、房间状态读取及保存权限。使用实际数据源、仓库和部分 Bloc，Matrix 与钱包 RPC 接口均由合成替身提供，没有真实消息、链上调用或交易。

联系人测试还覆盖备注写入失败后保留旧值、删除失败、好友邀请和在线状态快照；会话测试覆盖创建失败、未读徽标去重、输入状态超时与取消订阅。修复使用现有联系人、会话搜索、接受群邀请和持币设置入口。

### 仍未完成的准入路径

**GROUP-001 保持开放**：按群别名/直接加入的方法仍直接调用 SDK，没有同样的持币校验；本轮也没有验证服务端持币准入协议。因此这些本地检查不能被宣称为完整、服务端强制的持币群访问控制。正式插件 OPEN_ISSUES.md 已记录证据与下一步；本轮修复分别记在 CONTACT-001 / GROUP-002。

正式插件静态检查：0 错误、0 警告、173 条既有 info。宿主新 Git 依赖下 **303 项检查通过**，静态检查 0 错误、0 警告、155 条既有 info。767 个运行时文件及本轮 3 个测试文件已与实际 Git 依赖逐一核对。

### 验证证据

- [宿主测试日志](coverage-round4-2026-09-14/host-tests.log.gz) / [宿主静态检查](coverage-round4-2026-09-14/host-analyze.log.gz)
- [机器可读结果与哈希](coverage-round4-2026-09-14/summary.json)
- [基线 trace](coverage-round4-2026-09-14/baseline.lcov.gz) / [最终 trace](coverage-round4-2026-09-14/final.lcov.gz)
- 最终显式类型标注后，另跑 [49 项持币测试](coverage-round4-2026-09-14/gate-final.log.gz) 全部通过；不重复计入新增数。
- [完整测试日志](coverage-round4-2026-09-14/full-tests.log.gz) / [插件静态检查](coverage-round4-2026-09-14/analyze.log.gz)
- 旧实现失败证据：[联系人](coverage-round4-2026-09-14/contacts-before-fix.log.gz)、[会话查询](coverage-round4-2026-09-14/conversation-before-fix.log.gz)、[持币校验](coverage-round4-2026-09-14/gate-before-fix.log.gz)。

本轮未变更手机安装、真实账户或既有验收 tag；没有新的真机验收。

---

<a id="round-5"></a>

## 第五轮：群组加入校验与并发回归 — 2026-09-14

本轮将普通群组邀请、房间 ID、别名以及共享 Matrix 房间/群组数据源的加入逻辑接入 `RoomJoinService`。频道发现页改为调用带校验的群组仓库；接受邀请的 Bloc 直接呈现仓库返回的持币验证结果，避免界面和仓库重复查询余额。

新增行为覆盖包括：非法输入、别名解析失败和异常返回、加入已知/未知房间、已加入成员、禁用/缺失/非法门控、无验证器、余额不足及 RPC 错误、校验中规则原地修改或房间缓存替换、切换账号、重复点击合并、失败后重试。别名先解析为房间 ID，校验与实际加入使用同一 ID。真实仓库、数据源和 Bloc 在 Matrix/钱包替身边界下验证成功只查一次余额、失败保留持币提示且不加入。

### 测量结果

正式插件 `c1d222e3ea9c49a5f8bc51444154eb4026d689ef`，新增 **50 项行为测试**：加入校验 48、真实邀请 Bloc 2。插件全量 **6,321 项通过、1 项在线凭据测试跳过**；最终定向回归 185 项通过。宿主使用新 Git 依赖后 **353 项检查通过**；768 个运行时文件与镜像哈希一致。插件/宿主静态检查均为 0 错误、0 警告，分别保留 173/155 条 info。

| 范围 | 第四轮基线 | 本轮全量 |
|---|---:|---:|
| 原始 lcov | 28,636/131,242（21.82%） | 28,708/131,292（21.87%） |
| 非生成代码参考视图 | 27,502/79,327（34.67%） | 27,574/79,377（34.74%） |
| 新加入校验服务 | 本轮新增 | 47/47（100.00%） |
| 群组仓库 | 171/260（65.77%） | 182/262（69.47%） |
| Matrix 群组数据源 | 29/374（7.75%） | 43/370（11.62%） |
| Matrix 房间数据源 | 0/162（0.00%） | 3/161（1.86%） |
| 群组 Bloc | 269/314（85.67%） | 266/311（85.53%） |

群组 Bloc 移除了重复校验的 3 行已覆盖逻辑，未覆盖行数仍为 45，比例因此略降；没有隐藏这一变化。原始整体结果仍低于 70% 目标，参考视图不能代替原始统计。完整基线来自上一轮 final trace，经 SHA-256 验证；本轮完整 trace 独立保存，没有拼接定向测试结果或调整排除规则。

命令：`flutter test --no-pub --coverage --concurrency=4 --reporter expanded`；宿主：`flutter test --no-pub test/features/chat/ test/quality/ --reporter expanded`。两端静态检查均使用 `flutter analyze --no-pub --no-fatal-infos`。

证据：[机器统计与 trace 哈希](coverage-round5-2026-09-14/summary.json)、[完整最终 lcov](coverage-round5-2026-09-14/final.lcov.gz)、[基线 lcov](coverage-round5-2026-09-14/baseline.lcov.gz)、[插件全量日志](coverage-round5-2026-09-14/canonical-full.log.gz)、[定向回归](coverage-round5-2026-09-14/canonical-targeted.log.gz)、[宿主回归](coverage-round5-2026-09-14/host-tests.log.gz)、[插件静态检查](coverage-round5-2026-09-14/canonical-analyze.log.gz)、[宿主静态检查](coverage-round5-2026-09-14/host-analyze.log.gz)。

### 仍未完成的准入范围

`GROUP-001` 保持开放。这是对客户端已知门控的校验补齐；尚未加入的房间不一定提供完整状态，未知房间继续遵循服务器原有加入策略。Matrix 官方规范说明邀请/预览的 stripped state 可以是不完整的历史状态，不能把本地未读到门控解释为服务器已授权访问。依据：[Matrix Client-Server API — Stripped State](https://spec.matrix.org/v1.15/client-server-api/#stripped-state)。

源码搜索还发现联系人邀请、Moments 自动邀请、语音房间、Space 和用户名注册表各自保留 SDK 加入流程，已补入正式问题台账，需按各自协议审计。其他客户端、直接 SDK 调用和服务端强制准入仍未验收。本轮没有真实余额查询、链上交易、外部入群或新的真机验收；频道发现页的路由改动经过源码核对与编译，未另做真机点击认证。原真机验收 tag 保留原指向。
