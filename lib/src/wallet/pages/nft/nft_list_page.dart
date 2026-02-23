// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/api/simplehash_nft_api.dart';
import 'package:n42appv2/src/wallet/models/coin_model.dart';
import 'package:n42appv2/src/wallet/models/nft_model.dart';
import 'package:n42appv2/src/wallet/pages/nft/nft_detail_page.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// NFT 列表页
///
/// 展示某链下当前钱包地址持有的所有 NFT（2 列 grid）。
/// 点击任意 NFT → 进入 [NftDetailPage]。
class NftListPage extends StatefulWidget {
  final CoinModel coinModel;

  const NftListPage(this.coinModel, {super.key});

  @override
  State<NftListPage> createState() => _NftListPageState();
}

class _NftListPageState extends State<NftListPage> {
  late Future<List<NftModel>> _future;
  final _api = SimpleHashNftApi();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final address = widget.coinModel.address?.toString() ?? '';
    final coinType = widget.coinModel.coin['coinType'] as String? ?? '';
    _future = _api.fetchNfts(address, coinType);
  }

  void _retry() {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_nft_gallery,
      ),
      body: FutureBuilder<List<NftModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(context);
          }

          final nfts = snapshot.data ?? [];
          if (nfts.isEmpty) {
            return _buildEmpty(context);
          }

          return _buildGrid(context, nfts);
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
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              S.of(context).g_key_nft_error_retry,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
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
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_nft_no_items,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
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
        childAspectRatio: 0.82,
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
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name)
                .withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT 图片
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                  topRight: Radius.circular(ScreenUtil().setWidth(12)),
                ),
                child: _buildThumbnail(nft),
              ),
            ),
            // NFT 名称
            Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
              child: Text(
                nft.name,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Builder(
      builder: (context) => Container(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(20),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: ScreenUtil().setWidth(50),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ),
      ),
    );
  }
}
