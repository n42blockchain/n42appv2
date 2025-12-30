import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// 性能指标类型
enum PerformanceMetricType {
  /// 冷启动时间
  coldStart,
  
  /// 热启动时间
  warmStart,
  
  /// 页面加载时间
  pageLoad,
  
  /// 网络请求时间
  networkRequest,
  
  /// 数据库查询时间
  databaseQuery,
  
  /// 渲染帧时间
  frameRender,
  
  /// 用户交互响应时间
  userInteraction,
}

/// 性能指标数据
class PerformanceMetric {
  final PerformanceMetricType type;
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? attributes;

  PerformanceMetric({
    required this.type,
    required this.name,
    required this.duration,
    DateTime? timestamp,
    this.attributes,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'duration_ms': duration.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
    ...?attributes,
  };
}

/// 应用监控服务
/// 
/// 提供性能监控、错误追踪和分析功能
@singleton
class AppMonitor {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  
  /// 性能指标缓存
  final List<PerformanceMetric> _metricsBuffer = [];
  
  /// 缓存阈值
  static const int _bufferThreshold = 10;
  
  /// 性能阈值配置
  final Map<PerformanceMetricType, Duration> _thresholds = {
    PerformanceMetricType.coldStart: const Duration(seconds: 3),
    PerformanceMetricType.warmStart: const Duration(seconds: 1),
    PerformanceMetricType.pageLoad: const Duration(milliseconds: 500),
    PerformanceMetricType.networkRequest: const Duration(seconds: 2),
    PerformanceMetricType.databaseQuery: const Duration(milliseconds: 100),
    PerformanceMetricType.frameRender: const Duration(milliseconds: 16),
    PerformanceMetricType.userInteraction: const Duration(milliseconds: 100),
  };

  AppMonitor()
      : _analytics = FirebaseAnalytics.instance,
        _crashlytics = FirebaseCrashlytics.instance;

  // ==================== 性能监控 ====================

  /// 记录性能指标
  void trackPerformance({
    required PerformanceMetricType type,
    required String name,
    required Duration duration,
    Map<String, dynamic>? attributes,
  }) {
    final metric = PerformanceMetric(
      type: type,
      name: name,
      duration: duration,
      attributes: attributes,
    );
    
    _metricsBuffer.add(metric);
    
    // 检查是否超过阈值
    final threshold = _thresholds[type];
    if (threshold != null && duration > threshold) {
      _logSlowOperation(metric);
    }
    
    // 达到阈值时批量发送
    if (_metricsBuffer.length >= _bufferThreshold) {
      _flushMetrics();
    }
  }

  /// 记录慢操作
  void _logSlowOperation(PerformanceMetric metric) {
    debugPrint('⚠️ Slow operation detected: ${metric.name} took ${metric.duration.inMilliseconds}ms');
    
    _analytics.logEvent(
      name: 'slow_operation',
      parameters: {
        'type': metric.type.name,
        'name': metric.name,
        'duration_ms': metric.duration.inMilliseconds,
        'threshold_ms': _thresholds[metric.type]?.inMilliseconds ?? 0,
      },
    );
  }

  /// 刷新性能指标缓存
  Future<void> _flushMetrics() async {
    if (_metricsBuffer.isEmpty) return;
    
    for (final metric in _metricsBuffer) {
      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'type': metric.type.name,
          'name': metric.name,
          'duration_ms': metric.duration.inMilliseconds,
        },
      );
    }
    
    _metricsBuffer.clear();
  }

  /// 测量操作耗时
  Future<T> measure<T>({
    required PerformanceMetricType type,
    required String name,
    required Future<T> Function() operation,
    Map<String, dynamic>? attributes,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      trackPerformance(
        type: type,
        name: name,
        duration: stopwatch.elapsed,
        attributes: attributes,
      );
    }
  }

  /// 测量同步操作耗时
  T measureSync<T>({
    required PerformanceMetricType type,
    required String name,
    required T Function() operation,
    Map<String, dynamic>? attributes,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      trackPerformance(
        type: type,
        name: name,
        duration: stopwatch.elapsed,
        attributes: attributes,
      );
    }
  }

  // ==================== 错误追踪 ====================

  /// 记录错误
  void trackError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
    Map<String, dynamic>? information,
  }) {
    debugPrint('❌ Error tracked: $error');
    
    final Iterable<Object> infoList = information?.entries
        .map<Object>((e) => '${e.key}: ${e.value}') ?? [];
    
    _crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
      information: infoList,
    );
  }

  /// 记录 Flutter 错误
  void trackFlutterError(FlutterErrorDetails details) {
    debugPrint('❌ Flutter error: ${details.exception}');
    _crashlytics.recordFlutterFatalError(details);
  }

  /// 设置用户标识
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    await _analytics.setUserId(id: userId);
  }

  /// 设置自定义属性
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value.toString());
  }

  /// 记录日志消息
  void log(String message) {
    _crashlytics.log(message);
  }

  // ==================== 分析事件 ====================

  /// 记录屏幕浏览
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// 记录用户事件
  Future<void> trackEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // Convert dynamic values to Object for Firebase Analytics
    final Map<String, Object>? params = parameters?.map(
      (key, value) => MapEntry(key, value as Object),
    );
    await _analytics.logEvent(
      name: name,
      parameters: params,
    );
  }

  /// 记录用户属性
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ==================== 预定义事件 ====================

  /// 记录登录事件
  Future<void> trackLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// 记录注册事件
  Future<void> trackSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'email');
  }

  /// 记录钱包创建事件
  Future<void> trackWalletCreated({
    required String walletType,
    required String chainType,
  }) async {
    await trackEvent(
      name: 'wallet_created',
      parameters: {
        'wallet_type': walletType,
        'chain_type': chainType,
      },
    );
  }

  /// 记录交易事件
  Future<void> trackTransaction({
    required String type,
    required String chainType,
    required String tokenSymbol,
    required double amount,
    required bool success,
  }) async {
    await trackEvent(
      name: 'transaction',
      parameters: {
        'type': type,
        'chain_type': chainType,
        'token_symbol': tokenSymbol,
        'amount': amount,
        'success': success,
      },
    );
  }

  /// 记录挖矿事件
  Future<void> trackMining({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      name: 'mining_$action',
      parameters: parameters,
    );
  }

  // ==================== 生命周期管理 ====================

  /// 初始化监控
  Future<void> init({bool enableCrashlytics = true}) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enableCrashlytics);
    
    // 设置 Flutter 错误处理
    FlutterError.onError = trackFlutterError;
    
    // 设置平台错误处理
    PlatformDispatcher.instance.onError = (error, stack) {
      trackError(error, stack, fatal: true);
      return true;
    };
  }

  /// 销毁时刷新缓存
  Future<void> dispose() async {
    await _flushMetrics();
  }
}

/// 性能追踪 Stopwatch
class PerformanceStopwatch {
  final AppMonitor _monitor;
  final PerformanceMetricType type;
  final String name;
  final Map<String, dynamic>? attributes;
  final Stopwatch _stopwatch;

  PerformanceStopwatch({
    required AppMonitor monitor,
    required this.type,
    required this.name,
    this.attributes,
  })  : _monitor = monitor,
        _stopwatch = Stopwatch();

  /// 开始计时
  void start() => _stopwatch.start();

  /// 停止并记录
  void stop() {
    _stopwatch.stop();
    _monitor.trackPerformance(
      type: type,
      name: name,
      duration: _stopwatch.elapsed,
      attributes: attributes,
    );
  }

  /// 获取当前耗时
  Duration get elapsed => _stopwatch.elapsed;
}

