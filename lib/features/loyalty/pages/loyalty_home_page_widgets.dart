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

  // ── Theme helper ──────────────────────────────────────────────────────

  Color _themeColor(BuildContext context, AppThemeKeys key) {
    return AppThemeUtils.getColorByKey(context, key.name);
  }

  Widget _buildErrorView(BuildContext context, LoyaltyProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(80),
            color: Colors.red,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            'Failed to load loyalty data',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: _themeColor(context, AppThemeKeys.mainTextColor),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            provider.errorMessage ?? 'Please try again later',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ElevatedButton(
            onPressed: provider.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Points card ─────────────────────────────────────────────────────────

  Widget _buildPointsCard(BuildContext context, LoyaltyProvider provider) {
    final tierColor = Color(provider.getTierColorValue());
    final blueColor = _themeColor(context, AppThemeKeys.mainBlueColor);
    final account = provider.account;

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            blueColor,
            blueColor.withValues(alpha: 180 / 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: [
          BoxShadow(
            color: blueColor.withValues(alpha: 50 / 255),
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
                      account.tierEmoji,
                      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(6)),
                    Text(
                      account.tierName,
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
            '${account.availablePoints}',
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
                    'Next: ${_getNextTierName(account.tier)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white70,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${account.tierProgress}%',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.white70,
                        ),
                      ),
                      if (account.nextTierPoints > 0 &&
                          account.tier != LoyaltyTier.diamond) ...[
                        Text(
                          ' · ${account.nextTierPoints} pts to go',
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
                  value: account.tierProgress / 100,
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
              _buildStatItem('Total Earned', '${account.totalPoints}'),
              Container(
                width: 1,
                height: ScreenUtil().setWidth(40),
                color: Colors.white24,
              ),
              _buildStatItem('Used', '${account.usedPoints}'),
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
    final s = S.of(context);
    final statusColor = hasCheckedIn ? Colors.green : Colors.amber;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 30 / 255),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
            ),
            child: Icon(
              hasCheckedIn ? Icons.check_circle : Icons.calendar_today,
              color: statusColor,
              size: ScreenUtil().setWidth(32),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.g_key_loyalty_daily_checkin,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: _themeColor(context, AppThemeKeys.mainTextColor),
                  ),
                ),
                Text(
                  hasCheckedIn
                      ? s.g_key_loyalty_checked_today
                      : s.g_key_loyalty_earn_points(10),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
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
                  ? s.g_key_loyalty_checkin_done
                  : s.g_key_loyalty_checkin_btn,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick actions ───────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, LoyaltyProvider provider) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              context,
              s.g_key_loyalty_tasks,
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
              s.g_key_loyalty_rewards,
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
              s.g_key_loyalty_invite,
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
          color: _themeColor(context, AppThemeKeys.itemBgColor),
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
                color: _themeColor(context, AppThemeKeys.mainTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
