// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'airdrop_detail_page.dart';

/// Widgets mixin: section builder methods for [AirdropDetailPage].
mixin AirdropDetailWidgetsMixin
    on State<AirdropDetailPage>, AirdropDetailLogicMixin, AirdropDetailActionsMixin {
  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget buildHeader(BuildContext context, AirdropModel airdrop) {
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
            buildStatusBadge(context, airdrop.status),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        Row(
          children: [
            buildChainTag(context, airdrop.chainSymbol),
            SizedBox(width: ScreenUtil().setWidth(8)),
            buildTypeTag(context, airdrop.type),
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

  // ---------------------------------------------------------------------------
  // Value card
  // ---------------------------------------------------------------------------

  Widget buildValueCard(BuildContext context, AirdropModel airdrop) {
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

  // ---------------------------------------------------------------------------
  // Time info
  // ---------------------------------------------------------------------------

  Widget buildTimeInfo(BuildContext context, AirdropModel airdrop) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          if (airdrop.startDate != null)
            _buildTimeRow(context, 'Start Date', formatDate(airdrop.startDate!)),
          if (airdrop.endDate != null)
            _buildTimeRow(context, 'End Date', formatDate(airdrop.endDate!)),
          if (airdrop.claimDeadline != null) ...[
            _buildTimeRow(
              context,
              'Claim Deadline',
              formatDate(airdrop.claimDeadline!),
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

  // ---------------------------------------------------------------------------
  // Description
  // ---------------------------------------------------------------------------

  Widget buildDescription(BuildContext context, AirdropModel airdrop) {
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

  // ---------------------------------------------------------------------------
  // Requirements
  // ---------------------------------------------------------------------------

  Widget buildRequirements(BuildContext context, AirdropModel airdrop) {
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

  // ---------------------------------------------------------------------------
  // Social links
  // ---------------------------------------------------------------------------

  Widget buildSocialLinks(BuildContext context, AirdropModel airdrop) {
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
                  getSocialIcon(e.key),
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
      onTap: () => launchExternalUrl(context, url),
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
}
