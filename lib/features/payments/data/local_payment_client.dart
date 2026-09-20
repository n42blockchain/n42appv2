import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Local test transport only. Never use Matrix tokens or production credentials.
/// Switching accounts discards old responses; it cannot undo an accepted payment.
final class LocalPaymentClient {
  LocalPaymentClient({
    required Uri endpoint,
    required http.Client transport,
    this.enabled = false,
    this.timeout = const Duration(seconds: 10),
  }) : _endpoint = endpoint,
       _transport = transport {
    if (endpoint.scheme != 'http' ||
        endpoint.host != '127.0.0.1' ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.hasQuery ||
        endpoint.hasFragment ||
        (endpoint.path.isNotEmpty && endpoint.path != '/')) {
      throw ArgumentError('Local payment endpoint must be HTTP loopback');
    }
    if (timeout <= Duration.zero) throw ArgumentError('Invalid timeout');
  }

  final Uri _endpoint;
  final http.Client _transport;
  final bool enabled;
  final Duration timeout;
  String? _token;
  int _generation = 0;
  bool _closed = false;

  void activateTestAccount(String syntheticToken) {
    _requireEnabled();
    if (!RegExp(
      r'^synthetic-test-[A-Za-z0-9_-]{8,128}$',
    ).hasMatch(syntheticToken)) {
      throw ArgumentError('Expected a synthetic test account token');
    }
    _generation++;
    _token = syntheticToken;
  }

  void clearAccount() {
    _generation++;
    _token = null;
  }

  void close() {
    clearAccount();
    _closed = true;
    // The injected transport is owned by the caller.
  }

  Future<BigInt> balance(String asset) async {
    final result = await _request('GET', '/balances', query: {'asset': asset});
    if (result['asset'] != asset) {
      throw const LocalPaymentException('invalid_response');
    }
    return _units(result['available']);
  }

  Future<Map<String, dynamic>> transfer({
    required String recipient,
    required String asset,
    required BigInt amount,
    required String key,
  }) => _request(
    'POST',
    '/transfers',
    key: key,
    body: {'recipient': recipient, 'asset': asset, 'amount': _positive(amount)},
  );

  Future<Map<String, dynamic>> createPacket({
    required String room,
    required String asset,
    required BigInt total,
    required int slots,
    required DateTime expiresAt,
    required String key,
  }) {
    if (slots <= 0 || expiresAt.millisecondsSinceEpoch < 0) {
      throw ArgumentError('Invalid packet terms');
    }
    return _request(
      'POST',
      '/packets',
      key: key,
      body: {
        'room': room,
        'asset': asset,
        'total': _positive(total),
        'slots': slots.toString(),
        'expiresAt': (expiresAt.millisecondsSinceEpoch ~/ 1000).toString(),
      },
    );
  }

  Future<Map<String, dynamic>> claim(String packet, {required String key}) =>
      _packetAction(packet, 'claims', key);

  Future<Map<String, dynamic>> refund(String packet, {required String key}) =>
      _packetAction(packet, 'refunds', key);

  Future<Map<String, dynamic>> _packetAction(
    String packet,
    String action,
    String key,
  ) {
    if (!RegExp(r'^packet_[a-f0-9]{64}$').hasMatch(packet)) {
      throw ArgumentError('Invalid local packet identifier');
    }
    return _request('POST', '/packets/$packet/$action', key: key, body: {});
  }

  void _requireEnabled() {
    if (!enabled || kReleaseMode || _closed) {
      throw const LocalPaymentException('disabled');
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    String? key,
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    _requireEnabled();
    final token = _token;
    if (token == null) throw const LocalPaymentException('account_required');
    final generation = _generation;
    final request =
        http.Request(
            method,
            _endpoint.replace(path: path, queryParameters: query),
          )
          ..followRedirects = false
          ..headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      if (key == null || !RegExp(r'^[\x21-\x7e]{1,128}$').hasMatch(key)) {
        throw ArgumentError('Invalid idempotency key');
      }
      request.headers['Content-Type'] = 'application/json';
      request.headers['Idempotency-Key'] = key;
      request.body = jsonEncode(body);
      if (request.bodyBytes.length > 65536) {
        throw const LocalPaymentException('payload_too_large');
      }
    }
    try {
      final result = await _exchange(request).timeout(timeout);
      if (generation != _generation || _closed) {
        throw const LocalPaymentException('account_changed');
      }
      _validateReceipt(path, body, result);
      return result;
    } on LocalPaymentException {
      if (generation != _generation || _closed) {
        throw const LocalPaymentException('account_changed');
      }
      rethrow;
    } catch (_) {
      if (generation != _generation || _closed) {
        throw const LocalPaymentException('account_changed');
      }
      throw const LocalPaymentException('transport_error');
    }
  }

  static void _validateReceipt(
    String path,
    Map<String, dynamic>? body,
    Map<String, dynamic> result,
  ) {
    if (body == null) return;
    final fields = path == '/transfers'
        ? ['recipient', 'asset', 'amount']
        : path == '/packets'
        ? ['asset', 'total', 'slots', 'expiresAt']
        : <String>[];
    for (final field in fields) {
      if (result[field] != body[field]) {
        throw const LocalPaymentException('invalid_response');
      }
    }
    if (result['asset'] is! String || (result['asset'] as String).isEmpty) {
      throw const LocalPaymentException('invalid_response');
    }
    if (path.endsWith('/claims')) {
      if (result['packet'] != path.split('/')[2]) {
        throw const LocalPaymentException('invalid_response');
      }
      _units(result['amount']);
    } else {
      if (result['id'] is! String || (result['id'] as String).isEmpty) {
        throw const LocalPaymentException('invalid_response');
      }
      if (path.endsWith('/refunds')) _units(result['amount']);
    }
  }

  Future<Map<String, dynamic>> _exchange(http.Request request) async {
    final response = await _transport.send(request);
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      if (bytes.length + chunk.length > 65536) {
        throw const LocalPaymentException('invalid_response');
      }
      bytes.addAll(chunk);
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic> ||
        decoded['mode'] != 'localSimulation') {
      throw const LocalPaymentException('invalid_response');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'];
      const known = {
        'unauthorized',
        'invalid_request',
        'not_found',
        'conflict',
        'payload_too_large',
      };
      final code = error is Map ? error['code'] : null;
      throw LocalPaymentException(
        known.contains(code) ? code as String : 'server_error',
      );
    }
    for (final field in [
      'available',
      'amount',
      'total',
      'slots',
      'expiresAt',
    ]) {
      if (decoded.containsKey(field)) _units(decoded[field]);
    }
    return Map.unmodifiable(decoded);
  }

  static BigInt _units(dynamic value) {
    if (value is! String || !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(value)) {
      throw const LocalPaymentException('invalid_response');
    }
    return BigInt.parse(value);
  }

  static String _positive(BigInt value) {
    if (value <= BigInt.zero) throw ArgumentError('Amount must be positive');
    return value.toString();
  }
}

final class LocalPaymentException implements Exception {
  const LocalPaymentException(this.code);
  final String code;
  @override
  String toString() => 'LocalPaymentException: $code';
}
