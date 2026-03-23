import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/watch_wallet_utils.dart';

void main() {
  group('isValidWatchWalletAddress', () {
    test('accepts valid hex EVM addresses only', () {
      expect(
        isValidWatchWalletAddress('0x1234567890abcdef1234567890ABCDEF12345678'),
        isTrue,
      );
      expect(
        isValidWatchWalletAddress('0xzz34567890abcdef1234567890ABCDEF12345678'),
        isFalse,
      );
      expect(isValidWatchWalletAddress('0x1234'), isFalse);
    });
  });

  test(
    'findExistingWatchWallet matches normalized addresses only for watch wallets',
    () {
      final watchWallet = WalletInfo(walletName: 'Watch 1')
        ..watchOnly = true
        ..watchAddress = '0x1234567890ABCDEF1234567890ABCDEF12345678';
      final regularWallet = WalletInfo(walletName: 'Regular')
        ..watchOnly = false
        ..watchAddress = '0x1234567890abcdef1234567890abcdef12345678';

      expect(
        findExistingWatchWallet([
          watchWallet,
          regularWallet,
        ], ' 0x1234567890abcdef1234567890abcdef12345678 '),
        same(watchWallet),
      );
      expect(
        findExistingWatchWallet([
          regularWallet,
        ], '0x1234567890abcdef1234567890abcdef12345678'),
        isNull,
      );
    },
  );
}
