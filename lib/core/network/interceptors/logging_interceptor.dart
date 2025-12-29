import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 日志拦截器
/// 
/// 仅在 Debug 模式下输出请求/响应日志
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
  });

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
    final buffer = StringBuffer()
      ..writeln('┌────────────────────────────────────────────────────────────')
      ..writeln('│ 🚀 REQUEST')
      ..writeln('├────────────────────────────────────────────────────────────')
      ..writeln('│ ${options.method.toUpperCase()} ${options.uri}');
    
    if (printHeader && options.headers.isNotEmpty) {
      buffer.writeln('│ Headers:');
      options.headers.forEach((key, value) {
        // 隐藏敏感信息
        final displayValue = _isSensitive(key) ? '******' : value.toString();
        buffer.writeln('│   $key: $displayValue');
      });
    }
    
    if (printRequestBody && options.data != null) {
      buffer
        ..writeln('│ Body:')
        ..writeln('│   ${_formatJson(options.data)}');
    }
    
    buffer.writeln('└────────────────────────────────────────────────────────────');
    
    debugPrint(buffer.toString());
  }

  void _logResponse(Response response) {
    final buffer = StringBuffer()
      ..writeln('┌────────────────────────────────────────────────────────────')
      ..writeln('│ ✅ RESPONSE [${response.statusCode}]')
      ..writeln('├────────────────────────────────────────────────────────────')
      ..writeln('│ ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
    
    if (printResponseBody && response.data != null) {
      final data = _formatJson(response.data);
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
    final buffer = StringBuffer()
      ..writeln('┌────────────────────────────────────────────────────────────')
      ..writeln('│ ❌ ERROR [${err.response?.statusCode ?? 'N/A'}]')
      ..writeln('├────────────────────────────────────────────────────────────')
      ..writeln('│ ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}')
      ..writeln('│ Type: ${err.type}')
      ..writeln('│ Message: ${err.message}');
    
    if (err.response?.data != null) {
      buffer.writeln('│ Response: ${_formatJson(err.response?.data)}');
    }
    
    buffer.writeln('└────────────────────────────────────────────────────────────');
    
    debugPrint(buffer.toString());
  }

  bool _isSensitive(String key) {
    final sensitiveKeys = ['token', 'authorization', 'password', 'secret'];
    return sensitiveKeys.any((k) => key.toLowerCase().contains(k));
  }

  String _formatJson(dynamic data) {
    try {
      if (data is String) {
        return data;
      }
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

