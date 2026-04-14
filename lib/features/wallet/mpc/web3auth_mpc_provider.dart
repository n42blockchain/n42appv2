import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
  bool _initialized = false;

  /// Web3Auth Client ID（从 dashboard.web3auth.io 获取）
  final String clientId;

  /// 重定向 URI（Android/iOS deep link）
  final Uri redirectUrl;

  /// 网络环境
  final Network network;

  Web3AuthMpcProvider({
    required this.clientId,
    required this.redirectUrl,
    this.network = Network.sapphire_mainnet,
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
  Future<void> initialize() async {
    if (_initialized) return;

    await Web3AuthFlutter.init(
      Web3AuthOptions(
        clientId: clientId,
        network: network,
        redirectUrl: redirectUrl,
        buildEnv: BuildEnv.production,
        mfaSettings: MfaSettings(
          deviceShareFactor: MfaSetting(enable: true, priority: 1),
          backUpShareFactor: MfaSetting(enable: true, priority: 2),
          socialBackupFactor: MfaSetting(enable: true, priority: 3),
        ),
      ),
    );

    // Check for existing session
    try {
      _privateKey = await Web3AuthFlutter.getPrivKey();
      if (_privateKey != null && _privateKey!.isEmpty) {
        _privateKey = null;
      }
    } catch (_) {
      _privateKey = null;
    }

    _initialized = true;
    debugPrint('Web3AuthMpcProvider: initialized, logged_in=$isLoggedIn');
  }

  @override
  Future<MpcLoginResult> login(MpcLoginType type, {String? hint}) async {
    if (!_initialized) await initialize();

    final loginProvider = _mapLoginType(type);

    final response = await Web3AuthFlutter.login(
      LoginParams(
        loginProvider: loginProvider,
        extraLoginOptions: hint != null
            ? ExtraLoginOptions(login_hint: hint)
            : null,
        mfaLevel: MFALevel.DEFAULT,
      ),
    );

    _state = response;
    _privateKey = response.privKey;

    if (_privateKey == null || _privateKey!.isEmpty) {
      throw MpcLoginException('Login succeeded but no key was returned');
    }

    final address = _deriveAddress(_privateKey!);
    final userInfo = response.userInfo;

    return MpcLoginResult(
      address: address,
      publicKey: _derivePublicKey(_privateKey!),
      userId: userInfo?.verifierId ?? '',
      loginHint: _buildLoginHint(type, userInfo),
      provider: providerId,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await Web3AuthFlutter.logout();
    } catch (_) {}
    _privateKey = null;
    _state = null;
  }

  @override
  Future<MpcSignResult> signMessage(Uint8List messageHash) async {
    _ensureLoggedIn();
    final creds = _getCredentials(_privateKey!);
    final sig = creds.signPersonalMessageToUint8List(messageHash);
    return MpcSignResult(
      signature: sig,
      signatureHex: '0x${bytesToHex(sig)}',
    );
  }

  @override
  Future<MpcSignResult> signTransaction(Uint8List serializedTx) async {
    _ensureLoggedIn();
    // For raw transaction signing, the caller should provide the pre-hashed
    // transaction. We sign the hash with secp256k1.
    final creds = _getCredentials(_privateKey!);
    final sig = creds.signPersonalMessageToUint8List(serializedTx);
    return MpcSignResult(
      signature: sig,
      signatureHex: '0x${bytesToHex(sig)}',
    );
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
        factors.add('${info.typeOfLogin ?? "Social"}: ${info.name}');
      }
    }
    factors.add('Device share (this device)');
    return factors;
  }

  @override
  void dispose() {
    _privateKey = null;
    _state = null;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  void _ensureLoggedIn() {
    if (_privateKey == null) {
      throw MpcNotLoggedInException();
    }
  }

  Provider _mapLoginType(MpcLoginType type) => switch (type) {
    MpcLoginType.google => Provider.google,
    MpcLoginType.apple => Provider.apple,
    MpcLoginType.email => Provider.email_passwordless,
    MpcLoginType.phone => Provider.sms_passwordless,
    MpcLoginType.twitter => Provider.twitter,
    MpcLoginType.discord => Provider.discord,
    MpcLoginType.github => Provider.github,
  };

  String _buildLoginHint(MpcLoginType type, TorusUserInfo? userInfo) {
    final label = type.name[0].toUpperCase() + type.name.substring(1);
    final detail = userInfo?.email ?? userInfo?.name ?? userInfo?.verifierId ?? '';
    return detail.isNotEmpty ? '$label: $detail' : label;
  }

  /// Get EthPrivateKey from hex string
  EthPrivateKey _getCredentials(String privateKeyHex) {
    final clean = privateKeyHex.startsWith('0x')
        ? privateKeyHex
        : '0x$privateKeyHex';
    return EthPrivateKey.fromHex(clean);
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
