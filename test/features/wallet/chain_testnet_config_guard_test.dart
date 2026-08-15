import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

/// 守护链注册表的测试网配置。
///
/// 背景：ETH 曾长期停留在 Ropsten(3)、MATIC 停留在 Mumbai(80001)，两者分别于
/// 2022-12 与 2024-04 关停；由于 RPC 侧已切到 Sepolia/Amoy，会出现「RPC 连新网、
/// 签名带旧 chainId」而被节点拒绝的组合。BASE 则把 chainId_test 填成主网 8453，
/// 一旦 supportTest 被打开，"测试网"交易在主网同样合法、可被重放。
void main() {
  /// 已关停的测试网 chainId。
  const deadTestnets = <int, String>{
    3: 'Ropsten (2022-12 关停)',
    4: 'Rinkeby (2023 关停)',
    5: 'Goerli (2023 关停)',
    42: 'Kovan (2022 关停)',
    80001: 'Polygon Mumbai (2024-04 关停)',
  };

  Iterable<MapEntry<String, Map>> evmEntries(Map<String, dynamic> registry) sync* {
    for (final entry in registry.entries) {
      final value = entry.value;
      if (value is! Map) continue;
      final base = value['baseInfo'];
      if (base is! Map) continue;
      if (base['blockchainType'] != BlockchainType.Ethereum.name) continue;
      yield MapEntry(entry.key, base);
    }
  }

  int? asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');

  for (final registry in <MapEntry<String, Map<String, dynamic>>>[
    MapEntry('chainUrlMap(权威)', chainUrlMap),
    MapEntry('allChainUrlMap(目录)', allChainUrlMap),
  ]) {
    group(registry.key, () {
      test('不得使用已关停的测试网 chainId', () {
        final offenders = <String>[];
        for (final e in evmEntries(registry.value)) {
          final id = asInt(e.value['chainId_test']);
          if (id != null && deadTestnets.containsKey(id)) {
            offenders.add('${e.key}: chainId_test=$id → ${deadTestnets[id]}');
          }
        }
        expect(
          offenders,
          isEmpty,
          reason: '这些链指向已关停的测试网，测试网功能不可用：\n${offenders.join('\n')}',
        );
      });

      test('测试网 chainId 不得等于主网 chainId（重放风险）', () {
        final offenders = <String>[];
        for (final e in evmEntries(registry.value)) {
          final main = asInt(e.value['chainId']);
          final test = asInt(e.value['chainId_test']);
          if (main != null && test != null && test != 0 && main == test) {
            offenders.add('${e.key}: chainId=$main == chainId_test=$test');
          }
        }
        expect(
          offenders,
          isEmpty,
          reason: '测试网 chainId 等于主网会让"测试网"交易在主网同样合法、可被重放。'
              '无测试网时应填 0，使 resolveChainId 返回 null 并触发 fail-closed：\n'
              '${offenders.join('\n')}',
        );
      });
    });
  }

  group('两套注册表一致性', () {
    test('主要 EVM 链的 chainId_test 在两表中一致', () {
      // 权威表驱动转账，目录表用于加链判重；两者矛盾会误导排查。
      for (final key in const ['ETH', 'MATIC', 'BNB']) {
        final a = (chainUrlMap[key] as Map?)?['baseInfo'] as Map?;
        final b = (allChainUrlMap[key] as Map?)?['baseInfo'] as Map?;
        if (a == null || b == null) continue;
        expect(
          asInt(a['chainId_test']),
          asInt(b['chainId_test']),
          reason: '$key 在权威表与目录表的 chainId_test 不一致',
        );
      }
    });
  });
}
