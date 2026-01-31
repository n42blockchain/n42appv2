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
import 'package:n42appv2/src/widgets/prompt_widget.dart';

/// NFT 信息展示板
///
/// 在 NFT 详情页显示 NFT 信息和操作按钮（包括销毁）
class NftInfoBoard extends StatelessWidget {
  final String? address;
  final String? tokenName;
  final String? tokenId;
  final String? contractAddress;
  final String? imageUrl;
  final String? nftType; // 'ERC721' or 'ERC1155'
  final String? balance; // ERC1155 的数量
  final GestureTapCallback? sendTap;
  final GestureTapCallback? receiveTap;
  final GestureTapCallback? browserTap;
  final GestureTapCallback? burnTap;

  const NftInfoBoard({
    super.key,
    required this.address,
    this.tokenName,
    this.tokenId,
    this.contractAddress,
    this.imageUrl,
    this.nftType,
    this.balance,
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
          // NFT 图片和基本信息
          _buildNftHeader(context),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 地址信息
          _buildAddressRow(context),

          SizedBox(height: ScreenUtil().setWidth(10)),

          // Token ID
          if (tokenId != null && tokenId!.isNotEmpty)
            _buildInfoRow(context, 'Token ID', '#$tokenId'),

          // NFT 类型
          if (nftType != null && nftType!.isNotEmpty)
            _buildInfoRow(context, 'Type', nftType!),

          // ERC1155 数量
          if (nftType == 'ERC1155' && balance != null)
            _buildInfoRow(context, 'Balance', balance!),

          SizedBox(height: ScreenUtil().setWidth(30)),

          // 操作按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

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
                  errorBuilder: (ctx, error, stackTrace) => _buildPlaceholderImage(context),
                )
              : _buildPlaceholderImage(context),
        ),

        SizedBox(width: ScreenUtil().setWidth(20)),

        // NFT 名称和信息
        Expanded(
          child: Column(
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
                maxLines: 2,
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
                          'Contract: ${_shortenAddress(contractAddress!)}',
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
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Icon(
        Icons.image,
        size: ScreenUtil().setWidth(60),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            address ?? '',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: () => _copyToClipboard(context, address ?? ''),
          child: Container(
            margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
            child: Icon(
              Icons.copy,
              size: ScreenUtil().setWidth(36),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
      child: Row(
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
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
            ),
          ),
        ],
      ),
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
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                sendTap,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: _buildActionButton(
                context,
                S.of(context).g_key_33, // Receive
                Icons.qr_code,
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                receiveTap,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: _buildActionButton(
                context,
                S.of(context).g_key_196, // Browser
                Icons.open_in_browser,
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
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
              'Burn NFT',
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
    ToastUtils.showFtToast(child: successViewV1(S.of(context).copy), duration: 3);
  }

  String _shortenAddress(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }
}
