// Tests for DataTierService, DataTier enum, TierConfig, and TierMaintenanceResult.
// Uses mocktail to stub MediaLifecycleService and StorageMonitorService so
// no file-system or platform-channel calls are made.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/data_tier_service.dart';
import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';
import 'package:n42_chat/src/core/services/storage_monitor_service.dart';

class MockMediaLifecycleService extends Mock implements MediaLifecycleService {}

class MockStorageMonitorService extends Mock implements StorageMonitorService {}

void main() {
  late MockMediaLifecycleService mockLifecycle;
  late MockStorageMonitorService mockMonitor;
  late DataTierService service;

  setUp(() {
    mockLifecycle = MockMediaLifecycleService();
    mockMonitor = MockStorageMonitorService();
    service = DataTierService(
      lifecycleService: mockLifecycle,
      monitorService: mockMonitor,
    );
  });

  // ─────────────────────────────────────────────────
  // DataTier enum
  // ─────────────────────────────────────────────────

  group('DataTier enum', () {
    test('has 4 values: hot, warm, cold, ephemeral', () {
      expect(DataTier.values.length, 4);
      expect(DataTier.values, containsAll([
        DataTier.hot,
        DataTier.warm,
        DataTier.cold,
        DataTier.ephemeral,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // TierConfig
  // ─────────────────────────────────────────────────

  group('TierConfig defaults', () {
    const config = TierConfig();

    test('hotDays defaults to 30', () {
      expect(config.hotDays, 30);
    });

    test('warmDays defaults to 180', () {
      expect(config.warmDays, 180);
    });

    test('autoMaintenanceEnabled defaults to false', () {
      expect(config.autoMaintenanceEnabled, isFalse);
    });
  });

  group('TierConfig.copyWith', () {
    test('no overrides produces equal copy', () {
      const original = TierConfig();
      final copy = original.copyWith();
      expect(copy.hotDays, original.hotDays);
      expect(copy.warmDays, original.warmDays);
      expect(copy.autoMaintenanceEnabled, original.autoMaintenanceEnabled);
    });

    test('overrides hotDays only', () {
      const original = TierConfig();
      final modified = original.copyWith(hotDays: 14);
      expect(modified.hotDays, 14);
      expect(modified.warmDays, original.warmDays);
    });

    test('overrides warmDays only', () {
      const original = TierConfig();
      final modified = original.copyWith(warmDays: 90);
      expect(modified.warmDays, 90);
      expect(modified.hotDays, original.hotDays);
    });

    test('enables autoMaintenance', () {
      const original = TierConfig();
      final modified = original.copyWith(autoMaintenanceEnabled: true);
      expect(modified.autoMaintenanceEnabled, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // TierMaintenanceResult
  // ─────────────────────────────────────────────────

  group('TierMaintenanceResult', () {
    test('default constructor has all-zero fields', () {
      const result = TierMaintenanceResult();
      expect(result.warmFilesProcessed, 0);
      expect(result.coldFilesCleaned, 0);
      expect(result.bytesFreed, 0);
    });

    test('named fields can be set', () {
      const result = TierMaintenanceResult(
        warmFilesProcessed: 5,
        coldFilesCleaned: 10,
        bytesFreed: 1024 * 1024,
      );
      expect(result.warmFilesProcessed, 5);
      expect(result.coldFilesCleaned, 10);
      expect(result.bytesFreed, 1024 * 1024);
    });
  });

  // ─────────────────────────────────────────────────
  // DataTierService.getMessageTier
  // Constants: hotDataDays=30, warmDataDays=180
  // ─────────────────────────────────────────────────

  group('DataTierService.getMessageTier', () {
    test('timestamp from today is hot (0 days old)', () {
      expect(service.getMessageTier(DateTime.now()), DataTier.hot);
    });

    test('15 days ago is hot (≤ 30)', () {
      final ts = DateTime.now().subtract(const Duration(days: 15));
      expect(service.getMessageTier(ts), DataTier.hot);
    });

    test('exactly 30 days ago is hot (≤ 30)', () {
      final ts = DateTime.now().subtract(const Duration(days: 30));
      expect(service.getMessageTier(ts), DataTier.hot);
    });

    test('31 days ago is warm (> 30, ≤ 180)', () {
      final ts = DateTime.now().subtract(const Duration(days: 31));
      expect(service.getMessageTier(ts), DataTier.warm);
    });

    test('90 days ago is warm', () {
      final ts = DateTime.now().subtract(const Duration(days: 90));
      expect(service.getMessageTier(ts), DataTier.warm);
    });

    test('exactly 180 days ago is warm (≤ 180)', () {
      final ts = DateTime.now().subtract(const Duration(days: 180));
      expect(service.getMessageTier(ts), DataTier.warm);
    });

    test('181 days ago is cold (> 180)', () {
      final ts = DateTime.now().subtract(const Duration(days: 181));
      expect(service.getMessageTier(ts), DataTier.cold);
    });

    test('1 year ago is cold', () {
      final ts = DateTime.now().subtract(const Duration(days: 365));
      expect(service.getMessageTier(ts), DataTier.cold);
    });

    test('future timestamp is hot (negative age ≤ 30)', () {
      // Future timestamps have negative age → age <= hotDataDays → hot
      final ts = DateTime.now().add(const Duration(days: 5));
      expect(service.getMessageTier(ts), DataTier.hot);
    });
  });
}
