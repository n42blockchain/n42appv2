// Tests for StorageLevel, StorageStatus, and StorageConfig —
// the pure Dart data classes in storage_monitor_service.dart.
// StorageMonitorService itself (requires SharedPreferences + MediaLifecycleService)
// is not covered here.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/storage_monitor_service.dart';
import 'package:n42_chat/src/core/services/storage_manager_service.dart';

void main() {
  // ─────────────────────────────────────────────────
  // StorageLevel enum
  // ─────────────────────────────────────────────────

  group('StorageLevel enum', () {
    test('has 3 values: normal, warning, critical', () {
      expect(StorageLevel.values.length, 3);
      expect(StorageLevel.values, containsAll([
        StorageLevel.normal,
        StorageLevel.warning,
        StorageLevel.critical,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // StorageStatus — constructor defaults
  // ─────────────────────────────────────────────────

  group('StorageStatus constructor defaults', () {
    const status = StorageStatus();

    test('totalUsedBytes defaults to 0', () {
      expect(status.totalUsedBytes, 0);
    });

    test('mediaBytes defaults to 0', () {
      expect(status.mediaBytes, 0);
    });

    test('cleanableBytes defaults to 0', () {
      expect(status.cleanableBytes, 0);
    });

    test('cacheBytes defaults to 0', () {
      expect(status.cacheBytes, 0);
    });

    test('level defaults to normal', () {
      expect(status.level, StorageLevel.normal);
    });

    test('deviceFreeBytes defaults to null', () {
      expect(status.deviceFreeBytes, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageStatus — formatted getters (delegate to StorageInfo.formatSize)
  // ─────────────────────────────────────────────────

  group('StorageStatus formatted getters', () {
    const status = StorageStatus(
      totalUsedBytes: 1024 * 1024 * 5,    // 5 MB
      mediaBytes: 1024 * 1024 * 3,         // 3 MB
      cleanableBytes: 1024 * 512,           // 0.5 MB
      cacheBytes: 1024 * 1024,             // 1 MB
    );

    test('formattedTotal shows 5.0 MB', () {
      expect(status.formattedTotal, '5.0 MB');
    });

    test('formattedMedia shows 3.0 MB', () {
      expect(status.formattedMedia, '3.0 MB');
    });

    test('formattedCleanable shows 512.0 KB', () {
      expect(status.formattedCleanable, '512.0 KB');
    });

    test('formattedCache shows 1.0 MB', () {
      expect(status.formattedCache, '1.0 MB');
    });

    test('zero-size status shows "0 B" for all formatted fields', () {
      const zero = StorageStatus();
      expect(zero.formattedTotal, '0 B');
      expect(zero.formattedMedia, '0 B');
      expect(zero.formattedCleanable, '0 B');
      expect(zero.formattedCache, '0 B');
    });
  });

  // ─────────────────────────────────────────────────
  // StorageStatus — named fields
  // ─────────────────────────────────────────────────

  group('StorageStatus named fields', () {
    test('stores all provided fields', () {
      const status = StorageStatus(
        totalUsedBytes: 100,
        mediaBytes: 50,
        cleanableBytes: 30,
        cacheBytes: 20,
        level: StorageLevel.warning,
        deviceFreeBytes: 2 * 1024 * 1024 * 1024,
      );
      expect(status.totalUsedBytes, 100);
      expect(status.mediaBytes, 50);
      expect(status.cleanableBytes, 30);
      expect(status.cacheBytes, 20);
      expect(status.level, StorageLevel.warning);
      expect(status.deviceFreeBytes, 2 * 1024 * 1024 * 1024);
    });

    test('critical level is stored correctly', () {
      const status = StorageStatus(level: StorageLevel.critical);
      expect(status.level, StorageLevel.critical);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageConfig — constructor defaults
  // ─────────────────────────────────────────────────

  group('StorageConfig constructor defaults', () {
    const config = StorageConfig();

    test('warningThresholdMB defaults to 500', () {
      expect(config.warningThresholdMB, 500);
    });

    test('criticalThresholdMB defaults to 1000', () {
      expect(config.criticalThresholdMB, 1000);
    });

    test('autoCleanupDays defaults to 90', () {
      expect(config.autoCleanupDays, 90);
    });

    test('autoCleanupEnabled defaults to false', () {
      expect(config.autoCleanupEnabled, isFalse);
    });

    test('preserveThumbnails defaults to true', () {
      expect(config.preserveThumbnails, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // StorageConfig.copyWith
  // ─────────────────────────────────────────────────

  group('StorageConfig.copyWith', () {
    const original = StorageConfig();

    test('no overrides produces equal copy', () {
      final copy = original.copyWith();
      expect(copy.warningThresholdMB, original.warningThresholdMB);
      expect(copy.criticalThresholdMB, original.criticalThresholdMB);
      expect(copy.autoCleanupDays, original.autoCleanupDays);
      expect(copy.autoCleanupEnabled, original.autoCleanupEnabled);
      expect(copy.preserveThumbnails, original.preserveThumbnails);
    });

    test('overrides warningThresholdMB only', () {
      final modified = original.copyWith(warningThresholdMB: 200);
      expect(modified.warningThresholdMB, 200);
      expect(modified.criticalThresholdMB, original.criticalThresholdMB);
    });

    test('overrides criticalThresholdMB only', () {
      final modified = original.copyWith(criticalThresholdMB: 2000);
      expect(modified.criticalThresholdMB, 2000);
      expect(modified.warningThresholdMB, original.warningThresholdMB);
    });

    test('enables autoCleanup', () {
      final modified = original.copyWith(autoCleanupEnabled: true);
      expect(modified.autoCleanupEnabled, isTrue);
    });

    test('overrides autoCleanupDays', () {
      final modified = original.copyWith(autoCleanupDays: 30);
      expect(modified.autoCleanupDays, 30);
    });

    test('disables preserveThumbnails', () {
      final modified = original.copyWith(preserveThumbnails: false);
      expect(modified.preserveThumbnails, isFalse);
    });

    test('can override all fields simultaneously', () {
      final modified = original.copyWith(
        warningThresholdMB: 300,
        criticalThresholdMB: 800,
        autoCleanupDays: 60,
        autoCleanupEnabled: true,
        preserveThumbnails: false,
      );
      expect(modified.warningThresholdMB, 300);
      expect(modified.criticalThresholdMB, 800);
      expect(modified.autoCleanupDays, 60);
      expect(modified.autoCleanupEnabled, isTrue);
      expect(modified.preserveThumbnails, isFalse);
    });
  });
}
