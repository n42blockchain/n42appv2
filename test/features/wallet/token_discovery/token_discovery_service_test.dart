import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/token_discovery/discovered_token.dart';
import 'package:n42_wallet/features/wallet/token_discovery/token_discovery_service.dart';

void main() {
  group('token decimal metadata', () {
    test('accepts zero decimals and valid explorer integer values', () {
      expect(parseDiscoveredTokenDecimals(0), 0);
      expect(parseDiscoveredTokenDecimals('6'), 6);
      expect(parseDiscoveredTokenDecimals(255), 255);
    });

    test('rejects missing, malformed, fractional, and out-of-range values', () {
      expect(parseDiscoveredTokenDecimals(null), isNull);
      expect(parseDiscoveredTokenDecimals(''), isNull);
      expect(parseDiscoveredTokenDecimals('unknown'), isNull);
      expect(parseDiscoveredTokenDecimals(6.5), isNull);
      expect(parseDiscoveredTokenDecimals(-1), isNull);
      expect(parseDiscoveredTokenDecimals(256), isNull);
    });

    test('does not format a balance with invalid decimals as whole tokens', () {
      final token = DiscoveredToken(
        coinType: 'ETH',
        blockchainType: 'Ethereum',
        contractAddress: '0x1234',
        symbol: 'BAD',
        name: 'Bad metadata',
        decimals: 256,
        rawBalance: BigInt.parse('1000000000000000000000000000000'),
      );

      expect(token.humanBalance, '—');
    });
  });

  group('TokenDiscoveryService.matchesTrackedContract', () {
    test('matches EVM contracts case-insensitively', () {
      final matched = TokenDiscoveryService.matchesTrackedContract(
        coinType: 'ETH',
        contract: '0xAbCdEf',
        trackedContracts: {'0xabcdef'},
      );

      expect(matched, isTrue);
    });

    test('matches Solana contracts using exact stored case', () {
      final matched = TokenDiscoveryService.matchesTrackedContract(
        coinType: 'SOL',
        contract: 'So1MintAbC',
        trackedContracts: {'So1MintAbC'},
      );

      expect(matched, isTrue);
    });

    test('keeps compatibility with legacy lower-cased Solana entries', () {
      final matched = TokenDiscoveryService.matchesTrackedContract(
        coinType: 'SOL',
        contract: 'So1MintAbC',
        trackedContracts: {'so1mintabc'},
      );

      expect(matched, isTrue);
    });
  });
}
