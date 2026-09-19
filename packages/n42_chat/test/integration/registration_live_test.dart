// Opt-in production smoke. Creates and deactivates one disposable account.
// N42_REGISTRATION_SMOKE_URL=https://m.si46.world flutter test --no-pub \
//   test/integration/registration_live_test.dart
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';

class _Client extends Mock implements Client {}

class _Manager extends Mock implements MatrixClientManager {}

void main() {
  final url = Platform.environment['N42_REGISTRATION_SMOKE_URL'];
  test(
    'live datasource UIA registration, password login and cleanup',
    () async {
      final homeserver = Uri.parse(url!);
      expect(homeserver.scheme, 'https');
      final transport = http.Client();
      final api = MatrixApi(homeserver: homeserver, httpClient: transport);
      final username = 'n42_uia_${DateTime.now().microsecondsSinceEpoch}';
      final random = Random.secure();
      final password = List.generate(
        32,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      final client = _Client();
      final manager = _Manager();
      registerFallbackValue(homeserver);
      registerFallbackValue(AuthenticationData());
      when(() => manager.isInitialized).thenReturn(true);
      when(() => manager.client).thenReturn(client);
      when(() => manager.rememberCurrentAccount()).thenAnswer((_) async {});
      when(() => client.checkHomeserver(any())).thenAnswer(
        (_) async => (null, await api.getVersions(), <LoginFlow>[], null),
      );
      var attempts = 0;
      when(
        () => client.register(
          username: any(named: 'username'),
          password: any(named: 'password'),
          initialDeviceDisplayName: any(named: 'initialDeviceDisplayName'),
          auth: any(named: 'auth'),
        ),
      ).thenAnswer((call) async {
        attempts++;
        final response = await api.register(
          username: call.namedArguments[#username] as String,
          password: call.namedArguments[#password] as String,
          initialDeviceDisplayName: 'N42 disposable registration smoke',
          auth: call.namedArguments[#auth] as AuthenticationData?,
        );
        api.accessToken = response.accessToken;
        return response;
      });
      String? userId;
      try {
        final registered = await MatrixAuthDataSource(
          clientManager: manager,
        ).register(homeserver: url, username: username, password: password);
        userId = registered.userId;
        expect(registered.accessToken?.isNotEmpty, isTrue);
        expect(attempts, 2);
        final login = await api.login(
          'm.login.password',
          identifier: AuthenticationUserIdentifier(user: registered.userId),
          password: password,
        );
        expect(login.userId == registered.userId, isTrue);
        expect(login.accessToken.isNotEmpty, isTrue);
      } finally {
        try {
          if (api.accessToken != null) {
            AuthenticationData passwordAuth(String? session) =>
                AuthenticationPassword(
                  password: password,
                  identifier: AuthenticationUserIdentifier(
                    user: userId ?? username,
                  ),
                  session: session,
                );
            try {
              await api.deactivateAccount(
                auth: passwordAuth(null),
                erase: true,
              );
            } on MatrixException catch (error) {
              if (!error.requireAdditionalAuthentication) rethrow;
              await api.deactivateAccount(
                auth: passwordAuth(error.session),
                erase: true,
              );
            }
          }
        } finally {
          transport.close();
        }
      }
    },
    skip: url == null
        ? 'Requires explicit disposable-account smoke URL'
        : false,
  );
}
