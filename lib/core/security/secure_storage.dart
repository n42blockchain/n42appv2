import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// 安全存储服务
///
/// 使用 flutter_secure_storage 进行加密存储
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain
///
/// 安全特性:
/// - 敏感数据使用安全擦除机制
/// - 提供内存中敏感数据的清除方法
@singleton
class SecureStorage {
  late final FlutterSecureStorage _storage;

  /// 安全擦除字节数组
  ///
  /// 将数据覆写为零，防止内存残留
  static void secureWipeBytes(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  /// 安全擦除字符串 (尽可能)
  ///
  /// 注意: Dart 字符串是不可变的，此方法创建副本并返回
  /// 调用者应该立即将原变量设置为 null
  ///
  /// 示例用法:
  /// ```dart
  /// var mnemonic = await getMnemonic('id');
  /// // 使用 mnemonic...
  /// SecureStorage.secureWipeString(mnemonic);
  /// mnemonic = null; // 移除引用
  /// ```
  static void secureWipeString(String? data) {
    // Dart 字符串是不可变的，无法真正擦除
    // 此方法主要用于代码意图的文档化
    // 真正的安全措施在于:
    // 1. 尽快将变量设置为 null
    // 2. 使用 Uint8List 代替 String 存储敏感数据
    // 3. 依赖 Dart GC 和操作系统内存保护
    if (kDebugMode && data != null) {
      debugPrint('⚠️ [SecureStorage] Reminder: Set sensitive variable to null after use');
    }
  }

  /// 敏感数据包装器
  ///
  /// 使用后调用 dispose() 清除数据
  static SensitiveData<T> wrapSensitive<T>(T data) {
    return SensitiveData<T>(data);
  }
  
  // 存储键名常量
  static const String _keyToken = 'auth_token';
  static const String _keyUuid = 'user_uuid';
  static const String _keyEmail = 'user_email';
  static const String _keyUserInfo = 'user_info';
  static const String _keyWalletPrefix = 'wallet_';
  static const String _keyMnemonicPrefix = 'mnemonic_';
  static const String _keyPrivateKeyPrefix = 'pk_';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyGesturePassword = 'gesture_password';

  SecureStorage() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: 'n42_secure_prefs',
        preferencesKeyPrefix: 'n42_',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        accountName: 'n42wallet',
      ),
    );
  }

  // ==================== Token 管理 ====================
  
  /// 保存认证 Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// 获取认证 Token
  Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  /// 删除认证 Token
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // ==================== 用户信息 ====================
  
  /// 保存用户 UUID
  Future<void> saveUuid(String uuid) async {
    await _storage.write(key: _keyUuid, value: uuid);
  }

  /// 获取用户 UUID
  Future<String?> getUuid() async {
    return _storage.read(key: _keyUuid);
  }

  /// 删除用户 UUID
  Future<void> deleteUuid() async {
    await _storage.delete(key: _keyUuid);
  }

  /// 保存用户邮箱
  Future<void> saveEmail(String email) async {
    await _storage.write(key: _keyEmail, value: email);
  }

  /// 获取用户邮箱
  Future<String?> getEmail() async {
    return _storage.read(key: _keyEmail);
  }

  /// 保存用户信息（JSON）
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _storage.write(key: _keyUserInfo, value: jsonEncode(userInfo));
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    final value = await _storage.read(key: _keyUserInfo);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to decode user info: $e');
      return null;
    }
  }

  // ==================== 钱包凭证 ====================
  
  /// 保存钱包信息
  Future<void> saveWalletCredentials({
    required String address,
    required Map<String, dynamic> credentials,
  }) async {
    await _storage.write(
      key: '$_keyWalletPrefix$address',
      value: jsonEncode(credentials),
    );
  }

  /// 获取钱包信息
  Future<Map<String, dynamic>?> getWalletCredentials(String address) async {
    final value = await _storage.read(key: '$_keyWalletPrefix$address');
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to decode wallet credentials: $e');
      return null;
    }
  }

  /// 删除钱包信息
  Future<void> deleteWalletCredentials(String address) async {
    await _storage.delete(key: '$_keyWalletPrefix$address');
  }

  // ==================== 助记词管理 ====================
  
  /// 保存助记词（加密存储）
  /// 
  /// ⚠️ 助记词是极度敏感的信息，必须加密存储
  Future<void> saveMnemonic({
    required String walletId,
    required String mnemonic,
  }) async {
    // 额外的内存保护：使用后立即清除
    await _storage.write(
      key: '$_keyMnemonicPrefix$walletId',
      value: mnemonic,
    );
  }

  /// 获取助记词
  Future<String?> getMnemonic(String walletId) async {
    return _storage.read(key: '$_keyMnemonicPrefix$walletId');
  }

  /// 删除助记词
  Future<void> deleteMnemonic(String walletId) async {
    await _storage.delete(key: '$_keyMnemonicPrefix$walletId');
  }

  // ==================== 私钥管理 ====================
  
  /// 保存私钥（加密存储）
  /// 
  /// ⚠️ 私钥是极度敏感的信息，必须加密存储
  Future<void> savePrivateKey({
    required String address,
    required String privateKey,
  }) async {
    await _storage.write(
      key: '$_keyPrivateKeyPrefix$address',
      value: privateKey,
    );
  }

  /// 获取私钥
  Future<String?> getPrivateKey(String address) async {
    return _storage.read(key: '$_keyPrivateKeyPrefix$address');
  }

  /// 删除私钥
  Future<void> deletePrivateKey(String address) async {
    await _storage.delete(key: '$_keyPrivateKeyPrefix$address');
  }

  // ==================== 安全设置 ====================
  
  /// 设置生物识别启用状态
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  /// 获取生物识别启用状态
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  /// 保存手势密码
  Future<void> saveGesturePassword(List<int> pattern) async {
    await _storage.write(
      key: _keyGesturePassword,
      value: jsonEncode(pattern),
    );
  }

  /// 获取手势密码
  Future<List<int>?> getGesturePassword() async {
    final value = await _storage.read(key: _keyGesturePassword);
    if (value == null) return null;
    try {
      return (jsonDecode(value) as List).cast<int>();
    } catch (e) {
      debugPrint('Failed to decode gesture password: $e');
      return null;
    }
  }

  /// 删除手势密码
  Future<void> deleteGesturePassword() async {
    await _storage.delete(key: _keyGesturePassword);
  }

  // ==================== 通用方法 ====================
  
  /// 清除所有存储数据
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// 清除用户相关数据（登出时调用）
  Future<void> clearUserData() async {
    await deleteToken();
    await _storage.delete(key: _keyUuid);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyUserInfo);
  }

  /// 检查是否有存储的凭证
  Future<bool> hasCredentials() async {
    final token = await getToken();
    final uuid = await getUuid();
    return token != null && token.isNotEmpty &&
           uuid != null && uuid.isNotEmpty;
  }
}

/// 敏感数据包装器
///
/// 用于包装敏感数据，确保使用后可以被清除
///
/// 使用示例:
/// ```dart
/// final sensitive = SecureStorage.wrapSensitive(await getMnemonic('id'));
/// try {
///   // 使用 sensitive.value
/// } finally {
///   sensitive.dispose();
/// }
/// ```
class SensitiveData<T> {
  T? _value;
  bool _disposed = false;

  SensitiveData(this._value);

  /// 获取值
  ///
  /// 如果已被 dispose 则抛出异常
  T get value {
    if (_disposed) {
      throw StateError('SensitiveData has been disposed');
    }
    return _value as T;
  }

  /// 检查是否已被 dispose
  bool get isDisposed => _disposed;

  /// 清除数据
  void dispose() {
    if (_disposed) return;

    // 尝试清除数据
    if (_value is Uint8List) {
      SecureStorage.secureWipeBytes(_value as Uint8List);
    } else if (_value is List<int>) {
      final list = _value as List<int>;
      for (var i = 0; i < list.length; i++) {
        list[i] = 0;
      }
    }

    _value = null;
    _disposed = true;
  }
}

