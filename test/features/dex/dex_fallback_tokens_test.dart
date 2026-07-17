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

    test('every fallback token carries its own chain', () {
      const chains = ['ETH', 'BSC', 'POLYGON', 'ARB', 'OP', 'BASE', 'SOL'];
      for (final chain in chains) {
        final tokens = DexFallbackTokens.forChain(chain);
        expect(tokens, isNotEmpty, reason: chain);
        for (final token in tokens) {
          expect(token.chain, chain, reason: '$chain/${token.symbol}');
        }
      }
    });

    test('L2/side-chain contracts use canonical addresses', () {
      expect(
        DexFallbackTokens.forChain('POLYGON')[0].address,
        '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270',
      );
      expect(
        DexFallbackTokens.forChain('ARB')[2].address,
        '0xaf88d065e77c8cC2239327C5EDb3A432268e5831',
      );
      expect(
        DexFallbackTokens.forChain('OP')[1].address,
        '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58',
      );
      expect(
        DexFallbackTokens.forChain('BASE')[2].address,
        '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
      );
      for (final chain in ['POLYGON', 'ARB', 'OP', 'BASE']) {
        final tokens = DexFallbackTokens.forChain(chain);
        expect(tokens[1].decimals, 6, reason: '$chain USDT');
        expect(tokens[2].decimals, 6, reason: '$chain USDC');
      }
    });
  });
}
