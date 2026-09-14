import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/repositories/auth_repository_impl.dart';

class _Client extends Mock implements Client {}

class _Auth extends Mock implements MatrixAuthDataSource {}

class _Manager extends Mock implements MatrixClientManager {}

class _Storage extends SecureStorageDataSource {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

void main() {
  late _Client client;
  late _Storage storage;
  late AuthRepositoryImpl repository;
  setUp(() {
    client = _Client();
    storage = _Storage();
    final auth = _Auth();
    final manager = _Manager();
    when(() => auth.clientManager).thenReturn(manager);
    when(() => auth.isLoggedIn).thenReturn(true);
    when(() => manager.client).thenReturn(client);
    when(() => client.userID).thenReturn('@alice:test');
    when(() => client.homeserver).thenReturn(Uri.parse('https://hs.test'));
    when(() => client.deviceID).thenReturn('device');
    when(
      () => client.requestTokenTo3PIDEmail(any(), any(), any()),
    ).thenAnswer((_) async => RequestTokenResponse(sid: 'session-1'));
    when(() => client.add3PID(any(), any())).thenAnswer((_) async {});
    repository = AuthRepositoryImpl(
      authDataSource: auth,
      secureStorage: storage,
    );
  });
  tearDown(() => repository.dispose());
  test(
    'confirm cannot bind a different address from the requested email',
    () async {
      await repository.requestChangeEmail(
        password: 'password',
        newEmail: 'alice@example.org',
      );
      await expectLater(
        repository.confirmChangeEmail(newEmail: 'bob@example.org', code: ''),
        throwsStateError,
      );
      verifyNever(() => client.add3PID(any(), any()));
    },
  );
  test(
    'failed second request cannot mix its address and secret with the old sid',
    () async {
      await repository.requestChangeEmail(
        password: 'password',
        newEmail: 'alice@example.org',
      );
      final before = Map<String, String>.of(storage.values);
      when(
        () => client.requestTokenTo3PIDEmail(any(), 'bob@example.org', any()),
      ).thenThrow(StateError('offline'));
      await expectLater(
        repository.requestChangeEmail(
          password: 'password',
          newEmail: 'bob@example.org',
        ),
        throwsStateError,
      );
      expect(storage.values, before);
    },
  );
}
