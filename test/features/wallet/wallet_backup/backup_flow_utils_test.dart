import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';

void main() {
  group('parseBackupMnemonicWords', () {
    test('trims and filters empty words', () {
      expect(parseBackupMnemonicWords('  alpha   beta\n gamma  '), [
        'alpha',
        'beta',
        'gamma',
      ]);
    });

    test('returns empty list for null mnemonic', () {
      expect(parseBackupMnemonicWords(null), isEmpty);
    });
  });

  test(
    'walletHasBackupableMnemonic only returns true for real mnemonic words',
    () {
      expect(
        walletHasBackupableMnemonic(WalletInfo(mnemonic: 'one two three')),
        isTrue,
      );
      expect(walletHasBackupableMnemonic(WalletInfo(mnemonic: '   ')), isFalse);
    },
  );
}
