// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'loyalty_home_page.dart';

/// Widget builder mixin: main page widgets (points card, check-in, quick actions).
///
/// Extends [_LogicMixin] so it can access utility methods like [_tierColor],
/// [_getNextTierName], [_formatPts], etc.
mixin _WidgetsMixin on _LogicMixin {
  TabController get _tabController;

  // ── Points card ─────────────────────────────────────────────────────────

  Widget _buildPointsCard(BuildContext context, LoyaltyProvider provider) {
    final tierColor = Color(provider.getTierColorValue());

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withValues(alpha: 180 / 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: [
          BoxShadow(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withValues(alpha: 50 / 255),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: tier badge + help button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(12),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 50 / 255),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  border: Border.all(color: tierColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.account.tierEmoji,
                      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(6)),
                    Text(
                      provider.account.tierName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Rules button
              GestureDetector(
                onTap: _showRulesBottomSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(6),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: ScreenUtil().setWidth(18),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(4)),
                      Text(
                        'Rules',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // Points value
          Text(
            '${provider.account.availablePoints}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(64),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Available Points',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: Colors.white70,
            ),
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // Tier progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next: ${_getNextTierName(provider.account.tier)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white70,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${provider.account.tierProgress}%',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.white70,
                        ),
                      ),
                      if (provider.account.nextTierPoints > 0 &&
                          provider.account.tier != LoyaltyTier.diamond) ...[
                        Text(
                          ' · ${provider.account.nextTierPoints} pts to go',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                child: LinearProgressIndicator(
                  value: provider.account.tierProgress / 100,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(tierColor),
                  minHeight: ScreenUtil().setWidth(8),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Earned', '${provider.account.totalPoints}'),
              Container(
                width: 1,
                height: ScreenUtil().setWidth(40),
                color: Colors.white24,
              ),
              _buildStatItem('Used', '${provider.account.usedPoints}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // ── Check-in card ───────────────────────────────────────────────────────

  Widget _buildCheckInCard(BuildContext context, LoyaltyProvider provider) {
    final hasCheckedIn = provider.hasCheckedInToday;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: (hasCheckedIn ? Colors.green : Colors.amber)
                  .withValues(alpha: 30 / 255),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
            ),
            child: Icon(
              hasCheckedIn ? Icons.check_circle : Icons.calendar_today,
              color: hasCheckedIn ? Colors.green : Colors.amber,
              size: ScreenUtil().setWidth(32),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_loyalty_daily_checkin,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                Text(
                  hasCheckedIn
                      ? S.of(context).g_key_loyalty_checked_today
                      : S.of(context).g_key_loyalty_earn_points(10),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: hasCheckedIn ? null : () => _handleCheckIn(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasCheckedIn ? Colors.grey : Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
              ),
            ),
            child: Text(
              hasCheckedIn
                  ? S.of(context).g_key_loyalty_checkin_done
                  : S.of(context).g_key_loyalty_checkin_btn,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick actions ───────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, LoyaltyProvider provider) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              context,
              S.of(context).g_key_loyalty_tasks,
              '${provider.availableTasks.length}',
              Icons.assignment,
              Colors.blue,
              () => _tabController.animateTo(0),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: _buildQuickAction(
              context,
              S.of(context).g_key_loyalty_rewards,
              '${provider.rewards.length}',
              Icons.card_giftcard,
              Colors.purple,
              () => _tabController.animateTo(1),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: _buildQuickAction(
              context,
              S.of(context).g_key_loyalty_invite,
              '+100',
              Icons.person_add,
              Colors.green,
              () => _showReferralSheet(_provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    String badge,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(48),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 30 / 255),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Icon(icon, color: color, size: ScreenUtil().setWidth(28)),
                ),
                Positioned(
                  top: -4,
                  right: -8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(6),
                      vertical: ScreenUtil().setWidth(2),
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(18),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
