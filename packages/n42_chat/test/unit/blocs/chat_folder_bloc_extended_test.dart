// Extended tests for ChatFolderBloc — covers paths NOT in existing tests:
//   CreateChatFolder failure,
//   UpdateChatFolder failure + isSystem guard,
//   DeleteChatFolder failure + isSystem guard,
//   ReorderChatFolders

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/chat_folder_entity.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_event.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_state.dart';

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

const _customFolder = ChatFolderEntity(
  id: 'custom-1',
  name: 'Work',
  order: 100,
);

const _systemFolder = ChatFolderEntity(
  id: 'groups',
  name: 'Groups',
  order: -700,
  isSystem: true,
  filter: ChatFolderFilter(includeDirectMessages: false, includeGroups: true),
);

void main() {
  late MockPreferencesDataSource mockStorage;

  setUp(() {
    mockStorage = MockPreferencesDataSource();
    when(() => mockStorage.getChatFolders())
        .thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => mockStorage.saveChatFolders(any()))
        .thenAnswer((_) async {});
  });

  ChatFolderBloc buildBloc() =>
      ChatFolderBloc(storage: mockStorage);

  // ─────────────────────────────────────────────────
  // CreateChatFolder — failure
  // ─────────────────────────────────────────────────

  group('CreateChatFolder — save throws silently', () {
    blocTest<ChatFolderBloc, ChatFolderState>(
      'emits optimistic add even when saveChatFolders throws internally',
      build: () {
        when(() => mockStorage.saveChatFolders(any()))
            .thenThrow(Exception('Storage full'));
        return buildBloc();
      },
      seed: () => const ChatFolderState(
        folders: [_customFolder],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const CreateChatFolder(name: 'New Folder')),
      expect: () => [
        // _saveFolders catches exceptions internally → only optimistic add emitted
        isA<ChatFolderState>()
            .having((s) => s.folders.length, 'folders.length', 2),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // UpdateChatFolder — isSystem guard
  // ─────────────────────────────────────────────────

  group('UpdateChatFolder — isSystem guard', () {
    blocTest<ChatFolderBloc, ChatFolderState>(
      'does nothing when folder.isSystem is true',
      build: buildBloc,
      seed: () => const ChatFolderState(
        folders: [_systemFolder, _customFolder],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(UpdateChatFolder(
        _systemFolder.copyWith(name: 'Modified'),
      )),
      expect: () => <ChatFolderState>[],
      verify: (_) {
        verifyNever(() => mockStorage.saveChatFolders(any()));
      },
    );
  });

  // ─────────────────────────────────────────────────
  // UpdateChatFolder — failure
  // ─────────────────────────────────────────────────

  group('UpdateChatFolder — save throws silently', () {
    blocTest<ChatFolderBloc, ChatFolderState>(
      'emits optimistic update even when saveChatFolders throws internally',
      build: () {
        when(() => mockStorage.saveChatFolders(any()))
            .thenThrow(Exception('IO error'));
        return buildBloc();
      },
      seed: () => const ChatFolderState(
        folders: [_customFolder],
        isLoading: false,
      ),
      act: (bloc) =>
          bloc.add(UpdateChatFolder(_customFolder.copyWith(name: 'Renamed'))),
      expect: () => [
        // _saveFolders catches exceptions internally → only optimistic update emitted
        isA<ChatFolderState>().having(
          (s) => s.folders.firstWhere((f) => f.id == 'custom-1').name,
          'folder name',
          'Renamed',
        ),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // DeleteChatFolder — isSystem guard
  // ─────────────────────────────────────────────────

  group('DeleteChatFolder — isSystem guard', () {
    blocTest<ChatFolderBloc, ChatFolderState>(
      'does nothing when trying to delete a system folder',
      build: buildBloc,
      seed: () => const ChatFolderState(
        folders: [_systemFolder, _customFolder],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const DeleteChatFolder('groups')),
      expect: () => <ChatFolderState>[],
      verify: (_) {
        verifyNever(() => mockStorage.saveChatFolders(any()));
      },
    );
  });

  // ─────────────────────────────────────────────────
  // DeleteChatFolder — failure
  // ─────────────────────────────────────────────────

  group('DeleteChatFolder — save throws silently', () {
    blocTest<ChatFolderBloc, ChatFolderState>(
      'emits optimistic delete even when saveChatFolders throws internally',
      build: () {
        when(() => mockStorage.saveChatFolders(any()))
            .thenThrow(Exception('Delete failed'));
        return buildBloc();
      },
      seed: () => const ChatFolderState(
        folders: [_customFolder],
        isLoading: false,
        selectedFolderId: 'all',
      ),
      act: (bloc) => bloc.add(const DeleteChatFolder('custom-1')),
      expect: () => [
        // _saveFolders catches exceptions internally → only optimistic delete emitted
        isA<ChatFolderState>()
            .having((s) => s.folders.any((f) => f.id == 'custom-1'), 'has custom', isFalse),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // ReorderChatFolders
  // ─────────────────────────────────────────────────

  group('ReorderChatFolders', () {
    blocTest<ChatFolderBloc, ChatFolderState>(
      'emits reordered folders and persists',
      build: buildBloc,
      // Seed with empty folders so the reorder creates a state change
      seed: () => const ChatFolderState(
        folders: [],
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const ReorderChatFolders(
        [_customFolder],
      )),
      expect: () => [
        isA<ChatFolderState>()
            .having((s) => s.folders, 'folders', [_customFolder]),
      ],
      verify: (_) {
        verify(() => mockStorage.saveChatFolders(any())).called(1);
      },
    );
  });
}
