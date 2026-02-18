// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// 帧时序记录
class FrameTimingRecord {
  /// Build 阶段耗时（微秒）
  final int buildDuration;

  /// Rasterize 阶段耗时（微秒）
  final int rasterDuration;

  /// 总耗时（微秒）
  final int totalDuration;

  /// 帧时间戳
  final DateTime timestamp;

  FrameTimingRecord({
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.timestamp,
  });
}

/// 性能监控配置
///
/// 静态工具类，提供函数耗时测量和帧率分析能力。
/// 默认在非 Release 模式下启用。
class PerformanceConfig {
  PerformanceConfig._();

  /// 是否启用性能监控
  static bool isEnabled = !kReleaseMode;

  /// Jank 判定阈值（微秒）：超过 16ms（60fps）视为掉帧
  static const int _jankThresholdUs = 16000;

  static final Map<String, DateTime> _startTimes = {};
  static final List<FrameTimingRecord> _frameRecords = [];

  // ─── 耗时测量 ─────────────────────────────────────────────

  /// 开始计时
  static void startTiming(String name) {
    if (!isEnabled) return;
    _startTimes[name] = DateTime.now();
  }

  /// 结束计时并返回耗时（毫秒），未找到对应 start 时返回 null
  static int? endTiming(String name) {
    if (!isEnabled) return null;
    final startTime = _startTimes.remove(name);
    if (startTime == null) return null;
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  /// 测量异步操作耗时，返回操作结果
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    startTiming(name);
    try {
      return await operation();
    } finally {
      endTiming(name);
    }
  }

  /// 测量同步操作耗时，返回操作结果
  static T measureSync<T>(String name, T Function() operation) {
    startTiming(name);
    try {
      return operation();
    } finally {
      endTiming(name);
    }
  }

  // ─── 帧率分析 ─────────────────────────────────────────────

  /// 平均帧时间（毫秒），无帧数据时返回 0
  static double get averageFrameTime {
    if (_frameRecords.isEmpty) return 0;
    final total = _frameRecords.fold<int>(
      0,
      (sum, r) => sum + r.totalDuration,
    );
    return total / _frameRecords.length / 1000; // 微秒 → 毫秒
  }

  /// Jank 帧占比（0-1），无帧数据时返回 0
  static double get jankRate {
    if (_frameRecords.isEmpty) return 0;
    final jankCount = _frameRecords
        .where((r) => r.totalDuration > _jankThresholdUs)
        .length;
    return jankCount / _frameRecords.length;
  }

  /// 生成性能报告
  static Map<String, dynamic> getPerformanceReport() {
    final jankCount = _frameRecords
        .where((r) => r.totalDuration > _jankThresholdUs)
        .length;
    return {
      'averageFrameTime': averageFrameTime,
      'jankRate': jankRate,
      'totalFrames': _frameRecords.length,
      'jankFrames': jankCount,
    };
  }

  // ─── 数据管理 ─────────────────────────────────────────────

  /// 清除所有计时与帧记录
  static void clearData() {
    _startTimes.clear();
    _frameRecords.clear();
  }
}

/// 图片缓存配置工具
class ImageCacheConfig {
  ImageCacheConfig._();

  /// 配置 Flutter 图片缓存
  ///
  /// [maxCacheSize] — 最大缓存条目数。
  /// [maxCacheWidth] — 基于宽度估算的最大缓存字节数（width² × 4 bytes/px）。
  static void configure({int? maxCacheSize, int? maxCacheWidth}) {
    final cache = PaintingBinding.instance.imageCache;
    if (maxCacheSize != null) {
      cache.maximumSize = maxCacheSize;
    }
    if (maxCacheWidth != null) {
      // 用宽度的平方乘以 4（ARGB）估算最大字节数
      cache.maximumSizeBytes = maxCacheWidth * maxCacheWidth * 4;
    }
  }

  /// 获取当前缓存统计信息
  static Map<String, dynamic> getStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'maximumSize': cache.maximumSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSizeBytes': cache.maximumSizeBytes,
    };
  }

  /// 清空图片缓存
  static void clear() {
    PaintingBinding.instance.imageCache.clear();
  }
}
