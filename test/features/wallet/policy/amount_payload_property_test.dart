import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/domain/payment_amount.dart';
import 'package:n42_wallet/features/payments/domain/payment_asset.dart';
import 'package:n42_wallet/features/wallet/policy/restricted_signer.dart';

void main() {
  test('10000 amounts preserve display, precision, asset and ABI integer', () {
    final rng = Random(20261030);
    for (var i = 0; i < 10000; i++) {
      final decimals = i % 37;
      final chain = i % 2 == 0 ? '1' : '8453';
      const token = '0x4444444444444444444444444444444444444444';
      final asset = PaymentAsset(
        id: PaymentAssetId(
          namespace: 'eip155',
          network: chain,
          contract: token,
        ),
        symbol: 'SAME',
        decimals: decimals,
      );
      final units =
          (BigInt.from(rng.nextInt(1 << 30)) << 100) + BigInt.from(i + 1);
      final amount = PaymentAmount(asset: asset, units: units);
      expect(PaymentAmount.parse(amount.format(), asset: asset).units, units);
      final tx = RestrictedTransfer(
        chainId: int.parse(chain),
        account: '0x1111111111111111111111111111111111111111',
        recipient: '0x2222222222222222222222222222222222222222',
        asset: token,
        units: units,
        nonce: BigInt.from(i),
        gasLimit: BigInt.from(60000),
        gasPrice: BigInt.one,
      );
      expect(
        BigInt.parse(tx.data.substring(tx.data.length - 64), radix: 16),
        units,
      );
      expect(tx.payload['chainId'], int.parse(chain));
      expect(tx.payload['to'], asset.id.contract);
    }
  });
  test('rejects a mixed-case address with invalid checksum', () {
    expect(
      () => RestrictedTransfer(
        chainId: 1,
        account: '0x1111111111111111111111111111111111111111',
        recipient: '0x52908400098527886E0F7030069857D2E4169Ee7',
        asset: 'native',
        units: BigInt.one,
        nonce: BigInt.zero,
        gasLimit: BigInt.from(21000),
        gasPrice: BigInt.one,
      ),
      throwsArgumentError,
    );
  });
}
