import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final bool must;

  const LoginTitle({Key? key, required this.title, this.color,this.must=false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(must==true){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                color: color ??
                    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                fontSize: ScreenUtil().setSp(32.0)),
          ),
          Text(
            "*",
            style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                fontSize: ScreenUtil().setSp(20.0)),
          )
        ],
      );
    }else{
      return Text(
        title,
        style: TextStyle(
            color: color ??
                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            fontSize: ScreenUtil().setSp(32.0)),
      );
    }
  }
}