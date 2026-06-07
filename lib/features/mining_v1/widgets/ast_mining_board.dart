import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class ASTMiningBoard extends StatelessWidget {
  final int astNum;

  const ASTMiningBoard({super.key, required this.astNum});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.space12),
          _buildBoard(context),
          SizedBox(height: ScreenUtil().setWidth(72)),
          _buildItems(context),
          SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  String _getLevelText(BuildContext context) => switch (astNum) {
    50 => S.of(context).g_mining_key_62,
    100 => S.of(context).g_mining_key_61,
    _ => S.of(context).g_mining_key_63,
  };

  String _getTimes() => astNum == 50 ? "70" : "15";

  Widget _buildBoard(BuildContext context) {
    final bigImage = "assets/mining/ast_$astNum.png";
    final levelText = _getLevelText(context);
    final times = _getTimes();
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
                    style: AppTypography.headline.copyWith(color: AppColorTokens.of(context).textPrimary),
                  ),
                  SizedBox(height: AppSpacing.space12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$astNum",
                        style: TextStyle(
                          color: AppColorTokens.of(context).textPrimary,
                          fontSize: ScreenUtil().setSp(104),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CoinType.N.name,
                        style: TextStyle(
                          color: AppColorTokens.of(context).textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.space12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColorTokens.of(context).brand,
                          borderRadius: AppRadius.brSm,
                        ),
                        padding: EdgeInsets.all(AppSpacing.space2),
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(20),
                        ),
                      ),
                      SizedBox(width: AppSpacing.space4),
                      Expanded(
                        child: Text(
                          S.current.g_mining_key_32,
                          style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(36)),
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

  Widget _buildItems(BuildContext context) {
    final (maxReward, dailyLimit, rewardDistribution) = switch (astNum) {
      50 => (
        "4.5",
        S.of(context).g_mining_key_69,
        S.of(context).g_mining_key_71("0.5", "20,000"),
      ),
      100 => (
        "12",
        S.of(context).g_mining_key_70,
        S.of(context).g_mining_key_71("0.5", "1,500"),
      ),
      _ => (
        "75",
        S.of(context).g_mining_key_70,
        S.of(context).g_mining_key_71("0.625", "300"),
      ),
    };

    final divider = Divider(
      color: AppColorTokens.of(context).border,
      indent: 1,
      endIndent: 1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(
          context,
          "assets/mining/medal-star.png",
          S.current.g_mining_key_33,
          "$maxReward ${CoinType.N.name}",
        ),
        divider,
        _buildItem(
          context,
          "assets/mining/flash.png",
          S.current.g_mining_key_36,
          S.of(context).g_mining_key_72,
        ),
        divider,
        _buildItem(
          context,
          "assets/mining/star.png",
          S.current.g_mining_key_35,
          dailyLimit,
        ),
        divider,
        _buildItem(
          context,
          "assets/mining/grid-lock.png",
          S.current.g_mining_key_34,
          rewardDistribution,
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    String iconPath,
    String action,
    String desc,
  ) {
    final textStyle = AppTypography.caption.copyWith(color: AppColorTokens.of(context).textPrimary);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).brand,
              borderRadius: AppRadius.brSm,
            ),
            width: ScreenUtil().setWidth(44),
            height: ScreenUtil().setWidth(44),
            child: Center(
              child: Image.asset(
                iconPath,
                width: ScreenUtil().setWidth(24),
                height: ScreenUtil().setWidth(24),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(child: Text(action, style: textStyle)),
          Expanded(child: Text(desc, style: textStyle, maxLines: 2)),
          Image.asset(
            "assets/mining/duihao.png",
            width: ScreenUtil().setWidth(20),
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String iconPath, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff373739) : const Color(0xffEDEFF2),
        borderRadius: AppRadius.brXl,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: ScreenUtil().setWidth(24),
            fit: BoxFit.cover,
            color: AppColorTokens.of(context).textPrimary,
          ),
          SizedBox(width: AppSpacing.space4),
          Text(
            text,
            style: AppTypography.caption.copyWith(color: AppColorTokens.of(context).textPrimary),
          ),
        ],
      ),
    );
  }
}
