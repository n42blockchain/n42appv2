// Extended tests for GroupFileEntity — covers methods NOT in existing tests:
//   GroupFileType enum, isAudio, isDocument, isMedia,
//   typeFromMime, formattedSize, extension, formattedDuration,
//   copyWith, props equality,
//   GroupFilesStats (props, mediaCount, formattedTotalSize, fromFiles)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_file_entity.dart';

GroupFileEntity _file({
  String eventId = 'ev1',
  String name = 'file.txt',
  String url = 'mxc://a/b',
  int size = 1024,
  String mimeType = 'text/plain',
  GroupFileType fileType = GroupFileType.document,
  String senderId = '@alice:s',
  DateTime? sentAt,
  String roomId = '!room:s',
  int? duration,
}) =>
    GroupFileEntity(
      eventId: eventId,
      name: name,
      url: url,
      size: size,
      mimeType: mimeType,
      fileType: fileType,
      senderId: senderId,
      sentAt: sentAt ?? DateTime(2025, 1, 1),
      roomId: roomId,
      duration: duration,
    );

void main() {
  // ─────────────────────────────────────────────────
  // GroupFileType enum
  // ─────────────────────────────────────────────────

  group('GroupFileType', () {
    test('has 6 values', () {
      expect(GroupFileType.values, hasLength(6));
      expect(
        GroupFileType.values,
        containsAll([
          GroupFileType.image,
          GroupFileType.video,
          GroupFileType.audio,
          GroupFileType.document,
          GroupFileType.archive,
          GroupFileType.other,
        ]),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // typeFromMime
  // ─────────────────────────────────────────────────

  group('GroupFileEntity.typeFromMime', () {
    test('image mime → GroupFileType.image', () {
      expect(GroupFileEntity.typeFromMime('image/png'), GroupFileType.image);
      expect(GroupFileEntity.typeFromMime('image/jpeg'), GroupFileType.image);
    });

    test('video mime → GroupFileType.video', () {
      expect(GroupFileEntity.typeFromMime('video/mp4'), GroupFileType.video);
    });

    test('audio mime → GroupFileType.audio', () {
      expect(GroupFileEntity.typeFromMime('audio/mpeg'), GroupFileType.audio);
    });

    test('pdf mime → GroupFileType.document', () {
      expect(GroupFileEntity.typeFromMime('application/pdf'), GroupFileType.document);
    });

    test('text mime → GroupFileType.document', () {
      expect(GroupFileEntity.typeFromMime('text/plain'), GroupFileType.document);
    });

    test('zip mime → GroupFileType.archive', () {
      expect(GroupFileEntity.typeFromMime('application/zip'), GroupFileType.archive);
      expect(GroupFileEntity.typeFromMime('application/x-rar'), GroupFileType.archive);
    });

    test('unknown mime → GroupFileType.other', () {
      expect(GroupFileEntity.typeFromMime('application/octet-stream'), GroupFileType.other);
    });
  });

  // ─────────────────────────────────────────────────
  // isAudio / isDocument / isMedia
  // ─────────────────────────────────────────────────

  group('GroupFileEntity type getters', () {
    test('isAudio returns true only for audio type', () {
      expect(_file(fileType: GroupFileType.audio).isAudio, isTrue);
      expect(_file(fileType: GroupFileType.video).isAudio, isFalse);
      expect(_file(fileType: GroupFileType.image).isAudio, isFalse);
    });

    test('isDocument returns true only for document type', () {
      expect(_file(fileType: GroupFileType.document).isDocument, isTrue);
      expect(_file(fileType: GroupFileType.audio).isDocument, isFalse);
    });

    test('isMedia returns true for image, video, audio', () {
      expect(_file(fileType: GroupFileType.image).isMedia, isTrue);
      expect(_file(fileType: GroupFileType.video).isMedia, isTrue);
      expect(_file(fileType: GroupFileType.audio).isMedia, isTrue);
      expect(_file(fileType: GroupFileType.document).isMedia, isFalse);
      expect(_file(fileType: GroupFileType.archive).isMedia, isFalse);
      expect(_file(fileType: GroupFileType.other).isMedia, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // formattedSize
  // ─────────────────────────────────────────────────

  group('GroupFileEntity.formattedSize', () {
    test('bytes format when < 1 KB', () {
      expect(_file(size: 512).formattedSize, '512 B');
    });

    test('KB format when 1 KB ≤ size < 1 MB', () {
      expect(_file(size: 2048).formattedSize, '2.0 KB');
    });

    test('MB format when 1 MB ≤ size < 1 GB', () {
      expect(_file(size: 1024 * 1024 * 3).formattedSize, '3.0 MB');
    });

    test('GB format when ≥ 1 GB', () {
      expect(_file(size: 1024 * 1024 * 1024 * 2).formattedSize, '2.0 GB');
    });
  });

  // ─────────────────────────────────────────────────
  // extension
  // ─────────────────────────────────────────────────

  group('GroupFileEntity.extension', () {
    test('returns lowercase extension', () {
      expect(_file(name: 'Report.PDF').extension, 'pdf');
    });

    test('returns empty string when no dot', () {
      expect(_file(name: 'nodotfile').extension, '');
    });

    test('returns empty string when dot is last char', () {
      expect(_file(name: 'file.').extension, '');
    });
  });

  // ─────────────────────────────────────────────────
  // formattedDuration
  // ─────────────────────────────────────────────────

  group('GroupFileEntity.formattedDuration', () {
    test('returns null when duration is null', () {
      expect(_file().formattedDuration, isNull);
    });

    test('formats MM:SS correctly', () {
      expect(_file(duration: 125).formattedDuration, '02:05');
    });

    test('formats zero duration', () {
      expect(_file(duration: 0).formattedDuration, '00:00');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('GroupFileEntity.copyWith', () {
    test('changes single field', () {
      final f = _file(name: 'old.txt');
      final updated = f.copyWith(name: 'new.txt');
      expect(updated.name, 'new.txt');
      expect(updated.url, f.url);
      expect(updated.eventId, f.eventId);
    });
  });

  // ─────────────────────────────────────────────────
  // props equality
  // ─────────────────────────────────────────────────

  group('GroupFileEntity.props', () {
    test('two identical instances are equal', () {
      final a = _file(eventId: 'ev1', name: 'a.txt');
      final b = _file(eventId: 'ev1', name: 'a.txt');
      expect(a, equals(b));
    });

    test('different eventId → not equal', () {
      final a = _file(eventId: 'ev1');
      final b = _file(eventId: 'ev2');
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // GroupFilesStats
  // ─────────────────────────────────────────────────

  group('GroupFilesStats', () {
    test('default values are all zero', () {
      const s = GroupFilesStats();
      expect(s.totalCount, 0);
      expect(s.totalSize, 0);
      expect(s.imageCount, 0);
      expect(s.mediaCount, 0);
    });

    test('mediaCount sums image + video + audio', () {
      const s = GroupFilesStats(imageCount: 3, videoCount: 2, audioCount: 1);
      expect(s.mediaCount, 6);
    });

    test('formattedTotalSize shows B when < 1 KB', () {
      const s = GroupFilesStats(totalSize: 500);
      expect(s.formattedTotalSize, '500 B');
    });

    test('formattedTotalSize shows KB for KB range', () {
      const s = GroupFilesStats(totalSize: 4096);
      expect(s.formattedTotalSize, '4.0 KB');
    });

    test('props equality', () {
      const a = GroupFilesStats(totalCount: 5, imageCount: 2);
      const b = GroupFilesStats(totalCount: 5, imageCount: 2);
      expect(a, equals(b));
    });

    test('fromFiles computes counts and sizes', () {
      final files = [
        _file(fileType: GroupFileType.image, size: 1024),
        _file(fileType: GroupFileType.image, size: 2048),
        _file(fileType: GroupFileType.audio, size: 512),
        _file(fileType: GroupFileType.document, size: 256),
      ];
      final stats = GroupFilesStats.fromFiles(files);
      expect(stats.totalCount, 4);
      expect(stats.totalSize, 1024 + 2048 + 512 + 256);
      expect(stats.imageCount, 2);
      expect(stats.audioCount, 1);
      expect(stats.documentCount, 1);
      expect(stats.videoCount, 0);
      expect(stats.mediaCount, 3); // image + video + audio
    });
  });
}
