import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

Future<bool?> showSKipConfirmDialog(
    BuildContext context, GestureTapCallback? sureCall) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      //这是宽度沾满宽度
      insetPadding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      //设置圆角
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24))),
      content: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name)),
          child: SkipDialogView(
            sureCall: sureCall,
          )),
    ),
  );
}

class SkipDialogView extends StatelessWidget {
  final GestureTapCallback? sureCall;

  const SkipDialogView({Key? key, this.sureCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(44)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(72),
          ),
          Text(
            // "Are you sure you want to skip?",
            S.current.g_mining_key_45,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(44)),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(44),
          ),
          Image.asset(
            "assets/mining/big_tip.png",
            width: ScreenUtil().setWidth(130),
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: ScreenUtil().setWidth(44),
          ),
          Text(
            // "You will not receive any mining rewards until you choose 1 of the plans.",
            S.current.g_mining_key_46,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30)),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(44),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(88),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemBgColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
                      child: Center(
                        child: Text(
                          S.of(context).g_key_79,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainBlueColor.name),
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(30)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(30),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (sureCall != null) {
                        sureCall!();
                      }
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
                      child: Center(
                        child: Text(
                          S.of(context).g_key_78,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(30)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(48),
          ),
        ],
      ),
    );
  }
}