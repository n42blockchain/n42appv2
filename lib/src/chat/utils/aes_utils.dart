import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// AES 加密工具类
///
/// 安全特性:
/// - 使用随机 IV (每次加密生成新的 IV)
/// - 使用 PBKDF2 进行密钥派生
/// - IV 与密文一起存储，格式: base64(IV + 密文)
class AesUtils {
  /// PBKDF2 迭代次数 (OWASP 推荐至少 10000)
  static const int _pbkdf2Iterations = 100000;

  /// 盐的长度 (16 字节)
  static const int _saltLength = 16;

  /// IV 长度 (16 字节，AES 块大小)
  static const int _ivLength = 16;

  /// AES 密钥长度 (32 字节 = AES-256)
  static const int _keyLength = 32;

  /// 安全随机数生成器
  final Random _secureRandom = Random.secure();

  /// 生成随机字节
  Uint8List _generateRandomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }

  /// 使用 PBKDF2 派生密钥
  ///
  /// [password] 用户密码
  /// [salt] 盐值
  /// [keyLength] 输出密钥长度
  Uint8List _deriveKey(String password, Uint8List salt, int keyLength) {
    // 使用 PBKDF2 with SHA-256
    final hmac = Hmac(sha256, utf8.encode(password));
    final blocks = (keyLength / 32).ceil();
    final derivedKey = <int>[];

    for (var blockNum = 1; blockNum <= blocks; blockNum++) {
      var block = _pbkdf2Block(hmac, salt, blockNum);
      derivedKey.addAll(block);
    }

    return Uint8List.fromList(derivedKey.sublist(0, keyLength));
  }

  /// PBKDF2 单块计算
  List<int> _pbkdf2Block(Hmac hmac, Uint8List salt, int blockNum) {
    // U1 = PRF(Password, Salt || INT(i))
    final blockBytes = Uint8List(4);
    blockBytes[0] = (blockNum >> 24) & 0xFF;
    blockBytes[1] = (blockNum >> 16) & 0xFF;
    blockBytes[2] = (blockNum >> 8) & 0xFF;
    blockBytes[3] = blockNum & 0xFF;

    final input = Uint8List.fromList([...salt, ...blockBytes]);
    var u = hmac.convert(input).bytes;
    var result = List<int>.from(u);

    // U2 = PRF(Password, U1), ... Un = PRF(Password, Un-1)
    for (var i = 1; i < _pbkdf2Iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  /// AES 加密 (安全版本)
  ///
  /// 使用随机 IV 和 PBKDF2 密钥派生
  /// 输出格式: base64(salt + iv + ciphertext)
  ///
  /// [content] 要加密的明文
  /// [password] 加密密码
  String aesEncode(String content, String password) {
    // 生成随机盐和 IV
    final salt = _generateRandomBytes(_saltLength);
    final iv = _generateRandomBytes(_ivLength);

    // 使用 PBKDF2 派生密钥
    final derivedKey = _deriveKey(password, salt, _keyLength);

    // 使用派生密钥创建 AES 加密器
    final key = encrypt.Key(derivedKey);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    // 加密
    final encrypted = encrypter.encrypt(content, iv: encrypt.IV(iv));

    // 组合: salt + iv + ciphertext
    final combined = Uint8List.fromList([
      ...salt,
      ...iv,
      ...encrypted.bytes,
    ]);

    return base64Encode(combined);
  }

  /// AES 解密 (安全版本)
  ///
  /// 从密文中提取 salt 和 IV 进行解密
  ///
  /// [data] base64 编码的密文 (格式: salt + iv + ciphertext)
  /// [password] 解密密码
  String aesDecrypted(String data, String password) {
    // 解码 base64
    final combined = base64Decode(data);

    // 提取 salt, iv, ciphertext
    final salt = Uint8List.fromList(combined.sublist(0, _saltLength));
    final iv = Uint8List.fromList(
      combined.sublist(_saltLength, _saltLength + _ivLength),
    );
    final ciphertext = Uint8List.fromList(
      combined.sublist(_saltLength + _ivLength),
    );

    // 使用 PBKDF2 派生密钥
    final derivedKey = _deriveKey(password, salt, _keyLength);

    // 使用派生密钥创建 AES 解密器
    final key = encrypt.Key(derivedKey);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    // 解密
    return encrypter.decrypt(encrypt.Encrypted(ciphertext), iv: encrypt.IV(iv));
  }

  // ==================== 遗留兼容性方法 ====================
  // 以下方法用于解密旧格式数据，新数据请使用上述安全方法
  //
  // SECURITY WARNING:
  // 旧加密方法使用固定 IV，这在密码学上是不安全的，因为：
  // 1. 相同的明文+密码会产生相同的密文，允许模式分析
  // 2. 容易受到重放攻击
  // 3. 不符合现代加密标准
  //
  // 迁移策略：
  // 1. 新数据必须使用 aesEncode() 方法
  // 2. 读取旧数据时使用 aesDecryptedAuto() 自动检测格式
  // 3. 解密后应立即使用 aesEncode() 重新加密以升级格式

  /// Legacy encryption usage counter for monitoring migration progress
  static int _legacyDecryptionCount = 0;

  /// Get the count of legacy decryption operations (for monitoring)
  static int get legacyDecryptionCount => _legacyDecryptionCount;

  /// 遗留 IV (仅用于解密旧数据)
  @Deprecated('仅用于解密旧格式数据，新加密请使用 aesEncode')
  static const String _legacyIv = '2624b9a9c447e587';

  /// 解密旧格式数据 (使用固定 IV)
  ///
  /// SECURITY WARNING: This method uses a fixed IV which is cryptographically insecure.
  /// Only use for decrypting existing legacy data, then immediately re-encrypt with aesEncode().
  ///
  /// 仅用于向后兼容，解密使用旧版本加密的数据
  @Deprecated('仅用于解密旧格式数据')
  String aesDecryptedLegacy(String data, String password) {
    _legacyDecryptionCount++;
    // Log warning in debug mode to track legacy usage
    assert(() {
      print('⚠️ WARNING: Using legacy AES decryption (fixed IV). '
            'Consider migrating data to secure format. Count: $_legacyDecryptionCount');
      return true;
    }());

    final key = encrypt.Key.fromUtf8(password);
    final iv = encrypt.IV.fromUtf8(_legacyIv);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );
    return encrypter.decrypt(encrypt.Encrypted.fromBase64(data), iv: iv);
  }

  /// 尝试解密 (自动检测格式)
  ///
  /// 首先尝试新格式，失败后尝试旧格式
  ///
  /// Usage pattern for migration:
  /// ```dart
  /// final decrypted = aesUtils.aesDecryptedAuto(encryptedData, password);
  /// // Immediately re-encrypt with secure method to upgrade format
  /// final upgraded = aesUtils.aesEncode(decrypted, password);
  /// // Save upgraded data
  /// ```
  String aesDecryptedAuto(String data, String password) {
    try {
      // 尝试新格式 (salt + iv + ciphertext)
      final decoded = base64Decode(data);
      if (decoded.length > _saltLength + _ivLength) {
        return aesDecrypted(data, password);
      }
    } catch (_) {
      // 新格式解密失败，尝试旧格式
    }

    // ignore: deprecated_member_use_from_same_package
    return aesDecryptedLegacy(data, password);
  }

  /// Check if data is in legacy format (without trying to decrypt)
  ///
  /// Returns true if the data appears to be in the old format (no salt+iv prefix)
  bool isLegacyFormat(String data) {
    try {
      final decoded = base64Decode(data);
      // Legacy format doesn't have salt+iv prefix, so it's shorter
      return decoded.length <= _saltLength + _ivLength;
    } catch (_) {
      return true; // If we can't decode, assume legacy
    }
  }

  /// Migrate data from legacy format to secure format
  ///
  /// Returns the re-encrypted data in secure format, or null if migration fails
  String? migrateToSecureFormat(String legacyData, String password) {
    try {
      // ignore: deprecated_member_use_from_same_package
      final decrypted = aesDecryptedLegacy(legacyData, password);
      return aesEncode(decrypted, password);
    } catch (_) {
      return null;
    }
  }
}
