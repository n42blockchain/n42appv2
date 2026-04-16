import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/repositories/message_action_repository.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_event.dart';
import 'package:n42_chat/src/presentation/blocs/favorite/favorite_state.dart';

class MockMessageActionRepository extends Mock
    implements IMessageActionRepository {}

MessageEntity _makeMessage({
  String id = 'msg-1',
  MessageType type = MessageType.text,
}) =>
    MessageEntity(
      id: id,
      roomId: '!room:s',
      senderId: '@alice:s',
      senderName: 'Alice',
      content: 'Test message',
      timestamp: DateTime(2025, 6, 1),
      type: type,
      status: MessageStatus.sent,
    );

void main() {
  late MockMessageActionRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const <String>[]);
  });

  setUp(() {
    mockRepo = MockMessageActionRepository();
  });

  FavoriteBloc buildBloc() => FavoriteBloc(repository: mockRepo);

  group('initial state', () {
    test('has empty favorites, not loading', () {
      final bloc = buildBloc();
      expect(bloc.state.favorites, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);
      expect(bloc.state.filterType, isNull);
      expect(bloc.state.searchQuery, isNull);
    });
  });

  group('LoadFavorites', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'emits [loading, loaded] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getSavedMessages())
            .thenAnswer((_) async => [_makeMessage()]);
      },
      act: (bloc) => bloc.add(const LoadFavorites()),
      expect: () => [
        isA<FavoriteState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<FavoriteState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.favorites.length, 'favorites.length', 1),
      ],
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'emits [loading, error] on failure',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getSavedMessages())
            .thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const LoadFavorites()),
      expect: () => [
        isA<FavoriteState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<FavoriteState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'stores filterType from event',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getSavedMessages())
            .thenAnswer((_) async => [_makeMessage()]);
      },
      act: (bloc) => bloc.add(const LoadFavorites(filterType: 'text')),
      expect: () => [
        isA<FavoriteState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<FavoriteState>()
            .having((s) => s.filterType, 'filterType', 'text'),
      ],
    );
  });

  group('SearchFavorites', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'emits state with searchQuery set',
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchFavorites('alice')),
      expect: () => [
        isA<FavoriteState>()
            .having((s) => s.searchQuery, 'searchQuery', 'alice'),
      ],
    );
  });

  group('DeleteFavorite', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'removes favorite from list on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.unsaveMessage(any())).thenAnswer((_) async {});
      },
      seed: () => FavoriteState(
        favorites: [_makeMessage(id: 'msg-1'), _makeMessage(id: 'msg-2')],
      ),
      act: (bloc) => bloc.add(const DeleteFavorite('msg-1')),
      expect: () => [
        isA<FavoriteState>().having(
          (s) => s.favorites.any((f) => f.id == 'msg-1'),
          'msg-1 removed',
          isFalse,
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.unsaveMessage('msg-1')).called(1);
      },
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'emits error when unsaveMessage throws',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.unsaveMessage(any()))
            .thenThrow(Exception('Cannot delete'));
      },
      seed: () => FavoriteState(favorites: [_makeMessage()]),
      act: (bloc) => bloc.add(const DeleteFavorite('msg-1')),
      expect: () => [
        isA<FavoriteState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('EditFavoriteTags', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'calls editFavoriteTags then triggers LoadFavorites',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.editFavoriteTags(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockRepo.getSavedMessages())
            .thenAnswer((_) async => [_makeMessage()]);
      },
      act: (bloc) => bloc.add(
        const EditFavoriteTags(favoriteId: 'msg-1', tags: ['work', 'urgent']),
      ),
      verify: (_) {
        verify(() => mockRepo.editFavoriteTags('msg-1', ['work', 'urgent']))
            .called(1);
      },
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'emits error when editFavoriteTags throws',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.editFavoriteTags(any(), any()))
            .thenThrow(Exception('Tag edit failed'));
      },
      act: (bloc) => bloc.add(
        const EditFavoriteTags(favoriteId: 'msg-1', tags: []),
      ),
      expect: () => [
        isA<FavoriteState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('EditFavoriteRemark', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'calls editFavoriteRemark then triggers LoadFavorites',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.editFavoriteRemark(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockRepo.getSavedMessages())
            .thenAnswer((_) async => [_makeMessage()]);
      },
      act: (bloc) => bloc.add(
        const EditFavoriteRemark(favoriteId: 'msg-1', remark: 'Important note'),
      ),
      verify: (_) {
        verify(() => mockRepo.editFavoriteRemark('msg-1', 'Important note'))
            .called(1);
      },
    );
  });

  group('ChangeFavoriteFilter', () {
    blocTest<FavoriteBloc, FavoriteState>(
      'emits state with updated filterType',
      build: buildBloc,
      act: (bloc) => bloc.add(const ChangeFavoriteFilter('image')),
      expect: () => [
        isA<FavoriteState>()
            .having((s) => s.filterType, 'filterType', 'image'),
      ],
    );

    blocTest<FavoriteBloc, FavoriteState>(
      'emits state with null filterType when cleared',
      build: buildBloc,
      seed: () => const FavoriteState(filterType: 'text'),
      act: (bloc) => bloc.add(const ChangeFavoriteFilter(null)),
      expect: () => [
        isA<FavoriteState>()
            .having((s) => s.filterType, 'filterType', isNull),
      ],
    );
  });

  group('filteredFavorites', () {
    test('returns all favorites when no filter', () {
      const state = FavoriteState(filterType: null);
      // Just ensure FavoriteState.filteredFavorites compiles and works
      expect(state.filteredFavorites, isEmpty);
    });

    test('filters by searchQuery', () {
      final state = FavoriteState(
        favorites: [
          _makeMessage(id: 'msg-1'),
          MessageEntity(
            id: 'msg-2',
            roomId: '!room:s',
            senderId: '@bob:s',
            senderName: 'Bob',
            content: 'bob content',
            timestamp: DateTime(2025, 6, 1),
            type: MessageType.text,
            status: MessageStatus.sent,
          ),
        ],
        searchQuery: 'alice',
      );
      // senderName 'Alice' matches; 'bob content' with senderName 'Bob' does not
      expect(state.filteredFavorites.length, 1);
      expect(state.filteredFavorites.first.id, 'msg-1');
    });
  });
}
