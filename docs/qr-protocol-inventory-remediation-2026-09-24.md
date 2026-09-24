# QR 编码与解码协议盘点及整改方案

日期：2026-09-24

范围：N42 Wallet、N42 Chat、硬件钱包、身份扫码、安装邀请、TOTP、WalletConnect 与二维码扫描器。

## 摘要

系统目前没有单一的二维码协议：钱包支付、Chat 用户/群组、WalletConnect、Matrix、硬件钱包 UR、身份链接、安装邀请及 TOTP 各自使用不同载荷。主要风险是二维码携带的信息不足，扫描后只能猜测资产/网络；Chat 生成的部分链接没有对应的解析路径；两套相机扫描实现生命周期不一致。

整改按三个优先级实施：P0 保证钱包付款码精确指向链、网络、资产和收款人；P1 让 Chat 用户、房间及外部社交链接可按其公开格式识别，并在加入房间或离开应用前征求用户确认；P2 统一相机扫码实现并回归权限、补光灯和单次返回行为。

## 现状清单

| 场景 | 当前编码 | 当前解码/处理 | 主要问题 |
| --- | --- | --- | --- |
| 钱包收款 | `wallet_receive_qr.dart`：EVM 有金额时用 EIP-681；BTC、SOL、TON、TRX、XRP、Cosmos、NEAR 有金额时使用各自 scheme；无金额大多输出裸地址；其他链拼接 `?amount=` | `scan_to_pay_utils.dart` 只将 EIP-681 解析为资产请求；钱包首页 `wallet_page.dart` 将其路由到指定发送页，其他内容走币种选择 | 无金额时丢失链/资产；非 EVM token URI 没有一致的 token 身份；部分通用拼接不是已定义标准；错误 URI 可能回退到地址选择 |
| Chat 个人码 | `my_qrcode_page.dart`、个人资料页生成 `n42chat://user/<Matrix user ID>` | `social_scan_payload_parser.dart` 支持 N42 用户码、裸 Matrix 用户 ID、`matrix.to` 用户链接 | 自有 scheme 仅 N42 客户端识别，其他 Matrix 客户端不一定识别 |
| Chat 联系人/分享链接 | `user_profile_page.dart` 复用可分享链接组件；`shareable_link_actions.dart` 将调用方传入的 `link` 编成 QR | 取决于链接所属服务；通用 scanner 当前只处理 Matrix 用户、商户支付和内置 mini-app | 通用链接二维码不等于可信链接；必须按域名/协议分流，不能对任意 URL 自动执行 |
| Chat 群/空间码 | 数据源通过 `buildMatrixToRoomLink` 生成 `https://matrix.to/#/...` | 当前社交解析器只识别 Matrix 用户链接 | 同一 Chat 扫码页不能识别自己生成的房间/空间码 |
| Chat 商户收款 | `n42pay://pay?to=&amount=&token=<symbol>&memo=&chain=`；旧桥接还生成 `n42://pay?address=` | `payment_request_uri.dart` 解析新旧形式；扫描确认金额后调用钱包桥 | `chain` 可缺省，token 只用符号，无法跨链/同符号 token 精确识别；商户页没有稳定资产身份 |
| WalletConnect | `wc:` pairing URI | `wallet_connect_uri.dart` 识别并走连接流程 | 属于 DApp-钱包会话配对，不是收款协议；必须保留独立路由 |
| 硬件钱包 | Keystone 使用 `ur:eth-sign-request`、`ur:eth-signature`、`ur:crypto-hdkey`、`ur:crypto-account`；实现位于 `keystone_service.dart`、`ur_codec.dart`、`ur_fountain.dart` | 硬件钱包专用处理器 | UR 是类型化/分片传输体系，不应与支付 URI 混为一谈 |
| 离线签名展示 | `keystone_sign_page.dart` 使用 `QrImageView` 显示 UR/签名数据 | Keystone/硬件钱包扫码器重组分片数据 | 需保留 UR 类型、序号校验与多帧生命周期，不走通用单帧支付 parser |
| 通用钱包扫码 | `ScanPage` 使用 `qr_code_scanner_plus`，返回原始字符串 | 首页按 WalletConnect / EIP-681 / 地址分流 | 另一套扫描生命周期与 Chat 的 `mobile_scanner` 不同；目前权限检查中 iOS 与 Android 语义也不一致 |
| Chat 扫码 | `ScanQRPage` 使用 `mobile_scanner`，另支持相册识别和手动输入 | 先解析商户收款 URI，再解析社交码/内置 mini-app | Room permalink 未接入；外部社交链接未形成受限且有确认的统一路径 |
| 身份 Hub | `id_hub_scan.dart` 处理 `n42id://` | 身份专用流程 | 协议有独立业务语义，需保持隔离 |
| 邀请/下载/外部分享 | `setting_share.dart` 将 Browser 邀请/下载链接写入 QR；Chat `shareable_link_actions.dart` 以二维码分享调用方 URL | 浏览器/调用方业务页 | 需要验证域名、邀请状态和敏感参数；不得由钱包付款扫描器自动处理 |
| 认证器设置 | 钱包 Google Auth 与 Chat `Totp2faSetupPage` 生成 `otpauth://totp/...` | Google/Auth/TOTP 专用设置流程 | QR 含可直接生成验证码的共享密钥，禁止写入日志/通用扫描历史 |
| 安装/邀请 | `setting_share.dart` 生成 N42 Browser `/download?uuid=...&code=...` | 外部安装/邀请页面 | 载荷包含邀请信息，应单独校验有效期和签名/服务端状态；不能当作支付地址解析 |
| TOTP | `totp_util.dart` 与 Chat `totp.dart` 使用 `otpauth://` | OTP 专用解析器 | QR 包含密钥，扫描/分享需按秘密凭据保护 |
| 账户抽象账户 | `aa_account_detail_page.dart` 生成裸 EVM 地址 | 普通地址处理 | 缺少 chain ID，不能直接判定资产/网络 |
| 钱包桥接旧收款码 | `n42://pay?address=...` | Chat 兼容解析 | 没有网络或 token 身份，只能作为旧版兼容载荷 |

代码库中未发现服务端独立生成或解析这些 QR 协议的实现；服务端的支付请求/邀请 API 是否另有运行时契约，仍需与 API owner 核对。Chat 实现位于 `packages/n42_chat` 本地镜像，而正式依赖由 `pubspec.yaml` 的 Git 引用决定；本仓库完成后须将改动回推/同步至正式依赖源再发布。

检索覆盖了 app 与 `packages/n42_chat` 中二维码渲染 (`QrImageView`)、相机扫码 (`QRView`、`MobileScanner`) 和主要 URI scheme。二维码不仅限于支付，因此 P0 parser 只识别明确的支付协议，Chat、身份、认证器、硬件钱包与邀请继续使用专属处理器。

## 行业标准对比

| 标准 | 适用范围 | 对 N42 的要求 |
| --- | --- | --- |
| [EIP-681](https://eips.ethereum.org/EIPS/eip-681) | EVM 交易/付款 URI；chain ID、函数和 ABI 参数可写入 URL | 保留原生币 `value` 与 ERC-20 `transfer(address,uint256)` 格式；严格校验目标、chain ID、函数和重复参数，不能让未知交易调用进入转账流程 |
| [Bitcoin BIP-321](https://github.com/bitcoin/bips/blob/master/bip-0321.mediawiki) | `bitcoin:` 支付指令 URI；BIP-21 的后继规范，支持金额和扩展支付指令 | 支持地址、amount 与必要参数；未经用户确认不得支付；不能把 Bitcoin URI 当作可复用个人身份 |
| [Solana Pay v1](https://solana.com/docs/tools/solana-pay/specification/version1) | SOL 与 SPL Token 转账请求 URI | `spl-token` 必须使用 mint 地址而非 token 符号；amount 是用户单位；无金额时由付款方输入；本地 token 解析应匹配 mint |
| [CAIP-2](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md) / [CAIP-19](https://standards.chainagnostic.org/CAIPs/caip-19) | 跨链 network / asset 标识 | 可用于统一内部标识；它们本身不是完整支付 QR 协议，不能代替收款人、金额、memo 等请求字段 |
| [WalletConnect URI (EIP-1328)](https://eips.ethereum.org/EIPS/eip-1328) | 钱包与 DApp 建立会话的配对 URI | 保持独立连接流程；不得作为普通转账 URI 处理 |
| [BC-UR](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md) | 类型化二进制数据与二维码分片传输 | 继续用于硬件钱包/离线签名数据；不改写成支付 URI |
| [Matrix permalink](https://spec.matrix.org/v1.8/appendices/) | Matrix 用户、房间、事件的可移植链接 | Chat 自有用户码优先输出 `https://matrix.to/#/<user-id>`；房间链接按 Matrix permalink 语法解析，加入前由用户确认 |
| [WhatsApp Click to Chat](https://faq.whatsapp.com/5913398998672934) | 使用国际格式电话号码的 `https://wa.me/<number>` 链接 | 扫描后显示目标号码并要求确认，再打开外部 WhatsApp/系统链接；不得默认将号码上传为联系人 |
| vCard / 社交平台二维码 | 联系人信息交换或平台内部邀请 | 可选支持标准 `BEGIN:VCARD` 联系人卡；微信等平台私有/动态二维码没有跨平台统一解析格式，应安全拒绝或提示到对应官方应用处理，不能伪称通用兼容 |
| [Google Authenticator Key URI](https://github.com/google/google-authenticator/wiki/Key-Uri-Format) | TOTP 密钥导入 | 保持 OTP 专用流程，秘密不得流入社交/支付解析日志 |

### Chat 兼容性边界

Chat 码分为三类，采用与主流社交软件相同的可预期行为：

1. **跨客户端协议链接**：Matrix 用户/房间 permalink 能被其他 Matrix 客户端理解。N42 继续保留旧 `n42chat://user/` 解析兼容，但新生成个人码改为 Matrix permalink。
2. **外部平台链接**：WhatsApp 使用官方 `wa.me` 点击聊天格式；显示号码、提示将离开 N42 后再打开。扫描本身不代表好友关系或授权。
3. **平台私有二维码**：微信及其他封闭平台可能使用账号绑定、短期 token 或服务端动态数据。没有公开稳定的互操作协议时，不自行猜解；给出“使用对应官方应用扫码”的反馈。可互通的联系方式使用 vCard，而不是冒充微信/WhatsApp 私有码。

用户确认必须先于打开外部 URL、发起私聊或加入群/空间。解析器只接受 Matrix permalink 的 HTTPS 主机 `matrix.to` 与 WhatsApp 的 HTTPS 主机 `wa.me`，不允许把任意扫码 URL 传给通用 launcher。

Web3 领域没有一个能跨链、跨钱包的通用“token QR”标准：EIP-681 和 Solana Pay 分别定义链生态内交易请求，CAIP-19 解决资产标识但不定义完整支付意图。N42 因此保留生态 URI，并仅在生态格式缺少 network 或 token identity 时使用带版本的 fallback。

## 整改优先级及验收标准

### P0 — 钱包支付 QR：链、网络、资产精确解析

实现 EIP-681 与版本化 N42 fallback：

```text
n42pay://v1/pay?chain=<chain-mKey>&network=<mainnet|testnet>&type=<native|token>&to=<recipient>[&contract=<token-contract>][&amount=<decimal>]
```

`chain`、`network`、`type`、`to` 必填；token 必须有链/网络特定 contract 或 mint；native 禁止带 token 合约；金额为正的十进制用户单位，不使用科学计数法/千位分隔。EVM 优先用 EIP-681；Bitcoin/Solana 等已支持标准且上下文足以唯一解析时保留标准 URI；缺少网络或 token 身份时使用 N42 fallback。其它既有链 scheme 仅在可稳定映射到链、网络和资产时继续解析。

验收：

- 所有 N42 收款页生成的资产码都携带足够身份信息；无金额时发送页金额为空且可编辑。
- EVM 原生、ERC-20；Solana SOL、SPL mint；支持的 BTC/其他主链均解析到与收款页相同的 chain/network/asset。
- 对未知链、未知合约、错误网络、无效地址/金额、重复关键参数、未知 EIP-681 函数或缺少 token identity 的请求 fail closed，不回退到另一资产。
- 裸地址依旧进入资产选择器；WalletConnect 继续走配对流程。
- 单元测试覆盖编码、解析、候选资产精确匹配和 malformed inputs；相关既有钱包扫码测试通过。

### P1 — Chat QR：Matrix、WhatsApp 与联系人格式

新增标准 Matrix user/room permalink 解析和生成，兼容旧 N42 私有用户码；支持安全确认后的 WhatsApp `wa.me` 外部跳转；收款请求 v1 要求 chain/network/type/contract-or-mint 等资产身份，旧 `n42pay://pay` 与 `n42://pay` 只作明确标记的兼容格式，不能声称能精确选择资产；商户扫码如无法确认资产应提示用户选择或拒绝自动付款。群/空间扫描只展示预览，用户确认后才调用现有 join service。拒绝非白名单域名/伪造 Matrix 与 WhatsApp URL。

验收：

- 新个人二维码是可分享的 Matrix permalink，N42 仍识别旧码；Matrix user 与 room/space permalink 在同一扫码入口按正确目标分流。
- 房间加入和 WhatsApp 外跳都必须先获得明确确认；取消确认不产生网络加入/外跳副作用。
- `wa.me` 仅接收规范化国际号码；恶意域名、非 HTTPS、额外凭据/端口和畸形 fragment 不被 launcher 执行。
- 商户请求的 token 以链+网络+合约/mint 识别，不以 symbol 猜测；遗留旧请求只按兼容路径展示风险/要求显式选择。
- Chat 扫码、支付 URI、社交解析器和二维码页面相关测试通过。

### P2 — 统一钱包相机扫描实现

将钱包 `ScanPage` 从 `qr_code_scanner_plus` 切换到仓库已使用的 `mobile_scanner`。统一相机授权、前后台暂停/恢复、dispose、补光灯、单次扫码返回和 iOS/Android 权限状态；仍由页面返回原始字符串，支付路由保持独立。

验收：

- permission denied/restricted 可显示已有权限提示，已授权时摄像头正常启动；从后台/热重载返回后不重复创建或使用已销毁 controller。
- 补光灯状态正确；一次扫码只 pop 一次并停止相机；Widget dispose 后没有相机回调/资源泄漏。
- 移除 `qr_code_scanner_plus` 直接依赖及锁文件条目；保留扫码页面返回原始 QR 的接口与钱包路由回归。
- 相关测试、`flutter analyze --no-fatal-infos` 通过；iOS/Android 至少做一次设备或模拟器验证，测试环境无相机时单独记录为未验证项。

## 建议执行顺序

1. P0 纯协议模型、严格 parser/encoder、resolver 单测；先把失败/歧义请求 fail closed。
2. P0 接入钱包收款二维码与首页扫码分流，逐类资产验证端到端路由。
3. P1 Chat parser、生成器、确认 UX、旧版兼容和安全测试。
4. P2 相机切换、权限/生命周期/flash 验证和删除旧依赖。
5. 全量相关测试、静态分析、手动设备检查；将 `packages/n42_chat` 改动同步至正式 Git 依赖源后才能纳入正式发布。

## 主要代码入口

- 钱包生成：`lib/features/wallet/pages/wallet_receive_qr.dart`
- EIP-681：`lib/features/wallet/utils/eip681.dart`
- 钱包资产解析/路由：`lib/features/wallet/pages/send/scan_to_pay_utils.dart`、`lib/features/wallet/pages/wallet_page.dart`
- 钱包相机：`lib/features/component/pages/scan_page.dart`
- Chat 支付 URI：`packages/n42_chat/lib/src/core/utils/payment_request_uri.dart`
- Chat 社交解析及扫码：`packages/n42_chat/lib/src/core/utils/social_scan_payload_parser.dart`、`packages/n42_chat/lib/src/presentation/pages/qrcode/scan_qr_page.dart`
- Matrix permalink 及个人码：`packages/n42_chat/lib/src/core/utils/room_metadata_utils.dart`、`packages/n42_chat/lib/src/presentation/pages/qrcode/my_qrcode_page.dart`
- UR/硬件钱包：`lib/features/hardware_wallet/service/keystone_service.dart`、`lib/features/hardware_wallet/crypto/ur_codec.dart`
- 身份扫码：`lib/features/identity/services/id_hub_scan.dart`

## 资料来源

- Ethereum Improvement Proposals: [EIP-681](https://eips.ethereum.org/EIPS/eip-681), [EIP-1328](https://eips.ethereum.org/EIPS/eip-1328)
- Bitcoin Improvement Proposals: [BIP-321](https://github.com/bitcoin/bips/blob/master/bip-0321.mediawiki)
- Solana: [Solana Pay v1](https://solana.com/docs/tools/solana-pay/specification/version1)
- Chain Agnostic Improvement Proposals: [CAIP-2](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-2.md), [CAIP-19](https://standards.chainagnostic.org/CAIPs/caip-19)
- Blockchain Commons: [UR specification paper](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md)
- Matrix: [Specification appendices](https://spec.matrix.org/v1.8/appendices/)
- WhatsApp Help Center: [Click to Chat](https://faq.whatsapp.com/5913398998672934)
- Google Authenticator: [Key URI Format](https://github.com/google/google-authenticator/wiki/Key%20Uri%20Format)

## 执行结果（2026-09-24）

| 优先级 | 结果 | 验收证据 / 限制 |
| --- | --- | --- |
| P0 钱包支付 QR | 已完成 | 版本化 `n42pay://v1`、EIP-681 严格解析、链/网络/原生币或合约身份精确匹配；歧义/畸形/未知函数和超精度金额拒绝。ERC-20 EIP-681 只匹配 EVM 资产。覆盖生成/解析/解析资产与测试网隔离的测试通过。 |
| P1 Chat / 社交 QR | 本仓库实现已完成 | Matrix permalink、旧 N42 用户码兼容、WhatsApp `wa.me` 白名单与确认、群聊加入确认、支付二维码精确资产匹配和确认页身份展示均已实现并有测试。exact transfer 保留原始十进制金额到 sender；EVM/Solana 另传精确最小单位整数，测试验证完整 `SendParams` 到达 sender。测试网缺少 `contractTest` 的代币从 exact 资产列表移除并拒绝派发。`packages/n42_chat` 是本地镜像；`pubspec.yaml` 引用的正式 Git 依赖尚未同步，因此发布前必须 forward-port 到该固定版本的源仓库。微信等封闭平台私有动态码不宣称互通，提示使用官方应用。 |
| P2 钱包相机 | Android 验收通过 | 钱包 `ScanPage` 迁移到 `mobile_scanner`，移除 `qr_code_scanner_plus`；权限、单次返回和 dispose 有 Widget 测试。Pixel 8 / Android API 36 模拟器完成启动、重复暂停/恢复和销毁的相机集成测试。iOS 设备/模拟器未验证。 |

### 验收命令

- 最终钱包、Chat、扫码、协议和 sender 定向套件（含 sender 测试目录）：**216 项通过**。
- 钱包扫码分类器将 WalletConnect 与地址/支付 URI 分开，未知 scheme（如 `litecoin:`）拒绝进入地址选择；相应路由解析回归测试通过。
- Android 模拟器：`GRADLE_OPTS=-Dorg.gradle.java.home=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home scripts/test_device.sh emulator-5554 integration_test/wallet_scanner_camera_device_test.dart` → **1 项通过**。仅为本地构建，使用忽略的 `android/app/google-services.json`，该文件未跟踪、未提交。
- 改动 Dart 文件定向分析：`flutter analyze --no-fatal-infos` 对全部 57 个改动 Dart 文件 → **No issues found**。
- 全仓 `flutter analyze --no-fatal-infos` → **302 issues / 24 errors**。错误均来自未改动基线：`firebase_push_service.dart` 的 `AuthorizationStatus.deniedPermanently` 分支，以及 `packages/n42_jmt_verify` 缺少 `blake3_dart` 依赖/公开库造成的连锁错误。全仓分析因此仍未通过。
- `git diff --check` → 通过。

Android 构建还要求 JDK 21 的临时 `GRADLE_OPTS` 覆盖；仓库默认 JDK 路径在本机不存在。为避免公开 AndroidX 依赖误入 TrustWallet 私有 Maven 仓库，`android/build.gradle.kts` 已将该仓库限制为 `com.trustwallet` group。
