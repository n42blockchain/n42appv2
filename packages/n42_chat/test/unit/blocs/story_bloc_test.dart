import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/story_entity.dart';
import 'package:n42_chat/src/domain/repositories/story_repository.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_event.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_state.dart';

class MockStoryRepository extends Mock implements IStoryRepository {}

StoryEntity _makeStory({String id = 's-1', bool isViewed = false}) {
  final now = DateTime(2025, 6, 1, 12);
  return StoryEntity(
    id: id,
    eventId: '\$$id:s',
    userId: '@alice:s',
    userName: 'Alice',
    content: 'My story',
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
    isViewed: isViewed,
  );
}

UserStories _makeUserStories({
  String userId = '@alice:s',
  List<StoryEntity>? stories,
}) {
  return UserStories(
    userId: userId,
    userName: 'Alice',
    stories: stories ?? [_makeStory()],
    lastUpdated: DateTime(2025, 6, 1, 12),
  );
}

void main() {
  late MockStoryRepository mockRepo;

  setUp(() {
    mockRepo = MockStoryRepository();
  });

  StoryBloc buildBloc() => StoryBloc(mockRepo);

  group('initial state', () {
    test('is StoryState.initial()', () {
      final bloc = buildBloc();
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.isPosting, isFalse);
      expect(bloc.state.userStories, isEmpty);
      expect(bloc.state.myStories, isEmpty);
      expect(bloc.state.isEmpty, isTrue);
    });
  });

  group('LoadStories', () {
    blocTest<StoryBloc, StoryState>(
      'emits loading → loaded on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getStories(),
        ).thenAnswer((_) async => [_makeUserStories()]);
        when(
          () => mockRepo.getMyStories(),
        ).thenAnswer((_) async => [_makeStory(id: 'mine')]);
      },
      act: (bloc) => bloc.add(const LoadStories()),
      expect: () => [
        isA<StoryState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StoryState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.userStories.length, 'userStories.length', 1)
            .having((s) => s.myStories.length, 'myStories.length', 1),
      ],
    );

    blocTest<StoryBloc, StoryState>(
      'emits loading → error on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getStories(),
        ).thenThrow(Exception('Failed to load'));
        when(() => mockRepo.getMyStories()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const LoadStories()),
      expect: () => [
        isA<StoryState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StoryState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );

    blocTest<StoryBloc, StoryState>(
      'skips when already loading',
      build: buildBloc,
      seed: () => const StoryState(isLoading: true),
      setUp: () {
        when(() => mockRepo.getStories()).thenAnswer((_) async => []);
        when(() => mockRepo.getMyStories()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const LoadStories()),
      expect: () => <StoryState>[],
    );
  });

  group('PostStory', () {
    blocTest<StoryBloc, StoryState>(
      'emits posting → calls LoadStories on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.postStory(
            content: any(named: 'content'),
            media: any(named: 'media'),
            backgroundColor: any(named: 'backgroundColor'),
            textColor: any(named: 'textColor'),
          ),
        ).thenAnswer((_) async => _makeStory(id: 'new-story'));
        when(
          () => mockRepo.getStories(),
        ).thenAnswer((_) async => [_makeUserStories()]);
        when(
          () => mockRepo.getMyStories(),
        ).thenAnswer((_) async => [_makeStory(id: 'new-story')]);
      },
      act: (bloc) => bloc.add(const PostStory(content: 'Hello, Stories!')),
      expect: () => [
        isA<StoryState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<StoryState>().having((s) => s.isPosting, 'isPosting', isFalse),
        // Then LoadStories triggers: loading state
        isA<StoryState>().having((s) => s.isLoading, 'isLoading', isTrue),
        // Then LoadStories completes: loaded state
        isA<StoryState>().having((s) => s.isLoading, 'isLoading', isFalse),
      ],
    );

    blocTest<StoryBloc, StoryState>(
      'emits posting → error when postStory throws',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.postStory(
            content: any(named: 'content'),
            media: any(named: 'media'),
            backgroundColor: any(named: 'backgroundColor'),
            textColor: any(named: 'textColor'),
          ),
        ).thenThrow(Exception('Upload failed'));
      },
      act: (bloc) => bloc.add(const PostStory(content: 'Test')),
      expect: () => [
        isA<StoryState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<StoryState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );

    blocTest<StoryBloc, StoryState>(
      'emits error when postStory returns null',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.postStory(
            content: any(named: 'content'),
            media: any(named: 'media'),
            backgroundColor: any(named: 'backgroundColor'),
            textColor: any(named: 'textColor'),
          ),
        ).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const PostStory(content: 'Test')),
      expect: () => [
        isA<StoryState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<StoryState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );
  });

  group('DeleteStory', () {
    blocTest<StoryBloc, StoryState>(
      'calls deleteStory then reloads on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.deleteStory(any())).thenAnswer((_) async {});
        when(() => mockRepo.getStories()).thenAnswer((_) async => []);
        when(() => mockRepo.getMyStories()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const DeleteStory('s-1')),
      expect: () => [
        isA<StoryState>()
            .having(
              (s) => s.deleteActionVersion,
              'deleteActionVersion',
              1,
            )
            .having(
              (s) => s.deleteActionStoryId,
              'deleteActionStoryId',
              's-1',
            )
            .having(
              (s) => s.deleteActionStatus,
              'deleteActionStatus',
              StoryDeleteActionStatus.success,
            ),
        isA<StoryState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StoryState>().having((s) => s.isLoading, 'isLoading', isFalse),
      ],
      verify: (_) {
        verify(() => mockRepo.deleteStory('s-1')).called(1);
      },
    );

    blocTest<StoryBloc, StoryState>(
      'emits error when deleteStory throws',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.deleteStory(any()),
        ).thenThrow(Exception('Cannot delete'));
      },
      act: (bloc) => bloc.add(const DeleteStory('s-1')),
      expect: () => [
        isA<StoryState>()
            .having((s) => s.hasError, 'hasError', isTrue)
            .having(
              (s) => s.deleteActionVersion,
              'deleteActionVersion',
              1,
            )
            .having(
              (s) => s.deleteActionStoryId,
              'deleteActionStoryId',
              's-1',
            )
            .having(
              (s) => s.deleteActionStatus,
              'deleteActionStatus',
              StoryDeleteActionStatus.failure,
            ),
      ],
    );
  });

  group('ViewStory', () {
    blocTest<StoryBloc, StoryState>(
      'marks story as viewed optimistically',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.recordView(any())).thenAnswer((_) async {});
      },
      seed: () => StoryState(
        userStories: [
          _makeUserStories(stories: [_makeStory(id: 's-1', isViewed: false)]),
        ],
      ),
      act: (bloc) => bloc.add(const ViewStory('s-1')),
      expect: () => [
        isA<StoryState>().having(
          (s) => s.userStories.first.stories.first.isViewed,
          'story.isViewed',
          isTrue,
        ),
      ],
    );

    blocTest<StoryBloc, StoryState>(
      'emits error when recordView throws but does not block UX',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.recordView(any()),
        ).thenThrow(Exception('Network error'));
      },
      seed: () => StoryState(userStories: [_makeUserStories()]),
      act: (bloc) => bloc.add(const ViewStory('s-1')),
      expect: () => [
        isA<StoryState>().having((s) => s.hasError, 'hasError', isTrue),
      ],
    );
  });

  group('StoriesUpdated', () {
    blocTest<StoryBloc, StoryState>(
      'updates userStories list',
      build: buildBloc,
      act: (bloc) => bloc.add(StoriesUpdated([_makeUserStories()])),
      expect: () => [
        isA<StoryState>().having(
          (s) => s.userStories.length,
          'userStories.length',
          1,
        ),
      ],
    );

    blocTest<StoryBloc, StoryState>(
      'keeps myStories in sync when currentUserId is known',
      build: buildBloc,
      seed: () => StoryState(
        currentUserId: '@alice:s',
        myStories: [_makeStory(id: 'old-mine')],
      ),
      act: (bloc) => bloc.add(
        StoriesUpdated([
          _makeUserStories(
            userId: '@alice:s',
            stories: [_makeStory(id: 'fresh-mine')],
          ),
        ]),
      ),
      expect: () => [
        isA<StoryState>()
            .having((s) => s.userStories.length, 'userStories.length', 1)
            .having(
              (s) => s.myStories.map((story) => story.id).toList(),
              'myStories.ids',
              ['fresh-mine'],
            ),
      ],
    );
  });
}
