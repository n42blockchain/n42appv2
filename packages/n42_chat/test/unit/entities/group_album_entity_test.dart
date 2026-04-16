import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_album_entity.dart';

void main() {
  group('AlbumMediaType', () {
    test('should have all expected types', () {
      expect(AlbumMediaType.values, contains(AlbumMediaType.image));
      expect(AlbumMediaType.values, contains(AlbumMediaType.video));
      expect(AlbumMediaType.values.length, 2);
    });
  });

  group('AlbumMediaEntity', () {
    AlbumMediaEntity createTestMedia({
      String eventId = '\$event1',
      AlbumMediaType type = AlbumMediaType.image,
      int? width,
      int? height,
      int? duration,
      int size = 1024,
      DateTime? sentAt,
    }) {
      return AlbumMediaEntity(
        eventId: eventId,
        roomId: '!room:example.com',
        url: 'mxc://example.com/media',
        type: type,
        mimeType: type == AlbumMediaType.image ? 'image/jpeg' : 'video/mp4',
        size: size,
        width: width,
        height: height,
        duration: duration,
        senderId: '@user:example.com',
        senderName: 'Test User',
        sentAt: sentAt ?? DateTime.now(),
      );
    }

    test('should create with required fields', () {
      final media = createTestMedia();

      expect(media.eventId, '\$event1');
      expect(media.roomId, '!room:example.com');
      expect(media.type, AlbumMediaType.image);
      expect(media.isImage, true);
      expect(media.isVideo, false);
    });

    test('should identify video correctly', () {
      final video = createTestMedia(type: AlbumMediaType.video, duration: 60);

      expect(video.isImage, false);
      expect(video.isVideo, true);
      expect(video.duration, 60);
    });

    test('should calculate aspect ratio correctly', () {
      final media = createTestMedia(width: 1920, height: 1080);
      expect(media.aspectRatio, closeTo(1.78, 0.01));
    });

    test('should return null aspect ratio when dimensions missing', () {
      final media = createTestMedia();
      expect(media.aspectRatio, null);
    });

    test('should format size correctly', () {
      expect(createTestMedia(size: 500).formattedSize, '500 B');
      expect(createTestMedia(size: 1536).formattedSize, '1.5 KB');
      expect(createTestMedia(size: 1572864).formattedSize, '1.5 MB');
      expect(createTestMedia(size: 1610612736).formattedSize, '1.5 GB');
    });

    test('should format video duration correctly', () {
      expect(
        createTestMedia(type: AlbumMediaType.video, duration: 65).formattedDuration,
        '01:05',
      );
      expect(
        createTestMedia(type: AlbumMediaType.video, duration: 125).formattedDuration,
        '02:05',
      );
      expect(
        createTestMedia(type: AlbumMediaType.video, duration: 3600).formattedDuration,
        '60:00',
      );
    });

    test('should return null duration for images', () {
      final image = createTestMedia();
      expect(image.formattedDuration, null);
    });

    test('should get sender initials correctly', () {
      final media = AlbumMediaEntity(
        eventId: '1',
        roomId: 'r',
        url: 'u',
        type: AlbumMediaType.image,
        mimeType: 'image/jpeg',
        size: 100,
        senderId: 's',
        senderName: 'John Doe',
        sentAt: DateTime.now(),
      );
      expect(media.senderInitials, 'JD');
    });

    test('typeFromMime should detect types correctly', () {
      expect(AlbumMediaEntity.typeFromMime('image/jpeg'), AlbumMediaType.image);
      expect(AlbumMediaEntity.typeFromMime('image/png'), AlbumMediaType.image);
      expect(AlbumMediaEntity.typeFromMime('video/mp4'), AlbumMediaType.video);
      expect(AlbumMediaEntity.typeFromMime('video/webm'), AlbumMediaType.video);
    });

    test('copyWith should work correctly', () {
      final original = createTestMedia();
      final copy = original.copyWith(
        httpUrl: 'https://example.com/media',
        caption: 'Test caption',
      );

      expect(copy.eventId, original.eventId);
      expect(copy.httpUrl, 'https://example.com/media');
      expect(copy.caption, 'Test caption');
      expect(original.httpUrl, null);
    });
  });

  group('GroupAlbumStats', () {
    test('should create with default values', () {
      const stats = GroupAlbumStats();

      expect(stats.totalCount, 0);
      expect(stats.imageCount, 0);
      expect(stats.videoCount, 0);
      expect(stats.totalSize, 0);
    });

    test('should calculate from media list', () {
      final media = [
        AlbumMediaEntity(
          eventId: '1',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 1000,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 15),
        ),
        AlbumMediaEntity(
          eventId: '2',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.video,
          mimeType: 'video/mp4',
          size: 2000,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 16),
        ),
        AlbumMediaEntity(
          eventId: '3',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/png',
          size: 500,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 14),
        ),
      ];

      final stats = GroupAlbumStats.fromMedia(media);

      expect(stats.totalCount, 3);
      expect(stats.imageCount, 2);
      expect(stats.videoCount, 1);
      expect(stats.totalSize, 3500);
      expect(stats.oldestDate, DateTime(2024, 1, 14));
      expect(stats.newestDate, DateTime(2024, 1, 16));
    });

    test('should format total size correctly', () {
      expect(const GroupAlbumStats(totalSize: 1536).formattedTotalSize, '1.5 KB');
      expect(const GroupAlbumStats(totalSize: 1572864).formattedTotalSize, '1.5 MB');
    });
  });

  group('AlbumDateGroup', () {
    test('should create with required fields', () {
      final date = DateTime(2024, 1, 15);
      final media = [
        AlbumMediaEntity(
          eventId: '1',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: date,
        ),
      ];

      final group = AlbumDateGroup(date: date, media: media);

      expect(group.date, date);
      expect(group.count, 1);
    });

    test('should group media by date', () {
      final media = [
        AlbumMediaEntity(
          eventId: '1',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 15, 10, 0),
        ),
        AlbumMediaEntity(
          eventId: '2',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 15, 14, 0),
        ),
        AlbumMediaEntity(
          eventId: '3',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 16, 10, 0),
        ),
      ];

      final groups = AlbumDateGroup.groupByDate(media);

      expect(groups.length, 2);
      expect(groups[0].date, DateTime(2024, 1, 16)); // Most recent first
      expect(groups[0].count, 1);
      expect(groups[1].date, DateTime(2024, 1, 15));
      expect(groups[1].count, 2);
    });

    test('should return empty list for empty media', () {
      final groups = AlbumDateGroup.groupByDate([]);
      expect(groups, isEmpty);
    });
  });

  group('AlbumMonthGroup', () {
    test('should group media by month', () {
      final media = [
        AlbumMediaEntity(
          eventId: '1',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 15),
        ),
        AlbumMediaEntity(
          eventId: '2',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 2, 10),
        ),
        AlbumMediaEntity(
          eventId: '3',
          roomId: 'r',
          url: 'u',
          type: AlbumMediaType.image,
          mimeType: 'image/jpeg',
          size: 100,
          senderId: 's',
          senderName: 'User',
          sentAt: DateTime(2024, 1, 20),
        ),
      ];

      final groups = AlbumMonthGroup.groupByMonth(media);

      expect(groups.length, 2);
      expect(groups[0].year, 2024);
      expect(groups[0].month, 2);
      expect(groups[0].count, 1);
      expect(groups[1].month, 1);
      expect(groups[1].count, 2);
    });
  });

  group('AlbumFilter', () {
    final testMedia = [
      AlbumMediaEntity(
        eventId: '1',
        roomId: 'r',
        url: 'u',
        type: AlbumMediaType.image,
        mimeType: 'image/jpeg',
        size: 100,
        senderId: '@alice:example.com',
        senderName: 'Alice',
        sentAt: DateTime(2024, 1, 15),
      ),
      AlbumMediaEntity(
        eventId: '2',
        roomId: 'r',
        url: 'u',
        type: AlbumMediaType.video,
        mimeType: 'video/mp4',
        size: 200,
        senderId: '@bob:example.com',
        senderName: 'Bob',
        sentAt: DateTime(2024, 1, 20),
      ),
      AlbumMediaEntity(
        eventId: '3',
        roomId: 'r',
        url: 'u',
        type: AlbumMediaType.image,
        mimeType: 'image/png',
        size: 150,
        senderId: '@alice:example.com',
        senderName: 'Alice',
        sentAt: DateTime(2024, 2, 1),
      ),
    ];

    test('none filter should match all', () {
      final result = AlbumFilter.none.apply(testMedia);
      expect(result.length, 3);
    });

    test('imagesOnly should filter images', () {
      final result = AlbumFilter.imagesOnly.apply(testMedia);
      expect(result.length, 2);
      expect(result.every((m) => m.isImage), true);
    });

    test('videosOnly should filter videos', () {
      final result = AlbumFilter.videosOnly.apply(testMedia);
      expect(result.length, 1);
      expect(result.first.isVideo, true);
    });

    test('should filter by sender', () {
      const filter = AlbumFilter(senderId: '@alice:example.com');
      final result = filter.apply(testMedia);

      expect(result.length, 2);
      expect(result.every((m) => m.senderId == '@alice:example.com'), true);
    });

    test('should filter by date range', () {
      final filter = AlbumFilter(
        startDate: DateTime(2024, 1, 16),
        endDate: DateTime(2024, 1, 25),
      );
      final result = filter.apply(testMedia);

      expect(result.length, 1);
      expect(result.first.eventId, '2');
    });

    test('should combine filters', () {
      const filter = AlbumFilter(
        mediaType: AlbumMediaType.image,
        senderId: '@alice:example.com',
      );
      final result = filter.apply(testMedia);

      expect(result.length, 2);
    });

    test('hasFilter should detect active filters', () {
      expect(AlbumFilter.none.hasFilter, false);
      expect(AlbumFilter.imagesOnly.hasFilter, true);
      expect(const AlbumFilter(senderId: 'test').hasFilter, true);
    });

    test('copyWith should work correctly', () {
      const original = AlbumFilter(mediaType: AlbumMediaType.image);
      final copy = original.copyWith(senderId: '@user:example.com');

      expect(copy.mediaType, AlbumMediaType.image);
      expect(copy.senderId, '@user:example.com');
    });

    test('copyWith should clear fields', () {
      const original = AlbumFilter(
        mediaType: AlbumMediaType.image,
        senderId: '@user:example.com',
      );
      final copy = original.copyWith(clearMediaType: true);

      expect(copy.mediaType, null);
      expect(copy.senderId, '@user:example.com');
    });
  });
}
