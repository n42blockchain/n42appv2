import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/chat_folder_entity.dart';

void main() {
  group('ChatFolderEntity', () {
    test('should create with required fields', () {
      const folder = ChatFolderEntity(
        id: 'folder_1',
        name: 'Work',
      );

      expect(folder.id, 'folder_1');
      expect(folder.name, 'Work');
      expect(folder.icon, null);
      expect(folder.color, null);
      expect(folder.order, 0);
      expect(folder.includedRoomIds, isEmpty);
      expect(folder.excludedRoomIds, isEmpty);
      expect(folder.showUnreadCount, true);
      expect(folder.isSystem, false);
    });

    test('should create with all fields', () {
      const folder = ChatFolderEntity(
        id: 'folder_2',
        name: 'Personal',
        icon: '👤',
        color: '#FF5722',
        order: 1,
        includedRoomIds: ['!room1:test', '!room2:test'],
        excludedRoomIds: ['!room3:test'],
        showUnreadCount: false,
        showUnreadBadge: false,
        isSystem: false,
        unreadCount: 5,
        unreadChatsCount: 2,
      );

      expect(folder.icon, '👤');
      expect(folder.color, '#FF5722');
      expect(folder.includedRoomIds.length, 2);
      expect(folder.excludedRoomIds.length, 1);
      expect(folder.showUnreadCount, false);
      expect(folder.unreadCount, 5);
      expect(folder.unreadChatsCount, 2);
    });

    test('system folders should be defined correctly', () {
      expect(ChatFolderEntity.all.id, 'all');
      expect(ChatFolderEntity.all.isSystem, true);

      expect(ChatFolderEntity.unread.id, 'unread');
      expect(ChatFolderEntity.unread.filter.unreadOnly, true);

      expect(ChatFolderEntity.personal.id, 'personal');
      expect(ChatFolderEntity.personal.filter.includeDirectMessages, true);
      expect(ChatFolderEntity.personal.filter.includeGroups, false);

      expect(ChatFolderEntity.groups.id, 'groups');
      expect(ChatFolderEntity.groups.filter.includeGroups, true);
      expect(ChatFolderEntity.groups.filter.includeDirectMessages, false);

      expect(ChatFolderEntity.channels.id, 'channels');
      expect(ChatFolderEntity.channels.filter.includeChannels, true);

      expect(ChatFolderEntity.muted.id, 'muted');
      expect(ChatFolderEntity.muted.filter.mutedOnly, true);
    });

    test('hasFilter should detect custom filters', () {
      const noFilter = ChatFolderEntity(id: '1', name: 'No Filter');
      expect(noFilter.hasFilter, false);

      const withIncluded = ChatFolderEntity(
        id: '2',
        name: 'With Included',
        includedRoomIds: ['!room:test'],
      );
      expect(withIncluded.hasFilter, true);

      const withFilter = ChatFolderEntity(
        id: '3',
        name: 'With Filter',
        filter: ChatFolderFilter(unreadOnly: true),
      );
      expect(withFilter.hasFilter, true);
    });

    test('matchesRoom should work with included rooms', () {
      const folder = ChatFolderEntity(
        id: '1',
        name: 'Test',
        includedRoomIds: ['!room1:test', '!room2:test'],
      );

      expect(
        folder.matchesRoom(
          roomId: '!room1:test',
          isDirectMessage: false,
          isGroup: true,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        true,
      );

      expect(
        folder.matchesRoom(
          roomId: '!room3:test',
          isDirectMessage: false,
          isGroup: true,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        false,
      );
    });

    test('matchesRoom should respect excluded rooms', () {
      const folder = ChatFolderEntity(
        id: '1',
        name: 'Test',
        excludedRoomIds: ['!excluded:test'],
      );

      expect(
        folder.matchesRoom(
          roomId: '!excluded:test',
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        false,
      );
    });

    test('copyWith should create new instance with updated values', () {
      const original = ChatFolderEntity(
        id: '1',
        name: 'Original',
        icon: '📁',
        order: 0,
      );

      final modified = original.copyWith(
        name: 'Modified',
        order: 1,
        unreadCount: 10,
      );

      expect(modified.id, '1');
      expect(modified.name, 'Modified');
      expect(modified.icon, '📁');
      expect(modified.order, 1);
      expect(modified.unreadCount, 10);
      expect(original.name, 'Original');
    });

    test('toJson and fromJson should work correctly', () {
      const folder = ChatFolderEntity(
        id: 'folder_1',
        name: 'Work',
        icon: '💼',
        color: '#2196F3',
        order: 1,
        includedRoomIds: ['!room:test'],
        filter: ChatFolderFilter(unreadOnly: true),
      );

      final json = folder.toJson();
      final restored = ChatFolderEntity.fromJson(json);

      expect(restored.id, folder.id);
      expect(restored.name, folder.name);
      expect(restored.icon, folder.icon);
      expect(restored.color, folder.color);
      expect(restored.order, folder.order);
      expect(restored.includedRoomIds, folder.includedRoomIds);
      expect(restored.filter.unreadOnly, true);
    });
  });

  group('ChatFolderFilter', () {
    test('should create with default values', () {
      const filter = ChatFolderFilter();

      expect(filter.includeDirectMessages, true);
      expect(filter.includeGroups, true);
      expect(filter.includeChannels, true);
      expect(filter.unreadOnly, false);
      expect(filter.mutedOnly, false);
      expect(filter.excludeArchived, true);
    });

    test('matches should filter by type correctly', () {
      const dmOnly = ChatFolderFilter(
        includeDirectMessages: true,
        includeGroups: false,
        includeChannels: false,
      );

      expect(
        dmOnly.matches(
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        true,
      );

      expect(
        dmOnly.matches(
          isDirectMessage: false,
          isGroup: true,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        false,
      );
    });

    test('matches should filter unread correctly', () {
      const unreadFilter = ChatFolderFilter(unreadOnly: true);

      expect(
        unreadFilter.matches(
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 5,
        ),
        true,
      );

      expect(
        unreadFilter.matches(
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        false,
      );
    });

    test('matches should filter muted correctly', () {
      const mutedFilter = ChatFolderFilter(mutedOnly: true);

      expect(
        mutedFilter.matches(
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: true,
          unreadCount: 0,
        ),
        true,
      );

      expect(
        mutedFilter.matches(
          isDirectMessage: true,
          isGroup: false,
          isChannel: false,
          isMuted: false,
          unreadCount: 0,
        ),
        false,
      );
    });

    test('toJson and fromJson should work correctly', () {
      const filter = ChatFolderFilter(
        includeDirectMessages: false,
        unreadOnly: true,
        mutedOnly: false,
      );

      final json = filter.toJson();
      final restored = ChatFolderFilter.fromJson(json);

      expect(restored.includeDirectMessages, false);
      expect(restored.unreadOnly, true);
      expect(restored.mutedOnly, false);
    });
  });
}
