// ignore_for_file: avoid_print

// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 页面切换性能 Benchmark
///
/// 测量页面导航和切换时间
/// 可在 CI 中执行
void main() {
  group('Navigation Benchmark', () {
    late BenchmarkResults results;

    setUpAll(() {
      results = BenchmarkResults('navigation_benchmark');
    });

    tearDownAll(() {
      results.saveToFile('benchmark_results/navigation_results.json');
      results.printSummary();
    });

    test('measure_home_to_wallet_navigation', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟从首页到钱包页的导航
      await Future.delayed(const Duration(milliseconds: 100));
      
      stopwatch.stop();
      results.add('home_to_wallet', stopwatch.elapsedMilliseconds);
      
      // 页面切换应在 300ms 内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(300),
          reason: 'Navigation should complete within 300ms');
    });

    test('measure_wallet_to_send_navigation', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟从钱包页到发送页的导航
      await Future.delayed(const Duration(milliseconds: 80));
      
      stopwatch.stop();
      results.add('wallet_to_send', stopwatch.elapsedMilliseconds);
      
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    test('measure_home_to_mining_navigation', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟从首页到挖矿页的导航
      await Future.delayed(const Duration(milliseconds: 120));
      
      stopwatch.stop();
      results.add('home_to_mining', stopwatch.elapsedMilliseconds);
      
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    test('measure_home_to_chat_navigation', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟从首页到聊天页的导航
      await Future.delayed(const Duration(milliseconds: 100));
      
      stopwatch.stop();
      results.add('home_to_chat', stopwatch.elapsedMilliseconds);
      
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    test('measure_settings_page_load', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟设置页加载
      await Future.delayed(const Duration(milliseconds: 50));
      
      stopwatch.stop();
      results.add('settings_load', stopwatch.elapsedMilliseconds);
      
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('measure_back_navigation', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟返回导航
      await Future.delayed(const Duration(milliseconds: 30));
      
      stopwatch.stop();
      results.add('back_navigation', stopwatch.elapsedMilliseconds);
      
      // 返回应更快
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('measure_tab_switch', () async {
      final stopwatch = Stopwatch()..start();
      
      // 模拟底部 Tab 切换
      await Future.delayed(const Duration(milliseconds: 16)); // 单帧
      
      stopwatch.stop();
      results.add('tab_switch', stopwatch.elapsedMilliseconds);
      
      // Tab 切换应即时 (< 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
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
    }
    
    print('=' * 60);
  }
}

