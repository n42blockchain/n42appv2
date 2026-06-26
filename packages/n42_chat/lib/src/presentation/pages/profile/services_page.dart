import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../n42_chat.dart';
import '../../blocs/transfer/transfer_bloc.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/chat/contact_card_select_sheet.dart';
import '../transfer/receive_page.dart';
import '../transfer/transfer_page.dart';
import 'n42_bean_page.dart';

/// 服务页面
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  Future<void> _openTransfer(BuildContext context) async {
    final l10n = S.of(context);
    final isDark = context.isDarkMode;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactCardSelectSheet(
        isDark: isDark,
        selectContactText: l10n?.chatSelectContact ?? 'Select Contact',
        searchContactHintText: l10n?.chatSearchContactHint ?? 'Search contacts',
        noContactsFoundText:
            l10n?.contactNoContactsFound ?? 'No contacts found',
      ),
    );

    if (result == null || !context.mounted) {
      return;
    }

    final targetUserId = result['id'] as String?;
    final fallbackName = result['name'] as String?;
    if (targetUserId == null || targetUserId.isEmpty) {
      return;
    }

    try {
      final contactRepository = getIt<IContactRepository>();
      final roomId = await contactRepository.startDirectChat(targetUserId);
      final contact = await contactRepository.getContactById(targetUserId);

      if (!context.mounted) {
        return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TransferBloc>(),
            child: TransferPage(
              roomId: roomId,
              recipientAddress: contact?.walletAddress,
              recipientName:
                  contact?.effectiveDisplayName ?? fallbackName ?? targetUserId,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.blocTransferFailed ?? 'Transfer failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(title: S.of(context)?.profileServices ?? 'Services'),
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
              color: AppColors.primary,
              label: S.of(context)?.commonTransfer ?? 'Transfer',
              cardColor: cardColor,
              textColor: textColor,
              onTap: () => _openTransfer(context),
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
                    content: Text(
                      S.of(context)?.chatSendRedPacketInChat ??
                          'Please send red packet in chat',
                    ),
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
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<TransferBloc>(),
                      child: const ReceivePage(),
                    ),
                  ),
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
                if (N42Chat.invokeOpenWallet()) return;
                // 宿主未注册 handler（例如 chat 独立运行时），降级为信息提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallet is managed in the main app'),
                    duration: Duration(seconds: 2),
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
                if (N42Chat.invokeOpenCardPack()) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card Pack is managed in the main app'),
                    duration: Duration(seconds: 2),
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
            style: TextStyle(fontSize: 12, color: textColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
