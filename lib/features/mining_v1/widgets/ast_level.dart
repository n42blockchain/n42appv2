import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class AstLevel extends StatelessWidget {
  final int astNum;

  const AstLevel({super.key, required this.astNum});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space12,
      ),
      child: _buildBoard(context),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final bigImage = "assets/mining/ast_$astNum.png";
    final levelText = switch (astNum) {
      50 => S.of(context).g_mining_key_62,
      100 => S.of(context).g_mining_key_61,
      _ => S.of(context).g_mining_key_63,
    };
    final times = astNum == 50 ? "70" : "15";
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              bigImage,
              width: ScreenUtil().setWidth(216),
              fit: BoxFit.cover,
            ),
            SizedBox(width: ScreenUtil().setWidth(34)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelText,
                    style: AppTypography.headline.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$astNum",
                        style: AppTypography.displayLg.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CoinType.N.name,
                        style: AppTypography.headline.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.space12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColorTokens.of(context).brand,
                          borderRadius: AppRadius.brSm,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(20),
                        ),
                      ),
                      SizedBox(width: AppSpacing.space4),
                      Expanded(
                        child: Text(
                          S.current.g_mining_key_32,
                          style: AppTypography.caption.copyWith(
                            color: AppColorTokens.of(context).textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(72)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTag(
              context,
              "assets/mining/icon_full_node.png",
              S.of(context).g_mining_key_64,
            ),
            SizedBox(width: AppSpacing.space8),
            _buildTag(
              context,
              "assets/mining/lock_time.png",
              "$times ${S.of(context).g_mining_key_65}",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String iconAsset, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagBg = isDark ? const Color(0xFF373739) : const Color(0xFFEDEFF2);
    final textColor = AppColorTokens.of(context).textPrimary;

    return Container(
      decoration: BoxDecoration(color: tagBg, borderRadius: AppRadius.brXl),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconAsset,
            width: ScreenUtil().setWidth(24),
            fit: BoxFit.cover,
            color: textColor,
          ),
          SizedBox(width: AppSpacing.space4),
          Text(label, style: AppTypography.caption.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
