import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 钱包登录凭据派生（纯逻辑，便于单测）
///
/// 用「钱包对固定消息的签名」确定性地派生 Matrix 用户名+密码，复用既有的
/// Matrix 用户名/密码登录注册流程，无需新增服务端 SIWE 端点。
///
/// ## 安全前提（务必知悉）
/// - 钱包对 [canonicalLoginMessage] 的签名必须**确定性**（同地址同消息→同签名，
///   ECDSA RFC6979 / personal_sign 满足）。否则派生密码会变化导致账号锁死。
/// - 生产环境更稳的是服务端 SIWE（验签发 Matrix token）；本方案为纯客户端过渡。
class WalletLoginCredentials {
  final String username;
  final String password;

  const WalletLoginCredentials._of(this.username, this.password);

  /// 派生消息版本（变更会使所有派生账号失效，谨慎升级）
  static const String version = 'v1';

  /// 待签名的固定消息（含地址与版本，规范化小写地址）
  static String canonicalLoginMessage(String address) {
    final addr = _normalizeAddress(address);
    return 'N42 Chat wallet login\nversion: $version\naddress: $addr';
  }

  /// Matrix 用户名：`n42w_` + sha256(小写地址) 前 16 个 hex（合法 localpart，稳定）
  static String deriveUsername(String address) {
    final addr = _normalizeAddress(address);
    final digest = sha256.convert(utf8.encode('$version:$addr'));
    return 'n42w_${digest.toString().substring(0, 16)}';
  }

  /// Matrix 密码：sha256(签名) 的 base64url（去填充），强度足够且确定。
  static String derivePassword(String signature) {
    final sig = _normalizeSignature(signature);
    final digest = sha256.convert(utf8.encode('$version:$sig'));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// 由地址 + 签名派生完整凭据。
  static WalletLoginCredentials derive({
    required String address,
    required String signature,
  }) {
    return WalletLoginCredentials._of(
      deriveUsername(address),
      derivePassword(signature),
    );
  }

  static String _normalizeAddress(String address) {
    final addr = address.trim().toLowerCase();
    if (addr.isEmpty) {
      throw ArgumentError.value(address, 'address', 'must not be empty');
    }
    return addr;
  }

  static String _normalizeSignature(String signature) {
    final sig = signature.trim();
    if (sig.isEmpty) {
      throw ArgumentError.value(signature, 'signature', 'must not be empty');
    }
    return sig;
  }
}
