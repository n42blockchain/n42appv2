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
/// Tracks consecutive failures per request origin. When failures for one origin
/// reach [CircuitBreakerConfig.failureThreshold], that circuit **opens** and
/// rejects requests to that origin for [CircuitBreakerConfig.recoveryTimeout].
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

  final Map<String, _CircuitSnapshot> _circuits = {};

  /// Aggregate state visible for tests and diagnostics.
  ///
  /// Requests are isolated by origin. This getter reports the most restrictive
  /// state across tracked origins for compatibility with existing callers.
  CircuitState get state {
    if (_circuits.values.any((circuit) => circuit.state == CircuitState.open)) {
      return CircuitState.open;
    }
    if (_circuits.values.any(
      (circuit) => circuit.state == CircuitState.halfOpen,
    )) {
      return CircuitState.halfOpen;
    }
    return CircuitState.closed;
  }

  /// Maximum consecutive failure count across tracked origins.
  int get failureCount => _circuits.values.fold<int>(
    0,
    (maximum, circuit) =>
        circuit.failureCount > maximum ? circuit.failureCount : maximum,
  );

  CircuitBreakerInterceptor({this.config = const CircuitBreakerConfig()});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final circuit = _circuits[_originKey(options.uri)];
    if (circuit == null) {
      handler.next(options);
      return;
    }

    switch (circuit.state) {
      case CircuitState.closed:
      case CircuitState.halfOpen:
        handler.next(options);
      case CircuitState.open:
        if (circuit.lastFailureTime != null &&
            DateTime.now().difference(circuit.lastFailureTime!) >=
                config.recoveryTimeout) {
          circuit.state = CircuitState.halfOpen;
          handler.next(options);
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.unknown,
              error:
                  'Circuit breaker is open — '
                  'service unavailable, retry after '
                  '${config.recoveryTimeout.inSeconds}s',
            ),
          );
        }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _circuits.remove(_originKey(response.requestOptions.uri));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isTripError(err)) {
      final circuit = _circuits.putIfAbsent(
        _originKey(err.requestOptions.uri),
        _CircuitSnapshot.new,
      );
      circuit.failureCount++;
      circuit.lastFailureTime = DateTime.now();
      if (circuit.failureCount >= config.failureThreshold) {
        circuit.state = CircuitState.open;
      }
    }
    handler.next(err);
  }

  /// Whether the error type should count towards tripping the circuit.
  bool _isTripError(DioException err) {
    if (config.tripExceptionTypes.contains(err.type)) return true;
    if (err.type == DioExceptionType.badResponse) {
      final code = err.response?.statusCode;
      return code != null && config.tripStatusCodes.contains(code);
    }
    return false;
  }

  String _originKey(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final port = uri.port;
    return '$scheme://$host:$port';
  }

  /// Manually reset all origin circuits to closed state.
  ///
  /// Useful when external signals (e.g., connectivity restored) indicate
  /// the service may be available again.
  void reset() {
    _circuits.clear();
  }
}

class _CircuitSnapshot {
  CircuitState state = CircuitState.closed;
  int failureCount = 0;
  DateTime? lastFailureTime;
}
