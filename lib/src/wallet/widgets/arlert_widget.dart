import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

Future<void> alertWidget(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: ScreenUtil().setWidth(460),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).g_swap_key_20(CoinType.N.name),
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(40)
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60), vertical: ScreenUtil().setWidth(40)),
                      child: Image.asset(
                        "assets/home/swap/medal.png",
                        fit: BoxFit.cover,
                        height: ScreenUtil().setWidth(120),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ),
                  ),
                  Text(
                    S.of(context).g_swap_key_19,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(24)
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                      height: ScreenUtil().setWidth(88),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_swap_key_18,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
