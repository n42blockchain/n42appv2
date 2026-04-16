import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../utils/username_validator.dart';
import '../utils/debug_log.dart';

/// 用户名服务
///
/// 使用专用 Matrix 房间 `#n42-usernames:si46.world` 作为用户名注册表。
/// 每个用户名注册为类型 `n42.username.claim` 的状态事件，
/// state_key 为用户名本身，利用 Matrix 状态事件的天然唯一键保证唯一性。
class UsernameService {
  final MatrixClientManager _clientManager;

  static const String _registryRoomAlias = '#n42-usernames:si46.world';
  static const String _claimEventType = 'n42.username.claim';
  static const String _accountDataKey = 'n42.user.profile';

  String? _registryRoomId;

  UsernameService(this._clientManager);

  matrix.Client? get _client => _clientManager.client;

  /// 获取或加入注册表房间
  Future<String?> _getRegistryRoomId() async {
    if (_registryRoomId != null) return _registryRoomId;

    try {
      // 尝试通过别名查找
      final resolveResult = await _client?.getRoomIdByAlias(_registryRoomAlias);
      _registryRoomId = resolveResult?.roomId;

      // 如果还未加入，则加入
      if (_registryRoomId != null) {
        final room = _client?.getRoomById(_registryRoomId!);
        if (room == null) {
          await _client?.joinRoom(_registryRoomId!);
        }
      }

      return _registryRoomId;
    } catch (e) {
      debugLog('UsernameService: Failed to get registry room: $e');
      return null;
    }
  }

  /// 注册（声明）用户名
  ///
  /// 使用 Matrix 状态事件确保唯一性。
  /// state_key = 用户名 → 天然唯一键
  Future<bool> claimUsername(String username) async {
    // 先验证格式
    final validation = UsernameValidator.validate(username);
    if (!validation.isValid) return false;

    final normalized = UsernameValidator.normalize(username);
    final roomId = await _getRegistryRoomId();
    if (roomId == null || _client == null) return false;

    try {
      // 先检查是否已被占用
      final existing = await _lookupInRegistry(normalized);
      if (existing != null && existing != _client!.userID) {
        return false; // 已被其他用户占用
      }

      // 声明用户名（设置状态事件）
      await _client!.setRoomStateWithKey(
        roomId,
        _claimEventType,
        normalized,
        {
          'user_id': _client!.userID,
          'claimed_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // 同时保存到账户数据
      await _saveToAccountData(normalized);

      return true;
    } catch (e) {
      debugLog('UsernameService: Failed to claim username: $e');
      return false;
    }
  }

  /// 释放用户名
  Future<bool> releaseUsername(String username) async {
    final normalized = UsernameValidator.normalize(username);
    final roomId = await _getRegistryRoomId();
    if (roomId == null || _client == null) return false;

    try {
      // 清除状态事件（设为空内容）
      await _client!.setRoomStateWithKey(
        roomId,
        _claimEventType,
        normalized,
        {
          'user_id': null,
          'released_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // 从账户数据中移除
      await _saveToAccountData(null);
      return true;
    } catch (e) {
      debugLog('UsernameService: Failed to release username: $e');
      return false;
    }
  }

  /// 检查用户名是否可用
  Future<bool> isAvailable(String username) async {
    final normalized = UsernameValidator.normalize(username);
    final existing = await _lookupInRegistry(normalized);
    return existing == null || existing == _client?.userID;
  }

  /// 查找用户名对应的 Matrix 用户 ID
  Future<String?> lookupUsername(String username) async {
    final normalized = UsernameValidator.normalize(username);
    return _lookupInRegistry(normalized);
  }

  /// 搜索用户名（前缀匹配）
  Future<List<UsernameSearchResult>> searchUsernames(String query) async {
    final roomId = await _getRegistryRoomId();
    if (roomId == null || _client == null) return [];

    try {
      final room = _client!.getRoomById(roomId);
      if (room == null) return [];

      final results = <UsernameSearchResult>[];
      final normalizedQuery = query.toLowerCase();

      // 遍历房间状态事件进行前缀搜索
      final states = room.states[_claimEventType];
      if (states != null) {
        for (final entry in states.entries) {
          final username = entry.key;
          final event = entry.value;
          final userId = event.content['user_id'] as String?;

          if (userId != null &&
              userId.isNotEmpty &&
              username.startsWith(normalizedQuery)) {
            results.add(UsernameSearchResult(
              username: username,
              userId: userId,
            ));
          }
        }
      }

      return results;
    } catch (e) {
      debugLog('UsernameService: Failed to search usernames: $e');
      return [];
    }
  }

  /// 获取当前用户的用户名
  Future<String?> getMyUsername() async {
    if (_client == null) return null;
    try {
      final accountData = _client!.accountData[_accountDataKey];
      return accountData?.content['username'] as String?;
    } catch (e) {
      debugLog('Error: $e');
      return null;
    }
  }

  /// 在注册表中查找用户名
  Future<String?> _lookupInRegistry(String username) async {
    final roomId = await _getRegistryRoomId();
    if (roomId == null || _client == null) return null;

    try {
      final room = _client!.getRoomById(roomId);
      if (room == null) return null;

      final stateEvent = room.getState(_claimEventType, username);
      final userId = stateEvent?.content['user_id'] as String?;
      return (userId != null && userId.isNotEmpty) ? userId : null;
    } catch (e) {
      debugLog('Error: $e');
      return null;
    }
  }

  /// 保存用户名到账户数据
  Future<void> _saveToAccountData(String? username) async {
    if (_client == null) return;

    try {
      final existing = _client!.accountData[_accountDataKey]?.content ?? {};
      final updated = Map<String, dynamic>.from(existing);
      updated['username'] = username;
      await _client!.setAccountData(_client!.userID!, _accountDataKey, updated);
    } catch (e) {
      debugLog('UsernameService: Failed to save account data: $e');
    }
  }
}

/// 用户名搜索结果
class UsernameSearchResult {
  final String username;
  final String userId;

  const UsernameSearchResult({
    required this.username,
    required this.userId,
  });
}
