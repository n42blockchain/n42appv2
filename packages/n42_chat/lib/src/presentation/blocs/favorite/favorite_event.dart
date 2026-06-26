import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

/// 加载收藏列表
class LoadFavorites extends FavoriteEvent {
  final String? filterType;

  const LoadFavorites({this.filterType});

  @override
  List<Object?> get props => [filterType];
}

/// 搜索收藏
class SearchFavorites extends FavoriteEvent {
  final String query;

  const SearchFavorites(this.query);

  @override
  List<Object?> get props => [query];
}

/// 删除收藏
class DeleteFavorite extends FavoriteEvent {
  final String favoriteId;

  const DeleteFavorite(this.favoriteId);

  @override
  List<Object?> get props => [favoriteId];
}

/// 修改收藏标签
class EditFavoriteTags extends FavoriteEvent {
  final String favoriteId;
  final List<String> tags;

  const EditFavoriteTags({
    required this.favoriteId,
    required this.tags,
  });

  @override
  List<Object?> get props => [favoriteId, tags];
}

/// 修改收藏备注
class EditFavoriteRemark extends FavoriteEvent {
  final String favoriteId;
  final String remark;

  const EditFavoriteRemark({
    required this.favoriteId,
    required this.remark,
  });

  @override
  List<Object?> get props => [favoriteId, remark];
}

/// 筛选类型变更
class ChangeFavoriteFilter extends FavoriteEvent {
  final String? filterType;

  const ChangeFavoriteFilter(this.filterType);

  @override
  List<Object?> get props => [filterType];
}
