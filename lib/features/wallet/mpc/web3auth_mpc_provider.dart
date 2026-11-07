import 'dart:typed_data';

import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/web3dart.dart' show EthPrivateKey, bytesToHex;

import 'mpc_provider.dart';

/// Web3Auth MPC Provider 实现
///
/// 使用 Web3Auth 的 MPC-TSS 协议实现无助记词钱包：
/// - 社交登录（Google/Apple/Email）→ 密钥分片生成
/// - 2/3 阈值签名（设备分片 + 服务端分片 + 恢复分片）
/// - 用户无需保管助记词或私钥
class Web3AuthMpcProvider implements MpcProvider {
  Web3AuthResponse? _state;
  String? _privateKey;
  EthPrivateKey? _cachedCredentials;
  bool _initialized = false;
  bool _loginPending = false;
  bool _disposed = false;
  int _generation = 0;
  Future<void>? _initializing;
  Future<void>? _loggingOut;

  /// Web3Auth Client ID（从 dashboard.web3auth.io 获取）
  final String clientId;

  /// 重定向 URI（Android/iOS deep link）
  final Uri redirectUrl;

  /// 网络环境
  final Web3AuthNetwork network;

  Web3AuthMpcProvider({
    required this.clientId,
    required this.redirectUrl,
    this.network = Web3AuthNetwork.sapphire_mainnet,
  });

  @override
  String get providerId => 'web3auth';

  @override
  bool get isInitialized => _initialized;

  @override
  bool get isLoggedIn => _privateKey != null;

  @override
  String? get currentAddress {
    if (_privateKey == null) return null;
    return _deriveAddress(_privateKey!);
  }

  @override
  Future<void> initialize() {
    if (_disposed || _loggingOut != null) {
      throw StateError('Provider unavailable');
    }
    if (_initialized) return Future.value();
    return _initializing ??= _initialize().whenComplete(
      () => _initializing = null,
    );
  }

  Future<void> _initialize() async {
    final generation = _generation;

    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId: clientId,
        web3AuthNetwork: network,
        redirectUrl: redirectUrl.toString(),
        authBuildEnv: BuildEnv.production,
        mfaSettings: MfaSettings(
          deviceShareFactor: MfaSetting(enable: true, priority: 1),
          backUpShareFactor: MfaSetting(enable: true, priority: 2),
          socialBackupFactor: MfaSetting(enable: true, priority: 3),
        ),
      ),
    );

    // Check for existing session
    try {
      await Web3AuthFlutter.initialize();
      final key = await Web3AuthFlutter.getPrivateKey();
      if (generation != _generation || _disposed) return;
      if (key.isNotEmpty) _acceptKey(key);
    } catch (_) {
      if (generation == _generation) _clearSession();
    }

    if (generation != _generation || _disposed) return;
    _initialized = true;
    AppLogger.d('Web3AuthMpc', 'initialized, logged_in=$isLoggedIn');
  }

  @override
  Future<MpcLoginResult> login(MpcLoginType type, {String? hint}) async {
    if (_disposed || _loginPending || _loggingOut != null) {
      throw MpcLoginException('Login unavailable or already in progress');
    }
    _loginPending = true;
    final generation = _generation;
    try {
      if (!_initialized) await initialize();
      _assertCurrent(generation);
      // A cancelled/rejected account switch must not leave the old signer active.
      _clearSession();
      final response = await Web3AuthFlutter.connectTo(
        LoginParams(
          authConnection: _mapLoginType(type),
          extraLoginOptions: hint != null
              ? ExtraLoginOptions(login_hint: hint)
              : null,
          mfaLevel: MFALevel.DEFAULT,
        ),
      );
      _assertCurrent(generation);
      _acceptKey(response.privateKey ?? '');
      _state = response;
      final userInfo = response.userInfo;
      return MpcLoginResult(
        address: _deriveAddress(_privateKey!),
        publicKey: _derivePublicKey(_privateKey!),
        userId: userInfo?.userId ?? '',
        loginHint: _buildLoginHint(type, userInfo),
        provider: providerId,
      );
    } catch (_) {
      if (generation == _generation) _clearSession();
      rethrow;
    } finally {
      _loginPending = false;
    }
  }

  void _assertCurrent(int generation) {
    if (_disposed || generation != _generation) {
      throw MpcLoginException('Login expired');
    }
  }

  void _clearSession() {
    _privateKey = null;
    _cachedCredentials = null;
    _state = null;
  }

  void _acceptKey(String key) {
    final hex = key.startsWith('0x') ? key.substring(2) : key;
    final number = BigInt.tryParse(hex, radix: 16);
    final order = BigInt.parse(
      'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
      radix: 16,
    );
    if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hex) ||
        number == null ||
        number <= BigInt.zero ||
        number >= order) {
      throw MpcLoginException('Login returned an invalid signing key');
    }
    _clearSession();
    _privateKey = hex;
  }

  @override
  Future<void> logout() =>
      _loggingOut ??= _logout().whenComplete(() => _loggingOut = null);

  Future<void> _logout() async {
    ++_generation;
    _clearSession();
    try {
      await Web3AuthFlutter.logout();
    } catch (_) {}
    _privateKey = null;
    _cachedCredentials = null;
    _state = null;
  }

  @override
  Future<MpcSignResult> signMessage(Uint8List messageHash) async {
    _ensureLoggedIn();
    final creds = _getCredentials(_privateKey!);
    final sig = creds.signPersonalMessageToUint8List(messageHash);
    return MpcSignResult(signature: sig, signatureHex: '0x${bytesToHex(sig)}');
  }

  @override
  Future<MpcSignResult> signTransaction(Uint8List serializedTx) async {
    _ensureLoggedIn();
    // The interface accepts the unsigned transaction preimage, not a digest.
    // Hash it once without the EIP-191 personal-message prefix. The caller
    // remains responsible for encoding the signature into its transaction.
    final creds = _getCredentials(_privateKey!);
    final sig = creds.signToUint8List(serializedTx);
    return MpcSignResult(signature: sig, signatureHex: '0x${bytesToHex(sig)}');
  }

  @override
  Future<List<String>> getRecoveryFactors() async {
    final factors = <String>[];
    if (_state?.userInfo != null) {
      final info = _state!.userInfo!;
      if (info.email?.isNotEmpty == true) {
        factors.add('Email: ${info.email}');
      }
      if (info.name?.isNotEmpty == true) {
        factors.add('${info.authConnection ?? "Social"}: ${info.name}');
      }
    }
    factors.add('Device share (this device)');
    return factors;
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _clearSession();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  void _ensureLoggedIn() {
    if (_privateKey == null) {
      throw MpcNotLoggedInException();
    }
  }

  AuthConnection _mapLoginType(MpcLoginType type) => switch (type) {
    MpcLoginType.google => AuthConnection.google,
    MpcLoginType.apple => AuthConnection.apple,
    MpcLoginType.facebook => AuthConnection.facebook,
    MpcLoginType.email => AuthConnection.email_passwordless,
    MpcLoginType.phone => AuthConnection.sms_passwordless,
    MpcLoginType.twitter => AuthConnection.twitter,
    MpcLoginType.discord => AuthConnection.discord,
    MpcLoginType.github => AuthConnection.github,
  };

  String _buildLoginHint(MpcLoginType type, UserInfo? userInfo) {
    final label = type.name[0].toUpperCase() + type.name.substring(1);
    final detail = userInfo?.email ?? userInfo?.name ?? userInfo?.userId ?? '';
    return detail.isNotEmpty ? '$label: $detail' : label;
  }

  /// Get cached EthPrivateKey from hex string
  EthPrivateKey _getCredentials(String privateKeyHex) {
    if (_cachedCredentials != null) return _cachedCredentials!;
    final clean = privateKeyHex.startsWith('0x')
        ? privateKeyHex
        : '0x$privateKeyHex';
    _cachedCredentials = EthPrivateKey.fromHex(clean);
    return _cachedCredentials!;
  }

  /// Derive EVM address from secp256k1 private key
  String _deriveAddress(String privateKeyHex) {
    return _getCredentials(privateKeyHex).address.toString();
  }

  String _derivePublicKey(String privateKeyHex) {
    final creds = _getCredentials(privateKeyHex);
    return bytesToHex(creds.encodedPublicKey);
  }
}

/// MPC 登录异常
class MpcLoginException implements Exception {
  final String message;
  MpcLoginException(this.message);
  @override
  String toString() => 'MpcLoginException: $message';
}

/// MPC 未登录异常
class MpcNotLoggedInException implements Exception {
  @override
  String toString() => 'MpcNotLoggedInException: MPC wallet is not logged in';
}
