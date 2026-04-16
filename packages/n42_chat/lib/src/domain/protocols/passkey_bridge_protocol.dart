import 'dart:typed_data';

/// Passkey / WebAuthn 桥接协议。
///
/// 由宿主应用（本仓库主项目 N42 Wallet 已有 `lib/core/passkey/passkey_service.dart`）
/// 实现并注入。chat 包自身不直接依赖任何 Passkey SDK，以保持独立运行能力。
///
/// 注入方式：`N42Chat.configure(passkeyBridge: MyPasskeyBridgeImpl())`。
abstract class PasskeyBridge {
  /// 当前设备 / 系统是否支持 Passkey。
  Future<bool> isAvailable();

  /// 注册一个新 Passkey。
  ///
  /// 返回的 [PasskeyRegistrationResult] 包含凭据 ID 与公钥，需要交给
  /// 服务端（Matrix Homeserver）绑定。
  Future<PasskeyRegistrationResult> register({
    required String userId,
    required String userName,
    required Uint8List challenge,
    required String rpId,
    String? label,
  });

  /// 用 Passkey 进行断言认证。
  Future<PasskeyAssertionResult> authenticate({
    required Uint8List challenge,
    required String rpId,
    List<String>? allowCredentialIds,
  });

  /// 列出本设备已注册的 Passkey 摘要。
  Future<List<PasskeyCredentialSummary>> list();

  /// 移除本设备绑定的某个 Passkey。
  Future<void> remove(String credentialId);
}

class PasskeyRegistrationResult {
  const PasskeyRegistrationResult({
    required this.credentialId,
    required this.publicKey,
    required this.attestation,
  });
  final String credentialId;
  final Uint8List publicKey;
  final Uint8List attestation;
}

class PasskeyAssertionResult {
  const PasskeyAssertionResult({
    required this.credentialId,
    required this.signature,
    required this.authenticatorData,
    required this.clientDataJson,
    this.userHandle,
  });
  final String credentialId;
  final Uint8List signature;
  final Uint8List authenticatorData;
  final Uint8List clientDataJson;
  final String? userHandle;
}

class PasskeyCredentialSummary {
  const PasskeyCredentialSummary({
    required this.credentialId,
    required this.label,
    required this.createdAt,
  });
  final String credentialId;
  final String label;
  final DateTime createdAt;
}
