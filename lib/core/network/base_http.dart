// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/circuit_breaker_interceptor.dart';
import 'package:n42_wallet/core/network/retry_interceptor.dart';
import 'package:n42_wallet/core/security/security_config.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Base HTTP Client
///
/// Provides a centralized HTTP client using Dio.
/// Handles base URL configuration, headers, timeouts, and error handling.
///
/// ## Security Note
/// In production mode (kReleaseMode), SSL certificate validation should be enabled.
/// The current implementation allows bypassing SSL validation for development only.
class BaseHttp {
  final String baseUrl;
  final String baseUrlTest;

  /// Content-Type:
  /// - 0: application/json
  /// - 1: multipart/form-data
  /// - 2: application/x-www-form-urlencoded
  final int headerType;
  final Map<String, String> headerMap;

  late Dio _dio;
  late BaseOptions _options;

  /// Creates a new HTTP client instance
  ///
  /// [baseUrl] - Production API base URL
  /// [baseUrlTest] - Test/Development API base URL
  /// [headerMap] - Additional headers to include in all requests
  /// [headerType] - Content-Type selector (0: JSON, 1: form-data, 2: urlencoded)
  BaseHttp(
    this.baseUrl,
    this.baseUrlTest,
    this.headerMap, {
    this.headerType = 0,
  }) {
    _initDio();
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  void _initDio() {
    _options = _buildBaseOptions();
    _dio = Dio(_options)..interceptors.add(CircuitBreakerInterceptor());
    _dio.interceptors.add(RetryInterceptor(dio: _dio));
    _configureHttpAdapter();
  }

  BaseOptions _buildBaseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.isOnline ? baseUrl : baseUrlTest,
      connectTimeout: const Duration(milliseconds: 60000),
      receiveTimeout: const Duration(milliseconds: 60000),
      headers: {_contentTypeKey: _contentTypeString, ...headerMap},
    );
  }

  /// Configure HTTP adapter with SSL handling
  void _configureHttpAdapter() {
    _dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        // Use unified security configuration for SSL certificate verification
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) =>
                SecurityConfig.verifySslCertificate(cert, host, port);
        return client;
      };
  }

  // ---------------------------------------------------------------------------
  // Content-Type helpers
  // ---------------------------------------------------------------------------

  String get _contentTypeString => switch (headerType) {
        0 => 'application/json',
        1 => 'multipart/form-data',
        _ => 'application/x-www-form-urlencoded',
      };

  static const String _contentTypeKey = 'content-type';

  // ---------------------------------------------------------------------------
  // Core request
  // ---------------------------------------------------------------------------

  /// Core request method
  Future<T> _request<T>(
    String path, {
    required String method,
    required Map<String, dynamic> params,
    dynamic data,
    void Function(int, int)? sendProgress,
    void Function(int, int)? receiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? header,
    bool defaultReturn = true,
    Map<String, String>? userInfo,
    bool enableRetry = false,
  }) async {
    // RESTful path parameter substitution
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        if (path.contains(':$key')) {
          path = path.replaceAll(':$key', value.toString());
        }
      });
    }

    try {
      final options = Options(
        method: method,
        contentType: header?['content-type'] as String? ?? _contentTypeString,
        extra: enableRetry ? {RetryOptions.kRetryEnabled: true} : null,
        headers: {
          if (header != null) ...header,
          if (userInfo != null) ...userInfo,
        },
      );

      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: params,
        options: options,
        onSendProgress: sendProgress,
        onReceiveProgress: receiveProgress,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, defaultReturn);
    } on DioException catch (e) {
      return Future.error(_handleDioError(e));
    } catch (e) {
      return Future.error(S.current.g_key_error_3);
    }
  }

  // ---------------------------------------------------------------------------
  // Response & error handling
  // ---------------------------------------------------------------------------

  static const _successCodes = {200, 201, 202};

  T _handleResponse<T>(Response<dynamic> response, bool defaultReturn) {
    final statusCode = response.statusCode;
    if (!_successCodes.contains(statusCode)) {
      throw _handleHttpError(statusCode);
    }

    if (response.data == null) {
      throw S.current.g_key_error_1;
    }

    try {
      if (!defaultReturn) {
        return response.data as T;
      }
      if (response.data is Map || response.data is List) {
        return response.data as T;
      }
      return json.decode(response.data.toString()) as T;
    } catch (e) {
      throw S.current.g_key_error_1;
    }
  }

  /// Handle Dio exceptions
  String _handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        S.current.g_key_error_4,
      DioExceptionType.badCertificate => S.current.g_key_error_27,
      DioExceptionType.badResponse => _handleBadResponse(error.response),
      DioExceptionType.cancel => S.current.g_key_error_8,
      DioExceptionType.unknown => S.current.g_key_error_10,
    };
  }

  String _handleBadResponse(Response<dynamic>? response) {
    if (response == null) return S.current.g_key_error_28;
    final data = response.data;
    if (data is Map && data.containsKey('error')) {
      final errorData = data['error'];
      if (errorData is Map && errorData.containsKey('message')) {
        return errorData['message'].toString();
      }
      if (errorData is String) return errorData;
    }
    return _handleHttpError(response.statusCode);
  }

  /// Handle HTTP error codes
  String _handleHttpError(int? errorCode) => switch (errorCode) {
        400 => S.current.g_key_error_11,
        401 => S.current.g_key_error_12,
        403 => S.current.g_key_error_13,
        404 => S.current.g_key_error_14,
        408 => S.current.g_key_error_15,
        429 => S.current.g_key_error_23,
        500 => S.current.g_key_error_16,
        501 => S.current.g_key_error_17,
        502 => S.current.g_key_error_18,
        503 => S.current.g_key_error_19,
        504 => S.current.g_key_error_20,
        505 => S.current.g_key_error_21,
        _ => '${S.current.g_key_error_22}$errorCode',
      };

  // ---------------------------------------------------------------------------
  // Public HTTP methods
  // ---------------------------------------------------------------------------

  /// GET request
  Future<T> get<T>(
    String path, {
    required Map<String, dynamic> params,
    bool defaultReturn = true,
    bool addUserInfo = false,
    Map<String, dynamic>? header,
  }) {
    return _request(
      path,
      method: 'GET',
      params: params,
      defaultReturn: defaultReturn,
      userInfo: addUserInfo ? getUserToken() : null,
      header: header,
    );
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> params,
    dynamic data,
    void Function(int, int)? sendProgress,
    void Function(int, int)? receiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? header,
    bool defaultReturn = true,
    bool addUserInfo = false,
    bool enableRetry = false,
  }) {
    return _request(
      path,
      method: 'POST',
      params: params,
      data: data,
      sendProgress: sendProgress,
      receiveProgress: receiveProgress,
      cancelToken: cancelToken,
      defaultReturn: defaultReturn,
      userInfo: addUserInfo ? getUserToken() : null,
      header: header,
      enableRetry: enableRetry,
    );
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> params,
    dynamic data,
    bool defaultReturn = true,
    bool addUserInfo = false,
    Map<String, dynamic>? header,
  }) {
    return _request(
      path,
      method: 'PUT',
      params: params,
      data: data,
      defaultReturn: defaultReturn,
      userInfo: addUserInfo ? getUserToken() : null,
      header: header,
    );
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    required Map<String, dynamic> params,
    dynamic data,
    bool defaultReturn = true,
    bool addUserInfo = false,
    Map<String, dynamic>? header,
  }) {
    return _request(
      path,
      method: 'DELETE',
      params: params,
      data: data,
      defaultReturn: defaultReturn,
      userInfo: addUserInfo ? getUserToken() : null,
      header: header,
    );
  }

  // ---------------------------------------------------------------------------
  // Auth helpers
  // ---------------------------------------------------------------------------

  /// Get user authentication token headers
  Map<String, String>? getUserToken() {
    final user = AppGlobals.userInfo;
    if (user == null) return null;
    return {
      'Source': 'app',
      'Uuid': user.uuid ?? '',
      'Token': user.token ?? '',
    };
  }
}
