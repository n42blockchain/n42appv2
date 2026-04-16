// Tests for ChatFolderEvent subclasses in chat_folder_event.dart.
// ChatFolderEntity is const-constructible (id + name required, all others defaulted).
// Pure Dart — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/chat_folder_entity.dart';
import 'package:n42_chat/src/presentation/blocs/chat_folder/chat_folder_event.dart';

void main() {
  // Shared const folder for event tests
  const folder = ChatFolderEntity(id: 'f1', name: 'Work');
  const folderB = ChatFolderEntity(id: 'f2', name: 'Personal');

  // ─────────────────────────────────────────────────
  // LoadChatFolders
  // ─────────────────────────────────────────────────

  group('LoadChatFolders', () {
    test('is a ChatFolderEvent', () {
      expect(const LoadChatFolders(), isA<ChatFolderEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadChatFolders(), equals(const LoadChatFolders()));
    });
  });

  // ─────────────────────────────────────────────────
  // SelectChatFolder
  // ─────────────────────────────────────────────────

  group('SelectChatFolder', () {
    test('stores folderId', () {
      const e = SelectChatFolder('f1');
      expect(e.folderId, 'f1');
    });

    test('same folderId → equal', () {
      expect(const SelectChatFolder('f1'), equals(const SelectChatFolder('f1')));
    });

    test('different folderId → not equal', () {
      expect(
        const SelectChatFolder('f1'),
        isNot(equals(const SelectChatFolder('f2'))),
      );
    });

    test('is a ChatFolderEvent', () {
      expect(const SelectChatFolder('f1'), isA<ChatFolderEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // CreateChatFolder
  // ─────────────────────────────────────────────────

  group('CreateChatFolder', () {
    test('stores name', () {
      const e = CreateChatFolder(name: 'Work');
      expect(e.name, 'Work');
    });

    test('icon defaults to null', () {
      expect(const CreateChatFolder(name: 'F').icon, isNull);
    });

    test('filter defaults to empty ChatFolderFilter', () {
      const e = CreateChatFolder(name: 'F');
      expect(e.filter, const ChatFolderFilter());
    });

    test('includedRoomIds defaults to empty', () {
      expect(const CreateChatFolder(name: 'F').includedRoomIds, isEmpty);
    });

    test('stores icon when provided', () {
      const e = CreateChatFolder(name: 'F', icon: '📁');
      expect(e.icon, '📁');
    });

    test('stores includedRoomIds', () {
      const e = CreateChatFolder(
        name: 'F',
        includedRoomIds: ['!r1:s', '!r2:s'],
      );
      expect(e.includedRoomIds, ['!r1:s', '!r2:s']);
    });

    test('same fields → equal', () {
      expect(
        const CreateChatFolder(name: 'Work', icon: '💼'),
        equals(const CreateChatFolder(name: 'Work', icon: '💼')),
      );
    });

    test('different name → not equal', () {
      expect(
        const CreateChatFolder(name: 'A'),
        isNot(equals(const CreateChatFolder(name: 'B'))),
      );
    });

    test('is a ChatFolderEvent', () {
      expect(const CreateChatFolder(name: 'F'), isA<ChatFolderEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateChatFolder
  // ─────────────────────────────────────────────────

  group('UpdateChatFolder', () {
    test('stores folder fields', () {
      const e = UpdateChatFolder(folder);
      expect(e.folder.id, 'f1');
      expect(e.folder.name, 'Work');
    });

    test('same folder → equal', () {
      expect(
        const UpdateChatFolder(folder),
        equals(const UpdateChatFolder(folder)),
      );
    });

    test('different folder → not equal', () {
      expect(
        const UpdateChatFolder(folder),
        isNot(equals(const UpdateChatFolder(folderB))),
      );
    });

    test('is a ChatFolderEvent', () {
      expect(const UpdateChatFolder(folder), isA<ChatFolderEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // DeleteChatFolder
  // ─────────────────────────────────────────────────

  group('DeleteChatFolder', () {
    test('stores folderId', () {
      const e = DeleteChatFolder('f1');
      expect(e.folderId, 'f1');
    });

    test('same folderId → equal', () {
      expect(
        const DeleteChatFolder('f1'),
        equals(const DeleteChatFolder('f1')),
      );
    });

    test('different folderId → not equal', () {
      expect(
        const DeleteChatFolder('f1'),
        isNot(equals(const DeleteChatFolder('f2'))),
      );
    });

    test('is a ChatFolderEvent', () {
      expect(const DeleteChatFolder('f1'), isA<ChatFolderEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ReorderChatFolders
  // ─────────────────────────────────────────────────

  group('ReorderChatFolders', () {
    test('stores folders list', () {
      const e = ReorderChatFolders([folder, folderB]);
      expect(e.folders.length, 2);
      expect(e.folders.first.id, 'f1');
      expect(e.folders.last.id, 'f2');
    });

    test('empty list stored', () {
      expect(const ReorderChatFolders([]).folders, isEmpty);
    });

    test('same folders → equal', () {
      expect(
        const ReorderChatFolders([folder, folderB]),
        equals(const ReorderChatFolders([folder, folderB])),
      );
    });

    test('different order → not equal', () {
      expect(
        const ReorderChatFolders([folder, folderB]),
        isNot(equals(const ReorderChatFolders([folderB, folder]))),
      );
    });

    test('empty list → equal', () {
      expect(
        const ReorderChatFolders([]),
        equals(const ReorderChatFolders([])),
      );
    });

    test('is a ChatFolderEvent', () {
      expect(const ReorderChatFolders([]), isA<ChatFolderEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ChatFolderEntity default field values
  // ─────────────────────────────────────────────────

  group('ChatFolderEntity defaults', () {
    test('order defaults to 0', () {
      expect(const ChatFolderEntity(id: 'x', name: 'X').order, 0);
    });

    test('showUnreadCount defaults to true', () {
      expect(const ChatFolderEntity(id: 'x', name: 'X').showUnreadCount, isTrue);
    });

    test('showUnreadBadge defaults to true', () {
      expect(const ChatFolderEntity(id: 'x', name: 'X').showUnreadBadge, isTrue);
    });

    test('isSystem defaults to false', () {
      expect(const ChatFolderEntity(id: 'x', name: 'X').isSystem, isFalse);
    });

    test('unreadCount defaults to 0', () {
      expect(const ChatFolderEntity(id: 'x', name: 'X').unreadCount, 0);
    });

    test('static all folder is isSystem', () {
      expect(ChatFolderEntity.all.isSystem, isTrue);
      expect(ChatFolderEntity.all.id, 'all');
    });
  });
}
