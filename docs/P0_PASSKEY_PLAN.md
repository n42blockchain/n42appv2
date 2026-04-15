# P0: Passkey 支持实现计划

> **状态**: ✅ 阶段 1-3 已完成 | 阶段 4-5 待后续迭代
> **完成日期**: 2026-04-14

## 实现状态

### 阶段 1：Passkey 基础平台层 ✅
- `lib/core/passkey/passkey_config.dart` — WebAuthn 配置 + RIP-7212 P256 预编译链映射
- `lib/core/passkey/passkey_credential.dart` — 凭证模型 + AuthResult + PasskeyPlatform 枚举
- `lib/core/passkey/passkey_platform_adapter.dart` — MethodChannel 跨平台适配层 + PasskeyException 体系
- `android/app/src/main/kotlin/ai/n42/www/PasskeyHandler.kt` — Android Credential Manager API 桥接（DER 签名解析 + low-S 规范化）
- `ios/Runner/PasskeyHandler.swift` — iOS ASAuthorizationController 桥接（CBOR attestation 解析 + P-256 公钥提取）

### 阶段 2：应用登录/解锁集成 ✅
- `lib/core/passkey/passkey_service.dart` — 注册/认证/AA签名/凭证管理完整服务（通过 GetIt DI 注册）
- `lib/shared/domain/services/auth_service_interface.dart` — +3 Passkey 方法到 IAuthService 接口
- `lib/features/auth/data/services/auth_service_impl.dart` — Passkey 验证实现（懒初始化单例模式）
- `lib/features/login/widgets/passkey_login_button.dart` — 登录页 Passkey 按钮组件
- `lib/core/security/secure_storage.dart` — +Passkey 凭证安全存储方法
- `lib/core/di/injection.dart` — PasskeyService 注册到 GetIt
- `lib/l10n/intl_en.arb` + `intl_zh_TW.arb` — +14 个 Passkey 国际化字符串

### 阶段 3：AA 钱包 Passkey 签名 ✅
- `lib/features/wallet/aa/builder/passkey_signature_builder.dart` — P-256 签名 ABI 编码器（链上验证格式）
- `lib/features/wallet/aa/provider/passkey_signer_provider.dart` — Riverpod Provider：UserOp Passkey 签名流程
- `lib/features/wallet/aa/models/smart_account.dart` — +SignerType 枚举(eoa/passkey/mpc) + Passkey 字段
- `lib/features/wallet/aa/builder/signature_builder.dart` — +Passkey 签名代理方法

### 阶段 4：UI 完善 🔲 待实现
- Passkey 创建引导流程（onboarding）
- 签名确认弹窗 Passkey 选项
- 设置页 Passkey 管理（重命名/多设备管理）
- 错误处理降级策略

### 阶段 5：Web 平台适配 🔲 待实现
- Web 端 navigator.credentials API 适配
- Conditional UI 自动提示

## Simplify 审查修复（2026-04-15）
- 删除 `passkey_credential.dart` 中重复的 `SignerType` 枚举，统一使用 `smart_account.dart` 中的定义
- PasskeyService 改为通过 GetIt DI 注入（注册于 `injection.dart`），不再在各调用点手动构造
- `auth_service_impl` 中改为懒初始化单例 `_passkey` getter，避免每次调用创建新实例
- 删除 `passkey_signature_builder.parseSignature()` 死代码

## 技术选型
- Flutter: 自建 MethodChannel `n42.wallet/passkey`
- Android: Credential Manager API (Android 9+)
- iOS: ASAuthorizationController (iOS 16+)
- 链上: RIP-7212 P256 预编译（Base/OP/Arbitrum 等）+ Solidity fallback verifier
- 曲线: secp256r1/P-256 (WebAuthn ES256)

## 关键文件
```
lib/core/passkey/
├── passkey_config.dart          # WebAuthn 配置
├── passkey_credential.dart      # 凭证模型
├── passkey_platform_adapter.dart # 平台适配层
└── passkey_service.dart         # 核心服务

lib/features/wallet/aa/
├── builder/passkey_signature_builder.dart  # P-256 ABI 编码
├── provider/passkey_signer_provider.dart   # Riverpod 签名 Provider
└── models/smart_account.dart              # +SignerType 枚举

android/.../PasskeyHandler.kt    # Android 原生
ios/Runner/PasskeyHandler.swift  # iOS 原生
```
