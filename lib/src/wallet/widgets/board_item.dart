import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoardItem extends StatelessWidget {
  final String imagePath;
  final String action;
  final GestureTapCallback? onTap;
  final Color? color;

  const BoardItem(
      {Key? key,
        required this.imagePath,
        required this.action,
        this.onTap,
        this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: ScreenUtil().setWidth(80),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30),),
        ),
        child: Text(
          action,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
            fontSize: ScreenUtil().setSp(30),
          ),
        ),
      ),
    );
  }
  oldWidget(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: ScreenUtil().setWidth(70),
            height: ScreenUtil().setWidth(70),
            padding: EdgeInsets.all(ScreenUtil().setWidth(14),),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20),)),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
            child: Image.asset(
              imagePath,
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(40),
              fit: BoxFit.cover,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemTextColor.name),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(12),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12),),
            //height: ScreenUtil().setWidth(80),
            child: Text(
              action,
              style: TextStyle(
                color: color ??
                    AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
