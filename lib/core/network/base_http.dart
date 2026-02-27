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

  /// Reset Dio connection with optional test mode
  void reSetDio(bool isTest) {
    _initDio();
  }

  void _initDio() {
    _options = _buildBaseOptions();
    _dio = Dio(_options)
      ..interceptors.add(CircuitBreakerInterceptor())
      ..interceptors.add(RetryInterceptor(dio: _dio));
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

  String get _contentTypeString {
    switch (headerType) {
      case 0:
        return 'application/json';
      case 1:
        return 'multipart/form-data';
      default:
        return 'application/x-www-form-urlencoded';
    }
  }

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
        contentType: _contentTypeString,
        extra: enableRetry ? {RetryOptions.kRetryEnabled: true} : null,
        headers: {
          if (header != null) ...header,
          if (userInfo != null) ...userInfo,
        },
      );

      // Preserve explicit content-type from caller header if provided
      if (header != null && header['content-type'] == null) {
        options.contentType = _contentTypeString;
      }

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

  T _handleResponse<T>(Response<dynamic> response, bool defaultReturn) {
    final statusCode = response.statusCode;
    if (statusCode != 200 && statusCode != 201 && statusCode != 202) {
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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return S.current.g_key_error_4;
      case DioExceptionType.badCertificate:
        return S.current.g_key_error_27;
      case DioExceptionType.badResponse:
        final response = error.response;
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
      case DioExceptionType.cancel:
        return S.current.g_key_error_8;
      case DioExceptionType.unknown:
        return S.current.g_key_error_10;
    }
  }

  /// Handle HTTP error codes
  String _handleHttpError(int? errorCode) {
    switch (errorCode) {
      case 400:
        return S.current.g_key_error_11;
      case 401:
        return S.current.g_key_error_12;
      case 403:
        return S.current.g_key_error_13;
      case 404:
        return S.current.g_key_error_14;
      case 408:
        return S.current.g_key_error_15;
      case 429:
        return S.current.g_key_error_23;
      case 500:
        return S.current.g_key_error_16;
      case 501:
        return S.current.g_key_error_17;
      case 502:
        return S.current.g_key_error_18;
      case 503:
        return S.current.g_key_error_19;
      case 504:
        return S.current.g_key_error_20;
      case 505:
        return S.current.g_key_error_21;
      default:
        return '${S.current.g_key_error_22}$errorCode';
    }
  }

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
