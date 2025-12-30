// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/performance/performance_config.dart';

void main() {
  group('PerformanceConfig', () {
    setUp(() {
      PerformanceConfig.isEnabled = true;
      PerformanceConfig.clearData();
    });

    group('timing', () {
      test('should start and end timing', () async {
        PerformanceConfig.startTiming('test_operation');
        await Future.delayed(const Duration(milliseconds: 10));
        final duration = PerformanceConfig.endTiming('test_operation');

        expect(duration, isNotNull);
        expect(duration!, greaterThanOrEqualTo(10));
      });

      test('should return null for non-existent timing', () {
        final duration = PerformanceConfig.endTiming('non_existent');
        expect(duration, isNull);
      });

      test('should not track when disabled', () {
        PerformanceConfig.isEnabled = false;
        PerformanceConfig.startTiming('disabled_test');
        final duration = PerformanceConfig.endTiming('disabled_test');

        expect(duration, isNull);
      });
    });

    group('measureAsync', () {
      test('should measure async operation duration', () async {
        final result = await PerformanceConfig.measureAsync(
          'async_test',
          () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return 'result';
          },
        );

        expect(result, equals('result'));
      });

      test('should work when disabled', () async {
        PerformanceConfig.isEnabled = false;
        final result = await PerformanceConfig.measureAsync(
          'disabled_async',
          () async => 'result',
        );

        expect(result, equals('result'));
      });
    });

    group('measureSync', () {
      test('should measure sync operation duration', () {
        final result = PerformanceConfig.measureSync(
          'sync_test',
          () => 42,
        );

        expect(result, equals(42));
      });

      test('should work when disabled', () {
        PerformanceConfig.isEnabled = false;
        final result = PerformanceConfig.measureSync(
          'disabled_sync',
          () => 'result',
        );

        expect(result, equals('result'));
      });
    });

    group('frame timing', () {
      test('should calculate average frame time', () {
        // 初始状态应返回 0
        expect(PerformanceConfig.averageFrameTime, equals(0));
      });

      test('should calculate jank rate', () {
        // 初始状态应返回 0
        expect(PerformanceConfig.jankRate, equals(0));
      });
    });

    group('performance report', () {
      test('should generate report', () {
        final report = PerformanceConfig.getPerformanceReport();

        expect(report, isA<Map<String, dynamic>>());
        expect(report.containsKey('averageFrameTime'), isTrue);
        expect(report.containsKey('jankRate'), isTrue);
        expect(report.containsKey('totalFrames'), isTrue);
        expect(report.containsKey('jankFrames'), isTrue);
      });
    });

    group('clearData', () {
      test('should clear all data', () async {
        PerformanceConfig.startTiming('test');
        PerformanceConfig.clearData();

        // 清除后应返回 null
        final duration = PerformanceConfig.endTiming('test');
        expect(duration, isNull);
      });
    });
  });

  group('FrameTimingRecord', () {
    test('should create with all fields', () {
      final record = FrameTimingRecord(
        buildDuration: 1000,
        rasterDuration: 2000,
        totalDuration: 3000,
        timestamp: DateTime.now(),
      );

      expect(record.buildDuration, equals(1000));
      expect(record.rasterDuration, equals(2000));
      expect(record.totalDuration, equals(3000));
      expect(record.timestamp, isNotNull);
    });
  });

  group('ImageCacheConfig', () {
    setUpAll(() {
      // 需要 Flutter 绑定初始化
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('should configure cache', () {
      expect(
        () => ImageCacheConfig.configure(maxCacheSize: 100, maxCacheWidth: 1000),
        returnsNormally,
      );
    });

    test('should get stats', () {
      final stats = ImageCacheConfig.getStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('currentSize'), isTrue);
      expect(stats.containsKey('maximumSize'), isTrue);
    });

    test('should clear cache', () {
      expect(() => ImageCacheConfig.clear(), returnsNormally);
    });
  });
}

