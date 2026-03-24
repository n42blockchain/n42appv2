// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_logic.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_widgets.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_sections.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_products.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;

/// Earn 页面
///
/// 展示所有收益相关功能：Stake, Bridge, Mining, Swap, Airdrop, Rewards 等。
/// 通过 [earnProvider] 获取三链实时 APY 和用户活跃质押仓位。
class EarnPage extends ConsumerStatefulWidget {
  const EarnPage({super.key});

  @override
  ConsumerState<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends ConsumerState<EarnPage>
    with
        EarnPageLogicMixin,
        EarnPageWidgetsMixin,
        EarnPageSectionsMixin,
        EarnPageProductsMixin {
  @override
  void initState() {
    super.initState();
    // 初始化时加载多链质押仓位
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      loadStakedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final earnState = ref.watch(earnProvider);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            loadStakedData();
            await ref.read(earnProvider.notifier).refreshApys();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 顶部栏
              SliverToBoxAdapter(
                child: AppHomeTopBar(
                  title: S.of(context).g_key_earn_title,
                  onLeftImageClick: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onLeftImageUri: "assets/img/menu.png",
                ),
              ),

              // 总收益卡片
              SliverToBoxAdapter(child: buildEarningsCard(context, earnState)),

              // 主要功能区
              SliverToBoxAdapter(child: buildMainFeatures(context, earnState)),

              // 快捷工具区
              SliverToBoxAdapter(child: buildQuickTools(context)),

              // 已质押/活跃产品（始终显示，空时展示引导入口）
              SliverToBoxAdapter(
                child: buildActiveProducts(context, earnState),
              ),

              // 推荐产品（实时 APY）
              SliverToBoxAdapter(
                child: buildRecommendedProducts(context, earnState),
              ),

              // 底部间距
              SliverToBoxAdapter(
                child: SizedBox(height: ScreenUtil().setWidth(120)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
