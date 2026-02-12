// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/airdrop/models/airdrop_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// 空投详情页面
class AirdropDetailPage extends StatelessWidget {
  final AirdropModel airdrop;

  const AirdropDetailPage({
    super.key,
    required this.airdrop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部 App Bar
          SliverAppBar(
            expandedHeight: ScreenUtil().setWidth(200),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                airdrop.projectName,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withAlpha(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                    child: Image.network(
                      airdrop.projectLogo,
                      width: ScreenUtil().setWidth(80),
                      height: ScreenUtil().setWidth(80),
                      errorBuilder: (ctx, error, stack) => Container(
                        width: ScreenUtil().setWidth(80),
                        height: ScreenUtil().setWidth(80),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                        ),
                        child: Icon(Icons.token, color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 内容
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 空投名称和状态
                  _buildHeader(context),

                  SizedBox(height: ScreenUtil().setWidth(20)),

                  // 价值信息卡片
                  _buildValueCard(context),

                  SizedBox(height: ScreenUtil().setWidth(20)),

                  // 时间信息
                  _buildTimeInfo(context),

                  SizedBox(height: ScreenUtil().setWidth(20)),

                  // 描述
                  _buildDescription(context),

                  SizedBox(height: ScreenUtil().setWidth(20)),

                  // 领取条件
                  _buildRequirements(context),

                  SizedBox(height: ScreenUtil().setWidth(20)),

                  // 社交链接
                  if (airdrop.socialLinks != null && airdrop.socialLinks!.isNotEmpty)
                    _buildSocialLinks(context),

                  SizedBox(height: ScreenUtil().setWidth(30)),

                  // 操作按钮
                  _buildActionButtons(context),

                  SizedBox(height: ScreenUtil().setWidth(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                airdrop.name,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(36),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
            _buildStatusBadge(context, airdrop.status),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Row(
          children: [
            _buildChainTag(context, airdrop.chainSymbol),
            SizedBox(width: ScreenUtil().setWidth(8)),
            _buildTypeTag(context, airdrop.type),
            if (airdrop.tokenSymbol != null) ...[
              SizedBox(width: ScreenUtil().setWidth(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Text(
                  airdrop.tokenSymbol!,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildValueCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Value',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  airdrop.estimatedValueUsd != null
                      ? '\$${airdrop.estimatedValueUsd!.toStringAsFixed(2)}'
                      : 'TBD',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(36),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (airdrop.amount != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    airdrop.amount!,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          if (airdrop.startDate != null)
            _buildTimeRow(context, 'Start Date', _formatDate(airdrop.startDate!)),
          if (airdrop.endDate != null)
            _buildTimeRow(context, 'End Date', _formatDate(airdrop.endDate!)),
          if (airdrop.claimDeadline != null) ...[
            _buildTimeRow(
              context,
              'Claim Deadline',
              _formatDate(airdrop.claimDeadline!),
              isUrgent: airdrop.isExpiringSoon,
            ),
            if (airdrop.daysLeft != null && airdrop.daysLeft! >= 0)
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setWidth(8)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: airdrop.isExpiringSoon
                        ? Colors.orange.withAlpha(20)
                        : Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: airdrop.isExpiringSoon ? Colors.orange : Colors.green,
                        size: ScreenUtil().setWidth(24),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Text(
                        '${airdrop.daysLeft} days remaining',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: airdrop.isExpiringSoon ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, String label, String value,
      {bool isUrgent = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: isUrgent
                  ? Colors.orange
                  : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            airdrop.description,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements(BuildContext context) {
    if (airdrop.requirements.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          ...airdrop.requirements.map((req) => _buildRequirementItem(context, req)),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, AirdropRequirement req) {
    Color statusColor;
    IconData statusIcon;

    if (req.isMet == null) {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
    } else if (req.isMet!) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: ScreenUtil().setWidth(28)),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              req.description,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Links',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Wrap(
            spacing: ScreenUtil().setWidth(12),
            runSpacing: ScreenUtil().setWidth(12),
            children: [
              if (airdrop.projectUrl != null)
                _buildLinkButton(context, 'Website', Icons.language, airdrop.projectUrl!),
              ...airdrop.socialLinks!.entries.map(
                (e) => _buildLinkButton(
                  context,
                  e.key.capitalize(),
                  _getSocialIcon(e.key),
                  e.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, String label, IconData icon, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              .withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ScreenUtil().setWidth(24),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (airdrop.status == AirdropStatus.claimed) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(
              'Already Claimed',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (airdrop.status == AirdropStatus.expired) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Text(
              'Claim Period Ended',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (airdrop.isClaimable && airdrop.claimUrl != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchUrl(airdrop.claimUrl!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.redeem),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    'Claim Now',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (airdrop.status == AirdropStatus.upcoming)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: 设置提醒
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    'Remind Me',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, AirdropStatus status) {
    Color color;
    String text;

    switch (status) {
      case AirdropStatus.upcoming:
        color = Colors.blue;
        text = 'Upcoming';
        break;
      case AirdropStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case AirdropStatus.claimed:
        color = Colors.grey;
        text = 'Claimed';
        break;
      case AirdropStatus.expired:
        color = Colors.red;
        text = 'Expired';
        break;
      case AirdropStatus.ineligible:
        color = Colors.orange;
        text = 'Not Eligible';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChainTag(BuildContext context, String chain) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        chain,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeTag(BuildContext context, AirdropType type) {
    String text;
    Color color;

    switch (type) {
      case AirdropType.token:
        text = 'Token';
        color = Colors.purple;
        break;
      case AirdropType.nft:
        text = 'NFT';
        color = Colors.pink;
        break;
      case AirdropType.points:
        text = 'Points';
        color = Colors.amber;
        break;
      case AirdropType.testnet:
        text = 'Testnet';
        color = Colors.teal;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return Icons.alternate_email;
      case 'discord':
        return Icons.discord;
      case 'telegram':
        return Icons.telegram;
      case 'github':
        return Icons.code;
      default:
        return Icons.link;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch URL: $url, error: $e');
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
