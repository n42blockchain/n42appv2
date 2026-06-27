import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// 基于时间的一次性密码（TOTP, RFC 6238）+ Base32（RFC 4648）。
///
/// 纯逻辑，便于单测（可对 RFC 6238 测试向量校验）。用于 App 级 2FA：
/// 密钥以 Base32 提供给认证器 App（Google Authenticator / Authy 等），
/// 本端按相同算法生成/校验验证码。
class Totp {
  Totp._();

  static const int _defaultDigits = 6;
  static const int _defaultPeriod = 30;
  static const String _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// 生成给定时间点的验证码（[unixSeconds] 不传则需调用方传入，纯函数不取系统时钟）。
  static String generate(
    String base32Secret, {
    required int unixSeconds,
    int digits = _defaultDigits,
    int period = _defaultPeriod,
  }) {
    final counter = unixSeconds ~/ period;
    return _hotp(base32Decode(base32Secret), counter, digits);
  }

  /// 校验验证码，允许前后 [window] 个时间窗（默认 ±1，容忍时钟漂移）。
  static bool verify(
    String base32Secret,
    String code, {
    required int unixSeconds,
    int digits = _defaultDigits,
    int period = _defaultPeriod,
    int window = 1,
  }) {
    final cleaned = code.trim().replaceAll(' ', '');
    if (cleaned.length != digits) return false;
    final key = base32Decode(base32Secret);
    final base = unixSeconds ~/ period;
    for (var i = -window; i <= window; i++) {
      if (_constantTimeEquals(_hotp(key, base + i, digits), cleaned)) {
        return true;
      }
    }
    return false;
  }

  /// 生成随机 Base32 密钥（默认 20 字节 = 160 bit，认证器标准）。
  static String randomSecret({int bytes = 20, Random? random}) {
    final rng = random ?? Random.secure();
    final raw = Uint8List.fromList(
      List<int>.generate(bytes, (_) => rng.nextInt(256)),
    );
    return base32Encode(raw);
  }

  /// `otpauth://totp/...` 配置 URI（可生成二维码给认证器扫描）。
  static String provisioningUri({
    required String secret,
    required String accountName,
    required String issuer,
    int digits = _defaultDigits,
    int period = _defaultPeriod,
  }) {
    final label = Uri.encodeComponent('$issuer:$accountName');
    final params = <String, String>{
      'secret': secret,
      'issuer': issuer,
      'algorithm': 'SHA1',
      'digits': '$digits',
      'period': '$period',
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'otpauth://totp/$label?$query';
  }

  // ── HOTP (RFC 4226) ────────────────────────────────────────────────

  static String _hotp(Uint8List key, int counter, int digits) {
    final msg = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      msg[i] = c & 0xff;
      c >>= 8;
    }
    final hmacBytes = Hmac(sha1, key).convert(msg).bytes;
    final offset = hmacBytes[hmacBytes.length - 1] & 0x0f;
    final binary = ((hmacBytes[offset] & 0x7f) << 24) |
        ((hmacBytes[offset + 1] & 0xff) << 16) |
        ((hmacBytes[offset + 2] & 0xff) << 8) |
        (hmacBytes[offset + 3] & 0xff);
    final otp = binary % pow(10, digits).toInt();
    return otp.toString().padLeft(digits, '0');
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  // ── Base32 (RFC 4648, no padding) ──────────────────────────────────

  static String base32Encode(Uint8List data) {
    if (data.isEmpty) return '';
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final b in data) {
      buffer = (buffer << 8) | b;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        out.write(_base32Alphabet[(buffer >> bits) & 0x1f]);
      }
    }
    if (bits > 0) {
      out.write(_base32Alphabet[(buffer << (5 - bits)) & 0x1f]);
    }
    return out.toString();
  }

  static Uint8List base32Decode(String input) {
    final cleaned =
        input.toUpperCase().replaceAll('=', '').replaceAll(' ', '').trim();
    final out = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final ch in cleaned.codeUnits) {
      final val = _base32Alphabet.indexOf(String.fromCharCode(ch));
      if (val < 0) continue; // 跳过非法字符
      buffer = (buffer << 5) | val;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        out.add((buffer >> bits) & 0xff);
      }
    }
    return Uint8List.fromList(out);
  }
}
