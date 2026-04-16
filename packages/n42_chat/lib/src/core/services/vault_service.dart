import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_lock_service.dart';

/// 消息金库服务
///
/// 「金库」= 一组被用户标记为隐私级别最高的会话：
/// - 会话列表主视图中隐藏；仅在"金库入口"内可见。
/// - 进入金库时强制生物识别/PIN 解锁（复用 [ChatLockService]）。
/// - 添加到金库的会话会自动标记为 chat-lock（即便之前未锁）。
///
/// 仅本地持久化，不上传服务器——与 Matrix 联邦无关。
class VaultService {
  static const String _vaultRoomIdsKey = 'n42_vault_room_ids';
  static const String _vaultEnabledKey = 'n42_vault_enabled';

  final ChatLockService _lockService;
  final BehaviorSubject<Set<String>> _vaultRoomIds = BehaviorSubject.seeded(
    const <String>{},
  );
  bool _initialized = false;

  VaultService({required ChatLockService lockService})
      : _lockService = lockService;

  Future<void> _ensureLoaded() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_vaultRoomIdsKey) ?? const [];
    _vaultRoomIds.add(ids.toSet());
    _initialized = true;
  }

  /// 金库功能是否已被用户启用（首次使用要求设置 PIN）。
  Future<bool> isVaultEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vaultEnabledKey) ?? false;
  }

  /// 启用金库功能。
  Future<void> enableVault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultEnabledKey, true);
  }

  /// 关闭金库功能（同时清空列表）。
  Future<void> disableVault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vaultEnabledKey, false);
    await prefs.remove(_vaultRoomIdsKey);
    _vaultRoomIds.add(const <String>{});
  }

  /// 校验用户身份（生物识别优先，失败时用户可走 PIN 校验分支）。
  Future<bool> unlock({String? reason}) async {
    final enabled = await isVaultEnabled();
    if (!enabled) return false;
    return _lockService.verifyWithBiometric(
      reason: reason ?? 'Unlock the message vault',
    );
  }

  /// 获取当前金库中的 room ID 集合（同步快照）。
  Future<Set<String>> getVaultRoomIds() async {
    await _ensureLoaded();
    return _vaultRoomIds.value;
  }

  /// 监听金库 room ID 的变化。
  Stream<Set<String>> watchVaultRoomIds() {
    // 首次订阅前异步加载一次
    scheduleMicrotask(_ensureLoaded);
    return _vaultRoomIds.stream.distinct();
  }

  /// 添加一个会话到金库（自动上锁，覆盖已有锁状态）。
  Future<void> moveToVault(String roomId) async {
    await _ensureLoaded();
    final next = {..._vaultRoomIds.value, roomId};
    await _persist(next);
    // 金库中的会话强制锁定
    final alreadyLocked = await _lockService.isChatLocked(roomId);
    if (!alreadyLocked) {
      await _lockService.lockChat(roomId);
    }
  }

  /// 从金库移出（不自动解锁 chat-lock，由调用方二次确认）。
  Future<void> removeFromVault(String roomId, {bool alsoUnlock = false}) async {
    await _ensureLoaded();
    final next = _vaultRoomIds.value.toSet()..remove(roomId);
    await _persist(next);
    if (alsoUnlock) {
      await _lockService.unlockChat(roomId);
    }
  }

  /// 会话是否在金库中。
  Future<bool> isInVault(String roomId) async {
    await _ensureLoaded();
    return _vaultRoomIds.value.contains(roomId);
  }

  Future<void> _persist(Set<String> next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_vaultRoomIdsKey, next.toList());
    _vaultRoomIds.add(next);
  }

  Future<void> dispose() async {
    await _vaultRoomIds.close();
  }
}
