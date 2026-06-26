import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shared_preferences/shared_preferences.dart';

import 'biometric_service.dart';

/// 聊天锁服务
///
/// 管理每个聊天的独立锁定状态。
/// PIN 哈希和 salt 存储在 FlutterSecureStorage（Keychain/Keystore）中。
/// 已锁定房间列表（非敏感）保留在 SharedPreferences 中。
class ChatLockService {
  static const String _lockedChatsKey = 'chat_lock_locked_chats';

  // SecureStorage keys — intentionally same string as legacy SP keys
  // so migration reads the same logical key from the old store.
  // Do NOT change these without updating the migration logic.
  static const String _pinKeyPrefix = 'chat_lock_pin_';
  static const String _saltKeyPrefix = 'chat_lock_pin_salt_';

  final BiometricService _biometricService;
  final FlutterSecureStorage _secureStorage;

  ChatLockService({
    BiometricService? biometricService,
    FlutterSecureStorage? secureStorage,
  })  : _biometricService = biometricService ?? BiometricService(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// 检查聊天是否已锁定
  Future<bool> isChatLocked(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final lockedChats = prefs.getStringList(_lockedChatsKey) ?? [];
    return lockedChats.contains(roomId);
  }

  /// 锁定聊天
  Future<void> lockChat(String roomId, {String? pin}) async {
    final prefs = await SharedPreferences.getInstance();
    final lockedChats = prefs.getStringList(_lockedChatsKey) ?? [];
    if (!lockedChats.contains(roomId)) {
      lockedChats.add(roomId);
      await prefs.setStringList(_lockedChatsKey, lockedChats);
    }
    if (pin != null && pin.isNotEmpty) {
      await _savePinHash(roomId, pin);
    }
  }

  /// 解锁聊天（移除锁定）
  Future<void> unlockChat(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final lockedChats = prefs.getStringList(_lockedChatsKey) ?? [];
    lockedChats.remove(roomId);
    await prefs.setStringList(_lockedChatsKey, lockedChats);
    await _removePinHash(roomId);
  }

  /// 获取所有已锁定的聊天 ID
  Future<List<String>> getLockedChatIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_lockedChatsKey) ?? [];
  }

  /// 使用生物识别验证
  Future<bool> verifyWithBiometric({String? reason}) async {
    final result = await _biometricService.authenticate(
      reason: reason ?? 'Verify to access this chat',
    );
    return result.success;
  }

  /// 检查是否支持生物识别
  Future<bool> isBiometricAvailable() async {
    return _biometricService.isAvailable();
  }

  /// 验证 PIN 码
  Future<bool> verifyPin(String roomId, String pin) async {
    // 尝试从 SecureStorage 读取
    var storedHash = await _secureStorage.read(key: '$_pinKeyPrefix$roomId');
    var salt = await _secureStorage.read(key: '$_saltKeyPrefix$roomId');

    // 如果 SecureStorage 中没有，尝试从 SharedPreferences 迁移
    if (storedHash == null) {
      final migrated = await _migrateFromSharedPreferences(roomId);
      if (migrated) {
        storedHash = await _secureStorage.read(key: '$_pinKeyPrefix$roomId');
        salt = await _secureStorage.read(key: '$_saltKeyPrefix$roomId');
      }
    }

    if (storedHash == null) return false;

    if (salt != null && salt.isNotEmpty) {
      return _hashPin(pin, salt) == storedHash;
    }

    // Legacy format (plain SHA-256)
    final verified = _hashLegacyPin(pin) == storedHash;
    if (verified) {
      // Upgrade to PBKDF2 + SecureStorage
      await _savePinHash(roomId, pin);
    }
    return verified;
  }

  /// 检查聊天是否设置了 PIN 码
  Future<bool> hasPinSet(String roomId) async {
    // Check SecureStorage first
    final ssHash = await _secureStorage.read(key: '$_pinKeyPrefix$roomId');
    if (ssHash != null) return true;

    // Check SharedPreferences (not yet migrated)
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_pinKeyPrefix$roomId');
  }

  // ============================================
  // Private
  // ============================================

  /// 保存 PIN 码哈希到 SecureStorage
  Future<void> _savePinHash(String roomId, String pin) async {
    final salt = _generateSalt();
    await _secureStorage.write(key: '$_saltKeyPrefix$roomId', value: salt);
    await _secureStorage.write(
      key: '$_pinKeyPrefix$roomId',
      value: _hashPin(pin, salt),
    );

    // 清理旧的 SharedPreferences 数据
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_pinKeyPrefix$roomId');
      await prefs.remove('$_saltKeyPrefix$roomId');
    } catch (_) {
      // Non-critical: old data can remain
    }
  }

  /// 移除 PIN 码
  Future<void> _removePinHash(String roomId) async {
    await _secureStorage.delete(key: '$_pinKeyPrefix$roomId');
    await _secureStorage.delete(key: '$_saltKeyPrefix$roomId');

    // Also clean up any legacy SP data
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_pinKeyPrefix$roomId');
      await prefs.remove('$_saltKeyPrefix$roomId');
    } catch (_) {}
  }

  /// 从 SharedPreferences 迁移到 SecureStorage
  /// Returns true if migration was performed.
  Future<bool> _migrateFromSharedPreferences(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = prefs.getString('$_pinKeyPrefix$roomId');
      if (hash == null) return false;

      final salt = prefs.getString('$_saltKeyPrefix$roomId');

      // Write to SecureStorage
      await _secureStorage.write(key: '$_pinKeyPrefix$roomId', value: hash);
      if (salt != null) {
        await _secureStorage.write(key: '$_saltKeyPrefix$roomId', value: salt);
      }

      // Remove from SharedPreferences after successful migration
      await prefs.remove('$_pinKeyPrefix$roomId');
      await prefs.remove('$_saltKeyPrefix$roomId');

      return true;
    } catch (_) {
      // Migration failed silently — next call will retry
      return false;
    }
  }

  /// PBKDF2 哈希（100 000 轮）
  String _hashPin(String pin, String salt) {
    final saltBytes = Uint8List.fromList(utf8.encode(salt));
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(saltBytes, 100000, 32));
    final key = derivator.process(Uint8List.fromList(utf8.encode(pin)));
    return base64UrlEncode(key);
  }

  String _hashLegacyPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
