import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/nft_model.dart';
import 'package:n42_wallet/features/wallet/utils/nft_gallery_utils.dart';

/// Wallet Roadmap S4 —— NFT 画廊高级管理纯逻辑测试。
NftModel _nft({
  required String id,
  String name = 'NFT',
  String? collection,
  String? image = 'https://img/x.png',
}) {
  return NftModel(
    nftId: id,
    name: name,
    imageUrl: image,
    contractAddress: '0xc',
    tokenId: id,
    nftType: 'ERC721',
    balance: 1,
    chain: 'ethereum',
    collectionName: collection,
  );
}

void main() {
  group('isLikelySpam', () {
    test('flags airdrop/url keywords', () {
      expect(
        NftGalleryUtils.isLikelySpam(_nft(id: '1', name: 'Claim your reward')),
        isTrue,
      );
      expect(
        NftGalleryUtils.isLikelySpam(
            _nft(id: '2', name: 'Visit free-gift.io')),
        isTrue,
      );
    });

    test('keeps legit NFTs', () {
      expect(
        NftGalleryUtils.isLikelySpam(
            _nft(id: '3', name: 'Azuki #123', collection: 'Azuki')),
        isFalse,
      );
    });

    test('flags empty name+image+collection', () {
      expect(
        NftGalleryUtils.isLikelySpam(
            _nft(id: '4', name: '', collection: null, image: '')),
        isTrue,
      );
    });

    test('filterSpam drops only spam', () {
      final out = NftGalleryUtils.filterSpam([
        _nft(id: '1', name: 'Azuki #1', collection: 'Azuki'),
        _nft(id: '2', name: 'Claim 1000 USDT airdrop'),
      ]);
      expect(out.map((n) => n.nftId).toList(), ['1']);
    });
  });

  group('groupByCollection', () {
    test('groups by name asc, uncategorized last', () {
      final groups = NftGalleryUtils.groupByCollection([
        _nft(id: '1', collection: 'Zed'),
        _nft(id: '2', collection: 'Azuki'),
        _nft(id: '3', collection: null),
        _nft(id: '4', collection: 'Azuki'),
      ]);
      expect(groups.map((g) => g.name).toList(),
          ['Azuki', 'Zed', NftGalleryUtils.uncategorized]);
      expect(groups.first.items.length, 2); // two Azuki
    });
  });
}
