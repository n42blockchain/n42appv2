import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';

/// 订单与卡包页面
class OrdersAndCardsPage extends StatelessWidget {
  const OrdersAndCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              AppIcons.back,
              color: context.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context)?.profileOrdersAndCards ?? 'Orders & Cards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: context.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: S.of(context)?.profileOrders ?? 'Orders'),
              Tab(text: S.of(context)?.profileCardPack ?? 'Card Pack'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 订单 Tab
            _buildEmptyTab(
              context,
              icon: Icons.receipt_long_outlined,
              title: S.of(context)?.profileNoOrders ?? 'No orders',
              description: S.of(context)?.profileOrdersDesc ??
                  'Your orders will appear here',
            ),
            // 卡包 Tab
            _buildEmptyTab(
              context,
              icon: Icons.credit_card_outlined,
              title: S.of(context)?.profileNoCards ?? 'No cards',
              description: S.of(context)?.profileCardsDesc ??
                  'Your cards and coupons will appear here',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTab(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
