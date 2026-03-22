import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskValueBar extends StatelessWidget {
  const TaskValueBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(72),
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromRGBO(135, 161, 255, 1),
              Color.fromRGBO(60, 133, 255, 1),
              Color.fromRGBO(25, 118, 249, 1),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ScreenUtil().setWidth(30)),
            topRight: Radius.circular(ScreenUtil().setWidth(30)),
          )
      ),
      child: Row(
        // mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(48)),
              child: Text(
                S.current.g_key_wallet_k54,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              // "Reward",
              S.of(context).g_mining_key_48,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                fontSize: ScreenUtil().setSp(30),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(48)),
              child: Text(
                // "Time",
                S.of(context).g_key_wallet_k25,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                  fontSize: ScreenUtil().setSp(30),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          // Text("status"),
        ],
      ),
    );
  }
}