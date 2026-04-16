import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_file_entity.dart';

void main() {
  group('GroupFileType', () {
    test('should have all expected types', () {
      expect(GroupFileType.values, contains(GroupFileType.image));
      expect(GroupFileType.values, contains(GroupFileType.video));
      expect(GroupFileType.values, contains(GroupFileType.audio));
      expect(GroupFileType.values, contains(GroupFileType.document));
      expect(GroupFileType.values, contains(GroupFileType.archive));
      expect(GroupFileType.values, contains(GroupFileType.other));
      expect(GroupFileType.values.length, 6);
    });
  });

  group('GroupFileEntity', () {
    test('should create with required fields', () {
      final file = GroupFileEntity(
        eventId: '\$event1',
        name: 'document.pdf',
        url: 'mxc://example.com/abc123',
        size: 1024000,
        mimeType: 'application/pdf',
        fileType: GroupFileType.document,
        senderId: '@user:example.com',
        sentAt: DateTime(2024, 1, 15),
        roomId: '!room:example.com',
      );

      expect(file.eventId, '\$event1');
      expect(file.name, 'document.pdf');
      expect(file.url, 'mxc://example.com/abc123');
      expect(file.size, 1024000);
      expect(file.mimeType, 'application/pdf');
      expect(file.fileType, GroupFileType.document);
      expect(file.senderId, '@user:example.com');
      expect(file.httpUrl, null);
      expect(file.thumbnailUrl, null);
    });

    test('should create image file with dimensions', () {
      final image = GroupFileEntity(
        eventId: '\$event2',
        name: 'photo.jpg',
        url: 'mxc://example.com/photo',
        httpUrl: 'https://example.com/photo.jpg',
        size: 512000,
        mimeType: 'image/jpeg',
        fileType: GroupFileType.image,
        senderId: '@user:example.com',
        sentAt: DateTime(2024, 1, 15),
        roomId: '!room:example.com',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        width: 1920,
        height: 1080,
      );

      expect(image.isImage, true);
      expect(image.isMedia, true);
      expect(image.width, 1920);
      expect(image.height, 1080);
      expect(image.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('should create video file with duration', () {
      final video = GroupFileEntity(
        eventId: '\$event3',
        name: 'video.mp4',
        url: 'mxc://example.com/video',
        size: 10240000,
        mimeType: 'video/mp4',
        fileType: GroupFileType.video,
        senderId: '@user:example.com',
        sentAt: DateTime(2024, 1, 15),
        roomId: '!room:example.com',
        width: 1280,
        height: 720,
        duration: 125,
      );

      expect(video.isVideo, true);
      expect(video.isMedia, true);
      expect(video.duration, 125);
      expect(video.formattedDuration, '02:05');
    });

    test('typeFromMime should detect image types', () {
      expect(GroupFileEntity.typeFromMime('image/png'), GroupFileType.image);
      expect(GroupFileEntity.typeFromMime('image/jpeg'), GroupFileType.image);
      expect(GroupFileEntity.typeFromMime('image/gif'), GroupFileType.image);
      expect(GroupFileEntity.typeFromMime('image/webp'), GroupFileType.image);
    });

    test('typeFromMime should detect video types', () {
      expect(GroupFileEntity.typeFromMime('video/mp4'), GroupFileType.video);
      expect(GroupFileEntity.typeFromMime('video/webm'), GroupFileType.video);
      expect(GroupFileEntity.typeFromMime('video/quicktime'), GroupFileType.video);
    });

    test('typeFromMime should detect audio types', () {
      expect(GroupFileEntity.typeFromMime('audio/mpeg'), GroupFileType.audio);
      expect(GroupFileEntity.typeFromMime('audio/ogg'), GroupFileType.audio);
      expect(GroupFileEntity.typeFromMime('audio/wav'), GroupFileType.audio);
    });

    test('typeFromMime should detect document types', () {
      expect(GroupFileEntity.typeFromMime('application/pdf'), GroupFileType.document);
      expect(GroupFileEntity.typeFromMime('text/plain'), GroupFileType.document);
      expect(
        GroupFileEntity.typeFromMime('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        GroupFileType.document,
      );
    });

    test('typeFromMime should detect archive types', () {
      expect(GroupFileEntity.typeFromMime('application/zip'), GroupFileType.archive);
      expect(GroupFileEntity.typeFromMime('application/x-rar-compressed'), GroupFileType.archive);
      expect(GroupFileEntity.typeFromMime('application/x-tar'), GroupFileType.archive);
      expect(GroupFileEntity.typeFromMime('application/gzip'), GroupFileType.archive);
    });

    test('formattedSize should format correctly', () {
      expect(
        GroupFileEntity(
          eventId: '1', name: 'f', url: 'u', size: 500,
          mimeType: 'm', fileType: GroupFileType.other,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).formattedSize,
        '500 B',
      );

      expect(
        GroupFileEntity(
          eventId: '1', name: 'f', url: 'u', size: 1536,
          mimeType: 'm', fileType: GroupFileType.other,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).formattedSize,
        '1.5 KB',
      );

      expect(
        GroupFileEntity(
          eventId: '1', name: 'f', url: 'u', size: 1572864,
          mimeType: 'm', fileType: GroupFileType.other,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).formattedSize,
        '1.5 MB',
      );

      expect(
        GroupFileEntity(
          eventId: '1', name: 'f', url: 'u', size: 1610612736,
          mimeType: 'm', fileType: GroupFileType.other,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).formattedSize,
        '1.5 GB',
      );
    });

    test('extension should extract correctly', () {
      expect(
        GroupFileEntity(
          eventId: '1', name: 'document.pdf', url: 'u', size: 100,
          mimeType: 'm', fileType: GroupFileType.document,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).extension,
        'pdf',
      );

      expect(
        GroupFileEntity(
          eventId: '1', name: 'photo.JPG', url: 'u', size: 100,
          mimeType: 'm', fileType: GroupFileType.image,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).extension,
        'jpg',
      );

      expect(
        GroupFileEntity(
          eventId: '1', name: 'noextension', url: 'u', size: 100,
          mimeType: 'm', fileType: GroupFileType.other,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ).extension,
        '',
      );
    });

    test('copyWith should create new instance with updated values', () {
      final original = GroupFileEntity(
        eventId: '\$event1',
        name: 'original.pdf',
        url: 'mxc://example.com/original',
        size: 1024,
        mimeType: 'application/pdf',
        fileType: GroupFileType.document,
        senderId: '@user:example.com',
        sentAt: DateTime(2024, 1, 15),
        roomId: '!room:example.com',
      );

      final modified = original.copyWith(
        name: 'modified.pdf',
        httpUrl: 'https://example.com/modified.pdf',
      );

      expect(modified.eventId, '\$event1');
      expect(modified.name, 'modified.pdf');
      expect(modified.httpUrl, 'https://example.com/modified.pdf');
      expect(original.name, 'original.pdf');
      expect(original.httpUrl, null);
    });
  });

  group('GroupFilesStats', () {
    test('should create with default values', () {
      const stats = GroupFilesStats();

      expect(stats.totalCount, 0);
      expect(stats.totalSize, 0);
      expect(stats.imageCount, 0);
      expect(stats.videoCount, 0);
      expect(stats.audioCount, 0);
      expect(stats.documentCount, 0);
      expect(stats.otherCount, 0);
      expect(stats.mediaCount, 0);
    });

    test('should calculate from file list', () {
      final files = [
        GroupFileEntity(
          eventId: '1', name: 'photo.jpg', url: 'u', size: 1000,
          mimeType: 'image/jpeg', fileType: GroupFileType.image,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ),
        GroupFileEntity(
          eventId: '2', name: 'video.mp4', url: 'u', size: 2000,
          mimeType: 'video/mp4', fileType: GroupFileType.video,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ),
        GroupFileEntity(
          eventId: '3', name: 'doc.pdf', url: 'u', size: 500,
          mimeType: 'application/pdf', fileType: GroupFileType.document,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ),
        GroupFileEntity(
          eventId: '4', name: 'song.mp3', url: 'u', size: 1500,
          mimeType: 'audio/mpeg', fileType: GroupFileType.audio,
          senderId: 's', sentAt: DateTime.now(), roomId: 'r',
        ),
      ];

      final stats = GroupFilesStats.fromFiles(files);

      expect(stats.totalCount, 4);
      expect(stats.totalSize, 5000);
      expect(stats.imageCount, 1);
      expect(stats.videoCount, 1);
      expect(stats.audioCount, 1);
      expect(stats.documentCount, 1);
      expect(stats.mediaCount, 3);
    });

    test('formattedTotalSize should format correctly', () {
      expect(
        const GroupFilesStats(totalSize: 1536).formattedTotalSize,
        '1.5 KB',
      );

      expect(
        const GroupFilesStats(totalSize: 1572864).formattedTotalSize,
        '1.5 MB',
      );
    });
  });
}
