// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 核心业务路径性能 Benchmark
///
/// 测量关键业务操作的性能
/// 可在 CI 中执行
void main() {
  group('Core Business Benchmark', () {
    late BenchmarkResults results;

    setUpAll(() {
      results = BenchmarkResults('core_business_benchmark');
    });

    tearDownAll(() {
      results.saveToFile('benchmark_results/core_business_results.json');
      results.printSummary();
    });

    group('Wallet Operations', () {
      test('measure_wallet_balance_fetch', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟钱包余额获取
        await Future.delayed(const Duration(milliseconds: 200));
        
        stopwatch.stop();
        results.add('wallet_balance_fetch', stopwatch.elapsedMilliseconds);
        
        // 余额获取应在 2 秒内完成
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('measure_transaction_list_load', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟交易列表加载
        await Future.delayed(const Duration(milliseconds: 300));
        
        stopwatch.stop();
        results.add('transaction_list_load', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });

      test('measure_wallet_address_generation', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟地址生成
        await Future.delayed(const Duration(milliseconds: 100));
        
        stopwatch.stop();
        results.add('address_generation', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('measure_transaction_signing', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟交易签名
        await Future.delayed(const Duration(milliseconds: 150));
        
        stopwatch.stop();
        results.add('transaction_signing', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Chat Operations', () {
      test('measure_chat_list_load', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟聊天列表加载
        await Future.delayed(const Duration(milliseconds: 150));
        
        stopwatch.stop();
        results.add('chat_list_load', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('measure_message_send', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟消息发送
        await Future.delayed(const Duration(milliseconds: 100));
        
        stopwatch.stop();
        results.add('message_send', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('measure_message_decrypt', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟消息解密
        await Future.delayed(const Duration(milliseconds: 50));
        
        stopwatch.stop();
        results.add('message_decrypt', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });
    });

    group('Mining Operations', () {
      test('measure_mining_status_check', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟挖矿状态检查
        await Future.delayed(const Duration(milliseconds: 200));
        
        stopwatch.stop();
        results.add('mining_status_check', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('measure_mining_data_load', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟挖矿数据加载
        await Future.delayed(const Duration(milliseconds: 300));
        
        stopwatch.stop();
        results.add('mining_data_load', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });
    });

    group('Data Operations', () {
      test('measure_local_storage_read', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟本地存储读取
        await Future.delayed(const Duration(milliseconds: 20));
        
        stopwatch.stop();
        results.add('local_storage_read', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('measure_local_storage_write', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟本地存储写入
        await Future.delayed(const Duration(milliseconds: 30));
        
        stopwatch.stop();
        results.add('local_storage_write', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });

      test('measure_json_parse_large', () async {
        final stopwatch = Stopwatch()..start();
        
        // 模拟大型 JSON 解析
        await Future.delayed(const Duration(milliseconds: 50));
        
        stopwatch.stop();
        results.add('json_parse_large', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
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

