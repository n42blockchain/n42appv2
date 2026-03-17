import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage_flags_utils.dart';

void main() {
  test('walletHasUserPassword ignores watch-only sentinel passwords', () {
    final watchWallet = WalletInfo(password: '0')..watchOnly = true;
    final regularWallet = WalletInfo(password: 'secure-pass');

    expect(walletHasUserPassword(watchWallet), isFalse);
    expect(walletHasUserPassword(regularWallet), isTrue);
  });

  test(
    'walletCanBackupFromManage only applies to regular passwordless wallets',
    () {
      expect(walletCanBackupFromManage(WalletInfo(password: '')), isTrue);

      final watchWallet = WalletInfo(password: '0')..watchOnly = true;
      expect(walletCanBackupFromManage(watchWallet), isFalse);

      expect(
        walletCanBackupFromManage(WalletInfo(password: 'abc12345')),
        isFalse,
      );
    },
  );
}
