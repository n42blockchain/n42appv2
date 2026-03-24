import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/airdrop/api/airdrop_api.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';
import 'package:n42_wallet/features/airdrop/provider/airdrop_provider.dart';
import 'package:n42_wallet/features/models/message_model.dart';

void main() {
  group('AirdropProvider.refresh', () {
    test('enters error state when first load cannot fetch airdrops', () async {
      final provider = AirdropProvider(
        api: _FakeAirdropApi(failAirdrops: true),
      );

      await provider.initialize('0xabc');

      expect(provider.loadState, AirdropLoadState.error);
      expect(provider.errorMessage, 'Failed to load airdrops');
      expect(provider.airdrops, isEmpty);
    });

    test('keeps loaded state when refresh fails after cached data exists', () async {
      final api = _FakeAirdropApi();
      final provider = AirdropProvider(api: api);

      await provider.initialize('0xabc');
      expect(provider.loadState, AirdropLoadState.loaded);
      expect(provider.airdrops, hasLength(1));

      api.failAirdrops = true;
      await provider.refresh();

      expect(provider.loadState, AirdropLoadState.loaded);
      expect(provider.airdrops, hasLength(1));
      expect(provider.isNetworkError, isTrue);
    });

    test('deduplicates concurrent loadMore requests', () async {
      final api = _FakeAirdropApi(pageSize: 20);
      final provider = AirdropProvider(api: api);

      await provider.initialize('0xabc');
      expect(provider.hasMore, isTrue);
      expect(provider.airdrops, hasLength(20));

      await Future.wait([
        provider.loadMore(),
        provider.loadMore(),
        provider.loadMore(),
      ]);

      expect(api.pageCalls[2], 1);
      expect(provider.airdrops, hasLength(40));
    });
  });
}

class _FakeAirdropApi extends AirdropApi {
  _FakeAirdropApi({
    this.failAirdrops = false,
    this.pageSize = 1,
  });

  bool failAirdrops;
  final int pageSize;
  final Map<int, int> pageCalls = {};

  @override
  Future<MessageModel> getAirdrops({
    String? walletAddress,
    AirdropFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    pageCalls.update(page, (count) => count + 1, ifAbsent: () => 1);
    if (failAirdrops) {
      return MessageModel.error()..data = 'offline';
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return MessageModel()
      ..error = false
      ..data = List.generate(
        this.pageSize,
        (index) => _buildAirdrop(id: 'zro-$page-$index'),
      );
  }

  @override
  Future<MessageModel> getAirdropStats(String walletAddress) async {
    return MessageModel()
      ..error = false
      ..data = AirdropStats(
        totalAirdrops: 1,
        eligibleAirdrops: 1,
        claimedAirdrops: 0,
        totalValueUsd: 100,
        claimedValueUsd: 0,
        pendingValueUsd: 100,
      );
  }

  @override
  Future<MessageModel> getTrendingAirdrops() async {
    return MessageModel()
      ..error = false
      ..data = [_buildAirdrop()];
  }
}

AirdropModel _buildAirdrop({String id = 'zro'}) {
  final now = DateTime(2026, 3, 16);
  return AirdropModel(
    id: id,
    name: 'LayerZero',
    description: 'Bridge rewards',
    projectName: 'LayerZero',
    projectLogo: 'https://example.com/logo.png',
    projectUrl: 'https://example.com',
    chainSymbol: 'ETH',
    chainId: 1,
    type: AirdropType.token,
    status: AirdropStatus.active,
    priority: AirdropPriority.high,
    createdAt: now,
    updatedAt: now,
  );
}
