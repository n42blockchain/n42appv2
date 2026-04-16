import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shared_preferences/shared_preferences.dart';

import 'biometric_service.dart';

/// 聊天锁服务
///
/// 管理每个聊天的独立锁定状态（本地存储，不上传服务器）
/// 支持生物识别和 PIN 码两种解锁方式
class ChatLockService {
  static const String _lockedChatsKey = 'chat_lock_locked_chats';
  static const String _chatPinPrefix = 'chat_lock_pin_';
  static const String _chatPinSaltPrefix = 'chat_lock_pin_salt_';

  final BiometricService _biometricService;

  ChatLockService({BiometricService? biometricService})
      : _biometricService = biometricService ?? BiometricService();

  /// 检查聊天是否已锁定
  Future<bool> isChatLocked(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final lockedChats = prefs.getStringList(_lockedChatsKey) ?? [];
    return lockedChats.contains(roomId);
  }

  /// 锁定聊天
  ///
  /// [roomId] 房间ID
  /// [pin] 可选 PIN 码（如果不设置，则仅使用生物识别）
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
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('$_chatPinPrefix$roomId');
    if (storedHash == null) return false;

    final salt = prefs.getString('$_chatPinSaltPrefix$roomId');
    if (salt != null && salt.isNotEmpty) {
      return _hashPin(pin, salt) == storedHash;
    }

    final verified = _hashLegacyPin(pin) == storedHash;
    if (verified) {
      await _savePinHash(roomId, pin);
    }
    return verified;
  }

  /// 检查聊天是否设置了 PIN 码
  Future<bool> hasPinSet(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_chatPinPrefix$roomId');
  }

  /// 保存 PIN 码哈希
  Future<void> _savePinHash(String roomId, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = _generateSalt();
    await prefs.setString('$_chatPinSaltPrefix$roomId', salt);
    await prefs.setString('$_chatPinPrefix$roomId', _hashPin(pin, salt));
  }

  /// 移除 PIN 码
  Future<void> _removePinHash(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_chatPinPrefix$roomId');
    await prefs.remove('$_chatPinSaltPrefix$roomId');
  }

  /// 对 PIN 码进行 PBKDF2 哈希（100 000 轮，抵抗 4-6 位 PIN 的暴力破解）
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
