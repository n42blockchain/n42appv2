import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 重试拦截器
/// 
/// 对网络错误和超时自动重试
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  
  /// 最大重试次数
  final int maxRetries;
  
  /// 重试间隔（毫秒）
  final int retryDelayMs;
  
  /// 指数退避因子
  final double backoffFactor;
  
  /// 需要重试的状态码
  final List<int> retryStatusCodes;
  
  /// 不重试的请求方法
  final List<String> noRetryMethods;

  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.backoffFactor = 2.0,
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.noRetryMethods = const ['POST', 'PUT', 'PATCH', 'DELETE'],
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;
    
    // 检查是否应该重试
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }
    
    // 计算延迟时间（指数退避）
    final delay = _calculateDelay(retryCount);
    
    debugPrint('🔄 Retry ${retryCount + 1}/$maxRetries after ${delay}ms');
    
    // 等待后重试
    await Future.delayed(Duration(milliseconds: delay));
    
    try {
      // 更新重试计数
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      // 重新发起请求
      final response = await _dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      // 重试失败，继续传递错误
      return handler.next(err);
    }
  }

  bool _shouldRetry(DioException err, int retryCount) {
    // 超过最大重试次数
    if (retryCount >= maxRetries) return false;
    
    // 取消的请求不重试
    if (err.type == DioExceptionType.cancel) return false;
    
    // 检查请求方法（非幂等请求默认不重试）
    final method = err.requestOptions.method.toUpperCase();
    final forceRetry = err.requestOptions.extra['forceRetry'] as bool? ?? false;
    if (noRetryMethods.contains(method) && !forceRetry) return false;
    
    // 网络错误和超时可以重试
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    
    // 连接错误可以重试
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }
    
    // 检查状态码
    if (err.response != null && 
        retryStatusCodes.contains(err.response!.statusCode)) {
      return true;
    }
    
    // 检查是否是 Socket 异常
    if (err.error is SocketException) {
      return true;
    }
    
    return false;
  }

  int _calculateDelay(int retryCount) {
    // 指数退避：delay = baseDelay * (factor ^ retryCount)
    return (retryDelayMs * (backoffFactor.toInt() * retryCount)).toInt().clamp(
      retryDelayMs,
      30000, // 最大 30 秒
    );
  }
}

