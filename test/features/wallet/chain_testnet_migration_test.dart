import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_testnet_migration.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// 回归：七测真机证实旧钱包的 supportTest 从不迁移——第一次修复被误放进
/// Sonic(CoinType.S)专用分支，普通链永远不执行。本测试用**权威注册表真实
/// 配置**驱动报告中的三个失败场景，锁定迁移对所有链生效。
void main() {
  group('syncChainTestnetFlags（纯函数）', () {
    test('BNB：旧钱包 false → 权威 true（七测 FAIL 场景）', () {
      final stored = {'supportTest': false, 'isTest': false};
      final canonical = chainUrlMap['BNB'] as Map;
      expect(canonical['supportTest'], isTrue, reason: '前置：权威表 BNB 已打开测试网');

      final changed = syncChainTestnetFlags(stored, canonical);
      expect(changed, isTrue);
      expect(stored['supportTest'], isTrue);
    });

    test('TRX：旧钱包 false → 权威 true（七测 FAIL 场景）', () {
      final stored = {'supportTest': false, 'isTest': false};
      final changed = syncChainTestnetFlags(stored, chainUrlMap['TRX'] as Map);
      expect(changed, isTrue);
      expect(stored['supportTest'], isTrue);
    });

    test('ATOM：旧钱包 true → 权威 false，且停在测试网时拉回主网', () {
      final stored = {'supportTest': true, 'isTest': true};
      final canonical = chainUrlMap['ATOM'] as Map;
      expect(canonical['supportTest'], isFalse, reason: '前置：权威表 ATOM 已关闭测试网');

      final changed = syncChainTestnetFlags(stored, canonical);
      expect(changed, isTrue);
      expect(stored['supportTest'], isFalse);
      expect(stored['isTest'], isFalse, reason: '链关闭测试网后不能把钱包留在无法切回的测试网状态');
    });

    test('值已一致时不产生写入', () {
      final stored = {'supportTest': true, 'isTest': false};
      final changed = syncChainTestnetFlags(stored, chainUrlMap['ETH'] as Map);
      expect(changed, isFalse);
    });

    test('配置缺 supportTest 键时不动存量值', () {
      final stored = {'supportTest': true, 'isTest': true};
      final changed = syncChainTestnetFlags(stored, {'other': 1});
      expect(changed, isFalse);
      expect(stored['isTest'], isTrue);
    });
  });

  group('CoinModel 顶层 supportTest 复制（buildCoinModel 契约）', () {
    // buildCoinModel 无法在单测环境实例化（平台通道），此处锁定其数据前提：
    // supportTest 位于链条目**顶层**而 baseInfo 内没有——fromMap(baseInfo)
    // 必然取不到，构建处必须显式复制顶层值（七测 ATOM 运行时=true 的根因）。
    test('权威表中 supportTest 在顶层而非 baseInfo', () {
      for (final key in const ['ATOM', 'BNB', 'TRX', 'ETH']) {
        final chain = chainUrlMap[key] as Map;
        expect(
          chain.containsKey('supportTest'),
          isTrue,
          reason: '$key 顶层应有 supportTest',
        );
        final base = chain['baseInfo'] as Map;
        expect(
          base.containsKey('supportTest'),
          isFalse,
          reason:
              '$key 的 baseInfo 不应有 supportTest——'
              '若未来搬进 baseInfo，请同步更新 buildCoinModel 的复制逻辑',
        );
      }
    });
  });
}
