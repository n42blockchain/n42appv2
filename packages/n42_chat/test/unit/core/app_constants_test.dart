// Tests for AppConstants and StorageConstants in app_constants.dart.
// All fields are pure Dart constants (int, String, double, RegExp) — no deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/constants/app_constants.dart';

void main() {
  // ─────────────────────────────────────────────────
  // AppConstants — app info
  // ─────────────────────────────────────────────────

  group('AppConstants — app info', () {
    test('appName is N42 Chat', () {
      expect(AppConstants.appName, 'N42 Chat');
    });

    test('appVersion is 0.1.0', () {
      expect(AppConstants.appVersion, '0.1.0');
    });

    test('packageName is com.n42.chat', () {
      expect(AppConstants.packageName, 'com.n42.chat');
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — Matrix
  // ─────────────────────────────────────────────────

  group('AppConstants — Matrix', () {
    test('defaultHomeserver matches chat config default', () {
      expect(AppConstants.defaultHomeserver, 'https://m.si46.world');
    });

    test('popularHomeservers has 4 entries', () {
      expect(AppConstants.popularHomeservers, hasLength(4));
    });

    test('popularHomeservers contains default homeserver first', () {
      expect(
        AppConstants.popularHomeservers.first,
        AppConstants.defaultHomeserver,
      );
    });

    test('popularHomeservers contains matrix.org', () {
      expect(AppConstants.popularHomeservers, contains('https://matrix.org'));
    });

    test('popularHomeservers contains matrix.im', () {
      expect(AppConstants.popularHomeservers, contains('https://matrix.im'));
    });

    test('popularHomeservers contains tchncs.de', () {
      expect(AppConstants.popularHomeservers, contains('https://tchncs.de'));
    });

    test('popularHomeservers contains m.si46.world', () {
      expect(AppConstants.popularHomeservers, contains('https://m.si46.world'));
    });

    test('syncTimeout is 30', () {
      expect(AppConstants.syncTimeout, 30);
    });

    test('messagesPerPage is 50', () {
      expect(AppConstants.messagesPerPage, 50);
    });

    test('maxRetryCount is 5', () {
      expect(AppConstants.maxRetryCount, 5);
    });

    test('retryDelayMs is 1000', () {
      expect(AppConstants.retryDelayMs, 1000);
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — message
  // ─────────────────────────────────────────────────

  group('AppConstants — message', () {
    test('messageDeleteTimeout is 120', () {
      expect(AppConstants.messageDeleteTimeout, 120);
    });

    test('timeSeparatorThreshold is 5', () {
      expect(AppConstants.timeSeparatorThreshold, 5);
    });

    test('inputMaxLines is 6', () {
      expect(AppConstants.inputMaxLines, 6);
    });

    test('messageMaxLength is 10000', () {
      expect(AppConstants.messageMaxLength, 10000);
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — media
  // ─────────────────────────────────────────────────

  group('AppConstants — media', () {
    test('maxImageSize is 10 MB', () {
      expect(AppConstants.maxImageSize, 10 * 1024 * 1024);
    });

    test('imageCompressQuality is 80', () {
      expect(AppConstants.imageCompressQuality, 80);
    });

    test('thumbnailSize is 200', () {
      expect(AppConstants.thumbnailSize, 200);
    });

    test('maxFileSize is 50 MB', () {
      expect(AppConstants.maxFileSize, 50 * 1024 * 1024);
    });

    test('maxVoiceDuration is 60', () {
      expect(AppConstants.maxVoiceDuration, 60);
    });

    test('minVoiceDuration is 1', () {
      expect(AppConstants.minVoiceDuration, 1);
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — cache
  // ─────────────────────────────────────────────────

  group('AppConstants — cache', () {
    test('imageCacheMaxSize is 100 MB', () {
      expect(AppConstants.imageCacheMaxSize, 100 * 1024 * 1024);
    });

    test('imageCacheMaxAge is 30', () {
      expect(AppConstants.imageCacheMaxAge, 30);
    });

    test('messageCacheMaxAge is 90', () {
      expect(AppConstants.messageCacheMaxAge, 90);
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — UI
  // ─────────────────────────────────────────────────

  group('AppConstants — UI', () {
    test('pullToRefreshTrigger is 80', () {
      expect(AppConstants.pullToRefreshTrigger, 80.0);
    });

    test('scrollThreshold is 200', () {
      expect(AppConstants.scrollThreshold, 200.0);
    });

    test('keyboardDelayMs is 100', () {
      expect(AppConstants.keyboardDelayMs, 100);
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — notifications
  // ─────────────────────────────────────────────────

  group('AppConstants — notifications', () {
    test('notificationChannelId is n42_chat_messages', () {
      expect(AppConstants.notificationChannelId, 'n42_chat_messages');
    });

    test('notificationChannelName is N42 Chat Messages', () {
      expect(AppConstants.notificationChannelName, 'N42 Chat Messages');
    });

    test('notificationChannelDesc is New message notifications', () {
      expect(AppConstants.notificationChannelDesc, 'New message notifications');
    });
  });

  // ─────────────────────────────────────────────────
  // AppConstants — regex patterns
  // ─────────────────────────────────────────────────

  group('AppConstants.matrixIdPattern', () {
    test('accepts valid Matrix user ID', () {
      expect(
        AppConstants.matrixIdPattern.hasMatch('@alice:matrix.org'),
        isTrue,
      );
    });

    test('accepts user with dots and underscores', () {
      expect(
        AppConstants.matrixIdPattern.hasMatch('@alice.bob_123:server.io'),
        isTrue,
      );
    });

    test('rejects ID without leading @', () {
      expect(
        AppConstants.matrixIdPattern.hasMatch('alice:matrix.org'),
        isFalse,
      );
    });

    test('rejects ID without server part', () {
      expect(AppConstants.matrixIdPattern.hasMatch('@alice'), isFalse);
    });
  });

  group('AppConstants.roomIdPattern', () {
    test('accepts valid room ID', () {
      expect(AppConstants.roomIdPattern.hasMatch('!abc123:matrix.org'), isTrue);
    });

    test('rejects without leading !', () {
      expect(AppConstants.roomIdPattern.hasMatch('abc123:matrix.org'), isFalse);
    });

    test('rejects without server part', () {
      expect(AppConstants.roomIdPattern.hasMatch('!abc123'), isFalse);
    });
  });

  group('AppConstants.roomAliasPattern', () {
    test('accepts valid room alias', () {
      expect(
        AppConstants.roomAliasPattern.hasMatch('#general:matrix.org'),
        isTrue,
      );
    });

    test('rejects without leading #', () {
      expect(
        AppConstants.roomAliasPattern.hasMatch('general:matrix.org'),
        isFalse,
      );
    });
  });

  group('AppConstants.urlPattern', () {
    test('matches http URL', () {
      expect(AppConstants.urlPattern.hasMatch('http://example.com'), isTrue);
    });

    test('matches https URL', () {
      expect(
        AppConstants.urlPattern.hasMatch('https://example.com/path?q=1'),
        isTrue,
      );
    });

    test('is case-insensitive', () {
      expect(AppConstants.urlPattern.hasMatch('HTTPS://EXAMPLE.COM'), isTrue);
    });

    test('does not match plain text without scheme', () {
      expect(AppConstants.urlPattern.hasMatch('example.com'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageConstants
  // ─────────────────────────────────────────────────

  group('StorageConstants', () {
    test('defaultCleanupDays is 90', () {
      expect(StorageConstants.defaultCleanupDays, 90);
    });

    test('defaultWarningThresholdMB is 500', () {
      expect(StorageConstants.defaultWarningThresholdMB, 500);
    });

    test('defaultCriticalThresholdMB is 1000', () {
      expect(StorageConstants.defaultCriticalThresholdMB, 1000);
    });

    test('hotDataDays is 30', () {
      expect(StorageConstants.hotDataDays, 30);
    });

    test('warmDataDays is 180', () {
      expect(StorageConstants.warmDataDays, 180);
    });

    test('largeFileThreshold is 10 MB', () {
      expect(StorageConstants.largeFileThreshold, 10 * 1024 * 1024);
    });

    test('backupExtension is .n42backup', () {
      expect(StorageConstants.backupExtension, '.n42backup');
    });

    test('backupDirName is n42_chat_backups', () {
      expect(StorageConstants.backupDirName, 'n42_chat_backups');
    });

    test('metaDbDirName is n42_chat_storage', () {
      expect(StorageConstants.metaDbDirName, 'n42_chat_storage');
    });

    test('metaDbFileName is media_meta.db', () {
      expect(StorageConstants.metaDbFileName, 'media_meta.db');
    });
  });

  // ─────────────────────────────────────────────────
  // Sanity: thresholds ordering
  // ─────────────────────────────────────────────────

  group('StorageConstants threshold ordering', () {
    test('warning < critical', () {
      expect(
        StorageConstants.defaultWarningThresholdMB,
        lessThan(StorageConstants.defaultCriticalThresholdMB),
      );
    });

    test('hotDataDays < warmDataDays', () {
      expect(
        StorageConstants.hotDataDays,
        lessThan(StorageConstants.warmDataDays),
      );
    });

    test('largeFileThreshold == maxImageSize', () {
      expect(StorageConstants.largeFileThreshold, AppConstants.maxImageSize);
    });
  });
}
