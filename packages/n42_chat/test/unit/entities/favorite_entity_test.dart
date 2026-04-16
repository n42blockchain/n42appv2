import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/favorite_entity.dart';

void main() {
  final _createdAt = DateTime(2025, 6, 1);

  FavoriteEntity _makeFavorite({
    String id = 'fav-1',
    FavoriteType type = FavoriteType.text,
    String content = 'Hello, world!',
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    List<String> tags = const [],
    String? remark,
  }) {
    return FavoriteEntity(
      id: id,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      createdAt: _createdAt,
      tags: tags,
      remark: remark,
    );
  }

  group('FavoriteType', () {
    test('has 8 values', () {
      expect(FavoriteType.values.length, 8);
      expect(FavoriteType.values, containsAll([
        FavoriteType.text,
        FavoriteType.image,
        FavoriteType.video,
        FavoriteType.file,
        FavoriteType.link,
        FavoriteType.voice,
        FavoriteType.location,
        FavoriteType.note,
      ]));
    });
  });

  group('FavoriteEntity construction', () {
    test('creates with required fields', () {
      final entity = _makeFavorite();

      expect(entity.id, 'fav-1');
      expect(entity.type, FavoriteType.text);
      expect(entity.content, 'Hello, world!');
      expect(entity.createdAt, _createdAt);
      expect(entity.tags, isEmpty);
    });

    test('optional fields default to null', () {
      final entity = _makeFavorite();

      expect(entity.mediaUrl, isNull);
      expect(entity.thumbnailUrl, isNull);
      expect(entity.fileName, isNull);
      expect(entity.fileSize, isNull);
      expect(entity.sourceRoomId, isNull);
      expect(entity.sourceRoomName, isNull);
      expect(entity.sourceMessageId, isNull);
      expect(entity.sourceSenderId, isNull);
      expect(entity.sourceSenderName, isNull);
      expect(entity.remark, isNull);
    });

    test('creates with all optional fields', () {
      final entity = FavoriteEntity(
        id: 'fav-full',
        type: FavoriteType.file,
        content: 'Document',
        mediaUrl: 'https://example.com/file.pdf',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        fileName: 'report.pdf',
        fileSize: 1024 * 1024,
        sourceRoomId: '!room:s',
        sourceRoomName: 'Work Group',
        sourceMessageId: '\$msg:s',
        sourceSenderId: '@alice:s',
        sourceSenderName: 'Alice',
        createdAt: _createdAt,
        tags: ['work', 'important'],
        remark: 'Monthly report',
      );

      expect(entity.mediaUrl, 'https://example.com/file.pdf');
      expect(entity.fileName, 'report.pdf');
      expect(entity.fileSize, 1024 * 1024);
      expect(entity.tags, ['work', 'important']);
      expect(entity.remark, 'Monthly report');
    });
  });

  group('typeDescription', () {
    final expectations = {
      FavoriteType.text: '文本',
      FavoriteType.image: '图片',
      FavoriteType.video: '视频',
      FavoriteType.file: '文件',
      FavoriteType.link: '链接',
      FavoriteType.voice: '语音',
      FavoriteType.location: '位置',
      FavoriteType.note: '笔记',
    };

    for (final entry in expectations.entries) {
      test('${entry.key.name} → "${entry.value}"', () {
        final entity = _makeFavorite(type: entry.key);
        expect(entity.typeDescription, entry.value);
      });
    }
  });

  group('typeIcon', () {
    test('all types have a non-empty icon', () {
      for (final type in FavoriteType.values) {
        final entity = _makeFavorite(type: type);
        expect(entity.typeIcon, isNotEmpty,
            reason: 'FavoriteType.${type.name} should have an icon');
      }
    });
  });

  group('props equality', () {
    test('equal entities with same fields', () {
      final a = _makeFavorite();
      final b = _makeFavorite();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different id produces different entities', () {
      final a = _makeFavorite(id: 'fav-1');
      final b = _makeFavorite(id: 'fav-2');

      expect(a, isNot(equals(b)));
    });

    test('different type produces different entities', () {
      final a = _makeFavorite(type: FavoriteType.text);
      final b = _makeFavorite(type: FavoriteType.image);

      expect(a, isNot(equals(b)));
    });
  });

  group('copyWith', () {
    test('replaces type and remark', () {
      final original = _makeFavorite();
      final updated = original.copyWith(
        type: FavoriteType.image,
        remark: 'Updated remark',
      );

      expect(updated.id, original.id);
      expect(updated.type, FavoriteType.image);
      expect(updated.remark, 'Updated remark');
      expect(updated.content, original.content);
      expect(updated.createdAt, original.createdAt);
    });

    test('replaces tags list', () {
      final original = _makeFavorite(tags: ['a', 'b']);
      final updated = original.copyWith(tags: ['c', 'd', 'e']);

      expect(updated.tags, ['c', 'd', 'e']);
    });
  });

  group('fromJson / toJson', () {
    test('round trip preserves all fields', () {
      final original = FavoriteEntity(
        id: 'fav-rt',
        type: FavoriteType.image,
        content: 'A photo',
        mediaUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
        fileSize: 204800,
        sourceRoomId: '!room:s',
        sourceSenderName: 'Alice',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000),
        tags: ['photo', 'travel'],
        remark: 'Summer trip',
      );

      final json = original.toJson();
      final restored = FavoriteEntity.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.content, original.content);
      expect(restored.mediaUrl, original.mediaUrl);
      expect(restored.fileName, original.fileName);
      expect(restored.fileSize, original.fileSize);
      expect(restored.sourceRoomId, original.sourceRoomId);
      expect(restored.sourceSenderName, original.sourceSenderName);
      expect(restored.createdAt, original.createdAt);
      expect(restored.tags, original.tags);
      expect(restored.remark, original.remark);
    });

    test('fromJson uses text as fallback for unknown type', () {
      final json = {
        'id': 'fav-unk',
        'type': 'unknown_type',
        'content': 'Unknown',
        'created_at': 1_700_000_000_000,
      };
      final entity = FavoriteEntity.fromJson(json);
      expect(entity.type, FavoriteType.text);
    });

    test('fromJson with missing tags defaults to empty list', () {
      final json = {
        'id': 'fav-notags',
        'type': 'text',
        'content': 'No tags',
        'created_at': 1_700_000_000_000,
      };
      final entity = FavoriteEntity.fromJson(json);
      expect(entity.tags, isEmpty);
    });
  });

  group('RedPacketEntity', () {
    test('constructs with defaults', () {
      final entity = RedPacketEntity(
        id: 'rp-1',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '10.0',
        token: 'ETH',
        createdAt: _createdAt,
      );

      expect(entity.type, RedPacketType.normal);
      expect(entity.count, 1);
      expect(entity.greeting, '恭喜发财，大吉大利');
      expect(entity.status, RedPacketEntityStatus.pending);
      expect(entity.claimedCount, 0);
      expect(entity.claimedAmount, '0');
      expect(entity.expiredAt, isNull);
    });

    test('canClaim is true when pending and not expired', () {
      final entity = RedPacketEntity(
        id: 'rp-2',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '1.0',
        token: 'ETH',
        createdAt: _createdAt,
        status: RedPacketEntityStatus.pending,
        expiredAt: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(entity.canClaim, isTrue);
    });

    test('canClaim is false when already expired by expiredAt', () {
      final entity = RedPacketEntity(
        id: 'rp-3',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '1.0',
        token: 'ETH',
        createdAt: _createdAt,
        status: RedPacketEntityStatus.pending,
        expiredAt: DateTime(2020, 1, 1),
      );
      expect(entity.isExpired, isTrue);
      expect(entity.canClaim, isFalse);
    });

    test('isEmpty is true when status is empty', () {
      final entity = RedPacketEntity(
        id: 'rp-4',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '1.0',
        token: 'ETH',
        createdAt: _createdAt,
        status: RedPacketEntityStatus.empty,
      );
      expect(entity.isEmpty, isTrue);
    });

    test('fromJson / toJson round trip', () {
      final original = RedPacketEntity(
        id: 'rp-rt',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '5.0',
        token: 'ETH',
        type: RedPacketType.lucky,
        count: 5,
        greeting: '发财',
        status: RedPacketEntityStatus.opened,
        claimedCount: 3,
        claimedAmount: '3.0',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000),
      );

      final json = original.toJson();
      final restored = RedPacketEntity.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.type, original.type);
      expect(restored.count, original.count);
      expect(restored.status, original.status);
      expect(restored.claimedCount, original.claimedCount);
    });
  });

  group('RedPacketType', () {
    test('has 2 values', () {
      expect(RedPacketType.values.length, 2);
    });
  });

  group('RedPacketEntityStatus', () {
    test('has 5 values', () {
      expect(RedPacketEntityStatus.values.length, 5);
    });
  });
}
