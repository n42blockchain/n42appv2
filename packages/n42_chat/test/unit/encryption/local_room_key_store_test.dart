import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/encryption/utils/stored_inbound_group_session.dart';
import 'package:matrix/encryption/utils/pickle_key.dart';
import 'package:matrix/encryption/utils/session_key.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vodozemac/vodozemac.dart' as vod;
import 'package:n42_chat/src/core/encryption/local_room_key_store.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_auth_datasource.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';

class _Client extends Mock implements Client {}

class _Db extends Mock implements DatabaseApi {}

class _Storage extends Mock implements FlutterSecureStorage {}

class _Manager extends Mock implements MatrixClientManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Client client;
  late _Db db;
  late LocalRoomKeyStore store;
  late Map<String, StoredInboundGroupSession> sessions;
  String id(StoredInboundGroupSession s) => '${s.roomId}|${s.sessionId}';
  StoredInboundGroupSession fixture(String session) =>
      StoredInboundGroupSession(
        roomId: '!room:hs',
        sessionId: session,
        pickle: 'fixture-pickle',
        content: '{}',
        indexes: '{}',
        allowedAtIndex: '{}',
        senderKey: 'sender',
        senderClaimedKeys: '{}',
      );
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    client = _Client();
    db = _Db();
    store = LocalRoomKeyStore();
    sessions = {};
    when(() => client.userID).thenReturn('@alice:hs');
    when(() => client.homeserver).thenReturn(Uri.parse('https://hs.test'));
    when(() => client.database).thenReturn(db);
    when(() => client.encryption).thenReturn(null);
    when(
      () => db.getAllInboundGroupSessions(),
    ).thenAnswer((_) async => sessions.values.toList());
    when(() => db.getInboundGroupSession(any(), any())).thenAnswer(
      (c) async =>
          sessions['${c.positionalArguments[0]}|${c.positionalArguments[1]}'],
    );
    when(
      () => db.storeInboundGroupSession(
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
        any(),
      ),
    ).thenAnswer((c) async {
      final a = c.positionalArguments.cast<String>();
      final s = StoredInboundGroupSession(
        roomId: a[0],
        sessionId: a[1],
        pickle: a[2],
        content: a[3],
        indexes: a[4],
        allowedAtIndex: a[5],
        senderKey: a[6],
        senderClaimedKeys: a[7],
      );
      sessions[id(s)] = s;
    });
  });
  test(
    'logout database clearing retains only account-scoped inbound history',
    () async {
      final saved = fixture('one');
      sessions[id(saved)] = saved;
      await store.preserve(client);
      sessions.clear();
      when(() => client.userID).thenReturn('@bob:hs');
      await store.restore(client);
      expect(sessions, isEmpty);
      when(() => client.userID).thenReturn('@alice:hs');
      when(() => client.homeserver).thenReturn(Uri.parse('https://other.test'));
      await store.restore(client);
      expect(sessions, isEmpty);
      when(() => client.homeserver).thenReturn(Uri.parse('https://hs.test/'));
      await store.restore(client);
      expect(sessions[id(saved)]?.pickle, saved.pickle);
      final values = await store.storage.readAll();
      expect(values.length, 1);
      expect(values.values.single, isNot(contains('access_token')));
      expect(values.values.single, isNot(contains('password')));
      await store.deleteForIdentity(Uri.parse('https://hs.test'), '@alice:hs');
      sessions.clear();
      await store.restore(client);
      expect(sessions, isEmpty);
    },
  );
  test(
    'successive logouts merge history and do not overwrite active sessions',
    () async {
      final old = fixture('old');
      final recent = fixture('recent');
      sessions[id(old)] = old;
      await store.preserve(client);
      sessions.clear();
      sessions[id(recent)] = recent;
      await store.preserve(client);
      await store.restore(client);
      expect(sessions.keys, containsAll([id(old), id(recent)]));
      verifyNever(
        () => db.storeInboundGroupSession(
          recent.roomId,
          recent.sessionId,
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      );
    },
  );
  test(
    'successive snapshots preserve replay indexes learned after login',
    () async {
      final first = fixture('same');
      sessions[id(first)] = first;
      await store.preserve(client);
      sessions[id(first)] = StoredInboundGroupSession(
        roomId: first.roomId,
        sessionId: first.sessionId,
        pickle: first.pickle,
        content: first.content,
        indexes: '{"42":"event-after-login"}',
        allowedAtIndex: first.allowedAtIndex,
        senderKey: first.senderKey,
        senderClaimedKeys: first.senderClaimedKeys,
      );
      await store.preserve(client);
      sessions.clear();
      await store.restore(client);
      expect(jsonDecode(sessions[id(first)]!.indexes), {
        '42': 'event-after-login',
      });
    },
  );
  test('secure write failure prevents destructive SDK logout', () async {
    final storage = _Storage();
    final manager = _Manager();
    sessions[id(fixture('one'))] = fixture('one');
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenThrow(StateError('fixture-secret-do-not-expose'));
    when(() => manager.client).thenReturn(client);
    final auth = MatrixAuthDataSource(
      clientManager: manager,
      localRoomKeys: LocalRoomKeyStore(storage: storage),
    );
    await expectLater(
      auth.logout(),
      throwsA(isA<LocalRoomKeyPreservationException>()),
    );
    verifyNever(() => manager.logout());
  });
  test(
    'native ciphertext decrypts after database clear and secure restore',
    () async {
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final package = (config['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['name'] == 'flutter_vodozemac');
      final root = configFile.uri
          .resolve(package['rootUri'] as String)
          .toFilePath();
      final native =
          Platform.environment['N42_VODOZEMAC_TEST_LIB'] ??
          '$root/macos/flutter_vodozemac/flutter_vodozemac.xcframework/macos-arm64_x86_64/flutter_vodozemac.framework/flutter_vodozemac';
      final dir = await Directory.systemTemp.createTemp('n42-history-crypto-');
      addTearDown(() => dir.delete(recursive: true));
      await Link(
        '${dir.path}/libvodozemac_bindings_dart.${Platform.isMacOS ? 'dylib' : 'so'}',
      ).create(native);
      await vod.init(libraryPath: '${dir.path}/');
      final outbound = vod.GroupSession();
      final inbound = vod.InboundGroupSession(outbound.sessionKey);
      final cipher = outbound.encrypt('readable after logout');
      final session = StoredInboundGroupSession(
        roomId: '!room:hs',
        sessionId: inbound.sessionId,
        pickle: inbound.toPickleEncrypted('@alice:hs'.toPickleKey()),
        content: '{}',
        indexes: '{}',
        allowedAtIndex: '{}',
        senderKey: 'sender',
        senderClaimedKeys: '{}',
      );
      sessions[id(session)] = session;
      final manager = _Manager();
      when(() => manager.client).thenReturn(client);
      when(() => manager.isInitialized).thenReturn(true);
      when(() => manager.logout()).thenAnswer((_) async {
        sessions.clear();
        when(() => client.userID).thenReturn(null);
      });
      when(
        () => manager.login(
          homeserver: any(named: 'homeserver'),
          username: any(named: 'username'),
          password: any(named: 'password'),
          deviceName: any(named: 'deviceName'),
        ),
      ).thenAnswer((_) async {
        when(() => client.userID).thenReturn('@alice:hs');
        return LoginResponse.fromJson({
          'user_id': '@alice:hs',
          'access_token': 'fixture-token',
          'device_id': 'NEW',
        });
      });
      final auth = MatrixAuthDataSource(
        clientManager: manager,
        localRoomKeys: store,
      );
      await auth.logout();
      expect(sessions, isEmpty);
      await auth.loginWithPassword(
        homeserver: 'https://hs.test',
        username: 'alice',
        password: 'fixture-password',
      );
      final restored = SessionKey.fromDb(sessions[id(session)]!, '@alice:hs');
      expect(
        restored.inboundGroupSession!.decrypt(cipher).plaintext,
        'readable after logout',
      );
    },
    skip:
        !Platform.isMacOS &&
        Platform.environment['N42_VODOZEMAC_TEST_LIB'] == null,
  );
}
