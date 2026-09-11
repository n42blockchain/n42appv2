import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// RFC 6238 TOTP 工具类（纯客户端，无需网络）。
class TotpUtil {
  static const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const _period = 30;
  static const _digits = 6;

  /// 生成随机 Base32 secret（160 bits = 32 chars）。
  static String generateSecret() {
    final rng = Random.secure();
    return List.generate(32, (_) => _base32Alphabet[rng.nextInt(32)]).join();
  }

  /// 计算指定时间的验证码；未指定时使用当前时间。
  static String generate(String secret, {DateTime? at}) =>
      _hotp(_base32Decode(secret), _counter(at));

  /// 验证六位数字，允许前后一个时间窗口；损坏的密钥不能通过验证。
  static bool verify(String secret, String code, {DateTime? at}) {
    if (code.length != _digits || !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      return false;
    }
    try {
      final t = _counter(at);
      final key = _base32Decode(secret);
      return (t > 0 && _hotp(key, t - 1) == code) ||
          _hotp(key, t) == code ||
          _hotp(key, t + 1) == code;
    } on FormatException {
      return false;
    } on ArgumentError {
      return false;
    }
  }

  /// 构造 otpauth URI；标签和查询参数独立编码，避免特殊字符破坏二维码。
  static String buildOtpAuthUri({
    required String secret,
    required String account,
    String issuer = 'N42 Wallet',
  }) {
    _base32Decode(secret);
    final normalized = secret.toUpperCase().replaceFirst(RegExp(r'=+$'), '');
    final encodedIssuer = Uri.encodeComponent(issuer);
    final encodedAccount = Uri.encodeComponent(account);
    return 'otpauth://totp/$encodedIssuer:$encodedAccount'
        '?secret=$normalized&issuer=$encodedIssuer&algorithm=SHA1&digits=$_digits&period=$_period';
  }

  static int _counter(DateTime? at) {
    final milliseconds = (at ?? DateTime.now()).millisecondsSinceEpoch;
    if (milliseconds < 0) {
      throw ArgumentError('TOTP time must not precede the Unix epoch');
    }
    return milliseconds ~/ 1000 ~/ _period;
  }

  static String _hotp(Uint8List key, int counter) {
    final msg = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      msg[i] = c & 0xff;
      c >>= 8;
    }
    final hmac = Hmac(sha1, key).convert(msg).bytes;
    final offset = hmac[19] & 0xf;
    final code =
        ((hmac[offset] & 0x7f) << 24) |
        (hmac[offset + 1] << 16) |
        (hmac[offset + 2] << 8) |
        hmac[offset + 3];
    return (code % 1000000).toString().padLeft(_digits, '0');
  }

  static Uint8List _base32Decode(String input) {
    final upper = input.toUpperCase();
    if (!RegExp(r'^[A-Za-z2-7]+={0,6}$').hasMatch(input)) {
      throw const FormatException('Invalid Base32 secret');
    }
    final s = upper.replaceFirst(RegExp(r'=+$'), '');
    final remainder = s.length % 8;
    if (!const {0, 2, 4, 5, 7}.contains(remainder) ||
        (upper.length != s.length &&
            (remainder == 0 || upper.length != s.length + 8 - remainder))) {
      throw const FormatException('Invalid Base32 length or padding');
    }
    var bits = 0;
    var value = 0;
    final output = <int>[];
    for (final char in s.codeUnits) {
      value = (value << 5) | _base32Alphabet.codeUnits.indexOf(char);
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        output.add((value >> bits) & 0xff);
        value &= (1 << bits) - 1;
      }
    }
    if (value != 0) {
      throw const FormatException('Nonzero Base32 padding bits');
    }
    return Uint8List.fromList(output);
  }
}
