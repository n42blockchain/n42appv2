import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
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
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(
              ScreenUtil().setWidth(16))),
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(40)),
      child: _buildBoard(context),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final String bigImage = "assets/mining/ast_$astNum.png";
    String levelText;
    switch (astNum) {
      case 50:
        levelText = S.of(context).g_mining_key_62;
      case 100:
        levelText = S.of(context).g_mining_key_61;
      default:
        levelText = S.of(context).g_mining_key_63;
    }
    final String times = astNum == 50 ? "70" : "15";
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              bigImage,
              width: ScreenUtil().setWidth(216),
              // height: 108 / 375 * MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: ScreenUtil().setWidth(34),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelText,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(32)),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$astNum",
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontSize:ScreenUtil().setSp(104),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CoinType.N.name,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontWeight: FontWeight.bold,
                            fontSize:ScreenUtil().setSp(32)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainBlueColor.name),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          "assets/mining/lock.png",
                          width: ScreenUtil().setWidth(20),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(12),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          // "Unlock Period: 12 months",
                          S.current.g_mining_key_32,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor.name),
                              fontSize:ScreenUtil().setSp(24)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: ScreenUtil().setWidth(72),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTag(context, "assets/mining/icon_full_node.png", S.of(context).g_mining_key_64),
            SizedBox(width: ScreenUtil().setWidth(32)),
            _buildTag(context, "assets/mining/lock_time.png", "$times ${S.of(context).g_mining_key_65}"),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String iconAsset, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagBg = isDark ? const Color(0xff373739) : const Color(0xffEDEFF2);
    final textColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);

    return Container(
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
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
          SizedBox(width: ScreenUtil().setWidth(12)),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: ScreenUtil().setSp(24)),
          ),
        ],
      ),
    );
  }
}
