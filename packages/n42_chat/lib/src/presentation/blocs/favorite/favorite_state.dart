import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_entity.dart';

class FavoriteState extends Equatable {
  static const _sentinel = Object();
  static final _linkRegExp = RegExp(r'https?://');

  final List<MessageEntity> favorites;
  final String? filterType;
  final String? searchQuery;
  final bool isLoading;
  final String? error;

  const FavoriteState({
    this.favorites = const [],
    this.filterType,
    this.searchQuery,
    this.isLoading = false,
    this.error,
  });

  /// 过滤后的收藏列表
  List<MessageEntity> get filteredFavorites {
    var result = favorites;

    // 按类型筛选
    if (filterType != null) {
      switch (filterType) {
        case 'text':
          result = result.where((f) => f.type == MessageType.text).toList();
          break;
        case 'image':
          result = result.where((f) => f.type == MessageType.image).toList();
          break;
        case 'link':
          result = result
              .where((f) =>
                  f.type == MessageType.text &&
                  f.content.contains(_linkRegExp))
              .toList();
          break;
        case 'file':
          result = result.where((f) => f.type == MessageType.file).toList();
          break;
        case 'video':
          result = result.where((f) => f.type == MessageType.video).toList();
          break;
      }
    }

    // 按搜索词筛选
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      result = result
          .where((f) =>
              f.content.toLowerCase().contains(query) ||
              f.senderName.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  FavoriteState copyWith({
    List<MessageEntity>? favorites,
    Object? filterType = _sentinel,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteState(
      favorites: favorites ?? this.favorites,
      filterType: filterType == _sentinel ? this.filterType : filterType as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [favorites, filterType, searchQuery, isLoading, error];
}
