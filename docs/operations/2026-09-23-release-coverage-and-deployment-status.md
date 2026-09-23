# N42 发布覆盖率与服务端部署状态

审计日期：2026-09-23（America/Toronto）
代码基线：coverage-70 工作分支，基于 `master@bb861f310`
关联计划：[覆盖率与服务端运维并行计划](../superpowers/plans/2026-09-22-release-coverage-and-server-operations.md)
既有拓扑/服务手册：[N42 全后台与 Chat 插件部署盘点及运维手册](2026-08-24-backend-chat-deployment-runbook.md)

> 本文记录仓库内可重现的测试和配置检查，不代表 2026-09-23 对生产服务器进行了探测或部署。本文不含密钥值。

## 1. 执行摘要

- 主 Flutter CI 要求仍为 70% 行覆盖率。最新完整套件通过（5,829 passed、0 failed、0 skipped），覆盖率为 **72,033 / 132,316 = 54.4401%**；现有质量门如实失败，未降低阈值、排除生成代码或跳过测试。
- Chat 插件兼容基线全包复测为 **6,742 passed / 3 skipped / 0 failed**，覆盖率 **35,400 / 135,262 = 26.1714%**；建议的 70% 尚未设置为阻断门槛。
- Go 与 Python 的覆盖报告按服务分别保存，不与 Flutter LCOV 混合。LiveKit JWT 72.8%、AI Proxy 78%、Payment Sandbox 92% 已高于建议的 70%；其余服务仍不足。
- 本轮未获得服务器 SSH 登录凭据或明确目标环境，因此没有远程登录、生产变更或部署。SSH 公钥、SSH 私钥和 HTTPS TLS 证书是不同用途的凭据。
- `swap` 当前服务端仍未见 token 级用户认证；上线前必须先追踪调用方并确定兼容的 UUID/token 验证合同。不能仅凭客户端 UUID、CORS 或公网 TLS 作为身份验证。

## 2. 覆盖率和测试结果

| 组件 | 本轮验证 | 新鲜覆盖率 | 门槛状态 |
|---|---|---:|---|
| Flutter 主应用 | 兼容版 Chat pin 更新、钱包 bridge、CoinPriceAlertService、token-model、Session Key、ENS、Paymaster、AA 主页/批量交易主体、私钥导入、链详情面板与 BTC 家族发送回归后完整 `flutter test --no-pub --coverage --concurrency=4 --machine`；质量门计数 5,829 通过、0 失败、0 跳过 | 72,033 / 132,316 = **54.4401%** | `.github/workflows/ci.yml` 70% 门槛保持不变，未通过 |
| Chat 插件 | 基于 `7586c391` 的兼容提交 `c9a607c1` 全包 `flutter test --no-pub --coverage --concurrency=2 --machine`；质量门计数 6,742 通过、0 失败、3 跳过；全包 analyze 报告 278 条既有 info、无 warning/error | 35,400 / 135,262 = **26.1714%** | 独立报告已接入 CI；建议 70% 门槛暂不阻断 |
| Go `swap` | `go test ./...`、`go vet ./...`；另测 quote/commit/alert handler 边界和 SQL mock 持久化合同 | **39.9%** 语句覆盖率；`db` package 78.4%，alert handlers 48.1% | 报告/制品已接入，未设 70% 阈值 |
| Go `social-auth` | `go test ./...`、`go vet ./...`；覆盖 Telegram HMAC、handler 边界、本地 `httptest` OAuth 路径及环境配置解析 | **40.8%** 语句覆盖率；OAuth exchange 88.5%、JSON provider helper 85.7% | 报告/制品已接入，未设 70% 阈值 |
| Go `loyalty` | `go test ./...`、`go vet ./...`；覆盖奖励输入 fail-closed、授权/身份边界、`/tasks` 故障和必需配置/内部 token 长度校验 | **30.8%** 语句覆盖率；远端授权验证器 100%，`tasks` handler 89.5% | 报告/制品已接入，未设 70% 阈值 |
| Go `livekit-jwt` | `go test ./...`、`go vet ./...`；新增配置边界测试 | **72.8%** 语句覆盖率 | 超过建议 70%，仍只报告、不阻断 |
| Python `ai-proxy` | 13 项 unittest；新增授权失败、上游异常、handler 输入边界 | 153 条可执行语句；**78%** 行覆盖率 | 独立报告已接入，未设 70% 阈值 |
| Python `payment-sandbox` | 47 项 unittest | 510 条可执行语句；**92%** 行覆盖率 | 独立报告已接入，未设 70% 阈值 |
| JMT verifier | `packages/n42_jmt_verify` 下 `dart test` | 13 项通过；尚无独立覆盖门槛 | 主 CI 已加包内依赖解析和独立测试步骤 |

覆盖统计必须遵守各自分母：Flutter/Chat LCOV 只统计 `DA` 可执行行；Go 报告使用 Go statement coverage；Python 覆盖排除测试源文件并收集 branch 数据。不同语言及组件的数字不可相加。

## 3. 本轮修复与 CI 配置

### Flutter 主应用 / Chat

- 修复「+」面板首屏回归：Quick Reply 仅在存在回调时显示，避免不可用入口占据首屏位置；保留“Apps 应在首屏”的回归断言。
- Firebase Messaging 权限枚举采用保守默认分支，将旧 SDK 未识别的状态（含新版 permanent denial）映射到 denied，兼容宿主锁定版本和 Chat 独立依赖解析。
- 新增钱包数值解析边界测试、EVM 收据状态测试和 Gas Tracker 测试（EIP-1559 fee history、legacy fallback、base-fee 缺失、估算耗时格式）；另有断网时 Gas Tracker 卡片展示 fallback 状态的 widget 测试。Gas Tracker API 文件覆盖 79.63%，交易状态解析器覆盖 39.45%，卡片文件单测命中 89/253 行。
- 新增 keystore 备份的公钥/私钥可见性及密码门禁组件测试，以及 NFT 空列表、搜索清除测试；后者不请求真实链/API。为了避免报告误读，再次完整跑根套件（5,742 通过、0 跳过）后覆盖率为 48.5057%。
- 新增 add-token widget 边界测试（空地址、缺少链配置、超 18 位小数 fail-closed）；网络客户端通过测试 override 阻断。随后重新跑完整应用套件：5,745 通过、0 失败、0 跳过，64,622/132,307 = 48.8425%；70% 覆盖门禁仍按要求失败。
- 新增 Gas Tracker 卡片离线 fallback、提醒阈值验证/保存/恢复，以及 Sui 转账余额、自转和 dry-run 失败测试；网络/签名均由本地 fake 隔离。最新完整根套件为 5,750 通过、0 失败、0 跳过，65,535/132,310 = 49.5314%；70% 门禁仍保持失败。
- 追加 Gas 设置页速度/自定义输入/返回值断言，以及 XRP 数量与 reserve+fee 校验测试后再次全跑：5,753 通过、0 失败、0 跳过，66,253/132,310 = 50.0741%；70% 门禁仍保持失败。
- 再追加 ALGO 与 TRX 发送输入/余额/自转校验，完整套件最终为 5,757 通过、0 失败、0 跳过，66,836/132,310 = 50.5147%；70% 门禁依旧失败且未改门槛。
- 再追加 ENS 首页 empty/retry 与 NFT 信息卡 metadata/actions 测试，完整套件为 5,761 通过、0 失败、0 跳过，67,392/132,310 = 50.9349%；70% 门禁依旧失败。
- 追加市场详情缺失身份 fallback 与钱包币种搜索历史/排序测试后，完整套件为 5,764 通过、0 失败、0 跳过，67,931/132,310 = 51.3423%；70% 门禁依旧失败。
- 新增 TON 转账余额/数量与 Solana 无效配置短路测试后，完整套件为 5,767 通过、0 失败、0 跳过，68,374/132,313 = 51.6760%；70% 门禁依旧失败。
- 新增钱包首页初始加载及邮箱更新重试异常回归后，前一版本完整套件为 5,772 通过、0 失败、0 跳过，68,782/132,314 = 51.9839%。切换至插件独立修复分支并追加主 app 镜像回归后，完整套件为 5,773 通过、0 失败、0 跳过，覆盖率仍为 51.9839%；70% 门禁依旧失败且未改门槛。
- 新增钱包首页 watch-only 钱包可收款但不能发起发送、无助记词时 fail-closed、未备份钱包需确认备份三条 widget 回归后，目标页覆盖率由 32/306（10.5%）升至 119/306（38.9%）。最新完整套件 5,776 通过、0 失败、0 跳过，69,052/132,314 = 52.1880%；70% 门禁依旧失败且未改门槛。一次探索性的首页滚动/代币搜索测试因测试视口未挂载目标图标而移除；未改生产行为，搜索入口仍需后续通过稳定交互路径补测。
- 为 NFT 画廊加入可选 API 注入 seam（默认仍使用真实 SimpleHash API），以真实页面加本地固定响应验证垃圾 NFT 默认隐藏与显式显示、ERC1155 类型过滤、名称搜索及系列分组。定向 4 项通过；`nft_list_page_widgets.dart` 覆盖率 238/311 = 76.53%（基线 52/311），`nft_list_page.dart` 为 83/133 = 62.41%。完整套件 5,779 通过、0 失败、0 跳过，69,265/132,315 = 52.3486%；70% 门禁依旧失败且未改门槛。
- 新增对真实 `WalletActionProvider` 的查找优先级、默认钱包删除后索引钳制、空列表删除，以及缺少 N 链派生元数据时跳过密钥读取的行为测试。定向 5 项通过；provider 钱包操作文件由基线 35/284 升至 64/284（22.54%）。完整套件 5,784 通过、0 失败、0 跳过，69,298/132,315 = 52.3735%；70% 门禁依旧失败且未改门槛。
- 为 Add Token 页增加可选 TokenView API seam（生产默认仍用线上 API），以固定完整链/代币目录覆盖真实搜索、目录解析、Trustdart 地址校验及钱包 token 写入。搜索到 USDT 并添加后断言钱包主网代币表含正确 symbol/name/decimals 与非自定义来源；定向文件 4 项通过，相关 data 解析为 144/165（87.27%）、添加逻辑为 105/304（34.54%）。完整套件 5,785 通过、0 失败、0 跳过，69,539/132,316 = 52.5552%；70% 门禁依旧失败且未改门槛。
- 另批测试覆盖 Add Token 网络选择器从“全部网络”切换到 Ethereum 后更新活动链筛选并保留该链 USDT 搜索结果。定向文件 5 项通过、单文件 analyze 无 issue；完整套件 5,786 通过、0 失败、0 跳过，69,621/132,316 = 52.6172%；70% 门禁依旧失败且未改门槛。
- 新增 SOL SPL 发送缺少父 SOL 钱包时的 fail-closed widget 回归；定向文件 2 项通过、`dart analyze` 无 issue。`wallet_chain_send_sol_logic.dart` 定向行覆盖从原 7/223 增至 15/223；全量套件 5,787 通过、0 失败、0 跳过，69,647/132,316 = 52.6369%，70% 门禁如实失败。
- 新增 wallet transaction sync mixin 的内存 SQLite 行为测试，覆盖本地历史分页、ETH 插入/更新、TRX 合约过滤、SOL 时间戳刷新和 BTC 确认数/净转出金额；5 项通过、单文件 analyze 无 issue，mixin 定向覆盖 158/243 行。完整套件 5,792 通过、0 失败、0 跳过，69,842/132,316 = 52.7842%；70% 门禁依旧失败，未调整阈值。
- 扩充 `N42WalletBridge` 行为测试：支付 URI 编码与到期时间、空接收地址、EVM/N 链地址边界、NFT 参数拒绝、Aptos 与 EVM chain ID 碰撞保护，以及 token metadata 查询对无效地址/错误链 fail-closed。定向两个测试文件 31 项通过、analyze 无 issue；桥接文件定向覆盖由 80/310 升至 141/310。完整套件 5,799 通过、0 失败、0 跳过，69,903/132,316 = 52.8303%；70% 门禁依旧失败。
- 为 Chat bridge 增加有效 transfer 到选定链 sender 的分支回归，验证 unsupported chain 返回原有错误而不发起网络/签名调用；该定向文件 22 项通过，`analyze` 无 issue。钩子同步 bump build number 后重跑最终完整主套件：5,800 通过、0 失败、0 跳过，69,920/132,316 = 52.8432%；70% 门禁依旧失败。

### ALGO 最小余额回归修复

ALGO 发送页此前在成功加载最小余额后，会将 `AlgoModel.minBalance`（`BigInt`）直接传给要求 `String` 的 `toEther`，页面构建抛出 `_BigIntImpl is not a subtype of String`。经用户批准，新增成功加载最小余额的 widget 回归测试，先确认红灯复现，再将该值显式转为十进制字符串。定向测试 3 项全部通过；随后全量根套件 5,768 项通过，覆盖率 68,377/132,313 = 51.6782%。
- 新增 Chat 全包 CI：[`.github/workflows/chat-package.yml`](../../.github/workflows/chat-package.yml)。它直接在 `packages/n42_chat` 解析依赖、运行全包测试并上传独立 LCOV；目前只报告，不做 70% 阻断。
- 内置动画贴纸修复已在 Chat 独立仓库分支 `fix/offline-bundled-stickers-20260923` 提交 `a36d32569ee83c8c61ff92a893616744d2a91cbb`，并由 app 通过 `pubspec.yaml` 与 `pubspec_overrides.yaml` 同步 pin。后续过期状态清理修复提交 `7586c391b50c2086b033ed9626ad4c6eeeecf8c1`；app 当前 pin 到该提交，lockfile 已解析确认。双方 N42 客户端用稳定 `org.n42.sticker` pack/sticker ID 本地解析捆绑资源；发送不再上传重复媒体，未知 ID 仍保留 mxc/media fallback。定向测试覆盖发送端、接收端、未知 ID 兼容，共 5 项通过；过期状态清理的独立回归也通过。动画素材从贴纸面板的 `Animated` 包访问；GIF 搜索列表仍依赖在线 Giphy/Tenor，不等同于离线 GIF 搜索。
- 状态清理的根因是过期/空状态在没有状态故事房间时仍调用创建逻辑，创建失败后旧 presence 文本继续显示。现在清理状态不再新建房间，仍保留 presence 类型并清除状态文本；Chat 插件定向回归和主 app 定向镜像回归通过。最新兼容插件全套 6,742 项通过、3 项跳过；主 app 新 pin 全套 5,800 项通过，覆盖率为 52.8432%，70% 门槛仍未通过。
- 新增 `CoinPriceAlertService` 持久化回归，验证缺省状态、跨币种保存/更新、定向幂等删除以及损坏 JSON 的 fail-closed；4 项定向测试通过。后续串行主套件新鲜证据为 5,804 项通过、0 失败、0 跳过，LCOV 从 69,920/132,316 提升至 69,968/132,316（52.8795%）；运行结果 `/tmp/n42-app-tests-price-alert-batch-serial.jsonl`。70% 覆盖率门仍未通过。
- 随后的 provider 批次补充两项真实 token 模型/钱包状态测试：验证 token 继承其所属链账户路径与地址上下文、主网 token 添加入钱包映射且重复添加不重复呈现。定向测试与 analyze 均通过；提高进程文件句柄限制后完整套件 5,806 项通过、0 失败、0 跳过，LCOV 69,982/132,316 = 52.8901%；运行结果 `/tmp/n42-app-tests-token-batch.jsonl`。覆盖率离 CI 的 70% 仍差 17.1099 个百分点。
- 追加 testnet token 添加与 token 移除回归，确认测试网映射路径、余额模型呈现、pin key 的定向清理和无关 pin 保留。token provider 定向测试 4 项通过、analyze 无问题；完整套件 5,808 项通过、0 失败、0 跳过，LCOV 70,002/132,316 = 52.9052%；运行结果 `/tmp/n42-app-tests-token-extra-batch.jsonl`。70% 门仍未通过。
- Session Key 卡片新增 4 项 widget 行为测试，覆盖 active 状态的权限/额度/交易信息、撤销的取消与确认分支、expired 状态隐藏 active-only 控件以及地址复制反馈；定向 LCOV 达 207/220 行、analyze 无问题。完整套件 5,812 项通过、0 失败、0 跳过，整体 LCOV 70,250/132,316 = 53.0926%；运行结果 `/tmp/n42-app-tests-session-key-card.jsonl`，70% 门仍未通过。
- ENS 搜索结果组件扩展到 5 项行为测试，覆盖初始建议回调、查询 loading、可用域名的注册年限/注册回调、已占用域名 owner/到期信息及错误脱敏；定向覆盖 223/226 行且 analyze clean。完整套件 5,816 项通过、0 失败、0 跳过，LCOV 70,546/132,316 = 53.3163%；运行结果 `/tmp/n42-app-tests-ens-search-view.jsonl`，70% 门仍未通过。
- 新增 Paymaster 选择页 widget 回归，覆盖不支持链加载后保留自付选项并通过 Navigator 返回所选值，以及不可用赞助选项不可选；定向 2 项通过、单文件 analyze clean。完整套件 5,818 项通过、0 失败、0 跳过，LCOV 70,858/132,316 = 53.5521%；运行结果 `/tmp/n42-app-tests-paymaster-page.jsonl`，70% 门仍未通过。
- 新增 AA 主页 widget 回归，覆盖无效 EVM 地址的不可用提示/禁用入口，以及有效 owner 地址无智能账户时的三步引导；定向 2 项通过、单文件 analyze clean。完整套件 5,820 项通过、0 失败、0 跳过，LCOV 71,160/132,316 = 53.7803%；运行结果 `/tmp/n42-app-tests-aa-home-page.jsonl`，70% 门仍未通过。
- 新增 AA 批量交易主体 widget 回归，覆盖空列表引导/提交禁用，以及含操作时的赞助 Gas、估算错误、删除/清空和 paymaster 操作；定向 2 项通过、单文件 analyze clean。完整套件 5,822 项通过、0 失败、0 跳过，LCOV 71,530/132,316 = 54.0600%；运行结果 `/tmp/n42-app-tests-aa-batch-body.jsonl`，70% 门仍未通过。
- 新增私钥导入页面空值/畸形输入回归，验证无效输入在原生地址派生和钱包写入前 fail-closed；仅使用非敏感无效字符串，定向 2 项通过、单文件 analyze clean。完整套件 5,824 项通过、0 失败、0 跳过，LCOV 71,671/132,316 = 54.1665%；运行结果 `/tmp/n42-app-tests-import-privatekey.jsonl`，70% 门仍未通过。
- 新增链详情资产面板 widget 回归，验证余额信息展示、发送/收款/浏览器操作回调与可选锁定信息入口；`BTC` 类型让 ENS 展示走本地不支持分支。定向 2 项通过、单文件 analyze clean；完整套件 5,826 项通过、0 失败、0 跳过，LCOV 71,750/132,316 = 54.2262%；运行结果 `/tmp/n42-app-tests-wallet-chain-info-board.jsonl`，70% 门仍未通过。
- 新增 BTC 家族（LTC）发送页 widget 回归：验证 DApp 收款地址/金额预填且锁定、余额展示、超余额和非数字输入错误反馈，以及超余额时点击发送不进入确认/签名路由。定向 3 项通过，单文件 analyze 无问题；`wallet_chain_send_btc_widgets.dart` 覆盖 167/223 行（74.9%），`wallet_chain_send_btc_logic.dart` 覆盖 47/117 行（40.2%）。完整套件 5,829 项通过、0 失败、0 跳过，72,033/132,316 = 54.4401%；运行结果 `/tmp/n42-app-tests-btc-send.jsonl`，70% 门仍未通过。

### Go / Python 服务

- `.github/workflows/ci.yml` 的 Go matrix 为四个服务分别保存 `coverage.out` 和 `go tool cover -func` 摘要制品，并运行 `go vet`。
- 追加 Go 请求/配置边界测试后，各次独立本地全量/`go vet` 验证结果：`swap` 39.9%（新增 SQL mock 测试使持久化 `db` package 达到 78.4%）、`social-auth` 40.8%、`loyalty` 30.8%；新增配置测试覆盖 homeserver 归一化、TTL/CORS 解析、必需变量缺失和 token 长度门槛。OAuth/provider/auth-verifier 测试只连 `httptest` loopback fixture，没有实时凭据/服务；没有改动认证合同或服务运行时代码。
- [`.github/workflows/backend-python.yml`](../../.github/workflows/backend-python.yml) 使用 Python 3.12 和 `coverage==7.6.1`，将 `ai-proxy` 与 `payment-sandbox` 分开测试、报告与上传；测试代码不计入分母。
- 依赖仅用于测试；支付沙盒维持 synthetic/local 用途，没有引入真实支付端点、账户或密钥。

### 主 CI 依赖解析

`packages/n42_jmt_verify` 是独立 Dart 包，根目录 `flutter pub get` 不会生成其自身 `.dart_tool/package_config.json`。在全新环境直接对仓库根目录 analyze 时，这会造成该包的依赖/导出无法解析；先在该包目录运行 `flutter pub get` 后，包自身分析无 error，13 项测试通过，根级 analyze 的 error 诊断也消失。主 CI analyze 和 test job 均已添加包内依赖解析，test job 也独立执行 `dart test`。

本工作树最后一次根级 `flutter analyze --no-fatal-infos` 输出无 `error •` 行，但当次总计报告 278 条 issue；警告/info 的完整分类及是否适合清理仍需单独审查，不能据此声称全仓静态分析零问题。

## 4. 服务端认证合同盘点

| 服务 | 当前代码/文档描述的认证路径 | 发布前需要的工作 |
|---|---|---|
| `social-auth` | Discord/GitHub OAuth 或 Telegram 校验，然后使用 Matrix homeserver shared secret 注册/登录并返回 Matrix 凭据 | 验证 OAuth state/nonce、Telegram 重放保护、限流、密钥轮换与 homeserver 错误处理；实测 DNS/TLS 和真实 provider 回调 |
| `livekit-jwt` | Matrix Bearer token → homeserver `whoami`/房间成员验证 → 签发 LiveKit JWT | README 标为 legacy；先确认生产流量实际走哪条路，勿因本地测试通过就部署 |
| `loyalty` | `AUTH_VERIFY_URL` 核对 UUID、token 与钱包关联 | 继续补齐上游超时、拒绝、钱包不匹配和链/数据库故障覆盖 |
| `ai-proxy` | Matrix Bearer token 验证 | 已测缺失/格式错误授权、上游错误和输入拒绝；仍需验证线上验证服务合同与超时配置 |
| `swap` | 现有说明主要按用户提交 UUID 做归属判断，未发现 token 校验 | P0：映射客户端调用和 API 网关规则，确定可兼容的可信用户身份传递，再做未认证/越权测试；在此之前不可认为适合公网发布 |
| `payment-sandbox` | 本地合成支付/ledger 测试服务 | 仅限本地与 CI；禁止生产密钥、资金或真实支付 upstream |

更完整的服务环境变量、入口路径、反向代理、健康检查和上线顺序见既有运维手册 §3–§4。现有文档里的生产可达性结论基于其注明的 **2026-08-24** 检查；本轮没有重新进行外网生产探测，因此不能当作今天的在线状态。

## 5. 服务器登录和部署边界

本工作站审计时未发现 SSH alias 配置，ssh-agent 未加载 identity。手头提及的 SSH **公钥**只能配置在服务器端 `authorized_keys`；客户端仍需匹配的**私钥**，或另一个已批准的登录机制。SSL/TLS 证书只保护 HTTPS 链路，不授予 SSH shell 权限。不要通过聊天传送私钥、服务 token、数据库 DSN 或签名密钥。

本轮因此没有执行 SSH 探测、修改服务器、防火墙、DNS、反向代理、systemd、数据库、证书或生产环境变量。后续要部署至少需要：

1. 明确 staging/production 主机、所属账号和当前实际流量入口；
2. 操作人员在本机/受控 Secret Manager 配置凭据（私钥不入仓、不经聊天）；
3. 确认部署平台、镜像仓库、secret 注入方式、备份/迁移顺序、健康检查和回滚方案；
4. 对 `livekit-jwt` legacy 状态、`swap` 认证缺口及 homeserver/API 契约取得负责人确认；
5. 先 staging 验证并留下健康检查、日志和回滚证据，之后才考虑生产变更。

## 6. Chat 回归问题与可行方案

以下四项为用户提供的回归包记录：2026-09-23，应用 2.4.8（2026072792），均标记“问题仍存在”。GIF 另确认关闭 Wi-Fi、切换移动数据仍失败。当前工作树比该构建更新；没有在旧构建或真实双端设备上验证修复。

| 问题 | 仓库证据 / 当前判断 | 下一步验证 |
|---|---|---|
| 同机切换账号后自己消息明文、他人消息仍加密 | 登录切换会切换 Matrix 用户/设备数据库并恢复本地 Olm 状态；消息仓库也会在账号变化时清时间线缓存。代码路径没有找到按发送者决定解密显示的证据。较可能是切换后该账号未取得/未恢复他人发送的 Megolm 房间密钥，但尚未用双账号设备复现。 | 在同一设备 A→B→A 流程记录事件 ID、sender/device/session ID、key share 和解密结果；现有 `test/live/account_switch_encryption_test.dart` 是真实 Matrix opt-in 场景，需 QA 环境运行。 |
| GIF 列表加载失败（Wi-Fi 和移动数据均失败） | GIF picker 直连 Giphy/Tenor，宿主编译配置关闭代理路径；服务把非 200、网络异常或解析失败统一映射为加载失败。蜂窝也失败说明问题不只是 Wi-Fi，但无法仅凭此区分发布包缺 API key、403/429/配额、DNS/TLS/运营商策略、API 端点和媒体 CDN。 | 从设备采集脱敏 host/path、HTTP 状态或 transport error、时间戳、DNS/TLS 结果；分别检查列表 API 和图片 CDN。不得记录 API key。 |
| 图片预览翻译提示端侧模型不可用，稍后重试 | 页面先走 Google ML Kit 本地翻译；失败后询问是否发送已识别文字做远端 fallback，失败再显示通用 AI 错误。ML Kit 语言模型按需下载（官方文档约 30 MB/语言），目前代码首次使用才下载；第二阶段 provider 取决于构建配置，可能为 Google API、AI proxy 或 MyMemory。 | 记录平台、源/目标语言、模型下载状态及是否同意远端；远端仅收到 OCR 文本，不应上传原图。把内部错误分类为 unsupported/model-download/network/quota/upstream，而不是只显示泛化提示。 |
| 群主有 5 个联系人并创建 3 人群后，群主添加成员列表为空；其他成员正常 | Chat 页添加成员从 `ContactBloc` 已加载列表中过滤当前成员；若该页面拿到新建/未加载的 ContactBloc 或 provider 异常，会静默保留空列表。当前逻辑没发现群主专有过滤。 | 按实际导航路径核对 ContactBloc 是否 loaded、联系人数、房间现有 member/invited IDs；补 ChatPage 层测试覆盖 5 contacts/3 members/2 available 和新建 Bloc 场景。 |

### 群话题与群组通话（新增，2026-09-23）

用户补充的问题并提供 `~/Downloads/1.mov`。源码追踪和红绿测试确认两项根因：Matrix 接受频道 state 写入后，本地房间缓存可能尚未同步，`CreateChannel` 立即重读会把旧列表发给 UI；另外“编辑”推入的新路由没有携带 `GroupBloc`，在 `GroupChannelsPage` 的 `context.read<GroupBloc>()` 触发 `ProviderNotFoundException`。已修复为创建成功后以服务端返回的 room ID 补入暂未同步的频道，并通过 `BlocProvider.value` 将现有 bloc 传入编辑路由。Widget 测试还触发 ListTile 被彩色 `Container` 遮蔽墨水反馈的 Flutter 断言，现改为 `Material`。插件提交 `c9a607c1` 已推送，app `pubspec.yaml`、`pubspec_overrides.yaml` 和 lock 均指向该兼容提交；定向 BLoC 75 项与页面导航 widget 1 项通过。兼容分支完整测试 6,742 通过、3 跳过，app 完整测试 5,800 通过。

另两项是产品行为确认，不可仅凭代码断定为缺陷：群视频通话需决定发起时全员可接听/忽略，还是先选受邀成员；群语音需区分一次性群语音通话与可持续加入的语音房。代码显示群视频方法只为当前发起者获取 MatrixRTC/LiveKit token 并加入 LiveKit 房间，没有给其他群成员广播可接听邀请的路径；群语音方法存在，但群聊 AppBar 当前没有通话入口。已向用户征求上述两项选择，收到确认前不扩展邀请与房间生命周期语义。

兼容性核对曾发现 `71823b6` 所在远端分支与现有 app Chat 快照有 415 个文件差异，并缺少 app 正在调用的直播回调/美颜 API，因此没有采用；最终依赖基于当前锁定的 `7586c391`，只携带群话题回归修复。

### 内置动画表情（离线兜底）

插件已有 16 个 Noto Animated Emoji Lottie（Apache-2.0）和 OpenMoji SVG 表情；`packages/n42_chat/assets/stickers` 约 956 KB、52 个文件。它们已可从贴纸面板的 Animated 包访问。过去发送路径会上传 asset 到 Matrix media 得到 mxc，接收渲染默认请求该媒体，不按 `org.n42.sticker` 的 `pack_id/sticker_id` 解析本地资源，因此“素材随包存在”并不等于“收发双方离线本地显示”。本轮已修复发送和接收端协议：N42 客户端发送稳定资源 ID、不上传重复媒体；接收端命中本地包时优先直接渲染 asset，未知 ID 再回退原 mxc/媒体 URL。

用户已确认仅要求双方都使用 N42 Chat。本轮保留 GIF 远端目录为在线搜索，并由现有 Animated 贴纸包提供小体积离线常用动图；收发端现在走本地资源 ID，不上传重复媒体。未知 ID 和旧消息继续兼容 mxc/媒体路径。实现已推送到插件分支并由 app pin；真实双设备、关闭 Wi-Fi/蜂窝数据下的验收仍需 QA 安装包含该依赖的构建。注意：这提供的是贴纸面板中的离线动图，不会让在线 Giphy/Tenor GIF 搜索结果离线可用。

### 图片文字翻译选项（OCR 后仅翻译文字）

仓库已有 OCR 分块与 ML Kit on-device 翻译，不需要再造图像模型：图片文字由端侧 OCR 提取，翻译层只收文字。推荐按层实施：

1. **近期可靠性：**保留 ML Kit，但在用户选定常用目标语言后提供 Wi-Fi 优先的语言模型预下载/状态检查；下载失败时给出明确“模型未下载/语言不支持/无网络”并提供重试。Google 文档说明该 API 覆盖 50+ 语言、离线运行，但模型动态下载；Android/iOS 文档均称模型约 30 MB，iOS 内存开销约 30–150 MB。不能承诺首次安装即离线可翻译。
2. **免费云端 fallback：**当前默认 MyMemory 免 key，但公开服务限额/稳定性不适合作为 SLA。可评估 Google Cloud Translation：官方当前列出每月前 500,000 字符免费额度，超额计费；需云项目、预算告警，API 凭据只能放服务端，客户端只发用户同意后的 OCR 文本。额度和价格上线前需再次核对。
3. **自有服务端模型：**若希望数据不发给第三方，可在现有服务端部署 LibreTranslate/Argos Translate 或按实际语言对部署 Marian/OPUS-MT 专用模型；自托管软件许可、模型许可、语言覆盖、CPU/RAM/延迟和并发成本必须分别审核。NLLB distilled 600M 不宜未经评估就称为“小模型”，其模型卡许可限制也需先核对。服务端仍需鉴权、限流、超时、日志脱敏和用户明确同意。

不建议把公开免费翻译端点作为生产承诺，也不建议默认把整张图片或 OCR 文本发送到第三方。先补齐调用方的可观测性和语言模型下载交互，再根据用户隐私/质量/成本选择服务端方案。

### 回归清单补充与处理状态（2026-09-23）

用户补充的回归记录对应应用 **2.4.8 (2026072792)**。该构建早于本分支若干修复；“代码已修复”不等于该回归包已验收，仍需使用新构建复测。

| # | 回归问题 | 当前判断 | 后续批次/验收条件 |
|---:|---|---|---|
| 1 | 同一手机切换账号后，自己发的消息明文、他人消息仍加密 | 仍未复现并定位；此前分析指向账号切换后的房间密钥恢复/共享路径，不能仅按发送者做显示修补 | 独立加密诊断批次；双账号同机复现并记录脱敏后的事件、设备/会话和解密结果，确认根因后再加回归测试与修复 |
| 2 | GIF 搜索列表加载失败（Wi-Fi、移动数据均失败） | 在线 Giphy/Tenor 列表仍未修复；已内置的离线动图贴纸是另一入口，不能标成 GIF 列表已解决 | 独立 GIF 网络诊断批次；在设备侧区分 API 与媒体 CDN 的 DNS/TLS、HTTP 状态和限额，日志不得含 API key；修复后验证 Wi-Fi 与蜂窝网络 |
| 3 | 图片预览翻译提示端侧模型不可用/AI 暂不可用 | 未修复；现有 OCR/ML Kit 和远端文字翻译链路需要更清晰的模型下载状态与错误可观测性 | 独立翻译批次；覆盖模型未下载、语言不支持、离线、超时/上游错误和用户拒绝远端的回归，不上传原图；外部翻译服务选型另行确认成本与隐私 |
| 4 | 群主创建三人群后添加成员列表为空，其他成员正常 | 未修复；需区分联系人 BLoC 未加载与当前成员过滤结果 | Chat 插件独立批次；覆盖 5 个联系人、3 个现有成员、2 个可添加成员，以及 Bloc 加载/错误状态；真机验收群主与普通成员一致 |
| 5 | 群话题创建后未显示 | 当前插件代码已有创建后本地列表补入修复（`c9a607c1`）；用户记录的 2.4.8 回归包仍显示问题 | 在包含该 pin 的新构建中新建频道并确认无需等待额外同步即可出现在列表；记录 QA 结果后才关闭 |
| 6 | 点击编辑群话题后白屏 | 当前插件代码已有编辑路由传递 `GroupBloc` 的修复（`c9a607c1`） | 在包含该 pin 的新构建中打开编辑、修改、保存并返回详情；记录 QA 结果后才关闭 |
| 7 | 群视频邀请未送达其余成员 | 用户已确认：通知全部当前已加入成员，每人可接受或忽略，不自动加入。实现仍待做；现有 LiveKit 路径只让发起人入房 | 独立群呼叫信令/推送/服务端批次；先确定事件协议、成员资格与过期/取消/并发呼叫语义，再实现和做多设备、后台/锁屏验收。系统通知还是 CallKit 全屏来电的选择仍待确认 |
| 8 | 群聊缺少语音入口 | 用户已确认新增一次性群语音入口，与群视频并列；不做持续可加入语音房 | 与群呼叫批次分开验收语音媒体配置、加入/离开及结束行为；依赖第 7 项邀请信令 |
| 9 | 当前登录用户点击自己的头像无法进入个人详情 | 旧实现对自己的消息头像提前返回；拟让自己消息头像进入现有个人资料页、他人仍进入联系人详情。该行为方案尚待用户确认，未改代码 | 用户确认后单独插件批次，先加头像导航 widget 回归，再最小改动与新构建验收 |
| 10 | 共享实时位置页面白屏/地图未显示 | 尚未在设备复现；页面包含在线 OSM 瓦片层，中心点/位置事件或瓦片加载任一环节可能导致空白观感，当前不能定因 | 独立定位诊断批次；分别验证房间位置状态流、经纬度/权限、瓦片网络失败状态和空数据 UI；补断网/有效位置页面回归后再修 |

以上问题按独立行为批次处理，不与覆盖率测试批次或彼此无关的聊天修复捆绑。每批须留下定向测试、适用的全量测试/静态分析证据；每个修复分别提交和推送。需要外部账号、模型/API 凭据或设备验收的项目只记录阻塞条件，不在没有可复现证据时伪造通过状态。

## 7. 重现命令

主应用完整测试和覆盖率：

```bash
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --machine > /tmp/n42-app-tests.jsonl
python3 scripts/quality_gate.py tests /tmp/n42-app-tests.jsonl
python3 scripts/quality_gate.py coverage coverage/lcov.info --threshold 70
```

Chat 插件独立报告：

```bash
cd packages/n42_chat
flutter pub get
flutter test --coverage --concurrency=4
```

Go 单服务（每个目录分别执行；不要合并不同服务）：

```bash
cd backend/livekit-jwt
go test ./... -coverprofile=coverage.out
go vet ./...
go tool cover -func=coverage.out
```

Python `ai-proxy` 示例（`payment-sandbox` 仅替换源/测试目录；依赖由 `backend/requirements-test.txt` 提供）：

```bash
python -m pip install -r backend/requirements-test.txt
python -m coverage run --branch --source=backend/ai-proxy --omit='backend/ai-proxy/test_*.py,backend/ai-proxy/test_support.py' -m unittest discover -s backend/ai-proxy -p 'test_*.py' -v
python -m coverage report -m
```
