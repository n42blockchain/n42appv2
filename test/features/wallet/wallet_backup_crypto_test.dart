import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/wallet_backup_crypto.dart';

void main() {
  Map<String, dynamic> envelope() => {
    'app': 'N42Wallet',
    'version': 1,
    'kdf': 'pbkdf2-sha256',
    'iterations': 600000,
    'salt': base64Encode(List.filled(16, 0)),
    'iv': base64Encode(List.filled(16, 0)),
    'mac': base64Encode(List.filled(32, 0)),
    'data': base64Encode(List.filled(16, 0)),
  };

  for (final entry in <String, Object?>{
    'salt': 'not base64!',
    'iv': 12,
    'mac': null,
    'iterations': '600000',
  }.entries) {
    test('reports malformed ${entry.key} as a backup error', () async {
      final input = envelope()..[entry.key] = entry.value;
      await expectLater(
        WalletBackupCrypto.decrypt(jsonEncode(input), 'synthetic'),
        throwsA(isA<WalletBackupException>()),
      );
    });
  }
  for (final rounds in [-1, 0, WalletBackupCrypto.maxImportIterations + 1]) {
    test(
      'rejects unsupported derivation cost $rounds before deriving',
      () async {
        await expectLater(
          WalletBackupCrypto.decrypt(
            jsonEncode(envelope()..['iterations'] = rounds),
            'synthetic',
          ),
          throwsA(isA<WalletBackupException>()),
        );
      },
    );
  }
  for (final field in ['version', 'kdf']) {
    test('rejects unknown $field', () async {
      await expectLater(
        WalletBackupCrypto.decrypt(
          jsonEncode(envelope()..[field] = 'unknown'),
          'synthetic',
        ),
        throwsA(isA<WalletBackupException>()),
      );
    });
  }
  test('rejects oversized input before JSON parsing', () async {
    await expectLater(
      WalletBackupCrypto.decrypt(
        ' ' * (WalletBackupCrypto.maxBackupCharacters + 1),
        'synthetic',
      ),
      throwsA(isA<WalletBackupException>()),
    );
  });
  test(
    'current exports and legacy unlabeled envelopes still restore',
    () async {
      final wallets = <Map<String, dynamic>>[
        {
          'walletName': 'Synthetic recovery',
          'mnemonic': 'synthetic fixture only',
        },
      ];
      final exported = await WalletBackupCrypto.encrypt(
        wallets,
        'synthetic-password',
      );
      expect(
        await WalletBackupCrypto.decrypt(exported, 'synthetic-password'),
        wallets,
      );
      final legacy = jsonDecode(exported) as Map<String, dynamic>;
      legacy.remove('version');
      legacy.remove('kdf');
      expect(
        await WalletBackupCrypto.decrypt(
          jsonEncode(legacy),
          'synthetic-password',
        ),
        wallets,
      );
      await expectLater(
        WalletBackupCrypto.decrypt(exported, 'wrong-password'),
        throwsA(isA<WalletBackupException>()),
      );
    },
  );
}
