import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'gift_catalog.dart';
import 'gift_economy.dart';
import 'gift_providers.dart';

/// 礼物面板（底部弹窗，TikTok 式金币计价）。顶部显示我的金币余额 + 充值入口，
/// 每个礼物标注金币单价；选中即按金币扣费并经 Matrix 广播（全房动画 + 主播收益）。
class GiftPickerSheet extends ConsumerWidget {
  const GiftPickerSheet({super.key, required this.roomId});

  final String roomId;

  static Future<void> show(BuildContext context, {required String roomId}) {
    return showAppSheet<void>(
      context,
      builder: (_) => GiftPickerSheet(roomId: roomId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColorTokens.of(context);
    final coins = ref.watch(myCoinsProvider(roomId)).asData?.value ?? 0;
    final economy = ref.read(giftEconomyProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '送礼物',
                style: AppTypography.title.copyWith(color: c.textPrimary),
              ),
              const Spacer(),
              // 金币余额 + 充值
              Icon(Icons.monetization_on, color: c.warning, size: 18),
              SizedBox(width: AppSpacing.space2),
              Text(
                '$coins',
                style: AppTypography.bodyStrong.copyWith(color: c.textPrimary),
              ),
              SizedBox(width: AppSpacing.space4),
              TextButton(
                onPressed: () => economy.recharge(100),
                child: const Text('充值'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space6),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space4,
            crossAxisSpacing: AppSpacing.space4,
            childAspectRatio: 0.78,
            children: [
              for (final g in kLiveGifts)
                _GiftTile(
                  gift: g,
                  onTap: () => _send(context, ref, economy, g),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _send(
    BuildContext context,
    WidgetRef ref,
    LiveGiftEconomy economy,
    LiveGift gift,
  ) async {
    try {
      await economy.sendGift(roomId, gift.id);
      if (context.mounted) Navigator.of(context).pop();
    } on GiftInsufficientCoins {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('金币不足，请先充值')),
        );
    }
  }
}

class _GiftTile extends StatelessWidget {
  const _GiftTile({required this.gift, required this.onTap});

  final LiveGift gift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Container(
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(gift.emoji, style: const TextStyle(fontSize: 28)),
            SizedBox(height: AppSpacing.space2),
            Text(
              gift.label,
              style: AppTypography.captionSm.copyWith(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: c.warning, size: 11),
                SizedBox(width: AppSpacing.space2),
                Text(
                  '${gift.coinPrice}',
                  style: AppTypography.captionSm.copyWith(color: c.warning),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
