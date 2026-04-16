// Tests for wallet_bridge.dart — pure Dart value objects and MockWalletBridge.
// Covers: TransferResult (factory ctors, fields), PaymentRequest (isExpired,
// formattedAmount), TokenInfo (defaults), WalletUserInfo (displayName),
// MockWalletBridge (sync logic: isValidAddress, isWalletConnected, walletAddress).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/integration/wallet_bridge.dart';
import '../../mocks/mock_wallet_bridge.dart';

void main() {
  // ─────────────────────────────────────────────────
  // TransferResult
  // ─────────────────────────────────────────────────

  group('TransferResult constructor', () {
    test('stores success=true and transactionHash', () {
      const r = TransferResult(success: true, transactionHash: '0xABC');
      expect(r.success, isTrue);
      expect(r.transactionHash, '0xABC');
    });

    test('errorMessage defaults to null', () {
      expect(const TransferResult(success: true).errorMessage, isNull);
    });

    test('errorCode defaults to null', () {
      expect(const TransferResult(success: false).errorCode, isNull);
    });

    test('stores all optional fields', () {
      const r = TransferResult(
        success: false,
        errorMessage: 'Insufficient funds',
        errorCode: 'E001',
      );
      expect(r.errorMessage, 'Insufficient funds');
      expect(r.errorCode, 'E001');
    });
  });

  group('TransferResult.success factory', () {
    test('creates result with success=true', () {
      final r = TransferResult.success('0xDEADBEEF');
      expect(r.success, isTrue);
    });

    test('stores the transaction hash', () {
      final r = TransferResult.success('0xDEADBEEF');
      expect(r.transactionHash, '0xDEADBEEF');
    });

    test('errorMessage is null', () {
      expect(TransferResult.success('0x1').errorMessage, isNull);
    });
  });

  group('TransferResult.failure factory', () {
    test('creates result with success=false', () {
      final r = TransferResult.failure('Network error');
      expect(r.success, isFalse);
    });

    test('stores error message', () {
      final r = TransferResult.failure('Network error');
      expect(r.errorMessage, 'Network error');
    });

    test('transactionHash is null', () {
      expect(TransferResult.failure('err').transactionHash, isNull);
    });

    test('stores optional error code', () {
      final r = TransferResult.failure('err', code: 'NET_ERR');
      expect(r.errorCode, 'NET_ERR');
    });

    test('errorCode is null when not provided', () {
      expect(TransferResult.failure('err').errorCode, isNull);
    });
  });

  group('TransferResult.cancelled factory', () {
    test('success is false', () {
      expect(TransferResult.cancelled().success, isFalse);
    });

    test('errorMessage is User cancelled', () {
      expect(TransferResult.cancelled().errorMessage, 'User cancelled');
    });

    test('errorCode is CANCELLED', () {
      expect(TransferResult.cancelled().errorCode, 'CANCELLED');
    });
  });

  // ─────────────────────────────────────────────────
  // PaymentRequest
  // ─────────────────────────────────────────────────

  // Fixed test date — avoids wall-clock dependency in all PaymentRequest tests.
  final _created = DateTime.utc(2024, 1, 1);

  group('PaymentRequest constructor', () {
    final created = _created;

    test('stores required fields', () {
      final r = PaymentRequest(
        requestId: 'req1',
        amount: '1.5',
        token: 'ETH',
        receiverAddress: '0xABC',
        qrCodeData: 'n42://pay?...',
        createdAt: created,
      );
      expect(r.requestId, 'req1');
      expect(r.amount, '1.5');
      expect(r.token, 'ETH');
      expect(r.receiverAddress, '0xABC');
      expect(r.qrCodeData, 'n42://pay?...');
      expect(r.createdAt, created);
    });

    test('memo defaults to null', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '1', token: 'ETH',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
      );
      expect(r.memo, isNull);
    });

    test('expiresAt defaults to null', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '1', token: 'ETH',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
      );
      expect(r.expiresAt, isNull);
    });
  });

  group('PaymentRequest.isExpired', () {
    test('returns false when expiresAt is null', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '1', token: 'ETH',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
      );
      expect(r.isExpired, isFalse);
    });

    test('returns false when expiresAt is far in the future', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '1', token: 'ETH',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
        expiresAt: DateTime.utc(2100, 1, 1), // deterministic far-future
      );
      expect(r.isExpired, isFalse);
    });

    test('returns true when expiresAt is in the past', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '1', token: 'ETH',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
        expiresAt: DateTime.utc(2000, 1, 1), // deterministic past date
      );
      expect(r.isExpired, isTrue);
    });
  });

  group('PaymentRequest.formattedAmount', () {
    test('returns "amount token" string', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '2.5', token: 'USDT',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
      );
      expect(r.formattedAmount, '2.5 USDT');
    });

    test('different token appears in formatted string', () {
      final r = PaymentRequest(
        requestId: 'r', amount: '1', token: 'ETH',
        receiverAddress: '0x', qrCodeData: 'qr',
        createdAt: _created,
      );
      expect(r.formattedAmount, '1 ETH');
    });
  });

  // ─────────────────────────────────────────────────
  // TokenInfo
  // ─────────────────────────────────────────────────

  group('TokenInfo constructor', () {
    test('stores required fields', () {
      const t = TokenInfo(symbol: 'ETH', name: 'Ethereum', decimals: 18);
      expect(t.symbol, 'ETH');
      expect(t.name, 'Ethereum');
      expect(t.decimals, 18);
    });

    test('isNative defaults to false', () {
      expect(const TokenInfo(symbol: 'USDT', name: 'Tether', decimals: 6).isNative, isFalse);
    });

    test('contractAddress defaults to null', () {
      expect(
        const TokenInfo(symbol: 'ETH', name: 'Ethereum', decimals: 18).contractAddress,
        isNull,
      );
    });

    test('iconUrl defaults to null', () {
      expect(
        const TokenInfo(symbol: 'ETH', name: 'Ethereum', decimals: 18).iconUrl,
        isNull,
      );
    });

    test('stores isNative=true', () {
      const t = TokenInfo(symbol: 'ETH', name: 'Ethereum', decimals: 18, isNative: true);
      expect(t.isNative, isTrue);
    });

    test('stores contractAddress', () {
      const t = TokenInfo(
        symbol: 'USDT', name: 'Tether', decimals: 6,
        contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
      );
      expect(t.contractAddress, '0xdac17f958d2ee523a2206206994597c13d831ec7');
    });
  });

  // ─────────────────────────────────────────────────
  // WalletUserInfo
  // ─────────────────────────────────────────────────

  group('WalletUserInfo constructor', () {
    test('stores address', () {
      expect(
        const WalletUserInfo(address: '0xABC').address, '0xABC',
      );
    });

    test('username defaults to null', () {
      expect(const WalletUserInfo(address: '0x').username, isNull);
    });

    test('avatarUrl defaults to null', () {
      expect(const WalletUserInfo(address: '0x').avatarUrl, isNull);
    });

    test('matrixUserId defaults to null', () {
      expect(const WalletUserInfo(address: '0x').matrixUserId, isNull);
    });
  });

  group('WalletUserInfo.displayName', () {
    test('returns username when non-empty', () {
      const u = WalletUserInfo(address: '0xABC123', username: 'Alice');
      expect(u.displayName, 'Alice');
    });

    test('returns shortened address when username is null', () {
      const u = WalletUserInfo(address: '0xAbCdEf1234567890ABCD');
      final dn = u.displayName;
      expect(dn, startsWith('0xAbCd'));
      expect(dn, endsWith('ABCD'));
      expect(dn, contains('...'));
    });

    test('returns full address when address is short (<= 10 chars)', () {
      const u = WalletUserInfo(address: '0x123456');
      expect(u.displayName, '0x123456');
    });

    test('exactly 10 chars returns full address', () {
      const u = WalletUserInfo(address: '0123456789');
      expect(u.displayName, '0123456789');
    });

    test('returns username even if address is long (username takes priority)', () {
      const u = WalletUserInfo(
        address: '0xAbCdEf1234567890ABCDEF',
        username: 'Bob',
      );
      expect(u.displayName, 'Bob');
    });

    test('falls back to shortened address when username is empty string', () {
      // username != null but username.isEmpty → should use address fallback
      const u = WalletUserInfo(
        address: '0xAbCdEf1234567890ABCD',
        username: '',
      );
      final dn = u.displayName;
      expect(dn, isNot(''));
      // Should be the shortened address, not the empty username
      expect(dn, contains('...'));
    });
  });

  // ─────────────────────────────────────────────────
  // MockWalletBridge
  // ─────────────────────────────────────────────────

  group('MockWalletBridge', () {
    final mock = MockWalletBridge();

    test('isWalletConnected returns true', () {
      expect(mock.isWalletConnected, isTrue);
    });

    test('walletAddress is non-null and starts with 0x', () {
      expect(mock.walletAddress, startsWith('0x'));
    });

    test('walletAddress has length 42', () {
      expect(mock.walletAddress!.length, 42);
    });

    group('isValidAddress', () {
      test('returns true for valid 42-char 0x address', () {
        const valid = '0x1234567890abcdef1234567890abcdef12345678';
        expect(mock.isValidAddress(valid), isTrue);
      });

      test('returns false when address does not start with 0x', () {
        const noPrefix = '1234567890abcdef1234567890abcdef12345678ab';
        expect(mock.isValidAddress(noPrefix), isFalse);
      });

      test('returns false when address is too short', () {
        expect(mock.isValidAddress('0x1234'), isFalse);
      });

      test('returns false for empty string', () {
        expect(mock.isValidAddress(''), isFalse);
      });

      test('returns false for exactly 41 chars (one too short)', () {
        // 41 chars total: '0x' + 39 hex digits
        expect(mock.isValidAddress('0x${'a' * 39}'), isFalse);
      });

      test('returns false for 43 chars (one too long)', () {
        expect(mock.isValidAddress('0x${'a' * 41}'), isFalse);
      });

      test('non-hex chars with correct length are accepted by mock (known gap)', () {
        // MockWalletBridge only checks prefix and length — it does NOT verify
        // that characters 2-41 are valid hexadecimal digits.
        // '0x' + 40 'Z' chars (Z is not valid hex) → mock returns true.
        // Production IWalletBridge implementations MUST add hex-char validation.
        const nonHex = '0xZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ';
        expect(nonHex.length, 42);
        expect(mock.isValidAddress(nonHex), isTrue); // mock limitation
      });
    });
  });
}
