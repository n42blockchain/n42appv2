// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';

void main() {
  group('StakingModels Tests', () {
    group('StakingChainType enum', () {
      test('should have correct chain types', () {
        expect(
          StakingChainType.values.contains(StakingChainType.ethereum),
          true,
        );
        expect(StakingChainType.values.contains(StakingChainType.solana), true);
        expect(StakingChainType.values.contains(StakingChainType.cosmos), true);
        expect(
          StakingChainType.values.contains(StakingChainType.polkadot),
          true,
        );
        expect(StakingChainType.values.length, 4);
      });
    });

    group('StakingProtocol', () {
      test('should create from JSON correctly', () {
        final json = {
          'id': 'eth_lido',
          'name': 'Lido',
          'description': 'Liquid staking for Ethereum',
          'chainType': 'ethereum',
          'chainSymbol': 'ETH',
          'logoUri': 'https://example.com/lido.png',
          'apy': 4.0,
          'minStakeAmount': 0.0001,
          'unbondingPeriodDays': 0,
          'isLiquid': true,
          'liquidTokenSymbol': 'stETH',
        };

        final protocol = StakingProtocol.fromJson(json);

        expect(protocol.id, 'eth_lido');
        expect(protocol.name, 'Lido');
        expect(protocol.chainType, StakingChainType.ethereum);
        expect(protocol.apy, 4.0);
        expect(protocol.isLiquid, true);
        expect(protocol.liquidTokenSymbol, 'stETH');
      });

      test('should convert to JSON correctly', () {
        final protocol = StakingProtocol(
          id: 'test',
          name: 'Test Protocol',
          description: 'Test',
          chainType: StakingChainType.solana,
          chainSymbol: 'SOL',
          logoUri: 'https://example.com/logo.png',
          apy: 7.0,
          minStakeAmount: 0.01,
          unbondingPeriodDays: 2,
        );

        final json = protocol.toJson();

        expect(json['id'], 'test');
        expect(json['chainType'], 'solana');
        expect(json['apy'], 7.0);
      });
    });

    group('Validator', () {
      test('should create from JSON correctly', () {
        final json = {
          'address': '0x1234567890abcdef1234567890abcdef12345678',
          'name': 'Lido Finance',
          'description': 'Major staking provider',
          'logoUri': 'https://example.com/lido.png',
          'commission': 10.0,
          'apy': 4.0,
          'totalStaked': '1000000000000000000000000',
          'delegatorCount': 50000,
          'isActive': true,
          'uptime': 99.9,
        };

        final validator = Validator.fromJson(json);

        expect(validator.name, 'Lido Finance');
        expect(validator.commission, 10.0);
        expect(validator.isActive, true);
        expect(validator.uptime, 99.9);
        expect(validator.delegatorCount, 50000);
      });

      test('should handle Cosmos status format', () {
        final json = {
          'address': 'cosmosvaloper1...',
          'moniker': 'Cosmos Validator',
          'status': 'BOND_STATUS_BONDED',
          'commission': 5.0,
        };

        final validator = Validator.fromJson(json);

        expect(validator.name, 'Cosmos Validator');
        expect(validator.isActive, true);
      });
    });

    group('StakingPositionStatus enum', () {
      test('should have correct values', () {
        expect(
          StakingPositionStatus.values.contains(StakingPositionStatus.active),
          true,
        );
        expect(
          StakingPositionStatus.values.contains(
            StakingPositionStatus.unbonding,
          ),
          true,
        );
        expect(
          StakingPositionStatus.values.contains(
            StakingPositionStatus.completed,
          ),
          true,
        );
        expect(
          StakingPositionStatus.values.contains(
            StakingPositionStatus.withdrawn,
          ),
          true,
        );
      });
    });

    group('StakingActionType enum', () {
      test('should have correct action types', () {
        expect(
          StakingActionType.values.contains(StakingActionType.stake),
          true,
        );
        expect(
          StakingActionType.values.contains(StakingActionType.unstake),
          true,
        );
        expect(
          StakingActionType.values.contains(StakingActionType.claim),
          true,
        );
        expect(
          StakingActionType.values.contains(StakingActionType.restake),
          true,
        );
        expect(
          StakingActionType.values.contains(StakingActionType.redelegate),
          true,
        );
      });
    });

    group('StakingProtocols', () {
      test('should have predefined protocols', () {
        expect(StakingProtocols.all.length, 4);
        expect(StakingProtocols.ethLido.name, 'Lido');
        expect(StakingProtocols.solNative.chainType, StakingChainType.solana);
        expect(StakingProtocols.atomNative.unbondingPeriodDays, 21);
        expect(StakingProtocols.dotNative.unbondingPeriodDays, 28);
      });

      test('should get protocol by ID', () {
        final protocol = StakingProtocols.getById('eth_lido');
        expect(protocol, isNotNull);
        expect(protocol!.name, 'Lido');
      });

      test('should return null for unknown ID', () {
        final protocol = StakingProtocols.getById('unknown');
        expect(protocol, isNull);
      });

      test('should filter by chain type', () {
        final ethProtocols = StakingProtocols.getByChainType(
          StakingChainType.ethereum,
        );
        expect(ethProtocols.length, 1);
        expect(ethProtocols.first.id, 'eth_lido');
      });
    });

    group('StakingStats', () {
      test('should create empty stats', () {
        final stats = StakingStats.empty();

        expect(stats.totalStaked, BigInt.zero);
        expect(stats.totalRewards, BigInt.zero);
        expect(stats.averageApy, 0);
        expect(stats.activePositions, 0);
      });
    });

    group('StakingTransactionResponse', () {
      test('should create success response', () {
        final response = StakingTransactionResponse.success(
          txHash: '0xabc123',
          txData: {'nonce': 1},
        );

        expect(response.success, true);
        expect(response.txHash, '0xabc123');
        expect(response.error, isNull);
      });

      test('should create error response', () {
        final response = StakingTransactionResponse.error(
          'Insufficient balance',
        );

        expect(response.success, false);
        expect(response.error, 'Insufficient balance');
        expect(response.txHash, isNull);
      });
    });
  });

  group('APY Calculations', () {
    test('should calculate daily rewards correctly', () {
      final stakedAmount = BigInt.parse('1000000000000000000'); // 1 ETH
      const apy = 4.0;

      // Daily rate = APY / 365
      final dailyRate = apy / 365;
      final dailyRewards =
          stakedAmount *
          BigInt.from((dailyRate * 1e18).toInt()) ~/
          BigInt.from(1e18.toInt());

      expect(dailyRewards > BigInt.zero, true);
    });

    test('should calculate effective APY after commission', () {
      const baseApy = 5.0;
      const commission = 10.0;

      final effectiveApy = baseApy * (1 - commission / 100);

      expect(effectiveApy, 4.5);
    });
  });

  group('Unbonding Period Tests', () {
    test('should calculate unbonding end date correctly', () {
      const unbondingDays = 21;
      final startDate = DateTime(2024, 1, 1);

      final endDate = startDate.add(Duration(days: unbondingDays));

      expect(endDate, DateTime(2024, 1, 22));
    });

    test('should detect if unbonding is complete', () {
      final unbondingStartDate = DateTime.now().subtract(Duration(days: 22));
      const unbondingDays = 21;

      final unbondingEndDate = unbondingStartDate.add(
        Duration(days: unbondingDays),
      );
      final isComplete = DateTime.now().isAfter(unbondingEndDate);

      expect(isComplete, true);
    });
  });
}
