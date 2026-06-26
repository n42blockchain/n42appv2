import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/story_entity.dart';
import '../../../domain/repositories/story_repository.dart';
import 'story_event.dart';
import 'story_state.dart';

/// Story Bloc
///
/// 管理 Story（24小时状态动态）相关的业务逻辑
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final IStoryRepository _storyRepository;

  StreamSubscription<List<UserStories>>? _storiesSubscription;

  StoryBloc(this._storyRepository) : super(StoryState.initial()) {
    on<LoadStories>(_onLoadStories);
    on<SubscribeStories>(_onSubscribeStories);
    on<UnsubscribeStories>(_onUnsubscribeStories);
    on<PostStory>(_onPostStory);
    on<DeleteStory>(_onDeleteStory);
    on<ViewStory>(_onViewStory);
    on<StoriesUpdated>(_onStoriesUpdated);
  }

  @override
  Future<void> close() {
    _storiesSubscription?.cancel();
    return super.close();
  }

  /// 加载所有 Stories
  Future<void> _onLoadStories(
    LoadStories event,
    Emitter<StoryState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final userStories = await _storyRepository.getStories();
      final myStories = await _storyRepository.getMyStories();

      emit(
        state.copyWith(
          userStories: userStories,
          myStories: myStories,
          isLoading: false,
          currentUserId: myStories.isNotEmpty
              ? myStories.first.userId
              : state.currentUserId,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// 订阅 Story 更新
  Future<void> _onSubscribeStories(
    SubscribeStories event,
    Emitter<StoryState> emit,
  ) async {
    await _storiesSubscription?.cancel();

    _storiesSubscription = _storyRepository.watchStories().listen((
      userStories,
    ) {
      add(StoriesUpdated(userStories));
    });
  }

  /// 取消订阅 Story 更新
  Future<void> _onUnsubscribeStories(
    UnsubscribeStories event,
    Emitter<StoryState> emit,
  ) async {
    await _storiesSubscription?.cancel();
    _storiesSubscription = null;
  }

  /// 发布新 Story
  Future<void> _onPostStory(PostStory event, Emitter<StoryState> emit) async {
    emit(state.copyWith(isPosting: true, clearError: true));

    try {
      // 转换 StoryMediaInput 到 StoryMediaData
      final mediaDataList = event.media
          .map(
            (input) => StoryMediaData(
              bytes: input.bytes,
              filename: input.filename,
              mimeType: input.mimeType,
              type: input.type,
              width: input.width,
              height: input.height,
              duration: input.duration,
            ),
          )
          .toList();

      final story = await _storyRepository.postStory(
        content: event.content,
        media: mediaDataList.isNotEmpty ? mediaDataList : null,
        backgroundColor: event.backgroundColor,
        textColor: event.textColor,
      );

      if (story != null) {
        // 发布成功后重新加载 Stories
        emit(state.copyWith(isPosting: false));
        add(const LoadStories());
      } else {
        emit(state.copyWith(isPosting: false, error: 'Failed to post story'));
      }
    } catch (e) {
      emit(state.copyWith(isPosting: false, error: e.toString()));
    }
  }

  /// 删除 Story
  Future<void> _onDeleteStory(
    DeleteStory event,
    Emitter<StoryState> emit,
  ) async {
    try {
      await _storyRepository.deleteStory(event.storyId);

      emit(
        state.copyWith(
          clearError: true,
          deleteActionVersion: state.deleteActionVersion + 1,
          deleteActionStoryId: event.storyId,
          deleteActionStatus: StoryDeleteActionStatus.success,
        ),
      );

      // 删除成功后重新加载 Stories
      add(const LoadStories());
    } catch (e) {
      emit(
        state.copyWith(
          error: e.toString(),
          deleteActionVersion: state.deleteActionVersion + 1,
          deleteActionStoryId: event.storyId,
          deleteActionStatus: StoryDeleteActionStatus.failure,
        ),
      );
    }
  }

  /// 记录查看 Story
  Future<void> _onViewStory(ViewStory event, Emitter<StoryState> emit) async {
    try {
      await _storyRepository.recordView(event.storyId);

      // 乐观更新：将该 Story 标记为已查看
      final updatedUserStories = state.userStories.map((userStory) {
        final updatedStories = userStory.stories.map((story) {
          if (story.id == event.storyId) {
            return story.copyWith(isViewed: true);
          }
          return story;
        }).toList();

        return userStory.copyWith(stories: updatedStories);
      }).toList();

      emit(state.copyWith(userStories: updatedUserStories));
    } catch (e) {
      // 记录查看失败不阻塞用户体验，仅记录错误
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Stories 更新（来自订阅）
  void _onStoriesUpdated(StoriesUpdated event, Emitter<StoryState> emit) {
    final myStories = state.currentUserId == null
        ? state.myStories
        : event.userStories
              .where((userStory) => userStory.userId == state.currentUserId)
              .expand((userStory) => userStory.stories)
              .toList();

    emit(state.copyWith(userStories: event.userStories, myStories: myStories));
  }
}
