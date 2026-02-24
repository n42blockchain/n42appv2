// Tests for AggregatedToken, ChainTokenConfig, and AggregatedTokens.
// Pure Dart configuration classes — no platform-level side effects.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';

void main() {
  // ─────────────────────────────────────────────────
  // ChainTokenConfig
  // ─────────────────────────────────────────────────

  group('ChainTokenConfig', () {
    test('all required fields are set', () {
      const config = ChainTokenConfig(
        chainSymbol: 'ETH',
        contract: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
        decimals: 6,
        chainId: 1,
      );
      expect(config.chainSymbol, 'ETH');
      expect(config.contract, '0xdAC17F958D2ee523a2206206994597C13D831ec7');
      expect(config.decimals, 6);
      expect(config.chainId, 1);
    });

    test('rules defaults to ERC20', () {
      const config = ChainTokenConfig(
        chainSymbol: 'ETH',
        contract: '0x1234',
        decimals: 18,
        chainId: 1,
      );
      expect(config.rules, 'ERC20');
    });

    test('custom rules override default', () {
      const config = ChainTokenConfig(
        chainSymbol: 'BNB',
        contract: '0x5678',
        decimals: 18,
        chainId: 56,
        rules: 'BEP20',
      );
      expect(config.rules, 'BEP20');
    });

    test('TRC20 rules on Tron chain', () {
      const config = ChainTokenConfig(
        chainSymbol: 'TRX',
        contract: 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
        decimals: 6,
        chainId: 0,
        rules: 'TRC20',
      );
      expect(config.rules, 'TRC20');
    });
  });

  // ─────────────────────────────────────────────────
  // AggregatedToken
  // ─────────────────────────────────────────────────

  group('AggregatedToken', () {
    const testToken = AggregatedToken(
      symbol: 'TEST',
      name: 'Test Token',
      icon: 'https://example.com/test.png',
      chains: [
        ChainTokenConfig(chainSymbol: 'ETH', contract: '0x1234', decimals: 18, chainId: 1),
        ChainTokenConfig(chainSymbol: 'BNB', contract: '0x5678', decimals: 18, chainId: 56),
      ],
    );

    test('symbol is set correctly', () {
      expect(testToken.symbol, 'TEST');
    });

    test('name is set correctly', () {
      expect(testToken.name, 'Test Token');
    });

    test('icon URL is set correctly', () {
      expect(testToken.icon, 'https://example.com/test.png');
    });

    test('chains list contains correct entries', () {
      expect(testToken.chains.length, 2);
      expect(testToken.chains[0].chainSymbol, 'ETH');
      expect(testToken.chains[1].chainSymbol, 'BNB');
    });
  });

  // ─────────────────────────────────────────────────
  // AggregatedTokens.usdt
  // ─────────────────────────────────────────────────

  group('AggregatedTokens.usdt', () {
    test('symbol is USDT', () {
      expect(AggregatedTokens.usdt.symbol, 'USDT');
    });

    test('name is Tether USD', () {
      expect(AggregatedTokens.usdt.name, 'Tether USD');
    });

    test('supports ETH chain', () {
      final eth = AggregatedTokens.usdt.chains
          .firstWhere((c) => c.chainSymbol == 'ETH', orElse: null as Never Function()?);
      expect(eth.decimals, 6);
      expect(eth.chainId, 1);
    });

    test('ETH USDT has correct contract address', () {
      final eth = AggregatedTokens.usdt.chains.firstWhere((c) => c.chainSymbol == 'ETH');
      expect(eth.contract, '0xdAC17F958D2ee523a2206206994597C13D831ec7');
    });

    test('supports TRX chain with TRC20 rules', () {
      final trx = AggregatedTokens.usdt.chains.firstWhere((c) => c.chainSymbol == 'TRX');
      expect(trx.rules, 'TRC20');
      expect(trx.chainId, 0);
    });

    test('BSC USDT has BEP20 rules', () {
      final bnb = AggregatedTokens.usdt.chains.firstWhere((c) => c.chainSymbol == 'BNB');
      expect(bnb.rules, 'BEP20');
    });

    test('has at least 5 chains', () {
      expect(AggregatedTokens.usdt.chains.length, greaterThanOrEqualTo(5));
    });
  });

  // ─────────────────────────────────────────────────
  // AggregatedTokens.usdc
  // ─────────────────────────────────────────────────

  group('AggregatedTokens.usdc', () {
    test('symbol is USDC', () {
      expect(AggregatedTokens.usdc.symbol, 'USDC');
    });

    test('name is USD Coin', () {
      expect(AggregatedTokens.usdc.name, 'USD Coin');
    });

    test('supports BASE chain', () {
      final base = AggregatedTokens.usdc.chains
          .where((c) => c.chainSymbol == 'BASE')
          .toList();
      expect(base, isNotEmpty);
      expect(base.first.chainId, 8453);
    });

    test('supports SOL chain with SPL rules', () {
      final sol = AggregatedTokens.usdc.chains.firstWhere((c) => c.chainSymbol == 'SOL');
      expect(sol.rules, 'SPL');
    });

    test('has at least 6 chains', () {
      expect(AggregatedTokens.usdc.chains.length, greaterThanOrEqualTo(6));
    });
  });

  // ─────────────────────────────────────────────────
  // AggregatedTokens.all
  // ─────────────────────────────────────────────────

  group('AggregatedTokens.all', () {
    test('contains exactly 2 tokens (USDT and USDC)', () {
      expect(AggregatedTokens.all.length, 2);
    });

    test('first is USDT', () {
      expect(AggregatedTokens.all[0].symbol, 'USDT');
    });

    test('second is USDC', () {
      expect(AggregatedTokens.all[1].symbol, 'USDC');
    });
  });

  // ─────────────────────────────────────────────────
  // AggregatedTokens.getBySymbol
  // ─────────────────────────────────────────────────

  group('AggregatedTokens.getBySymbol', () {
    test('returns USDT for "USDT"', () {
      final token = AggregatedTokens.getBySymbol('USDT');
      expect(token, isNotNull);
      expect(token!.symbol, 'USDT');
    });

    test('returns USDC for "USDC"', () {
      final token = AggregatedTokens.getBySymbol('USDC');
      expect(token, isNotNull);
      expect(token!.symbol, 'USDC');
    });

    test('case-insensitive — lowercase "usdt" works', () {
      final token = AggregatedTokens.getBySymbol('usdt');
      expect(token, isNotNull);
    });

    test('case-insensitive — mixed case "Usdc" works', () {
      final token = AggregatedTokens.getBySymbol('Usdc');
      expect(token, isNotNull);
    });

    test('unknown symbol returns null', () {
      final token = AggregatedTokens.getBySymbol('XYZ');
      expect(token, isNull);
    });

    test('empty string returns null', () {
      final token = AggregatedTokens.getBySymbol('');
      expect(token, isNull);
    });
  });
}
