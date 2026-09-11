import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_explorer.dart';

void main() {
  test('account explorer uses the smart account network', () {
    const address = '0x1111111111111111111111111111111111111111';
    expect(
      aaAccountExplorer(1, address),
      contains('etherscan.io/address/$address'),
    );
    expect(aaAccountExplorer(11155111, address), contains('sepolia'));
    expect(aaAccountExplorer(8453, address), contains('basescan.org'));
    expect(aaAccountExplorer(999999999, address), isEmpty);
  });
}
