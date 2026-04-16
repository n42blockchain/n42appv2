import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../datasources/matrix/matrix_contact_datasource.dart';
import '../datasources/matrix/matrix_moment_datasource.dart';
import '../../core/utils/debug_log.dart';

/// 联系人仓库实现
class ContactRepositoryImpl implements IContactRepository {
  final MatrixContactDataSource _contactDataSource;
  final PreferencesDataSource _storageDataSource;
  final MatrixMomentDataSource _momentDataSource;

  /// 备注缓存
  Map<String, String> _remarkCache = {};

  ContactRepositoryImpl(
    this._contactDataSource,
    this._storageDataSource,
    this._momentDataSource,
  );

  /// 加载备注缓存
  Future<void> _loadRemarkCache() async {
    _remarkCache = await _storageDataSource.getContactRemarks();
  }

  /// 用户ID到房间ID的映射缓存
  Map<String, String> _directRoomIdMap = {};

  @override
  Future<List<ContactEntity>> getContacts() async {
    // 先加载备注缓存
    await _loadRemarkCache();

    // 获取用户ID到房间ID的映射
    _directRoomIdMap = _contactDataSource.getDirectChatRoomIdMap();

    final users = _contactDataSource.getDirectChatContacts();
    return users.map(_mapUserToEntity).toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  }

  @override
  Stream<List<ContactEntity>> watchContacts() async* {
    // 初始数据
    yield await getContacts();

    // 监听变化
    final stream = _contactDataSource.onContactsChanged;
    if (stream != null) {
      await for (final _ in stream) {
        yield await getContacts();
      }
    }
  }

  @override
  Future<ContactEntity?> getContactById(String userId) async {
    await _loadRemarkCache();
    final profile = await _contactDataSource.getUserProfile(userId);
    if (profile == null) return null;

    return _mapProfileToEntity(userId, profile);
  }

  @override
  Future<List<ContactEntity>> searchContacts(String query) async {
    if (query.trim().isEmpty) return getContacts();

    final contacts = await getContacts();
    final lowerQuery = query.toLowerCase();

    return contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(lowerQuery) ||
          contact.userId.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<ContactEntity>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    final profiles = await _contactDataSource.searchUsers(query, limit: limit);

    // 在线状态需要异步获取，这里先返回离线状态，后续可以单独更新
    return profiles.map((profile) {
      final avatarUrl = _contactDataSource.getProfileAvatarUrl(profile);
      return ContactEntity(
        userId: profile.userId,
        displayName: profile.displayName ?? profile.userId,
        avatarUrl: avatarUrl,
        // 默认离线，实际在线状态可以在UI层异步更新
        presence: PresenceStatus.offline,
      );
    }).toList();
  }

  @override
  Future<String> startDirectChat(String userId) async {
    final encrypted = await _storageDataSource.shouldDefaultEncryptNewChats();
    final roomId = await _contactDataSource.startDirectChat(
      userId,
      encrypted: encrypted,
    );

    // 发起聊天时，也邀请对方加入我的 Moment 房间
    try {
      await _momentDataSource.inviteFriendToMomentRoom(userId);
    } catch (e) {
      debugLog(
        'ContactRepository: Failed to invite to moment room after startDirectChat: $e',
      );
    }

    return roomId;
  }

  @override
  String? getDirectChatRoomId(String userId) {
    return _contactDataSource.getDirectChatRoomId(userId);
  }

  @override
  Future<void> ignoreUser(String userId) async {
    await _contactDataSource.ignoreUser(userId);
  }

  @override
  Future<void> unignoreUser(String userId) async {
    await _contactDataSource.unignoreUser(userId);
  }

  @override
  bool isUserIgnored(String userId) {
    return _contactDataSource.isUserIgnored(userId);
  }

  @override
  Future<List<ContactEntity>> getIgnoredUsers() async {
    final ignoredIds = _contactDataSource.ignoredUsers;
    final contacts = <ContactEntity>[];

    for (final userId in ignoredIds) {
      final profile = await _contactDataSource.getUserProfile(userId);
      if (profile != null) {
        contacts.add(_mapProfileToEntity(userId, profile));
      }
    }

    return contacts;
  }

  @override
  Future<List<FriendRequest>> getPendingFriendRequests() async {
    final invites = _contactDataSource.getPendingInvites();
    final requests = <FriendRequest>[];

    for (final room in invites) {
      // Use directChatMatrixID to get the inviter's ID for direct chat rooms
      final inviter = room.directChatMatrixID;
      final user = inviter != null
          ? room.unsafeGetUserFromMemoryOrFallback(inviter)
          : null;

      // 手动构建头像 URL
      String? avatarUrl;
      if (user?.avatarUrl != null) {
        avatarUrl = _contactDataSource.getUserAvatarUrl(user!);
      }

      // Use display name if available, otherwise extract username from userId
      String displayName = user?.calcDisplayname() ?? '';

      // If display name is empty or just the user ID, try to fetch from server
      if ((displayName.isEmpty || displayName == inviter) && inviter != null) {
        try {
          final profile = await _contactDataSource.getUserProfile(inviter);
          if (profile != null) {
            if (profile.displayName != null &&
                profile.displayName!.isNotEmpty) {
              displayName = profile.displayName!;
            }
            // Also get avatar from profile if not already set
            avatarUrl ??= _contactDataSource.getProfileAvatarUrl(profile);
          }
        } catch (e) {
          // Ignore errors, will use fallback
          debugLog('Error: $e');
        }
      }

      // Fallback: extract username from Matrix ID format (@username:server)
      if (displayName.isEmpty && inviter != null) {
        displayName = inviter.split(':').first.replaceFirst('@', '');
      }
      if (displayName.isEmpty) {
        displayName = 'Unknown User';
      }

      requests.add(
        FriendRequest(
          id: room.id,
          userId: inviter ?? '',
          userName: displayName,
          userAvatarUrl: avatarUrl,
          requestTime: null, // StrippedStateEvent doesn't have originServerTs
        ),
      );
    }

    return requests;
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    // 1. 接受好友请求（加入聊天房间）
    await _contactDataSource.acceptInvite(requestId);

    // 2. 获取好友的 userId
    final room = _contactDataSource.getRoomById(requestId);
    final friendUserId = room?.directChatMatrixID;

    // 3. 邀请好友加入我的 Moment 房间（使好友能看到我的朋友圈）
    if (friendUserId != null) {
      debugLog(
        'ContactRepository: Inviting friend $friendUserId to moment room',
      );
      try {
        await _momentDataSource.inviteFriendToMomentRoom(friendUserId);
      } catch (e) {
        debugLog('ContactRepository: Failed to invite to moment room: $e');
        // 不影响好友请求的接受
      }
    }
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await _contactDataSource.rejectInvite(requestId);
  }

  @override
  bool isUserOnline(String userId) {
    // 同步版本，返回false，实际使用需要异步调用
    return false;
  }

  @override
  DateTime? getLastActiveTime(String userId) {
    // 同步版本，返回null，实际使用需要异步调用
    return null;
  }

  /// 异步获取用户是否在线
  Future<bool> isUserOnlineAsync(String userId) async {
    return await _contactDataSource.isUserOnline(userId);
  }

  /// 异步获取用户最后活动时间
  Future<DateTime?> getLastActiveTimeAsync(String userId) async {
    return await _contactDataSource.getLastActiveTime(userId);
  }

  @override
  Stream<Map<String, bool>> watchOnlineStatus() async* {
    final stream = _contactDataSource.onPresenceChanged;
    if (stream == null) return;

    final statusMap = <String, bool>{};

    await for (final presence in stream) {
      statusMap[presence.userid] =
          presence.presence == matrix.PresenceType.online;
      yield Map.from(statusMap);
    }
  }

  @override
  Future<String?> getUserStatusMessage(String userId) async {
    return await _contactDataSource.getUserStatusMessage(userId);
  }

  @override
  Future<void> setMyStatus(String? statusMessage, {Duration? expiresIn}) async {
    await _contactDataSource.setCurrentUserStatus(
      statusMessage,
      expiresAt: expiresIn == null
          ? null
          : DateTime.now().toUtc().add(expiresIn),
    );
  }

  @override
  Future<String?> getMyStatus() async {
    final myUserId = _contactDataSource.currentUserId;
    if (myUserId == null) return null;
    return await _contactDataSource.getCurrentUserStatusMessage();
  }

  // ============================================
  // 辅助方法
  // ============================================

  ContactEntity _mapUserToEntity(matrix.User user) {
    final avatarUrl = _contactDataSource.getUserAvatarUrl(user);
    final remark = _remarkCache[user.id];
    // 从缓存的映射中获取私聊房间ID
    final directRoomId = _directRoomIdMap[user.id];

    return ContactEntity(
      userId: user.id,
      displayName: _contactDataSource.getUserDisplayName(user),
      avatarUrl: avatarUrl,
      // 在线状态需要异步获取，这里默认离线
      presence: PresenceStatus.offline,
      remark: remark,
      isBlocked: _contactDataSource.isUserIgnored(user.id),
      directRoomId: directRoomId,
      isFriend: directRoomId != null,
    );
  }

  ContactEntity _mapProfileToEntity(String userId, matrix.Profile profile) {
    final avatarUrl = _contactDataSource.getProfileAvatarUrl(profile);
    final remark = _remarkCache[userId];
    // 获取私聊房间ID
    final directRoomId = _contactDataSource.getDirectChatRoomId(userId);

    return ContactEntity(
      userId: userId,
      displayName: profile.displayName ?? userId,
      avatarUrl: avatarUrl,
      // 在线状态需要异步获取，这里默认离线
      presence: PresenceStatus.offline,
      remark: remark,
      isBlocked: _contactDataSource.isUserIgnored(userId),
      directRoomId: directRoomId,
      isFriend: directRoomId != null,
    );
  }

  @override
  Future<void> setContactRemark(String userId, String? remark) async {
    await _storageDataSource.setContactRemark(userId, remark);
    // 更新缓存
    if (remark == null || remark.isEmpty) {
      _remarkCache.remove(userId);
    } else {
      _remarkCache[userId] = remark;
    }
  }

  @override
  Future<String?> getContactRemark(String userId) async {
    // 先检查缓存
    if (_remarkCache.containsKey(userId)) {
      return _remarkCache[userId];
    }
    // 从存储中读取
    return await _storageDataSource.getContactRemark(userId);
  }

  @override
  Future<Map<String, String>> getContactRemarks() async {
    await _loadRemarkCache();
    return Map.from(_remarkCache);
  }

  @override
  Future<void> deleteContact(String userId) async {
    // 删除联系人
    await _contactDataSource.deleteContact(userId);
    // 清除备注缓存
    _remarkCache.remove(userId);
    await _storageDataSource.setContactRemark(userId, null);
  }
}
