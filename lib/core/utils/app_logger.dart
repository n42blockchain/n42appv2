// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/security/security_config.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 安全日志工具
///
/// 特点:
/// - 仅在 Debug 模式下输出日志
/// - 自动脱敏敏感信息
/// - 支持日志级别过滤
/// - 使用 developer.log 而非 print
class AppLogger {
  AppLogger._();

  /// 当前日志级别（仅输出该级别及以上的日志）
  static LogLevel _minLevel = LogLevel.debug;

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 调试日志
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace, data: data);
  }

  /// 信息日志
  static void info(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// 警告日志
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace, data: data);
  }

  /// 错误日志
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace, data: data);
  }

  /// 内部日志方法
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // 在 Release 模式下不输出任何日志
    if (kReleaseMode) return;

    // 检查日志级别
    if (level.index < _minLevel.index) return;

    final buffer = StringBuffer();

    // 添加级别标识
    buffer.write(_getLevelPrefix(level));

    // 添加标签
    if (tag != null) {
      buffer.write('[$tag] ');
    }

    // 添加消息
    buffer.write(message);

    // 添加脱敏后的数据
    if (data != null) {
      final maskedData = SecurityConfig.maskSensitiveMap(data);
      buffer.write(' | Data: $maskedData');
    }

    // 添加错误信息
    if (error != null) {
      buffer.write(' | Error: $error');
    }

    // 使用 developer.log 而非 print
    developer.log(
      buffer.toString(),
      name: tag ?? 'N42Wallet',
      error: error,
      stackTrace: stackTrace,
      level: _getDeveloperLogLevel(level),
    );
  }

  /// 获取级别前缀
  static String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 ';
      case LogLevel.info:
        return '💡 ';
      case LogLevel.warning:
        return '⚠️ ';
      case LogLevel.error:
        return '❌ ';
    }
  }

  /// 获取 developer.log 的日志级别
  static int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINE
      case LogLevel.info:
        return 800; // INFO
      case LogLevel.warning:
        return 900; // WARNING
      case LogLevel.error:
        return 1000; // SEVERE
    }
  }

  /// 打印方法调用（用于调试）
  static void methodCall(String methodName, {Map<String, dynamic>? params}) {
    if (kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.write('📞 $methodName');

    if (params != null && params.isNotEmpty) {
      final maskedParams = SecurityConfig.maskSensitiveMap(params);
      buffer.write('($maskedParams)');
    } else {
      buffer.write('()');
    }

    developer.log(buffer.toString(), name: 'MethodCall');
  }

  /// 打印网络请求（用于调试）
  static void network(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    dynamic response,
  }) {
    if (kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.writeln('🌐 $method $url');

    if (statusCode != null) {
      buffer.writeln('   Status: $statusCode');
    }

    if (headers != null) {
      final maskedHeaders = SecurityConfig.maskSensitiveMap(headers);
      buffer.writeln('   Headers: $maskedHeaders');
    }

    if (body != null) {
      if (body is Map<String, dynamic>) {
        final maskedBody = SecurityConfig.maskSensitiveMap(body);
        buffer.writeln('   Body: $maskedBody');
      } else {
        buffer.writeln('   Body: [${body.runtimeType}]');
      }
    }

    developer.log(buffer.toString(), name: 'Network');
  }
}

/// 简化的日志方法（用于快速替换 print）
///
/// 示例:
/// ```dart
/// // 替换前
/// print('Hello');
///
/// // 替换后
/// logDebug('Hello');
/// ```
void logDebug(String message, {String? tag}) {
  AppLogger.debug(message, tag: tag);
}

void logInfo(String message, {String? tag}) {
  AppLogger.info(message, tag: tag);
}

void logWarning(String message, {String? tag, Object? error}) {
  AppLogger.warning(message, tag: tag, error: error);
}

void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
  AppLogger.error(message, tag: tag, error: error, stackTrace: stackTrace);
}
