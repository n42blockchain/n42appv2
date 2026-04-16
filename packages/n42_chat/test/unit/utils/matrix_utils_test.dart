import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/utils/matrix_utils.dart';

class _MockClient extends Mock implements matrix.Client {}

void main() {
  // ─────────────────────────────────────────────────
  // getUsernameFromUserId
  // ─────────────────────────────────────────────────

  group('MatrixUtils.getUsernameFromUserId', () {
    test('extracts username from full Matrix ID', () {
      expect(MatrixUtils.getUsernameFromUserId('@alice:server.com'), 'alice');
    });

    test('extracts username from ID without subdomain', () {
      expect(MatrixUtils.getUsernameFromUserId('@bob:matrix.org'), 'bob');
    });

    test('@ only prefix without colon returns everything after @', () {
      expect(MatrixUtils.getUsernameFromUserId('@alice'), 'alice');
    });

    test('null returns null', () {
      expect(MatrixUtils.getUsernameFromUserId(null), isNull);
    });

    test('string without @ prefix returns null', () {
      expect(MatrixUtils.getUsernameFromUserId('alice:server.com'), isNull);
    });

    test('preserves underscores and digits in username', () {
      expect(
        MatrixUtils.getUsernameFromUserId('@user_123:server.com'),
        'user_123',
      );
    });
  });

  // ─────────────────────────────────────────────────
  // getServerFromUserId
  // ─────────────────────────────────────────────────

  group('MatrixUtils.getServerFromUserId', () {
    test('extracts server from full Matrix ID', () {
      expect(
        MatrixUtils.getServerFromUserId('@alice:server.com'),
        'server.com',
      );
    });

    test('extracts multi-part server name', () {
      expect(
        MatrixUtils.getServerFromUserId('@bob:matrix.example.org'),
        'matrix.example.org',
      );
    });

    test('null returns null', () {
      expect(MatrixUtils.getServerFromUserId(null), isNull);
    });

    test('string without colon returns null', () {
      expect(MatrixUtils.getServerFromUserId('@alice'), isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // getAvatarInitials
  // ─────────────────────────────────────────────────

  group('MatrixUtils.getAvatarInitials', () {
    test('uses displayName when provided', () {
      expect(MatrixUtils.getAvatarInitials('Alice', '@alice:server.com'), 'AL');
    });

    test('falls back to userId when displayName is null', () {
      expect(MatrixUtils.getAvatarInitials(null, '@alice:server.com'), 'AL');
    });

    test('falls back to ? when both are null', () {
      expect(MatrixUtils.getAvatarInitials(null, null), '?');
    });

    test('empty displayName returns first 2 chars or less', () {
      expect(MatrixUtils.getAvatarInitials('', null), '?');
    });

    test('single-word name returns first 2 chars uppercased', () {
      expect(MatrixUtils.getAvatarInitials('alice', null), 'AL');
    });

    test('single character name returns that character uppercased', () {
      expect(MatrixUtils.getAvatarInitials('a', null), 'A');
    });

    test('two-word name returns initials of each word', () {
      expect(MatrixUtils.getAvatarInitials('Alice Bob', null), 'AB');
    });

    test('three-word name returns only first two initials', () {
      expect(MatrixUtils.getAvatarInitials('Alice Bob Charlie', null), 'AB');
    });

    test('multiple spaces between words are ignored', () {
      expect(MatrixUtils.getAvatarInitials('Alice  Bob', null), 'AB');
    });
  });

  // ─────────────────────────────────────────────────
  // formatFileSize
  // ─────────────────────────────────────────────────

  group('MatrixUtils.formatFileSize', () {
    test('null returns empty string', () {
      expect(MatrixUtils.formatFileSize(null), '');
    });

    test('0 returns empty string', () {
      expect(MatrixUtils.formatFileSize(0), '');
    });

    test('negative returns empty string', () {
      expect(MatrixUtils.formatFileSize(-1), '');
    });

    test('bytes (< 1024) shows B', () {
      expect(MatrixUtils.formatFileSize(500), '500 B');
    });

    test('exactly 1 KB', () {
      expect(MatrixUtils.formatFileSize(1024), '1.0 KB');
    });

    test('2 KB', () {
      expect(MatrixUtils.formatFileSize(2048), '2.0 KB');
    });

    test('exactly 1 MB', () {
      expect(MatrixUtils.formatFileSize(1024 * 1024), '1.0 MB');
    });

    test('exactly 1 GB', () {
      expect(MatrixUtils.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
    });

    test('1 byte shows B', () {
      expect(MatrixUtils.formatFileSize(1), '1 B');
    });
  });

  // ─────────────────────────────────────────────────
  // formatDuration (milliseconds)
  // ─────────────────────────────────────────────────

  group('MatrixUtils.formatDuration', () {
    test('null returns "0:00"', () {
      expect(MatrixUtils.formatDuration(null), '0:00');
    });

    test('0 ms returns "0:00"', () {
      expect(MatrixUtils.formatDuration(0), '0:00');
    });

    test('30 000 ms returns "0:30"', () {
      expect(MatrixUtils.formatDuration(30000), '0:30');
    });

    test('60 000 ms returns "1:00"', () {
      expect(MatrixUtils.formatDuration(60000), '1:00');
    });

    test('90 000 ms returns "1:30"', () {
      expect(MatrixUtils.formatDuration(90000), '1:30');
    });

    test('seconds are zero-padded', () {
      expect(MatrixUtils.formatDuration(5000), '0:05');
    });

    test('2 minutes returns "2:00"', () {
      expect(MatrixUtils.formatDuration(120000), '2:00');
    });
  });

  // ─────────────────────────────────────────────────
  // formatVoiceDuration (seconds)
  // ─────────────────────────────────────────────────

  group('MatrixUtils.formatVoiceDuration', () {
    test('0 seconds shows 0"', () {
      expect(MatrixUtils.formatVoiceDuration(0), '0"');
    });

    test('30 seconds shows 30"', () {
      expect(MatrixUtils.formatVoiceDuration(30), '30"');
    });

    test('59 seconds shows 59"', () {
      expect(MatrixUtils.formatVoiceDuration(59), '59"');
    });

    test("exactly 60 seconds shows 1'", () {
      expect(MatrixUtils.formatVoiceDuration(60), "1'");
    });

    test("90 seconds shows 1'30\"", () {
      expect(MatrixUtils.formatVoiceDuration(90), "1'30\"");
    });

    test("exactly 2 minutes shows 2'", () {
      expect(MatrixUtils.formatVoiceDuration(120), "2'");
    });

    test("75 seconds shows 1'15\"", () {
      expect(MatrixUtils.formatVoiceDuration(75), "1'15\"");
    });
  });

  // ─────────────────────────────────────────────────
  // getMimeType
  // ─────────────────────────────────────────────────

  group('MatrixUtils.getMimeType', () {
    test('jpg returns image/jpeg', () {
      expect(MatrixUtils.getMimeType('photo.jpg'), 'image/jpeg');
    });

    test('jpeg returns image/jpeg', () {
      expect(MatrixUtils.getMimeType('photo.jpeg'), 'image/jpeg');
    });

    test('png returns image/png', () {
      expect(MatrixUtils.getMimeType('image.png'), 'image/png');
    });

    test('gif returns image/gif', () {
      expect(MatrixUtils.getMimeType('anim.gif'), 'image/gif');
    });

    test('mp3 returns audio/mpeg', () {
      expect(MatrixUtils.getMimeType('song.mp3'), 'audio/mpeg');
    });

    test('ogg returns audio/ogg', () {
      expect(MatrixUtils.getMimeType('voice.ogg'), 'audio/ogg');
    });

    test('mp4 returns video/mp4', () {
      expect(MatrixUtils.getMimeType('video.mp4'), 'video/mp4');
    });

    test('pdf returns application/pdf', () {
      expect(MatrixUtils.getMimeType('doc.pdf'), 'application/pdf');
    });

    test('txt returns text/plain', () {
      expect(MatrixUtils.getMimeType('notes.txt'), 'text/plain');
    });

    test('zip returns application/zip', () {
      expect(MatrixUtils.getMimeType('archive.zip'), 'application/zip');
    });

    test('unknown extension returns application/octet-stream', () {
      expect(MatrixUtils.getMimeType('file.xyz'), 'application/octet-stream');
    });

    test('extension detection is case-insensitive', () {
      expect(MatrixUtils.getMimeType('IMAGE.JPG'), 'image/jpeg');
    });
  });

  // ─────────────────────────────────────────────────
  // getMessageTypeFromMime
  // ─────────────────────────────────────────────────

  group('MatrixUtils.getMessageTypeFromMime', () {
    test('null returns m.file', () {
      expect(MatrixUtils.getMessageTypeFromMime(null), 'm.file');
    });

    test('image/* returns m.image', () {
      expect(MatrixUtils.getMessageTypeFromMime('image/jpeg'), 'm.image');
      expect(MatrixUtils.getMessageTypeFromMime('image/png'), 'm.image');
    });

    test('audio/* returns m.audio', () {
      expect(MatrixUtils.getMessageTypeFromMime('audio/mpeg'), 'm.audio');
      expect(MatrixUtils.getMessageTypeFromMime('audio/ogg'), 'm.audio');
    });

    test('video/* returns m.video', () {
      expect(MatrixUtils.getMessageTypeFromMime('video/mp4'), 'm.video');
    });

    test('application/* returns m.file', () {
      expect(MatrixUtils.getMessageTypeFromMime('application/pdf'), 'm.file');
    });

    test('text/* returns m.file', () {
      expect(MatrixUtils.getMessageTypeFromMime('text/plain'), 'm.file');
    });
  });

  // ─────────────────────────────────────────────────
  // ensureFileExtension
  // ─────────────────────────────────────────────────

  group('MatrixUtils.ensureFileExtension', () {
    test('filename with extension is unchanged', () {
      expect(
        MatrixUtils.ensureFileExtension('photo.jpg', '/path/photo.jpg'),
        'photo.jpg',
      );
    });

    test('filename without extension gets extension from path', () {
      expect(
        MatrixUtils.ensureFileExtension('photo', '/path/to/photo.jpg'),
        'photo.jpg',
      );
    });

    test('filename without extension and no path ext returns unchanged', () {
      // path ext would be 'path/to/photonoext' → last split = 'photonoext' (length > 5?)
      // Actually 'photonoext'.length = 10 > 5 → not added
      expect(
        MatrixUtils.ensureFileExtension('file', '/path/to/filenamenoext'),
        'file',
      );
    });

    test('path with short extension (≤5 chars) is applied', () {
      expect(
        MatrixUtils.ensureFileExtension('video', '/tmp/clip.webm'),
        'video.webm',
      );
    });
  });

  group('MatrixUtils media helpers', () {
    late _MockClient client;

    setUp(() {
      client = _MockClient();
      when(
        () => client.homeserver,
      ).thenReturn(Uri.parse('https://matrix.example.com'));
      when(() => client.accessToken).thenReturn('secret-token');
    });

    test('getMediaDownloadUrl builds authenticated media download URL', () {
      expect(
        MatrixUtils.getMediaDownloadUrl(
          'mxc://cdn.example.com/media123',
          client: client,
        ),
        'https://matrix.example.com/_matrix/client/v1/media/download/cdn.example.com/media123',
      );
    });

    test('getAvatarUrl builds thumbnail crop URL', () {
      expect(
        MatrixUtils.getAvatarUrl(
          'mxc://cdn.example.com/avatar123',
          client: client,
          size: 96,
        ),
        'https://matrix.example.com/_matrix/client/v1/media/thumbnail/cdn.example.com/avatar123?width=96&height=96&method=crop',
      );
    });

    test(
      'buildAuthenticatedMediaHeaders only sends token to same homeserver',
      () {
        expect(
          MatrixUtils.buildAuthenticatedMediaHeaders(
            'https://matrix.example.com/_matrix/client/v1/media/download/cdn.example.com/media123',
            client: client,
          ),
          const {'Authorization': 'Bearer secret-token'},
        );
      },
    );

    test('buildAuthenticatedMediaHeaders rejects port mismatch', () {
      expect(
        MatrixUtils.buildAuthenticatedMediaHeaders(
          'https://matrix.example.com:8448/_matrix/client/v1/media/download/cdn.example.com/media123',
          client: client,
        ),
        isEmpty,
      );
    });

    test('buildAuthenticatedMediaHeaders rejects different host', () {
      expect(
        MatrixUtils.buildAuthenticatedMediaHeaders(
          'https://cdn.example.com/_matrix/client/v1/media/download/cdn.example.com/media123',
          client: client,
        ),
        isEmpty,
      );
    });
  });
}
