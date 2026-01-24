import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/home/setting/security/security_google_download.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityEdit extends StatefulWidget{
  final String type;
  const SecurityEdit(this.type, {super.key});
  @override
  _SecurityEditState createState()=>_SecurityEditState();
}
class _SecurityEditState extends State<SecurityEdit>{
  Map<String,dynamic> securityMap={
    "email":false,
    "google":false,
    "face":false,
  };
  @override
  void initState() {
    super.initState();
    init();
  }
  init()async{
    Map<String,dynamic>? s=await SPUtil().getSecurity();
    if(s!=null){
      Map<String,dynamic>? userSecurityMap=s[AppGlobals.userInfo?.uuid??""];
      if(userSecurityMap!=null){
        setState(() {
          securityMap['email']=userSecurityMap['email'];
          securityMap['google']=userSecurityMap['google'];
          securityMap['face']=userSecurityMap['face']??false;
        });
      }
    }
  }
  //保存设置
  saveSecurity()async{
    SPUtil sPUtils=SPUtil();
    Map<String,dynamic>? s=await sPUtils.getSecurity();
    s ??= {};
    if(widget.type=="google"){
      if(securityMap["google"]==true){

      }else{
        s[AppGlobals.userInfo?.uuid??""]=securityMap;
        await sPUtils.setSecurity(s);
        setState(() {
        });
      }
    }else{

      s[AppGlobals.userInfo?.uuid??""]=securityMap;
      await sPUtils.setSecurity(s);
      setState(() {
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.type=="google"?S.of(context).google_verification:S.of(context).email_verification,
      ),
      body: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: ScreenUtil().setWidth(88.0),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Row(
                children: [
                  Container(
                    height: ScreenUtil().setWidth(40.0),
                    width: ScreenUtil().setWidth(40.0),
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                    child:Image.asset('assets/home/setting/scurity/item_${widget.type}.png',),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.type=="google"?S.of(context).google_verification:S.of(context).email_verification,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setWidth(30.0),
                      ),
                    ),
                  ),
                  Switch(
                    activeTrackColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                    value: securityMap[widget.type],
                    onChanged: (bool value){
                      if(widget.type=="google"){
                        if(value==false){
                          securityMap[widget.type]=value;
                          saveSecurity();
                        }else{
                          //跳转
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SecurityGoogleDownload()));
                        }
                      }else{
                        securityMap[widget.type]=value;
                        saveSecurity();
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                widget.type=="google"?S.of(context).google_verification_message7:S.of(context).email_verification_message1,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}