import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_html_css/simple_html_css.dart';

aboutShowDialog(context,String aboutStr,String title){
  showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(ScreenUtil().setWidth(16.0)),
        topRight: Radius.circular(ScreenUtil().setWidth(16.0)),
      ),
    ),
    context: context,
    builder: (BuildContext context){
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 1.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(50.0),
                    height: ScreenUtil().setWidth(50.0),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                    child: Icon(Icons.close),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(30.0),),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: RichText(
                  text: HTML.toTextSpan(
                    context,
                    aboutStr,
                    defaultTextStyle: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                      // etc etc
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
