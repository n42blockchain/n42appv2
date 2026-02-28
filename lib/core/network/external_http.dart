// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Lightweight HTTP client for third-party external APIs
/// (CoinGecko, alternative.me, CryptoCompare, etc.).
///
/// Intentionally has NO circuit breaker and NO retry interceptor so that
/// failures against external endpoints cannot trip the shared N42 circuit
/// breaker and block wallet-critical API calls.
///
/// Uses a conservative 10-second connect + receive timeout.
/// Callers are responsible for wrapping awaits with their own
/// [Future.timeout] if an even shorter deadline is needed.
class ExternalHttp {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'content-type': 'application/json'},
    ),
  );

  /// GET [url] and return the parsed response body, or null on any error.
  static Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final resp = await _dio.get<dynamic>(
        url,
        options: headers != null ? Options(headers: headers) : null,
      );
      return resp.data;
    } on DioException catch (e) {
      debugPrint('ExternalHttp.get error [$url]: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('ExternalHttp.get unexpected error [$url]: $e');
      return null;
    }
  }
}
