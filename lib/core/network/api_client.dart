// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/security/secure_storage.dart';

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
  late final Dio _dio;

  Dio get dio => _dio;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 1. Auth 拦截器：注入认证 Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // 2. Logging 拦截器
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        logPrint: (object) {
          if (kDebugMode) debugPrint(object.toString());
        },
      ),
    );

    // 3. Retry 拦截器：超时时重试一次
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (_) {
              // 重试也失败，继续传递原始错误
            }
          }
          handler.next(error);
        },
      ),
    );

    // 4. Error 拦截器：统一错误日志
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('[ApiClient] ${error.requestOptions.method} '
                '${error.requestOptions.path} → '
                '${error.response?.statusCode} ${error.message}');
          }
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
}
