// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';
import 'package:n42_wallet/features/airdrop/pages/airdrop_detail_page.dart';
import 'package:n42_wallet/features/airdrop/provider/airdrop_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:url_launcher/url_launcher.dart';

part 'airdrop_home_page_logic.dart';
part 'airdrop_home_page_widgets.dart';

/// 空投追踪首页
class AirdropHomePage extends StatefulWidget {
  final String walletAddress;

  const AirdropHomePage({
    super.key,
    required this.walletAddress,
  });

  @override
  State<AirdropHomePage> createState() => _AirdropHomePageState();
}

class _AirdropHomePageState extends State<AirdropHomePage>
    with SingleTickerProviderStateMixin, AirdropHomeLogicMixin, AirdropHomeWidgetsMixin {
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    provider = AirdropProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.initialize(widget.walletAddress);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airdrop Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilterSheet,
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: showNotificationSettings,
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Claimable'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Claimed'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: provider,
        builder: (context, _) {
          if (provider.loadState == AirdropLoadState.loading &&
              provider.airdrops.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.loadState == AirdropLoadState.error) {
            return buildErrorView(provider);
          }

          return Column(
            children: [
              buildStatsCard(provider),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    buildAirdropList(provider.airdrops, provider),
                    buildAirdropList(provider.claimableAirdrops, provider),
                    buildAirdropList(provider.upcomingAirdrops, provider),
                    buildAirdropList(provider.claimedAirdrops, provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
