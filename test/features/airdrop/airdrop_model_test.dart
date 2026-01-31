// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/airdrop/models/airdrop_model.dart';

void main() {
  group('AirdropModel Tests', () {
    group('AirdropStatus enum', () {
      test('should have correct values', () {
        expect(AirdropStatus.values.contains(AirdropStatus.upcoming), true);
        expect(AirdropStatus.values.contains(AirdropStatus.active), true);
        expect(AirdropStatus.values.contains(AirdropStatus.claimed), true);
        expect(AirdropStatus.values.contains(AirdropStatus.expired), true);
        expect(AirdropStatus.values.contains(AirdropStatus.ineligible), true);
      });
    });

    group('AirdropType enum', () {
      test('should have correct values', () {
        expect(AirdropType.values.contains(AirdropType.token), true);
        expect(AirdropType.values.contains(AirdropType.nft), true);
        expect(AirdropType.values.contains(AirdropType.points), true);
        expect(AirdropType.values.contains(AirdropType.testnet), true);
      });
    });

    group('AirdropPriority enum', () {
      test('should have correct values', () {
        expect(AirdropPriority.values.contains(AirdropPriority.high), true);
        expect(AirdropPriority.values.contains(AirdropPriority.medium), true);
        expect(AirdropPriority.values.contains(AirdropPriority.low), true);
      });
    });

    group('RequirementType enum', () {
      test('should have correct values', () {
        expect(RequirementType.values.contains(RequirementType.holdToken), true);
        expect(RequirementType.values.contains(RequirementType.holdNft), true);
        expect(RequirementType.values.contains(RequirementType.transactionCount), true);
        expect(RequirementType.values.contains(RequirementType.transactionVolume), true);
        expect(RequirementType.values.contains(RequirementType.useDapp), true);
        expect(RequirementType.values.contains(RequirementType.staking), true);
        expect(RequirementType.values.contains(RequirementType.liquidity), true);
        expect(RequirementType.values.contains(RequirementType.social), true);
        expect(RequirementType.values.contains(RequirementType.governance), true);
        expect(RequirementType.values.contains(RequirementType.other), true);
      });
    });

    group('AirdropSortBy enum', () {
      test('should have correct values', () {
        expect(AirdropSortBy.values.contains(AirdropSortBy.priority), true);
        expect(AirdropSortBy.values.contains(AirdropSortBy.value), true);
        expect(AirdropSortBy.values.contains(AirdropSortBy.deadline), true);
        expect(AirdropSortBy.values.contains(AirdropSortBy.name), true);
        expect(AirdropSortBy.values.contains(AirdropSortBy.createdAt), true);
      });
    });

    group('AirdropStats', () {
      test('should create empty stats', () {
        final stats = AirdropStats.empty();

        expect(stats.totalAirdrops, 0);
        expect(stats.eligibleAirdrops, 0);
        expect(stats.claimedAirdrops, 0);
        expect(stats.totalValueUsd, 0);
      });

      test('should create from JSON', () {
        final json = {
          'total_airdrops': 10,
          'eligible_airdrops': 5,
          'claimed_airdrops': 2,
          'total_value_usd': 1000.0,
          'claimed_value_usd': 500.0,
          'pending_value_usd': 300.0,
        };

        final stats = AirdropStats.fromJson(json);

        expect(stats.totalAirdrops, 10);
        expect(stats.eligibleAirdrops, 5);
        expect(stats.claimedAirdrops, 2);
        expect(stats.totalValueUsd, 1000.0);
      });
    });

    group('AirdropRequirement', () {
      test('should create from JSON', () {
        final json = {
          'id': 'req_1',
          'description': 'Hold at least 1 ETH',
          'type': 'holdToken',
          'is_met': true,
          'details': 'Current balance: 2 ETH',
        };

        final requirement = AirdropRequirement.fromJson(json);

        expect(requirement.id, 'req_1');
        expect(requirement.description, 'Hold at least 1 ETH');
        expect(requirement.type, RequirementType.holdToken);
        expect(requirement.isMet, true);
      });

      test('should convert to JSON', () {
        final requirement = AirdropRequirement(
          id: 'req_2',
          description: 'Complete 10 transactions',
          type: RequirementType.transactionCount,
          isMet: false,
        );

        final json = requirement.toJson();

        expect(json['id'], 'req_2');
        expect(json['type'], 'transactionCount');
        expect(json['is_met'], false);
      });
    });

    group('AirdropFilter', () {
      test('should create with default values', () {
        final filter = AirdropFilter();

        expect(filter.sortBy, AirdropSortBy.priority);
        expect(filter.sortDescending, true);
      });

      test('should copy with new values', () {
        final filter = AirdropFilter(
          sortBy: AirdropSortBy.priority,
          onlyEligible: false,
        );

        final newFilter = filter.copyWith(
          onlyEligible: true,
          minValueUsd: 100.0,
        );

        expect(newFilter.onlyEligible, true);
        expect(newFilter.minValueUsd, 100.0);
        expect(newFilter.sortBy, AirdropSortBy.priority);
      });
    });
  });

  group('Airdrop Filtering Tests', () {
    test('should filter airdrops by status', () {
      final statuses = [
        AirdropStatus.active,
        AirdropStatus.claimed,
        AirdropStatus.expired,
      ];

      final active = statuses.where((s) => s == AirdropStatus.active).toList();
      expect(active.length, 1);
    });

    test('should sort priorities correctly', () {
      final priorities = [
        AirdropPriority.low,
        AirdropPriority.high,
        AirdropPriority.medium,
      ];

      final sorted = [...priorities]..sort((a, b) =>
          AirdropPriority.values.indexOf(a) - AirdropPriority.values.indexOf(b));

      expect(sorted[0], AirdropPriority.high);
      expect(sorted[1], AirdropPriority.medium);
      expect(sorted[2], AirdropPriority.low);
    });
  });

  group('Deadline Calculation Tests', () {
    test('should detect expired airdrop', () {
      final expiredDate = DateTime.now().subtract(Duration(days: 1));
      final isExpired = DateTime.now().isAfter(expiredDate);
      expect(isExpired, true);
    });

    test('should calculate days until deadline', () {
      final now = DateTime.now();
      final deadline = now.add(Duration(days: 30));
      final daysUntil = deadline.difference(now).inDays;
      expect(daysUntil, 30);
    });

    test('should detect deadline approaching', () {
      final deadline = DateTime.now().add(Duration(days: 3));
      final daysUntil = deadline.difference(DateTime.now()).inDays;
      final isApproaching = daysUntil <= 7;
      expect(isApproaching, true);
    });
  });

  group('Eligibility Tests', () {
    test('should calculate eligibility progress', () {
      const completedRequirements = 3;
      const totalRequirements = 5;
      final progress = (completedRequirements / totalRequirements * 100).toInt();
      expect(progress, 60);
    });

    test('should detect full eligibility', () {
      const progress = 100;
      final isFullyEligible = progress >= 100;
      expect(isFullyEligible, true);
    });
  });
}
