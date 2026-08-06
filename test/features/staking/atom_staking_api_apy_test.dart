// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// AtomStakingApi APY 计算与兜底逻辑测试（不触网）。
//
// 覆盖 lib/features/staking/api/atom_staking_api.dart：
//   - buildInflationApyResult：正常路径 APY = inflation / stakingRatio * 100；
//   - stakingRatio<=0 除零保护：走兜底且 error=true（历史缺陷：得 Infinity）；
//   - fallbackInflationApyResult：error 必须为 true（历史缺陷：catch 里
//     回落假数据却置 error=false，调用方无法区分真实数据与兜底估算）。
//
// 调用方消费方式（决定 error=true 是安全修复的依据）：
//   earn_provider._fetchAtomApy / staking_provider._tryUpdateApy /
//   staking_home_page_logic.loadLiveApys 均检查 !result.error，
//   error=true 时忽略 data 走各自本地默认值。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/staking/api/atom_staking_api.dart';

void main() {
  group('buildInflationApyResult 正常路径', () {
    test('inflation=0.15, ratio=0.6 → apy=25，比例换算为百分数', () {
      final mm = AtomStakingApi.buildInflationApyResult(0.15, 0.6);
      expect(mm.error, isFalse);
      final data = mm.data as Map;
      expect(data['inflation'], closeTo(15.0, 1e-9));
      expect(data['stakingRatio'], closeTo(60.0, 1e-9));
      expect(data['apy'], closeTo(25.0, 1e-9));
    });

    test('inflation=0.1, ratio=1.0（全量质押）→ apy=10', () {
      final mm = AtomStakingApi.buildInflationApyResult(0.1, 1.0);
      expect(mm.error, isFalse);
      expect((mm.data as Map)['apy'], closeTo(10.0, 1e-9));
    });
  });

  group('stakingRatio 除零保护', () {
    test('ratio=0 → 走兜底且 error=true，apy 不为 Infinity', () {
      final mm = AtomStakingApi.buildInflationApyResult(0.15, 0.0);
      expect(mm.error, isTrue, reason: '兜底数据必须标记 error，调用方才能忽略');
      final apy = (mm.data as Map)['apy'] as double;
      expect(apy.isFinite, isTrue);
      expect(apy, 15.0);
    });

    test('ratio 为负（异常数据）同样走兜底', () {
      final mm = AtomStakingApi.buildInflationApyResult(0.15, -0.5);
      expect(mm.error, isTrue);
    });
  });

  group('fallbackInflationApyResult 诚实性', () {
    test('error 必须为 true，data 保留估算值供日志/调试参考', () {
      final mm = AtomStakingApi.fallbackInflationApyResult();
      expect(mm.error, isTrue,
          reason: '历史缺陷：catch 兜底曾置 error=false，调用方把估算值当真实数据');
      final data = mm.data as Map;
      expect(data['inflation'], 15.0);
      expect(data['stakingRatio'], 60.0);
      expect(data['apy'], 15.0);
    });
  });
}
