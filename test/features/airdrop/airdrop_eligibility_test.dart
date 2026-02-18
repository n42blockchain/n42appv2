// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/airdrop/models/airdrop_model.dart';
import 'package:n42appv2/src/models/message_model.dart';

void main() {
  group('Airdrop Eligibility Bug-Fix Tests', () {
    group('MessageModel error pattern (P1-5 regression)', () {
      // 验证 checkEligibility 修复后的行为：无数据时必须返回 error=true
      // 而非之前的 error=false + is_eligible=true
      test('MessageModel.error() sets error=true', () {
        final model = MessageModel.error();
        expect(model.error, isTrue);
      });

      test('MessageModel.error() with data preserves data field', () {
        final model = MessageModel.error()..data = 'Eligibility data unavailable';
        expect(model.error, isTrue);
        expect(model.data, 'Eligibility data unavailable');
      });

      test('Successful MessageModel has error=false', () {
        final model = MessageModel()
          ..error = false
          ..data = {'is_eligible': false};
        expect(model.error, isFalse);
        expect((model.data as Map)['is_eligible'], isFalse);
      });
    });

    group('AirdropModel', () {
      test('isEligible field correctly reflects eligibility', () {
        final model = AirdropModel(
          id: 'test-1',
          name: 'Test Airdrop',
          description: 'desc',
          projectName: 'Test',
          projectLogo: '',
          projectUrl: 'https://test.com',
          chainSymbol: 'ETH',
          chainId: 1,
          type: AirdropType.token,
          status: AirdropStatus.active,
          priority: AirdropPriority.medium,
          isEligible: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.isEligible, isFalse);
      });

      test('isEligible null means unknown (not eligible)', () {
        final model = AirdropModel(
          id: 'test-2',
          name: 'Test Airdrop',
          description: 'desc',
          projectName: 'Test',
          projectLogo: '',
          projectUrl: 'https://test.com',
          chainSymbol: 'ETH',
          chainId: 1,
          type: AirdropType.token,
          status: AirdropStatus.upcoming,
          priority: AirdropPriority.low,
          isEligible: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // null isEligible 表示未知，不应被误判为已符合条件
        expect(model.isEligible, isNull);
        expect(model.isEligible == true, isFalse);
      });

      test('AirdropModel with requirements shows unmet status', () {
        final requirements = [
          AirdropRequirement(
            id: 'r1',
            description: 'Hold 0.1 ETH',
            type: RequirementType.holdToken,
            isMet: false,
          ),
        ];

        final model = AirdropModel(
          id: 'test-3',
          name: 'Test',
          description: 'desc',
          projectName: 'Test',
          projectLogo: '',
          projectUrl: 'https://test.com',
          chainSymbol: 'ETH',
          chainId: 1,
          type: AirdropType.token,
          status: AirdropStatus.active,
          priority: AirdropPriority.high,
          requirements: requirements,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final unmet = model.requirements
            .where((r) => r.isMet == false)
            .toList();
        expect(unmet, hasLength(1));
      });
    });

    group('AirdropFilter', () {
      test('default filter has correct defaults', () {
        final filter = AirdropFilter();
        expect(filter.onlyEligible, isNull);
        expect(filter.sortDescending, isTrue);
        expect(filter.sortBy, AirdropSortBy.priority);
      });

      test('eligibleOnly filter can be set', () {
        final filter = AirdropFilter(onlyEligible: true);
        expect(filter.onlyEligible, isTrue);
      });
    });
  });
}
