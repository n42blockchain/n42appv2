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

  // 存储键名常量
  static const String _keyToken = 'auth_token';
  static const String _keyUuid = 'user_uuid';
  static const String _keyEmail = 'user_email';
  static const String _keyUserInfo = 'user_info';
  static const String _keyWalletPrefix = 'wallet_';
  static const String _keyMnemonicPrefix = 'mnemonic_';
  static const String _keyPrivateKeyPrefix = 'pk_';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyDeviceId = 'n42_device_id';
  static const String _keyPasskeyCredentials = 'passkey_credentials';
  static const String _keyPasskeyEnabled = 'passkey_enabled';

  SecureStorage() {
    _storage = const FlutterSecureStorage(
      // Android：flutter_secure_storage v9+ 默认使用 AES-256-GCM custom cipher，
      // 同时加密 key 和 value，防止通过文件系统侧信道推断内容。
      // 注意：encryptedSharedPreferences (Jetpack Security) 在 v11 中已废弃，
      // 库会在首次访问时自动将旧数据迁移到 custom cipher，无需额外配置。
      aOptions: AndroidOptions(
        sharedPreferencesName: 'n42_secure_prefs',
        preferencesKeyPrefix: 'n42_',
      ),
      // iOS：first_unlock_this_device
      // - 设备重启后首次解锁即可访问（适合 App 后台唤醒场景）
      // - 不同步到 iCloud Keychain / 不迁移到新设备（钱包密钥适合此级别）
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        accountName: 'n42wallet',
      ),
    );
  }

  /// 安全擦除字节数组
  ///
  /// 将数据覆写为零，防止内存残留
  static void secureWipeBytes(Uint8List data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  /// 敏感数据包装器
  ///
  /// 使用后调用 dispose() 清除数据
  static SensitiveData<T> wrapSensitive<T>(T data) {
    return SensitiveData<T>(data);
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
    return _readJson<Map<String, dynamic>>(_keyUserInfo, 'user info');
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
    return _readJson<Map<String, dynamic>>(
      '$_keyWalletPrefix$address',
      'wallet credentials',
    );
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
    await _storage.write(key: '$_keyMnemonicPrefix$walletId', value: mnemonic);
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
    await _storage.write(key: '$_keyPrivateKeyPrefix$address', value: privateKey);
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
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  /// 获取生物识别启用状态
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  // ==================== 设备标识 ====================

  /// 保存设备唯一标识
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  /// 获取设备唯一标识
  Future<String?> getDeviceId() async {
    return _storage.read(key: _keyDeviceId);
  }

  // ==================== Passkey 管理 ====================

  /// 保存 Passkey 凭证列表（JSON 序列化）
  Future<void> savePasskeyCredentials(String credentialsJson) async {
    await _storage.write(key: _keyPasskeyCredentials, value: credentialsJson);
  }

  /// 获取 Passkey 凭证列表
  Future<String?> getPasskeyCredentials() async {
    return _storage.read(key: _keyPasskeyCredentials);
  }

  /// 删除 Passkey 凭证
  Future<void> deletePasskeyCredentials() async {
    await _storage.delete(key: _keyPasskeyCredentials);
  }

  /// 设置 Passkey 启用状态
  Future<void> setPasskeyEnabled(bool enabled) async {
    await _storage.write(key: _keyPasskeyEnabled, value: enabled.toString());
  }

  /// 获取 Passkey 启用状态
  Future<bool> isPasskeyEnabled() async {
    final value = await _storage.read(key: _keyPasskeyEnabled);
    return value == 'true';
  }

  // ==================== 内部辅助 ====================

  /// 读取并解码 JSON 值，失败时返回 null
  Future<T?> _readJson<T>(String key, String label) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as T;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to decode $label: $e');
      return null;
    }
  }

  // ==================== 通用方法 ====================

  /// 清除所有存储数据
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// 清除用户相关数据（登出时调用）
  ///
  /// 删除认证信息、钱包凭证、助记词、私钥和安全设置。
  /// 保留 [_keyDeviceId] 以便跨登出持久化。
  Future<void> clearUserData() async {
    final allEntries = await _storage.readAll();
    final keysToDelete = <String>[
      _keyToken,
      _keyUuid,
      _keyEmail,
      _keyUserInfo,
      _keyBiometricEnabled,
      _keyPasskeyCredentials,
      _keyPasskeyEnabled,
    ];

    for (final key in allEntries.keys) {
      if (key.startsWith(_keyWalletPrefix) ||
          key.startsWith(_keyMnemonicPrefix) ||
          key.startsWith(_keyPrivateKeyPrefix)) {
        keysToDelete.add(key);
      }
    }

    await Future.wait(keysToDelete.map((key) => _storage.delete(key: key)));
  }

  /// 检查是否有存储的凭证
  Future<bool> hasCredentials() async {
    final results = await Future.wait([getToken(), getUuid()]);
    final token = results[0];
    final uuid = results[1];
    return token != null && token.isNotEmpty && uuid != null && uuid.isNotEmpty;
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
    if (_disposed) throw StateError('SensitiveData has been disposed');
    return _value as T;
  }

  /// 检查是否已被 dispose
  bool get isDisposed => _disposed;

  /// 清除数据
  void dispose() {
    if (_disposed) return;

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
