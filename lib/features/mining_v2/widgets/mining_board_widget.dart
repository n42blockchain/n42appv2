import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
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
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(24),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ),
                  AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  ).withValues(alpha: 0.8),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            child: Column(
              children: [
                _buildBoard(context),
                SizedBox(height: ScreenUtil().setWidth(40)),
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
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          ),
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          child: Image.asset("assets/mining/ast_50.png", fit: BoxFit.contain),
        ),
        SizedBox(width: ScreenUtil().setWidth(30)),
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
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                      fontSize: ScreenUtil().setSp(80),
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(6)),
                  Text(
                    CoinType.N.name,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil().setSp(28),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(24)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(10),
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                    ScreenUtil().setWidth(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(28),
                      height: ScreenUtil().setWidth(28),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(6),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).g_mining_unlock_period,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name,
                              ),
                              fontSize: ScreenUtil().setSp(20),
                            ),
                          ),
                          Text(
                            S.of(context).g_mining_unlockable_anytime,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name,
                              ),
                              fontSize: ScreenUtil().setSp(22),
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
        color: (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
      color: AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.itemLineColor.name,
      ).withValues(alpha: 0.5),
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
        vertical: ScreenUtil().setWidth(24),
        horizontal: ScreenUtil().setWidth(16),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
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
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            flex: 2,
            child: Text(
              action,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
                fontSize: ScreenUtil().setSp(24),
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
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Container(
                  width: ScreenUtil().setWidth(24),
                  height: ScreenUtil().setWidth(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: ScreenUtil().setWidth(16),
                    color: const Color(0xFF4CAF50),
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
