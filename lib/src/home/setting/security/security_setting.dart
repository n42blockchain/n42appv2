import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/home/setting/security/gesture_password_setting.dart';
import 'package:n42appv2/src/home/setting/security/lock_screen_resetpassword.dart';
import 'package:n42appv2/src/home/setting/security/security_edit.dart';
import 'package:n42appv2/src/home/widgets/face_recognition_public.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecuritySetting extends ConsumerStatefulWidget{
  const SecuritySetting({super.key});

  @override
  ConsumerState<SecuritySetting> createState()=>_SecuritySettingState();
}

class _SecuritySettingState extends ConsumerState<SecuritySetting>{
  List<String> lockTimeList=["10","30","60","120","180","240","300","600"];
  Map<String,dynamic> securityMap={
    "email":false,
    "google":false,
    "face":false,
  };
  bool checkBiometrics=true;
  @override
  void initState() {
    super.initState();
    init();
  }
  Future<void> init()async{
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
    initFace();
  }
  Future<void> initFace()async{
    FaceRecognitionPublic frp=FaceRecognitionPublic();
    checkBiometrics=await frp.checkBiometrics();
    setState(() {});
  }
  //保存设置
  Future<void> saveSecurity()async{
    SPUtil sPUtils=SPUtil();
    Map<String,dynamic>? s=await sPUtils.getSecurity();
    s ??= {};
    s[AppGlobals.userInfo?.uuid??""]=securityMap;
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
              rowItemNew(
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
              Builder(
                builder: (context) {
                  final screenLockState = ref.watch(screenLockProvider);
                  return Column(
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(60.0),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(40.0)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.of(context).g_lock_key15,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                        ),
                      ),
                      openLockScreenWidget(screenLockState),
                      openGesturePasswordWidget(screenLockState),
                      openFaceWidget(screenLockState),
                    ],
                  );
                },
              ),
              SizedBox(height: ScreenUtil().setWidth(100),),
            ],
          ),
        ),
      ),
    );
  }
  Widget rowItemNew(String title,bool open,Function callback){
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
  Widget openLockScreenWidget(ScreenLockState screenLockState){
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
            screenLockState.isLocked,
                (bool value)async{
              if(!screenLockState.isLocked){
                bool? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>LockScreenResetPassword(0)));
                if(r==true){
                  ref.read(screenLockProvider.notifier).setLockEnabled(value);
                }
              }else{
                ref.read(screenLockProvider.notifier).setLockEnabled(value);
              }
            },
          ),
          if(screenLockState.isLocked)
            lockTime(screenLockState),
          if(screenLockState.isLocked)
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
  Widget openGesturePasswordWidget(ScreenLockState screenLockState){
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
            screenLockState.gestureEnabled,
                (bool value)async{
              if(!screenLockState.gestureEnabled){
                String? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>GesturePasswordSetting(0)));
                if(r != null){
                  ref.read(screenLockProvider.notifier).setGestureEnabled(true);
                  // 将逗号分隔的字符串转换为 List<int>
                  final passwordList = r.split(',').map(int.parse).toList();
                  ref.read(screenLockProvider.notifier).setGesturePassword(passwordList);
                }
              }else{
                ref.read(screenLockProvider.notifier).setGestureEnabled(value);
              }
            },
          ),
          if(screenLockState.gestureEnabled)
            resetPassword(()async{
              String? r=await Navigator.push(context, MaterialPageRoute(builder: (context)=>GesturePasswordSetting(1,oldPassword: screenLockState.gesturePassword.join(','),)));
              if(r != null){
                // 将逗号分隔的字符串转换为 List<int>
                final passwordList = r.split(',').map(int.parse).toList();
                ref.read(screenLockProvider.notifier).setGesturePassword(passwordList);
              }
            }),
        ],
      ),
    );
  }
  //打开或关闭面部识别
  Widget openFaceWidget(ScreenLockState screenLockState){
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
            screenLockState.faceEnabled,
                (bool value){
              if(checkBiometrics){
                ref.read(screenLockProvider.notifier).setFaceEnabled(value);
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
  Widget openWidget(String title,bool value,Function valueChange){
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
            activeTrackColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
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
  Widget lockTime(ScreenLockState screenLockState){
    return InkWell(
      onTap: (){
        showNFTSheet(screenLockState);
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
              "${screenLockState.lockTimeSeconds} s",
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
  void showNFTSheet(ScreenLockState screenLockState){
    sheetBottom(
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
            if(title==screenLockState.lockTimeSeconds.toString()){
              titleColor=AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
              isSame=true;
            }
            return InkWell(
              onTap: (){
                if(title!=screenLockState.lockTimeSeconds.toString()){
                  ref.read(screenLockProvider.notifier).setLockTime(int.parse(title));
                }
                Navigator.pop(context);
              },
              child: SizedBox(
                height: ScreenUtil().setWidth(88.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$title s",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                    isSame?
                    SizedBox(
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
  Widget resetPassword(Function onTap){
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