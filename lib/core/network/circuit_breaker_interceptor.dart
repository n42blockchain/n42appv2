// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:dio/dio.dart';

/// Circuit breaker states.
///
/// ```
/// closed ──(failures >= threshold)──► open
///   ▲                                   │
///   │                          (recoveryTimeout elapsed)
///   │                                   ▼
///   └────(probe succeeds)──────── halfOpen
///                                   │
///                          (probe fails)
///                                   │
///                                   ▼
///                                 open
/// ```
enum CircuitState { closed, open, halfOpen }

/// Immutable circuit breaker configuration.
class CircuitBreakerConfig {
  /// Number of consecutive trip-eligible failures before opening the circuit.
  final int failureThreshold;

  /// How long the circuit stays open before transitioning to half-open.
  final Duration recoveryTimeout;

  /// HTTP status codes that count as circuit-tripping failures.
  final Set<int> tripStatusCodes;

  /// Dio exception types that count as circuit-tripping failures.
  final Set<DioExceptionType> tripExceptionTypes;

  const CircuitBreakerConfig({
    this.failureThreshold = 5,
    this.recoveryTimeout = const Duration(seconds: 30),
    this.tripStatusCodes = const {500, 502, 503, 504},
    this.tripExceptionTypes = const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    },
  });
}

/// Dio interceptor implementing the circuit breaker pattern.
///
/// Tracks consecutive failures to backend services. When failures exceed
/// [CircuitBreakerConfig.failureThreshold], the circuit **opens** and
/// immediately rejects all requests for [CircuitBreakerConfig.recoveryTimeout].
///
/// After the timeout, the circuit transitions to **half-open**, allowing a
/// single probe request. If it succeeds, the circuit **closes** (normal
/// operation resumes). If it fails, the circuit re-opens.
///
/// **Interceptor order**: Add BEFORE [RetryInterceptor] so that:
/// - `onRequest`: circuit check runs first (rejects if open).
/// - `onError` (reverse order): retries are attempted first, then the final
///   failure is recorded by the circuit breaker.
///
/// Only server errors (5xx) and network-level failures trip the circuit.
/// Client errors (4xx), cancellations, and certificate errors do not.
class CircuitBreakerInterceptor extends Interceptor {
  final CircuitBreakerConfig config;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  /// Visible for testing.
  CircuitState get state => _state;

  /// Visible for testing.
  int get failureCount => _failureCount;

  CircuitBreakerInterceptor({
    this.config = const CircuitBreakerConfig(),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    switch (_state) {
      case CircuitState.closed:
      case CircuitState.halfOpen:
        handler.next(options);
      case CircuitState.open:
        if (_shouldAttemptRecovery()) {
          _state = CircuitState.halfOpen;
          handler.next(options);
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.unknown,
              error: 'Circuit breaker is open — '
                  'service unavailable, retry after '
                  '${config.recoveryTimeout.inSeconds}s',
            ),
          );
        }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _recordSuccess();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isTripError(err)) {
      _recordFailure();
    }
    handler.next(err);
  }

  /// Whether enough time has elapsed since the last failure to allow a probe.
  bool _shouldAttemptRecovery() {
    if (_lastFailureTime == null) return true;
    return DateTime.now().difference(_lastFailureTime!) >=
        config.recoveryTimeout;
  }

  /// Record a successful response — resets the failure counter and closes
  /// the circuit.
  void _recordSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
  }

  /// Record a trip-eligible failure. Opens the circuit when the threshold
  /// is reached.
  void _recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    if (_failureCount >= config.failureThreshold) {
      _state = CircuitState.open;
    }
  }

  /// Whether the error type should count towards tripping the circuit.
  bool _isTripError(DioException err) {
    if (config.tripExceptionTypes.contains(err.type)) {
      return true;
    }
    if (err.type == DioExceptionType.badResponse) {
      final code = err.response?.statusCode;
      return code != null && config.tripStatusCodes.contains(code);
    }
    return false;
  }

  /// Manually reset the circuit to closed state.
  ///
  /// Useful when external signals (e.g., connectivity restored) indicate
  /// the service may be available again.
  void reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _lastFailureTime = null;
  }
}
