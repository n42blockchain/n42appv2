import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// 安全存储服务
/// 
/// 使用 flutter_secure_storage 进行加密存储
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain
@singleton
class SecureStorage {
  late final FlutterSecureStorage _storage;
  
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

