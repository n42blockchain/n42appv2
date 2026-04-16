import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/domain/repositories/moment_repository.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_event.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';

class MockMomentRepository extends Mock implements IMomentRepository {}

MomentEntity _makeMoment({String id = 'm-1', bool isFromMe = false}) {
  return MomentEntity(
    id: id,
    userId: '@alice:s',
    userName: 'Alice',
    content: 'Test moment',
    timestamp: DateTime(2025, 6, 1),
    isFromMe: isFromMe,
  );
}

void main() {
  late MockMomentRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(MomentVisibility.public);
    registerFallbackValue(const <String>[]);
  });

  setUp(() {
    mockRepo = MockMomentRepository();
  });

  MomentBloc buildBloc() => MomentBloc(mockRepo);

  group('initial state', () {
    test('is MomentState.initial()', () {
      final bloc = buildBloc();
      expect(bloc.state.moments, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.hasError, isFalse);
    });
  });

  group('LoadMoments', () {
    blocTest<MomentBloc, MomentState>(
      'emits loading → loaded on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getMoments(limit: any(named: 'limit')),
        ).thenAnswer((_) async => [_makeMoment()]);
        when(() => mockRepo.getUnreadMomentCount()).thenAnswer((_) async => 3);
      },
      act: (bloc) => bloc.add(const LoadMoments()),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.moments.length, 'moments.length', 1)
            .having((s) => s.unreadCount, 'unreadCount', 3),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'emits loading → error on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getMoments(limit: any(named: 'limit')),
        ).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const LoadMoments()),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'skips when already loading',
      build: buildBloc,
      seed: () => MomentState.loading(),
      setUp: () {
        when(
          () => mockRepo.getMoments(limit: any(named: 'limit')),
        ).thenAnswer((_) async => []);
        when(() => mockRepo.getUnreadMomentCount()).thenAnswer((_) async => 0);
      },
      act: (bloc) => bloc.add(const LoadMoments()),
      expect: () => <MomentState>[],
    );
  });

  group('PostTextMoment', () {
    blocTest<MomentBloc, MomentState>(
      'emits posting → moment prepended on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.postTextMoment(
            content: any(named: 'content'),
            location: any(named: 'location'),
            visibility: any(named: 'visibility'),
            visibilityUserIds: any(named: 'visibilityUserIds'),
          ),
        ).thenAnswer((_) async => _makeMoment(id: 'new-1', isFromMe: true));
        when(() => mockRepo.getUnreadMomentCount()).thenAnswer((_) async => 0);
      },
      act: (bloc) => bloc.add(const PostTextMoment(content: 'Hello world!')),
      expect: () => [
        isA<MomentState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<MomentState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.moments.first.id, 'moments.first.id', 'new-1'),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'clears stale error before a successful post completes',
      build: buildBloc,
      seed: () => const MomentState(errorMessage: 'old error'),
      setUp: () {
        when(
          () => mockRepo.postTextMoment(
            content: any(named: 'content'),
            location: any(named: 'location'),
            visibility: any(named: 'visibility'),
            visibilityUserIds: any(named: 'visibilityUserIds'),
          ),
        ).thenAnswer((_) async => _makeMoment(id: 'new-2', isFromMe: true));
      },
      act: (bloc) => bloc.add(const PostTextMoment(content: 'Retry post')),
      expect: () => [
        isA<MomentState>()
            .having((s) => s.isPosting, 'isPosting', isTrue)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<MomentState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', isNull)
            .having((s) => s.moments.first.id, 'moments.first.id', 'new-2'),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'emits posting → error on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.postTextMoment(
            content: any(named: 'content'),
            location: any(named: 'location'),
            visibility: any(named: 'visibility'),
            visibilityUserIds: any(named: 'visibilityUserIds'),
          ),
        ).thenThrow(Exception('Upload failed'));
        when(() => mockRepo.getUnreadMomentCount()).thenAnswer((_) async => 0);
      },
      act: (bloc) => bloc.add(const PostTextMoment(content: 'Hello!')),
      expect: () => [
        isA<MomentState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<MomentState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );
  });

  group('DeleteMoment', () {
    blocTest<MomentBloc, MomentState>(
      'emits updated moments list on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.deleteMoment(any())).thenAnswer((_) async {});
      },
      seed: () => MomentState(moments: [_makeMoment(id: 'm-1')]),
      act: (bloc) => bloc.add(const DeleteMoment('m-1')),
      expect: () => [
        isA<MomentState>()
            .having(
              (s) => s.moments.any((m) => m.id == 'm-1'),
              'moment removed',
              isFalse,
            )
            .having(
              (s) => s.deleteActionVersion,
              'deleteActionVersion',
              1,
            )
            .having(
              (s) => s.deleteActionMomentId,
              'deleteActionMomentId',
              'm-1',
            )
            .having(
              (s) => s.deleteActionStatus,
              'deleteActionStatus',
              MomentDeleteActionStatus.success,
            ),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'emits error on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.deleteMoment(any()),
        ).thenThrow(Exception('Cannot delete'));
      },
      seed: () => MomentState(moments: [_makeMoment(id: 'm-1')]),
      act: (bloc) => bloc.add(const DeleteMoment('m-1')),
      expect: () => [
        isA<MomentState>()
            .having((s) => s.hasError, 'hasError', isTrue)
            .having(
              (s) => s.deleteActionVersion,
              'deleteActionVersion',
              1,
            )
            .having(
              (s) => s.deleteActionMomentId,
              'deleteActionMomentId',
              'm-1',
            )
            .having(
              (s) => s.deleteActionStatus,
              'deleteActionStatus',
              MomentDeleteActionStatus.failure,
            ),
      ],
    );
  });

  group('LikeMoment / UnlikeMoment', () {
    blocTest<MomentBloc, MomentState>(
      'LikeMoment succeeds without error',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.likeMoment(any())).thenAnswer((_) async {});
      },
      seed: () => MomentState(moments: [_makeMoment(id: 'm-1')]),
      act: (bloc) => bloc.add(const LikeMoment('m-1')),
      // The bloc optimistically toggles like; we just check no error state
      verify: (_) {
        verify(() => mockRepo.likeMoment('m-1')).called(1);
      },
    );

    blocTest<MomentBloc, MomentState>(
      'UnlikeMoment calls repository',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.unlikeMoment(any())).thenAnswer((_) async {});
      },
      seed: () => MomentState(moments: [_makeMoment(id: 'm-1')]),
      act: (bloc) => bloc.add(const UnlikeMoment('m-1')),
      verify: (_) {
        verify(() => mockRepo.unlikeMoment('m-1')).called(1);
      },
    );
  });

  group('MarkMomentsAsRead', () {
    blocTest<MomentBloc, MomentState>(
      'calls repository and clears unread count',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.markMomentsAsRead()).thenAnswer((_) async {});
      },
      seed: () => const MomentState(unreadCount: 5),
      act: (bloc) => bloc.add(const MarkMomentsAsRead()),
      expect: () => [
        isA<MomentState>().having((s) => s.unreadCount, 'unreadCount', 0),
      ],
    );
  });
}
