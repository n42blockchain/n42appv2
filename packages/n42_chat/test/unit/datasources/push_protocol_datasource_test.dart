import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/data/datasources/push_protocol/push_protocol_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'fetchNotifications supports current and legacy response fields',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/apis'))
        ..httpClientAdapter = adapter;

      final datasource = PushProtocolDatasource(prefs: prefs, dio: dio);
      const address = '0x0000000000000000000000000000000000000000';

      final current = await datasource.fetchNotifications(
        walletAddress: address,
      );
      final legacy = await datasource.fetchNotifications(
        walletAddress: address,
        page: 2,
      );

      expect(current.single['payload_id'], '1');
      expect(legacy.single['payload_id'], '2');
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.first.uri.path,
        '/apis/v1/users/eip155:1:$address/feeds',
      );
      expect(adapter.requests.first.queryParameters, {'page': 1, 'limit': 20});
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final page = options.queryParameters['page'].toString();
    final field = page == '1' ? 'feeds' : 'results';
    return ResponseBody.fromString(
      jsonEncode({
        field: [
          {'payload_id': page},
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
