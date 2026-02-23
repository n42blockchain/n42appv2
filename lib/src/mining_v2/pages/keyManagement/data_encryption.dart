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
  // 输入验证
  if (data.isEmpty) {
    throw ArgumentError('data 不能为空');
  }
  if (password.isEmpty) {
    throw ArgumentError('password 不能为空');
  }

  try {
    // 将数据对象序列化为 JSON 字符串
    final dataJson = jsonEncode(data);
    if (dataJson.isEmpty) {
      throw ArgumentError('数据序列化失败');
    }

    // 生成随机 salt (16 字节) 和 IV (12 字节，AES-GCM 标准)
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final ivBytes = List<int>.generate(12, (_) => random.nextInt(256));
    final salt = Uint8List.fromList(saltBytes);
    final iv = Uint8List.fromList(ivBytes);

    // 配置 PBKDF2 密钥派生函数
    // 使用 SHA-256，150000 次迭代，生成 256 位（32 字节）密钥
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 150000,
      bits: 256,
    );

    // 从密码派生加密密钥
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    // 使用 AES-256-GCM 进行加密
    final aesGcm = AesGcm.with256bits();

    final encrypted = await aesGcm.encrypt(
      utf8.encode(dataJson),
      secretKey: key,
      nonce: iv,
    );

    // 构建加密数据格式
    final jsonMap = {
      "version": "1",
      "timestamp": DateTime.now().toUtc().toIso8601String(),

      "kdf": {
        "name": "pbkdf2",
        "params": { "iterations": 150000, "dklen": 32 },
        "salt": base64Encode(salt)
      },

      "cipher": {
        "name": "aes-256-gcm",
        "iv": base64Encode(iv)
      },

      "ciphertext": base64Encode(encrypted.cipherText),
      "tag": base64Encode(encrypted.mac.bytes),
    };
    return jsonEncode(jsonMap);
  } catch (e) {
    throw Exception('加密失败: $e');
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
  // 输入验证
  if (encryptedData.isEmpty) {
    throw ArgumentError('encryptedData 不能为空');
  }
  if (password.isEmpty) {
    throw ArgumentError('password 不能为空');
  }

  try {
    // 解析 JSON 数据
    final jsonData = jsonDecode(encryptedData) as Map<String, dynamic>;
    
    // 验证版本
    final version = jsonData['version'] as String?;
    if (version != '1') {
      throw ArgumentError('不支持的加密版本: $version');
    }

    // 提取 KDF 参数
    final kdf = jsonData['kdf'] as Map<String, dynamic>?;
    if (kdf == null) {
      throw ArgumentError('缺少 KDF 参数');
    }
    final kdfName = kdf['name'] as String?;
    if (kdfName != 'pbkdf2') {
      throw ArgumentError('不支持的 KDF 算法: $kdfName');
    }
    final kdfParams = kdf['params'] as Map<String, dynamic>?;
    if (kdfParams == null) {
      throw ArgumentError('缺少 KDF 参数配置');
    }
    final iterations = kdfParams['iterations'] as int?;
    final dklen = kdfParams['dklen'] as int?;
    if (iterations == null || dklen == null) {
      throw ArgumentError('KDF 参数不完整');
    }
    final saltBase64 = kdf['salt'] as String?;
    if (saltBase64 == null) {
      throw ArgumentError('缺少 salt');
    }
    final salt = base64Decode(saltBase64);

    // 提取加密参数
    final cipher = jsonData['cipher'] as Map<String, dynamic>?;
    if (cipher == null) {
      throw ArgumentError('缺少加密参数');
    }
    final cipherName = cipher['name'] as String?;
    if (cipherName != 'aes-256-gcm') {
      throw ArgumentError('不支持的加密算法: $cipherName');
    }
    final ivBase64 = cipher['iv'] as String?;
    if (ivBase64 == null) {
      throw ArgumentError('缺少 IV');
    }
    final iv = base64Decode(ivBase64);

    // 提取密文和认证标签
    final ciphertextBase64 = jsonData['ciphertext'] as String?;
    final tagBase64 = jsonData['tag'] as String?;
    if (ciphertextBase64 == null || tagBase64 == null) {
      throw ArgumentError('缺少密文或认证标签');
    }
    final ciphertext = base64Decode(ciphertextBase64);
    final tag = base64Decode(tagBase64);

    // 配置 PBKDF2 密钥派生函数（使用与加密时相同的参数）
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: dklen * 8, // dklen 是字节数，bits 是位数
    );

    // 从密码派生解密密钥（使用相同的 salt）
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    // 使用 AES-256-GCM 进行解密
    final aesGcm = AesGcm.with256bits();

    // 构建 SecretBox（包含密文和认证标签）
    final secretBox = SecretBox(
      ciphertext,
      nonce: iv,
      mac: Mac(tag),
    );

    // 解密
    final decrypted = await aesGcm.decrypt(
      secretBox,
      secretKey: key,
    );

    // 将解密后的字节转换为字符串，然后解析为 JSON 对象
    final decryptedJson = utf8.decode(decrypted);
    final data = jsonDecode(decryptedJson) as Map<String, dynamic>;
    
    return data;
  } on ArgumentError {
    rethrow;
  } catch (e) {
    // 可能是密码错误或其他解密错误
    throw Exception('解密失败: $e');
  }
}
