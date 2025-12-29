import 'dart:async';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/di/service_locator_setup.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/sp_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityGoogleVedification extends StatefulWidget{
  @override
  _SecurityGoogleVedificationState createState()=>_SecurityGoogleVedificationState();
}
class _SecurityGoogleVedificationState extends State<SecurityGoogleVedification>{
  TextEditingController pwdTextEditingController=TextEditingController();
  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController googleTextEditingController=TextEditingController();
  bool obscure=true;//是否显示密码
  String pwdErrorMessage="";//错误提示
  String emailErrorMessage="";
  String googleErrorMessage="";

  int emailSendWaitNum=60;//发送邮件倒计时
  bool emailSendWait=false;//发送邮件是否等待
  Load load=Load.finish;
  Load emailLoad=Load.finish;
  Load googleLoad=Load.finish;

  String walletName="";

  //账号安全
  Map<String,dynamic> securityMap={
    "email":false,
    "google":false,
    "face":false,
  };
  UserInfoApi? _userInfoAPI;
  UserInfoApi get userInfoAPI{
    if(_userInfoAPI==null){
      _userInfoAPI=UserInfoApi();
    }
    return _userInfoAPI!;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initWalletPassword();
    init_security();
  }
  // 加载钱包名 - 使用 IWalletService 替代 WalletActionProvider
  initWalletPassword() async {
    final walletService = ServiceLocatorSetup.walletService;
    if (walletService == null) {
      walletName = '${S.current.g_key_6} ';
      setState(() {});
      return;
    }
    
    // 获取主钱包
    final mainWallet = walletService.getMainWallet();
    walletName = '${S.current.g_key_6} ${mainWallet?.name ?? ""}';
    setState(() {});
  }
  //加载安全设置爱
  init_security()async{
    Map<String,dynamic>? s=await SPUtil().getSecurity();
    if(s!=null){
      Map<String,dynamic>? userSecurityMap=s[AppGlobals.userInfo?.uuid??""];
      if(userSecurityMap!=null){
        setState(() {
          //securityMap=userSecurityMap;
          securityMap['email']=userSecurityMap['email'];
          securityMap['google']=userSecurityMap['google'];
          securityMap['face']=userSecurityMap['face']==null?false:userSecurityMap['face'];
        });
      }
    }
  }
  //获取邮箱验证码
  getEmailVerification()async{
    if(emailLoad==Load.loading)return;
    if(emailSendWait)return;//是否正在等待
    setState(() {
      emailLoad=Load.loading;
    });
    MessageModel mm=await userInfoAPI.getEmailVerification();
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
  starEmailSendWait(){
    Timer(Duration(seconds: 1),(){
      setState(() {
        emailSendWaitNum--;
      });
      print(emailSendWaitNum);
      if(emailSendWaitNum<=0){
        emailSendWaitNum=60;
        emailSendWait=false;
      }else{
        starEmailSendWait();
      }
    });
  }

  // 验证密码 - 使用 SPUtil 直接读取钱包信息验证密码
  checkPwd() async {
    String pwdStr = pwdTextEditingController.text;
    if (pwdStr == "") {
      setState(() {
        pwdErrorMessage = S.of(context).g_key_t_33;
      });
      return false;
    }
    
    // 从 SPUtil 获取钱包列表进行密码验证
    Map<String, dynamic>? walletAll = await SPUtil().getWallsetInfo();
    WalletInfo? walletInfo;
    
    if (walletAll != null) {
      String userUUID = AppGlobals.userInfo?.uuid ?? "";
      Map<String, dynamic>? walletUser = walletAll[userUUID];
      if (walletUser != null) {
        List<dynamic> walletInfos = walletUser["wallet"] ?? [];
        List<WalletInfo> walletList = walletInfos
            .map((e) => WalletInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // 查找主钱包
        int mainIndex = walletList.indexWhere((e) => e.mainWallet == true);
        if (mainIndex != -1) {
          walletInfo = walletList[mainIndex];
        } else if (walletList.isNotEmpty) {
          walletInfo = walletList.first;
        }
      }
    }
    
    String oldPwdStr = walletInfo?.password ?? "";
    if (oldPwdStr != pwdStr) {
      setState(() {
        pwdErrorMessage = S.of(context).g_key_t_34;
      });
      return false;
    }
    setState(() {
      pwdErrorMessage = "";
    });
    return true;
  }
  //验证邮箱验证码
  checkEmailVerification()async{
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
    MessageModel mm= await userInfoAPI.checkEmailVerification(codeStr);
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
  //谷歌验证
  checkGoogleVerification()async{
    String codeStr=googleTextEditingController.text;
    if(codeStr==""){
      setState(() {
        googleErrorMessage=S.of(context).rest_Please_enter;
      });
      return false;
    }
    if(codeStr.length!=6){
      setState(() {
        googleErrorMessage=S.of(context).email_code_input_error;
      });
      return false;
    }
    MessageModel mm= await userInfoAPI.checkGoogle(codeStr);
    if(mm.error){
      setState(() {
        googleErrorMessage=S.of(context).email_code_input_error;
      });
      return false;
    }else{
      if(AppGlobals.userInfo!.bind_google_auth_state==false){
        AppGlobals.userInfo!.bind_google_auth_state=true;
        await SPUtil().saveUserInfo(AppGlobals.userInfo!);
      }
      setState(() {
        googleErrorMessage="";
      });
      return true;
    }
  }

  //保存设置
  saveSecurity()async{
    SPUtil sPUtils=SPUtil();
    Map<String,dynamic>? s=await sPUtils.getSecurity();
    if(s==null){
      s={};
    }
    s[AppGlobals.userInfo?.uuid??""]=securityMap;
    await sPUtils.setSecurity(s);
    setState(() {
    });
  }

  //关闭键盘
  closeKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).Verification,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  walletGoogle(),
                  walletEmail(),
                  walletPassword(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            height: ScreenUtil().setWidth(150.0),
            child: Container(
              height: ScreenUtil().setWidth(100.0),
              width: double.infinity,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
              padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(36.0),top: ScreenUtil().setWidth(26.0),left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0),),
              child: ButtonStyle2(context, ()async{
                //跳转
                if(load==Load.loading)return;
                setState(() {
                  load=Load.loading;
                });
                bool rValue=checkPwd();
                if(rValue==false){
                  setState(() {
                    load=Load.finish;
                  });
                  return;
                }
                if(securityMap['email']){
                  rValue=await checkEmailVerification();
                  if(rValue==false){
                    setState(() {
                      load=Load.finish;
                    });
                    return;
                  }
                }
                if(securityMap['google']==false){
                  rValue=await checkGoogleVerification();
                  if(rValue==false){
                    setState(() {
                      load=Load.finish;
                    });
                    return;
                  }
                }
                securityMap['google']=true;
                saveSecurity();
                setState(() {
                  load=Load.finish;
                });
                Navigator.popUntil(context, ModalRoute.withName('/securitySetting'));
              }, S.of(context).g_key_154,),
            ),
          ),
        ],
      ),
    );
  }

  //钱包密码
  Widget walletPassword(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).google_verification_message21(walletName),
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(30.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(30.0),),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
            constraints: BoxConstraints(
              minHeight: ScreenUtil().setWidth(88.0),
              maxHeight: ScreenUtil().setWidth(88.0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(30.0),
                    ),
                    obscureText:obscure,
                    controller: pwdTextEditingController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: S.of(context).g_key_t_35,
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil().setWidth(30.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18.0)),
                        isCollapsed: true
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
                  child: Container(
                    height: 22,
                    width: 22,
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
  }

  //邮箱验证
  Widget walletEmail(){
    if(securityMap['email']){
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).google_verification_message20,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(28.0),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(10.0),),
            Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(10.0),),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              ),
              constraints: BoxConstraints(
                minHeight: ScreenUtil().setWidth(88.0),
                maxHeight: ScreenUtil().setWidth(88.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setWidth(30.0),
                      ),
                      controller: emailTextEditingController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: S.of(context).rest_Please_enter,
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil().setWidth(30.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18.0)),
                      ),
                      maxLines: 1,
                      onEditingComplete: (){
                        closeKeyboard();
                      },
                    ),
                  ),
                  walletEmail_verification(),
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
      return SizedBox();
    }
  }
  //发送邮箱验证码按钮
  Widget walletEmail_verification(){
    //Color bgColor=AppThemeUtils.getColorByKey(context,AppThemeKeys.mainButtonBgColor);
    Widget leftWidget=SizedBox();
    if(emailLoad==Load.loading){
      //bgColor=AppThemeUtils.getColorByKey(context,AppThemeKeys.itemBorderColor);
      leftWidget=Container(
        height: ScreenUtil().setWidth(30.0),
        width: ScreenUtil().setWidth(30.0),
        child: CircularProgressIndicator(color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),),
      );
    }else if(emailSendWait){
      //bgColor=AppThemeUtils.getColorByKey(context,AppThemeKeys.itemBorderColor);
      leftWidget=Container(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(6.0)),
        child: Text(
          '(${emailSendWaitNum})',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30.0),
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
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leftWidget,
            Text(
              S.of(context).Verification,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //谷歌验证控件
  Widget walletGoogle(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).google_verification_message19,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(28.0),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(10.0),),
          Container(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(30.0),right: ScreenUtil().setWidth(10.0),),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(8.0))),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            ),
            constraints: BoxConstraints(
              maxHeight: ScreenUtil().setWidth(88.0),
              minHeight: ScreenUtil().setWidth(88.0),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setWidth(30.0),
                    ),
                    controller: googleTextEditingController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(18.0)),
                      hintText: S.of(context).rest_Please_enter,
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setWidth(30.0),
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
                  onTap: ()async{
                    ClipboardData? cd = await Clipboard.getData(Clipboard.kTextPlain);
                    if(cd!=null){
                      if(cd.text!=null && cd.text != "null"){
                        googleTextEditingController.text=cd.text!;
                        setState(() {
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0),horizontal: ScreenUtil().setWidth(20.0)),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
                    ),
                    child: Text(
                      S.of(context).g_key_166,
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
            visible: googleErrorMessage!="",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  googleErrorMessage,
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
}