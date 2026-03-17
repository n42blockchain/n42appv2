import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/token_discovery/token_discovery_service.dart';

void main() {
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
