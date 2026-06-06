import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// 加密密钥数据
///
/// [data] 要加密的数据对象，包含：
///   - privateKey: 私钥
///   - mnemonicWords: 助记词
///   - validator: 验证器对象（包含 privateKey 和 publicKey）
/// [password] 用户密码，用于派生加密密钥
///
/// 返回 JSON 格式的加密数据，包含版本、时间戳、KDF 参数、加密参数和密文
///
/// 数据结构示例：
/// {
///   "privateKey": "",
///   "mnemonicWords": "",
///   "validator": {
///     "privateKey": "",
///     "publicKey": ""
///   }
/// }
Future<String> encryptSecret({
  required Map<String, dynamic> data,
  required String password,
}) async {
  if (data.isEmpty) throw ArgumentError('data must not be empty');
  if (password.isEmpty) throw ArgumentError('password must not be empty');

  try {
    final dataJson = jsonEncode(data);
    if (dataJson.isEmpty) {
      throw ArgumentError('data serialization failed');
    }

    final random = Random.secure();
    final salt = Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    final iv = Uint8List.fromList(
      List<int>.generate(12, (_) => random.nextInt(256)),
    );

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 150000,
      bits: 256,
    );

    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    final aesGcm = AesGcm.with256bits();

    final encrypted = await aesGcm.encrypt(
      utf8.encode(dataJson),
      secretKey: key,
      nonce: iv,
    );

    final jsonMap = {
      "version": "1",
      "timestamp": DateTime.now().toUtc().toIso8601String(),

      "kdf": {
        "name": "pbkdf2",
        "params": {"iterations": 150000, "dklen": 32},
        "salt": base64Encode(salt),
      },

      "cipher": {"name": "aes-256-gcm", "iv": base64Encode(iv)},

      "ciphertext": base64Encode(encrypted.cipherText),
      "tag": base64Encode(encrypted.mac.bytes),
    };
    return jsonEncode(jsonMap);
  } catch (e) {
    throw Exception('encryption failed: $e');
  }
}

/// 解密密钥数据
///
/// [encryptedData] 加密后的 JSON 字符串（由 encryptSecret 生成）
/// [password] 用户密码，用于派生解密密钥
///
/// 返回解密后的数据对象，包含：
///   - privateKey: 私钥
///   - mnemonicWords: 助记词
///   - validator: 验证器对象（包含 privateKey 和 publicKey）
///
/// 抛出异常如果：
/// - 密码错误
/// - 加密数据格式不正确
/// - 解密失败
Future<Map<String, dynamic>> decryptSecret({
  required String encryptedData,
  required String password,
}) async {
  if (encryptedData.isEmpty)
    throw ArgumentError('encryptedData must not be empty');
  if (password.isEmpty) throw ArgumentError('password must not be empty');

  try {
    final jsonData = jsonDecode(encryptedData) as Map<String, dynamic>;

    final version = jsonData['version'] as String?;
    if (version != '1') {
      throw ArgumentError('unsupported encryption version: $version');
    }

    final kdf = jsonData['kdf'] as Map<String, dynamic>?;
    if (kdf == null) {
      throw ArgumentError('missing KDF parameters');
    }
    final kdfName = kdf['name'] as String?;
    if (kdfName != 'pbkdf2') {
      throw ArgumentError('unsupported KDF algorithm: $kdfName');
    }
    final kdfParams = kdf['params'] as Map<String, dynamic>?;
    if (kdfParams == null) {
      throw ArgumentError('missing KDF params config');
    }
    final iterations = kdfParams['iterations'] as int?;
    final dklen = kdfParams['dklen'] as int?;
    if (iterations == null || dklen == null) {
      throw ArgumentError('incomplete KDF params');
    }
    final saltBase64 = kdf['salt'] as String?;
    if (saltBase64 == null) {
      throw ArgumentError('missing salt');
    }
    final salt = base64Decode(saltBase64);

    final cipher = jsonData['cipher'] as Map<String, dynamic>?;
    if (cipher == null) {
      throw ArgumentError('missing cipher parameters');
    }
    final cipherName = cipher['name'] as String?;
    if (cipherName != 'aes-256-gcm') {
      throw ArgumentError('unsupported cipher algorithm: $cipherName');
    }
    final ivBase64 = cipher['iv'] as String?;
    if (ivBase64 == null) {
      throw ArgumentError('missing IV');
    }
    final iv = base64Decode(ivBase64);

    final ciphertextBase64 = jsonData['ciphertext'] as String?;
    final tagBase64 = jsonData['tag'] as String?;
    if (ciphertextBase64 == null || tagBase64 == null) {
      throw ArgumentError('missing ciphertext or auth tag');
    }
    final ciphertext = base64Decode(ciphertextBase64);
    final tag = base64Decode(tagBase64);

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: dklen * 8,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    final aesGcm = AesGcm.with256bits();
    final secretBox = SecretBox(ciphertext, nonce: iv, mac: Mac(tag));
    final decrypted = await aesGcm.decrypt(secretBox, secretKey: key);

    return jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
  } on ArgumentError {
    rethrow;
  } catch (e) {
    throw Exception('decryption failed: $e');
  }
}
