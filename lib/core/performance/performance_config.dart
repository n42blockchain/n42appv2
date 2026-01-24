// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// 性能监控配置
///
/// 提供性能监控和分析工具
class PerformanceConfig {
  PerformanceConfig._();

  /// 是否启用性能监控
  static bool isEnabled = kDebugMode;
  static final Map<String, _TimingData> _timings = {};
  static final List<FrameTimingRecord> _frameTimings = [];

  /// 开始计时
  static void startTiming(String label) {
    if (!isEnabled) return;
    _timings[label] = _TimingData(DateTime.now());
  }

  /// 结束计时并返回耗时（毫秒）
  static int? endTiming(String label) {
    if (!isEnabled) return null;
    final timing = _timings.remove(label);
    if (timing == null) return null;
    
    final duration = DateTime.now().difference(timing.startTime).inMilliseconds;
    if (kDebugMode) {
      developer.log('⏱️ $label: ${duration}ms', name: 'Performance');
    }
    return duration;
  }

  /// 测量异步操作耗时
  static Future<T> measureAsync<T>(String label, Future<T> Function() operation) async {
    if (!isEnabled) return operation();
    
    startTiming(label);
    try {
      return await operation();
    } finally {
      endTiming(label);
    }
  }

  /// 测量同步操作耗时
  static T measureSync<T>(String label, T Function() operation) {
    if (!isEnabled) return operation();
    
    startTiming(label);
    try {
      return operation();
    } finally {
      endTiming(label);
    }
  }

  /// 记录帧渲染时间
  static void recordFrameTiming(FrameTiming timing) {
    if (!isEnabled) return;
    
    final record = FrameTimingRecord(
      buildDuration: timing.buildDuration.inMicroseconds,
      rasterDuration: timing.rasterDuration.inMicroseconds,
      totalDuration: timing.totalSpan.inMicroseconds,
      timestamp: DateTime.now(),
    );
    
    _frameTimings.add(record);
    
    // 保留最近 100 帧数据
    if (_frameTimings.length > 100) {
      _frameTimings.removeAt(0);
    }
    
    // 检测卡顿 (> 16ms = 60fps threshold)
    if (record.totalDuration > 16000) {
      if (kDebugMode) {
        developer.log(
          '🔴 Jank detected: ${record.totalDuration / 1000}ms (build: ${record.buildDuration / 1000}ms, raster: ${record.rasterDuration / 1000}ms)',
          name: 'Performance',
        );
      }
    }
  }

  /// 获取平均帧时间
  static double get averageFrameTime {
    if (_frameTimings.isEmpty) return 0;
    final total = _frameTimings.fold<int>(0, (sum, f) => sum + f.totalDuration);
    return total / _frameTimings.length / 1000; // 返回毫秒
  }

  /// 获取卡顿率
  static double get jankRate {
    if (_frameTimings.isEmpty) return 0;
    final janks = _frameTimings.where((f) => f.totalDuration > 16000).length;
    return janks / _frameTimings.length;
  }

  /// 获取性能报告
  static Map<String, dynamic> getPerformanceReport() {
    return {
      'averageFrameTime': averageFrameTime,
      'jankRate': jankRate,
      'totalFrames': _frameTimings.length,
      'jankFrames': _frameTimings.where((f) => f.totalDuration > 16000).length,
    };
  }

  /// 清除性能数据
  static void clearData() {
    _timings.clear();
    _frameTimings.clear();
  }
}

class _TimingData {
  final DateTime startTime;
  _TimingData(this.startTime);
}

class FrameTimingRecord {
  final int buildDuration;
  final int rasterDuration;
  final int totalDuration;
  final DateTime timestamp;

  FrameTimingRecord({
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.timestamp,
  });
}

/// 性能优化混入
///
/// 提供 Widget 性能优化工具
mixin PerformanceOptimizationMixin {
  /// 防抖 setState
  Timer? _debounceTimer;
  
  void debounceSetState(VoidCallback fn, {Duration delay = const Duration(milliseconds: 16)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, fn);
  }

  void cancelDebounce() {
    _debounceTimer?.cancel();
  }
}

/// 图片缓存配置
class ImageCacheConfig {
  /// 配置图片缓存
  static void configure({
    int maxCacheSize = 100,
    int maxCacheWidth = 1000,
  }) {
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB
  }

  /// 清理图片缓存
  static void clear() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// 获取缓存统计
  static Map<String, dynamic> getStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSize': cache.maximumSize,
      'maximumSizeBytes': cache.maximumSizeBytes,
    };
  }
}

