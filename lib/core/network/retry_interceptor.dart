// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Keys for per-request retry control via [Options.extra].
abstract final class RetryOptions {
  /// Whether retry is enabled for this request (bool).
  static const String kRetryEnabled = 'retry_enabled';

  /// Maximum number of retries for this request (int).
  static const String kMaxRetries = 'retry_max_retries';

  /// Internal: current attempt number (int). Do not set manually.
  static const String kRetryAttempt = 'retry_attempt';
}

/// Immutable retry policy configuration.
class RetryPolicy {
  /// Maximum number of retries (excludes the initial request).
  final int maxRetries;

  /// Base delay for exponential backoff.
  final Duration baseDelay;

  /// Maximum delay cap.
  final Duration maxDelay;

  /// Maximum random jitter added to each delay.
  final Duration maxJitter;

  /// HTTP methods eligible for automatic retry.
  final Set<String> retryableMethods;

  /// HTTP status codes that trigger a retry.
  final Set<int> retryableStatusCodes;

  /// Dio exception types that trigger a retry.
  final Set<DioExceptionType> retryableExceptionTypes;

  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 16),
    this.maxJitter = const Duration(milliseconds: 500),
    this.retryableMethods = const {'GET'},
    this.retryableStatusCodes = const {500, 502, 503, 504},
    this.retryableExceptionTypes = const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    },
  });
}

/// Dio interceptor that implements automatic retry with exponential backoff
/// and random jitter.
///
/// Inserted into [Dio.interceptors] to transparently retry failed requests
/// that match the configured [RetryPolicy]. Only retries idempotent methods
/// (GET by default) unless explicitly overridden via [Options.extra].
///
/// 429 responses with a `Retry-After` header are respected.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final RetryPolicy policy;

  /// Visible for testing — allows injecting a deterministic RNG.
  final Random random;

  final Connectivity _connectivity;

  RetryInterceptor({
    required this.dio,
    this.policy = const RetryPolicy(),
    Random? random,
    Connectivity? connectivity,
  })  : random = random ?? Random(),
        _connectivity = connectivity ?? Connectivity();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;

    if (!_isRetryable(err) || !_shouldRetry(options)) {
      return handler.next(err);
    }

    final int attempt = options.extra[RetryOptions.kRetryAttempt] as int? ?? 0;
    final int maxRetries =
        options.extra[RetryOptions.kMaxRetries] as int? ?? policy.maxRetries;

    if (attempt >= maxRetries) {
      return handler.next(err);
    }

    // Check if request was cancelled before waiting.
    if (options.cancelToken?.isCancelled == true) {
      return handler.next(err);
    }

    // Skip retry when device has no network connection.
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasNetwork =
        connectivityResults.any((r) => r != ConnectivityResult.none);
    if (!hasNetwork) return handler.next(err);

    await Future<void>.delayed(_calculateDelay(attempt, err));

    // Check again after the delay.
    if (options.cancelToken?.isCancelled == true) {
      return handler.next(err);
    }

    // Increment attempt counter.
    options.extra[RetryOptions.kRetryAttempt] = attempt + 1;

    try {
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      // Let the interceptor chain handle further retries or propagation.
      handler.next(retryErr);
    }
  }

  /// Determines whether the error type is eligible for retry.
  bool _isRetryable(DioException err) {
    // Never retry cancellations or certificate errors.
    if (err.type == DioExceptionType.cancel ||
        err.type == DioExceptionType.badCertificate) {
      return false;
    }

    // Timeout / connection errors.
    if (policy.retryableExceptionTypes.contains(err.type)) return true;

    // Bad response — check status code. 429 Too Many Requests is always retryable.
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      return statusCode != null &&
          (policy.retryableStatusCodes.contains(statusCode) ||
              statusCode == 429);
    }

    return false;
  }

  /// Determines whether the request method (or per-request override) allows retry.
  bool _shouldRetry(RequestOptions options) {
    // Per-request explicit override.
    final extraEnabled = options.extra[RetryOptions.kRetryEnabled];
    if (extraEnabled is bool) return extraEnabled;

    // Default: only retry methods in the policy allow-list.
    return policy.retryableMethods.contains(options.method.toUpperCase());
  }

  /// Calculates delay with exponential backoff + jitter.
  ///
  /// For 429 responses, respects the `Retry-After` header (seconds) when present.
  Duration _calculateDelay(int attempt, DioException err) {
    // Check for Retry-After header on 429 responses.
    if (err.response?.statusCode == 429) {
      final retryAfter = err.response?.headers.value('retry-after');
      final seconds = retryAfter != null ? int.tryParse(retryAfter) : null;
      if (seconds != null && seconds > 0) {
        // Clamp to maxDelay for safety.
        final serverDelay = Duration(seconds: seconds);
        return serverDelay > policy.maxDelay ? policy.maxDelay : serverDelay;
      }
    }

    // Exponential backoff: baseDelay * 2^attempt.
    final exponentialMs =
        policy.baseDelay.inMilliseconds * pow(2, attempt).toInt();
    final clampedMs = min(exponentialMs, policy.maxDelay.inMilliseconds);

    // Random jitter in [0, maxJitter].
    final jitterMs = random.nextInt(policy.maxJitter.inMilliseconds + 1);

    return Duration(milliseconds: clampedMs + jitterMs);
  }
}
