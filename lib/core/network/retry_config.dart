// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:dio/dio.dart';
import 'package:n42_wallet/core/network/retry_interceptor.dart';

/// Pre-configured [RetryPolicy] presets and [Options] extension methods
/// for per-request retry control.
abstract final class RetryConfig {
  /// Default policy — 3 retries, 500 ms base delay, GET only.
  static const RetryPolicy defaultPolicy = RetryPolicy();

  /// Aggressive read — 5 retries, 300 ms base delay.
  /// Use for critical read operations like balance queries.
  static const RetryPolicy aggressiveRead = RetryPolicy(
    maxRetries: 5,
    baseDelay: Duration(milliseconds: 300),
  );

  /// Conservative — 2 retries, 2 s base delay.
  /// Use for rate-limited APIs.
  static const RetryPolicy conservative = RetryPolicy(
    maxRetries: 2,
    baseDelay: Duration(seconds: 2),
  );
}

/// Extension methods on [Options] for convenient per-request retry control.
extension RetryOptionsExtension on Options {
  /// Returns a copy with retry disabled for this request.
  Options noRetry() {
    return Options(
      method: method,
      headers: headers,
      contentType: contentType,
      responseType: responseType,
      extra: {...?extra, RetryOptions.kRetryEnabled: false},
    );
  }

  /// Returns a copy with retry explicitly enabled (e.g. for idempotent POST).
  Options withRetry({int? maxRetries}) {
    final extraMap = <String, dynamic>{
      ...?extra,
      RetryOptions.kRetryEnabled: true,
    };
    if (maxRetries != null) {
      extraMap[RetryOptions.kMaxRetries] = maxRetries;
    }
    return Options(
      method: method,
      headers: headers,
      contentType: contentType,
      responseType: responseType,
      extra: extraMap,
    );
  }
}
