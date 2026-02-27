// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page_logic.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page_widgets.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Staking 首页
///
/// 显示支持的质押协议列表和用户的质押仓位
class StakingHomePage extends StatefulWidget {
  final Map<StakingChainType, String>? userAddresses;

  const StakingHomePage({
    super.key,
    this.userAddresses,
  });

  @override
  State<StakingHomePage> createState() => _StakingHomePageState();
}

class _StakingHomePageState extends State<StakingHomePage>
    with
        SingleTickerProviderStateMixin,
        StakingHomePageLogicMixin,
        StakingHomePageWidgetsMixin {
  @override
  void initState() {
    super.initState();
    initLogic(this);
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_stake_title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab 栏
            buildTabBar(context),

            // Tab 内容
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  buildProtocolsTab(context),
                  buildPositionsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
