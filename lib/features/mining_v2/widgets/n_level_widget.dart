import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

class NLevelWidget extends StatelessWidget {
  final int nNum;

  const NLevelWidget({super.key, required this.nNum});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemBgColor.name,
        ),
        borderRadius: AppRadius.brMd,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: ScreenUtil().setWidth(6),
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
                  ).withValues(alpha: 0.6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(20)),
                topRight: Radius.circular(ScreenUtil().setWidth(20)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            child: _buildBoard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    const String bigImage = "assets/mining/ast_50.png";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: ScreenUtil().setWidth(160),
          height: ScreenUtil().setWidth(160),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4FACFE).withValues(alpha: 0.12),
                const Color(0xFF00F2FE).withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.brMd,
          ),
          padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
          child: Image.asset(bigImage, fit: BoxFit.contain),
        ),
        SizedBox(width: ScreenUtil().setWidth(24)),
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
                      fontSize: ScreenUtil().setSp(72),
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(6)),
                  Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(4)),
                    child: Text(
                      CoinType.N.name,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                        fontWeight: FontWeight.w600,
                        fontSize: ScreenUtil().setSp(24),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(20)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(14),
                  vertical: ScreenUtil().setWidth(10),
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ).withValues(alpha: 0.06),
                  borderRadius: AppRadius.brSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(26),
                      height: ScreenUtil().setWidth(26),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(14),
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
                              fontSize: ScreenUtil().setSp(18),
                            ),
                          ),
                          Text(
                            S.of(context).g_mining_unlockable_anytime,
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name,
                              ),
                              fontSize: ScreenUtil().setSp(20),
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
}
