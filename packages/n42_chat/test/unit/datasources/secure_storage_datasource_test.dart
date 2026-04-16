// Tests for SecureStorageDataSource — exercises the actual wrapper class
// (not the raw FlutterSecureStorage mock) via an injected MockFlutterSecureStorage.
//
// Coverage targets: saveSession/getSession/clearSession/hasSession,
// saveCredentials/getCredentials/clearCredentials/hasCredentials,
// addAccount/getAccounts/removeAccount/getAccountCount,
// saveBiometricSettings/getBiometricSettings/isBiometricEnabled/
// enableBiometricLogin/disableBiometricLogin/getBiometricUsername/getBiometricHomeserver,
// read/write/delete/clearAll/isAvailable.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/secure_storage_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageDataSource dataSource;

  // In-memory store that backs all mock operations
  final Map<String, String> store = {};

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    store.clear();
    dataSource = SecureStorageDataSource(storage: mockStorage);

    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((inv) async {
      store[inv.namedArguments[#key] as String] =
          inv.namedArguments[#value] as String;
    });

    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((inv) async => store[inv.namedArguments[#key] as String]);

    when(() => mockStorage.delete(key: any(named: 'key'))).thenAnswer((
      inv,
    ) async {
      store.remove(inv.namedArguments[#key] as String);
    });

    when(() => mockStorage.deleteAll()).thenAnswer((_) async => store.clear());
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Session management
  // ─────────────────────────────────────────────────────────────────────────

  group('saveSession / getSession', () {
    test('saved session can be retrieved', () async {
      await dataSource.saveSession(
        homeserver: 'https://server.com',
        accessToken: 'tok_abc',
        userId: '@alice:server.com',
        deviceId: 'device1',
      );

      final session = await dataSource.getSession();
      expect(session, isNotNull);
      expect(session!['homeserver'], 'https://server.com');
      expect(session['accessToken'], 'tok_abc');
      expect(session['userId'], '@alice:server.com');
      expect(session['deviceId'], 'device1');
    });

    test('getSession returns null when nothing is stored', () async {
      final session = await dataSource.getSession();
      expect(session, isNull);
    });

    test('hasSession returns true after save', () async {
      await dataSource.saveSession(
        homeserver: 'https://s.com',
        accessToken: 't',
        userId: '@u:s.com',
        deviceId: 'd',
      );
      expect(await dataSource.hasSession(), isTrue);
    });

    test('hasSession returns false when empty', () async {
      expect(await dataSource.hasSession(), isFalse);
    });
  });

  group('clearSession', () {
    test('session is gone after clearSession', () async {
      await dataSource.saveSession(
        homeserver: 'https://s.com',
        accessToken: 't',
        userId: '@u:s.com',
        deviceId: 'd',
      );
      await dataSource.clearSession();
      expect(await dataSource.getSession(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Credentials management
  // ─────────────────────────────────────────────────────────────────────────

  group('saveCredentials / getCredentials', () {
    test('saved credentials can be retrieved', () async {
      final saved = await dataSource.saveCredentials(
        homeserver: 'https://server.com',
        username: 'alice',
      );
      expect(saved, isTrue);

      final creds = await dataSource.getCredentials();
      expect(creds, isNotNull);
      expect(creds!['homeserver'], 'https://server.com');
      expect(creds['username'], 'alice');
      expect(creds.containsKey('password'), isFalse);
    });

    test('getCredentials returns null when nothing is stored', () async {
      final creds = await dataSource.getCredentials();
      expect(creds, isNull);
    });

    test('hasCredentials is true after save', () async {
      await dataSource.saveCredentials(
        homeserver: 'https://s.com',
        username: 'u',
      );
      expect(await dataSource.hasCredentials(), isTrue);
    });

    test('hasCredentials is false when empty', () async {
      expect(await dataSource.hasCredentials(), isFalse);
    });
  });

  group('clearCredentials', () {
    test('credentials are gone after clear', () async {
      await dataSource.saveCredentials(
        homeserver: 'https://s.com',
        username: 'u',
      );
      await dataSource.clearCredentials();
      expect(await dataSource.getCredentials(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Multi-account management
  // ─────────────────────────────────────────────────────────────────────────

  group('addAccount / getAccounts', () {
    test('returns empty map when no accounts stored', () async {
      final accounts = await dataSource.getAccounts();
      expect(accounts, isEmpty);
    });

    test('added account can be retrieved', () async {
      await dataSource.addAccount(
        userId: '@bob:server.com',
        homeserver: 'https://server.com',
        accessToken: 'tok_bob',
        deviceId: 'dev_b',
        displayName: 'Bob',
      );

      final accounts = await dataSource.getAccounts();
      expect(accounts.keys, contains('@bob:server.com'));
      expect(accounts['@bob:server.com']!['displayName'], 'Bob');
    });

    test('getAccountCount increments per added account', () async {
      expect(await dataSource.getAccountCount(), 0);

      await dataSource.addAccount(
        userId: '@a:s.com',
        homeserver: 'https://s.com',
        accessToken: 'ta',
        deviceId: 'da',
      );
      expect(await dataSource.getAccountCount(), 1);

      await dataSource.addAccount(
        userId: '@b:s.com',
        homeserver: 'https://s.com',
        accessToken: 'tb',
        deviceId: 'db',
      );
      expect(await dataSource.getAccountCount(), 2);
    });
  });

  group('removeAccount', () {
    test('removed account is no longer in getAccounts', () async {
      await dataSource.addAccount(
        userId: '@alice:s.com',
        homeserver: 'https://s.com',
        accessToken: 'ta',
        deviceId: 'da',
      );
      await dataSource.addAccount(
        userId: '@bob:s.com',
        homeserver: 'https://s.com',
        accessToken: 'tb',
        deviceId: 'db',
      );

      await dataSource.removeAccount('@alice:s.com');

      final accounts = await dataSource.getAccounts();
      expect(accounts.keys, isNot(contains('@alice:s.com')));
      expect(accounts.keys, contains('@bob:s.com'));
    });

    test('removing the last account deletes the accounts key', () async {
      await dataSource.addAccount(
        userId: '@solo:s.com',
        homeserver: 'https://s.com',
        accessToken: 'ts',
        deviceId: 'ds',
      );
      await dataSource.removeAccount('@solo:s.com');

      expect(await dataSource.getAccounts(), isEmpty);
    });
  });

  group('room bot webhook secret', () {
    test('saves and retrieves a room webhook secret', () async {
      await dataSource.saveRoomBotWebhookSecret('!room:s.com', 'secret-value');

      final secret = await dataSource.getRoomBotWebhookSecret('!room:s.com');

      expect(secret, 'secret-value');
    });

    test('clears the room webhook secret when value is empty', () async {
      await dataSource.saveRoomBotWebhookSecret('!room:s.com', 'secret-value');
      await dataSource.saveRoomBotWebhookSecret('!room:s.com', '');

      final secret = await dataSource.getRoomBotWebhookSecret('!room:s.com');

      expect(secret, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Biometric settings
  // ─────────────────────────────────────────────────────────────────────────

  group('saveBiometricSettings / getBiometricSettings', () {
    test('isBiometricEnabled returns false when nothing stored', () async {
      expect(await dataSource.isBiometricEnabled(), isFalse);
    });

    test('isBiometricEnabled returns true after enabling', () async {
      await dataSource.enableBiometricLogin(
        homeserver: 'https://server.com',
        username: 'alice',
      );
      expect(await dataSource.isBiometricEnabled(), isTrue);
    });

    test('isBiometricEnabled returns false after disabling', () async {
      await dataSource.enableBiometricLogin(
        homeserver: 'https://server.com',
        username: 'alice',
      );
      await dataSource.disableBiometricLogin();
      expect(await dataSource.isBiometricEnabled(), isFalse);
    });

    test('getBiometricUsername returns stored username', () async {
      await dataSource.enableBiometricLogin(
        homeserver: 'https://server.com',
        username: 'alice',
      );
      expect(await dataSource.getBiometricUsername(), 'alice');
    });

    test('getBiometricHomeserver returns stored homeserver', () async {
      await dataSource.enableBiometricLogin(
        homeserver: 'https://my.server.com',
        username: 'alice',
      );
      expect(
        await dataSource.getBiometricHomeserver(),
        'https://my.server.com',
      );
    });

    test('getBiometricSettings returns null when nothing stored', () async {
      expect(await dataSource.getBiometricSettings(), isNull);
    });

    test('saveBiometricSettings stores enabled=false explicitly', () async {
      await dataSource.saveBiometricSettings(enabled: false);
      final settings = await dataSource.getBiometricSettings();
      expect(settings, isNotNull);
      expect(settings!['enabled'], false);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Generic read / write / delete
  // ─────────────────────────────────────────────────────────────────────────

  group('read / write / delete', () {
    test('write and read round-trips value', () async {
      await dataSource.write('custom_key', 'custom_value');
      final result = await dataSource.read('custom_key');
      expect(result, 'custom_value');
    });

    test('read returns null for unknown key', () async {
      final result = await dataSource.read('no_such_key');
      expect(result, isNull);
    });

    test('delete removes the key', () async {
      await dataSource.write('temp_key', 'temp_val');
      await dataSource.delete('temp_key');
      expect(await dataSource.read('temp_key'), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // clearAll
  // ─────────────────────────────────────────────────────────────────────────

  group('clearAll', () {
    test('clears all stored keys', () async {
      await dataSource.saveSession(
        homeserver: 'https://s.com',
        accessToken: 't',
        userId: '@u:s.com',
        deviceId: 'd',
      );
      await dataSource.saveCredentials(
        homeserver: 'https://s.com',
        username: 'u',
      );

      await dataSource.clearAll();

      expect(store, isEmpty);
      expect(await dataSource.getSession(), isNull);
      expect(await dataSource.getCredentials(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // isAvailable
  // ─────────────────────────────────────────────────────────────────────────

  group('isAvailable', () {
    test('returns true when storage write/delete succeed', () async {
      expect(await dataSource.isAvailable(), isTrue);
    });

    test('returns false when storage throws', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Keychain error'));
      expect(await dataSource.isAvailable(), isFalse);
    });
  });
}
