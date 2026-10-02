import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/data_encryption.dart';

void main() {
  const secret = <String, dynamic>{
    'validator': {
      'publicKey': 'validator-public',
      'privateKey': 'validator-secret',
    },
    'mnemonicWords': 'alpha beta gamma',
  };

  test('encrypted validator data round-trips only with its password', () async {
    final encrypted = await encryptSecret(data: secret, password: '12345678');
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>;

    expect(envelope['version'], '1');
    expect((envelope['kdf'] as Map)['name'], 'pbkdf2');
    expect((envelope['cipher'] as Map)['name'], 'aes-256-gcm');
    expect(
      await decryptSecret(encryptedData: encrypted, password: '12345678'),
      secret,
    );
    await expectLater(
      decryptSecret(encryptedData: encrypted, password: '87654321'),
      throwsA(isA<Exception>()),
    );
  });

  test('encryption rejects missing secrets and passwords before KDF work', () {
    expect(
      () => encryptSecret(data: const {}, password: '12345678'),
      throwsArgumentError,
    );
    expect(
      () => encryptSecret(data: secret, password: ''),
      throwsArgumentError,
    );
  });

  test('decryption rejects empty input and unsupported envelope versions', () {
    expect(
      () => decryptSecret(encryptedData: '', password: '12345678'),
      throwsArgumentError,
    );
    expect(
      () =>
          decryptSecret(encryptedData: '{"version":"2"}', password: '12345678'),
      throwsArgumentError,
    );
  });
}
