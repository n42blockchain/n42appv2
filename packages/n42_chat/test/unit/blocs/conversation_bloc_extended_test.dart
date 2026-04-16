// Extended tests for ConversationBloc — covers handlers NOT exercised by
// conversation_bloc_test.dart:
//   SubscribeConversations, UnsubscribeConversations,
//   ClearSearch, CreateGroupChat,
//   SetConversationHidden, LoadHiddenConversations,
//   ClearNewConversationNavigation

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/domain/repositories/conversation_repository.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_event.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_state.dart';

class _MockConvRepo extends Mock implements IConversationRepository {}

class _MockPrefs extends Mock implements PreferencesDataSource {}

const _roomA = ConversationEntity(id: '!a:s', name: 'Alpha');
const _roomB = ConversationEntity(id: '!b:s', name: 'Beta', isPinned: true);
const _roomHidden = ConversationEntity(
  id: '!h:s',
  name: 'Hidden',
  isHidden: true,
);

void main() {
  late _MockConvRepo mockRepo;
  late _MockPrefs mockPrefs;

  setUp(() {
    mockRepo = _MockConvRepo();
    mockPrefs = _MockPrefs();
    // Default: no hidden chats
    when(
      () => mockPrefs.getHiddenChatIds(),
    ).thenAnswer((_) async => <String>{});
  });

  ConversationBloc buildBloc() => ConversationBloc(
    conversationRepository: mockRepo,
    storageDataSource: mockPrefs,
  );

  // ─────────────────────────────────────────────────
  // SubscribeConversations / UnsubscribeConversations
  // ─────────────────────────────────────────────────

  group('SubscribeConversations', () {
    test(
      'starts watching and emits ConversationsUpdated on new data',
      () async {
        final controller =
            StreamController<List<ConversationEntity>>.broadcast();
        when(
          () => mockRepo.watchConversations(),
        ).thenAnswer((_) => controller.stream);
        when(
          () => mockPrefs.getHiddenChatIds(),
        ).thenAnswer((_) async => <String>{});

        final bloc = buildBloc();
        addTearDown(bloc.close);

        bloc.add(const SubscribeConversations());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        controller.add([_roomA]);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.conversations.any((c) => c.id == '!a:s'), isTrue);

        await controller.close();
      },
    );
  });

  group('UnsubscribeConversations', () {
    blocTest<ConversationBloc, ConversationState>(
      'does not throw and emits no states',
      build: buildBloc,
      act: (bloc) => bloc.add(const UnsubscribeConversations()),
      expect: () => <ConversationState>[],
    );
  });

  // ─────────────────────────────────────────────────
  // ClearSearch
  // ─────────────────────────────────────────────────

  group('ClearSearch', () {
    blocTest<ConversationBloc, ConversationState>(
      'resets isSearching and clears filteredConversations',
      build: buildBloc,
      seed: () => const ConversationState(
        conversations: [_roomA, _roomB],
        isSearching: true,
        filteredConversations: [_roomA],
      ),
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [
        isA<ConversationState>()
            .having((s) => s.isSearching, 'isSearching', isFalse)
            .having(
              (s) => s.filteredConversations,
              'filteredConversations',
              isNull,
            ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // CreateGroupChat
  // ─────────────────────────────────────────────────

  group('CreateGroupChat', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits newConversationId on success then refreshes',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.createGroupChat(
            name: any(named: 'name'),
            topic: any(named: 'topic'),
            memberIds: any(named: 'memberIds'),
            encrypted: any(named: 'encrypted'),
          ),
        ).thenAnswer(
          (_) async =>
              const ConversationEntity(id: '!group:s', name: 'My Group'),
        );
        when(() => mockRepo.getConversations()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(
        const CreateGroupChat(
          name: 'My Group',
          memberIds: ['@alice:s', '@bob:s'],
        ),
      ),
      expect: () => [
        isA<ConversationState>()
            .having((s) => s.newConversationId, 'newConversationId', '!group:s')
            .having(
              (s) => s.conversations.any((c) => c.id == '!group:s'),
              'group inserted before refresh',
              isTrue,
            ),
        // RefreshConversations is dispatched internally; allow any loading state
        isA<ConversationState>(),
        isA<ConversationState>(),
      ],
      verify: (_) {
        verify(
          () => mockRepo.createGroupChat(
            name: 'My Group',
            topic: any(named: 'topic'),
            memberIds: ['@alice:s', '@bob:s'],
            encrypted: any(named: 'encrypted'),
          ),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error on repository failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.createGroupChat(
            name: any(named: 'name'),
            topic: any(named: 'topic'),
            memberIds: any(named: 'memberIds'),
            encrypted: any(named: 'encrypted'),
          ),
        ).thenThrow(Exception('create group error'));
      },
      act: (bloc) =>
          bloc.add(const CreateGroupChat(name: 'Broken Group', memberIds: [])),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.error,
          'error',
          contains('Failed to create group'),
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SetConversationHidden
  // ─────────────────────────────────────────────────

  group('SetConversationHidden', () {
    blocTest<ConversationBloc, ConversationState>(
      'hides a conversation — moves it to hiddenConversations',
      build: buildBloc,
      seed: () => const ConversationState(
        conversations: [_roomA],
        hiddenConversations: [],
      ),
      setUp: () {
        when(() => mockPrefs.hideChat(any())).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const SetConversationHidden(conversationId: '!a:s', hidden: true),
      ),
      expect: () => [
        isA<ConversationState>()
            .having(
              (s) => s.hiddenConversations.any((c) => c.id == '!a:s'),
              'room in hiddenConversations',
              isTrue,
            )
            .having(
              (s) => s.normalConversations.any((c) => c.id == '!a:s'),
              'room NOT in normalConversations',
              isFalse,
            ),
      ],
      verify: (_) {
        verify(() => mockPrefs.hideChat('!a:s')).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'unhides a conversation — removes it from hiddenConversations',
      build: buildBloc,
      seed: () => const ConversationState(
        conversations: [_roomHidden],
        hiddenConversations: [_roomHidden],
      ),
      setUp: () {
        when(() => mockPrefs.unhideChat(any())).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(
        const SetConversationHidden(conversationId: '!h:s', hidden: false),
      ),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.hiddenConversations.any((c) => c.id == '!h:s'),
          'room removed from hiddenConversations',
          isFalse,
        ),
      ],
      verify: (_) {
        verify(() => mockPrefs.unhideChat('!h:s')).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when storage throws',
      build: buildBloc,
      seed: () => const ConversationState(conversations: [_roomA]),
      setUp: () {
        when(
          () => mockPrefs.hideChat(any()),
        ).thenThrow(Exception('storage error'));
      },
      act: (bloc) => bloc.add(
        const SetConversationHidden(conversationId: '!a:s', hidden: true),
      ),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.error,
          'error',
          contains('Hide failed'),
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadHiddenConversations
  // ─────────────────────────────────────────────────

  group('LoadHiddenConversations', () {
    blocTest<ConversationBloc, ConversationState>(
      'loads hidden conversations from storage + repository',
      build: buildBloc,
      setUp: () {
        when(
          () => mockPrefs.getHiddenChatIds(),
        ).thenAnswer((_) async => {'!h:s'});
        when(
          () => mockRepo.getConversations(),
        ).thenAnswer((_) async => [_roomA, _roomHidden]);
      },
      act: (bloc) => bloc.add(const LoadHiddenConversations()),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.isLoadingHidden,
          'isLoadingHidden',
          isTrue,
        ),
        isA<ConversationState>()
            .having((s) => s.isLoadingHidden, 'isLoadingHidden', isFalse)
            .having(
              (s) => s.hiddenConversations.any((c) => c.id == '!h:s'),
              'hidden conv present',
              isTrue,
            ),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when repository throws',
      build: buildBloc,
      setUp: () {
        when(
          () => mockPrefs.getHiddenChatIds(),
        ).thenAnswer((_) async => {'!h:s'});
        when(
          () => mockRepo.getConversations(),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const LoadHiddenConversations()),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.isLoadingHidden,
          'isLoadingHidden',
          isTrue,
        ),
        isA<ConversationState>()
            .having((s) => s.isLoadingHidden, 'isLoadingHidden', isFalse)
            .having((s) => s.error, 'error', contains('Failed to load hidden')),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ClearNewConversationNavigation
  // ─────────────────────────────────────────────────

  group('ClearNewConversationNavigation', () {
    blocTest<ConversationBloc, ConversationState>(
      'clears one-shot navigation flag without mutating conversations',
      build: buildBloc,
      seed: () => const ConversationState(
        conversations: [_roomA],
        newConversationId: '!a:s',
      ),
      act: (bloc) => bloc.add(const ClearNewConversationNavigation()),
      expect: () => [
        isA<ConversationState>()
            .having((s) => s.newConversationId, 'newConversationId', isNull)
            .having((s) => s.conversations.length, 'conversation count', 1),
      ],
    );
  });
}
