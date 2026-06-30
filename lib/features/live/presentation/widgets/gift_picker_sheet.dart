import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'gift_catalog.dart';

/// 礼物选择面板（底部弹窗）。选中一个礼物即回调其 id 并关闭。
/// 纯视觉礼物，无真实价值，故不显示价格/余额。
class GiftPickerSheet extends StatelessWidget {
  const GiftPickerSheet({super.key, required this.onPick});

  final ValueChanged<String> onPick;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onPick,
  }) {
    return showAppSheet<void>(
      context,
      builder: (_) => GiftPickerSheet(onPick: onPick),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
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
          Text(
            '送礼物',
            style: AppTypography.title.copyWith(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.space6),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.space4,
            crossAxisSpacing: AppSpacing.space4,
            childAspectRatio: 0.85,
            children: [
              for (final g in kLiveGifts)
                _GiftTile(
                  gift: g,
                  onTap: () {
                    Navigator.of(context).pop();
                    onPick(g.id);
                  },
                ),
            ],
          ),
        ],
      ),
    );
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
          ],
        ),
      ),
    );
  }
}
