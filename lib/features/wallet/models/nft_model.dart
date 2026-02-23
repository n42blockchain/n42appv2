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
  final String nftType; // 'ERC721' | 'ERC1155' | 'NonFungibleToken'(SOL) | 'INSCRIPTION'(BTC)
  final int balance; // ERC1155 可能 > 1
  final String chain; // SimpleHash chain slug
  final String? openseaUrl;

  /// Collection 的最低挂单价（单位：token 原始单位，如 ETH）
  final double? floorPrice;

  /// 地板价对应的代币符号（如 'ETH'、'SOL'）
  final String? floorPriceSymbol;

  /// 动画/视频 URL（来自 animation_url 字段）
  final String? animationUrl;

  /// Ordinals 铭文编号（仅 BTC Ordinals 有效）
  final int? inscriptionNumber;

  /// Collection 名称（用于搜索/过滤）
  final String? collectionName;

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
    this.floorPrice,
    this.floorPriceSymbol,
    this.animationUrl,
    this.inscriptionNumber,
    this.collectionName,
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

    // 动画/视频 URL
    final animationUrl = nft['animation_url'] as String? ??
        (nft['extra_metadata'] as Map?)?['animation_original_url'] as String?;

    // NFT 类型
    final contractType = contract['type'] as String? ?? '';
    final nftType = contractType.isNotEmpty ? contractType : 'ERC721';

    // 余额：quantity_string（字符串）优先，回退到 quantity（整数）字段
    final rawQ = nft['quantity_string'] ?? nft['quantity'];
    final balance = rawQ is int
        ? rawQ
        : (rawQ is String ? (int.tryParse(rawQ) ?? 1) : 1);

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

    // Collection 地板价（取第一条 floor_prices 记录）
    double? floorPrice;
    String? floorPriceSymbol;
    final floorPrices = collection['floor_prices'] as List<dynamic>?;
    if (floorPrices != null && floorPrices.isNotEmpty) {
      final fp = floorPrices.first;
      if (fp is Map) {
        final rawValue = fp['value'];
        if (rawValue != null) {
          floorPrice = (rawValue is num)
              ? rawValue.toDouble()
              : double.tryParse(rawValue.toString());
        }
        final paymentToken = fp['payment_token'] as Map?;
        floorPriceSymbol = paymentToken?['symbol'] as String?;
      }
    }

    // Collection 名称
    final collectionName = collection['name'] as String?;

    // Ordinals 铭文编号
    final extraMetadata = nft['extra_metadata'] as Map?;
    int? inscriptionNumber;
    if (extraMetadata != null) {
      final rawNum = extraMetadata['inscription_number'];
      if (rawNum != null) {
        inscriptionNumber = rawNum is int
            ? rawNum
            : int.tryParse(rawNum.toString());
      }
    }

    return NftModel(
      nftId: nft['nft_id'] as String? ?? '',
      name: nft['name'] as String? ??
          collectionName ??
          'NFT #${nft['token_id']}',
      imageUrl: imageUrl,
      description: nft['description'] as String?,
      contractAddress: contract['address'] as String? ?? '',
      tokenId: nft['token_id'] as String? ?? '',
      nftType: nftType,
      balance: balance,
      chain: nft['chain'] as String? ?? '',
      openseaUrl: openseaUrl,
      floorPrice: floorPrice,
      floorPriceSymbol: floorPriceSymbol,
      animationUrl: animationUrl,
      inscriptionNumber: inscriptionNumber,
      collectionName: collectionName,
    );
  }

  bool get isSolana => chain == 'solana';
  bool get isErc1155 => nftType == 'ERC1155';
  bool get isOrdinal => chain == 'bitcoin';

  /// 是否有可播放的视频/动画内容
  bool get hasVideo {
    final url = animationUrl;
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.ogg');
  }

  /// 格式化地板价显示（保留 4 位有效数字）
  String? get floorPriceDisplay {
    if (floorPrice == null) return null;
    final sym = floorPriceSymbol ?? '';
    final val = floorPrice!;
    final formatted = val < 0.0001
        ? val.toStringAsExponential(2)
        : val < 1
            ? val.toStringAsFixed(4)
            : val.toStringAsFixed(3);
    return sym.isNotEmpty ? '$formatted $sym' : formatted;
  }
}
