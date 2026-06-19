/// MPC 钱包 provider 抽象接口
///
/// 所有 MPC 服务商（Web3Auth、Particle、Lit Protocol 等）都需实现此接口。
/// 业务层通过此接口与 MPC 服务交互，不直接依赖具体 SDK。
library;

import 'dart:typed_data';

/// MPC 登录方式
enum MpcLoginType { google, apple, email, phone, twitter, discord, github }

/// MPC 登录结果
class MpcLoginResult {
  /// 用户的 EVM 地址（由 MPC 密钥分片派生）
  final String address;

  /// 用户公钥（hex，不含 0x 前缀）
  final String publicKey;

  /// MPC 服务商返回的用户标识
  final String userId;

  /// 登录方式描述（如 'Google: user@gmail.com'）
  final String loginHint;

  /// 服务商标识
  final String provider;

  const MpcLoginResult({
    required this.address,
    required this.publicKey,
    required this.userId,
    required this.loginHint,
    required this.provider,
  });
}

/// MPC 签名结果
class MpcSignResult {
  /// 签名数据（65 bytes: r(32) + s(32) + v(1)）
  final Uint8List signature;

  /// 签名的十六进制表示（含 0x 前缀）
  final String signatureHex;

  const MpcSignResult({required this.signature, required this.signatureHex});
}

/// MPC Provider 抽象接口
abstract class MpcProvider {
  /// 服务商标识（如 'web3auth'、'particle'）
  String get providerId;

  /// 是否已初始化
  bool get isInitialized;

  /// 是否已登录
  bool get isLoggedIn;

  /// 当前用户地址（登录后可用）
  String? get currentAddress;

  /// 初始化 SDK（应用启动时调用一次）
  Future<void> initialize();

  /// 社交登录 → 生成/恢复 MPC 密钥分片
  Future<MpcLoginResult> login(MpcLoginType type, {String? hint});

  /// 登出并清理本地密钥分片
  Future<void> logout();

  /// 对消息哈希签名（EVM personal_sign）
  Future<MpcSignResult> signMessage(Uint8List messageHash);

  /// 对 EVM 交易签名
  ///
  /// [serializedTx] 为 RLP 编码的未签名交易（不含签名字段）
  Future<MpcSignResult> signTransaction(Uint8List serializedTx);

  /// 获取恢复因子描述列表
  Future<List<String>> getRecoveryFactors();

  /// 释放资源
  void dispose();
}

/// MPC Provider 注册表
///
/// 管理所有已注册的 MPC Provider 实例。
class MpcProviderRegistry {
  MpcProviderRegistry._();
  static final MpcProviderRegistry instance = MpcProviderRegistry._();

  final Map<String, MpcProvider> _providers = {};

  /// 注册 provider
  void register(MpcProvider provider) {
    _providers[provider.providerId] = provider;
  }

  /// 获取 provider
  MpcProvider? get(String providerId) => _providers[providerId];

  /// 获取默认 provider（第一个已注册的）
  MpcProvider? get defaultProvider =>
      _providers.isNotEmpty ? _providers.values.first : null;

  /// 所有已注册的 provider ID
  List<String> get availableProviders => _providers.keys.toList();

  /// 释放所有 provider
  void disposeAll() {
    for (final p in _providers.values) {
      p.dispose();
    }
    _providers.clear();
  }
}
