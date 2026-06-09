import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

class MiningBoardWidget extends StatelessWidget {
  final int nNum;
  final int cReward;

  const MiningBoardWidget({
    super.key,
    required this.nNum,
    required this.cReward,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space8,
              vertical: AppSpacing.space6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorTokens.of(context).brand,
                  AppColorTokens.of(context).brand.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(20)),
                topRight: Radius.circular(ScreenUtil().setWidth(20)),
              ),
            ),
            child: Text(
              S.of(context).g_mining_key_62, // "Entry"
              style: AppTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.space8),
            child: Column(
              children: [
                _buildBoard(context),
                SizedBox(height: AppSpacing.space12),
                _buildItems(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: ScreenUtil().setWidth(180),
          height: ScreenUtil().setWidth(180),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4FACFE).withValues(alpha: 0.15),
                const Color(0xFF00F2FE).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.brMd,
          ),
          padding: EdgeInsets.all(AppSpacing.space4),
          child: Image.asset("assets/mining/ast_50.png", fit: BoxFit.contain),
        ),
        SizedBox(width: AppSpacing.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "$nNum",
                    style: AppTypography.displayLg.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space2),
                  Text(
                    CoinType.N.name,
                    style: AppTypography.body.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.space6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColorTokens.of(
                          context,
                        ).brand.withValues(alpha: 0.08),
                  borderRadius: AppRadius.brMd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(28),
                      height: ScreenUtil().setWidth(28),
                      decoration: BoxDecoration(
                        color: AppColorTokens.of(context).brand,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.space2),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).g_mining_unlock_period,
                            style: AppTypography.captionSm.copyWith(
                              color: AppColorTokens.of(context).textSubtitle,
                            ),
                          ),
                          Text(
                            S.of(context).g_mining_unlockable_anytime,
                            style: AppTypography.caption.copyWith(
                              color: AppColorTokens.of(context).textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rewardPerVerification =
        "${toEther('$cReward', 9)} ${CoinType.N.name}";

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : AppColorTokens.of(context).textTertiary)
            .withValues(alpha: 0.03),
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            context,
            "assets/mining/medal-star.png",
            S.current.g_mining_key_33,
            rewardPerVerification,
            const Color(0xFF5C6BC0),
          ),
          _buildDivider(context),
          _buildItem(
            context,
            "assets/mining/flash.png",
            S.current.g_mining_key_36,
            S.of(context).g_mining_key_72,
            const Color(0xFF26A69A),
          ),
          _buildDivider(context),
          _buildItem(
            context,
            "assets/mining/grid-lock.png",
            S.current.g_mining_key_34,
            S.current.g_mining_key_74,
            const Color(0xFFFF7043),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: AppColorTokens.of(context).border.withValues(alpha: 0.5),
      height: 1,
      indent: ScreenUtil().setWidth(70),
      endIndent: ScreenUtil().setWidth(16),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String iconPath,
    String action,
    String desc,
    Color iconBgColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.space6,
        horizontal: AppSpacing.space4,
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.brMd,
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: ScreenUtil().setWidth(24),
                height: ScreenUtil().setWidth(24),
                fit: BoxFit.contain,
                color: iconBgColor,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            flex: 2,
            child: Text(
              action,
              style: AppTypography.caption.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    desc,
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.of(context).textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: AppSpacing.space2),
                Container(
                  width: ScreenUtil().setWidth(24),
                  height: ScreenUtil().setWidth(24),
                  decoration: BoxDecoration(
                    color: AppColorTokens.of(
                      context,
                    ).success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: ScreenUtil().setWidth(16),
                    color: AppColorTokens.of(context).success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
