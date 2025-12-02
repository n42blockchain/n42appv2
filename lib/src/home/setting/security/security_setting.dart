
import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/home/setting/security/gesture_password_setting.dart';
import 'package:n42appv2/src/home/setting/security/lock_screen_resetpassword.dart';
import 'package:n42appv2/src/home/setting/security/security_edit.dart';
import 'package:n42appv2/src/home/widgets/face_recognition_public.dart';
import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SecuritySetting extends StatefulWidget{
  @override
  _SecuritySettingState createState()=>_SecuritySettingState();
}

class _SecuritySettingState extends State<SecuritySetting>{
  List<String> lockTimeList=["10","30","60","120","180","240","300","600"];
  Map<String,dynamic> securityMap={
    "email":false,
    "google":false,
    "face":false,
  };
  bool checkBiometrics=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  init()async{
    Map<String,dynamic>? s=await SPUtil().getSecurity();
    if(s!=null){
      Map<String,dynamic>? userSecurityMap=s[Application.userInfo?.uuid??""];
      if(userSecurityMap!=null){
        setState(() {
          securityMap['email']=userSecurityMap['email'];
          securityMap['google']=userSecurityMap['google'];
          securityMap['face']=userSecurityMap['face']==null?false:userSecurityMap['face'];
        });
      }
    }
    initFace();
  }
  initFace()async{
    FaceRecognitionPublic frp=FaceRecognitionPublic();
    checkBiometrics=await frp.checkBiometrics();
    setState(() {});
  }
  //保存设置
  saveSecurity()async{
    SPUtil sPUtils=SPUtil();
    Map<String,dynamic>? s=await sPUtils.getSecurity();
    if(s==null){
      s={};
    }
    s[Application.userInfo?.uuid??""]=securityMap;
    await sPUtils.setSecurity(s);
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_11,
      ),
      body:SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20.0)),
                child: Text(
                  S.of(context).google_verification_message5,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
                child: Text(
                  S.of(context).google_verification_message6,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
              ),
              rowItem_new(
                S.of(context).email_verification,
                securityMap['email'],()async{
                await Navigator.push(context, MaterialPageRoute(builder: (context)=>SecurityEdit('email')));
                init();
              },),
              Container(
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
                ),
                child: Column(
                  children: [
                    openWidget(
                      S.of(context).g_lock_key1,
                      securityMap['face'],
                          (value)async{
                            if(checkBiometrics){
                              securityMap['face']= value;
                              saveSecurity();
                            }
                            setState(() {});
                        },
                    ),
                    if(checkBiometrics==false)
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30.0),
                          right: ScreenUtil().setWidth(10.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                S.of(context).g_lock_key7,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: ()async{
                                await openAppSettings();
                                initFace();
                              },
                              child: Text(
                                S.of(context).g_face_5,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                child: Consumer<PublicProvider>(
                    builder: (context,pValue,child){
                      return Column(
                        children: [
                          Container(
                            height: ScreenUtil().setWidth(60.0),
                            margin: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
                            child: Text(
                              S.of(context).g_lock_key15,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(30.0),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          openLockScreenWidget(pValue),
                          openGesturePasswordWidget(pValue),
                          openFaceWidget(pValue),
                        ],
                      );
                    }),
              ),
              SizedBox(height: ScreenUtil().setWidth(100),),
            ],
          ),
        ),
      ),
    );
  }
  rowItem_new(String title,bool open,Function callback){
    return InkWell(
      onTap: (){
        callback();
      },
      child: Container(
        height: ScreenUtil().setWidth(88.0),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0),),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
              child: Image.asset("assets/home/setting/scurity/${open?"open":"closs"}.png"),
            ),
            Expanded(
              flex: 1,
              child: Text(
                title,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(26.0),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,size: ScreenUtil().setWidth(40.0),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  //打开或关闭锁屏功能
  openLockScreenWidget(PublicProvider pValue){
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      ),
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setWidth(88.0),
      ),
      child: Column(
        children: [
          openWidget(
            S.of(context).g_lock_key3,
            pValue.lockScreenMap["lock"],
                (bool value)async{
              if(pValue.lockScreenMap["lock"]==false){
                bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>LockScreenResetPassword(0)));
                if(r==true){
                  pValue.lockScreenMap["lock"]=value;
                }
              }else{
                pValue.lockScreenMap["lock"]=value;
              }
              pValue.notifyListeners();
              pValue.setLockScreenData();
            },
          ),
          if(pValue.lockScreenMap["lock"])
            lockTime(pValue),
          if(pValue.lockScreenMap["lock"])
            resetPassword(
                    (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LockScreenResetPassword(1)));
                }
            ),
        ],
      ),
    );
  }
  //打开或关闭手势密码功能
  openGesturePasswordWidget(PublicProvider pValue){
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      ),
      constraints: BoxConstraints(
        minHeight: ScreenUtil().setWidth(88.0),
      ),
      child: Column(
        children: [
          openWidget(
            S.of(context).g_lock_key16,
            pValue.lockScreenMap["gesture"],
                (bool value)async{
              if(pValue.lockScreenMap["gesture"]==false){
                String? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>GesturePasswordSetting(0)));
                if(r != null){
                  pValue.lockScreenMap["gesture"]=true;
                  pValue.lockScreenMap["gesturePW"]=r;
                }
              }else{
                pValue.lockScreenMap["gesture"]=value;
              }
              pValue.notifyListeners();
              pValue.setLockScreenData();
            },
          ),
          if(pValue.lockScreenMap["gesture"])
            resetPassword(()async{
              String? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>GesturePasswordSetting(1,oldPassword: pValue.lockScreenMap['gesturePW'],)));
              if(r != null){
                pValue.lockScreenMap["gesturePW"]=r;
                pValue.notifyListeners();
                pValue.setLockScreenData();
              }
            }),
        ],
      ),
    );
  }
  //打开或关闭面部识别
  openFaceWidget(PublicProvider pValue){
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          openWidget(
            S.of(context).g_lock_key1,
            pValue.lockScreenMap["face"],
                (bool value){
              if(checkBiometrics){
                pValue.lockScreenMap["face"]=value;
                pValue.notifyListeners();
                pValue.setLockScreenData();
              }
              setState(() {});
            },
          ),
          if(checkBiometrics==false)
            Padding(
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(30.0),
                right: ScreenUtil().setWidth(10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      S.of(context).g_lock_key7,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: ()async{
                      await openAppSettings();
                      initFace();
                    },
                    child: Text(
                      S.of(context).g_face_5,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  //打开通用控件
  openWidget(String title,bool value,Function valueChange){
    return Container(
      height: ScreenUtil().setWidth(88.0),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),),
          Switch(
            activeColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
            value: value,
            onChanged: (bool value){
              valueChange(value);
            },
          ),
        ],
      ),
    );
  }

  //锁屏时间
  lockTime(PublicProvider pValue){
    return InkWell(
      onTap: (){
        showNFTSheet(pValue);
      },
      child: Container(
        //margin: EdgeInsets.only(bottom: scr.setWidth(10.0)),
        padding: EdgeInsets.symmetric(
          //vertical: scr.setWidth(30.0),
          horizontal: ScreenUtil().setWidth(30.0),
        ),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                S.of(context).g_lock_key4,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),),
            Text(
              "${pValue.lockScreenMap['lockTime']} s",
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(30.0),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_sharp,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              size: ScreenUtil().setWidth(40.0),
            ),
          ],
        ),
      ),
    );
  }
  showNFTSheet(PublicProvider pValue){
    SheetBottom(
      context,
      S.of(context).g_lock_key4,
      Container(
        margin: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        height: ScreenUtil().setWidth(88.0*lockTimeList.length),
        child: ListView.separated(
          itemCount: lockTimeList.length,
          itemBuilder: (context,int index){
            String title=lockTimeList[index];
            Color titleColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
            bool isSame=false;
            if(title==pValue.lockScreenMap['lockTime'].toString()){
              titleColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
              isSame=true;
            }
            return InkWell(
              onTap: (){
                if(title!=pValue.lockScreenMap['lockTime'].toString()){
                  pValue.lockScreenMap['lockTime']=int.parse(title);
                  pValue.notifyListeners();
                  pValue.setLockScreenData();
                }
                Navigator.pop(context);
              },
              child: Container(
                height: ScreenUtil().setWidth(88.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${title} s",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                    isSame?
                    Container(
                      height: ScreenUtil().setWidth(40.0),
                      width: ScreenUtil().setWidth(40.0),
                      child: Icon(
                        Icons.check,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      ),
                    ):SizedBox(),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context,int index){
            return Divider(
              indent: 0,
              endIndent: 0,
              height: ScreenUtil().setWidth(1.0),
            );
          },
        ),
      ),
    );
  }

  //重置密码
  resetPassword(Function onTap){
    return InkWell(
      onTap: (){
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          //vertical: scr.setWidth(20.0),
          horizontal: ScreenUtil().setWidth(30.0),
        ),
        height: ScreenUtil().setWidth(88.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                S.of(context).g_lock_key9,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),),
            Icon(
              Icons.arrow_forward_ios,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              size: ScreenUtil().setWidth(30.0),
            ),
          ],
        ),
      ),
    );
  }
}