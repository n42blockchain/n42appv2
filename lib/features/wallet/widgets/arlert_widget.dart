import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

Future<void> alertWidget(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).g_swap_key_20(CoinType.N.name),
                style: TextStyle(
                  color: AppColorTokens.of(context).textPrimary,
                  fontSize: ScreenUtil().setSp(40),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(60),
                  vertical: ScreenUtil().setWidth(40),
                ),
                child: Image.asset(
                  "assets/home/swap/medal.png",
                  fit: BoxFit.cover,
                  height: ScreenUtil().setWidth(120),
                  color: AppColorTokens.of(context).brand,
                ),
              ),
              Text(
                S.of(context).g_swap_key_19,
                style: TextStyle(
                  color: AppColorTokens.of(context).textPrimary,
                  fontSize: ScreenUtil().setSp(24),
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ScreenUtil().setWidth(40)),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainButtonBgColor.name,
                    ),
                    borderRadius: AppRadius.brSm,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(30),
                  ),
                  height: ScreenUtil().setWidth(88),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).g_swap_key_18,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainButtonTextColor.name,
                      ),
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
