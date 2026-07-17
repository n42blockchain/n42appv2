# N42 自动化测试执行手册

> 文档级别：自动化测试主文档（Single Source of Truth）
>
> 适用范围：N42 App、Wallet、Chat、本地插件、Dart 包、Go 后端和 Solidity 合约
>
> 当前代码基线：`master`
>
> 最近更新：2026-07-13

---

## 1. 文档定位

本手册规定自动化测试的执行命令、覆盖边界、结果判定、CI 对照、失败排查和新增测试要求。人工及真机全功能验收以 [`docs/QA_TEST_PLAN.md`](QA_TEST_PLAN.md) 为准。

历史 [`docs/archive/2025-12/TESTING_STRATEGY.md`](archive/2025-12/TESTING_STRATEGY.md) 只作为早期目标参考，不再代表当前测试文件、真实覆盖率或集成测试状态。

执行原则：

1. 能用确定性 fixture、fake、mock 或本地数据库验证的逻辑优先自动化。
2. 自动化必须验证真实结果，禁止无条件成功断言、空测试体和只延时不验证行为。
3. `SKIP`、`Blocked`、`continue-on-error` 和未执行均不计 Pass。
4. 涉及真实私钥、助记词、资金、远端账号、多设备 E2EE、推送和通话时，先自动验证协议与状态机，再执行最小真机 happy path。
5. 自动化用例名称应包含 `QA_TEST_PLAN.md` 的 Case ID，或在测试文件顶部注明覆盖映射。
6. 修复缺陷时，优先先写能复现缺陷的测试，再修改实现并验证测试转绿。

---

## 2. 结果定义

| 状态 | 定义 | 是否计入通过 |
|---|---|---|
| `Pass` | 测试实际执行且所有断言成立 | 是 |
| `Fail` | 测试执行后断言、编译、超时或清理失败 | 否 |
| `SKIP` | 测试已登记，但缺少安全 fixture、可控服务或批准数据 | 否 |
| `Blocked` | 设备、签名、权限、网络、账号或外部服务阻止执行 | 否 |
| `Not Run` | 本轮未执行 | 否 |
| `Flaky` | 同一提交和环境重复结果不一致 | 否，修复或隔离前阻止准入 |

测试进程退出码必须是 `0` 才能标 Pass。日志中的 `All tests passed!`、测试数量和提交 SHA 必须同时留证。

---

## 3. 当前测试栈与环境

| 区域 | 工具 | 当前本机 | CI 配置 |
|---|---|---|---|
| Flutter/Dart | `flutter_test`、`integration_test` | Flutter 3.41.9 / Dart 3.11.5 | Flutter 3.41.9 |
| Mock | Mockito、Mocktail、手写 fake | 由 `pubspec.lock` 固定 | 由 CI `flutter pub get` 解析 |
| 覆盖率 | Flutter LCOV | `coverage/lcov.info` | LCOV + Codecov |
| Go 后端 | Go `testing`、`httptest` | Go 1.26.1 | 当前 Flutter CI 未执行 |
| Android | Gradle/JUnit、Flutter device test | Android 16 真机可用 | API 30 Emulator |
| iOS | XCTest、Flutter device test | iOS Simulator/真机 | macOS iPhone Simulator |
| Java | Gradle toolchain | JDK 25 | 主 CI JDK 21；测试工作流 JDK 17 |

提交前以 CI 的 Flutter/JDK 组合为兼容下限。本机版本更高时，不能只凭本机通过推断 CI 必然通过。

---

## 4. 目录、责任与当前规模

| 路径 | 类型 | 当前规模 | 主要覆盖 |
|---|---|---:|---|
| `test/` | Unit/Widget/Golden/集成式组件测试 | 208 个测试文件 | Core、Wallet、AA、WalletConnect、Markets、Mining、宿主 UI |
| `packages/n42_chat/test/` | Chat Unit/Widget/Service | 30 个测试文件 | Push、消息工具、E2EE 工具、通话工具、无障碍、AI/贴纸 |
| `integration_test/app_test.dart` | 真 App 设备 Smoke | 1 个真实用例 | 生产入口、Navigator/路由注册、前后台生命周期 |
| `integration_test/device_full_flow_test.dart` | 真 App 设备点击 | 1 个生产入口用例 | Wallet、Market、Drawer、Chat 登录/搜索/主页签的安全点击与断言 |
| `integration_test/flows/wallet_flow_test.dart` | 设备用例登记 | 13 个显式 `SKIP` | 钱包 fixture、RPC 和测试网资金建设清单 |
| `test/quality/` | 自动化质量门禁 | 1 个文件 | 空断言、E2E 入口、SKIP 原因、测试文档完整性 |
| `packages/n42_jmt_verify/test/` | Dart Unit | 1 个文件 | Blake3/JMT proof 基础逻辑 |
| `plugins/flutter_mining/test/` | Flutter plugin Unit | 2 个文件 | Platform interface、MethodChannel |
| `plugins/flutter_mining/android/src/test/` | Kotlin JUnit | 1 个文件 | Android plugin registration |
| `backend/livekit-jwt/` | Go Unit/HTTP | 2 个测试文件 | JWT handler、Matrix 校验 |
| `backend/social-auth/` | Go Unit | 1 个测试文件 | 社交登录 |
| `backend/swap/` | Go Unit/Service | 6 个测试文件 | Quote、Alert、Price、Commit history |
| `backend/loyalty/` | Go Unit/HTTP | 1 个测试文件 | 鉴权、链上签到确认、溢出和推荐双边入账 |
| `contracts/loyalty/` | Foundry | 1 个 Solidity 测试文件 | 普通不可转让积分、签到、任务、推荐、消费和暂停 |
| `ios/RunnerTests/`、`macos/RunnerTests/` | XCTest | 各 1 个模板文件 | 当前仅模板，不计有效业务覆盖 |

`n42_chat` 在 `pubspec.yaml` 中声明为 Git 依赖，但本工作区通过 `pubspec_overrides.yaml` 指向 `packages/n42_chat/`。本地 Chat 测试结果仅对该 mirror 当前内容有效；提交前必须核对 Git dependency ref 与发布构建实际来源。

---

## 5. 前置准备

```bash
cd <repo-root>
flutter pub get
flutter doctor -v
flutter devices
```

要求：

1. `pubspec.lock` 与工作区依赖一致。
2. 本地 `pubspec_overrides.yaml` 不得意外改变发布依赖来源。
3. `.env`、签名文件、登录凭据、私钥和助记词不得加入 Git。
4. SQLite、secure storage 或缓存类测试必须使用临时目录并在 `tearDown` 清理。
5. 设备测试前保持手机解锁、信任开发电脑，并关闭会拦截调试安装的系统策略。

---

## 6. 统一执行脚本

仓库统一入口：

```bash
# 快速门禁：静态分析、自动化质量检查
./scripts/run_automated_tests.sh quick

# 完整自动化：quick + Flutter 覆盖率 + Chat + 本地包/插件 + Go 后端
./scripts/run_automated_tests.sh full

# 真机/模拟器启动 Smoke（不需要 Chat 凭据）
DEVICE_ID=<flutter-device-id> ./scripts/run_automated_tests.sh device-smoke

# 真机/模拟器 Wallet + Chat 完整安全点击流（凭据只放当前进程环境）
read -r -p "Chat test user: " N42_E2E_CHAT_USERNAME
read -r -s -p "Chat test password: " N42_E2E_CHAT_PASSWORD
printf '\n'
export N42_E2E_CHAT_USERNAME N42_E2E_CHAT_PASSWORD
DEVICE_ID=<flutter-device-id> ./scripts/run_automated_tests.sh device
unset N42_E2E_CHAT_USERNAME N42_E2E_CHAT_PASSWORD

# 独立全仓格式审计
./scripts/run_automated_tests.sh format
```

无线连接的 iOS 设备必须发布 VM Service 端口：

```bash
DEVICE_ID=<wireless-ios-id> \
PUBLISH_PORT=1 \
./scripts/run_automated_tests.sh device
```

除 Chat 登录外如需其他编译期配置，只传本地且已忽略的文件：

```bash
DEVICE_ID=<flutter-device-id> \
DART_DEFINE_FILE=.env \
./scripts/run_automated_tests.sh device
```

脚本不会创建凭据文件，也不会把配置值写入测试报告。不得把 Chat 登录写进 `DART_DEFINE_FILE`，不得用 `set -x` 执行带 secrets 的设备命令；执行后立即 `unset` 两个环境变量。Debug 构建可能包含编译期 define，测试结束后不得分发该 Debug 包，发布包必须重新无凭据构建。

---

## 7. 分层执行命令

### 7.1 格式与静态分析

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-fatal-infos --no-pub
```

任何 error、非零退出或格式差异均为 Fail。`--no-fatal-infos` 只允许 info，不允许忽略 error。

当前使用 Dart 3.11 执行全仓格式审计会报告 296 个历史文件需要格式化，因此 `format` 模式当前为已知 Fail，且尚未接入 `quick/full`。修复应单独提交，不能和业务或测试改动混在一起；`.github/workflows/ci.yml` 的同类格式步骤也会受此基线影响。

### 7.2 自动化质量门禁

```bash
flutter test --no-pub test/quality/integration_test_quality_test.dart
```

门禁必须验证：

- `integration_test/` 不存在无条件成功断言。
- App E2E 调用生产 `main()`，不是测试替身入口。
- 待建设设备用例显式 `skip: true` 且报告包含阻塞原因。
- 人工和自动化主文档存在、Case ID 唯一、覆盖范围完整。

### 7.3 Flutter 主套件

```bash
# 开发阶段，按目录或文件快速反馈
flutter test --no-pub test/features/wallet/
flutter test --no-pub test/core/security/
flutter test --no-pub test/features/wallet_connect/

# 发布候选，全量串行并生成覆盖率；macOS 先提高当前 shell 的软上限
ulimit -n 10240
flutter test --no-pub --coverage --concurrency=1
```

串行执行用于降低共享数据库、计时器、全局 provider 和原生 mock 的资源竞争。macOS 默认 `maxfiles=256` 时，本项目会在约 3000 项后让 Flutter DDS 报 `Too many open files`；`ulimit` 仅调整当前 shell，不修改系统配置。若并发模式失败而串行通过，仍须按 Flaky 排查，不得直接忽略。

### 7.4 Chat 套件

```bash
(
  cd packages/n42_chat
  flutter test --no-pub
)
```

重点检查 Push token/路由、Matrix 消息工具、E2EE/MLS 工具、通话参数、附件/贴纸、无障碍和 Widget 行为。真实 Matrix 房间、APNs/FCM、CallKit、LiveKit 和多设备密钥恢复仍需设备实弹。

### 7.5 本地 Dart 包与 Flutter 插件

```bash
(
  cd packages/n42_jmt_verify
  dart test
)

(
  cd plugins/flutter_mining
  flutter test --no-pub
)
```

MethodChannel fake 通过不等于 Android/iOS 原生实现通过。插件原生代码改动时，还必须运行对应 Gradle/XCTest，并在真机调用至少一个安全的只读方法。

### 7.6 Go 后端

```bash
(cd backend/livekit-jwt && go test -count=1 ./...)
(cd backend/social-auth && go test -count=1 ./...)
(cd backend/swap && go test -count=1 ./...)
(cd backend/loyalty && go test -count=1 ./...)
```

Go 单元测试不能替代部署验证。Nginx 路由、TLS、CORS、密钥注入和真实 Matrix/LiveKit 上游必须按 `QA_TEST_PLAN.md` 的 `EXT` 用例执行。

积分合约使用 Foundry 单独执行：

```bash
(cd contracts/loyalty && forge test)
```

必须验证默认每日 10 分、同一 UTC 日不可重复签到、request ID 防重放、推荐双方奖励、余额消费、operator 权限和紧急暂停。Foundry 通过不代表合约已部署，也不代表 relayer 已获得 N42 Gas。

### 7.7 真机/模拟器集成测试

```bash
flutter devices
DEVICE_ID=<device-id> ./scripts/run_automated_tests.sh device-smoke
```

当前 `app_test.dart` 自动验证：

1. 调用生产 `main()`。
2. 30 秒内出现 `MaterialApp`。
3. `Navigator` 和关键命名路由已注册。
4. pause/resume 后 App 仍存活且无 Flutter exception。

完整安全点击流：

```bash
export N42_E2E_CHAT_USERNAME=<runtime-only>
export N42_E2E_CHAT_PASSWORD=<runtime-only>
DEVICE_ID=<device-id> ./scripts/run_automated_tests.sh device
```

`device_full_flow_test.dart` 调用生产 `main()`，通过稳定 `ValueKey` 实际执行 `tester.tap` 和 `tester.enterText`，覆盖：

1. 首次协议确认与 Wallet、Mining、Earn(Android)、Market 主导航。
2. Market Trending/Search/Watchlist/News 与真实搜索输入。
3. Wallet 账号选择器、Wallet AI、WalletConnect、QR 收款菜单、Send/Receive/Swap 安全入口、ENS 和 Smart Account。
4. Profile、Wallet Manage、Address Book、Security、Settings、Loyalty、Airdrop、Browser、About 全部非破坏性 Drawer 入口。
5. Chat 欢迎/登录、运行时账号输入、全局搜索、Messages/Contacts/Discover/Me 和新增菜单。
6. 每步检查目标页面或控件存在，并检查未出现未处理 Flutter exception。

设备流在路由返回后额外推进一帧并读取 `tester.takeException()`，用于捕获组件真正卸载时才出现的生命周期错误。文本输入后主动收起 IME，避免键盘遮挡顶部按钮却产生非致命 `tap()` 警告。

该流只打开并返回交易、签名、二维码和账户管理入口，不输入助记词、不确认密码、不删除数据、不广播交易。它不能替代相机/麦克风/通知原生权限、双端消息到达、推送、LiveKit 通话、多设备 E2EE、真实 WalletConnect DApp 或链上最终状态。

`wallet_flow_test.dart` 的 13 项目前全部显式 `SKIP`。运行器显示它们不等于执行成功；只有实现安全 fixture、稳定控件 key/semantics、可控 RPC 并删除对应 `skip` 后，才能计 Pass。

设备环境注意事项：

- Android/HyperOS 可能直接以 `INSTALL_FAILED_USER_RESTRICTED` 拒绝 ADB 更新。可把同证书 APK 放入 Download 后从文件管理器更新，但“未经安全检测”和机主指纹必须人工确认；自动化不得绕过生物验证。
- 无线 iOS 使用 `PUBLISH_PORT=1`，测试期间保持设备解锁、屏幕常亮、Local Network 权限开启。条件允许时优先 USB。
- 当前 iOS 模拟器受旧 `MLImage.framework` 架构阻塞：其 arm64 slice 是 `iPhoneOS`，并非 `arm64-simulator`；在依赖升级前不能把模拟器未运行记为 App Fail。
- 任何安装、签名、系统权限或调试器错误都先判定发生在“用例开始前”还是“用例执行中”。前者记录 `Blocked`，后者根据断言和 App 行为记录 `Fail`。

---

## 8. 覆盖率生成与判定

生成：

```bash
ulimit -n 10240
flutter test --no-pub --coverage --concurrency=1
```

计算原始行覆盖率：

```bash
awk -F: '
  /^LF:/ { total += $2 }
  /^LH:/ { hit += $2 }
  END { printf "lines: %d/%d = %.2f%%\n", hit, total, 100 * hit / total }
' coverage/lcov.info
```

当前规则：

1. 报告原始 `LH/LF`，不得只报测试数量。
2. 生成文件、平台适配层或不可测代码若需排除，必须在 CI 和本地使用同一规则，并在报告列出排除模式。
3. 不得通过删除低覆盖文件、只测简单 getter 或修改分母来伪造提升。
4. `.github/workflows/ci.yml` 设置整体门禁 70%；最近真实原始基线为 13.60%，当前不满足门禁。
5. 覆盖率不足时仍可报告“测试执行 Pass”，但整体发布准入必须报告“Coverage Gate Fail/Blocked”，两者不能混写。

建议分阶段目标：

| 阶段 | 原始行覆盖目标 | 优先内容 |
|---|---:|---|
| A | 20% | Core security/network/storage、Wallet 签名/序列化、Chat Push |
| B | 35% | Providers、Repositories、错误/空/加载状态、AA/WC |
| C | 50% | 关键 Widget、导航、主题/国际化、数据库迁移 |
| D | 70% | 补齐业务分支并将 CI 门禁恢复为真实阻断 |

---

## 9. Wallet 自动化覆盖要求

| QA 范围 | 自动化重点 | 测试层 | 真机保留 |
|---|---|---|---|
| WLT | 助记词/私钥格式、地址派生、钱包隔离、备份 payload、删除门禁 | Unit/Provider/Native | 敏感页面遮挡、备份实操、卸载恢复 |
| CHN | 链配置、地址规则、自定义链、Token metadata、链切换 | Unit/Repository | RPC 兼容、真实余额和 Explorer |
| TX | 地址/金额/decimals、序列化、Gas、重试、轮询、memo | Unit/Widget/Fake RPC | 密码/生物识别、签名、广播和到账 |
| AA | UserOp、EIP-4337/7702、Session Key、Gas 估算 | Unit/Fake Bundler | 部署、Paymaster、真实上链 |
| WC/DAPP | URI、方法映射、链切换、会话状态、拒绝路径 | Unit/Provider/E2E fake | 二维码、真实 DApp、硬件确认 |
| MKT/ENS/PORT | 搜索、格式、去抖、分页、回退和错误映射 | Unit/Widget/HTTP fake | 生产数据正确性和第三方可用性 |
| DEFI/NFT | Quote/model、审批状态、批量资格、展示规则 | Unit/Provider | Swap/Bridge/Staking/NFT 真正执行 |
| GROW | 动态签到积分、不可转让合约、鉴权/防重放、推荐双边历史、空投 HTTPS 与无假数据回退 | Unit/Widget/Go/Foundry | 测试网部署、官方 Gas、第三方领取和批量转账广播 |

每个资金相关自动化默认不得连接主网广播端点。需要网络合约测试时使用 fake server、本地节点或批准的测试网隔离钱包。

---

## 10. Chat 自动化覆盖要求

| QA 范围 | 自动化重点 | 测试层 | 真机保留 |
|---|---|---|---|
| CHT | 登录错误映射、会话排序、搜索、分页、空/失败状态 | Unit/Widget/Fake Matrix | 真实账号登录和会话同步 |
| MSG | 消息解析、发送状态、回复/反应、附件 metadata、去重 | Unit/Widget/Repository fake | 双端到达、已读、输入态、媒体上传 |
| GRP | 权限状态机、邀请/移除请求、成员筛选 | Unit/Widget | 三账号真实群管理 |
| PUSH | token 解析、注册 payload、去重、点击路由 | Unit/Integration fake | APNs/FCM 前后台和杀进程 |
| CALL | JWT/URL 解析、房间参数、错误本地化、生命周期状态 | Unit/Go/Widget | 麦克风/相机、CallKit、LiveKit 双端 |
| E2EE | 加密工具、SAS 状态、恢复数据校验 | Unit/Repository fake | 新设备验证、跨设备历史解密 |
| PAY | URI、金额和业务消息模型 | Unit/Widget | 钱包确认、真实 txHash 和资产变化 |
| AI/Discover | 解析、规划器、失败回退、内容卡片 | Unit/Widget | 外部模型、直播、Mini App 实际服务 |

自动化测试使用的 Chat fixture 必须是一次性数据。登录账号与密码只通过 CI Secret 或本地安全注入，不得出现在测试源码、快照、日志或 Markdown。

---

## 11. Fixture、Mock 与测试数据规则

| 依赖 | 推荐替身 | 必测情况 |
|---|---|---|
| HTTP/Dio | Adapter/fake server | 200、3xx、400、401、403、404、409、429、500、超时、断连、坏 JSON |
| RPC/Bundler | 本地 fake RPC | 成功、revert、nonce 冲突、Gas 变化、pending、重复轮询 |
| Matrix | Repository fake/受控 homeserver | 登录过期、分页、重复 event、解密失败、离线重放 |
| Secure storage | 内存 fake/临时 keychain namespace | 不存在、损坏、迁移、删除、并发访问 |
| SQLite | 临时数据库 | 空库、旧 schema、迁移失败、重复数据、大数据量 |
| 时间 | Fake clock | 时区、过期、倒计时、跨日、系统时间跳变 |
| 文件/媒体 | 临时目录和小型 fixture | 不支持格式、超限、损坏、取消、权限拒绝 |

禁止条件：

- 在测试文件中保存真实助记词、私钥、钱包密码或长期 Access Token。
- 用生产主网钱包执行无人值守广播。
- 测试依赖执行顺序或复用上一个测试留下的全局状态。
- 使用无限 `pumpAndSettle()` 掩盖持续动画、轮询或泄漏计时器。
- 为了让 CI 变绿而删除断言、增加无原因 `skip` 或使用 `continue-on-error`。

---

## 12. 新增测试标准

### 12.1 文件与命名

- 路径镜像生产代码：`lib/features/x/a.dart` 对应 `test/features/x/a_test.dart`。
- 文件以 `_test.dart` 结尾。
- 用例名称描述输入、动作和结果，包含适用的 QA Case ID。
- 公共 fixture 放 `test/helpers/`；只被单模块使用的 fake 留在该模块测试目录。

### 12.2 最小场景集

每个新业务行为至少包含：

1. 正常路径。
2. 空值、边界值和最大长度。
3. 依赖失败、超时或坏数据。
4. 重复操作和幂等性。
5. 取消、返回或生命周期中断。
6. 涉及账户/钱包时的跨账号隔离。
7. 涉及 UI 时的 loading、empty、error、success 状态。
8. 涉及文案时的长文本、大字体、深浅主题或 RTL 风险。

### 12.3 Review 清单

- [ ] 测试在修复前能复现问题或明确失败。
- [ ] 测试没有真实 secrets、资金或生产写操作。
- [ ] 断言验证用户可见结果或业务契约，不只验证 mock 被调用。
- [ ] `setUp`/`tearDown` 清理全局状态、数据库、文件、计时器和平台 override。
- [ ] Case ID 和自动化层级已回写 `QA_TEST_PLAN.md`。
- [ ] 目标文件、模块套件、全量套件均通过。
- [ ] 覆盖率变化有记录；下降有明确原因和批准。

---

## 13. CI 现状与风险

### 13.1 `.github/workflows/ci.yml`

- 执行 root `flutter test --coverage` 和 70% 原始覆盖率门禁。
- 当前真实基线低于 70%，该 job 理论上会在 coverage step 失败。
- 未执行 `packages/n42_chat`、`n42_jmt_verify`、`flutter_mining`、四个 Go module 和 Foundry 合约测试。
- Android/iOS build 使用 `continue-on-error: true`，构建失败不会阻止整体测试结论。
- performance job 对冷启动、内存等状态写固定成功符号，不是测量结果。

### 13.2 `.github/workflows/test.yml`

- unit job 运行 `test/` 并生成覆盖率，但“coverage threshold”步骤没有实际计算。
- Widget job 只运行 `test/widget/`，不代表全部 Widget 测试。
- iOS/Android integration job 使用 `continue-on-error: true`，不能作为发布门禁。
- summary 只依赖 unit/widget，不包含 integration 结果。

### 13.3 修正优先级

1. CI 调用本手册统一脚本或等价命令，加入 Chat、本地包/插件和 Go 测试。
2. 将 integration 的真实 `app_test.dart` 设为阻断；显式 `SKIP` 继续单独报告。
3. 删除固定成功的性能结论，改为真实 trace/benchmark 阈值。
4. 统一 Flutter、Java 和覆盖率算法，避免两个 workflow 给出矛盾结果。
5. 先持续提升真实覆盖率，再让 70% 成为可达且不可绕过的门禁；期间必须显式显示未达标。

---

## 14. 失败排查

| 症状 | 首查 | 处理 |
|---|---|---|
| 编译失败 | `flutter pub get`、lock/override、生成文件 | 对齐依赖；必要时重新生成，不手改 generated 文件 |
| 单测单独过、全量失败 | 全局单例、共享 DB、timer、platform override | 补 `tearDown`，移除顺序依赖 |
| `pumpAndSettle` 超时 | 无限动画、轮询、未关闭 stream | 使用有上限的 pump，并断言具体状态 |
| Android 安装失败 | 手机解锁、USB install、旧签名包、存储 | 允许调试安装或卸载冲突测试包后重试 |
| iOS 找不到设备 | 解锁、Trust、Developer Mode、无线连接 | `flutter devices` 确认 ID，必要时 Xcode 首次运行 |
| E2E 启动超时 | 编译期配置、初始化网络、权限弹窗 | 保存设备日志，区分 App 失败与环境 Blocked |
| Go 后端失败 | env、端口、时区、race | 优先使用 `httptest`；不得依赖本机长期服务 |
| 覆盖率异常下降 | 新文件、生成文件、测试未执行 | 对比 LCOV 文件列表和 `LH/LF`，不要只看百分比 |

Flaky 用例必须至少重复 10 次定位：

```bash
for i in {1..10}; do
  flutter test --no-pub path/to/flaky_test.dart || break
done
```

---

## 15. 测试报告模板

```text
Commit:
Branch:
执行时间/时区:
执行机器与 Flutter/Dart/Go/Java:
设备 ID / OS（设备测试时）:

命令:
结果: Pass / Fail / SKIP / Blocked
Passed / Failed / Skipped 数量:
耗时:
原始行覆盖率 LH/LF:
日志或 CI Artifact:

失败 Case ID:
首个错误:
是否可重复:
阻塞原因/负责人/预计解除时间:
```

日志、截图和 Artifact 必须脱敏。不得粘贴登录密码、Access Token、助记词、私钥、完整 WalletConnect URI 或签名环境变量。

---

## 16. 2026-07-14 当前执行基线

| 套件 | 结果 | 可信范围 |
|---|---|---|
| Flutter 主套件 | Pass，3147 tests | root `test/`；本轮重新生成 lcov，原始行覆盖率为 `16118/118558 = 13.60%` |
| Airdrop/Loyalty 定向 Flutter | Pass，15 tests | API 正常/空/非 JSON/超时解析、HTTPS 限制、无 mock 回退、钱包地址、动态签到分值和推荐入口 |
| 自动化质量门禁 | Pass，7 tests | 空断言、真实入口、显式 SKIP、QA 文档、设备点击、运行时登录和 WalletConnect 生命周期约束 |
| Android 人工实弹 | Pass | Wallet/Market/Chat、真实文本发送、附件入口、视频呼叫权限和控制均已覆盖 |
| Android 完整点击 | Pass with defect | 生产入口 DEVICE-01 Driver 2/2 Pass；发现并修复 WalletConnect 卸载异常；临时 Profile 已删除，最终无凭据 Release `2026070904` 等待 HyperOS 指纹安装回归 |
| iOS USB 启动 Smoke | Pass | Flutter 3.41.9 Profile 全量构建并安装；连续 3 次冷启动，每次 8 秒后进程存活 |
| iOS 真机 App Smoke | Pass | USB Flutter Driver 2/2；DEVICE-01 因用户要求优先 Android 而暂停 |
| iOS Simulator 完整点击 | Blocked | `MLImage.framework` 不含 arm64-simulator slice，无匹配 destination |
| Wallet device flows | 13 `SKIP` | 未执行；等待安全 fixture/RPC |
| Chat 独立套件 | Pass，286 tests | 不替代双真机通话、推送和多设备 E2EE |
| JMT verification | Pass，13 tests | 含 BLAKE3/JMT proof；不替代原生调用 |
| Mining plugin | Pass，3 tests | Dart/MethodChannel fake；不替代真机挖矿原生实现 |
| Go 后端 | Pass；Loyalty 定向 6 tests | Loyalty 覆盖接口鉴权、内部任务令牌、链上确认、溢出和推荐双边入账；服务仍待部署 |
| Loyalty Foundry | Pass，8 tests | 普通非 ERC-20 积分合约；仍待 N42 测试网部署、验证和 relayer 充值 |
| Android 新功能点击 | Blocked | debug APK 构建成功；旧签名包已卸载，新包被设备 `INSTALL_FAILED_USER_RESTRICTED` 拒绝，DEVICE-01 未开始 |
| iOS 新功能点击 | Not Run | debug 无签名编译成功；本轮未安装到真机，不能计设备 Pass |

本节必须在每次完整执行后用真实数字更新。详细人工基线、生产 LiveKit 路由和零余额阻塞见 `QA_TEST_PLAN.md` 第 15 节。

---

## 17. 自动化建设待办

| 优先级 | 工作 | 完成标准 |
|---|---|---|
| A0 | CI 加入空断言和文档质量门禁 | PR 无法绕过 |
| A0 | CI 独立执行 Chat、Go、本地包/插件 | 每组有独立状态和日志 |
| A1 | Wallet fake RPC + secure-storage fixture | TX-04/05/10/13 删除 `SKIP` 并稳定运行 |
| A1 | Chat fake homeserver/repository E2E | 登录替身、会话、发送、搜索可重复点击 |
| A1 | Push/Deep Link device harness | 前后台、冷启动、重复通知可自动断言 |
| A2 | Screenshot/golden 基线治理 | Light/Dark/大字体/伪本地化有审阅流程 |
| A2 | 性能 trace | 冷启动、导航、长列表、内存使用有真实阈值 |
| A2 | 覆盖率提升 | 分阶段达到 20/35/50/70%，分母规则一致 |

---

## 18. 变更记录

| 日期 | 版本 | 变更 |
|---|---|---|
| 2025-12-29 | 0.1 | 历史测试策略，现已归档 |
| 2026-07-13 | 1.0 | 建立当前自动化主文档；盘点真实目录/规模；补充统一脚本、CI 差异、Wallet/Chat 映射、覆盖率和设备测试规则 |
| 2026-07-13 | 1.1 | 增加生产入口 Wallet + Chat 全设备点击流、运行时登录注入、无线 iOS driver、平台阻塞判定和本轮完整套件结果 |
| 2026-07-13 | 1.2 | 统一 Flutter 3.41.9 工具链；记录 Android 人工 Smoke、iOS USB 冷启动和 macOS 本地网络权限阻塞 |
| 2026-07-14 | 1.3 | 记录 Android DEVICE-01 2/2、Chat 实弹和 WalletConnect 生命周期缺陷；增强路由卸载/IME 自动化断言；更新 13.07% 覆盖率基线 |
| 2026-07-14 | 1.4 | 增加普通 Loyalty 合约/relayer、Airdrop/Loyalty Flutter 回归命令与覆盖映射；删除伪造积分成功的旧占位测试；记录 3147/15/6/8 自动化结果及双平台新功能真机状态 |
