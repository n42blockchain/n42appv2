import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/edit_wallet_utils.dart';

void main() {
  group('resolveEditedWalletName', () {
    test('returns trimmed user input when present', () {
      final name = resolveEditedWalletName(
        input: '  Main Wallet  ',
        existingName: 'Account1',
        walletIndex: 0,
      );

      expect(name, 'Main Wallet');
    });

    test('falls back to existing wallet name when input is blank', () {
      final name = resolveEditedWalletName(
        input: '   ',
        existingName: 'Account2',
        walletIndex: 1,
      );

      expect(name, 'Account2');
    });

    test(
      'uses indexed default when both input and existing name are blank',
      () {
        final name = resolveEditedWalletName(
          input: ' ',
          existingName: ' ',
          walletIndex: 2,
        );

        expect(name, 'Account3');
      },
    );
  });
}
