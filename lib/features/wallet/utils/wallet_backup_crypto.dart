import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// N42Wallet 加密备份工具
///
/// 文件格式（.n42backup）：JSON 信封包裹 AES-256-CBC 加密的载荷。
/// 密钥衍生：PBKDF2-SHA256，60 万次迭代。
/// 完整性：AES-CBC 内置 HMAC-SHA256 MAC。
class WalletBackupCrypto {
  static const _kVersion = 1;
  static const _kApp = 'N42Wallet';
  static const _kIterations = 600000;

  // AES-256-CBC with HMAC-SHA256 for integrity
  static final _cipher = AesCbc.with256bits(macAlgorithm: Hmac.sha256());

  WalletBackupCrypto._();

  // ──────────────────────────────────────────────
  // Encrypt
  // ──────────────────────────────────────────────

  /// 将钱包列表加密为 .n42backup JSON 字符串。
  ///
  /// [wallets] 每个元素包含 walletName / mnemonic / privateKey / timestamp。
  /// [password] 用户设置的备份密码（不存储，仅用于密钥衍生）。
  static Future<String> encrypt(
    List<Map<String, dynamic>> wallets,
    String password,
  ) async {
    final salt = _randomBytes(16);
    final key = await _deriveKey(password, salt, _kIterations);

    final payload = utf8.encode(jsonEncode({'wallets': wallets}));
    final secretBox = await _cipher.encrypt(payload, secretKey: key);

    return jsonEncode({
      'version': _kVersion,
      'app': _kApp,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'kdf': 'pbkdf2-sha256',
      'iterations': _kIterations,
      'salt': base64.encode(Uint8List.fromList(salt)),
      'iv': base64.encode(Uint8List.fromList(secretBox.nonce)),
      'mac': base64.encode(Uint8List.fromList(secretBox.mac.bytes)),
      'data': base64.encode(Uint8List.fromList(secretBox.cipherText)),
    });
  }

  // ──────────────────────────────────────────────
  // Decrypt
  // ──────────────────────────────────────────────

  /// 解密 .n42backup JSON 字符串，返回钱包列表。
  ///
  /// 密码错误或文件损坏时抛出 [WalletBackupException]。
  static Future<List<Map<String, dynamic>>> decrypt(
    String backupJson,
    String password,
  ) async {
    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(backupJson) as Map<String, dynamic>;
    } catch (_) {
      throw const WalletBackupException('Invalid backup file format');
    }

    if (envelope['app'] != _kApp) {
      throw const WalletBackupException('Not an N42Wallet backup file');
    }

    final salt = base64.decode(envelope['salt'] as String);
    final iv = base64.decode(envelope['iv'] as String);
    final mac = base64.decode(envelope['mac'] as String);
    final cipherText = base64.decode(envelope['data'] as String);
    final iterations = (envelope['iterations'] as int?) ?? _kIterations;

    final key = await _deriveKey(password, salt, iterations);

    final secretBox = SecretBox(cipherText, nonce: iv, mac: Mac(mac));

    final List<int> plaintext;
    try {
      plaintext = await _cipher.decrypt(secretBox, secretKey: key);
    } catch (_) {
      throw const WalletBackupException('Wrong password or corrupted backup');
    }

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
    } catch (_) {
      throw const WalletBackupException('Backup data is corrupted');
    }

    return (payload['wallets'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  static Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
  ) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  static List<int> _randomBytes(int count) {
    final rng = Random.secure();
    return List.generate(count, (_) => rng.nextInt(256));
  }
}

/// 备份加解密过程中的业务异常（格式错误、密码错误等）。
class WalletBackupException implements Exception {
  final String message;
  const WalletBackupException(this.message);

  @override
  String toString() => 'WalletBackupException: $message';
}
