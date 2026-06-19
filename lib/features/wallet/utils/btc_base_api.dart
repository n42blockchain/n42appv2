import 'dart:convert';

import 'package:bitcoin_base/bitcoin_base.dart' show ApiService;
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:http/http.dart' as http;

class ApiProviderException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const ApiProviderException(
    this.message, [
    this.statusCode,
    this.responseData,
  ]);

  @override
  String toString() => 'status: $statusCode $message ${responseData ?? ""}';
}

class BitcoinApiService implements ApiService {
  BitcoinApiService([http.Client? client]) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<T> get<T>(String url) async {
    final response = await _client.get(Uri.parse(url));
    return _readResponse<T>(response);
  }

  @override
  Future<T> post<T>(
    String url, {
    Map<String, String> headers = const {'Content-Type': 'application/json'},
    Object? body,
  }) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    return _readResponse<T>(response);
  }

  T _readResponse<T>(http.Response response) {
    final body = _readBody(response);
    if (T == String) return body as T;
    try {
      return jsonDecode(body) as T;
    } catch (e) {
      throw const ApiProviderException('invalid request');
    }
  }

  String _readBody(http.Response response) {
    _readErr(response);
    return StringUtils.decode(response.bodyBytes);
  }

  void _readErr(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) return;

    final body = StringUtils.decode(response.bodyBytes);
    Map<String, dynamic>? errorResult;
    try {
      if (body.isNotEmpty) errorResult = StringUtils.toJson(body);
    } catch (_) {
      // JSON 解析失败时 errorResult 保持为 null，安全忽略
    }
    throw ApiProviderException(
      body.isEmpty ? 'request_error' : body,
      response.statusCode,
      errorResult,
    );
  }
}
