import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// 订单与卡包页面
class OrdersAndCardsPage extends StatelessWidget {
  const OrdersAndCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context)?.profileOrdersAndCards ?? 'Orders & Cards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
              isDark: isDark,
              icon: Icons.receipt_long_outlined,
              title: S.of(context)?.profileNoOrders ?? 'No orders',
              description: S.of(context)?.profileOrdersDesc ??
                  'Your orders will appear here',
            ),
            // 卡包 Tab
            _buildEmptyTab(
              context,
              isDark: isDark,
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
    required bool isDark,
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
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
