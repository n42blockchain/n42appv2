// Extended tests for MomentBloc — covers handlers not exercised by
// moment_bloc_test.dart:
//   LoadMoreMoments, LoadUserMoments, PostImageMoment,
//   CommentMoment, DeleteComment, RefreshMoments,
//   MomentsUpdated, SubscribeMoments, UnsubscribeMoments
//
// Uses the same MockMomentRepository pattern but in a separate file to
// keep individual test files focused and avoid naming conflicts.

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/domain/repositories/moment_repository.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_event.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';

class _MockMomentRepository extends Mock implements IMomentRepository {}

MomentEntity _makeMoment({
  String id = 'm-1',
  String userId = '@alice:s',
}) {
  return MomentEntity(
    id: id,
    userId: userId,
    userName: 'Alice',
    content: 'Test moment',
    timestamp: DateTime(2025, 6, 1),
  );
}

MomentComment _makeComment({String id = 'c-1'}) {
  return MomentComment(
    id: id,
    userId: '@alice:s',
    userName: 'Alice',
    content: 'Nice!',
    timestamp: DateTime(2025, 6, 2),
  );
}

void main() {
  late _MockMomentRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(MomentVisibility.public);
    registerFallbackValue(const <String>[]);
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<MomentMediaInput>[]);
    registerFallbackValue(MomentMediaInput(bytes: Uint8List(0), filename: 'f'));
  });

  setUp(() {
    mockRepo = _MockMomentRepository();
  });

  MomentBloc buildBloc() => MomentBloc(mockRepo);

  // ─────────────────────────────────────────────────
  // LoadMoreMoments
  // ─────────────────────────────────────────────────

  group('LoadMoreMoments', () {
    blocTest<MomentBloc, MomentState>(
      'emits isLoadingMore=true → appended moments on success',
      build: buildBloc,
      seed: () => MomentState(
        moments: [_makeMoment(id: 'm-0')],
        hasMore: true,
        lastMomentId: 'm-0',
      ),
      setUp: () {
        when(() => mockRepo.getMoments(
              limit: any(named: 'limit'),
              beforeId: any(named: 'beforeId'),
            )).thenAnswer((_) async => [_makeMoment(id: 'm-1')]);
      },
      act: (bloc) => bloc.add(const LoadMoreMoments()),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.moments.length, 'moments.length', 2)
            .having((s) => s.moments.last.id, 'last moment id', 'm-1'),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'emits error when getMoments throws',
      build: buildBloc,
      seed: () => const MomentState(hasMore: true),
      setUp: () {
        when(() => mockRepo.getMoments(
              limit: any(named: 'limit'),
              beforeId: any(named: 'beforeId'),
            )).thenThrow(Exception('load more error'));
      },
      act: (bloc) => bloc.add(const LoadMoreMoments()),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'skips when hasMore is false',
      build: buildBloc,
      seed: () => const MomentState(hasMore: false),
      act: (bloc) => bloc.add(const LoadMoreMoments()),
      expect: () => <MomentState>[],
    );

    blocTest<MomentBloc, MomentState>(
      'skips when already loading more',
      build: buildBloc,
      seed: () => const MomentState(hasMore: true, isLoadingMore: true),
      act: (bloc) => bloc.add(const LoadMoreMoments()),
      expect: () => <MomentState>[],
    );

    blocTest<MomentBloc, MomentState>(
      'LoadMoreMoments with userId calls getUserMoments',
      build: buildBloc,
      seed: () => const MomentState(hasMore: true, lastMomentId: 'prev-id'),
      setUp: () {
        when(() => mockRepo.getUserMoments(
              any(),
              limit: any(named: 'limit'),
              beforeId: any(named: 'beforeId'),
            )).thenAnswer((_) async => [_makeMoment(id: 'user-m-1')]);
      },
      act: (bloc) => bloc.add(const LoadMoreMoments(userId: '@bob:s')),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.moments.any((m) => m.id == 'user-m-1'), 'has new moment', isTrue),
      ],
      verify: (_) {
        verify(() => mockRepo.getUserMoments(
              '@bob:s',
              limit: any(named: 'limit'),
              beforeId: any(named: 'beforeId'),
            )).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // LoadUserMoments
  // ─────────────────────────────────────────────────

  group('LoadUserMoments', () {
    blocTest<MomentBloc, MomentState>(
      'emits loading → user moments on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getUserMoments(
              any(),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [
              _makeMoment(id: 'u-1', userId: '@bob:s'),
              _makeMoment(id: 'u-2', userId: '@bob:s'),
            ]);
      },
      act: (bloc) => bloc.add(const LoadUserMoments('@bob:s')),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.moments.length, 'moments.length', 2),
      ],
      verify: (_) {
        verify(() => mockRepo.getUserMoments('@bob:s', limit: any(named: 'limit')))
            .called(1);
      },
    );

    blocTest<MomentBloc, MomentState>(
      'emits loading → error on failure',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getUserMoments(
              any(),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('user moments error'));
      },
      act: (bloc) => bloc.add(const LoadUserMoments('@bob:s')),
      expect: () => [
        isA<MomentState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<MomentState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // PostImageMoment
  // ─────────────────────────────────────────────────

  group('PostImageMoment', () {
    final fakeImage = MomentImageInput(
      bytes: Uint8List.fromList([0, 1, 2]),
      filename: 'photo.jpg',
      mimeType: 'image/jpeg',
      width: 800,
      height: 600,
    );

    blocTest<MomentBloc, MomentState>(
      'emits posting → moment prepended on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.postImageMoment(
              content: any(named: 'content'),
              images: any(named: 'images'),
              location: any(named: 'location'),
              visibility: any(named: 'visibility'),
              visibilityUserIds: any(named: 'visibilityUserIds'),
            )).thenAnswer((_) async => _makeMoment(id: 'img-1'));
      },
      act: (bloc) => bloc.add(PostImageMoment(images: [fakeImage])),
      expect: () => [
        isA<MomentState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<MomentState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.moments.first.id, 'first moment id', 'img-1'),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'emits posting → error on failure',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.postImageMoment(
              content: any(named: 'content'),
              images: any(named: 'images'),
              location: any(named: 'location'),
              visibility: any(named: 'visibility'),
              visibilityUserIds: any(named: 'visibilityUserIds'),
            )).thenThrow(Exception('image upload failed'));
      },
      act: (bloc) => bloc.add(PostImageMoment(images: [fakeImage])),
      expect: () => [
        isA<MomentState>().having((s) => s.isPosting, 'isPosting', isTrue),
        isA<MomentState>()
            .having((s) => s.isPosting, 'isPosting', isFalse)
            .having((s) => s.hasError, 'hasError', isTrue),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // CommentMoment
  // ─────────────────────────────────────────────────

  group('CommentMoment', () {
    blocTest<MomentBloc, MomentState>(
      'adds comment to moment in state on success',
      build: buildBloc,
      seed: () => MomentState(moments: [_makeMoment(id: 'm-1')]),
      setUp: () {
        when(() => mockRepo.commentMoment(
              momentId: any(named: 'momentId'),
              content: any(named: 'content'),
              replyToCommentId: any(named: 'replyToCommentId'),
              replyToUserId: any(named: 'replyToUserId'),
            )).thenAnswer((_) async => _makeComment(id: 'c-new'));
      },
      act: (bloc) => bloc.add(const CommentMoment(
        momentId: 'm-1',
        content: 'Great photo!',
      )),
      expect: () => [
        isA<MomentState>()
            .having(
              (s) => s.moments.firstWhere((m) => m.id == 'm-1').comments.length,
              'comments.length',
              1,
            )
            .having(
              (s) => s.commentSubmissionVersion,
              'commentSubmissionVersion',
              1,
            )
            .having(
              (s) => s.commentSubmissionMomentId,
              'commentSubmissionMomentId',
              'm-1',
            )
            .having(
              (s) => s.commentSubmissionStatus,
              'commentSubmissionStatus',
              MomentCommentSubmissionStatus.success,
            ),
      ],
      verify: (_) {
        verify(() => mockRepo.commentMoment(
              momentId: 'm-1',
              content: 'Great photo!',
              replyToCommentId: any(named: 'replyToCommentId'),
              replyToUserId: any(named: 'replyToUserId'),
            )).called(1);
      },
    );

    blocTest<MomentBloc, MomentState>(
      'emits error on repository failure',
      build: buildBloc,
      seed: () => MomentState(moments: [_makeMoment(id: 'm-1')]),
      setUp: () {
        when(() => mockRepo.commentMoment(
              momentId: any(named: 'momentId'),
              content: any(named: 'content'),
              replyToCommentId: any(named: 'replyToCommentId'),
              replyToUserId: any(named: 'replyToUserId'),
            )).thenThrow(Exception('comment error'));
      },
      act: (bloc) => bloc.add(const CommentMoment(
        momentId: 'm-1',
        content: 'Nice!',
      )),
      expect: () => [
        isA<MomentState>()
            .having((s) => s.hasError, 'hasError', isTrue)
            .having(
              (s) => s.commentSubmissionVersion,
              'commentSubmissionVersion',
              1,
            )
            .having(
              (s) => s.commentSubmissionMomentId,
              'commentSubmissionMomentId',
              'm-1',
            )
            .having(
              (s) => s.commentSubmissionStatus,
              'commentSubmissionStatus',
              MomentCommentSubmissionStatus.failure,
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // DeleteComment
  // ─────────────────────────────────────────────────

  group('DeleteComment', () {
    final momentWithComment = MomentEntity(
      id: 'm-1',
      userId: '@alice:s',
      userName: 'Alice',
      content: 'Test',
      timestamp: DateTime(2025, 6, 1),
      comments: [_makeComment(id: 'c-1')],
    );

    blocTest<MomentBloc, MomentState>(
      'removes comment from moment in state on success',
      build: buildBloc,
      seed: () => MomentState(moments: [momentWithComment]),
      setUp: () {
        when(() => mockRepo.deleteComment(any(), any()))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const DeleteComment('m-1', 'c-1')),
      expect: () => [
        isA<MomentState>().having(
          (s) => s.moments.firstWhere((m) => m.id == 'm-1').comments.length,
          'comments.length',
          0,
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.deleteComment('m-1', 'c-1')).called(1);
      },
    );

    blocTest<MomentBloc, MomentState>(
      'emits error on failure',
      build: buildBloc,
      seed: () => MomentState(moments: [momentWithComment]),
      setUp: () {
        when(() => mockRepo.deleteComment(any(), any()))
            .thenThrow(Exception('delete comment error'));
      },
      act: (bloc) => bloc.add(const DeleteComment('m-1', 'c-1')),
      expect: () => [
        isA<MomentState>().having((s) => s.hasError, 'hasError', isTrue),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // RefreshMoments
  // ─────────────────────────────────────────────────

  group('RefreshMoments', () {
    blocTest<MomentBloc, MomentState>(
      'calls repository.refreshMoments() then reloads',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.refreshMoments()).thenAnswer((_) async {});
        when(() => mockRepo.getMoments(limit: any(named: 'limit')))
            .thenAnswer((_) async => [_makeMoment(id: 'refreshed-1')]);
        when(() => mockRepo.getUnreadMomentCount()).thenAnswer((_) async => 0);
      },
      act: (bloc) => bloc.add(const RefreshMoments()),
      verify: (_) {
        verify(() => mockRepo.refreshMoments()).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // MomentsUpdated (internal stream event)
  // ─────────────────────────────────────────────────

  group('MomentsUpdated', () {
    blocTest<MomentBloc, MomentState>(
      'replaces moments list in state',
      build: buildBloc,
      seed: () => MomentState(moments: [_makeMoment(id: 'old-1')]),
      act: (bloc) => bloc.add(MomentsUpdated([
        _makeMoment(id: 'new-1'),
        _makeMoment(id: 'new-2'),
      ])),
      expect: () => [
        isA<MomentState>()
            .having((s) => s.moments.length, 'moments.length', 2)
            .having((s) => s.moments.first.id, 'first id', 'new-1'),
      ],
    );

    blocTest<MomentBloc, MomentState>(
      'empty list clears all moments',
      build: buildBloc,
      seed: () => MomentState(moments: [_makeMoment()]),
      act: (bloc) => bloc.add(const MomentsUpdated([])),
      expect: () => [
        isA<MomentState>().having((s) => s.moments, 'moments', isEmpty),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SubscribeMoments / UnsubscribeMoments
  // ─────────────────────────────────────────────────

  group('SubscribeMoments / UnsubscribeMoments', () {
    test('SubscribeMoments starts watching and updates state via stream', () async {
      final controller = StreamController<List<MomentEntity>>.broadcast();
      when(() => mockRepo.watchMoments()).thenAnswer((_) => controller.stream);

      final bloc = buildBloc();
      addTearDown(bloc.close);

      bloc.add(const SubscribeMoments());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Push an update through the stream.
      final update = [_makeMoment(id: 'stream-1')];
      controller.add(update);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.moments.any((m) => m.id == 'stream-1'), isTrue);

      await controller.close();
    });

    blocTest<MomentBloc, MomentState>(
      'UnsubscribeMoments does not throw and emits nothing',
      build: buildBloc,
      act: (bloc) => bloc.add(const UnsubscribeMoments()),
      expect: () => <MomentState>[],
    );
  });
}
