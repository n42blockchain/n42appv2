import 'dart:async';
import 'dart:io';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/edit_wallet_password.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_6.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:local_auth_android/local_auth_android.dart' as auth_android;
import 'package:local_auth_darwin/local_auth_darwin.dart' as auth_ios;

class WalletSecurityVerification extends StatefulWidget {
  const WalletSecurityVerification({super.key});

  @override
  State<WalletSecurityVerification> createState() => _WalletSecurityVerificationState();
}

class _WalletSecurityVerificationState extends State<WalletSecurityVerification> {
  TextEditingController pwdTextEditingController=TextEditingController();
  TextEditingController emailTextEditingController=TextEditingController();
  bool obscure=true;//是否显示密码
  String pwdErrorMessage="";//错误提示
  String emailErrorMessage="";
  String faceErrorMessage="";
  Map<String,dynamic> coinInfo={};
  String gasPrice="";
  int faceCheck=0;//0未验证，1验证成功，2验证失败
  int emailSendWaitNum=60;//发送邮件倒计时
  bool emailSendWait=false;//发送邮件是否等待
  Load load=Load.finish;
  Load emailLoad=Load.finish;
  //Load googleLoad=Load.finish;
  bool showWalletPassword=false;

  //账号安全
  Map<String,dynamic> securityMap={
    "email":false,
    //"google":false,
    "face":false,
  };
  late UserInfoApi userInfoApi;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userInfoApi=UserInfoApi();
    initSecurity();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    pwdTextEditingController.dispose();
    emailTextEditingController.dispose();
    //googleTextEditingController.dispose();
    emailSendWaitNum=0;
    super.dispose();
  }
  Future<void> initSecurity() async {
    //isGoogleAuth=AppGlobals.userInfo!.bindGoogleAuthState ?? false;
    Map<String,dynamic>? s=await SPUtil().getSecurity();
    if(s!=null){
      Map<String,dynamic>? userSecurityMap=s[AppGlobals.userInfo?.uuid??""];
      if(userSecurityMap!=null){
        setState(() {
          securityMap['email']=userSecurityMap['email'];
          //securityMap['google']=userSecurityMap['google'];
          securityMap['face']=userSecurityMap['face']??false;
        });
      }
    }
    if (!mounted) return;
    if(Provider.of<WalletActionProvider>(context,listen: false).walletInfo.password!=""){
      showWalletPassword=true;
    }
    setState(() {});
  }

  //验证密码
  bool checkPwd() {
    String pwdStr=pwdTextEditingController.text;
    /*if(pwdStr==""){
      setState(() {
        pwdErrorMessage=S.of(context).g_key_t_33;
      });
      return false;
    }*/
    String oldPwdStr=Provider.of<WalletActionProvider>(context,listen: false).walletInfo.password!;
    if(oldPwdStr!=pwdStr){
      setState(() {
        pwdErrorMessage=S.of(context).g_key_t_34;
      });
      return false;
    }
    setState(() {
      pwdErrorMessage="";
    });
    return true;
  }
  //关闭键盘
  void closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
  //获取邮箱验证码
  Future<void> getEmailVerification() async {
    if(emailLoad==Load.loading)return;
    if(emailSendWait)return;//是否正在等待
    setState(() {
      emailLoad=Load.loading;
    });
    MessageModel mm=await userInfoApi.getEmailVerification();
    if (!mounted) return;
    if(mm.error){
      ToastUtils.show(S.of(context).email_code_error);
    }else{
      ToastUtils.show(S.of(context).email_code_finish);
      emailSendWait=true;
      starEmailSendWait();
    }
    setState(() {
      emailLoad=Load.finish;
    });
  }
  //开启emailsendwait倒计时
  void starEmailSendWait() {
    Timer(Duration(seconds: 1),(){
      setState(() {
        emailSendWaitNum--;
      });
      //print(emailSendWaitNum);
      if(emailSendWaitNum<=0){
        emailSendWaitNum=60;
        emailSendWait=false;
      }else{
        starEmailSendWait();
      }
    });
  }
  //验证邮箱验证码
  Future<bool> checkEmailVerification() async {
    String codeStr=emailTextEditingController.text;
    if(codeStr==""){
      setState(() {
        emailErrorMessage=S.of(context).rest_Please_enter;
      });
      return false;
    }
    if(codeStr.length!=6){
      setState(() {
        emailErrorMessage=S.of(context).email_code_input_error;
      });
      return false;
    }
    MessageModel mm= await userInfoApi.checkEmailVerification(codeStr);
    if(mm.error){
      setState(() {
        emailErrorMessage=S.of(context).email_code_input_error;
      });
      return false;
    }else{
      setState(() {
        emailErrorMessage="";
      });
      return true;
    }
  }
  //生物识别
  Future<void> faceVerification() async {
    final LocalAuthentication auth = LocalAuthentication();
    _checkBiometrics(auth);
  }
  //检查生物特征是否可用
  Future<void> _checkBiometrics(LocalAuthentication auth) async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      canCheckBiometrics = false;
    }
    if(canCheckBiometrics){
      final List<BiometricType> availableBiometrics =
      await auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        canCheckBiometrics=false;
      }
      if(availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak) ||
          availableBiometrics.contains(BiometricType.fingerprint)){
        canCheckBiometrics=true;
      }else{
        canCheckBiometrics=false;
      }
    }
    if(canCheckBiometrics){
      setState(() {
        faceErrorMessage="";
      });
      _authenticateWithBiometrics(auth);
    }else{
      setState(() {
        faceErrorMessage=S.of(context).g_lock_key7;
      });
    }
  }
  //人体特征验证
  Future<void> _authenticateWithBiometrics(LocalAuthentication auth) async {
    bool authenticated = false;
    try {
      dynamic authMessage;
      if(Platform.isIOS){
        authMessage=auth_ios.IOSAuthMessages(
          lockOut: S.of(context).g_face_9,
          goToSettingsButton: S.of(context).g_face_5,
          goToSettingsDescription: S.of(context).g_face_6,
          cancelButton: S.of(context).g_key_79,
          localizedFallbackTitle: S.of(context).g_face_8,
        );
      }else{
        authMessage=auth_android.AndroidAuthMessages(
          biometricHint: S.of(context).g_face_1,
          biometricNotRecognized: S.of(context).g_face_2,
          biometricRequiredTitle: S.of(context).g_face_3,
          biometricSuccess: S.of(context).g_face_4,
          cancelButton: S.of(context).g_key_79,
          goToSettingsButton: S.of(context).g_face_5,
          goToSettingsDescription: S.of(context).g_face_6,
          signInTitle: S.of(context).g_face_7,
        );
      }
      authenticated = await auth.authenticate(
          localizedReason:
          S.of(context).g_face_10,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
          authMessages: [
            authMessage
          ]
      );
    } on PlatformException catch (e) {
      setState(() {
        faceCheck=2;
        faceErrorMessage=e.toString();
      });
      return;
    }
    setState(() {
      faceCheck=authenticated?1:2;
      if(authenticated){
        faceErrorMessage="";
      }else{
        faceErrorMessage=S.of(context).g_lock_key6;
      }
    });
  }
  //跳转 设置安全设置页
  Future<void> pushSetting() async {
    await Navigator.pushNamed(context, "securitySetting");
    initSecurity();
  }
  Future<void> pushEditWallet() async {
    int wIndex=Provider.of<WalletActionProvider>(context,listen: false).walletIndex;
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>EditWalletPassword(Provider.of<WalletActionProvider>(context,listen: false).walletInfo, wIndex)));
    initSecurity();
  }
  Future<bool> _pageBack(){
    if(Navigator.canPop(context)){
      Navigator.pop(context,false);
    }else{
      SystemNavigator.pop();
    }
    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pageBack();
      },
      child: Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).s_key_11,
          actions: [
            InkWell(
              onTap: (){
                pushSetting();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
                child: Image.asset(
                  'assets/img/Setting.png',
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  width: ScreenUtil().setWidth(40.0),
                  height:ScreenUtil().setWidth(40.0),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                  child:Column(
                    children: vWidget(),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Column(
                  children: [
                    Divider(
                      height: ScreenUtil().setWidth(1),
                      indent: 0,
                      endIndent: 0,
                    ),
                    Container(
                      height: ScreenUtil().setWidth(148.0),
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0),),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(88.0),
                              child: buttonStyle5(context, (){
                                closeKeyboard();
                                if(load==Load.loading)return;
                                Navigator.pop(context,false);
                              },
                                S.of(context).g_key_79,
                                AppThemeUtils.getColorByKey(context, load==Load.finish?AppThemeKeys.mainButtonTextColor.name:AppThemeKeys.mainButtonBgColor3.name),
                                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                                borderColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(30.0),),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              height: ScreenUtil().setWidth(88.0),
                              child: buttonStyle6(context, ()async{
                                closeKeyboard();
                                if(load==Load.loading) {
                                  return;
                                }
                                if(showWalletPassword==false && securityMap['face']==false && securityMap['email']==false //&& securityMap['google']==false
                                ) {
                                  return;
                                }
                                if(securityMap['face']){
                                  if(faceCheck != 1){
                                    faceErrorMessage=S.of(context).verification;
                                    setState(() {});
                                    return;
                                  }else{
                                    faceErrorMessage="";
                                    setState(() {});
                                  }
                                }
                                setState(() {
                                  load=Load.loading;
                                });
                                bool rValue=false;
                                if(showWalletPassword==true){
                                  //交易
                                  rValue=checkPwd();
                                  if(rValue==false){
                                    setState(() {
                                      load=Load.finish;
                                    });
                                    return;
                                  }
                                }
                                if(securityMap['email']){
                                  rValue=await checkEmailVerification();
                                  if (!context.mounted) return;
                                  if(rValue==false){
                                    setState(() {
                                      load=Load.finish;
                                    });
                                    return;
                                  }
                                }
                                if (!context.mounted) return;
                                setState(() {
                                  load=Load.finish;
                                });
                                Navigator.pop(context,true);
                              },
                                S.of(context).g_key_78,
                                AppThemeUtils.getColorByKey(context, (load==Load.finish && (showWalletPassword || securityMap['face'] || securityMap['email'] //|| securityMap['google']
                                ))?AppThemeKeys.mainButtonBgColor.name:AppThemeKeys.mainButtonBgColor3.name),
                                AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                                load==Load.loading,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> vWidget(){
    List<Widget> rw=[];
    rw.add(walletPassword());
    if(securityMap['email']){
      rw.insert(1, walletEmail());
    }else{
      rw.add(walletEmail());
    }
    if(securityMap['face']){
      rw.insert(1, walletFace());
    }else{
      rw.add(walletFace());
    }
    rw.add(SizedBox(height: ScreenUtil().setWidth(50.0),));
    return rw;
  }
  //钱包密码
  Widget walletPassword(){
    if(showWalletPassword){
      return Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_t_32,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(32.0),right: ScreenUtil().setWidth(32.0),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                      obscureText:obscure,
                      controller: pwdTextEditingController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: S.of(context).g_key_t_35,
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      maxLines: 1,
                      onEditingComplete: (){
                        closeKeyboard();
                      },
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        obscure=!obscure;
                      });
                    },
                    child: SizedBox(
                      height: ScreenUtil().setWidth(40.0),
                      width: ScreenUtil().setWidth(40.0),
                      child: Image.asset(
                        "assets/login/${obscure?'icon_denglu_yincang':'icon_denglu_xianshi'}.png",
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: pwdErrorMessage!="",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    pwdErrorMessage,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40.0),),
          ],
        ),
      );
    }else{
      return Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_key_t_32,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      S.of(context).g_lock_key24,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      if(AppGlobals.userInfo==null){
                        showLoginDialog();
                      }else{
                        pushEditWallet();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30.0))),
                      ),
                      child: Text(
                        S.of(context).google_verification_message10,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40.0),),
          ],
        ),
      );
    }
  }
  //生物识别验证
  Widget walletFace(){
    if(securityMap['face']){
      String contentStr="";
      if(faceCheck==1){
        contentStr=S.of(context).g_lock_key5;
      }else if(faceCheck==2){
        contentStr=S.of(context).g_lock_key6;
      }
      return Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).g_lock_key1,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(32.0),
                right: ScreenUtil().setWidth(32.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              ),
              height: ScreenUtil().setWidth(100.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      contentStr,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(24.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: ()async{
                      faceVerification();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30.0))),
                      ),
                      child: Text(
                        S.of(context).Verification,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: faceErrorMessage!="",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    faceErrorMessage,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40.0),),
          ],
        ),
      );
    }
    else{
      return Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    S.of(context).g_lock_key1,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      S.of(context).g_lock_key8,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      if(AppGlobals.userInfo==null){
                        showLoginDialog();
                      }else {
                        pushSetting();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30.0))),
                      ),
                      child: Text(
                        S.of(context).google_verification_message10,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40.0),),
          ],
        ),
      );
    }
  }
  //邮箱验证
  Widget walletEmail(){
    if(securityMap['email']){
      return Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).email_verification,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(32.0),right: ScreenUtil().setWidth(32.0),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                      controller: emailTextEditingController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: S.of(context).rest_Please_enter,
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      maxLines: 1,
                      onEditingComplete: (){
                        closeKeyboard();
                      },
                    ),
                  ),
                  walletEmailVerification(),
                ],
              ),
            ),
            Visibility(
              visible: emailErrorMessage!="",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    emailErrorMessage,
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                      fontSize: ScreenUtil().setSp(26.0),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(40.0),),
          ],
        ),
      );
    }
    else{
      return Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).email_verification,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      S.of(context).email_verification_message2,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        fontSize: ScreenUtil().setSp(28.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: ()async{
                      if(AppGlobals.userInfo==null){
                        showLoginDialog();
                      }else {
                        pushSetting();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                        borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30.0))),
                      ),
                      child: Text(
                        S.of(context).google_verification_message10,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                        ),
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
  }
  //发送邮箱验证码按钮
  Widget walletEmailVerification(){
    Color bgColor=AppThemeUtils.getColorByKey(context,AppThemeKeys.mainButtonBgColor.name);
    Widget leftWidget=SizedBox();
    if(emailLoad==Load.loading){
      bgColor=AppThemeUtils.getColorByKey(context,AppThemeKeys.itemBorderColor.name);
      leftWidget=SizedBox(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        child: CircularProgressIndicator(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),),
      );
    }else if(emailSendWait){
      bgColor=AppThemeUtils.getColorByKey(context,AppThemeKeys.itemBorderColor.name);
      leftWidget=Container(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
        child: Text(
          '($emailSendWaitNum)',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24.0),
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
          ),
        ),
      );
    }
    return InkWell(
      onTap: (){
        getEmailVerification();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(30.0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leftWidget,
            Text(
              S.of(context).Verification,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //登录提醒
  Future<void> showLoginDialog() async {
    final flag = await tipsDialog6(context, title:S.of(context).login_need_login,);
    if (!mounted) return;
    if (flag != null && flag) {
      await Navigator.pushNamed(context, "/LoginPage",);
      if (!mounted) return;
      Navigator.popUntil(context, ModalRoute.withName("/"));
    }
  }
}
