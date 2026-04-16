import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/media_folder_entity.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  final testTimestamp = DateTime(2024, 6, 15, 10, 30);

  MessageEntity createTestMessage({
    String id = '\$event1',
    MessageType type = MessageType.image,
    MessageMetadata? metadata,
  }) {
    return MessageEntity(
      id: id,
      roomId: '!room:example.com',
      senderId: '@user:example.com',
      senderName: 'Test User',
      content: 'media',
      type: type,
      timestamp: testTimestamp,
      metadata: metadata,
    );
  }

  group('MediaFolderEntity', () {
    group('creation', () {
      test('should create with required parameters', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder.id, 'folder1');
        expect(folder.name, 'Photos');
        expect(folder.items, isEmpty);
        expect(folder.createdAt, testTimestamp);
        expect(folder.coverUrl, null);
      });

      test('should create with coverUrl', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: const [],
          coverUrl: 'https://example.com/cover.jpg',
          createdAt: testTimestamp,
        );

        expect(folder.coverUrl, 'https://example.com/cover.jpg');
      });
    });

    group('itemCount', () {
      test('should return 0 for empty folder', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Empty',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder.itemCount, 0);
      });

      test('should return correct count for folder with items', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: [
            createTestMessage(id: '\$e1'),
            createTestMessage(id: '\$e2'),
            createTestMessage(id: '\$e3'),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.itemCount, 3);
      });
    });

    group('totalSize', () {
      test('should return 0 for empty folder', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Empty',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder.totalSize, 0);
      });

      test('should return 0 when items have no metadata', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'No Meta',
          items: [createTestMessage()],
          createdAt: testTimestamp,
        );

        expect(folder.totalSize, 0);
      });

      test('should sum sizes from metadata', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: [
            createTestMessage(
              id: '\$e1',
              metadata: const MessageMetadata(size: 1000),
            ),
            createTestMessage(
              id: '\$e2',
              metadata: const MessageMetadata(size: 2000),
            ),
            createTestMessage(
              id: '\$e3',
              metadata: const MessageMetadata(size: 500),
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.totalSize, 3500);
      });

      test('should handle mixed items with and without metadata', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Mixed',
          items: [
            createTestMessage(
              id: '\$e1',
              metadata: const MessageMetadata(size: 1024),
            ),
            createTestMessage(id: '\$e2'), // no metadata
            createTestMessage(
              id: '\$e3',
              metadata: const MessageMetadata(size: 2048),
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.totalSize, 3072);
      });
    });

    group('formattedTotalSize', () {
      test('should format bytes', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Small',
          items: [
            createTestMessage(
              metadata: const MessageMetadata(size: 500),
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.formattedTotalSize, '500 B');
      });

      test('should format kilobytes', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Medium',
          items: [
            createTestMessage(
              metadata: const MessageMetadata(size: 1536), // 1.5 KB
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.formattedTotalSize, '1.5 KB');
      });

      test('should format megabytes', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Large',
          items: [
            createTestMessage(
              metadata: const MessageMetadata(size: 5242880), // 5 MB
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.formattedTotalSize, '5.0 MB');
      });

      test('should format gigabytes', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Huge',
          items: [
            createTestMessage(
              metadata: const MessageMetadata(size: 2147483648), // 2 GB
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.formattedTotalSize, '2.0 GB');
      });

      test('should format 0 bytes', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Empty',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder.formattedTotalSize, '0 B');
      });

      test('should format exactly 1024 bytes as KB', () {
        final folder = MediaFolderEntity(
          id: 'folder1',
          name: 'Exact KB',
          items: [
            createTestMessage(
              metadata: const MessageMetadata(size: 1024),
            ),
          ],
          createdAt: testTimestamp,
        );

        expect(folder.formattedTotalSize, '1.0 KB');
      });
    });

    group('Equatable', () {
      test('should be equal with same properties', () {
        final folder1 = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: const [],
          createdAt: testTimestamp,
        );
        final folder2 = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder1, equals(folder2));
      });

      test('should not be equal with different id', () {
        final folder1 = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: const [],
          createdAt: testTimestamp,
        );
        final folder2 = MediaFolderEntity(
          id: 'folder2',
          name: 'Photos',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder1, isNot(equals(folder2)));
      });

      test('should not be equal with different name', () {
        final folder1 = MediaFolderEntity(
          id: 'folder1',
          name: 'Photos',
          items: const [],
          createdAt: testTimestamp,
        );
        final folder2 = MediaFolderEntity(
          id: 'folder1',
          name: 'Videos',
          items: const [],
          createdAt: testTimestamp,
        );

        expect(folder1, isNot(equals(folder2)));
      });
    });
  });

  group('MediaDateGroup', () {
    group('creation', () {
      test('should create with required parameters', () {
        final group = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: const [],
        );

        expect(group.date, DateTime(2024, 6, 15));
        expect(group.items, isEmpty);
      });

      test('should create with items', () {
        final group = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: [
            createTestMessage(id: '\$e1'),
            createTestMessage(id: '\$e2'),
          ],
        );

        expect(group.items.length, 2);
      });
    });

    group('Equatable', () {
      test('should be equal with same properties', () {
        final group1 = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: const [],
        );
        final group2 = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: const [],
        );

        expect(group1, equals(group2));
      });

      test('should not be equal with different date', () {
        final group1 = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: const [],
        );
        final group2 = MediaDateGroup(
          date: DateTime(2024, 6, 16),
          items: const [],
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should not be equal with different items', () {
        final group1 = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: [createTestMessage(id: '\$e1')],
        );
        final group2 = MediaDateGroup(
          date: DateTime(2024, 6, 15),
          items: [createTestMessage(id: '\$e2')],
        );

        expect(group1, isNot(equals(group2)));
      });
    });
  });

  group('MediaFilterType', () {
    test('should have all filter types', () {
      expect(MediaFilterType.values, contains(MediaFilterType.all));
      expect(MediaFilterType.values, contains(MediaFilterType.images));
      expect(MediaFilterType.values, contains(MediaFilterType.videos));
      expect(MediaFilterType.values, contains(MediaFilterType.files));
      expect(MediaFilterType.values, contains(MediaFilterType.audio));
      expect(MediaFilterType.values.length, 5);
    });
  });
}
