import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// App 级 TOTP 二步验证密钥存储（FlutterSecureStorage，Keychain/Keystore）。
///
/// 仅存「是否启用」与 Base32 密钥；验证码由 [Totp] 现算，不落盘。
class Totp2faStore {
  static const String _secretKey = 'n42.chat.totp_2fa_secret';

  final FlutterSecureStorage _storage;

  Totp2faStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// 是否已启用（存在密钥即启用）
  Future<bool> isEnabled() async {
    final s = await _storage.read(key: _secretKey);
    return s != null && s.isNotEmpty;
  }

  /// 读取 Base32 密钥（未启用返回 null）
  Future<String?> getSecret() async => _storage.read(key: _secretKey);

  /// 启用：写入密钥
  Future<void> enable(String base32Secret) =>
      _storage.write(key: _secretKey, value: base32Secret);

  /// 关闭：删除密钥
  Future<void> disable() => _storage.delete(key: _secretKey);
}
