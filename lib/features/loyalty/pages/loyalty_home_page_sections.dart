// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'loyalty_home_page.dart';

/// Section widgets: referral items, tier table, rule cards, and note items.
///
/// Extends [_WidgetsMixin] (which extends [_LogicMixin]) so it can access
/// utility methods and the provider.
mixin _SectionsMixin on _WidgetsMixin {
  // ── Referral item ───────────────────────────────────────────────────────

  @override
  Widget _buildReferralItem(BuildContext context, ReferralRecord r) {
    Color statusColor;
    String statusText;
    switch (r.status) {
      case ReferralStatus.confirmed:
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case ReferralStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case ReferralStatus.invalid:
        statusColor = Colors.red;
        statusText = 'Invalid';
        break;
    }

    final addr = r.referredAddress;
    final shortAddr = addr.length > 10
        ? '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}'
        : addr;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(40),
            height: ScreenUtil().setWidth(40),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: statusColor,
              size: ScreenUtil().setWidth(22),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.referredName ?? shortAddr,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                if (r.referredName != null)
                  Text(
                    shortAddr,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(8),
                  vertical: ScreenUtil().setWidth(3),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (r.pointsEarned > 0) ...[
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '+${r.pointsEarned} pts',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Rules sheet widgets ─────────────────────────────────────────────────

  @override
  Widget _buildRuleSection(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: ScreenUtil().setWidth(22),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
        SizedBox(width: ScreenUtil().setWidth(8)),
        Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
      ],
    );
  }

  @override
  Widget _buildTierTable(BuildContext context) {
    const tiers = [
      (LoyaltyTier.bronze, '🥉', 'Bronze', 0, 999),
      (LoyaltyTier.silver, '🥈', 'Silver', 1000, 2499),
      (LoyaltyTier.gold, '🥇', 'Gold', 2500, 4999),
      (LoyaltyTier.platinum, '💎', 'Platinum', 5000, 9999),
      (LoyaltyTier.diamond, '👑', 'Diamond', 10000, -1),
    ];

    final currentTier = _provider.account.tier;

    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: tiers.asMap().entries.map((entry) {
          final i = entry.key;
          final (tier, emoji, name, minPts, maxPts) = entry.value;
          final isCurrent = tier == currentTier;
          final tierClr = _tierColor(tier);

          return Container(
            decoration: BoxDecoration(
              color: isCurrent
                  ? tierClr.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: i == 0
                  ? BorderRadius.vertical(
                      top: Radius.circular(ScreenUtil().setWidth(12)),
                    )
                  : i == tiers.length - 1
                      ? BorderRadius.vertical(
                          bottom: Radius.circular(ScreenUtil().setWidth(12)),
                        )
                      : BorderRadius.zero,
              border: isCurrent
                  ? Border.all(color: tierClr.withValues(alpha: 0.4), width: 1)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(12),
              ),
              child: Row(
                children: [
                  Text(emoji, style: TextStyle(fontSize: ScreenUtil().setSp(28))),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? tierClr
                            : AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name,
                              ),
                      ),
                    ),
                  ),
                  Text(
                    maxPts < 0
                        ? '≥ ${_formatPts(minPts)} pts'
                        : '${_formatPts(minPts)} – ${_formatPts(maxPts)} pts',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                  if (isCurrent) ...[
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(6),
                        vertical: ScreenUtil().setWidth(2),
                      ),
                      decoration: BoxDecoration(
                        color: tierClr,
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(6)),
                      ),
                      child: Text(
                        'You',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(18),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget _buildRuleCard(BuildContext context, PointsRule rule, LoyaltyProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.getTaskTypeIcon(rule.taskType),
            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(2)),
                Text(
                  rule.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                // Limit info
                if (rule.dailyLimit != null || rule.totalLimit != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Wrap(
                    spacing: ScreenUtil().setWidth(8),
                    children: [
                      if (rule.dailyLimit != null)
                        _buildLimitChip(
                          context,
                          Icons.today,
                          'Daily limit: ${rule.dailyLimit}x',
                        ),
                      if (rule.totalLimit != null)
                        _buildLimitChip(
                          context,
                          Icons.all_inclusive,
                          'Total limit: ${rule.totalLimit}x',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10),
              vertical: ScreenUtil().setWidth(6),
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Text(
              '+${rule.points}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(14), color: Colors.orange),
          SizedBox(width: ScreenUtil().setWidth(4)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget _buildNoteItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemSubtitleTextColor.name,
          ),
          height: 1.5,
        ),
      ),
    );
  }
}
