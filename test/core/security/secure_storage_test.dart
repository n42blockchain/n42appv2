import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SecureStorage storage;
  setUp(() {
    // Test the real service through the plugin's in-memory platform adapter.
    // Device encryption and keychain accessibility need integration tests.
    FlutterSecureStorage.setMockInitialValues({});
    storage = SecureStorage();
  });

  test('authentication requires both nonempty token and UUID', () async {
    expect(await storage.hasCredentials(), isFalse);
    await storage.saveToken('fixture-token');
    expect(await storage.hasCredentials(), isFalse);
    await storage.saveUuid('alice');
    expect(await storage.hasCredentials(), isTrue);
    expect(await storage.getToken(), 'fixture-token');
    expect(await storage.getUuid(), 'alice');
    await storage.saveToken('');
    expect(await storage.hasCredentials(), isFalse);
    await storage.saveToken('fixture-token');
    await storage.saveUuid('');
    expect(await storage.hasCredentials(), isFalse);
    await storage.deleteToken();
    await storage.deleteUuid();
    expect(await storage.getToken(), isNull);
    expect(await storage.getUuid(), isNull);
  });

  test('profile JSON preserves Unicode and absent data returns null', () async {
    expect(await storage.getUserInfo(), isNull);
    final user = {
      'uuid': 'alice',
      'name': '测试🔑',
      'nested': {'active': true},
    };
    await storage.saveEmail('alice@example.test');
    await storage.saveUserInfo(user);
    expect(await storage.getEmail(), 'alice@example.test');
    expect(await storage.getUserInfo(), user);
  });

  test('corrupt or incorrectly typed JSON cannot become credentials', () async {
    for (final invalid in ['{broken', '[]', '123', '"text"']) {
      FlutterSecureStorage.setMockInitialValues({
        'user_info': invalid,
        'wallet_A': invalid,
      });
      expect(await storage.getUserInfo(), isNull);
      expect(await storage.getWalletCredentials('A'), isNull);
    }
  });

  test(
    'wallet credentials, mnemonics and keys are isolated by ID/address',
    () async {
      expect(await storage.getWalletCredentials('A'), isNull);
      for (final address in ['A', 'a']) {
        await storage.saveWalletCredentials(
          address: address,
          credentials: {'address': address, 'index': 7},
        );
        await storage.saveMnemonic(
          walletId: address,
          mnemonic: 'fixture-mnemonic-$address',
        );
        await storage.savePrivateKey(
          address: address,
          privateKey: 'fixture-key-$address',
        );
      }
      await storage.deleteWalletCredentials('A');
      await storage.deleteMnemonic('A');
      await storage.deletePrivateKey('A');
      expect(await storage.getWalletCredentials('A'), isNull);
      expect(await storage.getMnemonic('A'), isNull);
      expect(await storage.getPrivateKey('A'), isNull);
      expect(await storage.getWalletCredentials('a'), {
        'address': 'a',
        'index': 7,
      });
      expect(await storage.getMnemonic('a'), 'fixture-mnemonic-a');
      expect(await storage.getPrivateKey('a'), 'fixture-key-a');
    },
  );

  test(
    'security toggles default off and persist enable and disable transitions',
    () async {
      expect(await storage.isBiometricEnabled(), isFalse);
      expect(await storage.isPasskeyEnabled(), isFalse);
      for (final enabled in [true, false]) {
        await storage.setBiometricEnabled(enabled);
        await storage.setPasskeyEnabled(enabled);
        expect(await storage.isBiometricEnabled(), enabled);
        expect(await storage.isPasskeyEnabled(), enabled);
      }
      await storage.savePasskeyCredentials('[{"id":"fixture"}]');
      expect(await storage.getPasskeyCredentials(), '[{"id":"fixture"}]');
      await storage.deletePasskeyCredentials();
      expect(await storage.getPasskeyCredentials(), isNull);
    },
  );

  test('identity token removal preserves another DID token', () async {
    await storage.saveIdHubToken('did:n42:alice', '{"token":"a"}');
    await storage.saveIdHubToken('did:n42:bob', '{"token":"b"}');
    expect(await storage.getIdHubToken('did:n42:alice'), '{"token":"a"}');
    await storage.deleteIdHubToken('did:n42:alice');
    expect(await storage.getIdHubToken('did:n42:alice'), isNull);
    expect(await storage.getIdHubToken('did:n42:bob'), '{"token":"b"}');
  });

  test(
    'logout deletes all user secrets and settings but preserves device identity',
    () async {
      await storage.saveDeviceId('fixture-device');
      await storage.saveToken('fixture-token');
      await storage.saveUuid('alice');
      await storage.saveEmail('alice@example.test');
      await storage.saveUserInfo({'uuid': 'alice'});
      await storage.setBiometricEnabled(true);
      await storage.setPasskeyEnabled(true);
      await storage.savePasskeyCredentials('[{"id":"fixture"}]');
      for (final wallet in ['A', 'B']) {
        await storage.saveWalletCredentials(
          address: wallet,
          credentials: {'id': wallet},
        );
        await storage.saveMnemonic(
          walletId: wallet,
          mnemonic: 'fixture-mnemonic',
        );
        await storage.savePrivateKey(
          address: wallet,
          privateKey: 'fixture-private-key',
        );
        await storage.saveIdHubToken('did:n42:$wallet', '{"token":"fixture"}');
      }
      await storage.clearUserData();
      expect(await storage.getDeviceId(), 'fixture-device');
      expect(await storage.hasCredentials(), isFalse);
      expect(await storage.getEmail(), isNull);
      expect(await storage.getUserInfo(), isNull);
      expect(await storage.getPasskeyCredentials(), isNull);
      expect(await storage.isPasskeyEnabled(), isFalse);
      expect(await storage.isBiometricEnabled(), isFalse);
      for (final wallet in ['A', 'B']) {
        expect(await storage.getWalletCredentials(wallet), isNull);
        expect(await storage.getMnemonic(wallet), isNull);
        expect(await storage.getPrivateKey(wallet), isNull);
        expect(await storage.getIdHubToken('did:n42:$wallet'), isNull);
      }
      await storage.clearUserData();
      expect(await storage.getDeviceId(), 'fixture-device');
    },
  );

  test('full reset also deletes device identity', () async {
    await storage.saveDeviceId('fixture-device');
    await storage.saveToken('fixture-token');
    await storage.clearAll();
    expect(await storage.getDeviceId(), isNull);
    expect(await storage.getToken(), isNull);
  });

  test(
    'sensitive byte wrapper wipes retained bytes and rejects disposed access',
    () {
      final bytes = Uint8List.fromList([7, 8, 9]);
      final wrapped = SecureStorage.wrapSensitive(bytes);
      expect(wrapped.value, same(bytes));
      expect(wrapped.isDisposed, isFalse);
      wrapped.dispose();
      expect(bytes, [0, 0, 0]);
      expect(wrapped.isDisposed, isTrue);
      expect(() => wrapped.value, throwsStateError);
      wrapped.dispose();
    },
  );

  test('sensitive list and text wrappers clear references and block reuse', () {
    final list = [1, 2];
    final wrapped = SensitiveData(list);
    wrapped.dispose();
    expect(list, [0, 0]);
    final text = SensitiveData('fixture-password');
    expect(text.value, 'fixture-password');
    text.dispose();
    expect(() => text.value, throwsStateError);
  });
}
