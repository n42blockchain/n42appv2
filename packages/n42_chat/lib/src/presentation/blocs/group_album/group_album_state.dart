import 'package:equatable/equatable.dart';

import '../../../domain/entities/group_album_entity.dart';

/// 群相册状态
class GroupAlbumState extends Equatable {
  /// 房间 ID
  final String? roomId;

  /// 媒体列表
  final List<AlbumMediaEntity> media;

  /// 日期分组
  final List<AlbumDateGroup> dateGroups;

  /// 统计信息
  final GroupAlbumStats stats;

  /// 筛选器
  final AlbumFilter filter;

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 是否还有更多
  final bool hasMore;

  /// 错误信息
  final String? error;

  const GroupAlbumState({
    this.roomId,
    this.media = const [],
    this.dateGroups = const [],
    this.stats = const GroupAlbumStats(),
    this.filter = const AlbumFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  /// 初始状态
  factory GroupAlbumState.initial() => const GroupAlbumState(isLoading: true);

  /// 是否为空
  bool get isEmpty => media.isEmpty;

  /// 筛选后的媒体列表
  List<AlbumMediaEntity> get filteredMedia => filter.apply(media);

  /// 筛选后的日期分组
  List<AlbumDateGroup> get filteredDateGroups =>
      AlbumDateGroup.groupByDate(filteredMedia);

  GroupAlbumState copyWith({
    String? roomId,
    List<AlbumMediaEntity>? media,
    List<AlbumDateGroup>? dateGroups,
    GroupAlbumStats? stats,
    AlbumFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return GroupAlbumState(
      roomId: roomId ?? this.roomId,
      media: media ?? this.media,
      dateGroups: dateGroups ?? this.dateGroups,
      stats: stats ?? this.stats,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        roomId,
        media,
        dateGroups,
        stats,
        filter,
        isLoading,
        isLoadingMore,
        hasMore,
        error,
      ];
}
