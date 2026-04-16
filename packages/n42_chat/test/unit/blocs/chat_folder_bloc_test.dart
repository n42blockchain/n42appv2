import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/chat_folder_entity.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_event.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_state.dart';

class MockSecureStorage extends Mock implements PreferencesDataSource {}

void main() {
  late MockSecureStorage mockStorage;

  final systemFolders = [
    ChatFolderEntity.all,
    ChatFolderEntity.unread,
    ChatFolderEntity.personal,
    ChatFolderEntity.groups,
    ChatFolderEntity.channels,
    ChatFolderEntity.muted,
  ];

  const customFolder = ChatFolderEntity(
    id: 'custom-1',
    name: 'Work',
    icon: '\u{1F4BC}',
    order: 1,
    isSystem: false,
  );

  setUp(() {
    mockStorage = MockSecureStorage();
  });

  group('ChatFolderBloc', () {
    test('initial state should be correct', () {
      when(() => mockStorage.getChatFolders())
          .thenAnswer((_) async => []);

      final bloc = ChatFolderBloc(storage: mockStorage);

      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.selectedFolderId, equals('all'));
      expect(bloc.state.folders, isEmpty);
      expect(bloc.state.error, isNull);

      bloc.close();
    });

    blocTest<ChatFolderBloc, ChatFolderState>(
      'LoadChatFolders should load system + custom folders',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => [customFolder.toJson()]);
        return ChatFolderBloc(storage: mockStorage);
      },
      act: (bloc) => bloc.add(const LoadChatFolders()),
      expect: () => [
        // First emission: isLoading=true, clearError
        isA<ChatFolderState>()
            .having((s) => s.isLoading, 'isLoading', isTrue)
            .having((s) => s.error, 'error', isNull),
        // Second emission: folders loaded, isLoading=false
        isA<ChatFolderState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNull)
            .having(
              (s) => s.folders.length,
              'folders.length',
              equals(systemFolders.length + 1),
            )
            .having(
              (s) => s.folders.any((f) => f.id == 'custom-1'),
              'contains custom folder',
              isTrue,
            )
            .having(
              (s) => s.systemFolders.length,
              'systemFolders.length',
              equals(systemFolders.length),
            ),
      ],
      verify: (_) {
        verify(() => mockStorage.getChatFolders()).called(1);
      },
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'LoadChatFolders should return system folders on storage failure',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenThrow(Exception('Storage error'));
        return ChatFolderBloc(storage: mockStorage);
      },
      act: (bloc) => bloc.add(const LoadChatFolders()),
      expect: () => [
        // First emission: isLoading=true
        isA<ChatFolderState>()
            .having((s) => s.isLoading, 'isLoading', isTrue),
        // Second emission: fallback to system folders with error
        isA<ChatFolderState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull)
            .having(
              (s) => s.folders.length,
              'folders.length',
              equals(systemFolders.length),
            )
            .having(
              (s) => s.folders.every((f) => f.isSystem),
              'all system folders',
              isTrue,
            ),
      ],
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'SelectChatFolder should update selected ID',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: systemFolders,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const SelectChatFolder('unread')),
      expect: () => [
        isA<ChatFolderState>()
            .having(
              (s) => s.selectedFolderId,
              'selectedFolderId',
              equals('unread'),
            ),
      ],
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'CreateChatFolder should add folder and persist',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        when(() => mockStorage.saveChatFolders(any()))
            .thenAnswer((_) async {});
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: systemFolders,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const CreateChatFolder(
        name: 'Work',
        icon: '\u{1F4BC}',
      )),
      expect: () => [
        isA<ChatFolderState>()
            .having(
              (s) => s.folders.length,
              'folders.length',
              equals(systemFolders.length + 1),
            )
            .having(
              (s) => s.folders.any((f) => f.name == 'Work' && !f.isSystem),
              'contains new Work folder',
              isTrue,
            ),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'UpdateChatFolder should update non-system folder',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        when(() => mockStorage.saveChatFolders(any()))
            .thenAnswer((_) async {});
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: [...systemFolders, customFolder],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(
        UpdateChatFolder(customFolder.copyWith(name: 'Updated Work')),
      ),
      expect: () => [
        isA<ChatFolderState>()
            .having(
              (s) => s.folders.firstWhere((f) => f.id == 'custom-1').name,
              'updated folder name',
              equals('Updated Work'),
            ),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'UpdateChatFolder should ignore system folder',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: systemFolders,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(
        UpdateChatFolder(ChatFolderEntity.all.copyWith(name: 'Hacked')),
      ),
      expect: () => [],
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'DeleteChatFolder should remove and switch to all',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        when(() => mockStorage.saveChatFolders(any()))
            .thenAnswer((_) async {});
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: [...systemFolders, customFolder],
        selectedFolderId: 'custom-1',
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const DeleteChatFolder('custom-1')),
      expect: () => [
        isA<ChatFolderState>()
            .having(
              (s) => s.folders.any((f) => f.id == 'custom-1'),
              'custom folder removed',
              isFalse,
            )
            .having(
              (s) => s.selectedFolderId,
              'selectedFolderId',
              equals('all'),
            )
            .having(
              (s) => s.folders.length,
              'folders.length',
              equals(systemFolders.length),
            ),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'DeleteChatFolder should not delete system folder',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: systemFolders,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const DeleteChatFolder('all')),
      expect: () => [],
    );

    blocTest<ChatFolderBloc, ChatFolderState>(
      'ReorderChatFolders should update and persist',
      build: () {
        when(() => mockStorage.getChatFolders())
            .thenAnswer((_) async => []);
        when(() => mockStorage.saveChatFolders(any()))
            .thenAnswer((_) async {});
        return ChatFolderBloc(storage: mockStorage);
      },
      seed: () => ChatFolderState(
        folders: systemFolders,
        isLoading: false,
      ),
      act: (bloc) {
        final reordered = [...systemFolders.reversed];
        bloc.add(ReorderChatFolders(reordered));
      },
      expect: () => [
        isA<ChatFolderState>()
            .having(
              (s) => s.folders.first.id,
              'first folder id',
              equals(systemFolders.last.id),
            )
            .having(
              (s) => s.folders.last.id,
              'last folder id',
              equals(systemFolders.first.id),
            ),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );
  });
}
