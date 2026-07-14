// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page.dart';
import 'package:n42_wallet/features/airdrop/pages/airdrop_home_page.dart';
import 'package:n42_wallet/features/earn/provider/earn_provider.dart';
import 'package:n42_wallet/features/loyalty/pages/loyalty_home_page.dart';
import 'package:n42_wallet/features/staking/pages/staking_home_page.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/hardware_wallet_page.dart';
import 'package:n42_wallet/features/mining_v2/pages/mining_today_v2.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_select_page.dart';
import 'package:n42_wallet/features/wallet/pages/perps/perps_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_logic.dart';
import 'package:n42_wallet/features/earn/pages/earn_page_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;

/// 页面区域 mixin：主要功能区、快捷工具
mixin EarnPageSectionsMixin
    on ConsumerState<EarnPage>, EarnPageLogicMixin, EarnPageWidgetsMixin {
  // ──────────────────────────────────────────────────────────────────────────
  //  主要功能区（含 Mining + Swap）
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildMainFeatures(BuildContext context, EarnState earnState) {
    final maxApyStr = earnState.apyLoading
        ? '...'
        : earnState.maxApy.toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_earn_more,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          // 大功能卡片 — 横向滚动
          SizedBox(
            height: ScreenUtil().setWidth(230),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildFeatureCard(
                  context,
                  title: S.of(context).g_key_stake_stake,
                  subtitle: S.of(context).g_key_earn_up_to_apy(maxApyStr),
                  icon: Icons.account_balance_rounded,
                  gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                  badge: 'HOT',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StakingHomePage()),
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                buildFeatureCard(
                  context,
                  title: S.of(context).g_key_earn_mining,
                  subtitle: S.of(context).g_key_earn_node_mining_desc,
                  icon: Icons.developer_board_rounded,
                  gradientColors: const [Color(0xFFf7971e), Color(0xFFffd200)],
                  badge: 'N42',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MiningTodayV2()),
                  ),
                ),
                // iOS 商店审核对 DEX/交易所类功能审查严格(Guideline 3.1.5),
                // 该卡片(Buy N42)在 iOS 上隐藏,仅 Android 保留。
                if (AppConfig.swapFeatureEnabled) ...[
                  SizedBox(width: AppSpacing.space4),
                  buildFeatureCard(
                    context,
                    title: S.of(context).g_key_earn_swap,
                    subtitle: S.of(context).g_key_earn_buy_n_desc,
                    icon: Icons.currency_exchange_rounded,
                    gradientColors: const [
                      Color(0xFF4776E6),
                      Color(0xFF8E54E9),
                    ],
                    onTap: () => navigateToSwap(context),
                  ),
                ],
                SizedBox(width: AppSpacing.space4),
                buildFeatureCard(
                  context,
                  title: S.of(context).g_key_bridge_title,
                  subtitle: S.of(context).g_key_earn_cross_chain,
                  icon: Icons.swap_horiz_rounded,
                  gradientColors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BridgeHomePage()),
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                buildFeatureCard(
                  context,
                  title: S.of(context).g_key_airdrop_title,
                  subtitle: S.of(context).g_key_earn_claim_free,
                  icon: Icons.card_giftcard_rounded,
                  gradientColors: const [Color(0xFF00897B), Color(0xFF43A047)],
                  badge: 'LIVE',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AirdropHomePage(walletAddress: walletAddress),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                buildFeatureCard(
                  context,
                  title: S.of(context).g_key_loyalty_title,
                  subtitle: S.of(context).g_key_earn_daily_bonus,
                  icon: Icons.workspace_premium_rounded,
                  gradientColors: const [Color(0xFF1565C0), Color(0xFFF9A825)],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          LoyaltyHomePage(walletAddress: walletAddress),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  快捷工具区（4 个工具：Ledger / Gas / Batch / Burn）
  // ──────────────────────────────────────────────────────────────────────────

  Widget buildQuickTools(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.all(AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_earn_quick_tools,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space2,
              vertical: AppSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).bgSurface,
              borderRadius: AppRadius.brLg,
              border: Border.all(
                color: AppColorTokens.of(context).border.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                buildToolItem(
                  context,
                  icon: Icons.security_rounded,
                  label: s.g_key_earn_ledger,
                  color: const Color(0xFF607D8B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HardwareWalletPage(),
                    ),
                  ),
                ),
                buildToolItem(
                  context,
                  icon: Icons.local_gas_station_rounded,
                  label: s.g_key_earn_gas,
                  color: const Color(0xFFE91E63),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GasTrackerPage()),
                  ),
                ),
                buildToolItem(
                  context,
                  icon: Icons.send_rounded,
                  label: s.g_key_earn_batch,
                  color: const Color(0xFF00BCD4),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BatchTransferSelectPage(),
                    ),
                  ),
                ),
                buildToolItem(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: s.g_key_earn_burn,
                  color: const Color(0xFFFF5722),
                  onTap: () => showBurnNftTip(context),
                ),
                buildToolItem(
                  context,
                  icon: Icons.candlestick_chart_rounded,
                  label: s.g_key_earn_perps,
                  color: const Color(0xFF3F51B5),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PerpsPage(walletAddress: walletAddress),
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
}
