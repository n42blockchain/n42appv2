// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// MiningV2Provider.fullNodeEntity getter 派生逻辑测试。
//
// 覆盖 lib/features/mining_v2/provider/mining_v2_provider_beacon.dart 4-27 行：
// 纯 getter，直接读 provider 公开字段，不触网、不启定时器。
// 三态判定优先级：
//   (!showRedemption2 && exitTimestamp != 0) → offline（最高优先）
//   showRedemption → miningStatus ? online : offline
//   否则 → syncing

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';

void main() {
  /// 构造一个已具备"有效 keypart + 允许挖矿"前置条件的 provider
  MiningV2Provider buildProvider({
    bool? depositsEnable = true,
    Map<String, dynamic>? keypart = const {'publicKey': '0xabc123'},
  }) {
    final p = MiningV2Provider();
    p.depositsEnable = depositsEnable;
    p.miningKeypart = keypart;
    return p;
  }

  group('fullNodeEntity 前置条件（返回 null 的情形）', () {
    test('depositsEnable 为 null 时返回 null', () {
      final p = buildProvider(depositsEnable: null);
      expect(p.fullNodeEntity, isNull);
    });

    test('depositsEnable 为 false 时返回 null', () {
      final p = buildProvider(depositsEnable: false);
      expect(p.fullNodeEntity, isNull);
    });

    test('miningKeypart 为 null 时返回 null', () {
      final p = buildProvider(keypart: null);
      expect(p.fullNodeEntity, isNull);
    });

    test('publicKey 为空串时返回 null', () {
      final p = buildProvider(keypart: {'publicKey': ''});
      expect(p.fullNodeEntity, isNull);
    });
  });

  group('fullNodeEntity 三态判定', () {
    test('showRedemption + miningStatus 都为 true → online', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true; // exitTimestamp=0 时实际路径会置 true
      p.miningStatus = true;
      p.exitTimestamp = 0;

      final entity = p.fullNodeEntity;
      expect(entity, isNotNull);
      expect(entity!.status, NodeStatus.online);
      expect(entity.id, '0xabc123'); // id 即 publicKey
      expect(entity.name, 'Beacon Validator');
    });

    test('showRedemption=true 但 miningStatus=false → offline', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true;
      p.miningStatus = false;
      p.exitTimestamp = 0;

      expect(p.fullNodeEntity!.status, NodeStatus.offline);
    });

    test('showRedemption=false（激活周期未满）→ syncing', () {
      final p = buildProvider();
      p.showRedemption = false;
      p.showRedemption2 = true;
      p.miningStatus = true; // 即使 miningStatus=true 也不影响 syncing 判定
      p.exitTimestamp = 0;

      expect(p.fullNodeEntity!.status, NodeStatus.syncing);
    });

    test(
      'exitTimestamp!=0 且 showRedemption2=false → offline 优先于 online 判定',
      () {
        final p = buildProvider();
        // 即使 showRedemption + miningStatus 都为 true（本应 online），
        // 已退出（exitTimestamp!=0 && !showRedemption2）仍强制 offline
        p.showRedemption = true;
        p.showRedemption2 = false;
        p.miningStatus = true;
        p.exitTimestamp = 1700000000;

        expect(p.fullNodeEntity!.status, NodeStatus.offline);
      },
    );
  });

  group('fullNodeEntity uptime 计算（100 - inactivityPct，clamp 0..100）', () {
    MiningV2Provider readyProvider() {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true;
      p.miningStatus = true;
      return p;
    }

    test('正常百分比："12.5" → uptime 87.5', () {
      final p = readyProvider();
      p.inactivityScorePercentage = '12.5';
      expect(p.fullNodeEntity!.uptimePercentage, closeTo(87.5, 1e-9));
    });

    test('超界百分比："150" → 100-150=-50 被 clamp 到 0', () {
      final p = readyProvider();
      p.inactivityScorePercentage = '150';
      expect(p.fullNodeEntity!.uptimePercentage, 0.0);
    });

    test('非数字百分比：tryParse 失败按 0 处理 → uptime 100', () {
      final p = readyProvider();
      p.inactivityScorePercentage = 'not-a-number';
      expect(p.fullNodeEntity!.uptimePercentage, 100.0);
    });

    test('默认值 "0" → uptime 100', () {
      final p = readyProvider();
      expect(p.inactivityScorePercentage, '0');
      expect(p.fullNodeEntity!.uptimePercentage, 100.0);
    });
  });

  group('fullNodeEntity 时间与收益字段', () {
    test('exitTimestamp>0 时 expiresAt = 秒 × 1000 转毫秒', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = false;
      p.exitTimestamp = 1700000000;

      expect(
        p.fullNodeEntity!.expiresAt,
        DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000),
      );
    });

    test('exitTimestamp=0 时 expiresAt 为 null', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true;
      p.exitTimestamp = 0;

      expect(p.fullNodeEntity!.expiresAt, isNull);
    });

    test('activationTime 已设置时 activatedAt 精确透传', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true;
      final t = DateTime(2026, 1, 2, 3, 4, 5);
      p.activationTime = t;

      expect(p.fullNodeEntity!.activatedAt, t);
    });

    test('activationTime 为 null 时 activatedAt 回退为当前时间（非 null）', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true;
      p.activationTime = null;

      final before = DateTime.now();
      final activatedAt = p.fullNodeEntity!.activatedAt;
      final after = DateTime.now();
      // 现状断言：回退值取 DateTime.now()，落在调用前后区间内
      expect(activatedAt.isBefore(before), isFalse);
      expect(activatedAt.isAfter(after), isFalse);
    });

    test('totalRewards 透传 miningTotalRevenue', () {
      final p = buildProvider();
      p.showRedemption = true;
      p.showRedemption2 = true;
      p.miningTotalRevenue = 12.34;

      expect(p.fullNodeEntity!.totalRewards, 12.34);
    });
  });
}
