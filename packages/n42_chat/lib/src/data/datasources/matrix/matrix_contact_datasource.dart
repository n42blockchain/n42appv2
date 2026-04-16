import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/timed_status_utils.dart';
import '../../../core/utils/matrix_utils.dart';
import 'matrix_client_manager.dart';

/// Matrix联系人数据源
///
/// 封装Matrix SDK的联系人相关操作
class MatrixContactDataSource {
  final MatrixClientManager _clientManager;

  MatrixContactDataSource(this._clientManager);

  /// 获取Matrix客户端
  matrix.Client? get _client => _clientManager.client;

  /// 获取当前用户ID
  String? get currentUserId => _client?.userID;

  // ============================================
  // 联系人获取
  // ============================================

  /// 获取所有私聊联系人（有直接聊天的用户）
  List<matrix.User> getDirectChatContacts() {
    final contacts = <String, matrix.User>{};

    for (final room in _client?.rooms ?? <matrix.Room>[]) {
      final isDirectChat = room.isDirectChat;
      final isJoined = room.membership == matrix.Membership.join;
      if (isDirectChat && isJoined) {
        final partnerId = room.directChatMatrixID;
        if (partnerId != null && partnerId != _client?.userID) {
          final user = room.unsafeGetUserFromMemoryOrFallback(partnerId);
          contacts[partnerId] = user;
        }
      }
    }

    return contacts.values.toList();
  }

  /// 获取所有私聊联系人及其房间ID（用于备注名查找）
  Map<String, String> getDirectChatRoomIdMap() {
    final roomIdMap = <String, String>{};

    for (final room in _client?.rooms ?? <matrix.Room>[]) {
      final isDirectChat = room.isDirectChat;
      final isJoined = room.membership == matrix.Membership.join;
      if (isDirectChat && isJoined) {
        final partnerId = room.directChatMatrixID;
        if (partnerId != null && partnerId != _client?.userID) {
          roomIdMap[partnerId] = room.id;
        }
      }
    }

    return roomIdMap;
  }

  /// 获取所有已知用户（包括群聊成员）
  List<matrix.User> getAllKnownUsers() {
    final users = <String, matrix.User>{};

    for (final room in _client?.rooms ?? <matrix.Room>[]) {
      if (room.membership != matrix.Membership.join) continue;

      final participants = room.getParticipants();
      for (final participant in participants) {
        final participantId = participant.id;
        if (participantId != _client?.userID &&
            !users.containsKey(participantId)) {
          final user = room.unsafeGetUserFromMemoryOrFallback(participantId);
          users[participantId] = user;
        }
      }
    }

    return users.values.toList();
  }

  /// 搜索用户
  Future<List<matrix.Profile>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    if (_client == null || query.trim().isEmpty) return [];

    try {
      final result = await _client!.searchUserDirectory(query, limit: limit);
      return result.results;
    } catch (e) {
      return [];
    }
  }

  /// 根据用户ID获取用户资料
  Future<matrix.Profile?> getUserProfile(String userId) async {
    if (_client == null) return null;

    try {
      return await _client!.getProfileFromUserId(userId);
    } catch (e) {
      return null;
    }
  }

  /// 获取用户显示名称
  String getUserDisplayName(matrix.User user) {
    return user.calcDisplayname();
  }

  /// 获取用户头像URL
  String? getUserAvatarUrl(matrix.User user, {int size = 96}) {
    return MatrixUtils.getAvatarUrl(
      user.avatarUrl,
      client: _client,
      size: size,
    );
  }

  /// 获取Profile头像URL
  String? getProfileAvatarUrl(matrix.Profile profile, {int size = 96}) {
    return MatrixUtils.getAvatarUrl(
      profile.avatarUrl,
      client: _client,
      size: size,
    );
  }

  // ============================================
  // 联系人操作
  // ============================================

  /// 通过房间ID获取房间
  matrix.Room? getRoomById(String roomId) {
    return _client?.getRoomById(roomId);
  }

  /// 检查是否有与用户的私聊
  String? getDirectChatRoomId(String userId) {
    return _client?.getDirectChatFromUserId(userId);
  }

  /// 创建或获取与用户的私聊
  Future<String> startDirectChat(String userId, {bool encrypted = true}) async {
    if (_client == null) {
      throw Exception('Matrix client not initialized');
    }

    return await _client!.startDirectChat(userId, enableEncryption: encrypted);
  }

  /// 忽略用户
  Future<void> ignoreUser(String userId) async {
    if (_client == null) return;
    await _client!.ignoreUser(userId);
  }

  /// 取消忽略用户
  Future<void> unignoreUser(String userId) async {
    if (_client == null) return;
    await _client!.unignoreUser(userId);
  }

  /// 检查用户是否被忽略
  bool isUserIgnored(String userId) {
    return _client?.ignoredUsers.contains(userId) ?? false;
  }

  /// 获取被忽略的用户列表
  List<String> get ignoredUsers => _client?.ignoredUsers ?? [];

  // ============================================
  // 用户在线状态
  // ============================================

  /// 获取用户在线状态
  Future<matrix.CachedPresence?> getUserPresence(String userId) async {
    try {
      return await _client?.fetchCurrentPresence(userId);
    } catch (e) {
      return null;
    }
  }

  /// 获取用户是否在线
  Future<bool> isUserOnline(String userId) async {
    final presence = await getUserPresence(userId);
    return presence?.presence == matrix.PresenceType.online;
  }

  /// 获取用户最后活动时间
  Future<DateTime?> getLastActiveTime(String userId) async {
    final presence = await getUserPresence(userId);
    return presence?.lastActiveTimestamp;
  }

  /// 获取用户状态消息
  Future<String?> getUserStatusMessage(String userId) async {
    final presence = await getUserPresence(userId);
    return presence?.statusMsg;
  }

  /// 设置当前用户的状态消息
  Future<void> setUserStatus(String? statusMessage) async {
    await _setStatusMessage(statusMessage);
  }

  Future<void> setCurrentUserStatus(
    String? statusMessage, {
    DateTime? expiresAt,
    bool preserveCurrentPresence = false,
  }) async {
    if (_client == null) return;
    await _setStatusMessage(
      statusMessage,
      preserveCurrentPresence: preserveCurrentPresence,
    );
    await _client!.setAccountData(_client!.userID!, 'n42.user.status', {
      ...TimedStatusMetadata(
        message: statusMessage,
        expiresAt: expiresAt,
      ).toJson(),
    });
  }

  Future<String?> getCurrentUserStatusMessage() async {
    final client = _client;
    if (client == null || client.userID == null) {
      return null;
    }

    try {
      final raw = await client.getAccountData(
        client.userID!,
        'n42.user.status',
      );
      final metadata = TimedStatusMetadata.fromJson(raw);
      if (metadata.isExpired) {
        await setCurrentUserStatus(null, preserveCurrentPresence: true);
        return null;
      }
      if (metadata.hasMessage) {
        return metadata.message;
      }
    } catch (_) {
      // Fallback to presence status when account-data metadata is absent or invalid.
    }

    return await getUserStatusMessage(client.userID!);
  }

  /// 设置当前用户的在线状态
  Future<void> setPresenceStatus(
    matrix.PresenceType presenceType, {
    String? statusMessage,
  }) async {
    if (_client == null) return;
    await _client!.setPresence(
      _client!.userID!,
      presenceType,
      statusMsg: statusMessage,
    );
  }

  Future<void> _setStatusMessage(
    String? statusMessage, {
    bool preserveCurrentPresence = false,
  }) async {
    final client = _client;
    final userId = client?.userID;
    if (client == null || userId == null) return;

    var presenceType = matrix.PresenceType.online;
    if (preserveCurrentPresence) {
      try {
        presenceType = (await client.fetchCurrentPresence(userId)).presence;
      } catch (_) {
        // Fall back to online when the current presence cannot be resolved.
      }
    }

    await client.setPresence(userId, presenceType, statusMsg: statusMessage);
  }

  // ============================================
  // 好友请求（通过邀请实现）
  // ============================================

  /// 获取待处理的邀请
  List<matrix.Room> getPendingInvites() {
    return _client?.rooms
            .where(
              (room) =>
                  room.membership == matrix.Membership.invite &&
                  room.isDirectChat,
            )
            .toList() ??
        [];
  }

  /// 接受邀请
  Future<void> acceptInvite(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.join();
  }

  /// 拒绝邀请
  Future<void> rejectInvite(String roomId) async {
    final room = _client?.getRoomById(roomId);
    if (room == null) return;
    await room.leave();
  }

  /// 删除联系人（离开私聊房间）
  Future<void> deleteContact(String userId) async {
    if (_client == null) return;

    // 获取与该用户的私聊房间
    final roomId = _client!.getDirectChatFromUserId(userId);
    if (roomId == null) return;

    final room = _client!.getRoomById(roomId);
    if (room == null) return;

    // 离开房间（相当于删除联系人）
    await room.leave();
  }

  // ============================================
  // NFT 头像存储
  // ============================================

  static const String _nftAvatarEventType = 'n42.nft_avatar';

  /// 获取用户的 NFT 头像数据
  Map<String, dynamic>? getNftAvatarData() {
    if (_client == null) return null;
    try {
      final data = _client!.accountData[_nftAvatarEventType];
      return data?.content;
    } catch (e) {
      return null;
    }
  }

  /// 存储 NFT 头像数据到 Matrix account data
  Future<void> setNftAvatarData({
    required String contractAddress,
    required int tokenId,
    required int chainId,
    required String imageUrl,
  }) async {
    final userId = _client?.userID;
    if (_client == null || userId == null) return;
    await _client!.setAccountData(userId, _nftAvatarEventType, {
      'contract_address': contractAddress,
      'token_id': tokenId,
      'chain_id': chainId,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// 清除 NFT 头像数据
  Future<void> clearNftAvatarData() async {
    final userId = _client?.userID;
    if (_client == null || userId == null) return;
    await _client!.setAccountData(userId, _nftAvatarEventType, {
      'cleared': true,
    });
  }

  // ============================================
  // 监听
  // ============================================

  /// 监听联系人变化（通过同步事件）
  Stream<void>? get onContactsChanged => _client?.onSync.stream;

  /// 监听在线状态变化
  Stream<matrix.CachedPresence>? get onPresenceChanged =>
      _client?.onPresenceChanged.stream;
}
