import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavSettingItem extends StatelessWidget {
  final String path;
  final String action;
  final VoidCallback callback;
  final Color? imgColor;
  const NavSettingItem({required this.path,
    required this.action,
    required this.callback, this.imgColor,
    super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(30.0)),
        color: Colors.transparent,
        child: Row(
          children: [
            Image.asset(
              path,
              width: ScreenUtil().setWidth(60.0),
              height: ScreenUtil().setWidth(60.0),
              fit: BoxFit.contain,
              color: imgColor ,
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20.0),
                ),
                child: Text(
                  action,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: ScreenUtil().setWidth(30.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
            ),
          ],
        ),
      ),
    );
  }
}
