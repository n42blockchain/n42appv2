import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/group_album_entity.dart';
import '../../../domain/repositories/message_repository.dart';
import 'group_album_event.dart';
import 'group_album_state.dart';
import '../../../core/utils/debug_log.dart';

/// 群相册 BLoC
class GroupAlbumBloc extends Bloc<GroupAlbumEvent, GroupAlbumState> {
  final IMessageRepository _messageRepository;

  GroupAlbumBloc({
    required IMessageRepository messageRepository,
  })  : _messageRepository = messageRepository,
        super(GroupAlbumState.initial()) {
    on<LoadGroupAlbum>(_onLoadGroupAlbum);
    on<LoadMoreAlbum>(_onLoadMoreAlbum);
    on<ChangeAlbumFilter>(_onChangeAlbumFilter);
    on<RefreshGroupAlbum>(_onRefreshGroupAlbum);
  }

  Future<void> _onLoadGroupAlbum(
    LoadGroupAlbum event,
    Emitter<GroupAlbumState> emit,
  ) async {
    emit(state.copyWith(
      roomId: event.roomId,
      isLoading: true,
      clearError: true,
    ));

    try {
      final media = await _messageRepository.getRoomMedia(
        event.roomId,
        limit: event.limit,
      );

      final dateGroups = AlbumDateGroup.groupByDate(media);
      final stats = GroupAlbumStats.fromMedia(media);

      emit(state.copyWith(
        media: media,
        dateGroups: dateGroups,
        stats: stats,
        isLoading: false,
        hasMore: media.length >= event.limit,
      ));

      debugLog('GroupAlbumBloc: Loaded ${media.length} media items');
    } catch (e) {
      debugLog('GroupAlbumBloc: Failed to load album: $e');
      emit(state.copyWith(
        media: [],
        dateGroups: [],
        stats: const GroupAlbumStats(),
        isLoading: false,
        hasMore: false,
        error: 'Failed to load album',
      ));
    }
  }

  Future<void> _onLoadMoreAlbum(
    LoadMoreAlbum event,
    Emitter<GroupAlbumState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.roomId == null) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      // 使用最后一条媒体的 eventId 进行分页
      final lastEventId = state.media.isNotEmpty ? state.media.last.eventId : null;

      final moreMedia = await _messageRepository.getRoomMedia(
        state.roomId!,
        limit: 50,
        beforeEventId: lastEventId,
      );

      if (moreMedia.isEmpty) {
        emit(state.copyWith(isLoadingMore: false, hasMore: false));
        return;
      }

      final allMedia = [...state.media, ...moreMedia];
      final dateGroups = AlbumDateGroup.groupByDate(allMedia);
      final stats = GroupAlbumStats.fromMedia(allMedia);

      emit(state.copyWith(
        media: allMedia,
        dateGroups: dateGroups,
        stats: stats,
        isLoadingMore: false,
        hasMore: moreMedia.length >= 50,
      ));

      debugLog('GroupAlbumBloc: Loaded ${moreMedia.length} more media items, total: ${allMedia.length}');
    } catch (e) {
      debugLog('GroupAlbumBloc: Failed to load more: $e');
      emit(state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more',
      ));
    }
  }

  void _onChangeAlbumFilter(
    ChangeAlbumFilter event,
    Emitter<GroupAlbumState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onRefreshGroupAlbum(
    RefreshGroupAlbum event,
    Emitter<GroupAlbumState> emit,
  ) async {
    if (state.roomId == null) return;
    add(LoadGroupAlbum(roomId: state.roomId!));
  }
}
