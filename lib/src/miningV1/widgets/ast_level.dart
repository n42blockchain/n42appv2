import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class AstLevel extends StatelessWidget {
  final int astNum;

  const AstLevel({Key? key, required this.astNum}) : super(key: key);

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

  _buildBoard(BuildContext context) {
    String bigImage = "assets/mining/ast_$astNum.png";
    String levelText = astNum == 50
        ? S.of(context).g_mining_key_62
        : astNum == 100
        ? S.of(context).g_mining_key_61
        : S.of(context).g_mining_key_63;
    String times = astNum == 50 ? "70" : astNum == 100 ? "15" : "15";
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
        Row(//373739
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  color:Theme.of(context).brightness == Brightness.dark ? const Color(0xff373739):  const Color(0xffEDEFF2),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12), vertical: ScreenUtil().setWidth(6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/mining/icon_full_node.png",
                    width: ScreenUtil().setWidth(24),
                    fit: BoxFit.cover,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(12),
                  ),
                  Text(
                    S.of(context).g_mining_key_64,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setWidth(24)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(32),
            ),
            Container(
              decoration: BoxDecoration(
                  color:Theme.of(context).brightness == Brightness.dark ? const Color(0xff373739):  const Color(0xffEDEFF2),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12), vertical: ScreenUtil().setWidth(6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/mining/lock_time.png",
                    width: ScreenUtil().setWidth(24),
                    fit: BoxFit.cover,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(12),
                  ),
                  Text(
                    "$times ${S.of(context).g_mining_key_65}",
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(24)),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
