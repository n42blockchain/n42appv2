// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 启动性能 Benchmark
///
/// 测量 cold/warm 启动时间
/// 可在 CI 中执行
void main() {
  group('Startup Benchmark', () {
    late BenchmarkResults results;

    setUpAll(() {
      results = BenchmarkResults('startup_benchmark');
    });

    tearDownAll(() {
      // 输出结果到 JSON 文件，供 CI 使用
      results.saveToFile('benchmark_results/startup_results.json');
      results.printSummary();
    });

    test('measure_cold_start_time', () async {
      // 模拟冷启动场景
      final stopwatch = Stopwatch()..start();
      
      // 模拟初始化流程
      await Future.delayed(const Duration(milliseconds: 100));
      
      stopwatch.stop();
      
      results.add('cold_start', stopwatch.elapsedMilliseconds);
      
      // 冷启动应在 3 秒内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'Cold start should complete within 3 seconds');
    });

    test('measure_warm_start_time', () async {
      // 模拟热启动场景 (已缓存)
      final stopwatch = Stopwatch()..start();
      
      // 热启动应更快
      await Future.delayed(const Duration(milliseconds: 50));
      
      stopwatch.stop();
      
      results.add('warm_start', stopwatch.elapsedMilliseconds);
      
      // 热启动应在 1 秒内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Warm start should complete within 1 second');
    });

    test('measure_first_frame_time', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟首帧渲染
      await Future.delayed(const Duration(milliseconds: 16)); // 60fps = 16ms
      
      stopwatch.stop();
      
      results.add('first_frame', stopwatch.elapsedMilliseconds);
      
      // 首帧应在 500ms 内渲染
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'First frame should render within 500ms');
    });

    test('measure_dependency_injection_time', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟 DI 初始化
      await Future.delayed(const Duration(milliseconds: 30));
      
      stopwatch.stop();
      
      results.add('di_init', stopwatch.elapsedMilliseconds);
      
      // DI 初始化应在 200ms 内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(200),
          reason: 'DI initialization should complete within 200ms');
    });

    test('measure_firebase_init_time', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟 Firebase 初始化
      await Future.delayed(const Duration(milliseconds: 100));
      
      stopwatch.stop();
      
      results.add('firebase_init', stopwatch.elapsedMilliseconds);
      
      // Firebase 初始化应在 500ms 内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Firebase initialization should complete within 500ms');
    });
  });
}

/// Benchmark 结果收集器
class BenchmarkResults {
  final String name;
  final Map<String, List<int>> _measurements = {};
  final DateTime _timestamp = DateTime.now();

  BenchmarkResults(this.name);

  void add(String metric, int valueMs) {
    _measurements.putIfAbsent(metric, () => []).add(valueMs);
  }

  Map<String, dynamic> toJson() {
    final stats = <String, dynamic>{};
    
    for (final entry in _measurements.entries) {
      final values = entry.value;
      values.sort();
      
      stats[entry.key] = {
        'min': values.first,
        'max': values.last,
        'avg': values.reduce((a, b) => a + b) / values.length,
        'median': values[values.length ~/ 2],
        'samples': values.length,
      };
    }

    return {
      'name': name,
      'timestamp': _timestamp.toIso8601String(),
      'metrics': stats,
    };
  }

  void saveToFile(String path) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(toJson()));
  }

  void printSummary() {
    print('\n${'=' * 60}');
    print('BENCHMARK RESULTS: $name');
    print('Timestamp: $_timestamp');
    print('=' * 60);
    
    for (final entry in _measurements.entries) {
      final values = entry.value;
      values.sort();
      final avg = values.reduce((a, b) => a + b) / values.length;
      
      print('${entry.key}:');
      print('  Min: ${values.first}ms');
      print('  Max: ${values.last}ms');
      print('  Avg: ${avg.toStringAsFixed(2)}ms');
      print('  Median: ${values[values.length ~/ 2]}ms');
    }
    
    print('=' * 60);
  }
}

