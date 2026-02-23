// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';
import 'package:n42_wallet/features/airdrop/provider/airdrop_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 空投详情页面
class AirdropDetailPage extends StatefulWidget {
  final AirdropModel airdrop;
  final AirdropProvider provider;

  const AirdropDetailPage({
    super.key,
    required this.airdrop,
    required this.provider,
  });

  @override
  State<AirdropDetailPage> createState() => _AirdropDetailPageState();
}

class _AirdropDetailPageState extends State<AirdropDetailPage> {
  @override
  void initState() {
    super.initState();
    // 自动触发资格检测：active/upcoming 且 isEligible 未知时
    final airdrop = widget.airdrop;
    if (airdrop.isEligible == null &&
        (airdrop.status == AirdropStatus.active ||
            airdrop.status == AirdropStatus.upcoming)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.checkEligibility(airdrop.id);
      });
    }
  }

  /// 从 provider 获取最新模型（回退到构造函数传入的快照）
  AirdropModel get _airdrop {
    final found = widget.provider.airdrops
        .where((a) => a.id == widget.airdrop.id)
        .firstOrNull;
    return found ?? widget.airdrop;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final airdrop = _airdrop;
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
                          ).withValues(alpha: 180 / 255),
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
                            child: const Icon(Icons.token, color: Colors.white, size: 40),
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
                      _buildHeader(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(20)),

                      // 价值信息卡片
                      _buildValueCard(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(20)),

                      // 时间信息
                      _buildTimeInfo(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(20)),

                      // 描述
                      _buildDescription(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(20)),

                      // 领取条件
                      _buildRequirements(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(20)),

                      // 社交链接
                      if (airdrop.socialLinks != null && airdrop.socialLinks!.isNotEmpty)
                        _buildSocialLinks(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(30)),

                      // 操作按钮
                      _buildActionButtons(context, airdrop),

                      SizedBox(height: ScreenUtil().setWidth(40)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AirdropModel airdrop) {
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
                  color: Colors.grey.withValues(alpha: 20 / 255),
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

  Widget _buildValueCard(BuildContext context, AirdropModel airdrop) {
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

  Widget _buildTimeInfo(BuildContext context, AirdropModel airdrop) {
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
                        ? Colors.orange.withValues(alpha: 20 / 255)
                        : Colors.green.withValues(alpha: 20 / 255),
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

  Widget _buildDescription(BuildContext context, AirdropModel airdrop) {
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

  Widget _buildRequirements(BuildContext context, AirdropModel airdrop) {
    if (airdrop.requirements.isEmpty) return const SizedBox.shrink();

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

  Widget _buildSocialLinks(BuildContext context, AirdropModel airdrop) {
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
      onTap: () => _launchUrl(context, url),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              .withValues(alpha: 20 / 255),
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

  Widget _buildActionButtons(BuildContext context, AirdropModel airdrop) {
    if (airdrop.status == AirdropStatus.claimed) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 20 / 255),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
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
          color: Colors.red.withValues(alpha: 20 / 255),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red),
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

    final isChecking =
        widget.provider.eligibilityChecking[airdrop.id] == true;

    return Column(
      children: [
        // 资格未知时显示检测按钮/进度
        if (airdrop.isEligible == null &&
            (airdrop.status == AirdropStatus.active ||
                airdrop.status == AirdropStatus.upcoming))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isChecking
                  ? null
                  : () => widget.provider.checkEligibility(airdrop.id),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
              ),
              child: isChecking
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ScreenUtil().setWidth(28),
                          height: ScreenUtil().setWidth(28),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Text(
                          'Checking Eligibility...',
                          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Text(
                          'Check Eligibility',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

        // 不符合条件时显示提示
        if (airdrop.isEligible == false)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 20 / 255),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: ScreenUtil().setWidth(8)),
                Text(
                  'Not Eligible',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // 符合条件且有领取链接时显示 Claim 按钮
        if (airdrop.isClaimable && airdrop.claimUrl != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchUrl(context, airdrop.claimUrl!),
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
                  const Icon(Icons.redeem),
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

        // upcoming 空投显示提醒按钮
        if (airdrop.status == AirdropStatus.upcoming)
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _subscribeAlert(context, airdrop),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active),
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
          ),
      ],
    );
  }

  Future<void> _subscribeAlert(BuildContext context, AirdropModel airdrop) async {
    final success = await widget.provider.subscribeAlert(airdrop.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reminder set! We\'ll notify you when ${airdrop.name} is live.'
              : 'Failed to set reminder. Please try again.',
        ),
        duration: const Duration(seconds: 3),
      ),
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
        color: color.withValues(alpha: 30 / 255),
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
            .withValues(alpha: 20 / 255),
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
        color: color.withValues(alpha: 20 / 255),
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

  Future<void> _launchUrl(BuildContext context, String url) async {
    // Phishing check before opening in the external browser
    final result = PhishingDetector.instance.checkUrl(url);
    if (result == PhishingCheckResult.phishing) {
      if (!context.mounted) return;
      final proceed = await showPhishingWarningDialog(context, url);
      if (proceed != true) return;
      // User accepted the risk — whitelist for this session
      PhishingDetector.instance.allowForSession(url);
    }

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
