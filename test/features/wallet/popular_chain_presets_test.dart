import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/network/custom_chain_service.dart';
import 'package:n42_wallet/features/wallet/pages/network/popular_chain_presets.dart';

/// Wallet Roadmap S5 —— 热门链预设测试。
void main() {
  test('presets are non-empty and well-formed', () {
    final all = PopularChainPresets.all();
    expect(all, isNotEmpty);
    for (final c in all) {
      expect(c.chainId, greaterThan(0));
      expect(c.name.trim(), isNotEmpty);
      expect(c.rpcUrl.startsWith('http'), isTrue);
      expect(c.symbol.trim(), isNotEmpty);
    }
  });

  test('no preset collides with a built-in chain', () {
    for (final c in PopularChainPresets.all()) {
      expect(
        CustomChainService.builtInChainIds.contains(c.chainId),
        isFalse,
        reason: '${c.name} (${c.chainId}) collides with a built-in chain',
      );
    }
  });

  test('chain ids are unique', () {
    final ids = PopularChainPresets.all().map((c) => c.chainId).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('available filters out built-in and already-added', () {
    final all = PopularChainPresets.all();
    final first = all.first.chainId;
    final avail = PopularChainPresets.available([first]);
    expect(avail.any((c) => c.chainId == first), isFalse);
    expect(avail.length, all.length - 1);
  });
}
