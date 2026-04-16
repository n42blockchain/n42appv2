import 'package:matrix/matrix.dart' as matrix;

import '../../domain/entities/contact_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../core/services/ens_cache_service.dart';
import '../../core/services/username_service.dart';
import '../datasources/matrix/matrix_search_datasource.dart';
import '../datasources/matrix/matrix_client_manager.dart';
import '../../core/utils/debug_log.dart';
import '../../core/utils/matrix_utils.dart';

/// 搜索仓库实现
class SearchRepositoryImpl implements ISearchRepository {
  final MatrixSearchDataSource _searchDataSource;
  final MatrixClientManager _clientManager;
  final EnsCacheService? _ensCacheService;
  final UsernameService? _usernameService;

  SearchRepositoryImpl(
    this._searchDataSource,
    this._clientManager, {
    EnsCacheService? ensCacheService,
    UsernameService? usernameService,
  }) : _ensCacheService = ensCacheService,
       _usernameService = usernameService;

  @override
  Future<SearchResults> searchGlobal(
    String query, {
    SearchResultType? type,
    MessageSearchFilter? filter,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      return const SearchResults();
    }

    // 保存搜索记录
    await saveSearchQuery(query);

    List<SearchResultItem> contacts = [];
    List<SearchResultItem> groups = [];
    List<SearchResultItem> conversations = [];
    List<SearchResultItem> messages = [];

    // 根据类型搜索
    if (type == null || type == SearchResultType.all) {
      contacts = await searchContacts(query, limit: limit ~/ 4);
      groups = await searchGroups(query, limit: limit ~/ 4);
      conversations = await searchConversations(query, limit: limit ~/ 4);
      messages = await searchMessages(query, limit: limit ~/ 4, filter: filter);
    } else {
      switch (type) {
        case SearchResultType.contact:
          contacts = await searchContacts(query, limit: limit);
          break;
        case SearchResultType.group:
          groups = await searchGroups(query, limit: limit);
          break;
        case SearchResultType.conversation:
          conversations = await searchConversations(query, limit: limit);
          break;
        case SearchResultType.message:
          messages = await searchMessages(query, limit: limit, filter: filter);
          break;
        case SearchResultType.all:
          break;
      }
    }

    return SearchResults(
      contacts: contacts,
      groups: groups,
      conversations: conversations,
      messages: messages,
      query: query,
      messageFilter: filter == null || filter.isEmpty ? null : filter,
    );
  }

  @override
  Future<List<SearchResultItem>> searchContacts(
    String query, {
    int limit = 20,
  }) async {
    final results = <SearchResultItem>[];

    // @username 搜索
    if (query.startsWith('@') && _usernameService != null) {
      final usernameQuery = query.substring(1);
      if (usernameQuery.isNotEmpty) {
        try {
          final usernameResults = await _usernameService.searchUsernames(
            usernameQuery,
          );
          for (final usernameResult in usernameResults) {
            results.add(
              SearchResultItem(
                type: SearchResultType.contact,
                id: usernameResult.userId,
                title: '@${usernameResult.username}',
                subtitle: usernameResult.userId,
                matchedKeyword: query,
              ),
            );
          }
        } catch (e) {
          debugLog('SearchRepository: Username search failed: $e');
        }
      }
    }

    // .eth/.n42 ENS 域名搜索
    if (_isEnsQuery(query) && _ensCacheService != null) {
      try {
        final address = await _ensCacheService.resolveEnsName(query);
        if (address != null) {
          results.add(
            SearchResultItem(
              type: SearchResultType.contact,
              id: 'ens:$query',
              title: query,
              subtitle:
                  '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
              matchedKeyword: query,
            ),
          );
        }
      } catch (e) {
        debugLog('SearchRepository: ENS search failed: $e');
      }
    }

    // 常规本地联系人搜索
    final users = _searchDataSource.searchLocalContacts(query);
    results.addAll(
      users.take(limit).map((user) {
        final contact = _mapUserToContact(user);
        return SearchResultItem.fromContact(contact, matchedKeyword: query);
      }),
    );

    return results.take(limit).toList();
  }

  /// 检查查询是否为 ENS 域名格式
  bool _isEnsQuery(String query) {
    final lower = query.toLowerCase().trim();
    const ensSuffixes = [
      '.eth',
      '.n42',
      '.xyz',
      '.app',
      '.luxe',
      '.kred',
      '.art',
    ];
    return ensSuffixes.any((suffix) => lower.endsWith(suffix));
  }

  @override
  Future<List<SearchResultItem>> searchGroups(
    String query, {
    int limit = 20,
  }) async {
    final rooms = _searchDataSource.searchLocalGroups(query);

    return rooms.take(limit).map((room) {
      final conversation = _mapRoomToConversation(room);
      return SearchResultItem.fromConversation(
        conversation,
        matchedKeyword: query,
      );
    }).toList();
  }

  @override
  Future<List<SearchResultItem>> searchConversations(
    String query, {
    int limit = 20,
  }) async {
    final rooms = _searchDataSource.searchLocalConversations(query);

    return rooms.take(limit).map((room) {
      final conversation = _mapRoomToConversation(room);
      return SearchResultItem.fromConversation(
        conversation,
        matchedKeyword: query,
      );
    }).toList();
  }

  @override
  Future<List<SearchResultItem>> searchMessages(
    String query, {
    int limit = 50,
    String? roomId,
    MessageSearchFilter? filter,
  }) async {
    if (roomId != null) {
      // 在指定房间搜索
      final events = filter == null || filter.isEmpty
          ? await _searchDataSource.searchMessagesInRoom(
              roomId,
              query,
              limit: limit,
            )
          : await _searchDataSource.searchMessagesInRoom(
              roomId,
              query,
              filter: filter,
              limit: limit,
            );

      final room = _clientManager.client?.getRoomById(roomId);
      final roomName = room?.getLocalizedDisplayname() ?? '未知会话';
      final roomAvatar = _getRoomAvatarUrl(room);

      return events.map((event) {
        final message = _mapEventToMessage(event);
        return SearchResultItem.fromMessage(
          message,
          roomId: roomId,
          roomName: roomName,
          roomAvatarUrl: roomAvatar,
          matchedKeyword: query,
        );
      }).toList();
    } else {
      // 全局搜索消息
      final results = filter == null || filter.isEmpty
          ? await _searchDataSource.searchMessagesGlobally(query, limit: limit)
          : await _searchDataSource.searchMessagesGlobally(
              query,
              filter: filter,
              limit: limit,
            );

      return results.map((result) {
        final message = _mapEventToMessage(result.event);
        final roomAvatar = _getRoomAvatarUrl(result.room);

        return SearchResultItem.fromMessage(
          message,
          roomId: result.room.id,
          roomName: result.room.getLocalizedDisplayname(),
          roomAvatarUrl: roomAvatar,
          matchedKeyword: query,
        );
      }).toList();
    }
  }

  @override
  Future<ChatSearchResults> searchInChat(
    String roomId,
    String query, {
    MessageSearchFilter? filter,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      return ChatSearchResults(roomId: roomId);
    }

    final events = filter == null || filter.isEmpty
        ? await _searchDataSource.searchMessagesInRoom(
            roomId,
            query,
            limit: limit,
          )
        : await _searchDataSource.searchMessagesInRoom(
            roomId,
            query,
            filter: filter,
            limit: limit,
          );

    final messages = events.map(_mapEventToMessage).toList();

    return ChatSearchResults(
      messages: messages,
      query: query,
      roomId: roomId,
      currentIndex: messages.isNotEmpty ? 0 : -1,
      hasMore: messages.length >= limit,
      filter: filter == null || filter.isEmpty ? null : filter,
    );
  }

  @override
  Future<ChatSearchResults> loadMoreChatSearchResults(
    ChatSearchResults currentResults, {
    int limit = 50,
  }) async {
    // 加载更多结果
    final filter = currentResults.filter;
    final events = filter == null || filter.isEmpty
        ? await _searchDataSource.searchMessagesInRoom(
            currentResults.roomId,
            currentResults.query,
            limit: currentResults.messages.length + limit,
          )
        : await _searchDataSource.searchMessagesInRoom(
            currentResults.roomId,
            currentResults.query,
            filter: filter,
            limit: currentResults.messages.length + limit,
          );

    final messages = events.map(_mapEventToMessage).toList();

    return currentResults.copyWith(
      messages: messages,
      hasMore: messages.length >= currentResults.messages.length + limit,
    );
  }

  @override
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    return _searchDataSource.getRecentSearches(limit: limit);
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    await _searchDataSource.saveSearchQuery(query.trim());
  }

  @override
  Future<void> deleteSearchQuery(String query) async {
    await _searchDataSource.deleteSearchQuery(query);
  }

  @override
  Future<void> clearSearchHistory() async {
    await _searchDataSource.clearSearchHistory();
  }

  // ============================================
  // 辅助方法
  // ============================================

  ContactEntity _mapUserToContact(matrix.User user) {
    String? avatarUrl;
    final client = _clientManager.client;
    if (user.avatarUrl != null && client != null) {
      avatarUrl = MatrixUtils.getAvatarUrl(
        user.avatarUrl,
        client: client,
        size: 96,
      );
    }

    return ContactEntity(
      userId: user.id,
      displayName: user.calcDisplayname(),
      avatarUrl: avatarUrl,
    );
  }

  ConversationEntity _mapRoomToConversation(matrix.Room room) {
    final avatarUrl = _getRoomAvatarUrl(room);
    final lastEvent = room.lastEvent;

    return ConversationEntity(
      id: room.id,
      name: room.getLocalizedDisplayname(),
      avatarUrl: avatarUrl,
      lastMessage: lastEvent?.body,
      lastMessageTime: lastEvent?.originServerTs,
      unreadCount: room.notificationCount,
      type: room.isDirectChat
          ? ConversationType.direct
          : ConversationType.group,
      memberCount: room.summary.mJoinedMemberCount ?? 0,
    );
  }

  MessageEntity _mapEventToMessage(matrix.Event event) {
    return MessageEntity(
      id: event.eventId,
      roomId: event.roomId ?? '',
      senderId: event.senderId,
      senderName: event.senderFromMemoryOrFallback.calcDisplayname(),
      content: event.body,
      timestamp: event.originServerTs,
      type: _mapMessageType(event.messageType),
      status: MessageStatus.sent,
    );
  }

  MessageType _mapMessageType(String? msgType) {
    switch (msgType) {
      case matrix.MessageTypes.Text:
        return MessageType.text;
      case matrix.MessageTypes.Image:
        return MessageType.image;
      case matrix.MessageTypes.Video:
        return MessageType.video;
      case matrix.MessageTypes.Audio:
        return MessageType.audio;
      case matrix.MessageTypes.File:
        return MessageType.file;
      case matrix.MessageTypes.Location:
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }

  String? _getRoomAvatarUrl(matrix.Room? room) {
    if (room == null) return null;
    final client = _clientManager.client;
    return MatrixUtils.getAvatarUrl(room.avatar, client: client, size: 96);
  }
}

/// 消息搜索结果
class MessageSearchResult {
  final matrix.Event event;
  final matrix.Room room;

  MessageSearchResult({required this.event, required this.room});
}
