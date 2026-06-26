import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/red_packet_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/red_packet_entity.dart';
import 'red_packet_detail_page.dart';

/// 红包历史记录页
///
/// 两个 Tab：发出的 / 收到的
class RedPacketHistoryPage extends StatefulWidget {
  final String? roomId;
  final String userId;

  const RedPacketHistoryPage({
    super.key,
    this.roomId,
    required this.userId,
  });

  @override
  State<RedPacketHistoryPage> createState() => _RedPacketHistoryPageState();
}

class _RedPacketHistoryPageState extends State<RedPacketHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RedPacketEntity> _allRedPackets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final service = getIt<IRedPacketService>();
      final history = await service.getRedPacketHistory(
        roomId: widget.roomId,
        userId: widget.userId,
      );
      if (mounted) {
        setState(() {
          _allRedPackets = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('RedPacketHistoryPage._loadHistory error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<RedPacketEntity> get _sentPackets =>
      _allRedPackets.where((rp) => rp.senderId == widget.userId).toList();

  List<RedPacketEntity> get _receivedPackets =>
      _allRedPackets.where((rp) =>
        rp.claims.any((c) => c.userId == widget.userId),
      ).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.redPacketHistory ?? 'Red Packet History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n?.redPacketSent ?? 'Sent'),
            Tab(text: l10n?.redPacketReceived ?? 'Received'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.textSecondary,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_sentPackets, isDark, isSent: true),
                _buildList(_receivedPackets, isDark, isSent: false),
              ],
            ),
    );
  }

  Widget _buildList(List<RedPacketEntity> packets, bool isDark, {required bool isSent}) {
    if (packets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No red packets yet',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: packets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final rp = packets[index];
        return _buildRedPacketCard(rp, isDark, isSent: isSent);
      },
    );
  }

  Widget _buildRedPacketCard(RedPacketEntity rp, bool isDark, {required bool isSent}) {
    final l10n = S.of(context);
    final statusText = switch (rp.lifecycle) {
      RedPacketLifecycle.active => '${rp.claimedCount}/${rp.totalCount}',
      RedPacketLifecycle.completed => l10n?.redPacketClaimed ?? 'Claimed',
      RedPacketLifecycle.expired => l10n?.redPacketExpired ?? 'Expired',
    };
    final statusColor = switch (rp.lifecycle) {
      RedPacketLifecycle.active => AppColors.primary,
      RedPacketLifecycle.completed => AppColors.success,
      RedPacketLifecycle.expired => context.textTertiary,
    };

    return Card(
      color: context.surfaceColor,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('🧧', style: TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          rp.greeting.isNotEmpty ? rp.greeting : 'Red Packet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          '${rp.totalAmount.toStringAsFixed(2)} ${rp.token}  ·  '
          '${rp.createdAt.month}/${rp.createdAt.day} '
          '${rp.createdAt.hour.toString().padLeft(2, '0')}:'
          '${rp.createdAt.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 12,
            color: context.textTertiary,
          ),
        ),
        trailing: Text(
          statusText,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => RedPacketDetailPage(
                senderName: rp.senderName,
                senderAvatar: rp.senderAvatar,
                greeting: rp.greeting,
                claimedAmount: rp.claimedAmount.toStringAsFixed(2),
                token: rp.token,
                isClaimed: rp.claims.any((c) => c.userId == widget.userId),
                claimers: rp.claims
                    .map((c) => RedPacketClaimer(
                          name: c.userName,
                          amount: c.amount.toStringAsFixed(2),
                          claimTime: '${c.claimedAt.hour.toString().padLeft(2, '0')}:'
                              '${c.claimedAt.minute.toString().padLeft(2, '0')}',
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
