// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'loyalty_home_page.dart';

/// Logic mixin: event handlers + utility methods.
///
/// Requires [_LoyaltyHomePageState] to provide [_provider] and [widget].
mixin _LogicMixin on State<LoyaltyHomePage> {
  LoyaltyProvider get _provider;

  // ── Event handlers ──────────────────────────────────────────────────────

  Future<void> _handleCheckIn(LoyaltyProvider provider) async {
    try {
      final result = await provider.checkIn();
      if (!mounted) return;

      if (result != null) {
        final pointsEarned = result['points_earned'] as int? ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).g_key_loyalty_checkin_success} +$pointsEarned ${S.of(context).g_key_loyalty_points}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ToastUtils.show(S.of(context).g_key_loyalty_checkin_failed);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(S.of(context).g_key_loyalty_checkin_failed);
      }
    }
  }

  // ── Referral bottom sheet ───────────────────────────────────────────────

  void _showReferralSheet(LoyaltyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: _sheetDecoration(),
          child: Column(
            children: [
              _dragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                  children: [
                    // Icon + title
                    Center(
                      child: Icon(
                        Icons.person_add,
                        size: ScreenUtil().setWidth(56),
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(12)),
                    Center(
                      child: Text(
                        S.of(context).g_key_loyalty_invite_friends,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    Center(
                      child: Text(
                        S.of(context).g_key_loyalty_invite_bonus(100),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // Referral code
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.backGroundColor.name,
                        ),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.referralCode ?? S.of(context).g_key_106,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(32),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainTextColor.name,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: S.of(context).g_key_loyalty_copy,
                            onPressed: () {
                              if (provider.referralCode != null) {
                                Clipboard.setData(
                                  ClipboardData(text: provider.referralCode!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(context).g_key_119),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(12)),

                    // Share link button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final link = provider.referralLink;
                          if (link != null) {
                            Clipboard.setData(ClipboardData(text: link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Link copied: $link'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: Text(S.of(context).g_key_loyalty_share),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(14),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // Invited friends list
                    Row(
                      children: [
                        Text(
                          S.of(context).g_key_loyalty_invited_friends,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            fontWeight: FontWeight.bold,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Text(
                          '(${provider.referrals.length})',
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

                    SizedBox(height: ScreenUtil().setWidth(12)),

                    if (provider.referrals.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(24),
                        ),
                        child: Center(
                          child: Text(
                            'No referrals yet — share your code!',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(24),
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ...provider.referrals.map(
                        (r) => _buildReferralItem(context, r),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Rules bottom sheet ──────────────────────────────────────────────────

  void _showRulesBottomSheet() async {
    await _provider.loadRules();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final provider = _provider;
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: _sheetDecoration(),
            child: Column(
              children: [
                _dragHandle(),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                    vertical: ScreenUtil().setWidth(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                        size: ScreenUtil().setWidth(28),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Text(
                        'Points & Tier Rules',
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

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(24),
                    ),
                    children: [
                      // Tier system
                      _buildRuleSection(context, Icons.trending_up, 'Tier System'),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _buildTierTable(context),

                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // How to earn
                      _buildRuleSection(context, Icons.star, 'How to Earn Points'),
                      SizedBox(height: ScreenUtil().setWidth(12)),

                      if (provider.rules.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else
                        ...provider.rules.map(
                          (rule) => _buildRuleCard(context, rule, provider),
                        ),

                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // Notes
                      _buildRuleSection(context, Icons.info_outline, 'Notes'),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _buildNoteItem(context, '• Points expire after 12 months of inactivity.'),
                      _buildNoteItem(context, '• Tier upgrades are calculated weekly.'),
                      _buildNoteItem(context, '• Fraudulent activity may result in point forfeiture.'),

                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(14),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ScreenUtil().setWidth(12)),
                            ),
                          ),
                          child: const Text('Got it'),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Shared sheet helpers ────────────────────────────────────────────────

  BoxDecoration _sheetDecoration() => BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(20)),
        ),
      );

  Widget _dragHandle() => Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
        child: Container(
          width: ScreenUtil().setWidth(40),
          height: ScreenUtil().setWidth(4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  // ── Utility methods ─────────────────────────────────────────────────────

  String _getNextTierName(LoyaltyTier currentTier) => switch (currentTier) {
        LoyaltyTier.bronze => 'Silver',
        LoyaltyTier.silver => 'Gold',
        LoyaltyTier.gold => 'Platinum',
        LoyaltyTier.platinum => 'Diamond',
        LoyaltyTier.diamond => 'Max Level',
      };

  Color _tierColor(LoyaltyTier tier) => switch (tier) {
        LoyaltyTier.bronze => const Color(0xFFCD7F32),
        LoyaltyTier.silver => const Color(0xFFC0C0C0),
        LoyaltyTier.gold => const Color(0xFFFFD700),
        LoyaltyTier.platinum => const Color(0xFF8B8FA8),
        LoyaltyTier.diamond => const Color(0xFF6DD5FA),
      };

  String _formatPts(int pts) {
    if (pts >= 1000) return '${pts ~/ 1000}K';
    return '$pts';
  }

  // Forward declarations for widget methods used in this mixin.
  // Actual implementations live in _WidgetsMixin.
  Widget _buildReferralItem(BuildContext context, ReferralRecord r);
  Widget _buildRuleSection(BuildContext context, IconData icon, String title);
  Widget _buildTierTable(BuildContext context);
  Widget _buildRuleCard(BuildContext context, PointsRule rule, LoyaltyProvider provider);
  Widget _buildNoteItem(BuildContext context, String text);
}
