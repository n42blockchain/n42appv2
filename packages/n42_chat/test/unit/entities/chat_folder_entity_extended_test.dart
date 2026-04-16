// Extended tests for chat_folder_entity — covers methods NOT in existing tests:
//   ChatFolderEntity.matchesRoom (filter path),
//   ChatFolderEntity.copyWith,
//   ChatFolderFilter.props equality,
//   ChatFolderFilter.copyWith

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/chat_folder_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // ChatFolderEntity.matchesRoom — filter path
  // ─────────────────────────────────────────────────

  group('ChatFolderEntity.matchesRoom — filter path', () {
    const folder = ChatFolderEntity(
      id: 'f1',
      name: 'DMs',
      filter: ChatFolderFilter(includeDirectMessages: true, includeGroups: false),
      includedRoomIds: [],
      excludedRoomIds: [],
    );

    test('returns true when filter matches DM room', () {
      expect(
        folder.matchesRoom(
          roomId: '!dm:server',
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        isTrue,
      );
    });

    test('returns false when filter excludes group room', () {
      expect(
        folder.matchesRoom(
          roomId: '!group:server',
          isDirectMessage: false,
          isGroup: true,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        isFalse,
      );
    });

    test('excludedRoomIds takes precedence', () {
      const folderWithExclude = ChatFolderEntity(
        id: 'f2',
        name: 'All',
        filter: ChatFolderFilter(includeDirectMessages: true),
        includedRoomIds: [],
        excludedRoomIds: ['!excluded:server'],
      );
      expect(
        folderWithExclude.matchesRoom(
          roomId: '!excluded:server',
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        isFalse,
      );
    });

    test('includedRoomIds short-circuits filter', () {
      const folderWithInclude = ChatFolderEntity(
        id: 'f3',
        name: 'Custom',
        filter: ChatFolderFilter(includeDirectMessages: false),
        includedRoomIds: ['!special:server'],
        excludedRoomIds: [],
      );
      // Room is in includedRoomIds so filter is bypassed
      expect(
        folderWithInclude.matchesRoom(
          roomId: '!special:server',
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        isTrue,
      );
    });
  });

  // ─────────────────────────────────────────────────
  // ChatFolderEntity.copyWith
  // ─────────────────────────────────────────────────

  group('ChatFolderEntity.copyWith', () {
    const base = ChatFolderEntity(
      id: 'f1',
      name: 'Old Name',
      order: 0,
      showUnreadCount: true,
      showUnreadBadge: true,
    );

    test('changes name and order', () {
      final updated = base.copyWith(name: 'New Name', order: 5);
      expect(updated.name, 'New Name');
      expect(updated.order, 5);
      expect(updated.id, base.id);
    });

    test('changes showUnreadCount and showUnreadBadge', () {
      final updated = base.copyWith(showUnreadCount: false, showUnreadBadge: false);
      expect(updated.showUnreadCount, isFalse);
      expect(updated.showUnreadBadge, isFalse);
    });

    test('changes unreadCount', () {
      final updated = base.copyWith(unreadCount: 10);
      expect(updated.unreadCount, 10);
    });
  });

  // ─────────────────────────────────────────────────
  // ChatFolderFilter.props equality
  // ─────────────────────────────────────────────────

  group('ChatFolderFilter.props', () {
    test('two identical instances are equal', () {
      const a = ChatFolderFilter(
        includeDirectMessages: true,
        includeGroups: false,
        unreadOnly: true,
      );
      const b = ChatFolderFilter(
        includeDirectMessages: true,
        includeGroups: false,
        unreadOnly: true,
      );
      expect(a, equals(b));
    });

    test('different includeGroups → not equal', () {
      const a = ChatFolderFilter(includeGroups: true);
      const b = ChatFolderFilter(includeGroups: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // ChatFolderFilter.copyWith
  // ─────────────────────────────────────────────────

  group('ChatFolderFilter.copyWith', () {
    const base = ChatFolderFilter(
      includeDirectMessages: true,
      includeGroups: true,
      includeChannels: true,
    );

    test('changes single field', () {
      final updated = base.copyWith(unreadOnly: true);
      expect(updated.unreadOnly, isTrue);
      expect(updated.includeDirectMessages, isTrue);
      expect(updated.includeGroups, isTrue);
    });

    test('changes mutedOnly and pinnedOnly', () {
      final updated = base.copyWith(mutedOnly: true, pinnedOnly: true);
      expect(updated.mutedOnly, isTrue);
      expect(updated.pinnedOnly, isTrue);
      expect(updated.includeChannels, isTrue);
    });

    test('changes archivedOnly and excludeArchived', () {
      final updated = base.copyWith(archivedOnly: true, excludeArchived: false);
      expect(updated.archivedOnly, isTrue);
      expect(updated.excludeArchived, isFalse);
    });

    test('changes unmutedOnly', () {
      final updated = base.copyWith(unmutedOnly: true);
      expect(updated.unmutedOnly, isTrue);
    });
  });
}
