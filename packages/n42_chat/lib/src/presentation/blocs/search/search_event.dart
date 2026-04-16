import 'package:equatable/equatable.dart';

import '../../../domain/entities/search_result_entity.dart';

/// 搜索事件基类
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// 执行全局搜索
class PerformSearch extends SearchEvent {
  final String query;
  final SearchResultType? type;
  final MessageSearchFilter? filter;

  const PerformSearch(this.query, {this.type, this.filter});

  @override
  List<Object?> get props => [query, type, filter];
}

/// 搜索联系人
class SearchContacts extends SearchEvent {
  final String query;

  const SearchContacts(this.query);

  @override
  List<Object?> get props => [query];
}

/// 搜索群聊
class SearchGroups extends SearchEvent {
  final String query;

  const SearchGroups(this.query);

  @override
  List<Object?> get props => [query];
}

/// 搜索消息
class SearchMessages extends SearchEvent {
  final String query;
  final String? roomId;
  final MessageSearchFilter? filter;

  const SearchMessages(this.query, {this.roomId, this.filter});

  @override
  List<Object?> get props => [query, roomId, filter];
}

/// 清除搜索
class ClearSearch extends SearchEvent {
  const ClearSearch();
}

/// 加载搜索历史
class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

/// 删除搜索历史项
class DeleteSearchHistoryItem extends SearchEvent {
  final String query;

  const DeleteSearchHistoryItem(this.query);

  @override
  List<Object?> get props => [query];
}

/// 清除所有搜索历史
class ClearSearchHistory extends SearchEvent {
  const ClearSearchHistory();
}

/// 切换搜索类型
class ChangeSearchType extends SearchEvent {
  final SearchResultType type;

  const ChangeSearchType(this.type);

  @override
  List<Object?> get props => [type];
}

/// 聊天内搜索
class SearchInChat extends SearchEvent {
  final String roomId;
  final String query;
  final MessageSearchFilter? filter;

  const SearchInChat(this.roomId, this.query, {this.filter});

  @override
  List<Object?> get props => [roomId, query, filter];
}

/// 导航到下一个搜索结果
class NavigateToNextResult extends SearchEvent {
  const NavigateToNextResult();
}

/// 导航到上一个搜索结果
class NavigateToPreviousResult extends SearchEvent {
  const NavigateToPreviousResult();
}

/// 导航到指定索引的搜索结果
class NavigateToResultIndex extends SearchEvent {
  final int index;

  const NavigateToResultIndex(this.index);

  @override
  List<Object?> get props => [index];
}

/// 加载更多聊天搜索结果
class LoadMoreChatResults extends SearchEvent {
  const LoadMoreChatResults();
}
