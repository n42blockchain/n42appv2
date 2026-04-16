// Tests for StorageInfo, RoomStorageInfo, and MediaExtensions.
// All classes under test are pure Dart — no platform channels or file-system
// calls are needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';

void main() {
  // ─────────────────────────────────────────────────
  // StorageInfo.formatSize  (static, pure)
  // ─────────────────────────────────────────────────

  group('StorageInfo.formatSize', () {
    test('0 bytes → "0 B"', () {
      expect(StorageInfo.formatSize(0), '0 B');
    });

    test('1 byte → "1 B"', () {
      expect(StorageInfo.formatSize(1), '1 B');
    });

    test('1023 bytes → "1023 B" (below 1 KB threshold)', () {
      expect(StorageInfo.formatSize(1023), '1023 B');
    });

    test('1024 bytes → "1.0 KB"', () {
      expect(StorageInfo.formatSize(1024), '1.0 KB');
    });

    test('1536 bytes → "1.5 KB"', () {
      expect(StorageInfo.formatSize(1536), '1.5 KB');
    });

    test('1024 * 1024 - 1 bytes → KB representation', () {
      // Just below 1 MB — still KB
      final result = StorageInfo.formatSize(1024 * 1024 - 1);
      expect(result.endsWith('KB'), isTrue);
    });

    test('1 MB (1024*1024) → "1.0 MB"', () {
      expect(StorageInfo.formatSize(1024 * 1024), '1.0 MB');
    });

    test('2.5 MB → "2.5 MB"', () {
      expect(StorageInfo.formatSize((2.5 * 1024 * 1024).round()), '2.5 MB');
    });

    test('1 GB (1024^3) → "1.0 GB"', () {
      expect(StorageInfo.formatSize(1024 * 1024 * 1024), '1.0 GB');
    });

    test('1.5 GB → "1.5 GB"', () {
      expect(StorageInfo.formatSize((1.5 * 1024 * 1024 * 1024).round()), '1.5 GB');
    });
  });

  // ─────────────────────────────────────────────────
  // StorageInfo — constructor & getters
  // ─────────────────────────────────────────────────

  group('StorageInfo constructor defaults', () {
    const info = StorageInfo();

    test('all sizes default to 0', () {
      expect(info.totalSize, 0);
      expect(info.mediaSize, 0);
      expect(info.fileSize, 0);
      expect(info.cacheSize, 0);
      expect(info.otherSize, 0);
    });

    test('formatted getters return "0 B" for all-zero instance', () {
      expect(info.formattedTotal, '0 B');
      expect(info.formattedMedia, '0 B');
      expect(info.formattedFile, '0 B');
      expect(info.formattedCache, '0 B');
      expect(info.formattedOther, '0 B');
    });
  });

  group('StorageInfo named constructor', () {
    const info = StorageInfo(
      totalSize: 1024 * 1024 * 10,  // 10 MB
      mediaSize: 1024 * 1024 * 7,   // 7 MB
      fileSize: 1024 * 1024 * 2,    // 2 MB
      cacheSize: 512 * 1024,         // 0.5 MB
      otherSize: 512 * 1024,         // 0.5 MB
    );

    test('stores provided sizes', () {
      expect(info.totalSize, 1024 * 1024 * 10);
      expect(info.mediaSize, 1024 * 1024 * 7);
    });

    test('formatted getters reflect actual sizes', () {
      expect(info.formattedTotal, '10.0 MB');
      expect(info.formattedMedia, '7.0 MB');
      expect(info.formattedFile, '2.0 MB');
      expect(info.formattedCache, '512.0 KB');
    });
  });

  // ─────────────────────────────────────────────────
  // RoomStorageInfo
  // ─────────────────────────────────────────────────

  group('RoomStorageInfo', () {
    test('constructor stores fields correctly', () {
      const info = RoomStorageInfo(
        roomId: '!abc:server.com',
        roomName: 'My Room',
        totalSize: 2 * 1024 * 1024,
        mediaCount: 5,
        fileCount: 2,
      );
      expect(info.roomId, '!abc:server.com');
      expect(info.roomName, 'My Room');
      expect(info.mediaCount, 5);
      expect(info.fileCount, 2);
    });

    test('formattedSize delegates to StorageInfo.formatSize', () {
      const info = RoomStorageInfo(
        roomId: '!r:s',
        roomName: 'R',
        totalSize: 1024 * 1024,
      );
      expect(info.formattedSize, '1.0 MB');
    });

    test('defaults: mediaCount and fileCount are 0', () {
      const info = RoomStorageInfo(roomId: '!r:s', roomName: 'R');
      expect(info.mediaCount, 0);
      expect(info.fileCount, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // MediaExtensions — constant sets
  // ─────────────────────────────────────────────────

  group('MediaExtensions sets', () {
    test('image set contains expected extensions', () {
      expect(MediaExtensions.image, containsAll(['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg']));
    });

    test('video set contains expected extensions', () {
      expect(MediaExtensions.video, containsAll(['mp4', 'mov', 'avi', 'mkv', 'webm']));
    });

    test('audio set contains expected extensions', () {
      expect(MediaExtensions.audio, containsAll(['mp3', 'ogg', 'wav', 'm4a', 'aac']));
    });

    test('document set contains expected extensions', () {
      expect(MediaExtensions.document, containsAll(['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']));
    });

    test('allMedia is union of image + video + audio', () {
      for (final ext in MediaExtensions.image) {
        expect(MediaExtensions.allMedia, contains(ext));
      }
      for (final ext in MediaExtensions.video) {
        expect(MediaExtensions.allMedia, contains(ext));
      }
      for (final ext in MediaExtensions.audio) {
        expect(MediaExtensions.allMedia, contains(ext));
      }
    });

    test('document extensions are NOT in allMedia', () {
      for (final ext in MediaExtensions.document) {
        expect(MediaExtensions.allMedia, isNot(contains(ext)));
      }
    });
  });

  // ─────────────────────────────────────────────────
  // MediaExtensions.isMedia
  // ─────────────────────────────────────────────────

  group('MediaExtensions.isMedia', () {
    test('image extensions return true', () {
      for (final ext in ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg']) {
        expect(MediaExtensions.isMedia(ext), isTrue, reason: '.$ext should be media');
      }
    });

    test('video extensions return true', () {
      for (final ext in ['mp4', 'mov', 'avi', 'mkv', 'webm']) {
        expect(MediaExtensions.isMedia(ext), isTrue, reason: '.$ext should be media');
      }
    });

    test('audio extensions return true', () {
      for (final ext in ['mp3', 'ogg', 'wav', 'm4a', 'aac']) {
        expect(MediaExtensions.isMedia(ext), isTrue, reason: '.$ext should be media');
      }
    });

    test('document extensions return false', () {
      for (final ext in ['pdf', 'doc', 'docx', 'txt', 'zip']) {
        expect(MediaExtensions.isMedia(ext), isFalse, reason: '.$ext should not be media');
      }
    });

    test('uppercase extension is case-folded and recognised', () {
      expect(MediaExtensions.isMedia('JPG'), isTrue);
      expect(MediaExtensions.isMedia('MP4'), isTrue);
      expect(MediaExtensions.isMedia('MP3'), isTrue);
    });

    test('mixed-case extension is recognised', () {
      expect(MediaExtensions.isMedia('Png'), isTrue);
      expect(MediaExtensions.isMedia('MOV'), isTrue);
    });

    test('unknown extension returns false', () {
      expect(MediaExtensions.isMedia('xyz'), isFalse);
      expect(MediaExtensions.isMedia(''), isFalse);
      expect(MediaExtensions.isMedia('dart'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // MediaExtensions.isDocument
  // ─────────────────────────────────────────────────

  group('MediaExtensions.isDocument', () {
    test('document extensions return true', () {
      for (final ext in ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar']) {
        expect(MediaExtensions.isDocument(ext), isTrue, reason: '.$ext should be document');
      }
    });

    test('image extensions return false', () {
      for (final ext in ['jpg', 'png', 'gif']) {
        expect(MediaExtensions.isDocument(ext), isFalse, reason: '.$ext should not be document');
      }
    });

    test('uppercase extension is case-folded and recognised', () {
      expect(MediaExtensions.isDocument('PDF'), isTrue);
      expect(MediaExtensions.isDocument('DOCX'), isTrue);
    });

    test('unknown extension returns false', () {
      expect(MediaExtensions.isDocument('dart'), isFalse);
      expect(MediaExtensions.isDocument(''), isFalse);
    });
  });
}
