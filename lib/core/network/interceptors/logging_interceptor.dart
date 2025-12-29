import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/security/security_config.dart';

/// 日志拦截器
/// 
/// 仅在 Debug 模式下输出请求/响应日志
/// 自动脱敏敏感信息
class LoggingInterceptor extends Interceptor {
  /// 是否启用日志
  final bool enableLog;
  
  /// 是否打印请求头
  final bool printHeader;
  
  /// 是否打印请求体
  final bool printRequestBody;
  
  /// 是否打印响应体
  final bool printResponseBody;

  LoggingInterceptor({
    this.enableLog = kDebugMode,
    this.printHeader = false,
    this.printRequestBody = true,
    this.printResponseBody = true,
  }) {
    // 确保在 Release 模式下不启用日志
    if (kReleaseMode && enableLog) {
      debugPrint('⚠️ WARNING: Logging should be disabled in Release mode');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableLog) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableLog) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLog) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    // 在 Release 模式下禁止日志输出
    if (kReleaseMode) return;
    
    final buffer = StringBuffer()
      ..writeln('┌────────────────────────────────────────────────────────────')
      ..writeln('│ 🚀 REQUEST')
      ..writeln('├────────────────────────────────────────────────────────────')
      ..writeln('│ ${options.method.toUpperCase()} ${options.uri}');
    
    if (printHeader && options.headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        // 使用安全配置进行敏感信息脱敏
        final displayValue = SecurityConfig.maskSensitiveData(key, value);
        buffer.writeln('│   $key: $displayValue');
      });
    }
    
    if (printRequestBody && options.data != null) {
      buffer
        ..writeln('│ Body:')
        ..writeln('│   ${_formatAndMaskJson(options.data)}');
    }
    
    buffer.writeln('└────────────────────────────────────────────────────────────');
    
    debugPrint(buffer.toString());
  }

  void _logResponse(Response response) {
    // 在 Release 模式下禁止日志输出
    if (kReleaseMode) return;
    
    final buffer = StringBuffer()
      ..writeln('┌────────────────────────────────────────────────────────────')
      ..writeln('│ ✅ RESPONSE [${response.statusCode}]')
      ..writeln('├────────────────────────────────────────────────────────────')
      ..writeln('│ ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
    
    if (printResponseBody && response.data != null) {
      final data = _formatAndMaskJson(response.data);
      // 限制输出长度
      final truncated = data.length > 1000 
          ? '${data.substring(0, 1000)}... [truncated]' 
          : data;
      buffer
        ..writeln('│ Body:')
        ..writeln('│   $truncated');
    }
    
    buffer.writeln('└────────────────────────────────────────────────────────────');
    
    debugPrint(buffer.toString());
  }

  void _logError(DioException err) {
    // 在 Release 模式下禁止日志输出
    if (kReleaseMode) return;
    
    final buffer = StringBuffer()
      ..writeln('┌────────────────────────────────────────────────────────────')
      ..writeln('│ ❌ ERROR [${err.response?.statusCode ?? 'N/A'}]')
      ..writeln('├────────────────────────────────────────────────────────────')
      ..writeln('│ ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}')
      ..writeln('│ Type: ${err.type}')
      ..writeln('│ Message: ${err.message}');
    
    if (err.response?.data != null) {
      buffer.writeln('│ Response: ${_formatAndMaskJson(err.response?.data)}');
    }
    
    buffer.writeln('└────────────────────────────────────────────────────────────');
    
    debugPrint(buffer.toString());
  }

  /// 格式化 JSON 并脱敏敏感数据
  String _formatAndMaskJson(dynamic data) {
    try {
      if (data is String) {
        // 尝试解析为 JSON
        try {
          final parsed = jsonDecode(data);
          return _formatAndMaskJson(parsed);
        } catch (_) {
          return data;
        }
      }
      
      if (data is Map<String, dynamic>) {
        // 脱敏 Map 数据
        final masked = SecurityConfig.maskSensitiveMap(data);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(masked);
      }
      
      if (data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data.map((item) {
          if (item is Map<String, dynamic>) {
            return SecurityConfig.maskSensitiveMap(item);
          }
          return item;
        }).toList());
      }
      
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

