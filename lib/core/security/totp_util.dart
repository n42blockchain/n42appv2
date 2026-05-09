import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// RFC 6238 TOTP 工具类（纯客户端，无需网络）
class TotpUtil {
  static const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const _period = 30; // 时间步长（秒）
  static const _digits = 6;

  /// 生成随机 Base32 secret（160 bits = 32 chars）
  static String generateSecret() {
    final rng = Random.secure();
    return List.generate(32, (_) => _base32Alphabet[rng.nextInt(32)]).join();
  }

  /// 计算当前 TOTP 验证码
  static String generate(String secret) {
    final t = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _period;
    return _hotp(_base32Decode(secret), t);
  }

  /// 验证用户输入的 code（允许前后一个时间窗口的偏差）
  static bool verify(String secret, String code) {
    if (code.length != _digits) return false;
    final t = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _period;
    final key = _base32Decode(secret);
    return _hotp(key, t - 1) == code ||
        _hotp(key, t) == code ||
        _hotp(key, t + 1) == code;
  }

  /// 构造 otpauth URI，供 QR 码使用
  static String buildOtpAuthUri({
    required String secret,
    required String account,
    String issuer = 'N42 Wallet',
  }) {
    final encoded = Uri.encodeComponent(account);
    return 'otpauth://totp/$issuer:$encoded'
        '?secret=$secret&issuer=${Uri.encodeComponent(issuer)}&algorithm=SHA1&digits=6&period=30';
  }

  // ── 内部实现 ─────────────────────────────────────────────────────────────

  static String _hotp(Uint8List key, int counter) {
    // 8 字节大端序计数器
    final msg = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      msg[i] = c & 0xff;
      c >>= 8;
    }
    final hmac = Hmac(sha1, key).convert(msg).bytes;
    final offset = hmac[19] & 0xf;
    final code = ((hmac[offset] & 0x7f) << 24) |
        (hmac[offset + 1] << 16) |
        (hmac[offset + 2] << 8) |
        hmac[offset + 3];
    return (code % 1000000).toString().padLeft(6, '0');
  }

  static Uint8List _base32Decode(String input) {
    final s = input.toUpperCase().replaceAll('=', '');
    var bits = 0;
    var value = 0;
    final output = <int>[];
    for (final char in s.runes) {
      final idx = _base32Alphabet.codeUnits.indexOf(char);
      if (idx < 0) continue;
      value = (value << 5) | idx;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        output.add((value >> bits) & 0xff);
      }
    }
    return Uint8List.fromList(output);
  }
}
