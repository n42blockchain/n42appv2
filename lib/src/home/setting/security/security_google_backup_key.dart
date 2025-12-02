import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/home/setting/security/security_google_vedification.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecurityGoogleBackupKey extends StatefulWidget{
  @override
  _SecurityGoogleBackupKeyState createState()=>_SecurityGoogleBackupKeyState();
}
class _SecurityGoogleBackupKeyState extends State<SecurityGoogleBackupKey>{
  String googleAuthStr="";
  Load load=Load.finish;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bindGoogleVerification();
  }
  //绑定谷歌验证
  bindGoogleVerification()async{
    if(load==Load.loading)return;
    load=Load.loading;
    UserInfoApi userInfoAPI=UserInfoApi();
    MessageModel mm=await userInfoAPI.bindGoogle();
    if(mm.error){
      ToastUtils.show(S.of(context).google_verification_message3);
    }else{
      googleAuthStr=mm.data;
    }
    load=Load.finish;
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).google_verification_message17,
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
              alignment: Alignment.center,
              child: Text(
                S.of(context).google_verification_message18,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            googleAuthStr==""?Container(
              alignment: Alignment.center,
              width: ScreenUtil().setWidth(500.0),
              height: ScreenUtil().setWidth(500.0),
              child: InkWell(
                onTap: (){
                  bindGoogleVerification();
                },
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20.0)),
                  width: ScreenUtil().setWidth(90.0),
                  height: ScreenUtil().setWidth(90.0),
                  child: Image.asset("assets/img/shuaxin.png",
                    color:AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),),
                ),
              ),
            ):
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(50.0)),
              width: ScreenUtil().setWidth(500.0),
              height: ScreenUtil().setWidth(500.0),
              child: QrImageView(
                backgroundColor: Color(0xffffffff),
                data: "otpauth://totp/AmazaWallet?secret=${googleAuthStr}",
                version: QrVersions.min + 7,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(10.0),
                top: ScreenUtil().setWidth(14.0),
                bottom: ScreenUtil().setWidth(14.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      googleAuthStr,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      ToastUtils.init(context);
                      Clipboard.setData(ClipboardData(text: googleAuthStr));
                      ToastUtils.showFtToast(child:SuccessViewV1(S.of(context).copy),duration: 3);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                      child: Text(
                        S.of(context).g_key_119,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              height: ScreenUtil().setWidth(88.0),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(6.0)),
              child: ButtonStyle2(
                context,
                    (){
                  //跳转
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SecurityGoogleVedification()));
                },
                S.of(context).google_verification_message10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}