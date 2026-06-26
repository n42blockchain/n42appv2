import '../entities/search_result_entity.dart';

/// 搜索仓库接口
abstract class ISearchRepository {
  // ============================================
  // 全局搜索
  // ============================================

  /// 全局搜索（联系人、群聊、消息）
  Future<SearchResults> searchGlobal(
    String query, {
    SearchResultType? type,
    MessageSearchFilter? filter,
    int limit = 50,
  });

  /// 搜索联系人
  Future<List<SearchResultItem>> searchContacts(String query, {int limit = 20});

  /// 搜索群聊
  Future<List<SearchResultItem>> searchGroups(String query, {int limit = 20});

  /// 搜索会话
  Future<List<SearchResultItem>> searchConversations(
    String query, {
    int limit = 20,
  });

  /// 搜索消息
  Future<List<SearchResultItem>> searchMessages(
    String query, {
    int limit = 50,
    String? roomId,
    MessageSearchFilter? filter,
  });

  // ============================================
  // 聊天内搜索
  // ============================================

  /// 在指定聊天室内搜索消息
  Future<ChatSearchResults> searchInChat(
    String roomId,
    String query, {
    MessageSearchFilter? filter,
    int limit = 50,
  });

  /// 加载更多聊天内搜索结果
  Future<ChatSearchResults> loadMoreChatSearchResults(
    ChatSearchResults currentResults, {
    int limit = 50,
  });

  // ============================================
  // 搜索历史
  // ============================================

  /// 获取最近搜索记录
  Future<List<String>> getRecentSearches({int limit = 10});

  /// 保存搜索记录
  Future<void> saveSearchQuery(String query);

  /// 删除搜索记录
  Future<void> deleteSearchQuery(String query);

  /// 清除所有搜索历史
  Future<void> clearSearchHistory();
}
