import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/circuit_breaker_interceptor.dart';

// ---------------------------------------------------------------------------
// Mock HTTP adapter (same pattern as retry_interceptor_test.dart)
// ---------------------------------------------------------------------------

class _MockHttpAdapter implements HttpClientAdapter {
  final List<_MockResponse> responses = [];

  void enqueue(int statusCode, {dynamic data}) {
    responses.add(_MockResponse(statusCode, data: data));
  }

  /// Enqueue [count] responses with the same status code.
  void enqueueMany(int count, int statusCode) {
    for (var i = 0; i < count; i++) {
      enqueue(statusCode);
    }
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (responses.isEmpty) {
      throw StateError('No more mock responses');
    }
    final mock = responses.removeAt(0);
    return ResponseBody.fromString(
      mock.data?.toString() ?? '{"ok":true}',
      mock.statusCode,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MockResponse {
  final int statusCode;
  final dynamic data;
  _MockResponse(this.statusCode, {this.data});
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

({Dio dio, _MockHttpAdapter adapter, CircuitBreakerInterceptor cb})
    _createTestDio({CircuitBreakerConfig? config}) {
  final adapter = _MockHttpAdapter();
  final cb = CircuitBreakerInterceptor(
    config: config ?? const CircuitBreakerConfig(failureThreshold: 3),
  );
  final dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(cb);
  return (dio: dio, adapter: adapter, cb: cb);
}

void main() {
  // ---------------------------------------------------------------------------
  // State transitions
  // ---------------------------------------------------------------------------

  group('state transitions', () {
    test('starts in closed state', () {
      final cb = CircuitBreakerInterceptor();
      expect(cb.state, CircuitState.closed);
      expect(cb.failureCount, 0);
    });

    test('stays closed below failure threshold', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 3),
      );
      adapter.enqueue(502);
      adapter.enqueue(502);

      // Two failures — below threshold of 3.
      try { await dio.get('/a'); } catch (_) {}
      try { await dio.get('/b'); } catch (_) {}

      expect(cb.state, CircuitState.closed);
      expect(cb.failureCount, 2);
    });

    test('opens after reaching failure threshold', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 3),
      );
      adapter.enqueueMany(3, 502);

      for (var i = 0; i < 3; i++) {
        try { await dio.get('/test'); } catch (_) {}
      }

      expect(cb.state, CircuitState.open);
      expect(cb.failureCount, 3);
    });

    test('rejects immediately when open', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(
          failureThreshold: 2,
          recoveryTimeout: Duration(hours: 1), // won't expire in test
        ),
      );

      // Trip the circuit.
      adapter.enqueueMany(2, 500);
      try { await dio.get('/a'); } catch (_) {}
      try { await dio.get('/b'); } catch (_) {}
      expect(cb.state, CircuitState.open);

      // Next request should be rejected without consuming adapter response.
      adapter.enqueue(200);
      expect(
        () => dio.get('/c'),
        throwsA(isA<DioException>().having(
          (e) => e.error.toString(),
          'error message',
          contains('Circuit breaker is open'),
        )),
      );

      // The 200 response was NOT consumed — circuit rejected before reaching adapter.
      expect(adapter.responses.length, 1);
    });

    test('transitions to halfOpen after recovery timeout', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(
          failureThreshold: 2,
          recoveryTimeout: Duration.zero, // immediately eligible for recovery
        ),
      );

      // Trip the circuit.
      adapter.enqueueMany(2, 502);
      try { await dio.get('/a'); } catch (_) {}
      try { await dio.get('/b'); } catch (_) {}
      expect(cb.state, CircuitState.open);

      // With recoveryTimeout=0, next request should transition to halfOpen and go through.
      adapter.enqueue(200);
      final response = await dio.get('/c');
      expect(response.statusCode, 200);
      // Successful probe closes the circuit.
      expect(cb.state, CircuitState.closed);
    });

    test('halfOpen probe failure re-opens circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(
          failureThreshold: 2,
          recoveryTimeout: Duration.zero,
        ),
      );

      // Trip the circuit.
      adapter.enqueueMany(2, 503);
      try { await dio.get('/a'); } catch (_) {}
      try { await dio.get('/b'); } catch (_) {}
      expect(cb.state, CircuitState.open);

      // Probe request also fails → re-open.
      adapter.enqueue(503);
      try { await dio.get('/c'); } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('success resets failure count and closes circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 5),
      );

      // Accumulate some failures.
      adapter.enqueueMany(3, 502);
      for (var i = 0; i < 3; i++) {
        try { await dio.get('/test'); } catch (_) {}
      }
      expect(cb.failureCount, 3);

      // A success resets everything.
      adapter.enqueue(200);
      await dio.get('/test');
      expect(cb.failureCount, 0);
      expect(cb.state, CircuitState.closed);
    });
  });

  // ---------------------------------------------------------------------------
  // Trip error classification
  // ---------------------------------------------------------------------------

  group('trip error classification', () {
    test('500 trips the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(500);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('502 trips the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(502);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('503 trips the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(503);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('504 trips the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(504);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('400 does NOT trip the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(400);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.closed);
      expect(cb.failureCount, 0);
    });

    test('401 does NOT trip the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(401);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.closed);
    });

    test('404 does NOT trip the circuit', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(404);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.closed);
    });

    test('429 does NOT trip the circuit (rate limit, not server failure)', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(429);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.closed);
    });
  });

  // ---------------------------------------------------------------------------
  // Manual reset
  // ---------------------------------------------------------------------------

  group('reset()', () {
    test('resets state to closed', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 1),
      );
      adapter.enqueue(502);
      try { await dio.get('/test'); } catch (_) {}
      expect(cb.state, CircuitState.open);

      cb.reset();
      expect(cb.state, CircuitState.closed);
      expect(cb.failureCount, 0);
    });

    test('requests succeed after reset', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(
          failureThreshold: 1,
          recoveryTimeout: Duration(hours: 1),
        ),
      );

      // Trip the circuit with long recovery timeout.
      adapter.enqueue(502);
      try { await dio.get('/a'); } catch (_) {}
      expect(cb.state, CircuitState.open);

      // Without reset, request would be rejected.
      cb.reset();
      adapter.enqueue(200);
      final response = await dio.get('/b');
      expect(response.statusCode, 200);
    });
  });

  // ---------------------------------------------------------------------------
  // Config
  // ---------------------------------------------------------------------------

  group('CircuitBreakerConfig', () {
    test('default values', () {
      const config = CircuitBreakerConfig();
      expect(config.failureThreshold, 5);
      expect(config.recoveryTimeout, const Duration(seconds: 30));
      expect(config.tripStatusCodes, {500, 502, 503, 504});
      expect(config.tripExceptionTypes, {
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.connectionError,
      });
    });

    test('custom values', () {
      const config = CircuitBreakerConfig(
        failureThreshold: 10,
        recoveryTimeout: Duration(minutes: 1),
        tripStatusCodes: {500, 502},
      );
      expect(config.failureThreshold, 10);
      expect(config.recoveryTimeout, const Duration(minutes: 1));
      expect(config.tripStatusCodes, {500, 502});
    });
  });

  // ---------------------------------------------------------------------------
  // Successful requests
  // ---------------------------------------------------------------------------

  group('successful requests', () {
    test('do not increment failure count', () async {
      final (:dio, :adapter, :cb) = _createTestDio();
      adapter.enqueue(200);
      adapter.enqueue(200);
      adapter.enqueue(200);

      await dio.get('/a');
      await dio.get('/b');
      await dio.get('/c');

      expect(cb.failureCount, 0);
      expect(cb.state, CircuitState.closed);
    });

    test('interleaved success resets failure count', () async {
      final (:dio, :adapter, :cb) = _createTestDio(
        config: const CircuitBreakerConfig(failureThreshold: 5),
      );

      // 2 failures, then 1 success, then 2 failures → never trips (threshold 5).
      adapter.enqueue(502);
      adapter.enqueue(502);
      adapter.enqueue(200); // resets count
      adapter.enqueue(502);
      adapter.enqueue(502);

      try { await dio.get('/a'); } catch (_) {}
      try { await dio.get('/b'); } catch (_) {}
      expect(cb.failureCount, 2);

      await dio.get('/c'); // success resets
      expect(cb.failureCount, 0);

      try { await dio.get('/d'); } catch (_) {}
      try { await dio.get('/e'); } catch (_) {}
      expect(cb.failureCount, 2);
      expect(cb.state, CircuitState.closed);
    });
  });
}
