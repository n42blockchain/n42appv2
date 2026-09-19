import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements Client {}

class _Database extends Mock implements DatabaseApi {}

void main() {
  test(
    'checking another homeserver neither sends the active token nor changes its client',
    () async {
      final manager = _Manager();
      final client = _Client();
      final database = _Database();
      final requests = <Uri>[];
      final httpClient = MockClient((request) async {
        requests.add(request.url);
        expect(request.headers.containsKey('authorization'), isFalse);
        if (request.url.path.contains('.well-known'))
          return http.Response('{}', 404);
        if (request.url.path.endsWith('/versions'))
          return http.Response(
            jsonEncode({
              'versions': ['v1.13'],
            }),
            200,
          );
        if (request.url.path.endsWith('/login'))
          return http.Response(
            jsonEncode({
              'flows': [
                {'type': 'm.login.password'},
              ],
            }),
            200,
          );
        throw StateError('Unexpected request');
      });
      when(() => manager.isInitialized).thenReturn(true);
      when(() => manager.client).thenReturn(client);
      when(() => client.userID).thenReturn('@alice:original.test');
      when(() => client.database).thenReturn(database);
      when(() => client.httpClient).thenReturn(httpClient);
      when(() => client.supportedLoginTypes).thenReturn({'m.login.password'});
      final source = MatrixAuthDataSource(clientManager: manager);
      final (_, versions, flows) = await source.checkHomeserver(
        'https://other.test',
      );
      expect(versions.versions, ['v1.13']);
      expect(flows.single.type, 'm.login.password');
      expect(requests.every((uri) => uri.host == 'other.test'), isTrue);
      verifyNever(
        () => client.checkHomeserver(Uri.parse('https://other.test')),
      );
      verifyNever(() => database.close());
      httpClient.close();
    },
  );
}
