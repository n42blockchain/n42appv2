import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../../domain/repositories/moment_repository.dart';
import 'moment_event.dart';
import 'moment_state.dart';

/// 动态 Bloc
class MomentBloc extends Bloc<MomentEvent, MomentState> {
  final IMomentRepository _momentRepository;

  StreamSubscription<List<MomentEntity>>? _momentsSubscription;

  /// 正在处理中的点赞/取消点赞操作（防止重复请求）
  final Set<String> _pendingLikeOps = {};

  MomentBloc(this._momentRepository) : super(MomentState.initial()) {
    on<LoadMoments>(_onLoadMoments);
    on<LoadMoreMoments>(_onLoadMoreMoments);
    on<LoadUserMoments>(_onLoadUserMoments);
    on<PostTextMoment>(_onPostTextMoment);
    on<PostImageMoment>(_onPostImageMoment);
    on<PostVideoMoment>(_onPostVideoMoment);
    on<DeleteMoment>(_onDeleteMoment);
    on<LikeMoment>(_onLikeMoment);
    on<UnlikeMoment>(_onUnlikeMoment);
    on<CommentMoment>(_onCommentMoment);
    on<DeleteComment>(_onDeleteComment);
    on<RefreshMoments>(_onRefreshMoments);
    on<SubscribeMoments>(_onSubscribeMoments);
    on<UnsubscribeMoments>(_onUnsubscribeMoments);
    on<MomentsUpdated>(_onMomentsUpdated);
    on<MarkMomentsAsRead>(_onMarkMomentsAsRead);
  }

  @override
  Future<void> close() async {
    await _momentsSubscription?.cancel();
    _momentsSubscription = null;
    _pendingLikeOps.clear();
    return super.close();
  }

  /// 加载动态列表
  Future<void> _onLoadMoments(
    LoadMoments event,
    Emitter<MomentState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final moments = await _momentRepository.getMoments(limit: event.limit);

      final unreadCount = await _momentRepository.getUnreadMomentCount();

      emit(
        state.copyWith(
          moments: moments,
          isLoading: false,
          hasMore: moments.length >= event.limit,
          lastMomentId: moments.isNotEmpty ? moments.last.id : null,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// 加载更多动态
  Future<void> _onLoadMoreMoments(
    LoadMoreMoments event,
    Emitter<MomentState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final List<MomentEntity> moreMoments;
      if (event.userId != null) {
        moreMoments = await _momentRepository.getUserMoments(
          event.userId!,
          limit: 20,
          beforeId: state.lastMomentId,
        );
      } else {
        moreMoments = await _momentRepository.getMoments(
          limit: 20,
          beforeId: state.lastMomentId,
        );
      }

      emit(
        state.copyWith(
          moments: [...state.moments, ...moreMoments],
          isLoadingMore: false,
          hasMore: moreMoments.length >= 20,
          lastMomentId: moreMoments.isNotEmpty
              ? moreMoments.last.id
              : state.lastMomentId,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.toString()));
    }
  }

  /// 加载用户动态
  Future<void> _onLoadUserMoments(
    LoadUserMoments event,
    Emitter<MomentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final moments = await _momentRepository.getUserMoments(
        event.userId,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          moments: moments,
          isLoading: false,
          hasMore: moments.length >= event.limit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// 发布纯文字动态
  Future<void> _onPostTextMoment(
    PostTextMoment event,
    Emitter<MomentState> emit,
  ) async {
    emit(
      state.copyWith(isPosting: true, postingProgress: 0.0, clearError: true),
    );

    try {
      final moment = await _momentRepository.postTextMoment(
        content: event.content,
        location: event.location,
        visibility: event.visibility,
        visibilityUserIds: event.visibilityUserIds,
      );

      emit(
        state.copyWith(
          moments: [moment, ...state.moments],
          isPosting: false,
          postingProgress: 1.0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isPosting: false, errorMessage: e.toString()));
    }
  }

  /// 发布图片动态
  Future<void> _onPostImageMoment(
    PostImageMoment event,
    Emitter<MomentState> emit,
  ) async {
    emit(
      state.copyWith(isPosting: true, postingProgress: 0.0, clearError: true),
    );

    try {
      final mediaInputs = event.images
          .map(
            (img) => MomentMediaInput(
              bytes: img.bytes,
              filename: img.filename,
              mimeType: img.mimeType,
              width: img.width,
              height: img.height,
            ),
          )
          .toList();

      final moment = await _momentRepository.postImageMoment(
        content: event.content,
        images: mediaInputs,
        location: event.location,
        visibility: event.visibility,
        visibilityUserIds: event.visibilityUserIds,
      );

      emit(
        state.copyWith(
          moments: [moment, ...state.moments],
          isPosting: false,
          postingProgress: 1.0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isPosting: false, errorMessage: e.toString()));
    }
  }

  /// 发布视频动态
  Future<void> _onPostVideoMoment(
    PostVideoMoment event,
    Emitter<MomentState> emit,
  ) async {
    emit(
      state.copyWith(isPosting: true, postingProgress: 0.0, clearError: true),
    );

    try {
      final videoInput = MomentMediaInput(
        bytes: event.videoBytes,
        filename: event.filename,
        mimeType: event.mimeType,
        width: event.width,
        height: event.height,
        duration: event.duration,
      );

      final moment = await _momentRepository.postVideoMoment(
        content: event.content,
        video: videoInput,
        thumbnailBytes: event.thumbnailBytes,
        location: event.location,
        visibility: event.visibility,
        visibilityUserIds: event.visibilityUserIds,
      );

      emit(
        state.copyWith(
          moments: [moment, ...state.moments],
          isPosting: false,
          postingProgress: 1.0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isPosting: false, errorMessage: e.toString()));
    }
  }

  /// 删除动态
  Future<void> _onDeleteMoment(
    DeleteMoment event,
    Emitter<MomentState> emit,
  ) async {
    try {
      await _momentRepository.deleteMoment(event.momentId);

      emit(
        state.copyWith(
          moments: state.moments.where((m) => m.id != event.momentId).toList(),
          clearError: true,
          deleteActionVersion: state.deleteActionVersion + 1,
          deleteActionMomentId: event.momentId,
          deleteActionStatus: MomentDeleteActionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          deleteActionVersion: state.deleteActionVersion + 1,
          deleteActionMomentId: event.momentId,
          deleteActionStatus: MomentDeleteActionStatus.failure,
        ),
      );
    }
  }

  /// 点赞动态
  Future<void> _onLikeMoment(
    LikeMoment event,
    Emitter<MomentState> emit,
  ) async {
    // 防止重复点赞操作
    if (_pendingLikeOps.contains(event.momentId)) return;
    _pendingLikeOps.add(event.momentId);

    // 乐观更新：同时更新 isLikedByMe 和 likes 列表
    final client = MatrixClientManager.instance.client;
    final currentUserId = client?.userID ?? '';
    // Extract localpart from @user:server format
    final currentUserName = currentUserId.startsWith('@')
        ? currentUserId.substring(1).split(':').first
        : currentUserId;

    final updatedMoments = state.moments.map((m) {
      if (m.id == event.momentId) {
        final alreadyLiked = m.likes.any((l) => l.userId == currentUserId);
        if (alreadyLiked) return m.copyWith(isLikedByMe: true);
        return m.copyWith(
          isLikedByMe: true,
          likes: [
            ...m.likes,
            MomentLike(
              userId: currentUserId,
              userName: currentUserName,
              timestamp: DateTime.now(),
            ),
          ],
        );
      }
      return m;
    }).toList();

    emit(state.copyWith(moments: updatedMoments));

    try {
      await _momentRepository.likeMoment(event.momentId);
    } catch (e) {
      // 回滚
      final revertedMoments = state.moments.map((m) {
        if (m.id == event.momentId) {
          return m.copyWith(
            isLikedByMe: false,
            likes: m.likes.where((l) => l.userId != currentUserId).toList(),
          );
        }
        return m;
      }).toList();

      emit(
        state.copyWith(moments: revertedMoments, errorMessage: e.toString()),
      );
    } finally {
      _pendingLikeOps.remove(event.momentId);
    }
  }

  /// 取消点赞
  Future<void> _onUnlikeMoment(
    UnlikeMoment event,
    Emitter<MomentState> emit,
  ) async {
    // 防止重复操作
    if (_pendingLikeOps.contains(event.momentId)) return;
    _pendingLikeOps.add(event.momentId);

    final currentUserId = MatrixClientManager.instance.client?.userID ?? '';

    // 保存原始 likes 用于回滚
    final originalMoments = state.moments;

    // 乐观更新：同时移除 likes 列表中的当前用户
    final updatedMoments = state.moments.map((m) {
      if (m.id == event.momentId) {
        return m.copyWith(
          isLikedByMe: false,
          likes: m.likes.where((l) => l.userId != currentUserId).toList(),
        );
      }
      return m;
    }).toList();

    emit(state.copyWith(moments: updatedMoments));

    try {
      await _momentRepository.unlikeMoment(event.momentId);
    } catch (e) {
      // 回滚到原始状态（恢复完整的 likes 列表）
      emit(
        state.copyWith(moments: originalMoments, errorMessage: e.toString()),
      );
    } finally {
      _pendingLikeOps.remove(event.momentId);
    }
  }

  /// 评论动态
  Future<void> _onCommentMoment(
    CommentMoment event,
    Emitter<MomentState> emit,
  ) async {
    try {
      final comment = await _momentRepository.commentMoment(
        momentId: event.momentId,
        content: event.content,
        replyToCommentId: event.replyToCommentId,
        replyToUserId: event.replyToUserId,
      );

      // 更新本地状态
      final updatedMoments = state.moments.map((m) {
        if (m.id == event.momentId) {
          return m.addComment(comment);
        }
        return m;
      }).toList();

      emit(
        state.copyWith(
          moments: updatedMoments,
          clearError: true,
          commentSubmissionVersion: state.commentSubmissionVersion + 1,
          commentSubmissionMomentId: event.momentId,
          commentSubmissionStatus: MomentCommentSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          commentSubmissionVersion: state.commentSubmissionVersion + 1,
          commentSubmissionMomentId: event.momentId,
          commentSubmissionStatus: MomentCommentSubmissionStatus.failure,
        ),
      );
    }
  }

  /// 删除评论
  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<MomentState> emit,
  ) async {
    try {
      await _momentRepository.deleteComment(event.momentId, event.commentId);

      // 更新本地状态
      final updatedMoments = state.moments.map((m) {
        if (m.id == event.momentId) {
          return m.removeComment(event.commentId);
        }
        return m;
      }).toList();

      emit(state.copyWith(moments: updatedMoments));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// 刷新动态
  Future<void> _onRefreshMoments(
    RefreshMoments event,
    Emitter<MomentState> emit,
  ) async {
    await _momentRepository.refreshMoments();
    add(const LoadMoments(refresh: true));
  }

  /// 订阅动态更新
  Future<void> _onSubscribeMoments(
    SubscribeMoments event,
    Emitter<MomentState> emit,
  ) async {
    await _momentsSubscription?.cancel();

    _momentsSubscription = _momentRepository.watchMoments().listen((moments) {
      add(MomentsUpdated(moments));
    });
  }

  /// 取消订阅动态更新
  Future<void> _onUnsubscribeMoments(
    UnsubscribeMoments event,
    Emitter<MomentState> emit,
  ) async {
    await _momentsSubscription?.cancel();
    _momentsSubscription = null;
  }

  /// 动态列表更新
  void _onMomentsUpdated(MomentsUpdated event, Emitter<MomentState> emit) {
    emit(state.copyWith(moments: event.moments));
  }

  /// 标记已读
  Future<void> _onMarkMomentsAsRead(
    MarkMomentsAsRead event,
    Emitter<MomentState> emit,
  ) async {
    await _momentRepository.markMomentsAsRead();
    emit(state.copyWith(unreadCount: 0));
  }
}
