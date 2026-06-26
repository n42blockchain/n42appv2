import 'package:equatable/equatable.dart';

import '../../../domain/entities/search_result_entity.dart';

/// 搜索状态基类
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// 搜索初始状态
class SearchInitial extends SearchState {
  final List<String> recentSearches;

  const SearchInitial({this.recentSearches = const []});

  @override
  List<Object?> get props => [recentSearches];
}

/// 搜索中
class SearchLoading extends SearchState {
  final String query;
  final SearchResultType? type;

  const SearchLoading(this.query, {this.type});

  @override
  List<Object?> get props => [query, type];
}

/// 搜索完成
class SearchLoaded extends SearchState {
  final SearchResults results;
  final SearchResultType selectedType;
  final List<String> recentSearches;

  const SearchLoaded({
    required this.results,
    this.selectedType = SearchResultType.all,
    this.recentSearches = const [],
  });

  @override
  List<Object?> get props => [results, selectedType, recentSearches];

  SearchLoaded copyWith({
    SearchResults? results,
    SearchResultType? selectedType,
    List<String>? recentSearches,
  }) {
    return SearchLoaded(
      results: results ?? this.results,
      selectedType: selectedType ?? this.selectedType,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  /// 根据当前类型过滤的结果
  List<SearchResultItem> get filteredResults {
    switch (selectedType) {
      case SearchResultType.contact:
        return results.contacts;
      case SearchResultType.group:
        return results.groups;
      case SearchResultType.conversation:
        return results.conversations;
      case SearchResultType.message:
        return results.messages;
      case SearchResultType.all:
        return results.allResults;
    }
  }
}

/// 搜索失败
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 聊天内搜索状态
class ChatSearchState extends SearchState {
  final ChatSearchResults results;
  final bool isSearching;

  const ChatSearchState({
    required this.results,
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [results, isSearching];

  ChatSearchState copyWith({
    ChatSearchResults? results,
    bool? isSearching,
  }) {
    return ChatSearchState(
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

