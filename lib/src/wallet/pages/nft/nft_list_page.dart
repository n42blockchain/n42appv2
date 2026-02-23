// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/api/simplehash_nft_api.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/models/nft_model.dart';
import 'package:n42_wallet/src/wallet/pages/nft/nft_detail_page.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// NFT 列表页
///
/// 展示某链下当前钱包地址持有的所有 NFT（2 列 grid）。
/// 支持按名称/Collection 搜索、按类型过滤（全部/Video/ERC721/ERC1155/Ordinals）。
/// 点击任意 NFT → 进入 [NftDetailPage]。
class NftListPage extends StatefulWidget {
  final CoinModel coinModel;

  const NftListPage(this.coinModel, {super.key});

  @override
  State<NftListPage> createState() => _NftListPageState();
}

/// 类型过滤枚举
enum _NftFilter { all, video, erc721, erc1155, ordinals }

class _NftListPageState extends State<NftListPage> {
  late Future<List<NftModel>> _future;
  final _api = SimpleHashNftApi();
  final _searchController = TextEditingController();

  List<NftModel> _nfts = [];
  _NftFilter _filter = _NftFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    final address = widget.coinModel.address?.toString() ?? '';
    final coinType = widget.coinModel.coin['coinType'] as String? ?? '';
    _future = _api.fetchNfts(address, coinType).then((list) {
      if (mounted) setState(() => _nfts = list);
      return list;
    });
  }

  void _retry() {
    setState(() {
      _nfts = [];
      _load();
    });
  }

  List<NftModel> get _filtered {
    // 过滤掉 balance <= 0 的 NFT（API 数据异常 or 已全部转出的 ERC-1155）
    var list = _nfts.where((n) => n.balance > 0).toList();

    // 类型过滤
    switch (_filter) {
      case _NftFilter.video:
        list = list.where((n) => n.hasVideo).toList();
        break;
      case _NftFilter.erc721:
        list = list.where((n) => n.nftType == 'ERC721').toList();
        break;
      case _NftFilter.erc1155:
        list = list.where((n) => n.isErc1155).toList();
        break;
      case _NftFilter.ordinals:
        list = list.where((n) => n.isOrdinal).toList();
        break;
      case _NftFilter.all:
        break;
    }

    // 搜索过滤
    if (_query.isNotEmpty) {
      list = list.where((n) {
        return n.name.toLowerCase().contains(_query) ||
            (n.collectionName?.toLowerCase().contains(_query) ?? false);
      }).toList();
    }

    return list;
  }

  // 当前链是否有 Ordinals（BTC 链）
  bool get _hasOrdinals {
    final coinType = widget.coinModel.coin['coinType'] as String? ?? '';
    return coinType.toUpperCase() == 'BTC';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_nft_gallery,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildFilterChips(context),
          Expanded(
            child: FutureBuilder<List<NftModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _nfts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError && _nfts.isEmpty) {
                  return _buildError(context);
                }

                final filtered = _filtered;
                if (filtered.isEmpty) {
                  return _buildEmpty(context);
                }

                return _buildGrid(context, filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(16),
        ScreenUtil().setWidth(12),
        ScreenUtil().setWidth(16),
        ScreenUtil().setWidth(4),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: S.of(context).g_key_nft_search_hint,
          hintStyle: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: ScreenUtil().setWidth(28),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  iconSize: ScreenUtil().setWidth(24),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(12),
            horizontal: ScreenUtil().setWidth(16),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            borderSide: BorderSide(
              color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withAlpha(60),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            borderSide: BorderSide(
              color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name)
                  .withAlpha(60),
            ),
          ),
          filled: true,
          fillColor: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
        ),
        style: TextStyle(fontSize: ScreenUtil().setSp(26)),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = [
      (_NftFilter.all, S.of(context).g_key_nft_filter_all),
      if (_nfts.any((n) => n.hasVideo))
        (_NftFilter.video, S.of(context).g_key_nft_filter_video),
      if (!_hasOrdinals && _nfts.any((n) => n.nftType == 'ERC721'))
        (_NftFilter.erc721, 'ERC721'),
      if (!_hasOrdinals && _nfts.any((n) => n.isErc1155))
        (_NftFilter.erc1155, 'ERC1155'),
      if (_hasOrdinals || _nfts.any((n) => n.isOrdinal))
        (_NftFilter.ordinals, S.of(context).g_key_nft_ordinals),
    ];

    if (filters.length <= 1) return const SizedBox.shrink();

    final accentColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    return SizedBox(
      height: ScreenUtil().setWidth(52),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
        itemCount: filters.length,
        separatorBuilder: (ctx, i) => SizedBox(width: ScreenUtil().setWidth(8)),
        itemBuilder: (context, i) {
          final (type, label) = filters[i];
          final selected = _filter == type;
          return GestureDetector(
            onTap: () => setState(() => _filter = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: selected ? accentColor : accentColor.withAlpha(20),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(20)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _retry,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: ScreenUtil().setWidth(60),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              S.of(context).g_key_nft_error_retry,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.collections_outlined,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_nft_no_items,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<NftModel> nfts) {
    return GridView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ScreenUtil().setWidth(12),
        mainAxisSpacing: ScreenUtil().setWidth(12),
        childAspectRatio: 0.75,
      ),
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        return _buildNftCard(context, nfts[index]);
      },
    );
  }

  Widget _buildNftCard(BuildContext context, NftModel nft) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NftDetailPage(nft, widget.coinModel),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name)
                .withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT 图片（带视频/Ordinals 徽章）
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                      topRight: Radius.circular(ScreenUtil().setWidth(12)),
                    ),
                    child: _buildThumbnail(nft),
                  ),
                  // 视频播放图标徽章
                  if (nft.hasVideo)
                    Positioned(
                      top: ScreenUtil().setWidth(8),
                      right: ScreenUtil().setWidth(8),
                      child: Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(6)),
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: ScreenUtil().setWidth(22),
                        ),
                      ),
                    ),
                  // Ordinals 徽章
                  if (nft.isOrdinal)
                    Positioned(
                      top: ScreenUtil().setWidth(8),
                      left: ScreenUtil().setWidth(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(6),
                          vertical: ScreenUtil().setWidth(3),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7931A).withAlpha(220),
                          borderRadius:
                              BorderRadius.circular(ScreenUtil().setWidth(6)),
                        ),
                        child: Text(
                          'BTC',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // NFT 名称 + Floor Price
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(10),
                vertical: ScreenUtil().setWidth(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (nft.floorPriceDisplay != null) ...[
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Row(
                      children: [
                        Text(
                          '${S.of(context).g_key_nft_floor_price}: ',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            nft.floorPriceDisplay!,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(20),
                              fontWeight: FontWeight.w500,
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainBlueColor.name),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(NftModel nft) {
    if (nft.imageUrl != null && nft.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: nft.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildPlaceholder(nft),
        errorWidget: (context, url, error) => _buildPlaceholder(nft),
      );
    }
    return _buildPlaceholder(nft);
  }

  Widget _buildPlaceholder(NftModel nft) {
    return Builder(
      builder: (context) => Container(
        color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(20),
        child: Center(
          child: Icon(
            nft.isOrdinal ? Icons.currency_bitcoin : Icons.image_outlined,
            size: ScreenUtil().setWidth(50),
            color: nft.isOrdinal
                ? const Color(0xFFF7931A)
                : AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      ),
    );
  }
}
