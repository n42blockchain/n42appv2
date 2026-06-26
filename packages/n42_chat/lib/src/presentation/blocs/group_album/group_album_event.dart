import 'package:equatable/equatable.dart';

import '../../../domain/entities/group_album_entity.dart';

/// 群相册事件
abstract class GroupAlbumEvent extends Equatable {
  const GroupAlbumEvent();

  @override
  List<Object?> get props => [];
}

/// 加载群相册
class LoadGroupAlbum extends GroupAlbumEvent {
  final String roomId;
  final int limit;

  const LoadGroupAlbum({
    required this.roomId,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [roomId, limit];
}

/// 加载更多
class LoadMoreAlbum extends GroupAlbumEvent {
  const LoadMoreAlbum();
}

/// 更改筛选器
class ChangeAlbumFilter extends GroupAlbumEvent {
  final AlbumFilter filter;

  const ChangeAlbumFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// 刷新相册
class RefreshGroupAlbum extends GroupAlbumEvent {
  const RefreshGroupAlbum();
}
