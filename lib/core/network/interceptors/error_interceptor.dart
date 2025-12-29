import 'dart:io';

import 'package:dio/dio.dart';

import '../../error/exceptions.dart';

/// 错误处理拦截器
/// 
/// 统一转换 DioException 为应用异常
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    
    // 创建新的 DioException，携带我们的自定义异常
    final newError = DioException(
      requestOptions: err.requestOptions,
      error: exception,
      response: err.response,
      type: err.type,
      message: exception.message,
    );
    
    handler.next(newError);
  }

  AppException _mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: '请求超时，请检查网络后重试',
          originalError: err,
        );
      
      case DioExceptionType.connectionError:
        if (err.error is SocketException) {
          return const NetworkException(
            message: '无法连接到服务器，请检查网络设置',
          );
        }
        return NetworkException(
          message: '网络连接失败: ${err.message}',
          originalError: err,
        );
      
      case DioExceptionType.badCertificate:
        return const ServerException(
          message: '证书验证失败，请确保网络安全',
          code: 'CERTIFICATE_ERROR',
        );
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(err);
      
      case DioExceptionType.cancel:
        return const ServerException(
          message: '请求已取消',
          code: 'REQUEST_CANCELLED',
        );
      
      case DioExceptionType.unknown:
      default:
        if (err.error is SocketException) {
          return const NetworkException(
            message: '网络连接失败，请检查网络设置',
          );
        }
        return ServerException(
          message: err.message ?? '发生未知错误',
          code: 'UNKNOWN_ERROR',
          originalError: err,
        );
    }
  }

  AppException _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    
    // 尝试从响应中获取错误信息
    String? serverMessage;
    String? errorCode;
    
    if (responseData is Map) {
      serverMessage = responseData['message'] as String? ??
          responseData['error'] as String? ??
          responseData['msg'] as String?;
      errorCode = responseData['code']?.toString();
    }
    
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: serverMessage ?? '请求参数错误',
          code: errorCode,
        );
      
      case 401:
        return TokenExpiredException(
          message: serverMessage ?? '登录已过期，请重新登录',
        );
      
      case 403:
        return const PermissionException(
          message: '没有操作权限',
        );
      
      case 404:
        return ServerException(
          message: serverMessage ?? '请求的资源不存在',
          statusCode: statusCode,
          code: errorCode,
        );
      
      case 408:
        return const TimeoutException(
          message: '请求超时',
        );
      
      case 422:
        return ValidationException(
          message: serverMessage ?? '数据验证失败',
          code: errorCode,
        );
      
      case 429:
        return ServerException(
          message: serverMessage ?? '请求过于频繁，请稍后再试',
          statusCode: statusCode,
          code: 'RATE_LIMIT',
        );
      
      case 500:
        return ServerException(
          message: serverMessage ?? '服务器内部错误',
          statusCode: statusCode,
          code: errorCode,
        );
      
      case 502:
        return const ServerException(
          message: '网关错误',
          statusCode: 502,
          code: 'BAD_GATEWAY',
        );
      
      case 503:
        return const ServerException(
          message: '服务暂时不可用',
          statusCode: 503,
          code: 'SERVICE_UNAVAILABLE',
        );
      
      case 504:
        return const ServerException(
          message: '网关超时',
          statusCode: 504,
          code: 'GATEWAY_TIMEOUT',
        );
      
      default:
        return ServerException(
          message: serverMessage ?? 'HTTP 错误 $statusCode',
          statusCode: statusCode,
          code: errorCode,
        );
    }
  }
}

