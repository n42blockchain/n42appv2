import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/token_gate_entity.dart';

void main() {
  group('TokenStandard', () {
    test('has 4 values', () {
      expect(TokenStandard.values.length, 4);
      expect(TokenStandard.values, containsAll([
        TokenStandard.erc20,
        TokenStandard.erc721,
        TokenStandard.erc1155,
        TokenStandard.native,
      ]));
    });
  });

  group('GateOperator', () {
    test('has 2 values', () {
      expect(GateOperator.values.length, 2);
      expect(GateOperator.values, containsAll([
        GateOperator.and,
        GateOperator.or,
      ]));
    });
  });

  group('TokenGateRule', () {
    TokenGateRule _makeRule({
      String id = 'rule-1',
      TokenStandard tokenStandard = TokenStandard.erc20,
      int chainId = 1,
      String? contractAddress = '0xContract',
      BigInt? minBalance,
      BigInt? tokenId,
      String? symbol = 'USDT',
      int decimals = 18,
    }) {
      return TokenGateRule(
        id: id,
        tokenStandard: tokenStandard,
        chainId: chainId,
        contractAddress: contractAddress,
        minBalance: minBalance ?? BigInt.from(100),
        tokenId: tokenId,
        symbol: symbol,
        decimals: decimals,
      );
    }

    test('constructs with required fields', () {
      final rule = _makeRule();

      expect(rule.id, 'rule-1');
      expect(rule.tokenStandard, TokenStandard.erc20);
      expect(rule.chainId, 1);
      expect(rule.contractAddress, '0xContract');
      expect(rule.minBalance, BigInt.from(100));
      expect(rule.symbol, 'USDT');
      expect(rule.decimals, 18);
    });

    test('optional fields can be null', () {
      final rule = TokenGateRule(
        id: 'rule-min',
        tokenStandard: TokenStandard.native,
        chainId: 137,
        minBalance: BigInt.zero,
      );

      expect(rule.contractAddress, isNull);
      expect(rule.tokenId, isNull);
      expect(rule.symbol, isNull);
    });

    test('default decimals is 18', () {
      final rule = TokenGateRule(
        id: 'rule-dec',
        tokenStandard: TokenStandard.erc20,
        chainId: 1,
        minBalance: BigInt.one,
      );
      expect(rule.decimals, 18);
    });

    group('props equality', () {
      test('equal rules with same fields', () {
        final a = _makeRule();
        final b = _makeRule();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different id produces different rules', () {
        final a = _makeRule(id: 'r1');
        final b = _makeRule(id: 'r2');

        expect(a, isNot(equals(b)));
      });
    });

    group('toJson / fromJson', () {
      test('round trip preserves fields', () {
        final original = _makeRule(
          id: 'rule-rt',
          tokenStandard: TokenStandard.erc721,
          chainId: 56,
          contractAddress: '0xNFT',
          minBalance: BigInt.from(1),
          symbol: 'NFT',
          decimals: 0,
        );

        final json = original.toJson();
        final restored = TokenGateRule.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.tokenStandard, original.tokenStandard);
        expect(restored.chainId, original.chainId);
        expect(restored.contractAddress, original.contractAddress);
        expect(restored.minBalance, original.minBalance);
        expect(restored.symbol, original.symbol);
        expect(restored.decimals, original.decimals);
      });

      test('fromJson handles ERC-1155 with tokenId', () {
        final json = {
          'id': 'rule-1155',
          'token_standard': 'erc1155',
          'chain_id': 1,
          'min_balance': '1',
          'token_id': '42',
          'decimals': 0,
        };
        final rule = TokenGateRule.fromJson(json);

        expect(rule.tokenStandard, TokenStandard.erc1155);
        expect(rule.tokenId, BigInt.from(42));
      });

      test('fromJson uses erc20 as fallback for unknown standard', () {
        final json = {
          'id': 'rule-unk',
          'token_standard': 'unknown',
          'chain_id': 1,
          'min_balance': '100',
          'decimals': 18,
        };
        final rule = TokenGateRule.fromJson(json);
        expect(rule.tokenStandard, TokenStandard.erc20);
      });
    });
  });

  group('TokenGateConfig', () {
    test('default values', () {
      const config = TokenGateConfig();

      expect(config.enabled, isFalse);
      expect(config.rules, isEmpty);
      expect(config.operator, GateOperator.and);
      expect(config.setBy, isNull);
      expect(config.setAt, isNull);
      expect(config.denialMessage, isNull);
    });

    test('constructs with fields', () {
      final rule = TokenGateRule(
        id: 'r1',
        tokenStandard: TokenStandard.erc20,
        chainId: 1,
        minBalance: BigInt.from(100),
      );
      final config = TokenGateConfig(
        enabled: true,
        rules: [rule],
        operator: GateOperator.or,
        setBy: '@admin:server.com',
        denialMessage: 'You need tokens.',
      );

      expect(config.enabled, isTrue);
      expect(config.rules.length, 1);
      expect(config.operator, GateOperator.or);
      expect(config.setBy, '@admin:server.com');
      expect(config.denialMessage, 'You need tokens.');
    });

    group('copyWith', () {
      test('replaces enabled and operator', () {
        const original = TokenGateConfig();
        final updated = original.copyWith(
          enabled: true,
          operator: GateOperator.or,
        );

        expect(updated.enabled, isTrue);
        expect(updated.operator, GateOperator.or);
        expect(updated.rules, original.rules);
      });
    });

    group('toJson / fromJson', () {
      test('round trip with rules', () {
        final rule = TokenGateRule(
          id: 'r1',
          tokenStandard: TokenStandard.erc20,
          chainId: 1,
          minBalance: BigInt.from(1000),
          symbol: 'TOKEN',
        );
        final original = TokenGateConfig(
          enabled: true,
          rules: [rule],
          operator: GateOperator.or,
          setBy: '@admin:server.com',
          setAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000),
          denialMessage: 'Access denied.',
        );

        final json = original.toJson();
        final restored = TokenGateConfig.fromJson(json);

        expect(restored.enabled, original.enabled);
        expect(restored.rules.length, original.rules.length);
        expect(restored.operator, original.operator);
        expect(restored.setBy, original.setBy);
        expect(restored.setAt, original.setAt);
        expect(restored.denialMessage, original.denialMessage);
      });

      test('fromJson with null/missing fields uses defaults', () {
        final json = <String, dynamic>{};
        final config = TokenGateConfig.fromJson(json);

        expect(config.enabled, isFalse);
        expect(config.rules, isEmpty);
        expect(config.operator, GateOperator.and);
      });
    });

    group('props equality', () {
      test('identical configs are equal', () {
        const a = TokenGateConfig(enabled: true);
        const b = TokenGateConfig(enabled: true);

        expect(a, equals(b));
      });

      test('different enabled flag produces different configs', () {
        const a = TokenGateConfig(enabled: true);
        const b = TokenGateConfig(enabled: false);

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('TokenGateVerificationResult', () {
    test('error factory creates failed result', () {
      final result = TokenGateVerificationResult.error('Insufficient balance');

      expect(result.passed, isFalse);
      expect(result.errorMessage, 'Insufficient balance');
      expect(result.ruleResults, isEmpty);
    });

    test('constructs passed result', () {
      const result = TokenGateVerificationResult(passed: true);

      expect(result.passed, isTrue);
      expect(result.errorMessage, isNull);
    });
  });
}
