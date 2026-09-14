import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/data/services/email_change_service.dart';

class _Client extends Mock implements Client {}

class _Storage extends SecureStorageDataSource {
  final values = <String, String>{};
  bool failWrite = false;
  bool failDelete = false;
  void Function()? afterWrite;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrite) throw StateError('storage unavailable');
    values[key] = value;
    afterWrite?.call();
  }

  @override
  Future<void> delete(String key) async {
    if (failDelete) throw StateError('cleanup unavailable');
    values.remove(key);
  }
}

void main() {
  late _Client client;
  late _Storage storage;
  late EmailChangeService service;
  late DateTime now;
  late String userId, token, device;
  late Uri homeserver;
  late bool loggedIn;
  late Uri? submitUrl;
  late List<http.Request> submissions;
  late Future<http.Response> Function(http.Request) respond;
  EmailChangeService fresh() => EmailChangeService(
    currentClient: () => client,
    isLoggedIn: () => loggedIn,
    storage: storage,
    now: () => now,
    httpClient: () => MockClient((request) async {
      submissions.add(request);
      return respond(request);
    }),
  );
  Future<void> request({String email = 'alice@example.org'}) =>
      service.request(newEmail: email);
  Future<bool> confirm({
    String email = 'alice@example.org',
    String code = 'aB-7',
  }) => service.confirm(newEmail: email, code: code, password: 'test-password');
  Map<String, dynamic> saved() =>
      jsonDecode(storage.values[EmailChangeService.sessionKey]!)
          as Map<String, dynamic>;
  Future<void> validateBeforeBindingFailure() async {
    when(
      () => client.add3PID(any(), any()),
    ).thenThrow(http.ClientException('binding unavailable'));
    await expectLater(confirm(), throwsA(isA<http.ClientException>()));
    when(() => client.add3PID(any(), any())).thenAnswer((_) async {});
  }

  setUpAll(() => registerFallbackValue(AuthenticationData()));
  setUp(() {
    client = _Client();
    storage = _Storage();
    now = DateTime.utc(2026, 9, 14);
    userId = '@alice:test';
    token = 'test-access-token';
    device = 'device';
    homeserver = Uri.parse('https://hs.test');
    loggedIn = true;
    submitUrl = Uri.parse('https://verify.test/email/submit');
    submissions = [];
    respond = (_) async => http.Response('{"success":true}', 200);
    when(() => client.userID).thenAnswer((_) => userId);
    when(() => client.homeserver).thenAnswer((_) => homeserver);
    when(() => client.deviceID).thenAnswer((_) => device);
    when(() => client.accessToken).thenAnswer((_) => token);
    when(() => client.requestTokenTo3PIDEmail(any(), any(), any())).thenAnswer(
      (_) async => RequestTokenResponse(sid: 'sid-1', submitUrl: submitUrl),
    );
    when(
      () => client.add3PID(any(), any(), auth: any(named: 'auth')),
    ).thenAnswer((_) async {});
    service = fresh();
  });

  test(
    'publishes a complete account-bound session without password or access token',
    () async {
      await request(email: ' alice+tag@example.technology ');
      final record = saved();
      expect(record['email'], 'alice+tag@example.technology');
      expect(record['userId'], userId);
      expect(record['homeserver'], homeserver.toString());
      expect(record['deviceId'], device);
      expect(record['attempt'], 1);
      expect(record['secret'], isNotEmpty);
      expect(storage.values.values.single, isNot(contains('test-password')));
      expect(
        storage.values.values.single,
        isNot(contains('test-access-token')),
      );
      expect(service.requiresCode, isTrue);
    },
  );

  test(
    'submits an opaque token unchanged without credentials or redirects before binding',
    () async {
      await request();
      final record = saved();
      respond = (req) async {
        verifyNever(
          () => client.add3PID(any(), any(), auth: any(named: 'auth')),
        );
        expect(req.url, submitUrl);
        expect(req.followRedirects, isFalse);
        expect(req.headers.containsKey('authorization'), isFalse);
        expect(req.headers['content-type'], 'application/json');
        expect(jsonDecode(req.body), {
          'sid': 'sid-1',
          'client_secret': record['secret'],
          'token': ' AbC=123 ',
        });
        return http.Response('{"success":true}', 200);
      };
      expect(await confirm(code: ' AbC=123 '), isTrue);
      verify(
        () => client.add3PID(record['secret'] as String, 'sid-1'),
      ).called(1);
      expect(storage.values, isEmpty);
    },
  );

  test(
    'link verification skips token HTTP and relies on the server binding result',
    () async {
      submitUrl = null;
      await request();
      expect(service.requiresCode, isFalse);
      expect(await confirm(code: ''), isTrue);
      expect(submissions, isEmpty);
      verify(() => client.add3PID(any(), 'sid-1')).called(1);
    },
  );

  test('link flow never silently ignores a supplied code', () async {
    submitUrl = null;
    await request();
    await expectLater(confirm(), throwsFormatException);
    verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
  });

  test(
    'unverified link preserves server error and the session for retry',
    () async {
      submitUrl = null;
      await request();
      final error = MatrixException.fromJson({
        'errcode': 'M_THREEPID_AUTH_FAILED',
      });
      when(() => client.add3PID(any(), any())).thenThrow(error);
      await expectLater(confirm(code: ''), throwsA(same(error)));
      expect(storage.values, isNotEmpty);
    },
  );

  for (final code in ['', '   ']) {
    test('empty token is rejected before sending ($code)', () async {
      await request();
      await expectLater(confirm(code: code), throwsFormatException);
      expect(submissions, isEmpty);
      verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
    });
  }
  for (final response in [
    http.Response('{"success":false}', 200),
    http.Response('{}', 200),
    http.Response('[]', 200),
    http.Response('invalid', 200),
    http.Response('{"success":"true"}', 200),
    http.Response('{"success":true}', 302),
    http.Response('{"errcode":"M_SESSION_EXPIRED"}', 400),
    http.Response('unavailable', 503),
  ]) {
    test(
      'failed token response cannot bind and can retry: ${response.statusCode} ${response.body}',
      () async {
        await request();
        respond = (_) async => response;
        await expectLater(confirm(), throwsA(isA<Exception>()));
        verifyNever(
          () => client.add3PID(any(), any(), auth: any(named: 'auth')),
        );
        expect(storage.values, isNotEmpty);
        respond = (_) async => http.Response('{"success":true}', 200);
        expect(await confirm(), isTrue);
      },
    );
  }

  for (final change in [
    'email',
    'user',
    'server',
    'device',
    'logout',
    'expiry',
  ]) {
    test('rejects mismatched or expired session: $change', () async {
      await request();
      switch (change) {
        case 'user':
          userId = '@bob:test';
        case 'server':
          homeserver = Uri.parse('https://other.test');
        case 'device':
          device = 'another-device';
        case 'logout':
          loggedIn = false;
        case 'expiry':
          now = now.add(const Duration(hours: 1));
      }
      await expectLater(
        confirm(
          email: change == 'email' ? 'bob@example.org' : 'alice@example.org',
        ),
        throwsStateError,
      );
      expect(submissions, isEmpty);
      verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
    });
  }

  for (final invalidUrl in [
    'http://verify.test/submit',
    'https://user:pass@verify.test/submit',
    '/submit',
    'https://verify.test/#token',
  ]) {
    test('unsafe token URL cannot publish a session: $invalidUrl', () async {
      submitUrl = Uri.parse(invalidUrl);
      await expectLater(request(), throwsFormatException);
      expect(storage.values, isEmpty);
    });
  }

  test('resend reuses the secret and increments send attempt', () async {
    await request();
    final first = saved();
    await request();
    final second = saved();
    expect(second['secret'], first['secret']);
    expect(second['attempt'], 2);
    verify(
      () => client.requestTokenTo3PIDEmail(
        first['secret'] as String,
        'alice@example.org',
        2,
      ),
    ).called(1);
  });

  test(
    'failed replacement leaves the complete prior session unchanged',
    () async {
      await request();
      final prior = Map<String, String>.of(storage.values);
      when(
        () => client.requestTokenTo3PIDEmail(any(), 'bob@example.org', any()),
      ).thenThrow(StateError('offline'));
      await expectLater(request(email: 'bob@example.org'), throwsStateError);
      expect(storage.values, prior);
      expect(await confirm(), isTrue);
    },
  );

  test(
    'rejected session persistence leaves old state and reports failure',
    () async {
      await request();
      final prior = Map<String, String>.of(storage.values);
      storage.failWrite = true;
      await expectLater(request(email: 'bob@example.org'), throwsStateError);
      expect(storage.values, prior);
      storage.failWrite = false;
      expect(await confirm(), isTrue);
    },
  );

  test(
    'a reconstructed service can use the complete stored token session',
    () async {
      await request();
      service = fresh();
      expect(await confirm(), isTrue);
    },
  );

  for (final invalid in [
    'bad-json',
    '{}',
    '{"version":2}',
    '{"version":1,"expiresAt":"bad"}',
  ]) {
    test(
      'malformed session cannot bind and fresh request repairs it: $invalid',
      () async {
        storage.values[EmailChangeService.sessionKey] = invalid;
        await expectLater(confirm(), throwsFormatException);
        verifyNever(
          () => client.add3PID(any(), any(), auth: any(named: 'auth')),
        );
        await request();
        expect(await confirm(), isTrue);
      },
    );
  }

  test('concurrent requests cannot replace an in-flight session', () async {
    final pending = Completer<RequestTokenResponse>();
    when(
      () => client.requestTokenTo3PIDEmail(any(), any(), any()),
    ).thenAnswer((_) => pending.future);
    final first = request();
    await Future<void>.delayed(Duration.zero);
    await expectLater(request(email: 'bob@example.org'), throwsStateError);
    pending.complete(RequestTokenResponse(sid: 'sid-1', submitUrl: submitUrl));
    await first;
    expect(saved()['email'], 'alice@example.org');
  });

  test('account switch while requesting prevents publication', () async {
    final pending = Completer<RequestTokenResponse>();
    when(
      () => client.requestTokenTo3PIDEmail(any(), any(), any()),
    ).thenAnswer((_) => pending.future);
    final result = request();
    await Future<void>.delayed(Duration.zero);
    token = 'new-login-token';
    pending.complete(RequestTokenResponse(sid: 'sid-1', submitUrl: submitUrl));
    await expectLater(result, throwsStateError);
    expect(storage.values, isEmpty);
  });

  test('account switch after token validation prevents binding', () async {
    await request();
    respond = (_) async {
      userId = '@bob:test';
      return http.Response('{"success":true}', 200);
    };
    await expectLater(confirm(), throwsStateError);
    verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
  });

  test(
    'password challenge uses the entered password and server UIA session',
    () async {
      submitUrl = null;
      await request();
      when(() => client.add3PID(any(), any())).thenThrow(
        MatrixException.fromJson({
          'session': 'uia-session',
          'flows': [
            {
              'stages': ['m.login.password'],
            },
          ],
        }),
      );
      expect(await confirm(code: ''), isTrue);
      final auth =
          verify(
                () => client.add3PID(
                  any(),
                  any(),
                  auth: captureAny(
                    named: 'auth',
                    that: isA<AuthenticationPassword>(),
                  ),
                ),
              ).captured.single
              as AuthenticationPassword;
      expect(auth.password, 'test-password');
      expect(auth.session, 'uia-session');
      expect(auth.identifier.toJson()['user'], '@alice:test');
    },
  );

  test('unsupported UIA stages cannot be bypassed with the password', () async {
    submitUrl = null;
    await request();
    final error = MatrixException.fromJson({
      'session': 'uia',
      'flows': [
        {
          'stages': ['m.login.sso'],
        },
      ],
    });
    when(() => client.add3PID(any(), any())).thenThrow(error);
    await expectLater(confirm(code: ''), throwsA(same(error)));
    verifyNever(
      () => client.add3PID(
        any(),
        any(),
        auth: any(named: 'auth', that: isNotNull),
      ),
    );
  });

  test('network failure retains the session and does not bind', () async {
    await request();
    respond = (_) async => throw http.ClientException('offline');
    await expectLater(confirm(), throwsA(isA<http.ClientException>()));
    expect(storage.values, isNotEmpty);
    verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
  });

  test('session reset while verifying prevents a stale binding', () async {
    await request();
    respond = (_) async {
      service.reset();
      return http.Response('{"success":true}', 200);
    };
    await expectLater(confirm(), throwsStateError);
    verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
  });

  test(
    'wrong UIA password is surfaced without clearing the verification session',
    () async {
      submitUrl = null;
      await request();
      when(() => client.add3PID(any(), any())).thenThrow(
        MatrixException.fromJson({
          'session': 'uia-session',
          'flows': [
            {
              'stages': ['m.login.password'],
            },
          ],
        }),
      );
      final wrongPassword = MatrixException.fromJson({
        'errcode': 'M_FORBIDDEN',
      });
      when(
        () => client.add3PID(
          any(),
          any(),
          auth: any(named: 'auth', that: isNotNull),
        ),
      ).thenThrow(wrongPassword);
      await expectLater(confirm(code: ''), throwsA(same(wrongPassword)));
      expect(storage.values, isNotEmpty);
      verify(
        () => client.add3PID(
          any(),
          any(),
          auth: any(named: 'auth', that: isNotNull),
        ),
      ).called(1);
    },
  );

  for (final sid in ['', 'invalid sid', 'x' * 256]) {
    test(
      'invalid server session id cannot be stored: length=${sid.length}',
      () async {
        when(
          () => client.requestTokenTo3PIDEmail(any(), any(), any()),
        ).thenAnswer(
          (_) async => RequestTokenResponse(sid: sid, submitUrl: submitUrl),
        );
        await expectLater(request(), throwsFormatException);
        expect(storage.values, isEmpty);
      },
    );
  }

  test('server success remains success if local cleanup fails', () async {
    await request();
    storage.failDelete = true;
    expect(await confirm(), isTrue);
    expect(service.requiresCode, isNull);
  });

  for (final restart in [false, true]) {
    test(
      'binding retry does not resubmit a consumed token (restart=$restart)',
      () async {
        await request();
        respond = (_) async => submissions.length == 1
            ? http.Response('{"success":true}', 200)
            : http.Response('{"success":false}', 400);
        when(() => client.add3PID(any(), any())).thenThrow(
          MatrixException.fromJson({
            'session': 'uia-session',
            'flows': [
              {
                'stages': ['m.login.password'],
              },
            ],
          }),
        );
        final wrongPassword = MatrixException.fromJson({
          'errcode': 'M_FORBIDDEN',
        });
        when(
          () => client.add3PID(
            any(),
            any(),
            auth: any(named: 'auth', that: isNotNull),
          ),
        ).thenThrow(wrongPassword);
        await expectLater(confirm(), throwsA(same(wrongPassword)));
        if (restart) service = fresh();
        when(
          () => client.add3PID(
            any(),
            any(),
            auth: any(named: 'auth', that: isNotNull),
          ),
        ).thenAnswer((_) async {});

        expect(await confirm(), isTrue);
        expect(submissions, hasLength(1));
        expect(storage.values, isEmpty);
      },
    );
  }

  test(
    'binding failure can resume after restart without retaining the token',
    () async {
      await request();
      await validateBeforeBindingFailure();
      final record = storage.values[EmailChangeService.sessionKey]!;
      expect(saved()['tokenValidated'], isTrue);
      expect(record, isNot(contains('aB-7')));
      expect(record, isNot(contains('test-password')));
      expect(record, isNot(contains('test-access-token')));
      service = fresh();
      expect(await confirm(code: ''), isTrue);
      expect(submissions, hasLength(1));
    },
  );

  test(
    'binding starts only after the validation checkpoint is durable',
    () async {
      await request();
      when(() => client.add3PID(any(), any())).thenAnswer((_) async {
        expect(saved()['tokenValidated'], isTrue);
      });
      expect(await confirm(), isTrue);
    },
  );

  test(
    'checkpoint write failure stops binding and preserves the prior record',
    () async {
      await request();
      final prior = Map<String, String>.of(storage.values);
      storage.failWrite = true;
      await expectLater(confirm(), throwsStateError);
      expect(submissions, hasLength(1));
      expect(storage.values, prior);
      verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
    },
  );

  test(
    'resending starts unvalidated even when the server reuses the session ID',
    () async {
      await request();
      await validateBeforeBindingFailure();
      await request();
      expect(saved()['attempt'], 2);
      expect(saved()['tokenValidated'], isFalse);
      await expectLater(confirm(code: ''), throwsFormatException);
      expect(await confirm(code: 'new-token'), isTrue);
      expect(submissions, hasLength(2));
      expect(jsonDecode(submissions.last.body)['token'], 'new-token');
    },
  );

  test(
    'failed resend retains validation progress for the previous request',
    () async {
      await request();
      await validateBeforeBindingFailure();
      final prior = Map<String, String>.of(storage.values);
      when(
        () => client.requestTokenTo3PIDEmail(any(), any(), any()),
      ).thenThrow(http.ClientException('request unavailable'));
      await expectLater(request(), throwsA(isA<http.ClientException>()));
      expect(storage.values, prior);
      expect(await confirm(code: ''), isTrue);
      expect(submissions, hasLength(1));
    },
  );

  test(
    'old version 1 sessions without a checkpoint still require a token',
    () async {
      await request();
      storage.values[EmailChangeService.sessionKey] = jsonEncode(
        saved()..remove('tokenValidated'),
      );
      service = fresh();
      await expectLater(confirm(code: ''), throwsFormatException);
      expect(await confirm(), isTrue);
      expect(submissions, hasLength(1));
    },
  );

  for (final invalid in ['true', 1, null]) {
    test(
      'malformed validation checkpoint cannot skip token submission: $invalid',
      () async {
        await request();
        storage.values[EmailChangeService.sessionKey] = jsonEncode(
          saved()..['tokenValidated'] = invalid,
        );
        await expectLater(confirm(), throwsFormatException);
        expect(submissions, isEmpty);
        verifyNever(
          () => client.add3PID(any(), any(), auth: any(named: 'auth')),
        );
      },
    );
  }

  for (final change in ['email', 'user', 'server', 'device', 'expiry']) {
    test(
      'validated session still enforces identity and expiry: $change',
      () async {
        await request();
        await validateBeforeBindingFailure();
        clearInteractions(client);
        switch (change) {
          case 'user':
            userId = '@bob:test';
          case 'server':
            homeserver = Uri.parse('https://other.test');
          case 'device':
            device = 'other-device';
          case 'expiry':
            now = now.add(const Duration(hours: 1));
        }
        service = fresh();
        await expectLater(
          confirm(
            email: change == 'email' ? 'bob@example.org' : 'alice@example.org',
            code: '',
          ),
          throwsStateError,
        );
        expect(submissions, hasLength(1));
        verifyNever(
          () => client.add3PID(any(), any(), auth: any(named: 'auth')),
        );
      },
    );
  }

  test(
    'account change during checkpoint persistence prevents binding',
    () async {
      await request();
      storage.afterWrite = () => userId = '@bob:test';
      await expectLater(confirm(), throwsStateError);
      verifyNever(() => client.add3PID(any(), any(), auth: any(named: 'auth')));
      service = fresh();
      await expectLater(confirm(code: ''), throwsStateError);
    },
  );
}
