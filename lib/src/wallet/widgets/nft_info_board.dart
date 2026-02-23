// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/widgets/ens_address_display.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';

/// NFT 信息展示板
///
/// 在 NFT 详情页显示 NFT 信息和操作按钮（包括销毁）
class NftInfoBoard extends StatelessWidget {
  final String? address;
  final String? coinType; // 链类型（用于 ENS 解析）
  final String? tokenName;
  final String? tokenId;
  final String? contractAddress;
  final String? imageUrl;
  final String? nftType; // 'ERC721' or 'ERC1155'
  final String? balance; // ERC1155 的数量
  final String? description;
  final String? floorPriceDisplay; // 已格式化的地板价，如 "0.05 ETH"
  final int? inscriptionNumber; // BTC Ordinals 铭文编号
  final String? collectionName;
  final Widget? mediaWidget; // 自定义媒体区域（视频播放器等）
  final GestureTapCallback? sendTap;
  final GestureTapCallback? receiveTap;
  final GestureTapCallback? browserTap;
  final GestureTapCallback? burnTap;

  const NftInfoBoard({
    super.key,
    required this.address,
    this.coinType,
    this.tokenName,
    this.tokenId,
    this.contractAddress,
    this.imageUrl,
    this.nftType,
    this.balance,
    this.description,
    this.floorPriceDisplay,
    this.inscriptionNumber,
    this.collectionName,
    this.mediaWidget,
    this.sendTap,
    this.receiveTap,
    this.browserTap,
    this.burnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NFT 媒体区域（图片或视频播放器）
          if (mediaWidget != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              child: SizedBox(
                width: double.infinity,
                height: ScreenUtil().setWidth(320),
                child: mediaWidget!,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            // 标题 + 合约（媒体独占一行时横向展示）
            _buildTitleSection(context),
          ] else ...[
            // 默认：图片和标题左右布局
            _buildNftHeader(context),
          ],

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 地址信息
          _buildAddressRow(context),

          SizedBox(height: ScreenUtil().setWidth(10)),

          // Collection 名称
          if (collectionName != null && collectionName!.isNotEmpty)
            _buildInfoRow(
                context, S.of(context).g_key_nft_collection, collectionName!),

          // Token ID
          if (tokenId != null && tokenId!.isNotEmpty)
            _buildInfoRow(context, S.of(context).g_key_nft_token_id,
                '#$tokenId'),

          // NFT 类型
          if (nftType != null && nftType!.isNotEmpty)
            _buildInfoRow(
                context, S.of(context).g_key_nft_type, nftType!),

          // ERC1155 数量
          if (nftType == 'ERC1155' && balance != null)
            _buildInfoRow(
                context, S.of(context).g_key_nft_balance, balance!),

          // Ordinals 铭文编号
          if (inscriptionNumber != null)
            _buildInfoRow(
              context,
              S.of(context).g_key_nft_inscription,
              inscriptionNumber.toString(),
            ),

          // 地板价
          if (floorPriceDisplay != null) ...[
            SizedBox(height: ScreenUtil().setWidth(4)),
            _buildFloorPriceRow(context),
          ],

          // 描述
          if (description != null && description!.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(16)),
            _buildDescriptionSection(context),
          ],

          SizedBox(height: ScreenUtil().setWidth(30)),

          // 操作按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // ── Header: 图片 + 标题 横向布局 ──────────────────────────────────────────
  Widget _buildNftHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NFT 图片
        ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  width: ScreenUtil().setWidth(120),
                  height: ScreenUtil().setWidth(120),
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) =>
                      _buildPlaceholderImage(context),
                )
              : _buildPlaceholderImage(context),
        ),

        SizedBox(width: ScreenUtil().setWidth(20)),

        // NFT 名称和合约
        Expanded(child: _buildTitleSection(context)),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tokenName ?? 'NFT #${tokenId ?? "Unknown"}',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(36),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        if (contractAddress != null)
          GestureDetector(
            onTap: () => _copyToClipboard(context, contractAddress!),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${S.of(context).g_key_nft_contract}: ${_shortenAddress(contractAddress!)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Icon(
                  Icons.copy,
                  size: ScreenUtil().setWidth(24),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setWidth(120),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Icon(
        Icons.image,
        size: ScreenUtil().setWidth(60),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name),
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    return EnsAddressDisplay(
      address: address ?? '',
      coinType: coinType ?? 'ETH',
      style: EnsDisplayStyle.compact,
      showAvatar: true,
      showCopy: true,
      fontSize: ScreenUtil().setSp(26),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w500,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPriceRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(12),
          vertical: ScreenUtil().setWidth(8),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              .withAlpha(15),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_down_rounded,
              size: ScreenUtil().setWidth(22),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
            ),
            SizedBox(width: ScreenUtil().setWidth(6)),
            Text(
              '${S.of(context).g_key_nft_floor_price}: $floorPriceDisplay',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_nft_description,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Text(
          description!,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            height: 1.5,
          ),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 主要操作按钮（发送、接收、浏览器）
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                S.of(context).g_key_48, // Send
                Icons.send,
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                sendTap,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: _buildActionButton(
                context,
                S.of(context).g_key_33, // Receive
                Icons.qr_code,
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                receiveTap,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: _buildActionButton(
                context,
                S.of(context).g_key_196, // Browser
                Icons.open_in_browser,
                AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                browserTap,
              ),
            ),
          ],
        ),

        SizedBox(height: ScreenUtil().setWidth(16)),

        // 销毁按钮（独立一行，红色警告风格）
        if (burnTap != null)
          SizedBox(
            width: double.infinity,
            child: _buildBurnButton(context),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    GestureTapCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(16),
          horizontal: ScreenUtil().setWidth(12),
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: ScreenUtil().setWidth(36),
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBurnButton(BuildContext context) {
    return InkWell(
      onTap: burnTap,
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(16),
          horizontal: ScreenUtil().setWidth(20),
        ),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(15),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: Colors.red.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Colors.red,
              size: ScreenUtil().setWidth(32),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(
              S.of(context).g_key_nft_burn_title,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    ToastUtils.init(context);
    Clipboard.setData(ClipboardData(text: text));
    ToastUtils.showFtToast(
        child: successViewV1(S.of(context).copy), duration: 3);
  }

  String _shortenAddress(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }
}
