// Tests for wallet_entity.dart — pure Equatable entity classes and enums.
// Covers: TransactionStatus, ChainType enums; WalletEntity (shortAddress,
// copyWith, equality); AssetEntity (formattedBalance, valueUsd);
// TransactionEntity.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // TransactionStatus enum
  // ─────────────────────────────────────────────────

  group('TransactionStatus enum', () {
    test('has pending, confirmed, failed values', () {
      expect(TransactionStatus.values, containsAll([
        TransactionStatus.pending,
        TransactionStatus.confirmed,
        TransactionStatus.failed,
      ]));
    });

    test('three values total', () {
      expect(TransactionStatus.values.length, 3);
    });
  });

  // ─────────────────────────────────────────────────
  // ChainType enum
  // ─────────────────────────────────────────────────

  group('ChainType enum', () {
    test('contains all 13 expected values', () {
      expect(ChainType.values, containsAll([
        ChainType.ethereum,
        ChainType.bitcoin,
        ChainType.solana,
        ChainType.tron,
        ChainType.filecoin,
        ChainType.polkadot,
        ChainType.algorand,
        ChainType.aptos,
        ChainType.sui,
        ChainType.cosmos,
        ChainType.ripple,
        ChainType.tezos,
        ChainType.ton,
      ]));
    });

    test('13 values total', () {
      expect(ChainType.values.length, 13);
    });
  });

  // ─────────────────────────────────────────────────
  // WalletEntity
  // ─────────────────────────────────────────────────

  final created = DateTime.utc(2024, 1, 1);

  group('WalletEntity constructor', () {
    test('stores required fields', () {
      final e = WalletEntity(
        id: 'w1',
        name: 'My Wallet',
        address: '0xAbcDef1234567890',
        chainType: 'ethereum',
        createdAt: created,
      );
      expect(e.id, 'w1');
      expect(e.name, 'My Wallet');
      expect(e.address, '0xAbcDef1234567890');
      expect(e.chainType, 'ethereum');
      expect(e.createdAt, created);
    });

    test('isHD defaults to true', () {
      final e = WalletEntity(
          id: 'w', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
      expect(e.isHD, isTrue);
    });

    test('isWatchOnly defaults to false', () {
      final e = WalletEntity(
          id: 'w', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
      expect(e.isWatchOnly, isFalse);
    });

    test('derivationPath defaults to null', () {
      final e = WalletEntity(
          id: 'w', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
      expect(e.derivationPath, isNull);
    });

    test('index defaults to null', () {
      final e = WalletEntity(
          id: 'w', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
      expect(e.index, isNull);
    });

    test('coinMiniName defaults to null', () {
      final e = WalletEntity(
          id: 'w', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
      expect(e.coinMiniName, isNull);
    });

    test('stores optional fields when provided', () {
      final e = WalletEntity(
        id: 'w',
        name: 'N',
        address: '0x',
        chainType: 'eth',
        createdAt: created,
        isHD: false,
        derivationPath: "m/44'/60'/0'/0/1",
        isWatchOnly: true,
        index: 2,
        coinMiniName: 'ETH',
      );
      expect(e.isHD, isFalse);
      expect(e.derivationPath, "m/44'/60'/0'/0/1");
      expect(e.isWatchOnly, isTrue);
      expect(e.index, 2);
      expect(e.coinMiniName, 'ETH');
    });
  });

  group('WalletEntity.shortAddress', () {
    test('shows first 6 and last 4 chars for long address', () {
      final e = WalletEntity(
        id: 'w', name: 'N',
        address: '0xAbcDef1234567890ABCDEF',
        chainType: 'eth', createdAt: created,
      );
      final short = e.shortAddress;
      expect(short, startsWith('0xAbcD'));
      expect(short, endsWith('CDEF'));
      expect(short, contains('...'));
    });

    test('returns full address when length <= 10', () {
      final e = WalletEntity(
        id: 'w', name: 'N', address: '0x1234', chainType: 'eth', createdAt: created,
      );
      expect(e.shortAddress, '0x1234');
    });

    test('exactly 10 chars returns full address', () {
      final e = WalletEntity(
        id: 'w', name: 'N', address: '0123456789', chainType: 'eth', createdAt: created,
      );
      expect(e.shortAddress, '0123456789');
    });

    test('11 chars (one over threshold) uses truncated form', () {
      // Boundary: 10 → full, 11 → first 6 + '...' + last 4.
      final e = WalletEntity(
        id: 'w', name: 'N', address: '01234567890', chainType: 'eth', createdAt: created,
      );
      expect(e.shortAddress, contains('...'));
    });
  });

  group('WalletEntity.copyWith', () {
    final base = WalletEntity(
      id: 'w1', name: 'Wallet A', address: '0xABC',
      chainType: 'ethereum', createdAt: created,
    );

    test('copies without change when no args', () {
      final copy = base.copyWith();
      expect(copy.id, 'w1');
      expect(copy.name, 'Wallet A');
    });

    test('replaces name', () {
      expect(base.copyWith(name: 'New Name').name, 'New Name');
    });

    test('replaces address', () {
      expect(base.copyWith(address: '0xNEW').address, '0xNEW');
    });

    test('replaces isWatchOnly', () {
      expect(base.copyWith(isWatchOnly: true).isWatchOnly, isTrue);
    });

    test('replaces coinMiniName', () {
      expect(base.copyWith(coinMiniName: 'ETH').coinMiniName, 'ETH');
    });

    test('original unchanged after copyWith', () {
      base.copyWith(name: 'Changed');
      expect(base.name, 'Wallet A');
    });
  });

  group('WalletEntity equality', () {
    final a = WalletEntity(
      id: 'w1', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
    final b = WalletEntity(
      id: 'w1', name: 'N', address: '0x', chainType: 'eth', createdAt: created);
    final c = WalletEntity(
      id: 'w2', name: 'N', address: '0x', chainType: 'eth', createdAt: created);

    test('same fields → equal', () {
      expect(a, equals(b));
    });

    test('different id → not equal', () {
      expect(a, isNot(equals(c)));
    });
  });

  // ─────────────────────────────────────────────────
  // AssetEntity
  // ─────────────────────────────────────────────────

  group('AssetEntity constructor', () {
    // BigInt.zero is not const — use final variables instead of const.
    test('stores required fields', () {
      final e = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.zero,
        decimals: 18,
        chainType: 'ethereum',
      );
      expect(e.symbol, 'ETH');
      expect(e.name, 'Ethereum');
      expect(e.balance, BigInt.zero);
      expect(e.decimals, 18);
      expect(e.chainType, 'ethereum');
    });

    test('isNative defaults to false', () {
      final e = AssetEntity(
        symbol: 'TK', name: 'Token', balance: BigInt.zero,
        decimals: 18, chainType: 'eth',
      );
      expect(e.isNative, isFalse);
    });

    test('priceUsd defaults to null', () {
      final e = AssetEntity(
        symbol: 'TK', name: 'Token', balance: BigInt.zero,
        decimals: 18, chainType: 'eth',
      );
      expect(e.priceUsd, isNull);
    });

    test('contractAddress defaults to null', () {
      final e = AssetEntity(
        symbol: 'TK', name: 'Token', balance: BigInt.zero,
        decimals: 18, chainType: 'eth',
      );
      expect(e.contractAddress, isNull);
    });
  });

  group('AssetEntity.formattedBalance', () {
    test('returns "0" for zero balance', () {
      final e = AssetEntity(
        symbol: 'ETH', name: 'Ethereum', balance: BigInt.zero,
        decimals: 18, chainType: 'ethereum',
      );
      expect(e.formattedBalance, '0');
    });

    test('returns whole number when no fraction', () {
      // 1 ETH = 10^18 wei
      final e = AssetEntity(
        symbol: 'ETH', name: 'Ethereum',
        balance: BigInt.from(10).pow(18),
        decimals: 18, chainType: 'ethereum',
      );
      expect(e.formattedBalance, '1');
    });

    test('returns decimal string with trimmed trailing zeros', () {
      // 1.5 ETH = 1.5 * 10^18 wei
      final e = AssetEntity(
        symbol: 'ETH', name: 'Ethereum',
        balance: BigInt.from(15) * BigInt.from(10).pow(17),
        decimals: 18, chainType: 'ethereum',
      );
      expect(e.formattedBalance, '1.5');
    });

    test('returns decimal for USDT with 6 decimals', () {
      // 100.5 USDT = 100500000 (6 decimals)
      final e = AssetEntity(
        symbol: 'USDT', name: 'Tether',
        balance: BigInt.from(100500000),
        decimals: 6, chainType: 'ethereum',
      );
      expect(e.formattedBalance, '100.5');
    });
  });

  group('AssetEntity.valueUsd', () {
    test('returns null when priceUsd is null', () {
      final e = AssetEntity(
        symbol: 'TK', name: 'Token', balance: BigInt.zero,
        decimals: 18, chainType: 'eth',
      );
      expect(e.valueUsd, isNull);
    });

    test('returns 0.0 for zero balance even with price', () {
      final e = AssetEntity(
        symbol: 'ETH', name: 'Ethereum', balance: BigInt.zero,
        decimals: 18, chainType: 'ethereum', priceUsd: 3000.0,
      );
      expect(e.valueUsd, closeTo(0.0, 0.001));
    });

    test('calculates value = balance/decimals * priceUsd', () {
      // 2 ETH @ $3000 = $6000
      final e = AssetEntity(
        symbol: 'ETH', name: 'Ethereum',
        balance: BigInt.from(2) * BigInt.from(10).pow(18),
        decimals: 18, chainType: 'ethereum', priceUsd: 3000.0,
      );
      expect(e.valueUsd, closeTo(6000.0, 0.01));
    });
  });

  group('AssetEntity equality', () {
    test('same fields → equal', () {
      final a = AssetEntity(
        symbol: 'ETH', name: 'Ethereum', balance: BigInt.zero,
        decimals: 18, chainType: 'ethereum',
      );
      final b = AssetEntity(
        symbol: 'ETH', name: 'Ethereum', balance: BigInt.zero,
        decimals: 18, chainType: 'ethereum',
      );
      expect(a, equals(b));
    });

    test('different symbol → not equal', () {
      final a = AssetEntity(
        symbol: 'ETH', name: 'Ethereum', balance: BigInt.zero,
        decimals: 18, chainType: 'ethereum',
      );
      final b = AssetEntity(
        symbol: 'BTC', name: 'Ethereum', balance: BigInt.zero,
        decimals: 18, chainType: 'ethereum',
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // TransactionEntity
  // ─────────────────────────────────────────────────

  group('TransactionEntity', () {
    final ts = DateTime.utc(2024, 6, 1);

    test('stores all required fields', () {
      final e = TransactionEntity(
        hash: '0xTXHASH',
        from: '0xSENDER',
        to: '0xRECEIVER',
        value: BigInt.from(1000000000),
        timestamp: ts,
        status: TransactionStatus.confirmed,
      );
      expect(e.hash, '0xTXHASH');
      expect(e.from, '0xSENDER');
      expect(e.to, '0xRECEIVER');
      expect(e.value, BigInt.from(1000000000));
      expect(e.timestamp, ts);
      expect(e.status, TransactionStatus.confirmed);
    });

    test('errorMessage defaults to null', () {
      final e = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      expect(e.errorMessage, isNull);
    });

    test('gasUsed defaults to null', () {
      final e = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      expect(e.gasUsed, isNull);
    });

    test('stores errorMessage when provided', () {
      final e = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.failed,
        errorMessage: 'Out of gas',
      );
      expect(e.errorMessage, 'Out of gas');
    });

    test('same fields → equal', () {
      final a = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      final b = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      expect(a, equals(b));
    });

    test('different hash → not equal', () {
      final a = TransactionEntity(
        hash: 'h1', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      final b = TransactionEntity(
        hash: 'h2', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      expect(a, isNot(equals(b)));
    });

    test('different status → not equal', () {
      final a = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.pending,
      );
      final b = TransactionEntity(
        hash: 'h', from: 'f', to: 't', value: BigInt.zero,
        timestamp: ts, status: TransactionStatus.confirmed,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
