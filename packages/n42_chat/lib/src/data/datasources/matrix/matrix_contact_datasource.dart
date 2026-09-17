import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/timed_status_utils.dart';
import '../../../core/utils/matrix_utils.dart';
import 'matrix_client_manager.dart';
import 'contact_privacy_service.dart';
import 'message/direct_chat_send_guard.dart';
import '../../../core/utils/debug_log.dart';

class ContactMembershipUnavailable extends StateError {
  ContactMembershipUnavailable()
    : super('Contact membership could not be refreshed');
}

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

  /// Member state may be absent from memory after login with lazy loading.
  /// Never classify an unloaded member as a removed or unaccepted friend.
  Future<void> refreshDirectChatMembers() async {
    final client = _client;
    if (client == null) return;
    final accountId = client.userID;
    final rooms = client.rooms
        .where(
          (room) =>
              room.isDirectChat &&
              room.membership == matrix.Membership.join &&
              room.directChatMatrixID != accountId,
        )
        .toList();
    var failures = 0;
    for (var offset = 0; offset < rooms.length; offset += 8) {
      await Future.wait(
        rooms.skip(offset).take(8).map((room) async {
          final peer = room.directChatMatrixID;
          if (peer == null) return;
          try {
            await resolveDirectPeer(room, peer);
          } catch (_) {
            failures++;
            debugLog(
              'Contact member refresh failed; keeping other rooms available',
            );
          }
        }),
      );
      if (!identical(client, _client) || accountId != client.userID)
        throw StateError('Account changed');
    }
    if (failures > 0 && getDirectChatContacts().isEmpty) {
      throw ContactMembershipUnavailable();
    }
  }

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
          if (user.content['membership'] == 'join') {
            contacts[partnerId] = user;
          }
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
          final user = room.unsafeGetUserFromMemoryOrFallback(partnerId);
          if (user.content['membership'] == 'join') {
            roomIdMap[partnerId] = room.id;
          }
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

  matrix.Client? _chatOperationClient;
  String? _chatOperationAccount;
  final Map<String, Future<String>> _startingChats = {};
  Future<void> _chatQueue = Future<void>.value();

  /// Coalesce repeated scans and serialize m.direct writes across different peers.
  Future<String> startDirectChat(String userId, {bool encrypted = true}) {
    final client = _client;
    final account = client?.userID;
    if (client == null || account == null) {
      return Future.error(StateError('Matrix client not initialized'));
    }
    if (!identical(client, _chatOperationClient) ||
        account != _chatOperationAccount) {
      _chatOperationClient = client;
      _chatOperationAccount = account;
      _startingChats.clear();
      _chatQueue = Future<void>.value();
    }
    final pending = _startingChats[userId];
    if (pending != null) return pending;
    late final Future<String> operation;
    operation = _chatQueue
        .then((_) => _startDirectChat(client, account, userId, encrypted))
        .whenComplete(() {
          if (identical(_startingChats[userId], operation)) {
            _startingChats.remove(userId);
          }
        });
    _startingChats[userId] = operation;
    _chatQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<String> _startDirectChat(
    matrix.Client client,
    String account,
    String userId,
    bool encrypted,
  ) async {
    void checkSession() {
      if (!identical(client, _client) || account != client.userID) {
        throw StateError('Account changed');
      }
    }

    checkSession();
    if (!userId.startsWith('@') || !userId.contains(':')) {
      throw ArgumentError('Invalid user ID');
    }
    // Prefer an accepted room over a more recently active abandoned invitation.
    final candidates = client.rooms
        .where((room) => room.directChatMatrixID == userId)
        .toList();
    matrix.Room? pending;
    for (final room in candidates) {
      if (room.membership == matrix.Membership.invite) {
        pending ??= room;
        continue;
      }
      if (room.membership != matrix.Membership.join) continue;
      final peer = await resolveDirectPeer(room, userId);
      checkSession();
      if (peer.content['membership'] == 'join') return room.id;
      if (peer.content['membership'] == 'invite') pending ??= room;
      if (peer.content['membership'] == 'ban')
        throw StateError('Contact is blocked in this room');
    }
    if (pending != null) {
      if (pending.membership == matrix.Membership.invite) {
        // Explicitly adding someone who has already invited us is acceptance.
        await acceptInvite(pending.id);
        checkSession();
      }
      return pending.id;
    }
    checkSession();
    final roomId = await client.startDirectChat(
      userId,
      enableEncryption: encrypted,
      skipExistingChat: candidates.isNotEmpty,
    );
    checkSession();
    // The SDK acknowledges m.direct remotely before /sync updates this cache.
    // Reflect that acknowledged write so a second scan cannot create another room.
    final ids = {...?client.directChats[userId], roomId}.toList();
    client.accountData['m.direct'] = matrix.BasicEvent(
      type: 'm.direct',
      content: {...client.directChats, userId: ids},
    );
    return roomId;
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
    final privacy = ContactPrivacyService(_clientManager);
    if (privacy.hides(userId, story: true, incoming: true)) return null;
    for (final room in _client?.rooms ?? <matrix.Room>[]) {
      if (privacy.owner(room) != userId) continue;
      if (room.tags.containsKey(ContactPrivacyService.storyTag)) {
        if (!privacy.canView(room, userId, story: true)) return null;
        final status = TimedStatusMetadata.fromJson(
          room.getState('n42.user.status')?.content,
        );
        return status.isExpired ? null : status.message;
      }
    }
    final presence = await getUserPresence(userId);
    return presence?.statusMsg;
  }

  /// 设置当前用户的状态消息
  Future<void> setUserStatus(String? statusMessage) async {
    await setCurrentUserStatus(statusMessage);
  }

  Future<void> setCurrentUserStatus(
    String? statusMessage, {
    DateTime? expiresAt,
    bool preserveCurrentPresence = false,
  }) async {
    if (_client == null) return;
    final metadata = TimedStatusMetadata(
      message: statusMessage,
      expiresAt: expiresAt,
    ).toJson();
    final privacy = ContactPrivacyService(_clientManager);
    await privacy.load(_client!.userID!);
    await privacy.publishStatus(
      metadata,
      presenceType: preserveCurrentPresence ? null : matrix.PresenceType.online,
    );
    await _client!.setAccountData(
      _client!.userID!,
      'n42.user.status',
      metadata,
    );
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
    if (statusMessage != null) await setCurrentUserStatus(statusMessage);
    await _client!.setPresence(_client!.userID!, presenceType, statusMsg: '');
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

  List<matrix.Room> getOutgoingInvites() =>
      (_client?.rooms ?? <matrix.Room>[]).where((room) {
        final peer = room.directChatMatrixID;
        return room.membership == matrix.Membership.join &&
            peer != null &&
            peer != _client?.userID &&
            room
                    .unsafeGetUserFromMemoryOrFallback(peer)
                    .content['membership'] ==
                'invite';
      }).toList();

  /// 接受邀请
  Future<void> acceptInvite(String roomId) async {
    final client = _client;
    final account = client?.userID;
    final room = client?.getRoomById(roomId);
    if (client == null || account == null || room == null) {
      throw StateError('Friend request is no longer available');
    }
    void checkSession() {
      if (!identical(client, _client) || account != client.userID) {
        throw StateError('Account changed');
      }
    }

    final peer = room.directChatMatrixID;
    await room.join();
    checkSession();
    if (peer != null) {
      await room.addToDirectChat(peer);
      checkSession();
      // Once joined, the SDK can no longer infer the peer from the invitation.
      // Preserve the acknowledged mapping until account data arrives in /sync.
      client.accountData['m.direct'] = matrix.BasicEvent(
        type: 'm.direct',
        content: {
          ...client.directChats,
          peer: {...?client.directChats[peer], roomId}.toList(),
        },
      );
    }
    if (room.membership != matrix.Membership.join) {
      await client
          .waitForRoomInSync(roomId, join: true)
          .timeout(const Duration(seconds: 20));
      checkSession();
    }
    await refreshDirectChatMembers();
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
