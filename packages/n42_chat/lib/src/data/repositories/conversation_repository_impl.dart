import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../core/utils/matrix_utils.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../datasources/matrix/matrix_room_datasource.dart';

/// 会话仓库实现
class ConversationRepositoryImpl implements IConversationRepository {
  final MatrixRoomDataSource _roomDataSource;
  final PreferencesDataSource _secureStorage;

  ConversationRepositoryImpl(this._roomDataSource, this._secureStorage);

  @override
  Future<List<ConversationEntity>> getConversations() async {
    final rooms = _roomDataSource.getSortedRooms();
    return rooms.map(_mapRoomToEntity).toList();
  }

  @override
  Stream<List<ConversationEntity>> watchConversations() {
    final roomStream = _roomDataSource.onRoomsChanged;
    if (roomStream == null) {
      return const Stream.empty();
    }

    return _watchMappedRooms<List<matrix.Room>, List<ConversationEntity>>(
      roomStream: roomStream,
      mapValue: (rooms) => rooms.map(_mapRoomToEntity).toList(growable: false),
      hasTypingUsers: (conversations) =>
          conversations.any((item) => item.hasTypingUsers),
      refreshValue: () =>
          _roomDataSource.getSortedRooms().map(_mapRoomToEntity).toList(),
      timeoutFromRooms: _typingTimeoutFromRooms,
    );
  }

  @override
  Future<ConversationEntity?> getConversationById(String id) async {
    final room = _roomDataSource.getRoomById(id);
    if (room == null) return null;
    return _mapRoomToEntity(room);
  }

  @override
  Stream<ConversationEntity?> watchConversation(String id) {
    final roomStream = _roomDataSource.watchRoom(id);
    if (roomStream == null) {
      return const Stream.empty();
    }

    return _watchMappedRooms<matrix.Room?, ConversationEntity?>(
      roomStream: roomStream,
      mapValue: (room) => room == null ? null : _mapRoomToEntity(room),
      hasTypingUsers: (conversation) => conversation?.hasTypingUsers ?? false,
      refreshValue: () {
        final room = _roomDataSource.getRoomById(id);
        return room == null ? null : _mapRoomToEntity(room);
      },
      timeoutFromRooms: (room) => room?.client.typingIndicatorTimeout,
    );
  }

  @override
  Future<ConversationEntity> createDirectChat(String userId) async {
    final encrypted = await _secureStorage.shouldDefaultEncryptNewChats();
    final roomId = await _roomDataSource.createDirectChat(
      userId,
      encrypted: encrypted,
    );
    final room = _roomDataSource.getRoomById(roomId);
    if (room == null) {
      throw Exception('Failed to create direct chat');
    }
    return _mapRoomToEntity(room);
  }

  @override
  Future<ConversationEntity> createGroupChat({
    required String name,
    String? topic,
    List<String>? memberIds,
    bool encrypted = true,
  }) async {
    final roomId = await _roomDataSource.createGroupChat(
      name: name,
      topic: topic,
      inviteUserIds: memberIds,
      encrypted: encrypted,
    );
    final room = _roomDataSource.getRoomById(roomId);
    if (room == null) {
      throw Exception('Failed to create group chat');
    }
    return _mapRoomToEntity(room);
  }

  @override
  Future<void> joinConversation(String conversationIdOrAlias) async {
    await _roomDataSource.joinRoom(conversationIdOrAlias);
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    await _roomDataSource.leaveRoom(conversationId);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Matrix中离开房间即为删除
    await _roomDataSource.leaveRoom(conversationId);
  }

  @override
  Future<void> setMuted(String conversationId, bool muted) async {
    await setNotificationMode(
      conversationId,
      muted
          ? ConversationNotificationMode.muted
          : ConversationNotificationMode.allMessages,
    );
  }

  @override
  Future<void> setNotificationMode(
    String conversationId,
    ConversationNotificationMode mode,
  ) async {
    await _roomDataSource.setRoomNotificationMode(conversationId, mode);
  }

  @override
  Future<ConversationNotificationMode> getNotificationMode(
    String conversationId,
  ) async {
    final room = _roomDataSource.getRoomById(conversationId);
    if (room == null) {
      return ConversationNotificationMode.allMessages;
    }
    return _roomDataSource.getRoomNotificationMode(room);
  }

  @override
  Future<void> setPinned(String conversationId, bool pinned) async {
    await _roomDataSource.setRoomPinned(conversationId, pinned);
  }

  @override
  Future<void> setStrongReminder(String conversationId, bool enabled) async {
    await _secureStorage.setStrongReminder(conversationId, enabled);
  }

  @override
  Future<bool> getStrongReminder(String conversationId) async {
    return await _secureStorage.getStrongReminderStatus(conversationId);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _roomDataSource.markRoomAsRead(conversationId);
  }

  @override
  Future<int> getTotalUnreadCount() async {
    final rooms = _roomDataSource.getJoinedRooms();
    return rooms.fold<int>(0, (sum, room) {
      return sum + _roomDataSource.getUnreadCount(room);
    });
  }

  @override
  Stream<int> watchTotalUnreadCount() {
    return watchConversations().map((conversations) {
      return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
    });
  }

  @override
  Future<List<ConversationEntity>> searchConversations(String query) async {
    if (query.isEmpty) return getConversations();

    final lowerQuery = query.toLowerCase();
    final rooms = _roomDataSource.getJoinedRooms();

    return rooms
        .where((room) {
          final name = _roomDataSource.getRoomDisplayName(room).toLowerCase();
          return name.contains(lowerQuery);
        })
        .map(_mapRoomToEntity)
        .toList();
  }

  // ============================================
  // 辅助方法
  // ============================================

  /// 将Matrix Room转换为ConversationEntity
  ConversationEntity _mapRoomToEntity(matrix.Room room) {
    final lastMessageTime = _roomDataSource.getLastMessageTime(room);

    // 获取头像和成员信息
    String? avatarUrl;
    List<String?>? memberAvatarUrls;
    List<String>? memberNames;
    List<String>? memberIds;

    if (room.isDirectChat) {
      // 私聊：获取对方用户的真实头像
      final partner = _roomDataSource.getDirectChatPartner(room);
      final mxcUrl = partner?.avatarUrl?.toString();

      // 只使用用户明确设置的头像（非空且非默认占位图）
      if (mxcUrl != null && mxcUrl.isNotEmpty && mxcUrl.startsWith('mxc://')) {
        // 检查是否是服务器默认头像（跳过 identicon 和其他默认图）
        // tuwunel/Synapse 可能使用不同的默认头像 URL 模式
        final isDefaultAvatar =
            mxcUrl.contains('identicon') ||
            mxcUrl.contains('default') ||
            mxcUrl.contains('placeholder');

        if (!isDefaultAvatar) {
          avatarUrl = MatrixUtils.mxcToHttp(
            mxcUrl,
            client: room.client,
            width: 96,
            height: 96,
          );
        }
      }
      // avatarUrl 为 null 时，UI 根据 name 显示字母头像
    } else {
      // 群聊：获取房间头像
      avatarUrl = _roomDataSource.getRoomAvatarUrl(room);
      // 获取成员头像列表（用于九宫格头像）
      final members = _getGroupMemberInfo(room);
      memberAvatarUrls = members.$1;
      memberNames = members.$2;
      memberIds = members.$3;
    }

    // 获取私聊对方的用户ID
    String? directUserId;
    if (room.isDirectChat) {
      directUserId = room.directChatMatrixID;
    }

    final currentUserId = room.client.userID;
    final typingUsers = room.typingUsers
        .where((user) => user.id != currentUserId)
        .map((user) {
          final displayName = user.calcDisplayname().trim();
          return displayName.isNotEmpty ? displayName : user.id;
        })
        .toSet()
        .toList(growable: false);

    return ConversationEntity(
      id: room.id,
      name: _roomDataSource.getRoomDisplayName(room),
      avatarUrl: avatarUrl,
      type: room.isDirectChat
          ? ConversationType.direct
          : ConversationType.group,
      lastMessage: _roomDataSource.getLastMessagePreview(room),
      lastMessageTime: lastMessageTime,
      lastMessageSenderId: room.lastEvent?.senderId,
      unreadCount: _roomDataSource.getUnreadCount(room),
      highlightCount: _roomDataSource.getHighlightCount(room),
      isMuted: _roomDataSource.isMuted(room),
      isPinned: room.isFavourite,
      isEncrypted: _roomDataSource.isEncrypted(room),
      memberCount: _roomDataSource.getMemberCount(room),
      memberAvatarUrls: memberAvatarUrls,
      memberNames: memberNames,
      memberIds: memberIds,
      hasTypingUsers: typingUsers.isNotEmpty,
      typingUsers: typingUsers,
      directUserId: directUserId,
    );
  }

  Stream<T> _watchMappedRooms<S, T>({
    required Stream<S> roomStream,
    required T Function(S value) mapValue,
    required bool Function(T value) hasTypingUsers,
    required T Function() refreshValue,
    required Duration? Function(S value) timeoutFromRooms,
  }) {
    late final StreamController<T> controller;
    StreamSubscription<S>? subscription;
    Timer? refreshTimer;

    void scheduleRefresh(S value, T mapped) {
      refreshTimer?.cancel();
      refreshTimer = null;

      if (!hasTypingUsers(mapped)) {
        return;
      }

      final timeout = timeoutFromRooms(value);
      if (timeout == null) {
        return;
      }

      refreshTimer = Timer(timeout + const Duration(milliseconds: 250), () {
        if (!controller.isClosed) {
          controller.add(refreshValue());
        }
      });
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = roomStream.listen(
          (value) {
            final mapped = mapValue(value);
            if (!controller.isClosed) {
              controller.add(mapped);
            }
            scheduleRefresh(value, mapped);
          },
          onError: controller.addError,
          onDone: () {
            refreshTimer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () async {
        refreshTimer?.cancel();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  Duration? _typingTimeoutFromRooms(List<matrix.Room> rooms) {
    for (final room in rooms) {
      if (room.typingUsers.isNotEmpty) {
        return room.client.typingIndicatorTimeout;
      }
    }
    return null;
  }

  /// 获取群成员头像、名称和ID列表（最多17个，用于群详情页显示）
  /// 参照微信：包含自己，按加入顺序排列
  ///
  /// 优化：首次渲染时返回空列表，UI 异步加载
  /// 将首次渲染从 800ms 降至约 200ms
  (List<String?>, List<String>, List<String>) _getGroupMemberInfo(
    matrix.Room room, {
    bool lazyLoad = true,
  }) {
    // 首次渲染使用懒加载模式，返回空列表让 UI 快速显示
    // 后续 UI 层会异步请求完整成员信息
    if (lazyLoad) {
      return (<String?>[], <String>[], <String>[]);
    }

    final client = room.client;

    final avatarUrls = <String?>[];
    final names = <String>[];
    final ids = <String>[];

    // 获取已加入的成员（包括自己，最多取17个）
    final participants = room.getParticipants();

    int count = 0;
    for (final member in participants) {
      if (count >= 17) break;
      if (member.membership != matrix.Membership.join) continue; // 只取已加入的成员

      final memberName = member.displayName ?? member.id.localpart ?? '';
      final memberId = member.id;

      // 获取头像 URL - 只使用用户明确设置的头像
      final mxcUri = member.avatarUrl?.toString();
      String? httpUrl;

      // 检查是否是用户自定义头像（排除服务器默认头像）
      if (mxcUri != null && mxcUri.isNotEmpty && mxcUri.startsWith('mxc://')) {
        final isDefaultAvatar =
            mxcUri.contains('identicon') ||
            mxcUri.contains('default') ||
            mxcUri.contains('placeholder');

        if (!isDefaultAvatar) {
          httpUrl = MatrixUtils.mxcToHttp(
            mxcUri,
            client: client,
            width: 64,
            height: 64,
          );
        }
      }
      // httpUrl 为 null 时，UI 根据 memberName 显示字母头像

      avatarUrls.add(httpUrl);
      names.add(memberName);
      ids.add(memberId);
      count++;
    }

    return (avatarUrls, names, ids);
  }
}
