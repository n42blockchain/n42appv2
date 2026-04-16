import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../transfer/receive_page.dart';
import 'n42_bean_page.dart';

/// 服务页面
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.profileServices ?? 'Services',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildServiceItem(
              context,
              icon: Icons.monetization_on_outlined,
              color: const Color(0xFFFF9500),
              label: S.of(context)?.profileN42Bean ?? 'N42 Bean',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const N42BeanPage()),
                );
              },
            ),
            _buildServiceItem(
              context,
              icon: Icons.swap_horiz,
              color: const Color(0xFF07C160),
              label: S.of(context)?.commonTransfer ?? 'Transfer',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                // 通用转账入口，需要在聊天上下文中使用
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context)?.commonFeatureComingSoon(S.of(context)?.commonTransfer ?? 'Transfer') ?? 'Transfer coming soon'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildServiceItem(
              context,
              icon: Icons.card_giftcard,
              color: const Color(0xFFFF3B30),
              label: S.of(context)?.profileRedPacket ?? 'Red Packet',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context)?.chatSendRedPacketInChat ?? 'Please send red packet in chat'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildServiceItem(
              context,
              icon: Icons.qr_code,
              color: const Color(0xFF007AFF),
              label: S.of(context)?.commonPayment ?? 'Payment',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ReceivePage()),
                );
              },
            ),
            _buildServiceItem(
              context,
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF5856D6),
              label: S.of(context)?.profileWallet ?? 'Wallet',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context)?.commonFeatureComingSoon(S.of(context)?.profileWallet ?? 'Wallet') ?? 'Wallet coming soon'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildServiceItem(
              context,
              icon: Icons.credit_card,
              color: const Color(0xFF34C759),
              label: S.of(context)?.profileCardPack ?? 'Card Pack',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context)?.commonFeatureComingSoon(S.of(context)?.profileCardPack ?? 'Card Pack') ?? 'Card Pack coming soon'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required Color cardColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
