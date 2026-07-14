# N42 App 全量测试与发布验收手册

> 文档级别：测试团队主文档（Single Source of Truth）
>
> 适用范围：Android / iOS，Wallet + Chat + 宿主公共能力
>
> 当前基线：`master` 本轮发布提交
>
> Android：`2.4.4+2026070904`
>
> iOS：`2.4.4 (202607093)`
>
> 最近更新：2026-07-14

---

## 1. 文档定位与执行规则

本文档合并并修正了以下历史材料：

- `docs/functional_test_checklist.md`：早期 50 类功能、300+ 检查项。
- `docs/manual_test_requirements_en.md`：英文详细人工测试流程。
- `docs/device-test-reports/`：T17-T25 及此前真机报告。
- `docs/RELEASE_CHECKLIST.md`：发布构建和商店检查项。
- `.github/workflows/ci.yml`：CI 实际命令和覆盖率门禁。
- `test/`、`packages/n42_chat/test/`、`integration_test/`：当前自动化代码。
- `docs/AUTOMATED_TESTING.md`：自动化测试执行、覆盖率、CI 和失败排查主文档。

本文件从 2026-07-13 起作为测试团队的主执行手册。旧文档保留作历史依据；若描述冲突，以本文件、当前可达 UI 和当前代码为准。

执行规则：

1. 每次发版先执行第 6 节自动化，再执行第 8-15 节真机用例。
2. 当前包中真实可见且可达的功能必须给出 `Pass`、`Fail` 或 `Blocked`；隐藏或未启用功能标 `N/A`。
3. “页面能打开”不等于端到端通过。交易、消息、推送、通话、恢复等必须验证最终效果。
4. 数据模型、序列化、算法等无可点击 UI 的逻辑由自动化验证；其用户可见结果仍要真机回归。
5. 凡可稳定模拟、无需真实权限/资金/第三方账号的场景，优先自动化。新增缺陷修复必须先加回归测试，再人工复测。

### 1.1 结果与优先级

| 标记 | 含义 |
|---|---|
| `Pass` | 实际结果与预期一致，并有可追溯证据 |
| `Fail` | 可执行但结果错误 |
| `Blocked` | 因账号、资金、权限、后端、设备或第三方配置无法执行 |
| `N/A` | 本构建未开启或没有用户可达入口 |
| `Not Run` | 尚未执行 |

| 级别 | 定义 | 发布规则 |
|---|---|---|
| P0 | 资产、密钥、登录、主导航、核心消息、安装启动 | 必须全部 Pass |
| P1 | 主要功能或高频用户流 | Fail 必须修复或书面豁免 |
| P2 | 次要功能、低频边界、体验回归 | 记录缺陷并评估风险 |

### 1.2 自动化标记

| 标记 | 含义 |
|---|---|
| `U` | Dart/Go 单元测试：模型、解析、算法、状态和业务规则 |
| `W` | Flutter Widget、截图、语义、溢出测试 |
| `E2E` | 真正启动 App、点击真实控件并断言结果的设备自动化 |
| `SKIP` | 自动化已登记但因夹具、资金或外部依赖明确跳过，不计 Pass |
| `M` | 必须真机人工验证 |
| `EXT` | 需要外部服务、资金、多账号、多设备或硬件 |

---

## 2. 当前发布包

| 平台 | 文件 | 版本 | 已验证 |
|---|---|---|---|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` | `2.4.4+2026070904` | 包名 `ai.n42.www`、APK v2 签名、ZIP 完整性、非 debuggable/testOnly |
| Android AAB | `build/app/outputs/bundle/release/app-release.aab` | `2.4.4+2026070904` | JAR 签名、Bundle ZIP 完整性 |
| iOS | `build/ios/ipa/N42Wallet.ipa` | `2.4.4 (202607093)` | App Store 分发签名、Team `CFRXH38L48`、production push、`get-task-allow=false`、TestFlight profile |

领包后必须独立记录 SHA-256，不能只凭文件名判断版本。测试记录必须填写 App 显示版本、原生 build number 和 Git commit。

本轮交付包 SHA-256：

- Android APK：`ece168d52f5aef13ea59aaffe0dc558416b1dff6d9a48fcb08242f796c51dee0`
- Android AAB：`bce0b42d3b8d7be158578f81ca0639962637e32940effcb98638efdd71acaa0f`
- iOS IPA：`ed54287cbaa1e27bd6e20d3e9007939253c31760b4f46fd05994c61eefb8b51e`

交付与上传：

```bash
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
shasum -a 256 build/app/outputs/bundle/release/app-release.aab
shasum -a 256 build/ios/ipa/N42Wallet.ipa
```

- Android 测试包使用 `build/app/outputs/flutter-apk/app-release.apk`；`app-debug.apk` 只用于开发调试，不作为 RC。
- TestFlight/Transporter 选择 `build/ios/ipa/N42Wallet.ipa`，不要选择 `.xcarchive`、`Runner.app` 或 Debug 包。
- 可以使用 Apple Transporter 上传该 IPA，登录账号必须有对应 App Store Connect App 的上传权限。本轮导出由 App Store Connect 自动管理构建号，IPA 内实际 build number 为 `202607093`；上传前仍须确认不存在同号构建。
- Transporter 显示 Delivery Success 只代表上传完成；仍需等待 App Store Connect 处理、加密合规检查和 TestFlight 可测试状态。

---

## 3. 安全与测试数据

1. 禁止在文档、Bug、截图、录屏、消息或日志中写真实助记词、私钥、Keystore 密码、登录密码、Access Token 或 WalletConnect URI。
2. 发布变量只由本地安全 `.env` 或 CI Secret 注入；测试记录只写“已配置/未配置”。
3. 主网实弹必须使用专用小额钱包，单笔和每日上限由发布负责人书面确认。
4. 删除钱包、恢复、远程退出设备、移除群成员等破坏性流程仅可用于可丢弃数据。
5. 地址、Matrix ID、room ID、txHash 按团队规则脱敏；完整值只放受控附件。
6. 测试账号凭据由负责人单独安全发放，不写入仓库和本手册。

---

## 4. 环境、设备与数据准备

### 4.1 最低设备矩阵

| 维度 | 必测组合 |
|---|---|
| Android | 最低支持/老机 1 台；当前主流/最新系统 1 台；至少 1 台中低端设备 |
| iOS | iOS 16 最低兼容设备 1 台；当前最新 iOS 1 台 |
| 大屏 | iPad、折叠屏或大字体至少一组 |
| 主题 | 浅色、深色、跟随系统 |
| 语言 | 简体中文、英文、一种长文案语言、一种 RTL 语言 |
| 网络 | Wi-Fi、蜂窝、无网、弱网、Wi-Fi↔蜂窝切换 |
| 权限 | 通知/相机/麦克风/相册/定位：允许、拒绝、永久拒绝 |
| 安全 | 指纹或 Face ID 开/关；系统密码存在/不存在 |

### 4.2 必备账号

| 编号 | 数据 |
|---|---|
| A1 | 全新宿主账号，用于注册、首次引导、注销或清理 |
| A2 | 长期宿主账号，含历史设置、钱包和升级数据 |
| C1/C2 | 两个 Chat 账号，用于单聊、已读、输入态、通知和通话 |
| C3 | 第三个 Chat 账号，用于群管理、邀请、移除和权限 |
| C4 | 新设备 Chat 会话，用于 E2EE、SAS 和密钥恢复 |

### 4.3 必备钱包与外部数据

| 类型 | 用途 |
|---|---|
| 空钱包 | 空状态、余额不足、禁用按钮 |
| 小额主网钱包 | ETH/BTC/SOL/TRX 发送、Gas、交易历史 |
| 测试网钱包 | Sepolia 广播、加速、取消、AA |
| 多账号钱包 | Account1/Account2 切换，验证不误用私钥 |
| 观察钱包 | 只读限制，禁止签名和私钥导出 |
| Token/NFT 钱包 | ERC-20、NFT 展示、发送、隐藏、自定义 Token |
| AA 钱包 | EIP-4337/EIP-7702，已部署和未部署各一个 |
| WalletConnect DApp | EVM personal_sign、EIP-712、交易；Solana/TRON 签名 |
| Chat 房间 | 文本、图片、视频、语音、文件、PDF、投票、置顶、话题和 1000+ 消息 |
| 管理员群 | 至少 3 人，管理员、普通成员、待移除成员 |
| 硬件 | Ledger/Trezor/Keystone（入口可见时） |

---

## 5. 执行轮次

| 套件 | 内容 | 时机 |
|---|---|---|
| Smoke | 安装/升级、启动、Wallet、Chat 会话、设置、冷启动 | 每个候选包 |
| P0 | 钱包创建/导入/备份门禁/收发、签名、Chat 消息、E2EE、通知 | 每次发版 |
| Full | 本手册全部可达 P0/P1/P2 | RC 至少一次 |
| Destructive | 删除、恢复、远程退出、群管理、真实资金 | 专用数据和审批窗口 |
| Soak | 2 小时前后台、长列表、多次切账号/网络 | 大版本或通信/存储改动 |

---

## 6. 自动化测试现状与改进要求

完整命令、测试数据隔离、CI 对照、失败排查和新增用例规范见 `docs/AUTOMATED_TESTING.md`。本节只保留发布验收所需的结果摘要和人工追溯。

### 6.1 当前可信结果

| 检查 | 命令 | 2026-07-13 结果 |
|---|---|---|
| 静态分析 | `flutter analyze --no-fatal-infos --no-pub` | Pass，0 issues |
| Flutter 主套件 | `flutter test --no-pub` | Pass，3113 tests |
| Flutter 行覆盖率 | `flutter test --no-pub --coverage --concurrency=1` | Pass，`15366/117554 = 13.07%` |
| 自动化质量门禁 | `flutter test --no-pub test/quality/integration_test_quality_test.dart` | Pass，7 tests |
| Android 真机 App Smoke | Release APK 安装与人工点击 | Pass；HyperOS USB 安装受限后改由文件管理器安装，冷启动及 Wallet 主要安全入口通过 |
| iOS 真机启动 | Flutter 3.41.9 Profile + `devicectl` | Pass；USB 安装后连续 3 次冷启动，每次 8 秒后进程仍存活，联系人插件启动崩溃未复现 |
| iOS 真机 App Smoke | `flutter drive --profile ... integration_test/app_test.dart` | Pass，USB Driver 2/2；DEVICE-01 因用户要求优先 Android 而暂停 |
| iOS 模拟器完整点击 | `./scripts/run_automated_tests.sh device` | Blocked；旧 `MLImage.framework` 无 arm64-simulator slice，Xcode 26.6 无可用 x86_64 模拟器目标 |
| Chat 独立套件 | `cd packages/n42_chat && flutter test --no-pub` | Pass，282 tests（含 MatrixRTC OpenID 换票、响应解析及安全降级边界） |
| JMT / Mining | `dart test` / `flutter test --no-pub` | Pass，13 / 3 tests |
| 三个 Go 后端 | `go test -count=1 ./...` | Pass，livekit-jwt、social-auth、swap |
| Android Debug/Release | `flutter build apk ...` | Pass |
| iOS Release/IPA | `flutter build ios/ipa ...` | Pass |

Android Release 不应在旧 `GeneratedPluginRegistrant.java` 存在时盲目使用 `--no-pub`，否则可能把 `integration_test` 测试插件留在 Release 注册表并导致编译失败。

### 6.2 自动化规模和真实边界

| 区域 | 现状 | 不可替代的人工范围 |
|---|---|---|
| `test/` | 208 个测试文件；Wallet 66、Core 59、AA 8、WalletConnect 7，含 Widget/截图/溢出和自动化质量门禁 | 权限、原生签名、真实链上结果、完整导航 |
| `packages/n42_chat/test/` | 30 个文件，集中在 utils/services/widgets，少量 datasource/repository/encryption | Matrix 消息、推送、群管理、媒体、通话、多设备 |
| `integration_test/` | 3 个文件；1 个启动/生命周期 Smoke、1 个生产入口全设备点击流、13 个钱包资金/破坏性用例显式 `SKIP` | 系统权限、双端消息/通话、真实签名广播和最终链上结果仍必须人工实弹 |
| `backend/` | 9 个 Go 测试文件 | 部署后路由、密钥、跨域和真实上游 |
| 覆盖率 | `15366/117554 = 13.07%` 原始行覆盖 | CI 设置 70%，当前真实基线未达标 |

### 6.3 自动化优先级

| 优先级 | 应自动化内容 | 实现方式 |
|---|---|---|
| A0 | 禁止空断言/占位 E2E、静态分析、构建、单元测试 | CI 门禁和测试代码扫描 |
| A1 | 地址/金额/Gas/链参数、交易序列化、签名恢复、Wallet 切换隔离 | U + 原生单元/集成测试 |
| A1 | Chat 搜索/路由、Push 去重、token 解析、错误映射、隐私设置状态 | U + W |
| A1 | Wallet/Market/Chat 关键页面浅色/深色/大字体/伪本地化 | W + golden/overflow |
| A2 | App 启动、登录替身、主 Tab、Drawer、Wallet 收发校验、Chat 搜索 | 可重复的 E2E，使用 fake server/fixture |
| A2 | API 200/3xx/4xx/5xx、超时、旧/新响应格式 | MockWebServer/Dio adapter/Go httptest |
| 人工保留 | 系统权限弹窗、生物识别、CallKit、相机/麦克风、真实推送、多设备 E2EE | M + EXT |
| 人工保留 | 主网广播、Swap/Bridge/AA 最终上链、硬件钱包实体确认 | M + EXT |

新缺陷处理要求：

1. 可抽成纯函数/状态机的边界条件必须加 U。
2. UI 路由、错误文案、加载/空/失败态必须加 W。
3. 修复跨页面用户流程时优先补真实 E2E，不再增加 `expect(true, true)`。
4. 外部服务用 fake server 自动覆盖协议，再用真机仅验证一条生产 happy path。
5. 每个自动化用例必须映射到本手册 Case ID，命名或注释中写明 ID。

### 6.4 自动化到真机追溯

| 自动化组 | 内部逻辑 | 真机用例 |
|---|---|---|
| Core/network/security/storage | 重试、断路器、URL 安全、存储、迁移 | GEN、SEC、NET |
| Wallet models/providers | 链配置、余额、聚合币种、加载、切账号 | WLT、CHN |
| Send/transaction | 地址、精度、序列化、Gas、重试、轮询 | TX |
| AA | EIP-4337/7702、UserOp、Session Key | AA |
| WalletConnect/DApp | URI、EVM/Solana/TRON 映射、会话 | WC、DAPP |
| Market/ENS/Portfolio | 搜索、价格格式、告警、回退、ENS 错误 | MKT、ENS、PORT |
| Chat utils/widgets/services | token、Push、消息 UI/服务 | CHT、MSG、CALL、PUSH |
| L10n/截图/溢出 | 主题、伪本地化、关键布局 | UX |

### 6.5 设备点击自动化执行

`integration_test/device_full_flow_test.dart` 启动生产 `main()`，实际点击并断言：首次协议、Wallet/Mining/Earn(Android)/Market 主导航、Market 四个页签和搜索输入、钱包选择器、Wallet AI、WalletConnect、收发/Swap 安全入口、ENS、Smart Account、全部非破坏性 Drawer 入口，以及 Chat 运行时登录、全局搜索、四个主页签和新增菜单。

```bash
read -r -p "Chat test user: " N42_E2E_CHAT_USERNAME
read -r -s -p "Chat test password: " N42_E2E_CHAT_PASSWORD
printf '\n'
export N42_E2E_CHAT_USERNAME N42_E2E_CHAT_PASSWORD

DEVICE_ID=<android-or-wired-ios-id> ./scripts/run_automated_tests.sh device
DEVICE_ID=<wireless-ios-id> PUBLISH_PORT=1 ./scripts/run_automated_tests.sh device

unset N42_E2E_CHAT_USERNAME N42_E2E_CHAT_PASSWORD
```

运行前必须保持设备解锁。HyperOS 首次 USB 安装需在手机上等待倒计时结束并点“继续安装”；该原生安全弹窗不能由 Flutter 测试越权点击。自动化只打开并安全返回交易/签名类入口，不输入助记词、不确认密码、不广播交易、不删除数据。完整细节和结果判定见 `docs/AUTOMATED_TESTING.md`。

---

## 7. 通用安装、启动与升级

| ID | P | 前置与操作 | 预期 | 自动化 |
|---|---|---|---|---|
| GEN-01 | P0 | 全新安装；首启、同意协议、进入首页；强杀再启 | 无白屏/闪退/死循环；首次引导只出现一次 | E2E(待补)、M |
| GEN-02 | P0 | 从上一个商店版本覆盖安装；打开 Wallet/Chat/设置 | 钱包、Chat session、主题、语言、历史数据保留 | U(迁移)、E2E(待补)、M |
| GEN-03 | P0 | 冷启动、热启动、后台 10 秒/5 分钟、强杀重启 | 回到正确登录态；敏感页按策略锁定 | E2E(待补)、M |
| GEN-04 | P1 | 刷新、上传、报价、消息发送时切后台/强杀，再进入 | 不重复提交；可恢复或明确失败；无数据损坏 | U(状态)、M |
| GEN-05 | P0 | 无网启动 Wallet/Chat；恢复网络 | 本地数据可查；远程数据有提示；自动重连 | U(重试)、M |
| GEN-06 | P1 | Android 返回/手势、iOS 左滑、Deep Link 冷/热启动 | 导航栈正确；不退出到空白页；不绕过登录/聊天锁 | U(路由)、E2E(待补)、M |
| GEN-07 | P1 | 时区、12/24 小时制、系统时间前后调整 | 消息、交易、定时任务时间正确；无负倒计时 | U(部分)、M |

---

## 8. Wallet 全量用例

### 8.1 创建、导入、备份与恢复

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| WLT-01 | P0 | 创建新钱包；输入名称/密码；展示、打乱并验证助记词 | 助记词顺序校验正确；完成后只进入新钱包；日志/任务预览无敏感内容 | U(输入)、E2E(待补)、M |
| WLT-02 | P0 | 分别用 12/24 词导入；测试空格、大小写、错词、错词数、重复词 | 合法输入成功；非法输入本地拦截；不创建半成品钱包 | U、E2E(待补)、M |
| WLT-03 | P0 | 导入合法/非法 EVM 私钥；对照预期地址 | 合法私钥生成正确地址；非法私钥返回可读错误、不崩溃 | U、iOS native 历史 Pass、M |
| WLT-04 | P1 | Keystore 导入：正确/错误密码、损坏 JSON、错误链 | 仅正确凭据成功；错误不暴露内部异常 | U、M |
| WLT-05 | P0 | 未备份钱包尝试发送/导出；完成备份后重试 | 备份门禁生效；身份验证后才显示敏感内容 | U、M |
| WLT-06 | P0 | 导出备份；关闭页面、切后台；检查截图/任务预览 | 离开后敏感数据立即清理；应用切换器不显示明文 | U(backup payload)、M |
| WLT-07 | P0 | 删除可丢弃钱包；测试取消、错密码、删除最后一个钱包 | 二次确认和密码验证生效；不影响其他钱包 | U、M(破坏性) |
| WLT-08 | P0 | 清数据后用备份恢复；核对多链地址 | 所有派生地址与原钱包一致；余额重新同步 | U(地址)、M(破坏性) |
| WLT-09 | P1 | 修改钱包密码；用旧/新密码执行签名 | 旧密码失效；新密码解锁和签名成功 | U、M |
| WLT-10 | P1 | 创建/导入观察钱包；尝试发送、导出和 DApp 签名 | 只读页面可查；所有需私钥操作禁用并明确提示 | U、M |

### 8.2 多钱包、多账号和资产加载

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| WLT-11 | P0 | Account1→Account2→Account1；每次检查名称、总额、地址、币种 | 不显示上一账号资产；加载期间不泄漏旧数据 | U、W、M |
| WLT-12 | P1 | 快速切换 10 次；加载时下拉刷新 | 无越界/闪退/顺序错乱；最终数据属于当前账号 | U(状态)、M |
| WLT-13 | P1 | 重命名、复制地址、隐藏/显示总额；重启 | 显示和持久化正确；隐私模式不泄露数字 | U、M |
| WLT-14 | P1 | 检查渐进加载；首条链返回后继续等待 | 无需等待所有链即可显示已有资产；后续链不清空已有结果 | U、M |
| WLT-15 | P2 | 小额资产过滤、排序、置顶币种；重启 | 规则和持久化正确；总额不因隐藏而错误 | U、M |

### 8.3 链、地址和 Token

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| CHN-01 | P0 | 分别打开 ETH/BTC/SOL/TRX；复制地址、展示 QR、与预期派生地址比对 | 地址格式和链完全一致，无跨链复用 | U、native 历史 Pass、M |
| CHN-02 | P1 | TON/APT/SUI/DOT/XRP/FIL/ZIL/NEAR/XLM/VET/ADA/EGLD 等可见链做地址/余额 smoke | 页面可达、地址格式正确、无原生崩溃 | U(多链)、M |
| CHN-03 | P1 | 添加非内置 EVM 链；错 chainId/RPC、重复链；重启和删除 | 参数校验、持久化和删除正确；不重复显示 | U、M |
| CHN-04 | P1 | 搜索/添加合法 ERC-20；错误合约、错链、重复 Token | metadata/decimals/symbol 正确；非法输入不落库 | U、M |
| CHN-05 | P2 | 隐藏/显示/置顶 Token；后台刷新价格 | 用户设置不被刷新覆盖；余额和价格不串币 | U、M |

### 8.4 收款、发送、Gas 与交易历史

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| TX-01 | P0 | 首页点 Receive；切链/币；复制、分享 QR | 地址与当前链一致；剪贴板/分享内容正确 | U(EIP-681)、M |
| TX-02 | P1 | 输入正数、0、负数、超长小数的收款金额；扫码 | 有效金额写入 URI；无效数量拦截；扫码后地址/金额一致 | U、M |
| TX-03 | P0 | 扫描地址 QR、EIP-681、WC、普通文本、URL QR | 按类型路由；不把任意 URL 当转账；取消安全返回 | U、M |
| TX-04 | P0 | 发送页输入空、错链、校验和错误地址、本人地址 | 实时给出明确错误；不进入签名 | U、E2E(待补)、M |
| TX-05 | P0 | 输入空、0、负数、科学计数、超 decimals、超余额和 MAX | 精度与余额校验正确；不四舍五入成超额 | U、E2E(待补)、M |
| TX-06 | P0 | 小额 EVM native 转账；核对 from/to/value/gas；签名广播 | 弹窗与请求一致；产生真实 txHash；链上可查 | U、M、EXT(资金) |
| TX-07 | P0 | 小额 ERC-20 转账；核对 decimals、Gas 和余额变化 | 金额精确；目标 Token 与主币 Gas 扣除正确 | U、M、EXT |
| TX-08 | P0 | BTC/SOL/TRX 各执行一笔小额广播 | 链特有费用/签名/状态正确；不误用 EVM 格式 | U、M、EXT |
| TX-09 | P1 | XRP/Cosmos 等需 memo/tag 的链测试空、非法和有效值 | 强制规则正确；广播 payload 包含对应字段 | U、M、EXT |
| TX-10 | P1 | Gas 慢/标准/快速/自定义；过低和极高值 | 估算、法币折算、最终参数一致；危险值警告 | U、M |
| TX-11 | P1 | 创建 pending EVM 交易；加速和取消 | nonce 一致、Gas 提高；原交易和替代交易状态正确 | U、M、EXT |
| TX-12 | P1 | 广播时断网/切后台；恢复后查详情 | 不重复广播；通过 hash/nonce 恢复真实状态 | U(重试/轮询)、M、EXT |
| TX-13 | P1 | 交易列表分页/筛选；详情复制 hash/地址；打开 Explorer | 顺序/状态/时间正确；Explorer 匹配链；无重复项 | U、M |
| TX-14 | P1 | 失败交易重试；修改 Gas/余额后再发 | 原失败记录保留；新交易不误标为原 hash | U、M、EXT |
| TX-15 | P2 | 地址簿添加/编辑/删除/同名/错链；发送页选择 | 存储、搜索和链过滤正确；不静默填入其他链地址 | U、M |

### 8.5 Markets、Portfolio、Gas 和资讯

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| MKT-01 | P0 | 遍历 Trending/Search/Watchlist/News | 四个 Tab 可达；加载/错误/空状态明确；无溢出 | U、W、M |
| MKT-02 | P1 | 搜 BTC、不存在币、特殊字符；快速连续搜索 | 去抖与结果正确；旧请求不覆盖新关键词 | U、W、M |
| MKT-03 | P1 | 币详情切 1H/1D/1W/1M；收藏/取消 | 价格、涨跌、图表周期一致；Watchlist 同步 | U、W、M |
| MKT-04 | P1 | 无网、超时、429、5xx 进入 Markets | 使用可用 fallback 或可读错误；不无限 loading、不暴露堆栈 | U、M |
| MKT-05 | P1 | 价格告警高于/低于、无效值、编辑、删除 | 规则持久化；按策略单次/重复触发 | U、W、M、EXT |
| MKT-06 | P2 | 新建/编辑/删除 Trade Journal；错误数量/价格 | 盈亏计算与持久化正确 | U、W、M |
| PORT-01 | P1 | 检查 Portfolio 总额、持仓、变化和链分布 | 与钱包首页和链上余额可对账；不重复计值 | U、W、M |
| PORT-02 | P1 | 切 Account1/2、币种和时间范围 | 持仓/历史属于当前账号；无旧数据泄漏 | U、M |
| PORT-03 | P2 | DeFi positions 在有/无 `DEBANK_API_KEY` 的包测试 | 有配置显示真实仓位；无配置隐藏/降级，不造数据 | M、EXT |
| PORT-04 | P2 | News 刷新、详情、返回和断网 | RSS 来源/时间正确；外链安全；错误不崩溃 | U、M |
| PORT-05 | P1 | Gas Tracker 切链、刷新和告警 | Gwei/速度/法币折算一致；代理认证成功；失败可读 | U、M |

### 8.6 ENS

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| ENS-01 | P1 | 切支持网络；输入 0/1/2/3+ 字符、空格、Unicode | 最短长度门禁正确；标准化后搜索 | U、W、M |
| ENS-02 | P1 | 搜可用、已注册和不存在名称 | 状态、owner、到期时间和操作按钮正确 | U、M、EXT |
| ENS-03 | P1 | 无网、超时、RPC 错误 | 显示本地化通用失败；不显示 Dio/socket/原始 URL | U、W、M |
| ENS-04 | P2 | 入口可见时执行注册、续费、解析设置、子域 | 费用、链、合约请求正确；成功后刷新 | U(部分)、M、EXT |

### 8.7 Smart Account / AA

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| AA-01 | P1 | 创建 SimpleAccount；记录 counterfactual 地址；重启 | 未部署地址稳定；owner 属于当前 active wallet | U、M |
| AA-02 | P1 | Account1/2 各创建 AA；verify/mining 与 active 不同 | owner/signer 始终使用 active wallet | U、M |
| AA-03 | P1 | 检查未部署/已部署/EIP-7702 状态 | 标签、地址、网络与链上代码一致 | U、M、EXT |
| AA-04 | P1 | 零余额页点 MAX/发送 | 显示真实 0；不出现 mock 余额；发送禁用 | U、M |
| AA-05 | P1 | 有资金时发送 UserOperation；查 bundler/receipt | UserOp hash 和最终 txHash 可追溯；轮询正确 | U、M、EXT |
| AA-06 | P1 | bundler/paymaster 超时、401、5xx、拒绝代付 | 错误可读；不伪造成功；可安全重试 | U、M、EXT |
| AA-07 | P2 | Session Key 创建、过期、撤销和越权 | 权限/时间/合约范围受限；撤销后不可签名 | U、M、EXT |
| AA-08 | P2 | EIP-7702 升级/回退（网络支持时） | 授权与状态准确；不支持网络禁用 | U、M、EXT |

### 8.8 Swap、Bridge、Buy/Sell、Staking 和 Earn

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| DEFI-01 | P1 | Swap 选链/币、金额并获取报价 | 路径、价格影响、滑点、手续费、Gas 完整；有有效期 | U、M、EXT |
| DEFI-02 | P1 | 无效金额、余额/Gas 不足、同币、无流动性 | 不允许提交；错误对应真实原因 | U、M |
| DEFI-03 | P1 | ERC-20 首次 approve 后 Swap；分别拒绝 | 两阶段状态分离；拒绝不产生伪记录 | U、M、EXT |
| DEFI-04 | P1 | 报价过期/超滑点；刷新后提交 | 旧报价不可继续；超滑点拦截或明确失败 | U、M、EXT |
| DEFI-05 | P1 | Bridge 选源/目标链、币和报价 | 两链不同；费用、时间、最少到账正确 | U、M、EXT |
| DEFI-06 | P1 | Bridge approve、发送、中继、到账 | 源/目标链均可追溯；部分失败不误报成功 | U、M、EXT |
| DEFI-07 | P2 | Buy/Sell、KYC 取消、第三方返回、未配置 key | 有 key 才可用；无 key 隐藏/降级；日志不泄漏 KYC | M、EXT |
| DEFI-08 | P1 | Aave 存入、approve、提取；余额不足和拒绝 | 仓位/APY/余额正确；每阶段可追溯 | U(部分)、M、EXT |
| DEFI-09 | P1 | Hyperliquid 开/平仓、调杠杆、无保证金 | 方向、杠杆、强平价、PnL 正确；高风险二次确认 | M、EXT |
| DEFI-10 | P1 | Staking 选验证者、质押、解质押和锁定期 | 最小额、APY、佣金、解绑定日期正确 | U(模型)、M、EXT |
| DEFI-11 | P2 | BTC Staking 存入/赎回（入口可见时） | BTC 网络、脚本、锁定期和费用正确 | M、EXT |
| DEFI-12 | P2 | Earn 列表、协议详情、排序、筛选、空状态 | APY 来源/时间明确；不把预估表述为保证收益 | U、M |

### 8.9 NFT、批量转账、硬件钱包和 Wallet AI

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| NFT-01 | P1 | NFT 空/有资产钱包；切链、筛选、详情 | 空态正确；图片/metadata/collection/tokenId 匹配；失败有占位 | U、M、EXT |
| NFT-02 | P1 | 发送 NFT；错地址、不持有 tokenId、Gas 不足 | 仅 owner 可签；成功后列表刷新且链上可查 | U、M、EXT |
| NFT-03 | P2 | NFT 批量选择/发送/部分失败 | 数量/Gas 正确；失败项单独列出 | U、M、EXT |
| BAT-01 | P1 | 批量转账手动添加、CSV 导入、重复/空/错行 | 错误指向具体行；总额和费用正确 | U、M |
| BAT-02 | P1 | 小额批量广播；中途拒绝/部分失败 | 每笔可追溯；不重复付款 | U、M、EXT |
| HW-01 | P1 | 扫描/连接；拒绝蓝牙/USB；断开重连 | 设备名、地址、链匹配；拒绝权限可恢复；无假连接 | U(模型)、M、EXT |
| HW-02 | P1 | 硬件确认/拒绝转账和消息签名 | 设备屏幕与 App 数据一致；拒绝不广播 | U、M、EXT |
| AIW-01 | P1 | 顶部进入 Wallet AI；检查 Balance/Portfolio/Help | 标记 Read-only；快捷项可点；无未接通 Gas 快捷项 | U、M |
| AIW-02 | P1 | 切换钱包并询问余额/持仓 | 快照属于当前钱包；不包含密钥材料 | U、M |
| AIW-03 | P1 | 要求助手转账、签名或导出私钥 | 不执行写入/签名，不绕过密码门禁 | U、M |

### 8.10 WalletConnect、DApp 与 Deep Link

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| WC-01 | P0 | Wallet 顶部扫码入口 | 打开新建连接页，可选 Paste/Scan；不误进 session 管理 | U、M |
| WC-02 | P0 | 扫描/粘贴合法 WC URI；无效/过期/重复 URI | proposal 显示 DApp、网络、权限；错误不无限 Pairing | U、M、EXT |
| WC-03 | P0 | 批准/拒绝 EVM session；对端检查 | 双端状态一致；拒绝不留残缺 session | U、M、EXT |
| WC-04 | P0 | active=Account1、mining=Account2；personal_sign 并恢复地址 | 必须恢复为 Account1，不误用 mining wallet | U、历史真机 Pass、M |
| WC-05 | P0 | EIP-712；超长字段、可疑 spender | 展示可读 domain/message；风险警告；可拒绝 | U、M、EXT |
| WC-06 | P0 | eth_sendTransaction；核对 from/to/value/data/chainId | 确认后才广播；返回真实 txHash | U、M、EXT |
| WC-07 | P1 | Solana signMessage；DApp Ed25519 验签 | 返回 64-byte 签名；原消息验签通过 | U、历史真机 Pass、M |
| WC-08 | P1 | TRON 消息/交易签名（有对端时） | 地址和签名格式可被 DApp 验证 | U、M、EXT |
| WC-09 | P1 | 多 session；强杀、网络切换、过期、主动断开 | 持久化/清理正确；断开后 DApp 同步 | U、M、EXT |
| DAPP-01 | P0 | Browser 输入 HTTPS；前进/后退/刷新/关闭 | WebView 导航正确；地址栏一致；无白屏 | U、M |
| DAPP-02 | P0 | 测试 DApp 调 accounts/personal_sign | 注入 active wallet；弹确认；签名可恢复地址 | U、历史真机 Pass、M |
| DAPP-03 | P1 | DApp 请求切链/加链；错 chainId/RPC | 用户确认后才更改；错误参数拦截 | U、M |
| DAPP-04 | P1 | HTTP、javascript/data/file URL、钓鱼域名、证书错误 | 危险 scheme 拦截；钓鱼警告；TLS 错误不静默继续 | U、M |
| DAPP-05 | P1 | WC/N42 Deep Link 冷/热启动、未登录打开 | 进入正确页；先登录/解锁再恢复目标 | U、E2E(待补)、M |

### 8.11 Verification、Mining、奖励和空投

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| GROW-01 | P1 | Verification 选择 verify wallet，再切 active wallet | 两种钱包标识清晰；签名不串账号 | U(部分)、M |
| GROW-02 | P1 | 切 Mining v1/v2（入口可见时）；启动/停止/领取 | 状态、产出、价格和日界线计算正确 | U、M、EXT |
| GROW-03 | P1 | 挖矿中后台、断网、强杀、跨日 | 不重复计奖；按服务端状态恢复 | U、M、EXT |
| GROW-04 | P2 | Loyalty 任务、领取、重复点击、历史 | 满足条件才可领；幂等；积分/历史一致 | U(部分)、M、EXT |
| GROW-05 | P2 | Airdrop 列表、搜索、资格检查、无资格 | 来源/风险可见；不伪造资格 | M、EXT |
| GROW-06 | P2 | 有资格测试钱包领取；拒绝/失败/重复领取 | 交易可追溯；重复领取拦截；不导航恶意站点 | M、EXT |

---

## 9. Chat 全量用例

### 9.1 登录、会话与主导航

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| CHT-01 | P0 | 从底部 Chat 进入；未登录/已登录各一次 | 未登录进欢迎/登录页；已登录直进会话列表；无重复初始化 | E2E(待补)、M |
| CHT-02 | P0 | 使用分配账号登录；空用户名/密码、错凭据、快速连点 | 有效登录成功；错误可读；不发起重复 session | U(配置)、E2E(待补)、M、EXT |
| CHT-03 | P0 | 强杀重启、断网启动、模拟 token 过期 | session 持久化；断网可查本地数据；过期刷新或安全返回登录 | U(存储)、M |
| CHT-04 | P1 | 登出；检查缓存/通知/session；重新登录 | 凭据和敏感缓存清理；宿主钱包不被误删 | E2E(待补)、M |
| CHT-05 | P1 | 遍历 Messages/Contacts/Discover/Me；连续切 Tab；返回 Wallet | 选中态、导航栈和未读数正确；无状态串页 | W(部分)、E2E(待补)、M |
| CHT-06 | P1 | 逐个执行可见社交登录；取消、回调错误、未配置包 | 只显示配置完整 provider；校验 state；取消不留 loading | U、M、EXT |

### 9.2 会话列表、搜索和会话控制

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| CHT-07 | P0 | 检查单聊/群聊顺序、最后消息、时间、未读、加密标识 | 按最新活动排序；文本/媒体/草稿预览正确 | W(部分)、M |
| CHT-08 | P0 | 顶部全局搜索；搜会话、联系人、群和消息；点击结果 | 搜索页正常打开；分类正确；跳到目标对象/消息 | U(搜索 utils)、W(入口)、M |
| CHT-09 | P1 | 搜不存在词、emoji、特殊字符、大小写；快速输入删除 | 空态、去抖、高亮正确；无结果不报错 | U、W、M |
| CHT-10 | P1 | 长按会话：置顶、静音、已读/未读、删除和取消 | 状态立即更新并持久化；删除二次确认 | W(部分)、M |
| CHT-11 | P2 | 收藏/隐藏/文件夹（入口可见时）；添加、移除、重启 | 各列表一致；隐藏不等于删除；搜索策略符合定义 | M |
| CHT-12 | P1 | 会话内搜索；上/下一条；跳转旧消息 | 高亮和定位正确；加密历史可搜；翻页不丢结果 | U(部分)、M |

### 9.3 文本消息、输入栏和消息状态

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| MSG-01 | P0 | C1 向 C2 发文本；C2 前台接收并已读 | 发送中→已发送→已送达/已读正确；时间顺序正确 | M、EXT(2 账号) |
| MSG-02 | P0 | 断网发送；恢复网络；重试/取消；快速连点发送 | 失败态可识别；不丢草稿；恢复后不重复消息 | U(去重)、M |
| MSG-03 | P1 | 空白、多行、超长、emoji、RTL、中英混合；复制/选择 | 限制和换行正确；不溢出；复制无 UI 杂质 | W、M |
| MSG-04 | P1 | Markdown 粗/斜体/代码/引用；URL 点击和预览 | 安全渲染；代码不执行；恶意 URL 经安全检查 | W(部分)、M |
| MSG-05 | P1 | @单人/@all（有/无权限）；候选列表搜索 | mention ID/显示名正确；无权限不能 @all；对方收到通知 | M、EXT |
| MSG-06 | P1 | 输入后返回列表/强杀；再打开；发送 | 草稿持久化；列表显示草稿标识；发送后清理 | W(部分)、M |
| MSG-07 | P2 | C1 输入/停止，C2 观察；关闭 typing 隐私开关 | 指示器按时消失；关闭后不向服务端上报 | M、EXT |
| MSG-08 | P1 | 定时发送：快捷/自定义/过去时间/取消/重启 | 过去时间拦截；到时只发一次；取消后不发 | U(时间逻辑待补)、M、EXT |
| MSG-09 | P2 | 快捷回复新增/编辑/删除/插入，翻译开关 | 插入内容正确且不自动发送；设置持久化 | W(待补)、M |

### 9.4 图片、视频、语音、文件、位置、GIF 和贴纸

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| MED-01 | P0 | 相册选图、拍照；首次允许/拒绝权限；发送并在 C2 查看 | 权限降级正确；缩略图/原图/方向/尺寸正确 | W(部分)、M、EXT |
| MED-02 | P1 | 编辑图片：裁剪、旋转、涂鸦、文字、滤镜、撤销/重做、取消 | 发送结果与预览一致；取消不上载；不破坏原图 | W(编辑器待扩)、M |
| MED-03 | P1 | 多图、大图、不支持格式；上传中断网/取消 | 顺序/进度/部分失败明确；不留损坏消息 | M、EXT |
| MED-04 | P1 | 发视频；检查缩略图、时长、播放、前后台 | 音画正常；播放状态可恢复；遵循自动下载设置 | M、EXT |
| MED-05 | P0 | 长按录音、上滑取消、过短、锁定录音；C2 播放 | 权限、波形、时长、取消和播放唯一性正确 | W(部分)、M、EXT |
| MED-06 | P1 | 语音转文字：配置/未配置 STT，网络失败 | 有配置返回真实结果；无配置降级；不影响语音播放 | M、EXT |
| MED-07 | P1 | 发普通文件/PDF/超限文件；下载、取消、打开 | 名称/大小/MIME 正确；PDF 可预览；超限前拦截 | M、EXT |
| MED-08 | P1 | 发静态位置；拒绝定位；打开地图 | 授权后才获取；坐标/预览正确；无权限可恢复 | M、EXT |
| MED-09 | P2 | 实时位置开始/停止/后台（入口可见时） | 明确持续分享状态；停止后不再上报 | M、EXT |
| MED-10 | P1 | GIF 搜索/翻页/发送；无 key 包 | 有 key 正常出图；无 key 显示配置降级；不崩溃 | API U(待补)、M、EXT |
| MED-11 | P1 | 贴纸面板、搜索/收藏/发送、动图播放 | 缓存和尺寸正确；不挤压输入栏 | W(部分)、M |
| MED-12 | P2 | 联系人名片、音乐分享和视频消息（入口可见时） | 消息 schema、预览、点击目标和权限正确 | U(model 待补)、M |

### 9.5 消息操作、特殊消息和话题

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| ACT-01 | P0 | 长按自己/他人、文本/媒体/系统消息 | 菜单只显示有权限操作；不越界/溢出 | W、M |
| ACT-02 | P0 | 复制、引用回复、取消引用、表情反应/取消 | 复制正确；引用可跳原消息；反应去重并同步 | W(部分)、M、EXT |
| ACT-03 | P1 | 编辑可编辑消息；超时/他人消息；查编辑历史 | 权限和标识正确；搜索结果更新 | U(权限待补)、M、EXT |
| ACT-04 | P0 | 删除本地/撤回全员；取消；超时撤回 | 撤回范围正确；附件缓存按策略清理 | M、EXT |
| ACT-05 | P1 | 转发到单聊/群聊/多选；取消部分目标 | 类型和归属正确；加密媒体可解密 | M、EXT |
| ACT-06 | P1 | 多选；批量复制/删除/转发/收藏；返回键退出 | 勾选/计数/操作/退出状态正确 | W(部分)、M |
| ACT-07 | P1 | 投票：单/多选、重复投票、截止、结果 | 规则和统计实时一致；截止后不可投 | U(model 待补)、M、EXT |
| ACT-08 | P1 | 置顶/取消消息；打开置顶列表；无权限操作 | 权限、顺序、跳转正确；无权限拦截 | M、EXT |
| ACT-09 | P1 | Thread 回复、返回主线、未读、删除原消息 | 主线/话题计数一致；导航和引用可追溯 | M、EXT |
| ACT-10 | P2 | 翻译、TTS 朗读、收藏（入口可见时） | 语言/播放/缓存正确；无 key 可降级 | U(部分)、M、EXT |
| ACT-11 | P2 | 阅后即焚发送、打开、倒计时、多设备（入口可见时） | 销毁时机一致；多设备不留明文；截图策略符合产品定义 | M、EXT |
| ACT-12 | P1 | 加密转账/付款请求/系统消息等特殊消息 | 未知或旧版本消息有安全 fallback；不把解析失败显示成成功 | U(model 待补)、W(待补)、M |

### 9.6 联系人、好友和群组

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| CON-01 | P0 | Contacts 列表、字母索引、搜索、详情 | 排序、头像、显示名、Matrix ID 正确；大列表稳定 | W(待补)、M |
| CON-02 | P1 | Add Friend：Matrix ID/用户名/钱包地址/ENS；错误输入和自己 | 解析到正确用户；无结果明确；不可添加自己 | U(部分)、M、EXT |
| CON-03 | P1 | 发请求、接受/忽略、重复请求、取消 | 状态双端一致；幂等；不重复建联系人 | U(state 待补)、M、EXT |
| CON-04 | P1 | 备注、标签、拉黑/解除；被拉黑方发消息/通话 | 显示名优先级正确；协议层权限生效 | M、EXT |
| CON-05 | P2 | My QR、好友/room/payment QR 扫码 | 识别类型并正确导航；非法 QR 不崩溃 | U(路由)、M |
| GRP-01 | P0 | 创建群：选 C2/C3、命名、头像；逐阶段取消 | 只在最终确认创建；成员和加密设置正确 | E2E(fake 待补)、M、EXT |
| GRP-02 | P0 | 三人各发文本；检查发送者、未读和已读 | 所有成员收到；列表预览显示发送者 | M、EXT |
| GRP-03 | P1 | 修改群名/头像/公告；普通成员尝试 | 管理员更改同步；无权限请求被服务端拒绝 | M、EXT |
| GRP-04 | P1 | 邀请/移除、升/降管理员、禁言 | powerLevel/系统消息正确；被移除者不能继续发送 | M、EXT(破坏性) |
| GRP-05 | P1 | 退出群、群主退出、取消二次确认 | 群主转让/限制符合策略；退出后不再收消息 | M、EXT |
| GRP-06 | P1 | 群文件、相册、置顶、定时消息列表 | 类型筛选和跳转正确；删除后更新 | W(列表待补)、M、EXT |
| GRP-07 | P2 | 公开/邀请/审批/慢速/只读频道（可见时） | 加群和发言权限在服务端生效 | M、EXT |
| GRP-08 | P2 | Token Gate ERC-20/721/1155，持有/不持有，AND/OR | 链上/服务端验证；不可仅绕过 UI | U(rule 待补)、M、EXT |

### 9.7 Chat Wallet 桥、支付和业务消息

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| PAY-01 | P1 | 聊天附件打开 Transfer；选链/币/金额；取消/确认 | 调宿主 Wallet 确认/密码页；Chat 不接触私钥 | U(桥模型)、M、EXT |
| PAY-02 | P1 | 小额真实转账；成功后发送 txHash 消息 | 只在真实广播成功后显示成功；hash 可查 | M、EXT(资金) |
| PAY-03 | P1 | Payment Request；对方接受/拒绝/过期 | 金额/链/收款人不可静默更改；状态双端一致 | U(model 待补)、M、EXT |
| PAY-04 | P1 | Chat Receive、QR、复制、分享 | 地址属于 active wallet；与 Wallet Receive 一致 | U(部分)、M |
| PAY-05 | P1 | Red Packet 打开、输入、取消/创建 | 必须显示“聊天内记录，非真实链上资产转移”；不误导 | W(文案待补)、M |
| PAY-06 | P2 | 订阅/会员支付入口（可见时） | 无真实结算后端时标 demo/不可用，不伪造成功 | M、EXT |

### 9.8 语音/视频通话、屏幕共享和语音房

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| CALL-01 | P0 | C1→C2 发起 1:1 语音；C2 前台接听/拒绝 | 来电页、铃声、状态、挂断原因双端一致 | U(state 待补)、M、EXT |
| CALL-02 | P0 | C2 后台/锁屏；C1 发起语音/视频 | APNs/FCM/CallKit/Android 来电到达；点击进入通话 | M、EXT |
| CALL-03 | P1 | 通话中静音、扬声器/听筒、蓝牙、切后台 | 本地/远端媒体状态正确；路由切换不掉线 | U(部分)、M、EXT |
| CALL-04 | P1 | 视频开关、前后摄像头、拒绝相机/麦克风 | 双端状态一致；拒绝权限可降级/安全结束 | M、EXT |
| CALL-05 | P1 | 群内 Video Call；至少 3 人加入/退出 | token 成功后才入房；参与者/媒体状态正确 | U(token utils)、M、EXT |
| CALL-06 | P0 | OpenID/JWT 返回 301/400/401/403/404/5xx/非 JWT | 请求发往 `{livekit_service_url}/sfu/get`；显示本地化连接失败；不暴露 token、HTML 或原始响应 | U、W(错误态待补)、M |
| CALL-07 | P1 | Wi-Fi↔蜂窝、5-20 秒断网、恢复、远端挂断 | 重连状态明确；不卡通话页；超时释放资源 | U(state)、M、EXT |
| CALL-08 | P1 | 屏幕共享允许/拒绝、切后台、结束 | 权限正确；远端可见；结束后停止捕获 | U(部分)、M、EXT |
| CALL-09 | P2 | 虚拟背景/模糊/关闭；低端机、横竖屏 | 生效且不黑屏/严重掉帧/崩溃 | U(处理引擎)、M、EXT |
| CALL-10 | P2 | 通话录制入口（可见时） | Egress 未部署时禁用/明确未配置，不伪造成功 | M、EXT |
| CALL-11 | P2 | 语音房创建/加入/退出；主持静音/踢出/举手 | 角色/权限服务端生效；离房后音频完全停止 | M、EXT |

### 9.9 E2EE、聊天锁、隐私和多设备

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| E2E-01 | P0 | 加密单聊/群发文本和媒体 | 双端可解密；日志无明文；锁标识正确 | U(部分 encryption)、M、EXT |
| E2E-02 | P0 | 新设备登录；未恢复密钥查旧消息；恢复后再查 | 未恢复显示无法解密；恢复后可读 | U(部分)、M、EXT |
| E2E-03 | P1 | SAS/Emoji：一致、不一致、取消 | 双方确认后才 trusted；取消/不一致不信任 | U(部分)、M、EXT |
| E2E-04 | P1 | 密钥备份/恢复；错 key、中途断网 | 错 key 不覆盖现有密钥；可继续；敏感 key 不入日志 | M、EXT |
| SEC-CH-01 | P1 | 开 Chat Lock；设 PIN；正确/错误 PIN；生物识别 | 进入必须验证；错误有节流；取消返回列表 | W(逻辑待补)、M |
| SEC-CH-02 | P1 | Deep Link/通知打开锁定聊天；平板分屏 | 不绕过聊天锁；未验证不显示消息预览 | E2E(待补)、M |
| PRIV-01 | P1 | 已读、typing、最后上线、在线状态开/关；C2 观察 | 每个开关在协议层生效，不只隐藏本地 UI | M、EXT |
| PRIV-02 | P1 | 头像/资料/消息/通话/群邀请可见范围 | 联系人和陌生人实际权限符合设置 | M、EXT |
| DEV-01 | P1 | 设备列表、本设备标识、改名、刷新 | 设备 ID/时间正确；当前设备不可误删 | M、EXT |
| DEV-02 | P1 | 远程退出 C4；C4 尝试继续发消息 | 二次确认；C4 token 失效；C1 不受影响 | M、EXT(破坏性) |

### 9.10 Discover、Moments、Stories、Mini Apps、Games 和 AI

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| DSC-01 | P1 | 遍历 Discover 可见入口；返回和刷新 | 每个入口有实际页或明确未开启；无空壳/死链接 | E2E(导航待补)、M |
| DSC-02 | P1 | Moments 发图文/视频；C2 看、赞、评论；删除 | 可见范围、排序、计数和删除同步 | U(model 待补)、M、EXT |
| DSC-03 | P2 | Story 文本/图/视频；浏览者；过期 | 24h 和可见范围正确；过期不在 feed | U(time 待补)、M、EXT |
| DSC-04 | P2 | Spaces/Communities/Channels 创建/加入/退出/只读 | 层级和权限正确；消息不串房间 | M、EXT |
| DSC-05 | P1 | Mini App 打开/关闭、网络失败、请求钱包/相机权限 | WebView 沙箱和权限确认生效；不能直接取私钥 | U(URL/bridge)、M、EXT |
| DSC-06 | P2 | 2048 滑动、计分、重开、后台恢复 | 手势/合并/分数/布局正确；不影响 Chat session | U(game logic 待补)、M |
| DSC-07 | P2 | Sticker Store/Services/Orders/Cards 可见入口 | 已实现功能真实可用；未实现标 N/A | M、EXT |
| AI-CH-01 | P1 | AI 总结/润色/回复/翻译；有 key/无 key | 有 key 返回相关结果；无 key 降级/隐藏；不自动发送 | U(部分)、M、EXT |
| AI-CH-02 | P1 | 长消息、图片、恶意 prompt、索要密钥 | 不暴露 token/助记词/其他房间内容 | U(部分)、M |
| AI-CH-03 | P2 | Local LLM 有/无模型 URL；下载中断、空间不足 | 无模型明确未配置/回退，不声称离线可用 | M、EXT |
| DSC-08 | P2 | On-chain 通知、积分、榜单、兑换 | 数据真实；分页/空态/重复兑换正确 | U(Push 部分)、M、EXT |

### 9.11 Chat 资料、设置、存储、备份和导出

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| CFG-01 | P1 | 编辑头像/昵称/签名/状态/用户名；取消和重名 | 预览、上传、服务端同步正确；重名拦截 | W(form 待补)、M、EXT |
| CFG-02 | P2 | 普通/NFT 头像（入口可见）；切钱包 | 验证 NFT owner；不持有者不可设 | M、EXT |
| CFG-03 | P1 | 通知/隐私/外观/语言/背景/快捷回复/翻译逐项修改并重启 | 立即生效并持久化；Chat 与宿主主题/语言协调 | U(部分)、W、M |
| CFG-04 | P1 | Auto-download 在 Wi-Fi/蜂窝/漫游和不同大小媒体下测试 | 只在策略允许时自动下载；无静默大流量 | U(policy 待补)、M |
| CFG-05 | P1 | Storage 统计、按房间/类型清理、取消、重启 | 统计合理；清缓存不删服务端消息；可重下 | U(统计待补)、M |
| CFG-06 | P1 | Chat backup/restore；错密码、损坏备份、中断 | 完整性验证；错误不覆盖现有数据；敏感材料不泄漏 | U(format 待补)、M、EXT |
| CFG-07 | P2 | 导出文本/时间范围/媒体（入口可见） | 范围、编码、时间、附件完整；分享前隐私提示 | U(format 待补)、M |
| CFG-08 | P2 | Connected Accounts/Bridges 添加/解绑/错凭据 | 只显示已部署 bridge；解绑后停同步；不泄漏 token | M、EXT |

---

## 10. 推送、通知、角标与 Deep Link

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| PUSH-01 | P0 | C1 前台，C2 发消息 | 应用内通知符合策略；会话和底部未读数更新；不重复 | U(去重)、M、EXT |
| PUSH-02 | P0 | C1 后台，C2 发单聊/群聊/@mention | 系统通知到达；标题/预览/隐私符合设置 | U(路由/去重)、M、EXT |
| PUSH-03 | P0 | 点击通知：冷启动/热启动/已在其他房间 | 打开正确 room/消息；不重复路由；聊天锁先验证 | U、E2E(待补)、M |
| PUSH-04 | P1 | 快速连发相同 event；服务端重推 | event ID 去重；无双通知/重复导航 | U、M、EXT |
| PUSH-05 | P1 | 静音会话、全局关通知、系统拒绝权限 | 行为与三层设置一致；有设置引导但不反复申请 | M、EXT |
| PUSH-06 | P1 | 已读、清会话和登出后检查角标 | 角标与真实未读一致；不为负数 | U、M |
| PUSH-07 | P1 | Push Protocol 当前 `feeds` 与旧 `results` 响应 | 均标准化；请求不带服务端禁止的 `raw` 参数 | U、M、EXT |
| PUSH-08 | P1 | Push API 无网/429/5xx/空 feed；多轮轮询 | 无原始报错气泡；退避重试；不无限请求 | U、M |
| PUSH-09 | P1 | `n42://chat/user/group/friendCard`、`n42app://`、WC deep link | 冷/热启动可路由；错 ID 有错误页；不绕登录 | U、E2E(待补)、M |

---

## 11. 宿主认证、安全、设置与通用 UI

### 11.1 认证和安全

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| AUTH-01 | P0 | 邮箱/密码登录；空、错误、锁定、连续点击 | 校验、错误、防重和登录态正确 | U、E2E(待补)、M、EXT |
| AUTH-02 | P1 | 注册；OTP 正确/错误/过期/重发；重复邮箱 | 倒计时、幂等和错误正确；成功 session 唯一 | U、E2E(待补)、M、EXT |
| AUTH-03 | P1 | 忘记密码、改邮箱；无网/过期验证码 | 后端路由真实可用；更改后旧凭据失效；不伪造成功 | U(部分)、M、EXT |
| AUTH-04 | P1 | 所有可见社交登录；取消、账号冲突和回调攻击 | 配置门禁、OAuth state/redirect 校验正确 | U、M、EXT |
| SEC-01 | P0 | 设置 App 密码锁；正确/错误密码；重启 | 未解锁不显示资产/消息；错误不泄露有效位数 | U、M |
| SEC-02 | P0 | 指纹/Face ID 成功、失败、取消、系统生物信息改变 | 成功解锁；失败回退密码；系统变化后重验证 | U、M |
| SEC-03 | P1 | 立即/1/5 分钟自动锁；敏感页切后台 | 超时后锁定；敏感页优先立即遮罩 | U、M |
| SEC-04 | P1 | 连续输错、暴力尝试、前后台绕过 | 延时/锁定生效；重启不清必要锁定状态 | U、M |
| SEC-05 | P1 | Root/越狱/调试/模拟器可控环境 | 风险警告符合策略；普通设备不误报 | U、M、EXT |
| SEC-06 | P0 | 审计日志、崩溃报告、剪贴板和任务预览 | 无助记词/私钥/密码/token；按策略清剪贴板 | U(部分)、M |

### 11.2 主题、语言、字体、可访问性和设置

| ID | P | 操作 | 预期 | 自动化 |
|---|---|---|---|---|
| UX-01 | P1 | 浅色/深色/跟随系统；遍历 Wallet/Market/Chat/弹窗 | 对比度合格；无同色文字背景；重启持久 | U、W/截图、M |
| UX-02 | P1 | 中文/英文/长文案语言/RTL；不重启切换 | 宿主和 Chat 同步；无漏翻/键名；RTL 正确 | U(l10n)、W(伪本地化)、M |
| UX-03 | P1 | 系统字体 100%/130%/200%；遍历导航/弹窗/确认页 | 文本不裁切/重叠；按钮可点；重要数据可见 | W/overflow、M |
| UX-04 | P1 | VoiceOver/TalkBack 遍历主导航、收发、聊天输入、图标按钮 | 焦点、label、role、value 正确；不误读密钥 | W(语义待扩)、M |
| UX-05 | P1 | 横竖屏、折叠/分屏、键盘弹出/收起、聊天长列表 | 布局不突变/丢状态；输入栏不被键盘遮挡 | U(responsive)、W、M |
| UX-06 | P2 | 法币、分隔符、时区和日期格式 | 资产/行情/交易/消息按地区显示且数值不变 | U(格式)、M |
| UX-07 | P1 | Settings 所有可见入口；About 版本/协议/隐私链接 | 无死链/空页/错版本；外链 HTTPS | E2E(导航待补)、M |
| UX-08 | P2 | 分享 App、清缓存、自动下载、通知和快捷回复 | 对象和持久化正确；清缓存不删钱包 | U(部分)、M |

---

## 12. 权限专项矩阵

每个权限执行：首次允许、首次拒绝、永久拒绝后从系统设置恢复、使用中撤销。

| 权限 | 入口 | 拒绝时预期 |
|---|---|---|
| 相机 | Wallet 扫码、Chat 拍照/QR/视频 | 不白屏/崩溃；解释用途；可转粘贴或相册 |
| 相册 | Chat 媒体、头像、NFT 保存 | 不触发原生崩溃；有设置引导 |
| 麦克风 | 语音消息、通话、语音房 | 不开始录音；通话安全降级/结束；状态不卡死 |
| 通知 | Chat、来电、价格/Gas 告警 | 应用内仍可用；有设置引导；不反复申请 |
| 定位 | Chat 静态/实时位置 | 不发送空坐标；明确取消 |
| 蓝牙 | 硬件钱包、通话音频 | 不假连接；可改 USB/听筒 |
| 生物识别 | App Lock、钱包备份/签名、Chat Lock | 回退密码且不降低安全级别 |

---

## 13. 弱网、异常、压力和安全专项

| ID | P | 场景 | 预期 | 自动化 |
|---|---|---|---|---|
| NET-01 | P0 | DNS 失败、无网、连接超时 | 可读错误、可重试、不丢本地数据、不显示 raw exception | U、M |
| NET-02 | P1 | 2G/3G、500-2000ms 延迟、10% 丢包 | loading 可取消；按钮防重；超时/重试可观测 | U、M |
| NET-03 | P1 | Wi-Fi↔蜂窝，正在同步/通话 | Wallet 不乱序；Matrix/LiveKit 重连；消息不丢不重 | U、M |
| NET-04 | P1 | HTTP 301/400/401/403/404/429/5xx、HTML body | 错误映射正确；不暴露 token/HTML/内部 URL；3xx 不当成功 | U、M |
| NET-05 | P1 | 连点发送/支付/领取/建群 10 次 | UI 防重、服务端幂等；最多一条真实记录 | U(部分)、M |
| NET-06 | P2 | 服务恢复后从错误页/后台返回 | 无需清数据即可恢复；无永久空态 | U(重试)、M |
| PERF-01 | P1 | 100+ 会话、1000+ 消息、500+ Token/NFT | 首屏可用、分页正确、无 ANR/OOM、滚动可接受 | benchmark(部分)、M |
| PERF-02 | P1 | 连续运行 2 小时；反复 Wallet↔Chat、媒体/通话、切账号 | 内存不无界增长；无崩溃/假死/连接泄漏 | M |
| PERF-03 | P2 | 低存储、低内存、系统回收 App | 上传/下载明确失败；重建不破坏数据库 | M |
| SAFE-01 | P0 | 发送/签名确认页检查完整地址、金额、链、spender 和 data | 显示与真实 payload 一致；关键信息不隐藏 | U(解码)、M |
| SAFE-02 | P0 | active/mining/verify 账号不同，执行 TX/WC/DApp/AA | signer 始终是 active wallet | U、M、EXT |
| SAFE-03 | P0 | 粘贴地址后确认前比对；模拟剪贴板替换 | 最终页显示真实完整地址；可发现替换 | U(地址)、M |
| SAFE-04 | P1 | 恶意 URL、XSS 文本、过大 JSON、深层 EIP-712 | 不执行消息代码；解析有上限；无卡死/栈溢出 | U、M |

---

## 14. 多链实弹记录表

P0 至少 ETH/BTC/SOL/TRX；其余按发版范围为 P1/P2。每个可见且声称支持发送的链复制一行。

| 链 | 地址派生 | 余额 | 收款 QR | 地址校验 | 费用 | 消息签名 | 交易广播 | Explorer | 结果/证据 |
|---|---|---|---|---|---|---|---|---|---|
| Ethereum/EVM |  |  |  |  |  |  |  |  |  |
| Bitcoin |  |  |  |  |  | N/A |  |  |  |
| Solana |  |  |  |  |  |  |  |  |  |
| TRON |  |  |  |  |  |  |  |  |  |
| TON |  |  |  |  |  |  |  |  |  |
| Aptos |  |  |  |  |  |  |  |  |  |
| SUI |  |  |  |  |  |  |  |  |  |
| Polkadot |  |  |  |  |  |  |  |  |  |
| Cosmos 系 |  |  |  |  |  |  |  |  |  |
| XRP |  |  |  |  |  |  |  |  |  |
| NEAR |  |  |  |  |  |  |  |  |  |
| Stellar |  |  |  |  |  |  |  |  |  |
| Cardano |  |  |  |  |  |  |  |  |  |
| VeChain |  |  |  |  |  |  |  |  |  |
| MultiversX |  |  |  |  |  |  |  |  |  |
| 其他当前可见链 |  |  |  |  |  |  |  |  |  |

---

## 15. 当前已知限制与必复测项

| ID | 现状 | 当前处理 | 发布前要求 |
|---|---|---|---|
| K-01 | 客户端曾把 MatrixRTC `livekit_service_url` 基地址误当 token API，直接发送 Matrix access token，未按协议请求 `/sfu/get` | 已改为 Matrix OpenID 换票、解析响应 `url/jwt` 并保留受控旧服务回退；生产 `healthz=200`、`sfu/get` 协议校验正常 | 两台真机/两个账号重跑 CALL-05/07；完成前标 `Fix ready / device retest pending`，不得直接标 Pass |
| K-02 | 当前真机钱包余额为 0 | 已完成无广播 UI/校验流程 | 准备受控小额钱包，重跑 TX-06~14、AA-05、DEFI-03/06/08/09、PAY-02 |
| K-03 | 历史 `integration_test/` 曾使用空断言 | 已删除空断言；增加 6 项质量门禁和生产入口完整点击流；13 个钱包资金/破坏性用例显式 `SKIP` 并附原因 | 设备流实际跑完前不得记 Pass；不得删除 `SKIP` 伪装执行 |
| K-04 | 原始行覆盖 13.07%，CI 门禁 70% | 主套件 3113 项全通过 | 对齐门禁或持续补测；不得伪报 70% |
| K-05 | Chat 红包为本地演示记录，不上链 | 页面已有免责声明 | PAY-05 每版验证；不执行真实资产断言 |
| K-06 | Egress、部分 Bridge、Local LLM、部分社交登录需外部部署/key | 未配置时应隐藏或降级 | 以 `docs/EXTERNAL_DEPENDENCIES.md` 为准；N/A 不得误标 Pass |
| K-07 | Android 16 HyperOS 3 拦截 ADB 更新安装 | 首轮最新源码 Profile 与 DEVICE-01 Driver 2/2 Pass；临时 Profile 已安全删除，最终无测试凭据 Release `2026070904` 已由文件管理器进入机主指纹安装 | 完成当前 N42Wallet 指纹验证，冷启动 Release，并确认 WalletConnect 返回日志干净 |
| K-08 | iPhone iOS 27 的旧联系人插件在 UIScene 启动时强制访问 `AppDelegate.window`，且无线 LLDB 曾导致设备无响应 | 已迁移 Flutter UIScene 生命周期，升级 `flutter_contacts` 至 Flutter 3.41 兼容的 2.1.0；Flutter 3.41.9 Profile 全量构建后 USB 安装，连续 3 次冷启动和 Driver App Smoke 2/2 通过 | Android 优先测试完成后，通过 USB 恢复 DEVICE-01；当前完整点击为 Paused，不记 Blocked/Pass |
| K-09 | iOS 模拟器依赖不兼容 arm64 | `MLImage.framework` arm64 slice 为 iPhoneOS，只有 x86_64 slice 可供模拟器；当前 Xcode 仅 arm64 | 升级/替换为含 arm64-simulator slice 的 MLImage XCFramework，删除 Runner 的 arm64 simulator 排除后复测 |

### 15.1 2026-07-13 历史人工真机基线

| 区域 | 已验证 |
|---|---|
| Wallet | Account1/2 隔离、备份门禁、无效发送、Receive、DEX/ENS 入口与错误、Wallet AI 只读、Smart Account 状态、WalletConnect 新连接、渐进加载 |
| Chat | session 保留、会话列表/全局搜索、联系人、建群/加友入口、群搜索、长按/复制/引用取消/反应、附件/Topics/Details/Files/Scheduled、Discover/Moments/Live/Voice/Mini Apps/Games、Me 设置 |
| 异常 | LiveKit 本地化失败、Push Protocol 当前 API、连续轮询无崩溃或渲染异常 |

该表来自本轮自动化改造前的人工记录，只代表当时基线，不替代新 RC 回归。

### 15.2 2026-07-13 本轮设备自动化结果

| 平台 | 设备 | 执行结果 | 结论 |
|---|---|---|---|
| Android | Xiaomi 25098RA98C / Android 16 / HyperOS 3 | 冷启动及 Wallet/Market/Chat 人工实弹通过；文本真实发送；视频呼叫权限与控制正常；生产入口 DEVICE-01 Driver 2/2 Pass；最终无凭据 Release 已进入 HyperOS 指纹安装 | `Pass with defect`：发现 WalletConnect 卸载期 `ref.read`，代码已修，仍待 Release 安装后回归 |
| iOS 真机 | iPhone 17 Pro Max / iOS 27.0 / USB | Flutter 3.41.9 Profile 全量构建、签名、安装 Pass；连续 3 次冷启动存活；Driver App Smoke 2/2 | 启动与 App Smoke `Pass`；DEVICE-01 因切换 Android 而 `Paused` |
| iOS Simulator | iPhone 17 Pro / iOS 26.5 | Xcode 无匹配的 simulator destination | `Blocked`，依赖架构不兼容，不计 Pass/Fail |

Android DEVICE-01 已取得 2/2 Driver Pass，但同轮日志发现并修复 WalletConnect 生命周期缺陷，因此发布结论仍需修复包二次真机回归。静态、单元、Widget、包、插件和后端套件不替代双端消息、完整通话、系统权限和链上广播。

---

## 16. Bug 提交标准

### 16.1 严重度

| 级别 | 定义 | 示例 |
|---|---|---|
| Blocker/P0 | 资产丢失、密钥泄露、错账号签名、无法启动/登录/恢复 | 转错地址、升级清空钱包 |
| Critical/P1 | 主流程不可用或数据严重错误 | 消息不发、余额串账号、通知跳错房间 |
| Major/P2 | 次要功能错误，有稳定绕过方式 | 某附件失败、某语言溢出 |
| Minor/P3 | 文案、样式、低频体验 | 图标对齐、非关键文案 |

### 16.2 Bug 模板

```text
标题：[平台][模块][用例ID] 简要问题
严重度：Blocker / Critical / Major / Minor
结果：Fail / Blocked
复现率：必现 / x/10 / 偶现

环境：
- App 版本 + build：
- Git commit：
- 设备 / OS：
- 网络 / 主题 / 语言 / 字体：
- 账号类型（不写密码）：
- 钱包类型 / 链（不写私钥）：

前置条件：
步骤：
1.
2.
3.

预期：
实际：
可追溯数据：脱敏 txHash / roomId / eventId / requestId、时间和时区
附件：截图 / 录屏 / 脱敏日志
```

---

## 17. 发布准入与签字

必须同时满足：

1. Android 和 iOS 各至少一台真机完成 Smoke + P0。
2. 所有 P0 Pass；无开放的崩溃、ANR、资产、密钥、错账号签名和数据丢失问题。
3. Wallet 创建/导入/备份门禁/收款/地址和金额校验在新包通过。
4. 至少一笔受控小额交易和一次真实 DApp/WC 签名可追溯；无法提供资金须书面豁免。
5. Chat 双账号文本、至少一类媒体、搜索、群消息、推送点击和 E2EE 真机通过。
6. 所有后端依赖均有 Pass/Blocked/N/A 及原因。
7. 静态分析、主自动化套件、Android Release、iOS IPA 均有当前 commit 日志。
8. 覆盖率按真实 lcov 记录；CI 门禁失败不能人工冒充通过。
9. 验证商店包版本、ID、签名、权限说明、隐私清单、协议和隐私链接。

| 角色 | 姓名 | 结论 | 日期 | 备注/豁免单 |
|---|---|---|---|---|
| Android QA |  |  |  |  |
| iOS QA |  |  |  |  |
| Wallet QA |  |  |  |  |
| Chat QA |  |  |  |  |
| 安全/风控 |  |  |  |  |
| 发布负责人 |  |  |  |  |

---

## 18. 变更记录

| 日期 | 版本 | 变更 |
|---|---|---|
| 2026-07-10 | 1.0 | 初版 Wallet 回归手册 |
| 2026-07-13 | 2.0 | 合并旧中英文清单和 T17-T25；补全 Wallet + Chat；增加自动化追溯、权限/弱网/安全/发布准入；明确 integration test 占位和 13.05% 真实覆盖率 |
| 2026-07-13 | 2.1 | 删除 integration test 空断言；新增真实 App 启动/生命周期 E2E、显式阻塞用例和自动化质量门禁 |
| 2026-07-13 | 2.2 | 增加自动化测试主文档和统一执行脚本引用；区分自动化执行、设备实弹和发布验收责任 |
| 2026-07-13 | 2.3 | 增加 Wallet + Chat 生产入口全设备点击流、运行时登录注入、真机/模拟器执行命令与本轮 Android/iOS 阻塞证据；更新自动化套件结果 |
| 2026-07-13 | 2.4 | 更新 Android 人工 Smoke 与 iOS USB 三次冷启动结果；记录 UIScene/联系人启动修复及本地网络权限阻塞 |
| 2026-07-14 | 2.5 | 更新 Android Wallet/Chat 实弹、视频权限与文本发送、DEVICE-01 Driver 结果、WalletConnect 生命周期修复和 13.07% 覆盖率基线 |
