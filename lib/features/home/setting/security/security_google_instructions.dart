import 'package:n42_wallet/features/home/setting/security/security_google_backup_key.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityGoogleInstructions extends StatelessWidget{
  const SecurityGoogleInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).google_verification_message12,
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          children: [
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
                  width: ScreenUtil().setWidth(40.0),
                  height: ScreenUtil().setWidth(40.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                  ),
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                  ),
                ),
                Expanded(child: Text(
                  S.of(context).google_verification_message13,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(26.0),
                  ),
                ),),
              ],
            ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: ScreenUtil().setWidth(40.0),
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(18.0)),
                  child: MySeparator(
                    ScreenUtil().setWidth(2.0),
                    AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                Expanded(child: SizedBox(),),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: ScreenUtil().setWidth(360.0),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        //margin: EdgeInsets.only(right: scr.setWidth(30.0)),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        ),
                        child: Text(
                          "2",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ),
                      Expanded(child: Container(
                        alignment: Alignment.center,
                        //margin: EdgeInsets.only(right: scr.setWidth(28.0)),
                        width: ScreenUtil().setWidth(40.0),
                        //margin: EdgeInsets.only(left: scr.setWidth(18.0)),
                        child: MySeparator(
                          ScreenUtil().setWidth(2.0),
                          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),),
                    ],
                  ),
                ),
                Expanded(child: Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setWidth(4.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).google_verification_message14,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(26.0),
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setWidth(210),
                        width: ScreenUtil().setWidth(316),
                        margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(30.0),
                        ),
                        child: Image.asset('assets/home/setting/scurity/example.png'),
                      ),
                    ],
                  ),

                ),),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: ScreenUtil().setWidth(100.0),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        //margin: EdgeInsets.only(right: scr.setWidth(30.0)),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                          border: Border.all(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                            width: ScreenUtil().setWidth(2.0),
                          ),
                        ),
                        child: Text(
                          "3",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                            fontSize: ScreenUtil().setSp(26.0),
                          ),
                        ),
                      ),
                      Expanded(child: Container(
                        alignment: Alignment.center,
                        //margin: EdgeInsets.only(right: scr.setWidth(28.0)),
                        width: ScreenUtil().setWidth(40.0),
                        //margin: EdgeInsets.only(left: scr.setWidth(18.0)),
                        child: MySeparator(
                          ScreenUtil().setWidth(2.0),
                          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),),
                    ],
                  ),
                ),
                Expanded(child: Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setWidth(4.0)),
                  child: Text(
                    S.of(context).google_verification_message15,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                  ),

                ),),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: ScreenUtil().setWidth(100.0),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(30.0)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        //margin: EdgeInsets.only(right: scr.setWidth(30.0)),
                        width: ScreenUtil().setWidth(40.0),
                        height: ScreenUtil().setWidth(40.0),
                        child: Image.asset('assets/home/setting/scurity/open.png'),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Text(
                  S.of(context).google_verification_message16,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(26.0),
                  ),
                ),),
              ],
            ),
            const Spacer(),
            Container(
              height: ScreenUtil().setWidth(88.0),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(6.0)),
              child: buttonStyle2(context, (){
                //跳转
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SecurityGoogleBackupKey()));
              }, S.of(context).next,),
            ),
          ],
        ),
      ),
    );
  }
}
class MySeparator extends StatelessWidget{
  final double width;
  final Color color;
  const MySeparator(this.width,this.color, {super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(
        builder: (BuildContext context,BoxConstraints constraints){
          final boxHeight=constraints.constrainHeight();
          final dashHeight=2.0;
          final dashWidth=width;
          final int dashCount= (boxHeight/(2*dashHeight).floor()).toInt();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.vertical,
            children: List.generate(dashCount, (_){
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        }
    );
  }
}