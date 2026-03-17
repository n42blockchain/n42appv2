import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/staking_btc/staking_btc_utils.dart';

void main() {
  test('parseStakingLockupSeconds converts day strings to seconds', () {
    expect(parseStakingLockupSeconds('1'), 86400);
    expect(parseStakingLockupSeconds('1.5'), 129600);
  });

  test('parseStakingLockupSeconds rejects invalid values', () {
    expect(parseStakingLockupSeconds(null), isNull);
    expect(parseStakingLockupSeconds(''), isNull);
    expect(parseStakingLockupSeconds('0'), isNull);
    expect(parseStakingLockupSeconds('abc'), isNull);
  });

  test(
    'staking redeem utxo query constants keep first-page multi-utxo fetch',
    () {
      expect(kStakingRedeemUtxoPageSize, 10);
      expect(kStakingRedeemUtxoPageNum, 1);
    },
  );
}
