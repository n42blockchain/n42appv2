// Tests for TransferParams, GasEstimation, UnsupportedChainException,
// and TransferException in transfer_handler.dart.
// All are pure Dart data classes — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/transfer_handler.dart';

void main() {
  // ─────────────────────────────────────────────────
  // TransferParams
  // ─────────────────────────────────────────────────

  group('TransferParams constructor', () {
    test('stores required fields', () {
      const p = TransferParams(
        chainSymbol: 'ETH',
        fromAddress: '0xFrom',
        toAddress: '0xTo',
        value: 1.5,
      );
      expect(p.chainSymbol, 'ETH');
      expect(p.fromAddress, '0xFrom');
      expect(p.toAddress, '0xTo');
      expect(p.value, 1.5);
    });

    test('optional fields have correct defaults', () {
      const p = TransferParams(
        chainSymbol: 'BTC',
        fromAddress: '1A',
        toAddress: '1B',
        value: 0.001,
      );
      expect(p.contractAddress, '');
      expect(p.isTest, isFalse);
      expect(p.maxValue, isTrue);
      expect(p.message, isNull);
      expect(p.privateKey, isNull);
      expect(p.pathIndex, 0);
      expect(p.chainMap, isNull);
      expect(p.token, isNull);
    });

    test('stores all optional fields', () {
      const p = TransferParams(
        chainSymbol: 'ETH',
        fromAddress: '0xFrom',
        toAddress: '0xTo',
        value: 100.0,
        contractAddress: '0xContract',
        isTest: true,
        maxValue: false,
        message: 'hello',
        privateKey: '0xPrivKey',
        pathIndex: 3,
        chainMap: {'rpcUrl': 'https://rpc.example.com'},
        token: {'symbol': 'USDT'},
      );
      expect(p.contractAddress, '0xContract');
      expect(p.isTest, isTrue);
      expect(p.maxValue, isFalse);
      expect(p.message, 'hello');
      expect(p.privateKey, '0xPrivKey');
      expect(p.pathIndex, 3);
      expect(p.chainMap, {'rpcUrl': 'https://rpc.example.com'});
      expect(p.token, {'symbol': 'USDT'});
    });

    test('value can be zero', () {
      const p = TransferParams(
        chainSymbol: 'ETH',
        fromAddress: '0xFrom',
        toAddress: '0xTo',
        value: 0.0,
      );
      expect(p.value, 0.0);
    });
  });

  // ─────────────────────────────────────────────────
  // GasEstimation
  // ─────────────────────────────────────────────────

  group('GasEstimation', () {
    test('stores all fields', () {
      final g = GasEstimation(
        gasLimit: BigInt.from(21000),
        gasPrice: BigInt.from(1000000000),
        totalFee: BigInt.from(21000000000000),
      );
      expect(g.gasLimit, BigInt.from(21000));
      expect(g.gasPrice, BigInt.from(1000000000));
      expect(g.totalFee, BigInt.from(21000000000000));
      expect(g.errorMessage, isNull);
    });

    test('stores errorMessage when provided', () {
      final g = GasEstimation(
        gasLimit: BigInt.zero,
        gasPrice: BigInt.zero,
        totalFee: BigInt.zero,
        errorMessage: 'insufficient balance',
      );
      expect(g.errorMessage, 'insufficient balance');
    });

    test('isSuccess true when no errorMessage', () {
      final g = GasEstimation(
        gasLimit: BigInt.from(21000),
        gasPrice: BigInt.from(1),
        totalFee: BigInt.from(21000),
      );
      expect(g.isSuccess, isTrue);
    });

    test('isSuccess false when errorMessage set', () {
      final g = GasEstimation(
        gasLimit: BigInt.zero,
        gasPrice: BigInt.zero,
        totalFee: BigInt.zero,
        errorMessage: 'network error',
      );
      expect(g.isSuccess, isFalse);
    });

    test('BigInt.zero is valid for all fee fields', () {
      final g = GasEstimation(
        gasLimit: BigInt.zero,
        gasPrice: BigInt.zero,
        totalFee: BigInt.zero,
      );
      expect(g.isSuccess, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // UnsupportedChainException
  // ─────────────────────────────────────────────────

  group('UnsupportedChainException', () {
    test('stores chainSymbol', () {
      const e = UnsupportedChainException('MYCHAIN');
      expect(e.chainSymbol, 'MYCHAIN');
    });

    test('toString contains chain symbol', () {
      const e = UnsupportedChainException('MYCHAIN');
      expect(e.toString(), contains('MYCHAIN'));
    });

    test('toString has expected prefix', () {
      const e = UnsupportedChainException('XYZ');
      expect(e.toString(), 'Unsupported chain: XYZ');
    });

    test('implements Exception', () {
      const e = UnsupportedChainException('ETH');
      expect(e, isA<Exception>());
    });

    test('can be thrown and caught', () {
      expect(
        () => throw const UnsupportedChainException('UNKNOWN'),
        throwsA(
          isA<UnsupportedChainException>().having(
            (e) => e.chainSymbol,
            'chainSymbol',
            'UNKNOWN',
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // TransferException
  // ─────────────────────────────────────────────────

  group('TransferException', () {
    test('stores message', () {
      const e = TransferException('transfer failed');
      expect(e.message, 'transfer failed');
    });

    test('details defaults to null', () {
      const e = TransferException('transfer failed');
      expect(e.details, isNull);
    });

    test('stores details when provided', () {
      const e = TransferException('transfer failed', details: 'nonce too low');
      expect(e.details, 'nonce too low');
    });

    test('toString without details returns message only', () {
      const e = TransferException('transfer failed');
      expect(e.toString(), 'transfer failed');
    });

    test('toString with details includes details', () {
      const e = TransferException('transfer failed', details: 'nonce too low');
      expect(e.toString(), 'transfer failed: nonce too low');
    });

    test('implements Exception', () {
      const e = TransferException('err');
      expect(e, isA<Exception>());
    });

    test('can be thrown and caught', () {
      expect(
        () => throw const TransferException(
          'tx rejected',
          details: 'gas limit exceeded',
        ),
        throwsA(
          isA<TransferException>()
              .having((e) => e.message, 'message', 'tx rejected')
              .having((e) => e.details, 'details', 'gas limit exceeded'),
        ),
      );
    });
  });
}
