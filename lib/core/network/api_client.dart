// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:dio/dio.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

/// 应用通用 HTTP 客户端
///
/// 封装 Dio 实例，预配置：
/// - 30 秒超时（连接/接收/发送）
/// - Auth 拦截器：自动注入 Bearer Token
/// - Logging 拦截器：调试模式输出请求/响应日志
/// - Retry 拦截器：超时时自动重试一次
/// - Error 拦截器：统一错误日志
class ApiClient {
  final SecureStorage _secureStorage;
  final Dio _dio;

  Dio get dio => _dio;

  /// 日志中需要过滤的敏感请求头
  static const _sensitiveHeaders = [
    'Authorization',
    'authorization',
    'Cookie',
    'cookie',
    'Token',
    'token',
    'Uuid',
  ];
  static const _retryableMethods = {'GET', 'HEAD', 'OPTIONS'};

  ApiClient(this._secureStorage)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 1. Auth + Logging 请求拦截器：注入 Token，输出安全日志
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final safeHeaders = Map<String, dynamic>.from(options.headers)
            ..removeWhere((key, _) => _sensitiveHeaders.contains(key));
          AppLogger.d(
            'ApiClient',
            '→ ${options.method} ${options.path} headers: $safeHeaders',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d(
            'ApiClient',
            '← ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
      ),
    );

    // 2. Retry + Error 错误拦截器：超时重试一次，输出统一错误日志
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final isTimeout =
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout;

          if (isTimeout &&
              shouldRetryRequest(error.requestOptions) &&
              error.requestOptions.extra['_retried'] != true) {
            try {
              error.requestOptions.extra['_retried'] = true;
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (_) {
              // 重试也失败，继续传递原始错误
            }
          }

          AppLogger.w(
            'ApiClient',
            '${error.requestOptions.method} ${error.requestOptions.path} → '
                '${error.response?.statusCode} ${error.message}',
          );
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  static bool shouldRetryRequest(RequestOptions options) {
    return _retryableMethods.contains(options.method.toUpperCase());
  }
}
