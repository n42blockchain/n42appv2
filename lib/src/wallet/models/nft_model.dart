// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// NFT 数据模型 — 承接 SimpleHash `/nfts/owners_v2` 响应
class NftModel {
  final String nftId;
  final String name;
  final String? imageUrl;
  final String? description;
  final String contractAddress;
  final String tokenId;
  final String nftType; // 'ERC721' | 'ERC1155' | 'NonFungibleToken'(SOL)
  final int balance; // ERC1155 可能 > 1
  final String chain; // SimpleHash chain slug
  final String? openseaUrl;

  const NftModel({
    required this.nftId,
    required this.name,
    this.imageUrl,
    this.description,
    required this.contractAddress,
    required this.tokenId,
    required this.nftType,
    required this.balance,
    required this.chain,
    this.openseaUrl,
  });

  factory NftModel.fromSimpleHash(Map<String, dynamic> json) {
    final nft = json;
    final contract = nft['contract'] as Map<String, dynamic>? ?? {};
    final collection = nft['collection'] as Map<String, dynamic>? ?? {};

    // 图片 URL：优先使用 previews，再用 image_url
    final previews = nft['previews'] as Map<String, dynamic>?;
    String? imageUrl = previews?['image_small_url'] as String? ??
        previews?['image_medium_url'] as String? ??
        nft['image_url'] as String?;

    // NFT 类型
    final contractType = contract['type'] as String? ?? '';
    final nftType = contractType.isNotEmpty ? contractType : 'ERC721';

    // 余额（owners_v2 中的 quantity_string 或 quantity）
    final quantityStr = nft['quantity_string'] as String? ?? '1';
    final balance = int.tryParse(quantityStr) ?? 1;

    // OpenSea / marketplace URL
    final marketplaces = nft['markets'] as List<dynamic>?;
    String? openseaUrl;
    if (marketplaces != null) {
      for (final m in marketplaces) {
        if (m is Map && m['marketplace_id'] == 'opensea') {
          openseaUrl = m['marketplace_collection_url'] as String?;
          break;
        }
      }
    }
    // 备用：从 external_url 取
    openseaUrl ??= nft['external_url'] as String?;

    return NftModel(
      nftId: nft['nft_id'] as String? ?? '',
      name: nft['name'] as String? ??
          collection['name'] as String? ??
          'NFT #${nft['token_id']}',
      imageUrl: imageUrl,
      description: nft['description'] as String?,
      contractAddress: contract['address'] as String? ?? '',
      tokenId: nft['token_id'] as String? ?? '',
      nftType: nftType,
      balance: balance,
      chain: nft['chain'] as String? ?? '',
      openseaUrl: openseaUrl,
    );
  }

  bool get isSolana => chain == 'solana';
  bool get isErc1155 => nftType == 'ERC1155';
}
