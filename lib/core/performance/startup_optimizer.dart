// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 启动优化器
///
/// 提供启动时间测量和优化策略
class StartupOptimizer {
  StartupOptimizer._();

  static DateTime? _appStartTime;
  static DateTime? _firstFrameTime;
  static DateTime? _homePageReadyTime;
  static final Map<String, int> _milestones = {};

  /// 记录应用启动时间
  static void recordAppStart() {
    _appStartTime = DateTime.now();
    _recordMilestone('app_start');
  }

  /// 记录首帧渲染时间
  static void recordFirstFrame() {
    _firstFrameTime = DateTime.now();
    _recordMilestone('first_frame');
    
    if (kDebugMode && _appStartTime != null) {
      final coldStart = _firstFrameTime!.difference(_appStartTime!).inMilliseconds;
      developer.log('🚀 Cold start to first frame: ${coldStart}ms', name: 'Startup');
    }
  }

  /// 记录首页就绪时间
  static void recordHomePageReady() {
    _homePageReadyTime = DateTime.now();
    _recordMilestone('home_ready');
    
    if (kDebugMode && _appStartTime != null) {
      final totalStart = _homePageReadyTime!.difference(_appStartTime!).inMilliseconds;
      developer.log('🏠 Total startup time: ${totalStart}ms', name: 'Startup');
    }
  }

  /// 记录里程碑
  static void _recordMilestone(String name) {
    if (_appStartTime == null) return;
    _milestones[name] = DateTime.now().difference(_appStartTime!).inMilliseconds;
  }

  /// 记录自定义里程碑
  static void recordMilestone(String name) {
    _recordMilestone(name);
    if (kDebugMode) {
      developer.log('📍 Milestone [$name]: ${_milestones[name]}ms', name: 'Startup');
    }
  }

  /// 获取冷启动时间
  static int? get coldStartTime {
    if (_appStartTime == null || _firstFrameTime == null) return null;
    return _firstFrameTime!.difference(_appStartTime!).inMilliseconds;
  }

  /// 获取完整启动时间
  static int? get totalStartupTime {
    if (_appStartTime == null || _homePageReadyTime == null) return null;
    return _homePageReadyTime!.difference(_appStartTime!).inMilliseconds;
  }

  /// 获取启动报告
  static Map<String, dynamic> getStartupReport() {
    return {
      'coldStartTime': coldStartTime,
      'totalStartupTime': totalStartupTime,
      'milestones': Map<String, int>.from(_milestones),
    };
  }

  /// 重置启动数据
  static void reset() {
    _appStartTime = null;
    _firstFrameTime = null;
    _homePageReadyTime = null;
    _milestones.clear();
  }
}

/// 延迟初始化管理器
///
/// 将非关键初始化推迟到首帧渲染后
class DeferredInitializer {
  static final List<Future<void> Function()> _deferredTasks = [];
  static bool _hasExecuted = false;

  /// 添加延迟任务
  static void addTask(Future<void> Function() task) {
    _deferredTasks.add(task);
  }

  /// 执行所有延迟任务
  static Future<void> executeAll() async {
    if (_hasExecuted) return;
    _hasExecuted = true;

    // 等待首帧渲染完成
    await Future.delayed(Duration.zero);
    
    for (final task in _deferredTasks) {
      try {
        await task();
      } catch (e) {
        if (kDebugMode) {
          developer.log('Deferred task failed: $e', name: 'DeferredInit');
        }
      }
    }
    
    _deferredTasks.clear();
    StartupOptimizer.recordMilestone('deferred_init_complete');
  }

  /// 在首帧后执行
  static void executeAfterFirstFrame() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      StartupOptimizer.recordFirstFrame();
      executeAll();
    });
  }

  /// 重置
  static void reset() {
    _deferredTasks.clear();
    _hasExecuted = false;
  }
}

/// 预加载管理器
///
/// 管理资源预加载
class PreloadManager {
  static final Set<String> _preloadedAssets = {};
  static final Set<String> _preloadedRoutes = {};

  /// 预加载图片资源
  static Future<void> preloadImage(String assetPath) async {
    if (_preloadedAssets.contains(assetPath)) return;
    _preloadedAssets.add(assetPath);
    // 实际预加载由 precacheImage 完成
  }

  /// 标记路由已预加载
  static void markRoutePreloaded(String routeName) {
    _preloadedRoutes.add(routeName);
  }

  /// 检查资源是否已预加载
  static bool isAssetPreloaded(String assetPath) {
    return _preloadedAssets.contains(assetPath);
  }

  /// 检查路由是否已预加载
  static bool isRoutePreloaded(String routeName) {
    return _preloadedRoutes.contains(routeName);
  }

  /// 清理预加载缓存
  static void clear() {
    _preloadedAssets.clear();
    _preloadedRoutes.clear();
  }
}

