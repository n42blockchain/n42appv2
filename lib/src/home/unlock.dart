import 'dart:async';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/home/widgets/face_recognition_public.dart';
import 'package:n42appv2/src/home/widgets/gesture_password/gesture_password.dart';
import 'package:n42appv2/src/login/pages/login_page.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

/// Unlock Page - Migrated to Riverpod
/// 
/// Uses ConsumerStatefulWidget for:
/// - Screen lock state management via screenLockProvider
/// - Biometric and password verification
class Unlock extends ConsumerStatefulWidget {
  const Unlock({super.key});
  @override
  ConsumerState<Unlock> createState() => _UnlockState();
}

class _UnlockState extends ConsumerState<Unlock> {
  //TextEditingController inputEditingController=TextEditingController();
  //String pwdErrorMessage="";
  String inputPassword="";
  bool check=false;//是否通过验证
  bool obscure=true;//是否显示密码

  bool faceShow=false;
  bool gestureShow=false;
  bool passwordShow=false;
  int gestureErrorCount=0;//手势输入错误次数
  int passwordErrorCount=0;//密码输入错误次数
  int passwordUnlock=60;//密码解锁倒计时
  Timer? passworldTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }
  initData() {
    faceShow = false;
    gestureShow = false;
    passwordShow = false;
    gestureErrorCount = 0; // 手势输入错误次数
    passwordErrorCount = 0; // 密码输入错误次数
    passwordUnlock = 60; // 密码解锁倒计时
    
    // Use Riverpod screenLockProvider
    final lockState = ref.read(screenLockProvider);
    final dOld = lockState.passwordLockTimestamp;
    
    if (dOld != 0) {
      int dNow = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (dNow - dOld < 55) {
        setState(() {
          passwordUnlock = 60 - (dNow - dOld);
        });
        passwordLock(setData: false);
        return;
      }
    }
    
    if (lockState.faceEnabled) {
      initFace();
    } else {
      faceShow = true;
    }
    
    if (!lockState.gestureEnabled) {
      gestureShow = true;
    }
    
    if (!lockState.isLocked) {
      passwordShow = true;
    }
  }
  initFace() async {
    final lockState = ref.read(screenLockProvider);
    if (lockState.faceEnabled) {
      FaceRecognitionPublic frp = FaceRecognitionPublic();
      bool checkBiometrics = await frp.checkBiometrics();
      if (!mounted) return;
      if (checkBiometrics) {
        bool authenticate = await frp.authenticateWithBiometrics();
        if (!mounted) return;
        if (authenticate) {
          check = true;
          back();
        } else {
          // 验证失败
          check = false;
          ToastUtils.show(S.of(context).g_unlock_key7);
        }
      } else {
        // 无法使用生物识别
        check = false;
        ToastUtils.show(S.of(context).g_lock_key7);
      }
    }
    setState(() {
      faceShow = true;
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(passworldTimer !=null){
      passworldTimer!.cancel();
      passworldTimer=null;
    }
    super.dispose();
  }

  back(){
    Navigator.pop(context,true);
  }
  // 验证密码
  checkPwd() {
    String pwdStr = inputPassword;
    
    // Use Riverpod screenLockProvider
    final lockState = ref.read(screenLockProvider);
    
    if (!lockState.verifyPassword(pwdStr)) {
      setState(() {
        passwordErrorCount++;
        inputPassword = "";
      });
      if (passwordErrorCount >= 3) {
        setState(() {
          passwordShow = true;
        });
        passwordLock();
      }
      return false;
    }
    
    check = true;
    back();
    return true;
  }

  passwordLock({bool setData = true}) async {
    if (setData) {
      // Update password lock timestamp via Riverpod
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await ref.read(screenLockProvider.notifier).setPasswordLockTimestamp(timestamp);
    }
    
    passworldTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (passwordUnlock > 1) {
        setState(() {
          passwordUnlock--;
        });
      } else {
        passworldTimer!.cancel();
        initData();
        setState(() {});
      }
    });
  }

  Future<bool> _pageBack(){
    if(check){
      if(Navigator.canPop(context)){
        Navigator.pop(context,true);
      }else{
        SystemNavigator.pop();
      }
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    return _buildUnlockWidget();
  }

  Widget _buildUnlockWidget() {
    // Watch screen lock state from Riverpod
    final lockState = ref.watch(screenLockProvider);
    
    String textspanStr = S.of(context).g_unlock_key2;
    List<Widget> columns = [];
    
    if (lockState.faceEnabled && faceShow == false) {
          columns.add( Expanded(
            flex: 1,
            child: SizedBox(),
          ));
        }
        else if (lockState.gestureEnabled && faceShow && gestureShow == false) {
          columns.addAll([
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
              padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
              width: double.infinity,
              height: ScreenUtil().setWidth(120.0),
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_unlock_key3,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(44.0),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if(gestureErrorCount!=0)
              Container(
                margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
                padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
                width: double.infinity,
                height: ScreenUtil().setWidth(120.0),
                alignment: Alignment.center,
                child: Text(
                  S.of(context).g_unlock_key4(3-gestureErrorCount),
                  //"Pattern password input error,you have ${3-gestureErrorCount} chances.",
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    fontSize: ScreenUtil().setSp(32.0),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              flex: 1,
              child: Center(
                child: SizedBox(
                  height: ScreenUtil().setWidth(480.0),
                  width: ScreenUtil().setWidth(480.0),
                  child:                   GesturePassword(
                    (String value) async {
                      // Use lockState from Riverpod
                      if (lockState.verifyGesture(stringToIntArray(value))) {
                        check = true;
                        back();
                      } else {
                        gestureErrorCount++;
                        if (gestureErrorCount >= 3) {
                          setState(() {
                            gestureShow = true;
                          });
                        }
                      }
                    },
                    ScreenUtil().setWidth(160.0),
                    answer: lockState.gesturePassword,
                  ),
                ),
              ),
            ),]);
        }
        else if (lockState.isLocked && faceShow && gestureShow && passwordShow == false) {
          columns.addAll([
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
              padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
              width: double.infinity,
              height: ScreenUtil().setWidth(120.0),
              alignment: Alignment.center,
              child: Text(
                S.of(context).g_unlock_key5,
                //"Enter password",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(44.0),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if(passwordErrorCount!=0)
              Container(
                margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0)),
                padding: EdgeInsets.all(ScreenUtil().setWidth(16.0)),
                width: double.infinity,
                height: ScreenUtil().setWidth(120.0),
                alignment: Alignment.center,
                child: Text(
                  3-passwordErrorCount==1?S.of(context).g_unlock_key8(3-passwordErrorCount):S.of(context).g_unlock_key6(3-passwordErrorCount),
                  //"Password input error,you have ${3-passwordErrorCount} chances",
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    fontSize: ScreenUtil().setSp(32.0),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Container(
              height: ScreenUtil().setWidth(120),
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60.0)),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context,int index){
                  double width=(MediaQuery.of(context).size.width-ScreenUtil().setWidth(180.0))/6;
                  bool isInput=inputPassword.length>=index+1;
                  return Container(
                    width: width,
                    height: ScreenUtil().setWidth(36.0),
                    alignment: Alignment.center,
                    child: Container(
                      height: ScreenUtil().setWidth(36.0),
                      width: ScreenUtil().setWidth(36.0),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, isInput?AppThemeKeys.mainBlueColor.name:AppThemeKeys.itemBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(36.0),)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(120.0),),
                child: GridView.count(
                  crossAxisCount: 3,
                  children: List.generate(12, (index) {
                    Widget childWidget;
                    String title="";
                    if(index==10){
                      childWidget=SizedBox();
                    }else if(index==11){
                      childWidget=Icon(
                        Icons.close,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        size: ScreenUtil().setWidth(48.0),
                      );
                    }else{
                      title="${index==9?0:index+1}";
                      childWidget=Text(
                        title,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(48.0)
                        ),
                      );
                    }
                    return InkWell(
                        onTap: (){
                          if(index==10){
                          }else if(index==11){
                            if(inputPassword==""){
                              return;
                            }else{
                              inputPassword=inputPassword.substring(0,inputPassword.length-1);
                            }
                          }else{
                            inputPassword='$inputPassword$title';
                            if(inputPassword.length==6){
                              checkPwd();
                            }
                          }
                          setState(() {});
                        },
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: childWidget,
                        )
                    );

                  }),
                ),
              ),
            )
          ]);
        }
        else{
          textspanStr="";
          /*columns.add(
            Expanded(flex: 1,child: EmptyView(type: EmptyType.noData,canRefresh: false,),),
          );*/
          columns.add(
            Expanded(flex: 1,child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  S.of(context).g_unlock_key10(passwordUnlock),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
              ),
            ),),
          );
        }
        columns.add(Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(60.0),),
          padding: EdgeInsets.all(ScreenUtil().setWidth(12.0),),
          width: double.infinity,
          alignment: Alignment.center,
          //height: scr.setWidth(120.0),
          child: RichText(
            maxLines: 3,
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: textspanStr,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(26.0),
                ),
              ),
              TextSpan(
                  text:S.of(context).g_unlock_key9,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(26.0),
                  ),
              ),
              TextSpan(
                  text:S.of(context).g_key_login,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      //退出登陆
                      String tokenId=AppGlobals.userInfo?.token??"";
                      await Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                      if(AppGlobals.userInfo !=null){
                        if((AppGlobals.userInfo?.token??"") !=tokenId){
                          check=true;
                          back();
                          /*if(widget.type =="resumed"){
                          Navigator.pop(context);
                        }*/
                        }
                      }
                    }),
            ],),
          ),
        ));
        Widget stack=Stack(
          children: [
            Positioned(
              top: ScreenUtil().setWidth(120.0),
              bottom: ScreenUtil().setWidth(120.0),
              left: ScreenUtil().setWidth(30.0),
              right: ScreenUtil().setWidth(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns,
              ),
            ),
          ],
        );
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _pageBack();
          },
          child: Scaffold(
            backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
            body: stack,
          ),
        );
  }
  stringToIntArray(String answer){
    List<String> answerStrList=answer.split(',');
    List<int> answerIntList=[];
    for(String value in answerStrList){
      answerIntList.add(int.parse(value));
    }
    return answerIntList;
  }
}