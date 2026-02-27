import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

Future<bool?> showGroupConfirmDialog(BuildContext context, int num,
    String lockDate, GestureTapCallback? sureCall) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      //这是宽度沾满宽度
      insetPadding: EdgeInsets.all(ScreenUtil().setWidth(28)),
      //设置圆角
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24))),
      content: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.backGroundColor.name)),
          child: GroupConfirm(
            num: num,
            lockDate: lockDate,
            sureCall: sureCall,
          )),
    ),
  );
}

class GroupConfirm extends StatelessWidget {
  final int num;
  final String lockDate;
  final GestureTapCallback? sureCall;

  const GroupConfirm(
      {super.key, required this.num, required this.lockDate, this.sureCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(44)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(80),
          ),
          Image.asset(
            'assets/img/ast_nft.png',
            width: ScreenUtil().setWidth(160),
            fit: BoxFit.cover,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(80),
          ),
          Text(
            "Confirmation",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(44)),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(54),
          ),
          Text(
            // "Are you sure you want to lock $num AsT until $lockDate to run a node?",
            S.of(context).g_mining_key76(num.toString(), lockDate),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(28)),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(90),
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
                      sureCall?.call();
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
            height: ScreenUtil().setWidth(54),
          ),
        ],
      ),
    );
  }
}