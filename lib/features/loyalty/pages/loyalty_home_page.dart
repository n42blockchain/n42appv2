// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';
import 'package:n42_wallet/features/loyalty/pages/history_page.dart';
import 'package:n42_wallet/features/loyalty/pages/rewards_page.dart';
import 'package:n42_wallet/features/loyalty/pages/tasks_page.dart';
import 'package:n42_wallet/features/loyalty/provider/loyalty_provider.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'loyalty_home_page_logic.dart';
part 'loyalty_home_page_widgets.dart';
part 'loyalty_home_page_sections.dart';

/// 积分系统首页
class LoyaltyHomePage extends StatefulWidget {
  final String walletAddress;

  const LoyaltyHomePage({
    super.key,
    required this.walletAddress,
  });

  @override
  State<LoyaltyHomePage> createState() => _LoyaltyHomePageState();
}

class _LoyaltyHomePageState extends State<LoyaltyHomePage>
    with SingleTickerProviderStateMixin, _LogicMixin, _WidgetsMixin, _SectionsMixin {
  @override
  late final TabController _tabController;
  @override
  late final LoyaltyProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = LoyaltyProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.initialize(widget.walletAddress);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_loyalty_title,
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          final provider = _provider;
          if (provider.loadState == LoyaltyLoadState.loading &&
              provider.account.totalPoints == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildPointsCard(context, provider),
                ),
                SliverToBoxAdapter(
                  child: _buildCheckInCard(context, provider),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickActions(context, provider),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      unselectedLabelColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                      indicatorColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      tabs: [
                        Tab(text: S.of(context).g_key_loyalty_tasks),
                        Tab(text: S.of(context).g_key_loyalty_rewards),
                        Tab(text: S.of(context).g_key_loyalty_history),
                      ],
                    ),
                    AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.backGroundColor.name,
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                TasksPage(tasks: provider.tasks, provider: _provider),
                RewardsPage(
                  rewards: provider.rewards,
                  availablePoints: provider.account.availablePoints,
                  provider: _provider,
                ),
                HistoryPage(history: provider.history),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Tab Bar 吸顶代理
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
