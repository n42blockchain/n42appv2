import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';

void main() {
  const address = '0x1111111111111111111111111111111111111111';
  for (final scenario in [
    'empty',
    'address',
    'negative',
    'overflow',
    'sumOverflow',
  ]) {
    test('batch encoding rejects $scenario before signing', () async {
      final max = (BigInt.one << 256) - BigInt.one;
      final items = <BatchTransferItem>[
        BatchTransferItem(
          id: '1',
          toAddress: scenario == 'address' ? '0x12' : address,
          amount: scenario == 'negative'
              ? -BigInt.one
              : scenario == 'overflow'
              ? max + BigInt.one
              : max,
        ),
        if (scenario == 'sumOverflow')
          BatchTransferItem(id: '2', toAddress: address, amount: BigInt.one),
      ];
      final result = await BatchTransferApi().buildBatchTransaction(
        chainSymbol: 'ETH',
        fromAddress: address,
        tokenAddress: null,
        items: scenario == 'empty' ? [] : items,
        gasLimit: BigInt.from(100000),
        nonce: 0,
        chainId: 1,
        gasPrice: BigInt.one,
      );
      expect(result.error, isTrue);
    });
  }
  for (final text in ['1.2345678', '1.2.3', '1e3', '+1', '-1', '1 2', '.5']) {
    test('CSV rejects ambiguous or inexact amount $text', () {
      expect(
        () => BatchTransferItem.fromCsvRow('$address,$text', 0, 6),
        throwsFormatException,
      );
    });
  }
  test('CSV accepts excess zero precision without changing value', () {
    expect(
      BatchTransferItem.fromCsvRow('$address,1.2300000', 0, 6).amount,
      BigInt.from(1230000),
    );
  });
  test('CSV preserves integers beyond double precision', () {
    expect(
      BatchTransferItem.fromCsvRow('$address,9007199254740993', 0, 0).amount,
      BigInt.parse('9007199254740993'),
    );
  });
  test('CSV accepts uint256 maximum and rejects overflow', () {
    final max = (BigInt.one << 256) - BigInt.one;
    expect(BatchTransferItem.fromCsvRow('$address,$max', 0, 0).amount, max);
    expect(
      () => BatchTransferItem.fromCsvRow('$address,${max + BigInt.one}', 0, 0),
      throwsFormatException,
    );
  });
  for (final decimals in [-1, 256]) {
    test('CSV rejects decimals $decimals', () {
      expect(
        () => BatchTransferItem.fromCsvRow('$address,1', 0, decimals),
        throwsFormatException,
      );
    });
  }
}
