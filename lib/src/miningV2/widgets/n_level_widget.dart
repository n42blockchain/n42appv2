import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/generated/l10n.dart';

class NLevelWidget extends StatelessWidget {
  final int nNum;

  const NLevelWidget({Key? key, required this.nNum}) : super(key: key);

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
    const String bigImage = "assets/mining/ast_50.png";
    final String levelText = S.of(context).g_mining_key_62;
    //String times = "70";
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
                        "$nNum",
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
      ],
    );
  }
}