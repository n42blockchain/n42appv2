import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/payments/domain/payment_amount.dart';
import 'package:n42_wallet/features/payments/domain/payment_asset.dart';
import 'package:n42_wallet/features/payments/domain/payment_transfer_intent.dart';

void main() {
  const contract = '0x1111111111111111111111111111111111111111';
  const recipient = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd';
  final now = DateTime.utc(2026, 9, 20, 12);

  PaymentAsset token({String network = '8453', int decimals = 6}) =>
      PaymentAsset(
        id: PaymentAssetId(
          namespace: 'eip155',
          network: network,
          contract: contract,
        ),
        symbol: 'USDC',
        decimals: decimals,
      );

  PaymentTransferIntent prepare({
    PaymentAmount? amount,
    String expectedNetwork = '8453',
    String expectedContract = contract,
    String toRecipient = recipient,
    BigInt? tokenBalance,
    BigInt? nativeFeeBalance,
    BigInt? quotedFee,
    DateTime? expiresAt,
  }) => PaymentTransferIntent.prepare(
    amount: amount ?? PaymentAmount.parse('1.25', asset: token()),
    expectedNetwork: expectedNetwork,
    expectedContract: expectedContract,
    recipient: toRecipient,
    tokenBalance: tokenBalance ?? BigInt.from(1250000),
    nativeFeeBalance: nativeFeeBalance ?? BigInt.from(100),
    quotedFee: quotedFee ?? BigInt.from(100),
    expiresAt: expiresAt ?? now.add(const Duration(minutes: 1)),
    now: now,
  );

  test('encodes exact ERC-20 transfer words with zero native call value', () {
    final intent = prepare();
    expect(intent.namespace, 'eip155');
    expect(intent.network, '8453');
    expect(intent.chainId, BigInt.from(8453));
    expect(intent.to, contract);
    expect(intent.recipient, recipient);
    expect(intent.value, BigInt.zero);
    expect(intent.amount.units, BigInt.from(1250000));
    expect(
      intent.calldata,
      '0xa9059cbb'
      '000000000000000000000000abcdefabcdefabcdefabcdefabcdefabcdefabcd'
      '00000000000000000000000000000000000000000000000000000000001312d0',
    );
    expect(intent.calldata.length, 138);
    expect(intent.quotedFee, BigInt.from(100));
    expect(intent.preparedAt, now);
    expect(intent.expiresAt, now.add(const Duration(minutes: 1)));
  });

  test('same symbol on another chain or contract is rejected', () {
    final ethereumAmount = PaymentAmount.parse(
      '1.25',
      asset: token(network: '1'),
    );
    expect(() => prepare(amount: ethereumAmount), throwsArgumentError);
    expect(
      () => prepare(
        expectedContract: '0x2222222222222222222222222222222222222222',
      ),
      throwsArgumentError,
    );
  });

  test('native and non-EVM assets cannot become ERC-20 intents', () {
    for (final id in [
      PaymentAssetId(namespace: 'eip155', network: '8453', contract: null),
      PaymentAssetId(
        namespace: 'solana',
        network: 'mainnet',
        contract: 'TestMint',
      ),
    ]) {
      final amount = PaymentAmount(
        asset: PaymentAsset(id: id, symbol: 'USDC', decimals: 6),
        units: BigInt.one,
      );
      expect(() => prepare(amount: amount), throwsArgumentError);
    }
  });

  test(
    'zero token contract is rejected even when expected identity matches',
    () {
      final zeroContract = '0x${'0' * 40}';
      final zeroAsset = PaymentAsset(
        id: PaymentAssetId(
          namespace: 'eip155',
          network: '8453',
          contract: zeroContract,
        ),
        symbol: 'USDC',
        decimals: 6,
      );
      expect(
        () => prepare(
          amount: PaymentAmount(asset: zeroAsset, units: BigInt.one),
          expectedContract: zeroContract,
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'canonical equivalent chain and address spelling produces same call',
    () {
      final intent = prepare(
        expectedNetwork: '08453',
        expectedContract: contract.toUpperCase(),
        toRecipient: recipient.toUpperCase(),
      );
      expect(intent.calldata, prepare().calldata);
      expect(intent.recipient, recipient);
      expect(intent.network, '8453');
    },
  );

  test('recipient must be exactly a nonzero 20-byte hexadecimal address', () {
    for (final invalid in [
      '',
      '0x1234',
      '0x${'0' * 40}',
      '$recipient\n',
      '$recipient ',
      '${recipient}0',
      recipient.replaceFirst('a', 'g'),
    ]) {
      expect(
        () => prepare(toRecipient: invalid),
        throwsArgumentError,
        reason: invalid,
      );
    }
  });

  test(
    'six and eighteen decimal amounts encode their own exact smallest unit',
    () {
      for (final decimals in [6, 18]) {
        final amount = PaymentAmount.parse(
          '0.${'0' * (decimals - 1)}1',
          asset: token(decimals: decimals),
        );
        final intent = prepare(amount: amount, tokenBalance: BigInt.one);
        expect(intent.calldata.substring(74), '${'0' * 63}1');
        expect(intent.amount.asset.decimals, decimals);
      }
    },
  );

  test(
    'large integer and uint256 maximum never round through floating point',
    () {
      for (final units in [
        BigInt.parse('900719925474099312345678901234567890'),
        PaymentTransferIntent.maxUint256,
      ]) {
        final intent = prepare(
          amount: PaymentAmount(asset: token(), units: units),
          tokenBalance: units,
        );
        expect(BigInt.parse(intent.calldata.substring(74), radix: 16), units);
        expect(intent.calldata.length, 138);
      }
    },
  );

  test('zero and uint256 overflow cannot be encoded as transfers', () {
    for (final units in [
      BigInt.zero,
      PaymentTransferIntent.maxUint256 + BigInt.one,
    ]) {
      expect(
        () => prepare(
          amount: PaymentAmount(asset: token(), units: units),
          tokenBalance: units,
        ),
        throwsArgumentError,
      );
    }
  });

  test(
    'balances exactly equal to amount and fee pass; one unit short fails',
    () {
      expect(prepare().amount.units, BigInt.from(1250000));
      expect(
        () => prepare(tokenBalance: BigInt.from(1249999)),
        throwsStateError,
      );
      expect(
        () => prepare(nativeFeeBalance: BigInt.from(99)),
        throwsStateError,
      );
      expect(
        prepare(
          nativeFeeBalance: BigInt.zero,
          quotedFee: BigInt.zero,
        ).quotedFee,
        BigInt.zero,
      );
    },
  );

  test('negative balance or fee snapshots are rejected', () {
    expect(() => prepare(tokenBalance: -BigInt.one), throwsArgumentError);
    expect(() => prepare(nativeFeeBalance: -BigInt.one), throwsArgumentError);
    expect(() => prepare(quotedFee: -BigInt.one), throwsArgumentError);
  });

  test('quote expires at the boundary, not after it', () {
    expect(() => prepare(expiresAt: now), throwsStateError);
    expect(
      () => prepare(expiresAt: now.subtract(const Duration(microseconds: 1))),
      throwsStateError,
    );
    expect(
      prepare(expiresAt: now.add(const Duration(microseconds: 1))).preparedAt,
      now,
    );
    final sameInstant = DateTime.parse('2026-09-20T08:00:00-04:00');
    expect(() => prepare(expiresAt: sameInstant), throwsStateError);
  });
}
