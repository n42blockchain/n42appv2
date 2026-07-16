import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';

void main() {
  group('DexFallbackTokens', () {
    test('returns canonical Ethereum swap tokens', () {
      final tokens = DexFallbackTokens.forChain('ETH');

      expect(tokens.map((token) => token.symbol), ['WETH', 'USDT', 'USDC']);
      expect(tokens[0].address, '0xC02aaA39b223FE8D0A0E5C4F27eAD9083C756Cc2');
      expect(tokens[1].decimals, 6);
      expect(tokens[2].decimals, 6);
    });

    test('uses the correct decimals for BSC stablecoins', () {
      final tokens = DexFallbackTokens.forChain('BSC');

      expect(tokens.map((token) => token.symbol), ['WBNB', 'USDT', 'USDC']);
      expect(tokens[1].decimals, 18);
      expect(tokens[2].decimals, 18);
    });

    test('returns Solana native mint and stablecoin mints', () {
      final tokens = DexFallbackTokens.forChain('SOL');

      expect(tokens.map((token) => token.symbol), ['SOL', 'USDC', 'USDT']);
      expect(tokens[0].decimals, 9);
      expect(tokens[2].address, 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB');
    });

    test('returns no fallback for unsupported chains', () {
      expect(DexFallbackTokens.forChain('N42'), isEmpty);
    });
  });
}
