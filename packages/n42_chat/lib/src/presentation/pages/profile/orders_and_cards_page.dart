import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/red_packet_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/red_packet_entity.dart';
import '../../../n42_chat.dart';

/// Activity and card-pack hub used by the Me tab.
///
/// Orders are backed by the existing red-packet ledger instead of a static
/// empty placeholder. Cards delegate to the wallet host where card ownership
/// lives, while standalone chat presents an explicit unavailable state.
class OrdersAndCardsPage extends StatefulWidget {
  const OrdersAndCardsPage({super.key});

  @override
  State<OrdersAndCardsPage> createState() => _OrdersAndCardsPageState();
}

class _OrdersAndCardsPageState extends State<OrdersAndCardsPage> {
  List<RedPacketEntity> _activity = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    if (mounted) setState(() => _loading = true);
    try {
      final activity = await getIt<IRedPacketService>().getRedPacketHistory();
      activity.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _activity = activity;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

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
            icon: Icon(AppIcons.back, color: context.textPrimary, size: 20),
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
              Tab(text: S.of(context)?.profileOrders ?? 'Activity'),
              Tab(text: S.of(context)?.profileCardPack ?? 'Card Pack'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildActivity(context), _buildCards(context)],
        ),
      ),
    );
  }

  Widget _buildActivity(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_activity.isEmpty) {
      return _buildEmptyTab(
        context,
        icon: Icons.receipt_long_outlined,
        title: S.of(context)?.profileNoOrders ?? 'No activity yet',
        description:
            S.of(context)?.profileOrdersDesc ?? 'Sent red packets appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivity,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _activity.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 72, color: context.dividerColor),
        itemBuilder: (context, index) {
          final packet = _activity[index];
          return ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE64340).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_giftcard, color: Color(0xFFE64340)),
            ),
            title: Text(
              packet.greeting.isEmpty ? 'Red Packet' : packet.greeting,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${_statusLabel(packet.lifecycle)} · '
              '${packet.claimedCount}/${packet.totalCount} claimed',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${packet.totalAmount.toStringAsFixed(2)} ${packet.token}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  _dateLabel(packet.createdAt),
                  style: TextStyle(color: context.textSecondary, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 64,
              color: context.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cards and passes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wallet cards, coupons, and passes are managed by the main app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (N42Chat.invokeOpenCardPack()) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card Pack requires the main app'),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Open Card Pack'),
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
    return RefreshIndicator(
      onRefresh: _loadActivity,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Icon(icon, size: 64, color: context.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  String _statusLabel(RedPacketLifecycle lifecycle) => switch (lifecycle) {
    RedPacketLifecycle.active => 'Active',
    RedPacketLifecycle.completed => 'Completed',
    RedPacketLifecycle.expired => 'Expired',
  };

  String _dateLabel(DateTime value) =>
      '${value.month}/${value.day}/${value.year}';
}
