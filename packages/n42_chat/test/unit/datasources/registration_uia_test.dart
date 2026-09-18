import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';

class _Client extends Mock implements Client {}

class _Manager extends Mock implements MatrixClientManager {}

void main() {
  late _Client client;
  late MatrixAuthDataSource source;
  late List<AuthenticationData?> requests;
  late List<Object> responses;
  final success = RegisterResponse.fromJson({
    'user_id': '@alice:test',
    'access_token': 'fixture',
    'device_id': 'device',
  });
  MatrixException challenge(
    List<List<String>> flows, {
    List<String> completed = const [],
  }) => MatrixException(
    http.Response(
      jsonEncode({
        'session': 'registration-session',
        'flows': flows.map((s) => {'stages': s}).toList(),
        'completed': completed,
      }),
      401,
    ),
  );
  Future<RegisterResponse> register({String? token}) => source.register(
    homeserver: 'https://hs.test',
    username: 'alice',
    password: 'Password123!',
    registrationToken: token,
  );
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://hs.test'));
    registerFallbackValue(AuthenticationData());
  });
  setUp(() {
    client = _Client();
    final manager = _Manager();
    when(() => manager.isInitialized).thenReturn(true);
    when(() => manager.client).thenReturn(client);
    when(() => client.checkHomeserver(any())).thenAnswer(
      (_) async =>
          (null, GetVersionsResponse(versions: ['v1.1']), <LoginFlow>[], null),
    );
    requests = [];
    responses = [success];
    when(
      () => client.register(
        username: any(named: 'username'),
        password: any(named: 'password'),
        initialDeviceDisplayName: any(named: 'initialDeviceDisplayName'),
        auth: any(named: 'auth'),
      ),
    ).thenAnswer((call) async {
      requests.add(call.namedArguments[#auth] as AuthenticationData?);
      final next = responses.removeAt(0);
      if (next is RegisterResponse) return next;
      throw next;
    });
    source = MatrixAuthDataSource(clientManager: manager);
  });
  test(
    'open registration does not send unsolicited token authentication',
    () async {
      expect(await register(token: 'provided-token'), same(success));
      expect(requests, [null]);
    },
  );
  test(
    'SDK transport challenge without HTTP response completes registration',
    () async {
      final api = MatrixApi();
      late MatrixException challenge;
      try {
        api.unexpectedResponse(
          http.Response('', 401),
          Uint8List.fromList(
            utf8.encode(
              jsonEncode({
                'session': 'sdk-session',
                'flows': [
                  {
                    'stages': ['m.login.dummy'],
                  },
                ],
              }),
            ),
          ),
        );
      } on MatrixException catch (error) {
        challenge = error;
      }
      expect(challenge.response, isNull);
      responses = [challenge, success];
      expect(await register(), same(success));
      expect(requests.last!.toJson(), {
        'type': 'm.login.dummy',
        'session': 'sdk-session',
      });
    },
  );
  test('dummy registration completes with the server session', () async {
    responses = [
      challenge([
        ['m.login.dummy'],
      ]),
      success,
    ];
    expect(await register(), same(success));
    expect(requests.last!.toJson(), {
      'type': 'm.login.dummy',
      'session': 'registration-session',
    });
  });
  test('token followed by dummy completes all required stages', () async {
    const stages = ['m.login.registration_token', 'm.login.dummy'];
    responses = [
      challenge([stages]),
      challenge([stages], completed: [stages.first]),
      success,
    ];
    expect(await register(token: 'supplied-token'), same(success));
    expect(requests[1]!.toJson(), {
      'type': stages.first,
      'session': 'registration-session',
      'token': 'supplied-token',
    });
    expect(requests[2]!.type, 'm.login.dummy');
  });
  test('chooses a supported complete alternative flow', () async {
    responses = [
      challenge([
        ['m.login.recaptcha'],
        ['m.login.dummy'],
      ]),
      success,
    ];
    expect(await register(), same(success));
    expect(requests.last!.type, 'm.login.dummy');
  });
  test(
    'missing token stops at challenge without bypassing required stages',
    () async {
      final error = challenge([
        ['m.login.registration_token', 'm.login.dummy'],
      ]);
      responses = [error];
      await expectLater(register(), throwsA(same(error)));
      expect(requests, [null]);
    },
  );
  test('decoded forbidden error is not retried as authentication', () async {
    final error = MatrixException.fromJson({
      'errcode': 'M_FORBIDDEN',
      'error': 'Registration has been disabled',
    });
    responses = [error];
    await expectLater(register(), throwsA(same(error)));
    expect(requests, [null]);
  });
  test('decoded unsupported authentication is not bypassed', () async {
    final error = MatrixException.fromJson({
      'session': 'sdk-session',
      'flows': [
        {
          'stages': ['m.login.recaptcha'],
        },
      ],
    });
    responses = [error];
    await expectLater(register(), throwsA(same(error)));
    expect(requests, [null]);
  });
  test('rejected token preserves actual server error', () async {
    final error = MatrixException(
      http.Response(
        '{"errcode":"M_FORBIDDEN","error":"Invalid registration token"}',
        403,
      ),
    );
    responses = [
      challenge([
        ['m.login.registration_token'],
      ]),
      error,
    ];
    await expectLater(register(token: 'invalid'), throwsA(same(error)));
    expect(requests, hasLength(2));
  });
  test('repeated incomplete stage stops instead of retrying forever', () async {
    final error = challenge([
      ['m.login.dummy'],
    ]);
    responses = [error, error];
    await expectLater(register(), throwsA(same(error)));
    expect(requests, hasLength(2));
  });
  test('malformed challenge preserves Matrix error', () async {
    final error = MatrixException.fromJson({
      'flows': [
        {
          'stages': ['m.login.dummy'],
        },
      ],
    });
    responses = [error];
    await expectLater(register(), throwsA(same(error)));
  });
}
