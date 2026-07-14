// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;

const asset = '0x1111111111111111111111111111111111111111';
const account = '0x2222222222222222222222222222222222222222';

void main() {
  group('AaveService configuration', () {
    test('exposes the six configured Aave V3 markets', () {
      expect(AaveService.poolAddresses.keys, {1, 10, 137, 8453, 42161, 43114});
      for (final chainId in AaveService.poolAddresses.keys) {
        expect(AaveService.isAvailable(chainId), isTrue);
        expect(AaveService.getPoolAddress(chainId), startsWith('0x'));
      }
      expect(AaveService.isAvailable(56), isFalse);
    });
  });

  group('AaveService calldata builders', () {
    test('approve encodes selector and two ABI words', () {
      final data = AaveService.buildApproveCalldata(
        spender: account,
        amount: BigInt.from(7),
      );
      expect(data.length, 68);
      expect(bytesToHex(data).substring(0, 8), '095ea7b3');
      expect(bytesToHex(data).substring(32, 72), account.substring(2));
      expect(data.last, 7);
    });

    test('supply encodes selector, amount, account and referral code', () {
      final data = AaveService.buildSupplyCalldata(
        asset: asset,
        amount: BigInt.from(42),
        onBehalfOf: account,
        referralCode: 9,
      );
      final hex = bytesToHex(data);
      expect(data.length, 132);
      expect(hex.substring(0, 8), '617ba037');
      expect(data[67], 42);
      expect(data.last, 9);
    });

    test('withdraw, borrow and repay use the expected ABI shapes', () {
      final withdraw = AaveService.buildWithdrawCalldata(
        asset: asset,
        amount: BigInt.one,
        to: account,
      );
      final borrow = AaveService.buildBorrowCalldata(
        asset: asset,
        amount: BigInt.one,
        onBehalfOf: account,
      );
      final repay = AaveService.buildRepayCalldata(
        asset: asset,
        amount: BigInt.one,
        onBehalfOf: account,
      );

      expect(withdraw.length, 100);
      expect(bytesToHex(withdraw).substring(0, 8), '69328dec');
      expect(borrow.length, 164);
      expect(bytesToHex(borrow).substring(0, 8), 'a415bcad');
      expect(repay.length, 132);
      expect(bytesToHex(repay).substring(0, 8), '573ade81');
    });
  });

  test('parses official GraphQL reserve values and APY fractions', () {
    final reserve = AaveReserve.fromGraphApi({
      'underlyingToken': {
        'address': asset,
        'symbol': 'USDC',
        'name': 'USD Coin',
        'decimals': 6,
      },
      'size': {'usd': '123.45'},
      'supplyInfo': {
        'apy': {'value': '0.031'},
      },
      'borrowInfo': {
        'apy': {'value': '0.047'},
        'total': {'usd': '50'},
        'availableLiquidity': {'usd': '73.45'},
      },
    });

    expect(reserve.symbol, 'USDC');
    expect(reserve.decimals, 6);
    expect(reserve.supplyApy, 3.1);
    expect(reserve.borrowApy, 4.7);
    expect(reserve.totalLiquidityUsd, 123.45);
    expect(reserve.availableLiquidityUsd, 73.45);
  });
}
