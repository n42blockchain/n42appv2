// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'airdrop_home_page.dart';

/// Logic mixin: state fields, navigation, URL launching, badges, empty/error views,
/// filter sheet, and notification settings.
mixin AirdropHomeLogicMixin on State<AirdropHomePage> {
  late TabController tabController;
  late AirdropProvider provider;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void navigateToDetail(AirdropModel airdrop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirdropDetailPage(airdrop: airdrop, provider: provider),
      ),
    );
  }

  void claimAirdrop(AirdropModel airdrop) {
    if (airdrop.claimUrl != null) {
      launchExternalUrl(context, airdrop.claimUrl!);
    }
  }

  // ---------------------------------------------------------------------------
  // URL launching
  // ---------------------------------------------------------------------------

  Future<void> launchExternalUrl(BuildContext context, String url) async {
    final result = PhishingDetector.instance.checkUrl(url);
    if (result == PhishingCheckResult.phishing) {
      if (!context.mounted) return;
      final proceed = await showPhishingWarningDialog(context, url);
      if (proceed != true) return;
      PhishingDetector.instance.allowForSession(url);
    }

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch URL: $url, error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Status / chain / type badges
  // ---------------------------------------------------------------------------

  Widget buildStatusBadge(AirdropStatus status) {
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
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 30 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildChainTag(String chain) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            .withValues(alpha: 20 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        chain,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildTypeTag(AirdropType type) {
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
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 20 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty & error views
  // ---------------------------------------------------------------------------

  Widget buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            'No airdrops found',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            'Check back later for new opportunities',
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
    );
  }

  Widget buildErrorView(AirdropProvider p) {
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
            'Failed to load airdrops',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ElevatedButton(
            onPressed: p.refresh,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter bottom sheet
  // ---------------------------------------------------------------------------

  void showFilterSheet() {
    final currentFilter = provider.filter;
    AirdropType? selectedType =
        currentFilter.types?.isNotEmpty == true ? currentFilter.types!.first : null;
    bool onlyEligible = currentFilter.onlyEligible ?? false;
    bool onlyHighValue = currentFilter.onlyHighValue ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(ctx).g_key_filter,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          provider.clearFilter();
                        },
                        child: Text(S.of(ctx).g_key_reset),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    S.of(ctx).g_key_filter_type,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    spacing: 8,
                    children: AirdropType.values.map((type) {
                      final label = type.name[0].toUpperCase() + type.name.substring(1);
                      return ChoiceChip(
                        label: Text(label),
                        selected: selectedType == type,
                        onSelected: (v) => setSheetState(() => selectedType = v ? type : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(ctx).g_key_eligible_only),
                    value: onlyEligible,
                    onChanged: (v) => setSheetState(() => onlyEligible = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(ctx).g_key_high_value_only),
                    value: onlyHighValue,
                    onChanged: (v) => setSheetState(() => onlyHighValue = v),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.applyFilter(AirdropFilter(
                          types: selectedType != null ? [selectedType!] : null,
                          onlyEligible: onlyEligible ? true : null,
                          onlyHighValue: onlyHighValue ? true : null,
                        ));
                      },
                      child: Text(S.of(ctx).g_key_apply),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Notification settings dialog
  // ---------------------------------------------------------------------------

  void showNotificationSettings() {
    bool newAirdrops = true;
    bool eligibilityAlerts = true;
    bool deadlineReminders = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(S.of(ctx).g_key_notification_settings),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(ctx).g_key_new_airdrops),
                    value: newAirdrops,
                    onChanged: (v) => setDialogState(() => newAirdrops = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(ctx).g_key_eligibility_alerts),
                    value: eligibilityAlerts,
                    onChanged: (v) => setDialogState(() => eligibilityAlerts = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(ctx).g_key_deadline_reminders),
                    value: deadlineReminders,
                    onChanged: (v) => setDialogState(() => deadlineReminders = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.of(ctx).g_key_79),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.of(ctx).g_key_115),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
